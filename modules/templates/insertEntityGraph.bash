#!/usr/bin/env bash

set -euo pipefail

cleanup() {
  if [ "$params.optionalGadmDataDirectory"   != "NA" ] &&  [ "${params.optionalGadmSocketDirectory}" != "NA" ] && [ "${params.optionalGadmPort}" != "NA" ]; then
    singularity exec instance://${workflow.runName} pg_ctl stop -D /var/lib/postgresql/data -m smart
    singularity instance stop ${workflow.runName}
  fi
  exit 1;
}

# Trap the ERR signal and run the cleanup function
trap 'cleanup' ERR

POSTGRES_IMAGE="docker://postgis/postgis:15-3.4";
internalGadmDsn="";
internalUseOntologyTermTableForTaxonTerms="";
internalUseIsaSimpleParser="";
internalOntologyMappingFile="";
internalDateObfuscationFile="";
internalValueMappingFile="";
internalOntologyMappingOverrideFile="";
internalInvestigationSubset="";
internalLoadProtocolTypeAsVariable="";
internalProtocolVariableSourceId="";

if [ "$params.investigationSubset" != "NA" ] ; then
  internalInvestigationSubset="--investigationSubset $params.investigationSubset";
fi

if [ "$params.useOntologyTermTableForTaxonTerms" == true ] ; then
    internalUseOntologyTermTableForTaxonTerms="--useOntologyTermTableForTaxonTerms";
fi

if [ "$params.loadProtocolTypeAsVariable" == true ] ; then
    internalLoadProtocolTypeAsVariable="--loadProtocolTypeAsVariable";
fi

if [ "$params.protocolVariableSourceId" != "NA" ] ; then
  internalProtocolVariableSourceId="--protocolVariableSourceId $params.protocolVariableSourceId";
fi

if [ "$params.optionalGadmDataDirectory"   != "NA" ] &&  [ "${params.optionalGadmSocketDirectory}" != "NA" ] && [ "${params.optionalGadmPort}" != "NA" ]; then
    internalGadmDsn="--gadmDsn dbi:Pg:database=gadm;host=${params.optionalGadmSocketDirectory};port=${params.optionalGadmPort}"
    singularity instance start --bind ${params.optionalGadmSocketDirectory}:/var/run/postgresql --bind ${params.optionalGadmDataDirectory}:/var/lib/postgresql/data \$POSTGRES_IMAGE $workflow.runName

    APPTAINER_PGDATA=/var/lib/postgresql/data APPTAINERENV_PGPORT=${params.optionalGadmPort} APPTAINERENV_POSTGRES_PASSWORD=mypass singularity run instance://${workflow.runName} -p ${params.optionalGadmPort} & pid=\$!
    timeout 90s bash -c "until singularity exec instance://${workflow.runName} pg_isready -p ${params.optionalGadmPort}; do sleep 5 ; done;"
fi


# two commas here makes string lower case
if [ "$params.isaFormat" == "simple" ] ; then
    internalInvestigationFile="${params.studyDirectory}/${params.investigationBaseName}";
    internalOntologyMappingFile="--ontologyMappingFile ${params.webDisplayOntologyFile}";
    internalUseIsaSimpleParser="--isSimpleConfiguration ";

    if [ "${params.optionalDateObfuscationFile}" != "NA" ] ; then
        internalDateObfuscationFile="--dateObfuscationFile ${params.optionalDateObfuscationFile}";
    fi

    if [ "${params.optionalValueMappingFile}" != "NA" ] ; then
        internalValueMappingFile="--valueMappingFile ${params.optionalValueMappingFile}";
    fi

    if [ "${params.optionalOntologyMappingOverrideFile}" != "NA" ] ; then
        internalOntologyMappingOverrideFile="--ontologyMappingOverrideFileBaseName ${params.optionalOntologyMappingOverrideFile}";
    fi
fi

ga ApiCommonData::Load::Plugin::InsertEntityGraph \$internalLoadProtocolTypeAsVariable \$internalProtocolVariableSourceId \$internalUseOntologyTermTableForTaxonTerms \$internalInvestigationSubset \$internalUseIsaSimpleParser \$internalOntologyMappingFile \$internalDateObfuscationFile \$internalValueMappingFile \$internalOntologyMappingOverrideFile \$internalGadmDsn \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --investigationBaseName $params.investigationBaseName \\
  --metaDataRoot $params.studyDirectory \\
  --schema $params.schema

if [ "$params.optionalGadmDataDirectory"   != "NA" ] &&  [ "${params.optionalGadmSocketDirectory}" != "NA" ] && [ "${params.optionalGadmPort}" != "NA" ]; then
   cleanup
fi


if [ \'$params.speciesReconciliationOntologySpec\' != "NA" ]; then
  reconcilePopBioSpecies.pl --fallbackSpecies \'$params.speciesReconciliationFallbackSpecies\' --veupathOntologySpec \'$params.speciesReconciliationOntologySpec\' --extDbRlsSpec \'$extDbRlsSpec\'
fi

echo "DONE";
