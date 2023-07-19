#!/usr/bin/env nextflow
nextflow.enable.dsl=2

webDisplayOntologySpec = Channel.value(params.webDisplayOntologySpec)
extDbRlsSpec = Channel.value(params.extDbRlsSpec)

process makeDownloadFiles {
    publishDir "$params.resultsDirectory", pattern: "*.txt", mode: "copy" 

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
    val studies    

    script:
    """
    singularity exec --bind $GUS_HOME/config/gus.config:/project/gus.config --bind $params.resultsDirectory:/data  docker://veupathdb/tool-eda-file-dumper:latest dumpFiles ${studies[0]} /data /project/gus.config 
    """

    stub:
    """
    echo "make binary files"
    """
}



workflow dumpFiles {
    take:
    datasetTablesOut

    main:
    results =  makeDownloadFiles(datasetTablesOut, extDbRlsSpec, webDisplayOntologySpec)
    studies = results.flatten().filter( ~/.*Studies.txt$/).splitCsv(header:false, sep:"\t", by:1)
    makeBinaryFiles(datasetTablesOut, studies);
    

}
