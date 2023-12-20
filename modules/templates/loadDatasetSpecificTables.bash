#!/usr/bin/env bash

set -euo pipefail

internalCollectionsYaml="";

if [ "$params.optionalCollectionsYaml" != "NA" ] ; then
  internalCollectionsYaml="--collectionsYaml $params.optionalCollectionsYaml";
fi

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi


ga ApiCommonData::Load::Plugin::LoadDatasetSpecificEntityGraph \$internalCollectionsYaml \$internalGusConfigFile \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
