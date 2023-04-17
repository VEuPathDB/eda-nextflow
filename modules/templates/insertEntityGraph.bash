#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::InsertEntityGraph $internalUseOntologyTermTableForTaxonTerms $internalInvestigationSubset $internalUseIsaSimpleParser $internalOntologyMappingFile $internalDateObfuscationFile $internalValueMappingFile $internalOntologyMappingOverrideBaseName \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --investigationBaseName $params.investigationBaseName \\
  --metaDataRoot $params.studyDirectory \\
  --schema $params.schema

  if [ \'$params.speciesReconciliationOntologySpec\' != "NA" ]; then
    reconcilePopBioSpecies.pl --fallbackSpecies \'$params.speciesReconciliationFallbackSpecies\' --veupathOntologySpec \'$params.speciesReconciliationOntologySpec\' --extDbRlsSpec \'$extDbRlsSpec\'
  fi


echo "DONE";
