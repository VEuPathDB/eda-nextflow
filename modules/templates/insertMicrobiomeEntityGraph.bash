#!/usr/bin/env bash

set -euo pipefail

internalValueMappingFile="";
if [ -e $params.optionalValueMappingFile ]; then 
  internalValueMappingFile=" --valueMappingFile ${params.optionalValueMappingFile}"
fi

internalOntologyMappingOverrideFile="";
if [ -e $params.optionalOntologyMappingOverrideFile ]; then 
  internalOntologyMappingOverrideFile="--ontologyMappingOverrideFile ${params.optionalOntologyMappingOverrideFile}"
fi

internalIsRelativeAbundance="";
if [ "$params.isRelativeAbundance" == true ] ; then
    internalIsRelativeAbundance="--isRelativeAbundance";
fi

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi

ga ApiCommonData::Load::Plugin::MBioInsertEntityGraph \$internalOntologyMappingOverrideFile \$internalValueMappingFile \$internalIsRelativeAbundance \$internalGusConfigFile \\
  --commit \\
  --investigationFile "${studyDir}/${params.investigationBaseName}" \\
  --sampleDetailsFile "${studyDir}/${params.sampleDetailsFile}" \\
  --mbioResultsDir "${studyDir}/${params.assayResultsDirectory}" \\
  --mbioResultsFileExtensions "$params.assayResultsFileExtensionsJson" \\
  --dieOnFirstError 1 \\
  --ontologyMappingFile $ontologyMappingOrOwlFile \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --schema $params.schema \\
  --useOntologyTermTableForTaxonTerms 1

echo "DONE" 
