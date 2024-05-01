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
include { unpack; unpackBiom } from './modules/unpack.nf'
include { downloadPopset } from './modules/popset.nf'

//---------------------------------------------------------------------------------
// Main workflow
//---------------------------------------------------------------------------------
workflow {
    loadInitialOntology()
    loadEntityGraph(loadInitialOntology.out, params.studyDirectory, params.webDisplayOntologyFile)
    loadDatasetSpecificAnnotationPropertiesAndGraphs(loadEntityGraph.out)
    dumpFiles(loadDatasetSpecificAnnotationPropertiesAndGraphs.out)
}

workflow loadEntityGraphEntry {
    loadInitialOntology()
    loadEntityGraph(loadInitialOntology.out, params.studyDirectory, params.webDisplayOntologyFile)
}

workflow loadDatasetSpecificAnnotationPropertiesAndGraphsEntry {
    loadDatasetSpecificAnnotationPropertiesAndGraphs(Channel.value("READY!"))
    dumpFiles(loadDatasetSpecificAnnotationPropertiesAndGraphs.out)
}

workflow popsetEntry {
    loadInitialOntology()
    downloadPopset(loadInitialOntology.out)
    loadEntityGraph(downloadPopset.out, params.studyDirectory, params.webDisplayOntologyFile)

}
  

workflow fileDumper {
  dumpFiles(Channel.value("READY!"));
}

workflow loadUserDataset {
    unpack()
    loadOntologyFromTabDelim(unpack.out.isaSimpleDir, unpack.out.ontology_terms, unpack.out.ontology_relationships)
    loadEntityGraph(loadOntologyFromTabDelim.out, unpack.out.isaSimpleDir, unpack.out.ontology_mapping)
    loadDatasetSpecificAnnotationPropertiesAndGraphs(loadEntityGraph.out)
    dumpUserDatasetFiles(loadDatasetSpecificAnnotationPropertiesAndGraphs.out)
}


workflow loadBiomUserDataset {
    unpackBiom()
    loadOntologyFromTabDelim(unpackBiom.out.isaSimpleDir, unpackBiom.out.ontology_terms, unpackBiom.out.ontology_relationships)
    loadEntityGraph(loadOntologyFromTabDelim.out, unpackBiom.out.isaSimpleDir, unpackBiom.out.ontology_mapping)
    loadDatasetSpecificAnnotationPropertiesAndGraphs(loadEntityGraph.out)
    dumpUserDatasetFiles(loadDatasetSpecificAnnotationPropertiesAndGraphs.out)

}
