#!/usr/bin/env bash

set -euo pipefail

internalUseOntologyTermTableForTaxonTerms="";
internalUseIsaSimpleParser="";
internalOntologyMappingFile="";
internalDateObfuscationFile="";
internalValueMappingFile="";
internalOntologyMappingOverrideBaseName="";
internalInvestigationSubset="";

if [ "$params.investigationSubset" != "NA" ] ; then
  internalInvestigationSubset="--investigationSubset $params.investigationSubset";
fi

if [ "$params.useOntologyTermTableForTaxonTerms" = true ] ; then
    internalUseOntologyTermTableForTaxonTerms="--useOntologyTermTableForTaxonTerms";
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

    if [ "${params.optionalOntologyMappingOverrideBaseName}" != "NA" ] ; then
        internalOntologyMappingOverrideBaseName="--ontologyMappingOverrideFileBaseName ${params.optionalOntologyMappingOverrideBaseName}";
    fi
fi

ga ApiCommonData::Load::Plugin::InsertEntityGraph \$internalUseOntologyTermTableForTaxonTerms \$internalInvestigationSubset \$internalUseIsaSimpleParser \$internalOntologyMappingFile \$internalDateObfuscationFile \$internalValueMappingFile \$internalOntologyMappingOverrideBaseName \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --investigationBaseName $params.investigationBaseName \\
  --metaDataRoot $params.studyDirectory \\
  --schema $params.schema

  if [ \'$params.speciesReconciliationOntologySpec\' != "NA" ]; then
    reconcilePopBioSpecies.pl --fallbackSpecies \'$params.speciesReconciliationFallbackSpecies\' --veupathOntologySpec \'$params.speciesReconciliationOntologySpec\' --extDbRlsSpec \'$extDbRlsSpec\'
  fi


echo "DONE";
