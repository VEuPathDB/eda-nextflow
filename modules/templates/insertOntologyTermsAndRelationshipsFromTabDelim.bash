#!/usr/bin/env bash

set -euo pipefail

internalGusConfigFile="";
if [ "$params.gusConfigFile" != "NA" ] ; then
  internalGusConfigFile="--gusConfigFile $params.gusConfigFile";
fi

plugin="GUS::Supported::Plugin::InsertOntologyFromTabDelim";
if [ "$params.schema" == "ApidbUserDatasets" ] ; then
    plugin="ApiCommonData::Load::Plugin::InsertOntologyFromTabDelimUD"
fi


ga \$plugin \$internalGusConfigFile \\
    --termFile $ontologyTerms \\
    --relFile $ontologyRelationships \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --commit

echo "DONE Loading Ontology Terms And Relationships";
