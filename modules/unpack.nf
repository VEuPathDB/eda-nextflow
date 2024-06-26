#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process makeSimpleFiles {
    publishDir params.studyDirectory, mode: 'copy'

    output:
    path (params.investigationSubset)

    script:
    """
    shopt -s nullglob
    files=""
    for file in $params.studyDirectory/*.{txt,tsv,csv}; do
    files+=" -m \$file"
    done
    exportInvestigation.pl -a \$files -t $params.investigationSubset
    """
 }

process makeOntologyFiles {
    input:
    path studyDir

    output:
    path "ontology_terms.txt", emit: ontology_terms
    path "ontology_relationships.txt", emit: ontology_relationships
    path "${studyDir}/ontologyMapping.xml", emit: ontology_mapping

    script:
    """
    ontologyTermsToTabDelim.pl ${studyDir}/ontologyMapping.xml .

    geoTermsAndRelationships.pl --output_type term >ontology_terms.txt.geohash
    geoTermsAndRelationships.pl --output_type relationship --ontology_terms ontology_terms.txt --ontology_relationships ontology_relationships.txt >ontology_relationships.txt.geohash

    cat ontology_terms.txt.geohash >> ontology_terms.txt
    cat ontology_relationships.txt.geohash >>ontology_relationships.txt
    """
}

process makeSimpleFilesFromParsedBiom {
    publishDir params.studyDirectory, mode: 'copy'

    output:
    path (params.investigationSubset)

    script:
    """
    mkdir $params.investigationSubset
    biomFilesToIsasimple $params.studyDirectory/data.tsv $params.studyDirectory/metadata.json $params.investigationSubset
    """
 }


process addGeotermsToOntologyFiles {
    input:
    path studyDir

    output:
    path "ontology_terms.txt", emit: ontology_terms
    path "ontology_relationships.txt", emit: ontology_relationships
    path "${studyDir}/ontologyMapping.xml", emit: ontology_mapping


    script:
    """
    cp ${studyDir}/ontology_terms.txt ./ontology_terms.txt
    cp ${studyDir}/ontology_relationships.txt ./ontology_relationships.txt

    geoTermsAndRelationships.pl --output_type term >ontology_terms.txt.geohash
    geoTermsAndRelationships.pl --output_type relationship --ontology_terms ontology_terms.txt --ontology_relationships ontology_relationships.txt >ontology_relationships.txt.geohash

    cat ontology_terms.txt.geohash >> ontology_terms.txt
    cat ontology_relationships.txt.geohash >>ontology_relationships.txt
    """

}


process makeDirectoryForStudies {
    input:
    path studyDir

    output:
    path "isaSimpleDirectory"

    script:
    """
    mkdir isaSimpleDirectory
    mv $studyDir isaSimpleDirectory
    """
}


workflow unpack {
    main:

    parsedStudyDir = makeSimpleFiles();
    ontologyTermsAndRelationships = makeOntologyFiles(parsedStudyDir)
    isaSimpleDir = makeDirectoryForStudies(parsedStudyDir)

    emit:
    isaSimpleDir = isaSimpleDir
    ontology_terms = ontologyTermsAndRelationships.ontology_terms
    ontology_relationships = ontologyTermsAndRelationships.ontology_relationships
    ontology_mapping = ontologyTermsAndRelationships.ontology_mapping
}


workflow unpackBiom {
    main:

    parsedStudyDir = makeSimpleFilesFromParsedBiom();
    ontologyTermsAndRelationships = addGeotermsToOntologyFiles(parsedStudyDir)
    isaSimpleDir = makeDirectoryForStudies(parsedStudyDir)

    emit:
    isaSimpleDir = isaSimpleDir
    ontology_terms = ontologyTermsAndRelationships.ontology_terms
    ontology_relationships = ontologyTermsAndRelationships.ontology_relationships
    ontology_mapping = ontologyTermsAndRelationships.ontology_mapping
}
