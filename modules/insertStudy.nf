#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'

webDisplaySpec = Channel.value(params.webDisplayOntologySpec)
extDBRlsSpec = Channel.value(params.extDbRlsSpec)

 if(params.isaFormat == "simple") {

     if(params.optionalDateObfuscationFile != "NA") {
         file(params.optionalDateObfuscationFile, checkIfExists: true)
     }

     if(params.optionalValueMappingFile != "NA") {
         file(params.optionalValueMappingFile, checkIfExists: true)
     }

     if(params.optionalOntologyMappingOverrideFile != "NA") {
         file(params.optionalOntologyMappingOverrideFile, checkIfExists: true)
     }
 }
 else if(params.isaFormat == "isatab") { } // nothing to see here
 else if(params.isaFormat == "NA" && params.optionalMegaStudyYaml != "NA") {} // nothing to see here
 else {
     throw new Exception("for non mega studies, param isaFormat must be simple|isatab")
 }

 if(params.optionalMegaStudyYaml != "NA") {
    file(params.optionalMegaStudyYaml, checkIfExists: true)
 }


process insertEntityTypeGraph {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    val extDBIsReady
    val ontologySpecIsReady
    val studyDir
    val ontologyMappingOrOwlFile

    output:
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


    stub:
    """
    echo "insert entity type graph"
    """

}

// If we are in user datasets mode, the attribute value tables will be written to files
process loadAttributesAndValues {
    publishDir "$params.resultsDirectory", pattern: '*.{cache}', mode: "copy"
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    stdout emit: verbiage
    path "*.cache"

    script:
    template 'loadAttributesAndValues.bash'


    stub:
    """
    echo "load attribute values"
    """

}


process loadEntityTypeAndAttributeGraphs {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    stdout

    script:
    template 'loadEntityTypeAndAttributeGraphs.bash'

    stub:
    """
    echo "load attribute graph and entity type graph"
    """

}



process loadAnnotationProperties {
    tag "plugin"

    input:
    val extDbRlsSpec
    stdin

    output:
    stdout

    script:
    template 'loadAnnotationProperties.bash'


    stub:
    """
    echo "load annotation properties tables"
    """

}



process loadDatasetSpecificTables {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    stdout

    script:
    template 'loadDatasetSpecificTables.bash'


    stub:
    """
    echo "load dataset specific tables"
    """

}

workflow loadEntityGraph {
    take:
    initOntologyOut
    studyDir
    ontologyMappingOrOwlFile

    main:

    def (databaseName, databaseVersion) = params.extDbRlsSpec.split("\\|")

    extDbRlsOut = insertExternalDatabaseAndRelease(tuple(databaseName, databaseVersion), initOntologyOut)

    entityGraphOut = insertEntityTypeGraph(extDBRlsSpec, webDisplaySpec, extDbRlsOut, initOntologyOut, studyDir, ontologyMappingOrOwlFile)
    attributesOut = loadAttributesAndValues(extDBRlsSpec, webDisplaySpec, entityGraphOut).verbiage

    emit:
    attributesOut
}


workflow loadDatasetSpecificAnnotationPropertiesAndGraphs {
    take:
    entityGraphOut

    main:

    annPropOut = Channel.value("READY!")
    if(params.optionalAnnotationPropertiesFile != "NA" && file(params.optionalAnnotationPropertiesFile).exists()) {
        annPropOut = loadAnnotationProperties(extDBRlsSpec, entityGraphOut)
    }

    graphsOut = loadEntityTypeAndAttributeGraphs(extDBRlsSpec, webDisplaySpec, entityGraphOut.combine(annPropOut))
    datasetTablesOut = loadDatasetSpecificTables(extDBRlsSpec, webDisplaySpec, graphsOut)

    emit:
    datasetTablesOut
}

