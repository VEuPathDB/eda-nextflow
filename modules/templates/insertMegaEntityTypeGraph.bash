#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::InsertMegaEntityGraph  $params.internalMegaStudyYaml \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --studyStableId $params.megaStudyStableId \\
  --schema $params.schema

echo "DONE"
