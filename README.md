# LDI Replication Lab Data Preparation

This prepares and cleans the raw data from the LDI Replication Lab. The output is manually curated on Zenodo, and used for downstream analysis.

## Data Citation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2639919.svg)](https://doi.org/10.5281/zenodo.2639919) - Always points to the latest version

> Hautahi Kingi, Sylverie Herbert, Flavio Stanchi, & Vilhuber, Lars. (2019). Data from the Cornell LDI Replication Lab (Version v20190414) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.2639919

## Code Archive
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.26413087.svg)](https://doi.org/10.5281/zenodo.26413087) - Always points to the latest code release version

> Hautahi Kingi, Sylverie Herbert, Flavio Stanchi, & Lars Vilhuber. (2019, April 14). labordynamicsinstitute/ldi-replication-dataprep: LDI Replication Lab Data Preparation (Version v20190414). Zenodo. http://doi.org/10.5281/zenodo.2641308

## Structure

- [data](data/) contains the data
  - [replication_data](data/replication_data) contains the cleaned and anonymized data on replicators' assessment, and outcome of the replication attempts. Code to anonymize is in the [programs](programs/) directory. Raw data is not made available due to privacy concerns, but the code will reveal that only person IDs were modified.
  - [interwrk](data/interwrk) is only used for processing while article tables are generated, and contains no permanent data. In the replication archive, this directory is empty, and will be created if absent.
- [programs](programs/) contains all programs to clean and process the data outlined above. The code can only be run by the authors, because it requires access to identifying data (anonymizing). Code that cannot be executed by third parties (anonymizing code) is marked "eval=false" in the [README](programs/README.Rmd). All code is executed from within this directory - load the  [README](programs/README.Rmd) in Rstudio or R, and evaluate (knit).

## Additional files
- [pathconfig.R]() defines common paths used by all programs and is referenced from within the [programs](programs/) and [text](text/) directories. It should not be executed separately.
- [global-libraries.R]() defines libraries used by all programs and is referenced from within the [programs](programs/) and [text](text/) directories. It should not be executed separately.
- README.md - this file

## Requirements
- R
  - the only package that needs to be present before starting is `rprojroot`. 
  - All others are dynamically installed. Complete lists are 
    - [global-libraries.R]()
    - [programs/libraries.R]()
- (optional but useful) Rstudio
