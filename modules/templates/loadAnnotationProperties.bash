#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::LoadAnnotationProperties \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --annotationPropertiesFile TODO
    --schema $params.schema \\
    --commit

echo "DONE"
