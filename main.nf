#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------------------------
// Param checking and set some internal param values
//---------------------------------------------------------------------------------

if(params.studyDirectory) {
    file(params.studyDirectory, type: "dir", checkIfExists: true);
}
else {
    throw new Exception("missing params.studyDirectory");
}

if(params.webDisplayOntologyFile) {
    file(params.webDisplayOntologyFile, checkIfExists: true)
}
else {
    throw new Exception("missing params.webDisplayOntologyFile");
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
else {
    throw new Exception("param isaFormat must be simple|isatab")
}



params.internalRunRLocally = params.schema == 'ApidbUserDatasets' ? "--runRLocally" : ''

if(params.optionalMegaStudyYaml && file(params.optionalMegaStudyYaml).exists()) {
    params.internalMegaStudyYaml =  "--megaStudyYaml $params.optionalMegaStudyYaml";
}

//---------------------------------------------------------------------------------
// Includes
//---------------------------------------------------------------------------------
include { loadOntologyStuff } from './modules/insertOntologyTerms.nf'
include { loadStudy } from './modules/insertStudy.nf'
include { dumpFiles } from './modules/fileDumper.nf'

//---------------------------------------------------------------------------------
// Main workflow
//---------------------------------------------------------------------------------
workflow {
    loadOntologyStuff | loadStudy | dumpFiles
}
