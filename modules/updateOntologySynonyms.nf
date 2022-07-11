#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process updateOntologySynonyms {
    input:
    val webDisplayOntologySpec

    output:
    val webDisplayOntologySpec

    when:
    file(params.internalUpdateSynonymsFile).exists()

    script:
    template 'updateOntologySynonyms.bash'
}
