#!/usr/bin/env nextflow
nextflow.enable.dsl=2

webDisplayOntologySpec = Channel.value(params.webDisplayOntologySpec)
extDbRlsSpec = Channel.value(params.extDbRlsSpec)

process makeDownloadFiles {
    input:
    stdin
    val extDbRlsSpec
    val webDisplayOntologySpec

    output:
    path '*.txt'

    script:
    template 'makeDownloadFiles.bash'

    stub:
    """
    echo "make download files"
    """
}



process makeBinaryFiles {
    input:
    stdin

    script:
    """
    singularity exec --bind $GUS_HOME/config/gus.config:/project/gus.config --bind ${launchDir}/forDownloads:/data  docker://veupathdb/tool-eda-file-dumper:latest dumpFiles 'TODO_STUDY_NAME' /data /project/gus.config 
    """

    stub:
    """
    echo "make download files"
    """
}



workflow dumpFiles {
    take:
    datasetTablesOut

    main:

//    makeDownloadFiles(datasetTablesOut, extDbRlsSpec, webDisplayOntologySpec)
    makeBinaryFiles(datasetTablesOut);
    

}
