#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------------------------
// Param checking and set some internal param values
//---------------------------------------------------------------------------------

if(params.studyDirectory != "NA") {
    file(params.studyDirectory, type: "dir", checkIfExists: true);
}
else {
    throw new Exception("missing params.studyDirectory");
}

if(params.webDisplayOntologyFile != "NA") {
    file(params.webDisplayOntologyFile, checkIfExists: true)
}

if(params.optionalAnnotationPropertiesFile != "NA") {
    file(params.optionalAnnotationPropertiesFile, checkIfExists: true);
}


params.internalUseOntologyTermTableForTaxonTerms = "";
params.internalUseIsaSimpleParser = "";
params.internalOntologyMappingFile = "";
params.internalDateObfuscationFile = "";
params.internalValueMappingFile = "";
params.internalOntologyMappingOverrideBaseName = "";
params.internalInvestigationSubset = params.investigationSubset != "NA" ? "--investigationSubset " +  params.investigationSubset : "";


if(params.useOntologyTermTableForTaxonTerms) {
    params.internalUseOntologyTermTableForTaxonTerms = "--useOntologyTermTableForTaxonTerms";
}

if(params.isaFormat.toLowerCase() == "simple") {
    params.internalInvestigationFile = params.studyDirectory + "/" + params.investigationBaseName

    params.internalOntologyMappingFile = "--ontologyMappingFile " + params.webDisplayOntologyFile;
    params.internalUseIsaSimpleParser = "--isSimpleConfiguration ";

    if(params.optionalDateObfuscationFile != "NA") {
        file(params.optionalDateObfuscationFile, checkIfExists: true);
        params.internalDateObfuscationFile = "--dateObfuscationFile " + params.optionalDateObfuscationFile;
    }
    else {
        params.internalDateObfuscationFile = "";
    }

    if(params.optionalValueMappingFile != "NA") {
        file(params.optionalValueMappingFile, checkIfExists: true)
        params.internalValueMappingFile = "--valueMappingFile " + params.optionalValueMappingFile;
    }
    else {
        params.internalValueMappingFile = "";
    }

    if(params.optionalOntologyMappingOverrideBaseName != "NA") {
        params.internalOntologyMappingOverrideFile = params.studyDirectory + "/" + params.optionalOntologyMappingOverrideBaseName
        file(params.internalOntologyMappingOverrideFile, checkIfExists: true);
        params.internalOntologyMappingOverrideBaseName = "--ontologyMappingOverrideFileBaseName " + params.optionalOntologyMappingOverrideBaseName;
    }
    else {
        params.internalOntologyMappingOverrideBaseName = "";
    }

}
else if(params.isaFormat == "isatab") { } // nothing to see here
else if(params.isaFormat == "NA" && params.optionalMegaStudyYaml != "NA") {} // nothing to see here
else {
    throw new Exception("for non mega studies, param isaFormat must be simple|isatab")
}

params.internalRunRLocally = params.schema == 'ApidbUserDatasets' ? "--runRLocally" : ''

if(params.optionalMegaStudyYaml != "NA" && file(params.optionalMegaStudyYaml).exists()) {
    params.internalMegaStudyYaml =  "--megaStudyYaml $params.optionalMegaStudyYaml";
}

//---------------------------------------------------------------------------------
// Includes
//---------------------------------------------------------------------------------
include { loadInitialOntology } from './modules/insertOntologyTerms.nf'
include { loadEntityGraph; loadDatasetSpecificAnnotationPropertiesAndGraphs } from './modules/insertStudy.nf'
include { dumpFiles } from './modules/fileDumper.nf'

//---------------------------------------------------------------------------------
// Main workflow
//---------------------------------------------------------------------------------
workflow {
    loadInitialOntology | loadEntityGraph | loadDatasetSpecificAnnotationPropertiesAndGraphs
}

workflow loadEntityGraphEntry {
    loadEntityGraph(Channel.value("READY!"));
}

workflow loadDatasetSpecificAnnotationPropertiesAndGraphsEntry {
    loadDatasetSpecificAnnotationPropertiesAndGraphs(Channel.value("READY!"));
}
