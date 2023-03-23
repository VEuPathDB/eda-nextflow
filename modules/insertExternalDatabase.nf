#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process insertExternalDatabaseAndRelease {
    tag "plugin"

    input:
    tuple val(databaseName), val(databaseVersion)

    output:
    stdout


    script:
    template 'insertExternalDatabaseAndRelease.bash'

    stub:
    """
    echo "insert external database and release"
    """

}
