#!/usr/bin/env nextflow
nextflow.enable.dsl=2


include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'

include { updateOntologySynonyms as updateEntityTypes } from './updateOntologySynonyms.nf' addParams(internalUpdateSynonymsFile: params.optionalEntityTypeFile)
include { updateOntologySynonyms as updateOrdinals } from './updateOntologySynonyms.nf' addParams(internalUpdateSynonymsFile: params.optionalOrdinalsFile)
include { updateOntologySynonyms as updateOwlAttributes } from './updateOntologySynonyms.nf' addParams(internalUpdateSynonymsFile: params.optionalOwlAttributesFile)

process insertOntologyTermsAndRelationships {
    tag "plugin"

    input:
    val extDbRlsSpec
    stdin

    output:
    val extDbRlsSpec
    stdout

    script:
    template 'insertOntologyTermsAndRelationships.bash'
}

process startUpdateSynonyms {
    input:
    val extDbRlsSpec

    output:
    val extDbRlsSpec
    stdout

    script:
    """
    echo "Ready to update ontology synonyms!"
    """
}


workflow loadOntologyStuff {
    main:
    webDisplaySpecChannel = Channel.value(params.webDisplayOntologySpec)

    if(params.loadWebDisplayOntologyFile) {
        def (databaseName, databaseVersion) = params.webDisplayOntologySpec.split("\\|");

        insertExternalDatabaseAndRelease(databaseName, databaseVersion) \
            | insertOntologyTermsAndRelationships \
            | (updateEntityTypes & updateOrdinals & updateOwlAttributes)
    }
    else {
        startUpdateSynonyms(webDisplaySpecChannel) \
            | (updateEntityTypes & updateOrdinals & updateOwlAttributes)

    }

    emit:
    extDbRlsSpec = webDisplaySpecChannel;
    ontologyOut = webDisplaySpecChannel.concat(updateEntityTypes.out.verbiage, updateOrdinals.out.verbiage, updateOwlAttributes.out.verbiage);
}
