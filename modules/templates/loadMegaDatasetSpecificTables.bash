#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::LoadMegaDatasetSpecificEntityGraph $params.internalMegaStudyYaml \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
