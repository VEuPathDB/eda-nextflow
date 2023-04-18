#!/usr/bin/env bash

set -euo pipefail
internalInvestigationFile="${params.studyDirectory}/${params.investigationBaseName}";
ga ApiCommonData::Load::Plugin::MBioInsertEntityGraph \\
  --commit \\
  --investigationFile \$internalInvestigationFile \\
  --sampleDetailsFile $params.sampleDetailsFile \\
  --mbioResultsDir $params.assayResultsDirectory \\
  --mbioResultsFileExtensions $params.assayResultsFileExtensionsJson \\
  --dieOnFirstError 1 \\
  --ontologyMappingFile $params.ontologyMappingFile \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --schema $params.schema


echo "DONE";
