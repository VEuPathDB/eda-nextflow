#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process insertEntityTypeGraph {
    input:
    val extDbRlsSpec
    val webDisplayOntologySpec

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec

    script:

    if(params.optionalMegaStudyYaml && file(params.optionalMegaStudyYaml).exists()) {
        template 'insertMegaEntityTypeGraph.bash'
    }

    else if(params.project == "MicrobiomeDB") {
        template 'insertMicrobiomeEntityGraph.bash'
    }
//    else if(params.project == "VectorBase") {
//        template 'insertVectorBaseEntityGraph.bash'
//    }

    else if(params.isaFormat == "isatab") {
        template 'insertEntityGraphFromISATab.bash'
    }
    else {
        template 'insertEntityGraph.bash'
    }
}

process loadAttributesAndValues {
    input:
    val extDbRlsSpec
    val webDisplayOntologySpec

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec

    script:

    template 'loadAttributesAndValues.bash'
}

process loadEntityTypeAndAttributeGraphs {
    input:
    val extDbRlsSpec
    val webDisplayOntologySpec

    output:
    val extDbRlsSpec
    val webDisplayOntologySpec

    script:
    template 'loadEntityTypeAndAttributeGraphs.bash'
}

process loadDatasetSpecificTables {
    input:
    val extDbRlsSpec
    val webDisplayOntologySpec

    output:
    val extDbRlsSpec, emit: extDbRlsSpec
    val webDisplayOntologySpec, emit: webDisplayOntologySpec

    script:
    if(params.optionalMegaStudyYaml && file(params.optionalMegaStudyYaml).exists()) {
        template 'loadMegaDatasetSpecificTables.bash'
    }
    else{
        template 'loadDatasetSpecificTables.bash'
    }
}



workflow loadStudy {
    take:
    webDisplayOntologySpec

    main:
    extDbSpec = Channel.value(params.extDbRlsSpec)

    insertEntityTypeGraph(extDbSpec, webDisplayOntologySpec) \
        | loadAttributesAndValues \
        | loadEntityTypeAndAttributeGraphs \
        | loadDatasetSpecificTables

    emit:
    loadDatasetSpecificTables.out.extDbRlsSpec
    loadDatasetSpecificTables.out.webDisplayOntologySpec
}
