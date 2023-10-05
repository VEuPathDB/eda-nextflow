#!/usr/bin/env bash

set -euo pipefail

internalNoCommonDef="";

if [ "$params.noCommonDef" == "true" ]; then
  internalNoCommonDef="--noCommonDef";
fi

ga ApiCommonData::Load::Plugin::LoadEntityTypeAndAttributeGraphs \$internalNoCommonDef \\
    --logDir \$PWD \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
