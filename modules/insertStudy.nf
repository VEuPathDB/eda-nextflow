#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'

process insertEntityTypeGraph {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdout

    script:

    if(params.optionalMegaStudyYaml != "NA" && file(params.optionalMegaStudyYaml).exists()) {
        template 'insertMegaEntityTypeGraph.bash'
    }

    else if(params.project == "MicrobiomeDB") {
        template 'insertMicrobiomeEntityGraph.bash'
    }

    else {
        template 'insertEntityGraph.bash'
    }
}

process loadAttributesAndValues {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdout

    script:

    template 'loadAttributesAndValues.bash'
}

process loadEntityTypeAndAttributeGraphs {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdout

    script:
    template 'loadEntityTypeAndAttributeGraphs.bash'
}

process loadDatasetSpecificTables {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    val extDbRlsSpec, emit: extDbRlsSpec
    val webDisplayOntologySpec, emit: webDisplayOntologySpec
    stdout

    script:
    if(params.optionalMegaStudyYaml != "NA"  && file(params.optionalMegaStudyYaml).exists()) {
        template 'loadMegaDatasetSpecificTables.bash'
    }
    else{
        template 'loadDatasetSpecificTables.bash'
    }
}



workflow loadStudy {
    take:
    webDisplayOntologySpec
    logData

    main:
//    extDbSpec = Channel.value(params.extDbRlsSpec)

    def (databaseName, databaseVersion) = params.extDbRlsSpec.split("\\|");
    insertExternalDatabaseAndRelease(databaseName, databaseVersion);

    insertEntityTypeGraph(insertExternalDatabaseAndRelease.out[0], webDisplayOntologySpec, logData.concat(insertExternalDatabaseAndRelease.out[1])) \
        | loadAttributesAndValues \
        | loadEntityTypeAndAttributeGraphs \
        | loadDatasetSpecificTables

//    emit:
//    loadDatasetSpecificTables.out.extDbRlsSpec
//    loadDatasetSpecificTables.out.webDisplayOntologySpec
}
