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
for ( x in 1:length(ws) ) {
  if ( ws[x] != "2009 missing online material" ) {
    print(paste("Processing",ws[x]))
    if ( x == 1 ) {
      # Read in the first list and set variable types
      repllist <- read_csv(file = file.path(interwrk,paste0("replication_list_",x,".csv")),
                           col_types = cols(
                             .default = col_character(), X1 = col_integer(),
                             Year = col_integer(),Volume = col_integer(),
                             Issue = col_integer()
                             )
                           )
    } else {

      # Read in the subsequent lists and set variable types
      tmp <- read_csv(file = file.path(interwrk,paste0("replication_list_",x,".csv")),
                      col_types = cols(
                        .default = col_character(), X1 = col_integer(),
                        Year = col_integer(), Volume = col_integer(),
                        Issue = col_integer()
                        )
                      )

      # Add to master dataframe
      repllist <- bind_rows(repllist,tmp)
      rm(tmp)
    }
  }
}

# -------------------------------------
# Tidy up compiled master file
# -------------------------------------

# Fix typos
repllist2 <- repllist %>%
  mutate(DOI = ifelse(DOI == "10.1257/aer.2013047","10.1257/aer.20130479",DOI)) %>%
  mutate(DOI = ifelse(DOI == "10.1257/app.4.1.247","10.1257/app.4.2.247",DOI))

# Drop the verbose article descriptions (authors, etc.) to later pick it up again from Crossref
repllist2 <- repllist2 %>%
  select(DOI,`Source Title`,
         `Entry Questionnaire`,`Entry Questionnaire Author`,`Expected Difficulty`,
         Completed1 = Completed, Replicated1 = Replicated, Replicator1 = Replicator,
         Completed2 = Completed_1, Replicated2 = Replicated_1, Replicator2 = `2nd Replicator`,
         `Data Type`,`Data Access Type`,`Data Comments`,`Data URL`,`Data Contact`,
         starts_with("Data Access Type:"),worksheet.rownum=X1,worksheet)

# Some diagnostics
knitr::kable(table(repllist2$`Entry Questionnaire Author`,repllist2$`Source Title`))

# Save
saveRDS(repllist2,file=file.path(interwrk,"repllist2.Rds"))

