#!/usr/bin/env bash

set -euo pipefail

internalNoCommonDef="";

if [ "$params.noCommonDef" == "true" ]; then
  internalNoCommonDef="--noCommonDef";
fi

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi

ga ApiCommonData::Load::Plugin::LoadEntityTypeAndAttributeGraphs \$internalNoCommonDef \$internalGusConfigFile \\
    --logDir \$PWD \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
