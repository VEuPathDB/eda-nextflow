#!/usr/bin/env bash

set -euo pipefail


ga ApiCommonData::Load::Plugin::MBioInsertEntityGraph \\
  --commit \\
  --investigationFile "${params.studyDirectory}/${params.investigationBaseName}" \\
  --sampleDetailsFile "${params.studyDirectory}/${params.sampleDetailsFile}" \\
  --mbioResultsDir "${params.studyDirectory}/$params.assayResultsDirectory" \\
  --mbioResultsFileExtensions $params.assayResultsFileExtensionsJson \\
  --dieOnFirstError 1 \\
  --ontologyMappingFile $params.webDisplayOntologyFile \\
  --ontologyMappingOverrideFile $params.optionalOntologyMappingOverrideFile \\
  --valueMappingFile $params.optionalValueMappingFile \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --schema $params.schema

echo "DONE";
