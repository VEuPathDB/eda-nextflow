#!/usr/bin/env bash

set -euo pipefail

echo ga ApiCommonData::Load::Plugin::LoadDatasetSpecificEntityGraph \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
