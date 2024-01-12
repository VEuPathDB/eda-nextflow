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



# Check if any .cache files were found. if not make empty
cache_files=\$(find . -maxdepth 1 -type f -name "*.cache")
if [ -z "\$cache_files" ]; then
    # No .txt files found, create a file named empty.txt.
    touch empty.cache
fi


echo "DONE"
