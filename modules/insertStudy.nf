#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { insertExternalDatabaseAndRelease } from './insertExternalDatabase.nf'

webDisplaySpec = Channel.value(params.webDisplayOntologySpec);
extDBRlsSpec = Channel.value(params.extDbRlsSpec);

 if(params.isaFormat == "simple") {

     if(params.optionalDateObfuscationFile != "NA") {
         file(params.optionalDateObfuscationFile, checkIfExists: true);
     }

     if(params.optionalValueMappingFile != "NA") {
         file(params.optionalValueMappingFile, checkIfExists: true);
     }

     if(params.optionalOntologyMappingOverrideBaseName != "NA") {
         params.internalOntologyMappingOverrideFile = params.studyDirectory + "/" + params.optionalOntologyMappingOverrideBaseName;
         file(params.internalOntologyMappingOverrideFile, checkIfExists: true);
     }
 }
 else if(params.isaFormat == "isatab") { } // nothing to see here
 else if(params.isaFormat == "NA" && params.optionalMegaStudyYaml != "NA") {} // nothing to see here
 else {
     throw new Exception("for non mega studies, param isaFormat must be simple|isatab")
 }

 if(params.optionalMegaStudyYaml != "NA") {
    file(params.optionalMegaStudyYaml, checkIfExists: true);
 }


process insertEntityTypeGraph {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    val extDBIsReady
    val ontologySpecIsReady

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

process loadAttributesAndValues {
    tag "plugin"

    input:
    val extDbRlsSpec
    val webDisplayOntologySpec
    stdin

    output:
    stdout

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

    main:

    def (databaseName, databaseVersion) = params.extDbRlsSpec.split("\\|");

    extDbRlsOut = insertExternalDatabaseAndRelease(tuple databaseName, databaseVersion);

    entityGraphOut = insertEntityTypeGraph(extDBRlsSpec, webDisplaySpec, extDbRlsOut, initOntologyOut);
    attributesOut = loadAttributesAndValues(extDBRlsSpec, webDisplaySpec, entityGraphOut);

    emit:
    attributesOut
}


workflow loadDatasetSpecificAnnotationPropertiesAndGraphs {
    take:
    entityGraphOut

    main:

    annPropOut = Channel.value("READY!");
    if(params.optionalAnnotationPropertiesFile != "NA") {
        annPropOut = loadAnnotationProperties(extDBRlsSpec, entityGraphOut);
    }

    graphsOut = loadEntityTypeAndAttributeGraphs(extDBRlsSpec, webDisplaySpec, annPropOut);
    datasetTablesOut = loadDatasetSpecificTables(extDBRlsSpec, webDisplaySpec, graphsOut)


    emit:
    datasetTablesOut
}

