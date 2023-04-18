#!/usr/bin/env bash

set -euo pipefail

internalMegaStudyYaml="";
if [ "$params.optionalMegaStudyYaml" != "NA" ] ; then
    internalMegaStudyYaml="--megaStudyYaml ${params.optionalMegaStudyYaml}";
fi

ga ApiCommonData::Load::Plugin::InsertMegaEntityGraph  \$internalMegaStudyYaml \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --studyStableId $params.megaStudyStableId \\
  --schema $params.schema

echo "DONE"
