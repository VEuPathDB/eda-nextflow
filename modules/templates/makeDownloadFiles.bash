#!/usr/bin/env bash

set -euo pipefail

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi

ga ApiCommonData::Load::Plugin::MakeEntityDownloadFiles \$internalGusConfigFile \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --fileBasename $params.downloadFileBaseName \\
  --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
  --outputDir \$PWD \\
  --schema $params.schema

echo "DONE";
