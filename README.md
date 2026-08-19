# eda-nextflow

Nextflow pipeline that builds the entity/attribute graph and derived annotation artifacts backing VEuPathDB's Explore/Discover (EDA) study-based sites.

## Overview

eda-nextflow loads a study's metadata (ISA-Tab, "simple" tab-delimited, mega-study, or MicroBiomeDB assay data) into the EDA entity-attribute-value schema. It inserts the ontology and external database records a study depends on, builds the entity type graph and attribute value tables via VEuPathDB's GUS plugins, loads the dataset-specific tables and web-display attribute/entity graphs, and produces the download and binary artifact files consumed by the EDA web application. Separate entry points also support pulling PopSet/GenBank assay data from NCBI ahead of a load, and ingesting user-uploaded datasets (ISA-Tab or BIOM) into `ApidbUserDatasets`.

The pipeline is a thin orchestration layer around GUS plugins (`ga <Plugin::Name> ...`, e.g. `ApiCommonData::Load::Plugin::InsertEntityGraph`, `LoadEntityTypeAndAttributeGraphs`, `MakeEntityDownloadFiles`) that already exist in the VEuPathDB GUS application stack; Nextflow's role is to sequence and parallelize these plugin invocations across a study load.

## Requirements

- Nextflow
- A GUS application environment providing the `ga` command and the VEuPathDB Perl plugins referenced by each process (typically supplied by the container/environment the pipeline is launched from)
- Singularity, for the optional GADM (geographic administrative boundaries) PostGIS instance used during entity graph loading, and for the file-dumper's binary artifact step

## Usage

Run via ReFlow or directly with Nextflow, selecting an entry point with `-entry`:

```
nextflow run VEuPathDB/eda-nextflow -r main \
  -entry loadEntityGraphEntry \
  --studyDirectory /path/to/isatab-study/ \
  --project MyProjectDB \
  --extDbRlsSpec 'MyStudy_RSRC|1.0' \
  -resume -C site.config
```

Omitting `-entry` runs the default (unnamed) workflow, which performs a full study load end to end.

### Entry points

- **(default)** — Full ISA-Tab/simple study load: loads the initial web-display ontology, builds the entity type and attribute graphs, loads dataset-specific annotation properties/tables and the entity/attribute web-display graphs, then dumps download and binary files. Equivalent to running `loadEntityGraphEntry` followed by `loadDatasetSpecificAnnotationPropertiesAndGraphsEntry`.
- **`loadEntityGraphEntry`** — Loads the initial ontology and the entity type/attribute graph only (`loadInitialOntology` + `loadEntityGraph`), without loading dataset-specific tables or dumping files. Useful for loading a study's core entity graph as a first pass.
- **`loadDatasetSpecificAnnotationPropertiesAndGraphsEntry`** — Loads annotation properties (if `optionalAnnotationPropertiesFile` is set), the entity type/attribute web-display graphs, and the dataset-specific tables, then dumps files. Run after `loadEntityGraphEntry` to finish a study that's already had its entity graph loaded.
- **`popsetEntry`** — Loads the initial ontology, downloads and assembles PopSet/GenBank assay data for a study's taxa from NCBI (`esearch`/`efetch`/`xtract`), then loads the entity graph from the downloaded data.
- **`fileDumper`** — Regenerates the download and binary artifact files for a study that is already loaded, without re-loading any data.
- **`loadUserDataset`** — Unpacks a user-uploaded ISA-Tab-like dataset, loads its ontology from tab-delimited ontology files, loads the entity graph and dataset-specific tables, and produces user-dataset install artifacts (`ApidbUserDatasets` schema).
- **`loadBiomUserDataset`** — Same as `loadUserDataset`, but starting from a BIOM-format assay (`data.tsv` + `metadata.json`) that is first converted to the simple ISA format.

## Key parameters

- `studyDirectory` — path to the study's ISA-Tab/simple metadata directory (required for study loads)
- `project` — target project (e.g. `PROJECT`, or `MicrobiomeDB` to trigger the microbiome-specific entity graph loader)
- `schema` — target database schema (`EDA`, or `ApidbUserDatasets` for user dataset loads)
- `extDbRlsSpec` — external database name/version spec for the study (`Name|Version`)
- `isaFormat` — `isatab` or `simple`, selects the metadata parser
- `investigationBaseName` — name of the investigation file within `studyDirectory`
- `webDisplayOntologySpec` / `webDisplayOntologyFile` / `loadWebDisplayOntologyFile` — the web-display ontology spec, its OWL file, and whether to load it as part of the run
- `optionalMegaStudyYaml` / `megaStudyStableId` — configure a mega-study load spanning multiple sub-studies
- `assayResultsDirectory` / `assayResultsFileExtensionsJson` / `sampleDetailsFile` — MicroBiomeDB assay result inputs used by the microbiome entity graph loader
- `optionalDateObfuscationFile` / `optionalValueMappingFile` / `optionalOntologyMappingOverrideBaseName` — optional transformation files used with `isaFormat = simple`
- `optionalAnnotationPropertiesFile` — annotation properties file loaded during the dataset-specific pass, if present
- `investigationSubset` — restricts a load to a subset of the investigation
- `downloadFileBaseName` / `resultsDirectory` — naming and destination for generated download files
- `speciesReconciliationOntologySpec` / `speciesReconciliationFallbackSpecies` — PopBio species reconciliation settings applied after the entity graph load

A GUS config file path (`params.gusConfigFile`) and other site-specific settings (e.g. GADM database connection parameters) are normally supplied by the site's ReFlow config rather than the pipeline's own `nextflow.config`.

## Output

- The study's entity type graph, attribute values, dataset-specific tables, and (where applicable) annotation properties, loaded into the target GUS/EDA schema
- Tab-delimited download files (`*.txt`) published to `resultsDirectory`
- Binary EDA artifact files produced by the `tool-eda-file-dumper` image for studies that were loaded
- For user dataset entry points: an `install.json`, `.cache` files, and `.ctl` SQL*Loader control files describing the user dataset's install artifacts
- For `popsetEntry`: assembled PopSet/GenBank assay, pathogen taxon, and sequence data staged for entity graph loading
