#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::MakeEntityDownloadFiles \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --fileBasename $params.downloadFileBaseName \\
  --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
  --outputDir \$PWD \\
  --schema $params.schema

echo "DONE";
