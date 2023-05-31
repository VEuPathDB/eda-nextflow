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

ga ApiCommonData::Load::Plugin::MBioInsertEntityGraph \$internalOntologyMappingOverrideFile \$internalValueMappingFile \\
  --commit \\
  --investigationFile "${params.studyDirectory}/${params.investigationBaseName}" \\
  --sampleDetailsFile "${params.studyDirectory}/${params.sampleDetailsFile}" \\
  --mbioResultsDir "${params.studyDirectory}/${params.assayResultsDirectory}" \\
  --mbioResultsFileExtensions $params.assayResultsFileExtensionsJson \\
  --dieOnFirstError 1 \\
  --ontologyMappingFile $params.webDisplayOntologyFile \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --schema $params.schema

echo "DONE" 
