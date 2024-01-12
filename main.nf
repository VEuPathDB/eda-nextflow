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

if(params.webDisplayOntologyFile != "NA" && params.schema != 'ApidbUserDatasets') {
    file(params.webDisplayOntologyFile, checkIfExists: true)
}


//---------------------------------------------------------------------------------
// Includes
//---------------------------------------------------------------------------------
include { loadInitialOntology; loadOntologyFromTabDelim } from './modules/insertOntologyTerms.nf'
include { loadEntityGraph; loadDatasetSpecificAnnotationPropertiesAndGraphs } from './modules/insertStudy.nf'
include { dumpFiles; dumpUserDatasetFiles } from './modules/fileDumper.nf'
include { unpack } from './modules/unpack.nf'

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
    loadDatasetSpecificAnnotationPropertiesAndGraphs(Channel.value("READY!")) | dumpFiles
}

workflow fileDumper {
  dumpFiles(Channel.value("READY!"));
}

workflow loadUserDataset {
    unpack | loadOntologyFromTabDelim | loadEntityGraph | loadDatasetSpecificAnnotationPropertiesAndGraphs | dumpUserDatasetFiles
    //loadDatasetSpecificAnnotationPropertiesAndGraphs(Channel.value("READY!"));
}

