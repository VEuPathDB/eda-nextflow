#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::InsertAnnotationProperties \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --attributesFile $params.optionalAnnotationPropertiesFile \\
    --schema $params.schema \\
    --commit

echo "DONE"
