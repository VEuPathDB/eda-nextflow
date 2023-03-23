#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process makeDownloadFiles {
    input:
    val extDbRlsSpec
    val webDisplayOntologySpec

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec

    script:
    template 'makeDownloadFiles.bash'

    stub:
    """
    echo "make download files"
    """


}

workflow dumpFiles {
    take:
    extDbRlsSpec
    webDisplayOntologySpec

    main:
    makeDownloadFiles(extDbRlsSpec, webDisplayOntologySpec)
    // TODO:  binary files for scalability
}
