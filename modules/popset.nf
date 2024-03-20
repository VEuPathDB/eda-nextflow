#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { loadAttributesAndValues } from './insertStudy.nf'

process getQueryResult {
  output:
    path queryResult 
  script:
    """
   queryparams=`paste -s ${params.investigationSubset}/familyNcbiTaxonIds.txt |sed 's/\t/[organism:exp] OR /g; s/\$/[organism:exp]/'`
   esearch -db popset -query '\$queryparams' > queryResult
    """
}

process getStudies {
  input:
    path queryResult
  output:
    path studies 
  script:
   """
   cat queryResult |esummary -mode xml | xtract -pattern DocumentSummary -element Gi SetType Title > studies
   """
}

process getFasta {
  input:
    path queryResult 
  output:
    path sequences
  script:
   """
   cat queryResult | efetch -format fasta > sequences
   """
}

process getGenbankXml {
  input:
    path queryResult 
  output:
    path gbxml
  script:
   """
   cat queryResult | efetch -format gb | transmute -g2x > gbxml
   """
}

process xtractAssay {
  input:
    path gbxml
  output:
    path assayTall
  script:
    """
  xtract -input gbxml -pattern INSDSeq -ACC INSDSeq_accession-version -group INSDFeature -KEY INSDFeature_key -block INSDQualifier -deq "\n" -element "&ACC" "&KEY" INSDQualifier_name INSDQualifier_value > assayTall
    """
}

process pivotAssay {
  input:
    path assayTall
  output:
    path assay
  script:
  """
  #!/usr/bin/env Rscript
  library(plyr);
  library(tidyverse);
  assays_tall = read_tsv("assayTall", col_names = c("accession", "key", "property", "value"));
  assays_wide = pivot_wider(assays_tall, names_from = property, values_from = value, values_fn = function(x) paste(x, collapse = "|"))
  assays_wide\$translation = NULL;
  assays_wide\$transl_table = NULL;
  assays_wide\$transl_except = NULL;
  if( 'lat_lon' %in% names(assays_wide) ){
    cat(sprintf("Parsing lat_lon..."));
    assays_wide = separate_wider_delim(assays_wide, lat_lon, " ", names = c("latitude","latdir","longitude","londir"));
    assays_wide\$latdir = mapvalues( assays_wide\$latdir, c("N", "S"), c("", "-"));
    assays_wide\$londir = mapvalues( assays_wide\$londir, c("E", "W"), c("", "-"));
    assays_wide\$latitude = paste( assays_wide\$latdir, assays_wide\$latitude, sep = "");
    assays_wide\$longitude = paste( assays_wide\$latdir, assays_wide\$longitude, sep = "");
    assays_wide\$latitude = mapvalues(assays_wide\$latitude, c("NANA"), c(""));
    assays_wide\$longitude = mapvalues(assays_wide\$longitude, c("NANA"), c(""));
    # clean up 
    assays_wide\$lat_lon = NULL;
    assays_wide\$latdir = NULL;
    assays_wide\$londir = NULL;
    cat(sprintf("Done\n"));
  }
  write_tsv(assays_wide, "assay", na = "");
  """
}

process xtractPubmed {
  input:
    path gbxml
  output:
    path pubmed
  script:
    """
  xtract -input gbxml -pattern INSDSeq -ACCVER INSDSeq_accession-version -group INSDReference -if INSDReference_pubmed -is-not NULL -element INSDReference_pubmed INSDReference_title "&ACCVER" > pubmed
    """
}

process getGiAccessionMapping {
  input:
    path studies
  output:
    path gi2acc
  script:
   """
  /usr/bin/env bash
  for gid in `cut -f1 studies`
    do
    for acc in `efetch -db popset -id \$gid -format gb | transmute -g2x | xtract -pattern INSDSeq -element INSDSeq_accession-version`; do
      printf "%s\t%s\n" \$gid \$acc
    done
  done > gi2acc
   """
}

process mergeAll {
  input:
    path gi2acc
    path studies
    path assay
    path pubmed 
  output:
    path 'popset.txt'
  script:
    """
  #!/usr/bin/env Rscript
  library(tidyverse);
  # start with gi2acc 
  finaldf = read_tsv('gi2acc', col_names = c('gi', 'accession')) %>% mutate_all(as.character);
  # merge studies
  studies_df = read_tsv('studies', col_names = c("gi", "studytype", "title"));
  finaldf = merge(finaldf,studies_df,by = c('gi'), all.x = T);
  # merge assay
  assay_df = read_tsv('assay') %>% mutate_all(as.character);
  finaldf = merge(finaldf,assay_df,by = c('accession'), all.x = T);
  # merge pubmed
  pubmed_df = read_tsv('pubmed', col_names =  c("pubmedid", "pubmed_title", "accession")) %>% mutate_all(as.character);
  finaldf = merge(finaldf,pubmed_df,by = c('accession'), all.x = T);
  # done
  write_tsv(finaldf, 'popset.txt', na = '');
    """
}

process insertPopsetEntityTypeGraph {

  input:
    path mergeFile
    val edrs
    val webDisplayOntologySpec
    val initOntology
  output:
    stdout
  script:
// TODO: --commit
  """
ga ApiCommonData::Load::Plugin::InsertEntityGraph \\
  --isSimpleConfiguration 1 \\
  --investigationBaseName $params.investigationFileBasename \\
  --ontologyMappingFile $params.webDisplayOntologyFile \\
  --ontologyMappingOverrideFileBaseName $params.optionalOntologyMappingOverrideFile \\
  --extDbRlsSpec '$edrs' \\
  --schema $params.schema \\
  --metaDataRoot $params.studyDirectory \\
  --commit
  """
}

workflow loadPopsetEntityGraph {
    take:
    initOntologyOut
    main:
  
    qrOut = getQueryResult();
    studiesOut = getStudies(qrOut);
    mappingOut = getGiAccessionMapping(studiesOut);
    gbOut = getGenbankXml(qrOut);
    assayWideOut = xtractAssay(gbOut);
    assayOut = pivotAssay(assayWideOut);
    pubmedOut = xtractPubmed(gbOut);
    mergeOut = mergeAll(mappingOut,studiesOut,assayOut,pubmedOut);

    entityGraphOut = insertPopsetEntityTypeGraph(mergeOut, params.extDbRlsSpec, params.webDisplayOntologySpec, initOntologyOut);
    attributesOut = loadAttributesAndValues(params.extDbRlsSpec, params.webDisplayOntologySpec, entityGraphOut)
  
    emit:
    attributesOut

}
   
  
