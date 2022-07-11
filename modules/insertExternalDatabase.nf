#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process insertExternalDatabaseAndRelease {
    input:
    val databaseName
    val databaseVersion

    output:
    val "$databaseName|$databaseVersion"

    script:
    template 'insertExternalDatabaseAndRelease.bash'
}
