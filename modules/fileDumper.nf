#!/usr/bin/env nextflow
nextflow.enable.dsl=2

webDisplayOntologySpec = Channel.value(params.webDisplayOntologySpec)
extDbRlsSpec = Channel.value(params.extDbRlsSpec)

process makeDownloadFiles {
    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin


    output:
    stdout

    script:
    template 'makeDownloadFiles.bash'

    stub:
    """
    echo "make download files"
    """
}

workflow dumpFiles {
    take:
    datasetTablesOut

    main:
    makeDownloadFiles(datasetTablesOut, extDBRlsSpec, webDisplaySpec)
    // TODO:  binary files for scalability
}
