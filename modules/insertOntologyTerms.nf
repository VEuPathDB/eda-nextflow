#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'


// TODO:  make this work for tab file(s) and owl file
process insertOntologyTermsAndRelationships {
    tag "plugin"

    input:
    val(extDbRlsSpec)
    stdin

    output:
    stdout

    script:
    template 'insertOntologyTermsAndRelationships.bash'

    stub:
    """
    echo "initial insert ontology terms and relationships"
    """
}

workflow loadInitialOntology {
    main:
    webDisplaySpecChannel = Channel.value(params.webDisplayOntologySpec)

    initOntologyOut = Channel.value("READY")

    if(params.loadWebDisplayOntologyFile) {
        def (databaseName, databaseVersion) = params.webDisplayOntologySpec.split("\\|");
        extDbRlsOut = insertExternalDatabaseAndRelease(tuple databaseName, databaseVersion);
        initOntologyOut = insertOntologyTermsAndRelationships(webDisplaySpecChannel, extDbRlsOut);
    }

    emit:
    initOntologyOut
}
