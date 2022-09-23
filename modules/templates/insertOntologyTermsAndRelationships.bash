#!/usr/bin/env bash

set -euo pipefail

ga GUS::Supported::Plugin::InsertOntologyTermsAndRelationships \\
    -inFile ${params.webDisplayOntologyFile} \\
    --owlReader ApiCommonData::Load::OwlReader \\
    --extDbRlsSpec \'$extDbRlsSpec\' \\
    --relTypeExtDbRlsSpec 'Ontology_Relationship_Types_RSRC|%' \\
    --commit

echo "DONE Loading Ontology Terms And Relationships";
