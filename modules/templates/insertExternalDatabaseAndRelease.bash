#!/usr/bin/env bash

set -euo pipefail

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi


insertExternalDatabasePlugin="GUS::Supported::Plugin::InsertExternalDatabase";
insertExternalDatabaseReleasePlugin="GUS::Supported::Plugin::InsertExternalDatabaseRls";
if [ "$params.schema" == "ApidbUserDatasets" ] ; then
    insertExternalDatabasePlugin=ApiCommonData::Load::Plugin::InsertExternalDatabaseUD
    insertExternalDatabaseReleasePlugin=ApiCommonData::Load::Plugin::InsertExternalDatabaseRlsUD
fi

ga \$insertExternalDatabasePlugin \$internalGusConfigFile \\
--name $databaseName \\
--commit;

ga \$insertExternalDatabaseReleasePlugin \$internalGusConfigFile \\
--databaseName $databaseName \\
--databaseVersion $databaseVersion \\
--commit;

echo "DONE Loading External Database and Release";
