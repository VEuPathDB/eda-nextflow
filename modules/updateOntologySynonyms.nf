#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process updateOntologySynonyms {
    tag "plugin"

    input:
    val webDisplayOntologySpec
    stdin

    output:
    val webDisplayOntologySpec, emit: webDisplayOntologySpec
    stdout emit: verbiage

    when:
    file(params.internalUpdateSynonymsFile).exists()

    script:
    template 'updateOntologySynonyms.bash'


    stub:
    """
    echo "insert annotatino properties"
    """


}
