#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'



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


process insertOntologyTermsAndRelationshipsFromTabDelim {
    tag "plugin"

    input:
    val(extDbRlsSpec)
    stdin
    path(ontologyTerms)
    path(ontologyRelationships)

    output:
    stdout

    script:
    template 'insertOntologyTermsAndRelationshipsFromTabDelim.bash'

    stub:
    """
    echo "initial insert ontology terms and relationships from tab delim"
    """
}


workflow loadInitialOntology {
    main:
    webDisplaySpecChannel = Channel.value(params.webDisplayOntologySpec)

    initOntologyOut = Channel.value("READY")

    if(params.loadWebDisplayOntologyFile) {
        def (databaseName, databaseVersion) = params.webDisplayOntologySpec.split("\\|");
        extDbRlsOut = insertExternalDatabaseAndRelease(tuple(databaseName, databaseVersion), initOntologyOut);
        initOntologyOut = insertOntologyTermsAndRelationships(webDisplaySpecChannel, extDbRlsOut);
    }

    emit:
    initOntologyOut
}

workflow loadOntologyFromTabDelim {
    take:
    studyDir
    ontologyTerms
    ontologyRelationships

    main:
    webDisplaySpecChannel = Channel.value(params.webDisplayOntologySpec)

    def (databaseName, databaseVersion) = params.webDisplayOntologySpec.split("\\|");
    extDbRlsOut = insertExternalDatabaseAndRelease(tuple(databaseName, databaseVersion), webDisplaySpecChannel);
    ontologyOut = insertOntologyTermsAndRelationshipsFromTabDelim(webDisplaySpecChannel, extDbRlsOut, ontologyTerms, ontologyRelationships);

    emit:
    ontologyOut
}
