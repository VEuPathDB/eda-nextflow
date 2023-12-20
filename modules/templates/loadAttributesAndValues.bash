#!/usr/bin/env bash

set -euo pipefail

internalRunRLocally="";
if [ "$params.schema" == "ApidbUserDatasets" ] ; then
    internalRunRLocally="--runStatsScriptLocally";
fi

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi


ga ApiCommonData::Load::Plugin::LoadAttributesFromEntityGraph \$internalRunRLocally \$internalGusConfigFile \\
    --logDir \$PWD \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
    --schema $params.schema \\
    --commit

echo "DONE"
