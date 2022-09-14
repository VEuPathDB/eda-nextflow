#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process insertExternalDatabaseAndRelease {
    tag "plugin"

    input:
    val databaseName
    val databaseVersion

    output:
    val "$databaseName|$databaseVersion"
    stdout

    script:
    template 'insertExternalDatabaseAndRelease.bash'
}
