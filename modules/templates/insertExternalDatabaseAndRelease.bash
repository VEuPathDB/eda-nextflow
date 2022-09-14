#!/usr/bin/env bash

set -euo pipefail

ga GUS::Supported::Plugin::InsertExternalDatabase \\
--name $databaseName \\
--commit;

ga GUS::Supported::Plugin::InsertExternalDatabaseRls \\
--databaseName $databaseName \\
--databaseVersion $databaseVersion \\
--commit;

echo "DONE Loading External Database and Release";
