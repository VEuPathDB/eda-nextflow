#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::LoadEntityTypeAndAttributeGraphs \\
    --logDir \$PWD \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --ontologyExtDbRlsSpec \'$webDisplayOntologySpec\' \\
    --schema $params.schema \\
    --commit;

echo "DONE"
