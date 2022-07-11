#!/usr/bin/env nextflow
nextflow.enable.dsl=2


include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'

include { updateOntologySynonyms as updateEntityTypes } from './updateOntologySynonyms.nf' addParams(internalUpdateSynonymsFile: params.optionalEntityTypeFile)
include { updateOntologySynonyms as updateOrdinals } from './updateOntologySynonyms.nf' addParams(internalUpdateSynonymsFile: params.optionalOrdinalsFile)
include { updateOntologySynonyms as updateOwlAttributes } from './updateOntologySynonyms.nf' addParams(internalUpdateSynonymsFile: params.optionalOwlAttributesFile)

process insertOntologyTermsAndRelationships {
    input:
    val extDbRlsSpec

    output:
    val extDbRlsSpec

    script:
    template 'insertOntologyTermsAndRelationships.bash'
}




workflow loadOntologyStuff {
    main:
    if(params.loadWebDisplayOntologyFile) {
        def (databaseName, databaseVersion) = params.webDisplayOntologySpec.split("\\|");
        insertExternalDatabaseAndRelease(databaseName, databaseVersion) \
            | insertOntologyTermsAndRelationships \
            | ( updateEntityTypes & updateOrdinals & updateOwlAttributes)
    }
    else {
        webDisplaySpecChannel = Channel.value(params.webDisplayOntologySpec)
        webDisplaySpecChannel | ( updateEntityTypes & updateOrdinals & updateOwlAttributes)
    }

    emit:
    extDbRlsSpec = webDisplaySpecChannel.concat(updateEntityTypes.out, updateOrdinals.out, updateOwlAttributes.out).distinct()
}
