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

    output:
    val extDbRlsSpec
    stdout

    script:
    template 'insertOntologyTermsAndRelationships.bash'
}


workflow loadOntologyStuff {
    main:
    webDisplaySpecChannel = Channel.value(params.webDisplayOntologySpec)
    logData = Channel.value("LOG")
    if(params.loadWebDisplayOntologyFile) {
        def (databaseName, databaseVersion) = params.webDisplayOntologySpec.split("\\|");

        insertExternalDatabaseAndRelease(databaseName, databaseVersion) \
         | insertOntologyTermsAndRelationships
            | (updateEntityTypes & updateOrdinals & updateOwlAttributes)
    }
    else {
        updateEntityTypes(webDisplaySpecChannel, logData);
        updateOrdinals(webDisplaySpecChannel, logData);
        updateOwlAttributes(webDisplaySpecChannel, logData);
    }

    emit:
    extDbRlsSpec = webDisplaySpecChannel.concat(updateEntityTypes.out.webDisplayOntologySpec, updateOrdinals.out.webDisplayOntologySpec, updateOwlAttributes.out.webDisplayOntologySpec).distinct();
    logData = logData.concat(updateEntityTypes.out.logData, updateOrdinals.out.logData, updateOwlAttributes.out.logData);
}
