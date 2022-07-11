#!/usr/bin/env bash

set -euo pipefail

echo ga GUS::Supported::Plugin::InsertExternalDatabase \\
--name $databaseName \\
--commit;

echo ga GUS::Supported::Plugin::InsertExternalDatabaseRls \\
--databaseName $databaseName \\
--databaseVersion $databaseVersion \\
--commit;

echo "DONE";
