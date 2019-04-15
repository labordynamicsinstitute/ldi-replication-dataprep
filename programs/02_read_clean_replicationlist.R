# This program reads the data created by the replicators and downloaded from
# Google in the previous step and compiles them into a master dataframe

# -------------------------------------
# Compile replication lists into a master file
# -------------------------------------

# Read in worksheet names of the replication google sheets
ws <- readRDS(file=file.path(interwrk,"mapping_ws_nums.Rds"))
ws <- as.vector(unlist(ws[1:length(ws)-1]))

# Compile all the worksheets except for "2009 missing online material"
repllist <- NA
read.as.csv <- FALSE

myfilter <- function (ds) {
	ds <- ds %>% select(DOI,
								`Entry Questionnaire`,assessor,`Expected Difficulty`,
								Completed1 = Completed, Replicated1 = Replicated, Replicator1 = Replicator,
								Completed2 = Completed_1, Replicated2 = Replicated_1, Replicator2 = `2nd Replicator`,
								`Data Type`,`Data Access Type`,`Data Comments`,`Data URL`,`Data Contact`,
								starts_with("Data Access Type:"),worksheet) 
	return(ds)
}

for ( x in 1:length(ws) ) {
  if ( ws[x] != "2009 missing online material" & ws[x] != "Spring2016 list") {
    print(paste("Processing",ws[x]))
    if ( x == 1 ) {
      # Read in the first list and set variable types
      if ( read.as.csv ) {
          repllist <- read_csv(file = file.path(interwrk,paste0("replication_list_",x,".csv")),
                           col_types = cols(
                             .default = col_character(), X1 = col_integer(),
                             Year = col_integer(),Volume = col_integer(),
                             Issue = col_integer()
                             )
                           )
      } else {
      	repllist <- readRDS(file.path(interwrk,paste0("replication_list_",x,".Rds"))) %>%
      		mutate(`Expected Difficulty`=as.numeric(`Expected Difficulty`)) 
      }
    	# adjust for idiosyncracies
    	if ( ws[x] == "MASTER Summer 2018 forward" ) {
    		repllist <- repllist %>%
    			mutate(assessor = ifelse(`Entry Questionnaire Author`=="",Replicator,`Entry Questionnaire Author`))
    	}
    	repllist <- myfilter(repllist)
    } else {
      # Read in the subsequent lists and set variable types
    	if ( read.as.csv ) {
         tmp <- read_csv(file = file.path(interwrk,paste0("replication_list_",x,".csv")),
                      col_types = cols(
                        .default = col_character(), X1 = col_integer(),
                        Year = col_integer(), Volume = col_integer(),
                        Issue = col_integer()
                        )
                      )
    	} else {
    		tmp <- readRDS(file.path(interwrk,paste0("replication_list_",x,".Rds")))
    	}
    	# adjust for idiosyncracies
    	tmp$assessor <- ""
    	if ( ws[x] == "Summer2016" ) {
    		tmp <- tmp %>% rename(exp_diff = `Expected Difficulty`) %>%
    			             mutate(`Expected Difficulty` = as.numeric(substr(exp_diff,1,1)))
    		
    	}
    	if ( ws[x] == "Spring2017" |  ws[x] == "AEJApp2012" | ws[x] == "Spring2016 list" ) {
    		tmp$`Data URL` = ""
    		tmp$`Data Contact` = ""
    	}
    	if ( ws[x] == "Spring2017" |  ws[x] == "Spring2016"  ) {
    		tmp <- mutate(tmp,`2nd Replicator`=ifelse(`2nd Replicator` %in% c("Y","N"),NA,`2nd Replicator`))
    	}
    	# keep only relevant vars
    	tmp <- myfilter(tmp)
      # Add to master dataframe
      repllist <- bind_rows(repllist,tmp)
      rm(tmp)
    }
  }
}

# -------------------------------------
# Tidy up compiled master file
# -------------------------------------

# Fix typos,  Standardize some variables
# Classify the various options
val.completed <- c("compelte","complete","completed","competed")
val.incorrect <- c("done incorrectly")
val.valid <- c("completed","incorrect")
# Classify the various options

repllist2 <- repllist %>%
  mutate(DOI = ifelse(DOI == "10.1257/aer.2013047","10.1257/aer.20130479",DOI)) %>%
  mutate(DOI = ifelse(DOI == "10.1257/app.4.1.247","10.1257/app.4.2.247",DOI)) %>%
	mutate(assessor = ifelse(assessor=="" | is.na(assessor),`Entry Questionnaire`,assessor)) %>%
	mutate(assessor = ifelse(tolower(assessor) %in% val.completed,"",assessor)) %>%
	mutate(assessor = ifelse((assessor=="" | is.na(assessor) ) & Replicator1 !="",Replicator1,assessor)) %>%
	mutate(`Entry Questionnaire` = ifelse(`Entry Questionnaire`==assessor,"completed",
																				`Entry Questionnaire`)) %>%
    mutate(`Entry Questionnaire` = ifelse(tolower(`Entry Questionnaire`) %in% val.completed,val.valid[1],
																		`Entry Questionnaire`)) %>%
	mutate(`Entry Questionnaire` = ifelse(tolower(`Entry Questionnaire`) %in% val.incorrect,val.valid[2],
																				`Entry Questionnaire`)) %>%
	mutate(`Completed1` = ifelse(is.na(Completed1) & !is.na(Replicated1),"yes",Completed1)) 
	
	



# Save
saveRDS(repllist2,file=file.path(interwrk,"repllist2.Rds"))

