#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------------------------
// Param checking
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
    loadInitialOntology | loadEntityGraph | loadDatasetSpecificAnnotationPropertiesAndGraphs | dumpFiles
}

workflow loadEntityGraphEntry {
    loadInitialOntology | loadEntityGraph;
}

workflow loadDatasetSpecificAnnotationPropertiesAndGraphsEntry {
    loadDatasetSpecificAnnotationPropertiesAndGraphs(Channel.value("READY!"));
}

workflow fileDumper {
  dumpFiles(Channel.value("READY!"));
}
