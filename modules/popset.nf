#!/usr/bin/env nextflow
nextflow.enable.dsl=2

webDisplaySpec = Channel.value(params.webDisplayOntologySpec)
extDBRlsSpec = Channel.value(params.extDbRlsSpec)

process getQueryResult {
  output:
    path queryResult 
  script:
    """
   for id in `cat $PWD/../final/familyNcbiTaxonIds.txt`; do printf "txid%d[organism:exp]\\n" \$id; done | paste -sd, | sed 's/,/ OR /g' > querystring
   esearch -db popset -query "`cat querystring`" > queryResult
   count=`xtract -input queryResult -pattern ENTREZ_DIRECT -element Count`
   if [ \$count -eq 0 ]; then exit 1; else exit 0; fi
    """
}

process getStudies {
  input:
    path queryResult
  output:
    path studiesRaw
  script:
   """
   cat queryResult |esummary -mode xml | xtract -pattern DocumentSummary -element Gi SetType Title > studiesRaw
   count=`wc -l studies |cut -d' '  -f1`
   if [ \$count -eq 0 ]; then exit 1; else exit 0; fi

   """
}

process shortenTitles {
  input:
    path studiesRaw
  output:
    path studies
  script:
  '''
  #!/usr/bin/env perl
  open(FH, "< studiesRaw") or die "Cannot open studiesRaw: $!\n";
  open(OF, "> studies");
  while(<FH>){
    chomp;
    @a=split /\\t/;
    if(length($a[2])>400){
      $a[2] = substr($a[2],0,360) . "... [title truncated]"
    }
    printf OF ("%s\n", join("\\t", @a));
  }
  '''

}

process getFasta {
  input:
    path queryResult 
  output:
    path sequences
  script:
   """
   cat queryResult | efetch -format fasta > sequences
   count=`wc -l sequences |cut -d' '  -f1`
   if [ \$count -eq 0 ]; then exit 1; else exit 0; fi
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
  count=`wc -l gbxml | cut -d' '  -f1`
  if [ \$count -eq 0 ]; then exit 1; else exit 0; fi
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
  count=`wc -l assay |cut -d' '  -f1`
  if [ \$count -eq 0 ]; then exit 1; else exit 0; fi
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
  assays_wide\$genbank_country = assays_wide\$country;
  assays_wide\$country = NULL;
  assays_wide = mutate(assays_wide, country = str_extract( genbank_country, "^[^:]+"));
  if( 'lat_lon' %in% names(assays_wide) ){
    cat(sprintf("Parsing lat_lon..."));
    assays_wide = separate_wider_delim(assays_wide, lat_lon, " ", names = c("latitude","latdir","longitude","londir"));
    assays_wide\$latdir = mapvalues( assays_wide\$latdir, c("N", "S"), c("", "-"));
    assays_wide\$londir = mapvalues( assays_wide\$londir, c("E", "W"), c("", "-"));
    assays_wide\$latitude = paste( assays_wide\$latdir, assays_wide\$latitude, sep = "");
    assays_wide\$longitude = paste( assays_wide\$latdir, assays_wide\$longitude, sep = "");
    assays_wide\$latitude = mapvalues(assays_wide\$latitude, c("NANA"), c(""));
    assays_wide\$longitude = mapvalues(assays_wide\$longitude, c("NANA"), c(""));
    assays_wide = mutate(assays_wide, has_geolocation = case_when( !is.na(latitude) ~ 'yes', is.na(latitude) ~ 'no' ) )
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
  count=`wc -l assay |cut -d' '  -f1`
  if [ \$count -eq 0 ]; then exit 1; fi
    """
}

process xtractSeqlen {
  input:
    path gbxml
  output:
    path acc2len
  script:
    """
xtract -input gbxml -pattern INSDSeq -element INSDSeq_accession-version INSDSeq_sequence > acc2seq 
cut -f2 acc2seq | awk '{print length}' > len 
paste acc2seq len | cut -f1,3 > acc2len 
  count=`wc -l acc2len |cut -d' '  -f1`
  if [ \$count -eq 0 ]; then exit 1; fi
    """
}

process getGiAccessionMapping {
  input:
    path studies
  output:
    path gi2acc
  script:
   """
  for gid in `cut -f1 studies`
    do
    for acc in `efetch -db popset -id \$gid -format gb | transmute -g2x | xtract -pattern INSDSeq -element INSDSeq_accession-version`; do
      printf "%s\t%s\n" \$gid \$acc
    done
  done > gi2acc
  count=`wc -l gi2acc |cut -d' '  -f1`
  if [ \$count -eq 0 ]; then exit 1; fi
   """
}

process mergeAll {
  input:
    path gi2acc
    path studies
    path assay
    path pubmed 
    path acc2len 
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
  # merge acc2len
  acc2len_df = read_tsv('acc2len', col_names =  c("accession", "read_length")) %>% mutate_all(as.character);
  finaldf = merge(finaldf,acc2len_df,by = c('accession'), all.x = T);
  # done
  write_tsv(finaldf, 'popset.txt', na = '');
    """
}

process copyToFinal {
  input:
    path mergeFile
    path fastaFile
    val datasetName
  output:
    stdout
  script:
  """
if [ -h $PWD/../final/$mergeFile ]; then rm $PWD/../final/$mergeFile; fi
ln -s `realpath $mergeFile` $PWD/../final/
ln `realpath $fastaFile` $PWD/../${datasetName}.fasta
  """
}

workflow downloadPopset {

    take:
    initOntologyOut
    main:

    def (datasetName, datasetVersion) = params.extDbRlsSpec.split("\\|")
  
    qrOut = getQueryResult()
    studiesRawOut = getStudies(qrOut)
    studiesOut = shortenTitles(studiesRawOut)
    mappingOut = getGiAccessionMapping(studiesOut)
    gbOut = getGenbankXml(qrOut)
    assayWideOut = xtractAssay(gbOut)
    assayOut = pivotAssay(assayWideOut)
    pubmedOut = xtractPubmed(gbOut)
    seqlenOut = xtractSeqlen(gbOut)
    mergeOut = mergeAll(mappingOut,studiesOut,assayOut,pubmedOut,seqlenOut)
    fastaOut = getFasta(qrOut)
    copyOut = copyToFinal(mergeOut,fastaOut,datasetName)
    emit:
    copyOut

}
   
  
