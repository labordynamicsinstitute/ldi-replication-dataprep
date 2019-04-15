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
date: "**2019-04-14"
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

We rely on the R packages **`rprojroot` and `checkpoint` - if you do not have those, you need to install them. All other packages are installed automatically.

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
## > confidential <- file.path(basepath, "data", "confidential")
## 
## > programs <- file.path(basepath, "programs")
## 
## > for (dir in list(dataloc, interwrk, Outputs, confidential)) {
## +     if (file.exists(dir)) {
## +     }
## +     else {
## +         dir.create(file.path(dir) .... [TRUNCATED] 
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

```
## 
## > ws <- readRDS(file = file.path(interwrk, "mapping_ws_nums.Rds"))
## 
## > ws <- as.vector(unlist(ws[1:length(ws) - 1]))
## 
## > repllist <- NA
## 
## > read.as.csv <- FALSE
## 
## > myfilter <- function(ds) {
## +     ds <- ds %>% select(DOI, `Entry Questionnaire`, assessor, 
## +         `Expected Difficulty`, Completed1 = Completed, .... [TRUNCATED] 
## 
## > for (x in 1:length(ws)) {
## +     if (ws[x] != "2009 missing online material" & ws[x] != "Spring2016 list") {
## +         print(paste("Processing", ws[x .... [TRUNCATED] 
## [1] "Processing MASTER Summer 2018 forward"
```

```
## Warning: NAs introduced by coercion
```

```
## [1] "Processing Spring2018AER"
## [1] "Processing First2014"
## [1] "Processing Spring2018"
## [1] "Processing First2015"
## [1] "Processing Second2015"
## [1] "Processing Spring2016"
## [1] "Processing Summer2016"
## [1] "Processing Summer2017"
## [1] "Processing Spring2017"
## [1] "Processing AEJApp2012"
## 
## > val.completed <- c("compelte", "complete", "completed", 
## +     "competed")
## 
## > val.incorrect <- c("done incorrectly")
## 
## > val.valid <- c("completed", "incorrect")
## 
## > repllist2 <- repllist %>% mutate(DOI = ifelse(DOI == 
## +     "10.1257/aer.2013047", "10.1257/aer.20130479", DOI)) %>% 
## +     mutate(DOI = ifelse(DOI  .... [TRUNCATED] 
## 
## > saveRDS(repllist2, file = file.path(interwrk, "repllist2.Rds"))
```

At the end of this program, a dataset **`repllist2.Rds` should be present in `interwrk`, containing consolidated data.

### Some diagnostics


```
##      DOI            Entry Questionnaire   assessor        
##  Length:1231        Length:1231         Length:1231       
##  Class :character   Class :character    Class :character  
##  Mode  :character   Mode  :character    Mode  :character  
##                                                           
##                                                           
##                                                           
##                                                           
##  Expected Difficulty  Completed1        Replicated1       
##  Min.   :1.000       Length:1231        Length:1231       
##  1st Qu.:2.000       Class :character   Class :character  
##  Median :3.000       Mode  :character   Mode  :character  
##  Mean   :3.257                                            
##  3rd Qu.:5.000                                            
##  Max.   :5.000                                            
##  NA's   :508                                              
##  Replicator1         Completed2        Replicated2       
##  Length:1231        Length:1231        Length:1231       
##  Class :character   Class :character   Class :character  
##  Mode  :character   Mode  :character   Mode  :character  
##                                                          
##                                                          
##                                                          
##                                                          
##  Replicator2         Data Type         Data Access Type  
##  Length:1231        Length:1231        Length:1231       
##  Class :character   Class :character   Class :character  
##  Mode  :character   Mode  :character   Mode  :character  
##                                                          
##                                                          
##                                                          
##                                                          
##  Data Comments        Data URL         Data Contact      
##  Length:1231        Length:1231        Length:1231       
##  Class :character   Class :character   Class :character  
##  Mode  :character   Mode  :character   Mode  :character  
##                                                          
##                                                          
##                                                          
##                                                          
##   worksheet         Data Access Type: restricted Data Access Type: public
##  Length:1231        Length:1231                  Length:1231             
##  Class :character   Class :character             Class :character        
##  Mode  :character   Mode  :character             Mode  :character        
##                                                                          
##                                                                          
##                                                                          
##                                                                          
##  Data Access Type: Unknown
##  Length:1231              
##  Class :character         
##  Mode  :character         
##                           
##                           
##                           
## 
```

                              completed   incorrect    NA
---------------------------  ----------  ----------  ----
AEJApp2012                            0           0    40
First2014                             0           0    38
First2015                            35           0     0
MASTER Summer 2018 forward          544           1   221
Second2015                           36           0     0
Spring2016                           64           0     0
Spring2017                            0           0    10
Spring2018                           31           0    15
Spring2018AER                         1           0   121
Summer2016                           20           0    14
Summer2017                            0           0    40
NA                                    0           0     0

We cannot tabulate here by journal, since that information is embedded in the DOI, which we will parse separately.


Var1            Freq
-------------  -----
in progress       39
incomplete        51
needs abaqus       1
needs dynare       1
no                 2
working            6
y                135
yes              550
NA               446

## Anonymize the data
The Google Sheet data contains the actual login ID or name of the replicators. We anonymize them. This can only be executed by the project owners.

 - Input data: path `interwrk`
 - Output data: path `dataloc`
 

```r
source(file.path(programs,"03_gen_anonymous_ID.R"),echo=TRUE)
```

```
## 
## > tmp_repllist <- readRDS(file = file.path(interwrk, 
## +     "repllist2.Rds"))
## 
## > entryQ <- readRDS(file = file.path(interwrk, "entryQ.Rds"))
## 
## > entryQ2011 <- readRDS(file = file.path(interwrk, "entryQ2011.Rds"))
## 
## > exitQ <- readRDS(file = file.path(interwrk, "exitQ.Rds"))
## 
## > repllistnames <- tmp_repllist %>% select(DOI, assessor, 
## +     Replicator1, Replicator2, worksheet) %>% filter(!(is.na(assessor) & 
## +     is.na(Repl .... [TRUNCATED] 
## 
## > entryQ2011.names <- entryQ2011 %>% select(DOI, NetID)
## 
## > entryQ.names <- entryQ %>% select(DOI, NetID)
## 
## > entryQnames_complete <- rbind(entryQ.names, entryQ2011.names)
## 
## > setnames(exitQ, "NetID or email", "NetID", skip_absent = TRUE)
## 
## > candidates <- merge(x = repllistnames, y = entryQnames_complete, 
## +     by = "DOI", all = TRUE) %>% filter(!is.na(worksheet))
## 
## > write.csv(candidates, file = file.path(interwrk, "maplist_entry.csv"))
## 
## > mapping_nametoID <- read.csv(file.path(confidential, 
## +     "mapping_name_ID.csv")) %>% select(Name, NetID) %>% mutate(Name = gsub(" $", 
## +     "",  .... [TRUNCATED] 
## 
## > anonymise <- function(data, cols_to_mask, algo = "sha256") {
## +     if (!require(digest)) 
## +         stop("digest package is required")
## +     to_anon .... [TRUNCATED] 
## 
## > entryQnames_list <- unique(entryQnames_complete[, 
## +     c("NetID")])
## 
## > entryQnames_list$ID <- anonymise(entryQnames_list, 
## +     c("NetID"))
## 
## > entryQ$ID <- anonymise(entryQ, c("NetID"))
## 
## > exitQ$ID <- anonymise(exitQ, c("NetID"))
## 
## > mapping_nametoID$ID <- anonymise(mapping_nametoID, 
## +     c("NetID"))
## 
## > test.entryQ <- entryQ %>% filter(is.na(ID) & !is.na(NetID))
## 
## > test.exitQ <- exitQ %>% filter(is.na(ID) & !is.na(NetID))
## 
## > tmp_repllist$Replicator1a <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator1, 
## +     mapping_nametoID$NetID)])
## 
## > tmp_repllist$Replicator1b <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator1, 
## +     mapping_nametoID$Name)])
## 
## > tmp_repllist$Replicator1c <- as.character(entryQnames_list$ID[match(tmp_repllist$Replicator1, 
## +     entryQnames_list$NetID)])
## 
## > tmp_repllist$Replicator1_anon <- pmax(tmp_repllist$Replicator1a, 
## +     tmp_repllist$Replicator1b, tmp_repllist$Replicator1c, na.rm = TRUE)
## 
## > tmp_repllist$Replicator2a <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator2, 
## +     mapping_nametoID$NetID)])
## 
## > tmp_repllist$Replicator2b <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator2, 
## +     mapping_nametoID$Name)])
## 
## > tmp_repllist$Replicator2c <- as.character(entryQnames_list$ID[match(tmp_repllist$Replicator2, 
## +     entryQnames_list$NetID)])
## 
## > tmp_repllist$Replicator2_anon <- pmax(tmp_repllist$Replicator2a, 
## +     tmp_repllist$Replicator2b, tmp_repllist$Replicator2c, na.rm = TRUE)
## 
## > tmp_repllist$assessora <- as.character(mapping_nametoID$ID[match(tmp_repllist$assessor, 
## +     mapping_nametoID$NetID)])
## 
## > tmp_repllist$assessorb <- as.character(mapping_nametoID$ID[match(tmp_repllist$assessor, 
## +     mapping_nametoID$Name)])
## 
## > tmp_repllist$assessorc <- as.character(entryQnames_list$ID[match(tmp_repllist$assessor, 
## +     entryQnames_list$NetID)])
## 
## > tmp_repllist$assessor_anon <- pmax(tmp_repllist$assessora, 
## +     tmp_repllist$assessorb, tmp_repllist$Replicator2c, na.rm = TRUE)
## 
## > test.repllist.var1 <- tmp_repllist %>% filter(is.na(Replicator1_anon) & 
## +     !is.na(Replicator1))
## 
## > test.repllist.var2 <- tmp_repllist %>% filter(is.na(Replicator2_anon) & 
## +     !is.na(Replicator2))
## 
## > test.repllist.var3 <- tmp_repllist %>% filter(is.na(assessor_anon) & 
## +     !is.na(assessor))
## 
## > nrow(test.entryQ)
## [1] 0
## 
## > nrow(test.exitQ)
## [1] 0
## 
## > nrow(test.repllist.var1)
## [1] 0
## 
## > nrow(test.repllist.var2)
## [1] 0
## 
## > nrow(test.repllist.var3)
## [1] 0
## 
## > tmp_repllist <- tmp_repllist %>% select(-starts_with("assessor"), 
## +     -starts_with("Replicator"), ends_with("_anon"))
```




### Sanity Checks

Anonymized IDs should be present when a non-anonymous ID is present:

 - Entry questionnaire: **OK**
 - Exit questionnaire: **OK**
 - Replication Assignment List, Var1: **OK**
 - Replication Assignment List, Var2: **OK**
 - Replication Assignment List, Var3: **OK**


## Prepare for upload to Zenodo

In order to upload, we 

- strip the non-anonymous ID variable
verify that no names are contained in the relevant columns anymore
- create a rudimentary codebook


```r
# Rewrite and replace the data set without NetID
entryQ <- select(entryQ,ID,everything(),-c(NetID))
exitQ <-select(exitQ,ID,everything(),-c(NetID))
# this is already done
#tmp_repllist <- select(tmp_repllist,select=-assessor,-Replicator1,-Replicator2)

# Save in permanent location
knitr::kable(names(entryQ),caption = "Names on EntryQ data")
```



Table: Names on EntryQ data

|x                                                                 |
|:-----------------------------------------------------------------|
|ID                                                                |
|Timestamp                                                         |
|DOI                                                               |
|TypeOfArticle                                                     |
|OnlineData                                                        |
|AdditionalMaterialNumber                                          |
|OnlineMaterials1_DOI                                              |
|OnlineData_1                                                      |
|DataAbsence                                                       |
|DataRunClean                                                      |
|OnlineDataDOI2                                                    |
|OnlineDataHandle2                                                 |
|OnlineDataURL2                                                    |
|DataAvailability                                                  |
|DataAvailabilityAccess                                            |
|DataAvailabilityExclusive                                         |
|OtherNotes1                                                       |
|Is there some other online material that you wish to describe     |
|OnlineDataDOI2_1                                                  |
|OnlineDataHandle2_1                                               |
|OnlineDataURL2_1                                                  |
|DataAvailability2                                                 |
|DataAvailabilityAccess2                                           |
|DataAvailabilityExclusive2                                        |
|OtherNotes2                                                       |
|Do you want to describe another dataset                           |
|OnlineDataDOI3                                                    |
|OnlineDataHandle3                                                 |
|OnlineDataURL3                                                    |
|DataAvailability3                                                 |
|DataAvailabilityAccess3                                           |
|DataAvailabilityExclusive3                                        |
|OtherNotes3                                                       |
|DataRunFinal                                                      |
|OnlineFinalDataDOI                                                |
|OnlineFinalDataHandle                                             |
|OnlineFinalDataURL                                                |
|FinalDataAvailability                                             |
|FinalDataAvailabilityAccess                                       |
|FinalDataAvailabilityExclusive                                    |
|OtherNotesFinal                                                   |
|DataFormatInputs                                                  |
|OnlineDataFormat2                                                 |
|OnlinePrograms                                                    |
|OnlineProgramsInside                                              |
|OnlineProgramsDOI                                                 |
|OnlineProgramsHDL                                                 |
|OnlineProgramsURL                                                 |
|DocReadmePresent                                                  |
|DocReadmeContent                                                  |
|ProgramFormat                                                     |
|ProgramSequence                                                   |
|ProgramsDocumentation                                             |
|ProgramsHeaderAuthor                                              |
|ProgramsHeaderInfo                                                |
|ProgramsStructureManual                                           |
|GeneralNotes                                                      |
|How difficult do you think replicating the article will be        |
|OnlineMaterials                                                   |
|OnlineMaterials1                                                  |
|Do you want to describe another dataset provided with the article |
|OnlineMaterials1_URL                                              |
|OnlineMaterials2                                                  |
|OnlineMaterials2_URL                                              |
|OnlineMaterials2_DOI                                              |
|Is there some other online material that you wish to describe_1   |
|OnlineMaterials3                                                  |
|OnlineMaterials3_URL                                              |
|OnlineMaterials3_DOI                                              |
|AnalysisData                                                      |
|OnlineMaterials1_Description                                      |
|OnlineMaterials2_Description                                      |
|OnlineMaterials3_Description                                      |
|Programs                                                          |
|OnlineDataProvided                                                |
|DataSetNumbers                                                    |
|DataSetClassification1                                            |
|OnlineDataDOI1                                                    |
|OnlineDataHandle1                                                 |
|OnlineDataURL1                                                    |
|OnlineDataFormat1                                                 |
|DataSetClassification2                                            |
|OtherNotes2_1                                                     |
|InputData                                                         |
|InputData1                                                        |
|InputDataRef                                                      |
|InputDataDOI1                                                     |
|InputDataURL1                                                     |
|InputDataHandle1                                                  |
|InputDataFormat1                                                  |
|InputDataAvailability1                                            |
|InputDataMoreThanOne                                              |
|InputData2                                                        |
|InputDataDOI2                                                     |
|InputDataHandle2                                                  |
|InputDataURL2                                                     |
|InputDataFormat2                                                  |
|InputDataAvailability2                                            |
|InputDataOtherNotes1                                              |
|InputDataOtherNotes2                                              |
|Flag for follow-up                                                |
|OnlinePrograms_1                                                  |
|flag2011                                                          |

```r
saveRDS(entryQ,,file=file.path(Outputs,"entryQ_pub.Rds"))
write.csv(entryQ, file = file.path(Outputs,"entryQ_pub.csv"))

knitr::kable(names(exitQ),caption = "Names on ExitQ data")
```



Table: Names on ExitQ data

|x                                                                      |
|:----------------------------------------------------------------------|
|ID                                                                     |
|Timestamp                                                              |
|DOI                                                                    |
|Code_Success                                                           |
|Program_Run_Clean                                                      |
|Directory_Change                                                       |
|Code_Changes                                                           |
|Output_Accuracy                                                        |
|Discrepancy_Location                                                   |
|Software_Extensions                                                    |
|Software_Version                                                       |
|First_Replicator                                                       |
|Common_Issues                                                          |
|Overcome_Issues                                                        |
|Replication_Helpfulness                                                |
|README_Quality                                                         |
|README_Comments                                                        |
|How difficult do you think the replication exercise was                |
|Comments on difficulty                                                 |
|GeneralNotes                                                           |
|What Software did you use for the replication (including the version)  |
|Replication_Success                                                    |
|Main_Issue                                                             |
|Data_Type                                                              |
|Data_Access_Type                                                       |
|Software_Type                                                          |
|Data_Type_1                                                            |
|Cost of data access (in approximate $)                                 |
|Cost of software purchase (in approximate $)                           |
|What software did the authors use to run their programs (if specified) |

```r
saveRDS(exitQ,file = file.path(Outputs,"exitQ_pub.Rds"))
write.csv(exitQ, file = file.path(Outputs,"exitQ_pub.csv"))

knitr::kable(names(tmp_repllist),caption = "Names on Replication Assignment List data")
```



Table: Names on Replication Assignment List data

|x                            |
|:----------------------------|
|DOI                          |
|Entry Questionnaire          |
|Expected Difficulty          |
|Completed1                   |
|Replicated1                  |
|Completed2                   |
|Replicated2                  |
|Data Type                    |
|Data Access Type             |
|Data Comments                |
|Data URL                     |
|Data Contact                 |
|worksheet                    |
|Data Access Type: restricted |
|Data Access Type: public     |
|Data Access Type: Unknown    |
|Replicator1_anon             |
|Replicator2_anon             |
|assessor_anon                |

```r
saveRDS(tmp_repllist, file = file.path(Outputs,"replication_list_pub.Rds"))
write.csv(tmp_repllist, file = file.path(Outputs,"replication_list_pub.csv"))

# write metadata

metadata <- data.frame(schema="dc.terms")
metadata$dc.identifier <- "10.5281/zenodo.2639920"
metadata$dc.title <- "Data from the Cornell LDI Replication Lab"
metadata$dc.creator <- "Hautahi Kingi and Sylverie Herbert and Flavio Stancchi and Lars Vilhuber"
metadata$dc.date <- as.character(as.Date.character(Sys.Date()))
metadata$last.update <- as.character(as.Date.character(Sys.Date()))
metadata$last.modified.by <- Sys.info()["user"]
metadata$dc.relation <- gsub("git@","https://",gsub(":","/",gsub("\\.git","",git_remotes()$origin)))
```

```
## ✔ Setting active project to '/mnt/local/slow_home/vilhuber/Workspace-non-encrypted/git/LDI/ldi-replication-dataprep'
```

```r
metadata$dc.type <- "data"
metadata <- gather(metadata)
```

```
## Warning: attributes are not identical across measure variables;
## they will be dropped
```

```r
write.csv(metadata, file = file.path(Outputs,"metadata.csv"),row.names = FALSE)
knitr::kable(metadata)
```



key                value                                                                    
-----------------  -------------------------------------------------------------------------
schema             dc.terms                                                                 
dc.identifier      10.5281/zenodo.2639920                                                   
dc.title           Data from the Cornell LDI Replication Lab                                
dc.creator         Hautahi Kingi and Sylverie Herbert and Flavio Stancchi and Lars Vilhuber 
dc.date            2019-04-14                                                               
last.update        2019-04-14                                                               
last.modified.by   vilhuber                                                                 
dc.relation        https://github.com/labordynamicsinstitute/ldi-replication-dataprep       
dc.type            data                                                                     


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

