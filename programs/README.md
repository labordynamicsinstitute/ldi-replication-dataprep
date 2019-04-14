---
title: "Programs"
author: 
  1:
    name: "Lars Vilhuber"
  2:
    name: "Flavio Stancchi"
  3:
    name: "Hautahi Kingi"
  4:
    name: "Sylverie Herbert"
date: "2019-04-14"
output: 
  html_document: 
    keep_md: yes
    number_sections: yes
---


# Programs

Programs are split into three parts:

## Data preparation
The original data are collected through a Google Form, and are thus stored on a Google Sheet. They do contain personal identifiers which we wish to hide, and the site requires authentication. The first set of programs thus
- download from Google (snapshot)
- anonymize the data
- upload the data a permanent location (Zenodo) (not functional yet)

In general, these programs can only be run by project members with access to the Google Sheet.



## Setup

We rely on the R packages `rprojroot` and `checkpoint` - if you do not have those, you need to install them. All other packages are installed automatically.

Most parameters are set in the `config.R`:

```r
source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=TRUE)
```

```
## 
## > basepath <- rprojroot::find_rstudio_root_file()
## 
## > dataloc <- file.path(basepath, "data", "replication_data")
## 
## > interwrk <- file.path(basepath, "data", "interwrk")
## 
## > Outputs <- file.path(basepath, "data", "outputs")
## 
## > programs <- file.path(basepath, "programs")
## 
## > for (dir in list(dataloc, interwrk, Outputs)) {
## +     if (file.exists(dir)) {
## +     }
## +     else {
## +         dir.create(file.path(dir))
## +     }
## + }
## 
## > MRAN.snapshot <- "2019-01-01"
## 
## > options(repos = c(CRAN = paste0("https://mran.revolutionanalytics.com/snapshot/", 
## +     MRAN.snapshot)))
```

```r
source(file.path(programs,"config.R"), echo=TRUE)
# private config - not part of REPO! See private repo labordynamicsinstitute/aej-applied-replications/programs/config-private.R and copy manually into this directory
source(file.path(programs,"config-private.R"), echo=FALSE)
```

Note that the path `interwrk` is transitory, and is only kept during processing. It will be empty in the replication archive.

Any libraries needed are called and if necessary installed through `libraries.R`:


```r
source(file.path(basepath,"global-libraries.R"),echo=TRUE)
```

```
## 
## > pkgTest <- function(x) {
## +     if (!require(x, character.only = TRUE)) {
## +         install.packages(x, dep = TRUE)
## +         if (!require(x, charact .... [TRUNCATED] 
## 
## > global.libraries <- c("dplyr", "devtools", "rprojroot", 
## +     "tictoc")
## 
## > results <- sapply(as.list(global.libraries), pkgTest)
```

```
## Loading required package: dplyr
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```
## Loading required package: devtools
```

```
## Loading required package: rprojroot
```

```
## Loading required package: tictoc
```

```r
source(file.path(programs,"libraries.R"), echo=TRUE)
```

```
## 
## > libraries <- c("dplyr", "devtools", "googlesheets", 
## +     "rcrossref", "readr", "tidyr", "summarytools", "anonymizer", 
## +     "digest", "data.table ..." ... [TRUNCATED] 
## 
## > results <- sapply(as.list(libraries), pkgTest)
```

```
## Loading required package: googlesheets
```

```
## Loading required package: rcrossref
```

```
## Loading required package: readr
```

```
## Loading required package: tidyr
```

```
## Loading required package: summarytools
```

```
## Loading required package: anonymizer
```

```
## Loading required package: digest
```

```
## Loading required package: data.table
```

```
## 
## Attaching package: 'data.table'
```

```
## The following objects are masked from 'package:dplyr':
## 
##     between, first, last
```

```
## 
## > cbind(libraries, results)
##       libraries      results
##  [1,] "dplyr"        "OK"   
##  [2,] "devtools"     "OK"   
##  [3,] "googlesheets" "OK"   
##  [4,] "rcrossref"    "OK"   
##  [5,] "readr"        "OK"   
##  [6,] "tidyr"        "OK"   
##  [7,] "summarytools" "OK"   
##  [8,] "anonymizer"   "OK"   
##  [9,] "digest"       "OK"   
## [10,] "data.table"   "OK"
```

These sections are included in all relevant programs, and configure the programs to run almost everywhere (tested on Linux and Mac OS).



## Download the replication data from Google Sheet
The responses to the replication attempts are stored on Google Sheets. We download, then combine and clean the data. This can only be executed by the project owners.

 - Input data: On Google Sheets (private)
 - Output data: path `interwrk',"repllist2.Rds"
 

```r
source(file.path(programs,"01_download_replication.R"),echo=TRUE)
```

At the end of this step, the `interwrk` directory  should have the following data files:

- entryQ.{Rds,csv} - the main data from the "Entry" questionnaire (assessment)
- exitQ.{Rds,csv} - the main data from the post-replication "Exit" questionnaire (assessment)
- entryQ2011.{Rds,csv} - data from the experiment with 2011 publications, prior to a uniform questionnaire (experimental data)
- mapping_ws_nums.Rds - a mapping of numbers to sheet names in the assignment
- replication_list_{n}.{Rds,csv} - individual tabs from the assignment spreadsheet. Until 2018, each batch of replicators was assigned jobs in a separate tab of the master spreadsheet. After 2018, only a single tab was updated going forward.

The next program consolidates these files.


```r
source(file.path(programs,"02_read_clean_replicationlist.R"),echo=TRUE)
```

At the end of this program, a dataset `repllist2.Rds` should be present in `interwrk`, containing consolidated data.

## Anonymize the data
The Google Sheet data contains the actual login ID or name of the replicators. We anonymize them. This can only be executed by the project owners.

 - Input data: path `interwrk`
 - Output data: path `dataloc`
 

```r
source(file.path(programs,"03_gen_anonymous_ID.R"),echo=TRUE)
```

## Prepare for upload to Zenodo

In order to upload, we 

- verify that no names are contained in the relevant columns anymore
- create a rudimentary codebook

The upload itself at this time is manual.

## Processing info

```r
Sys.info()
```

```
##                                         sysname 
##                                         "Linux" 
##                                         release 
##                            "4.4.176-96-default" 
##                                         version 
## "#1 SMP Fri Mar 22 06:23:26 UTC 2019 (a0dd1b8)" 
##                                        nodename 
##                                      "zotique2" 
##                                         machine 
##                                        "x86_64" 
##                                           login 
##                                      "vilhuber" 
##                                            user 
##                                      "vilhuber" 
##                                  effective_user 
##                                      "vilhuber"
```

