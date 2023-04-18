#!/usr/bin/env bash

set -euo pipefail

internalRunRLocally="";
if [ "$params.schema" == "ApidbUserDatasets" ] ; then
    internalRunRLocally="--runRLocally";
fi

ga ApiCommonData::Load::Plugin::LoadAttributesFromEntityGraph \$internalRunRLocally \\
    --logDir \$PWD \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
    --schema $params.schema \\
    --commit

echo "DONE"
