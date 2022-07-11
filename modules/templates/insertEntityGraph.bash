#!/usr/bin/env bash

set -euo pipefail

echo ga ApiCommonData::Load::Plugin::InsertEntityGraph $params.internalUseIsaSimpleParser $params.internalOntologyMappingFile $params.internalDateObfuscationFile $params.internalValueMappingFile $params.internalOntologyMappingOverrideBaseName \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --investigationBaseName $params.investigationBaseName \\
  --metaDataRoot $params.studyDirectory \\
  --schema $params.schema

echo "DONE";
