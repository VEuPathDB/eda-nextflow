#!/usr/bin/env bash

set -euo pipefail

if [ "$params.optionalCollectionsYaml" != "NA" ] ; then
  internalCollectionsYaml="--collectionsYaml $params.optionalCollectionsYaml";
fi


ga ApiCommonData::Load::Plugin::LoadDatasetSpecificEntityGraph \$internalCollectionsYaml \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
