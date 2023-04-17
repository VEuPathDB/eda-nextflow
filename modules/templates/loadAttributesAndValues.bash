#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::LoadAttributesFromEntityGraph $internalRunRLocally \\
    --logDir \$PWD \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
    --schema $params.schema \\
    --commit

echo "DONE"
