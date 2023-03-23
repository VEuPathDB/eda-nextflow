#!/usr/bin/env bash

set -euo pipefail

ga ApiCommonData::Load::Plugin::InsertEntityGraph $params.internalInvestigationSubset $params.internalUseIsaSimpleParser $params.internalOntologyMappingFile $params.internalDateObfuscationFile $params.internalValueMappingFile $params.internalOntologyMappingOverrideBaseName \\
  --commit \\
  --extDbRlsSpec \'$extDbRlsSpec\' \\
  --investigationBaseName $params.investigationBaseName \\
  --metaDataRoot $params.studyDirectory \\
  --schema $params.schema

  if [ \'$params.speciesReconciliationOntologySpec\' != "NA" ]; then
    reconcilePopBioSpecies.pl --fallbackSpecies \'$params.speciesReconciliationFallbackSpecies\' --veupathOntologySpec \'$params.speciesReconciliationOntologySpec\' --extDbRlsSpec \'$extDbRlsSpec\'
  fi


echo "DONE";
