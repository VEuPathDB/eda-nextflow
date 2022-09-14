#!/usr/bin/env bash

set -euo pipefail

ga GUS::Supported::Plugin::InsertOntologySynonymAttributes \\
--extDbRlsSpec \'$webDisplayOntologySpec\' \\
--attributesFile ${params.internalUpdateSynonymsFile} \\
--append 1 \\
--commit

echo "DONE";
