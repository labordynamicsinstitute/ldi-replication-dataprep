# This program downloads the data created by the replicators from the
# Google sheets noted in the config.R file
# and saves the csv/R files in the data/replications_data folder
# You may need to issue the gs_auth() function first
# gs_auth()

# -------------------------------------
# Extract Entry Questionnaire and Save
# -------------------------------------

# Extract Google Sheet Information Object
entryQ.gs <- gs_key(entry_KEY)
gs_auth()
entryQ2011.gs <- gs_key(entry2011_KEY)

# Print worksheet names
gs_ws_ls(entryQ.gs)
gs_ws_ls(entryQ2011.gs)


# Extract Entry Questionnaire and tidy
entryQ <- entryQ.gs %>% gs_read(ws = "Form Responses 1") %>%
	select(-`[Row 1]`,-starts_with("X6"))
names(entryQ) <- sub("\\?","",names(entryQ))
setnames(entryQ,"X94","InputDataMoreThanOne")


entryQ2011 <- entryQ2011.gs %>% gs_read(ws = "Form Responses 1")
names(entryQ2011) <- sub("\\?","",names(entryQ2011))

# Rename the columns of 2011 questionnaires to fit the new version of the questionnaire
setnames(entryQ2011,"X34","NetID")
setnames(entryQ2011,"OnlineData","OnlineDataProvided")
setnames(entryQ2011,"OnlineAppendix","OnlineMaterials")
setnames(entryQ2011,"OnlineAppendixURL","OnlineMaterials1")
setnames(entryQ2011,"OnlineAppendixDOI","OnlineMaterials1_DOI")

# For those, needs to reshuffle a little
setnames(entryQ2011,"DataFormatAnalysis","OnlineDataFormat2")
entryQ2011$DataFormatInputs1 <- entryQ2011$DataFormatInputs
setnames(entryQ2011,"DataFormatInputs","InputDataFormat1")
setnames(entryQ2011,"DataFormatInputs1","OnlineDataFormat1")
setnames(entryQ2011,"OnlineDataHandle","OnlineDataHandle1")
setnames(entryQ2011,"OnlineDataDOI","OnlineDataDOI1")
setnames(entryQ2011,"OnlineDataURL","OnlineDataURL1")

entryQ2011$DataSetClassification1[!is.na(entryQ2011$OnlineDataFormat1)]<- "Input Data"
entryQ2011$DataSetClassification2[!is.na(entryQ2011$OnlineDataFormat2)]<- "Analysis Data"

entryQ2011$OnlineDataDOI2 <- ifelse(!is.na(entryQ2011$OnlineDataFormat2), entryQ2011$OnlineDataDOI1, NA)
entryQ2011$OnlineDataURL2 <- ifelse(!is.na(entryQ2011$OnlineDataFormat2), entryQ2011$OnlineDataURL1, NA)
entryQ2011$OnlineDataHandle2 <- ifelse(!is.na(entryQ2011$OnlineDataFormat2), entryQ2011$OnlineDataHandle1, NA)




# Create a flag
entryQ2011$flag2011 <- 1
entryQ$flag2011 <- 0

# Save
saveRDS(entryQ,file = file.path(interwrk,"entryQ.Rds"))
write.csv(entryQ,file = file.path(interwrk,"entryQ.csv"))
saveRDS(entryQ2011,file = file.path(interwrk,"entryQ2011.Rds"))
write.csv(entryQ2011,file = file.path(interwrk,"entryQ2011.csv"))
# -------------------------------------
# Extract Exit Questionnaire and Save
# -------------------------------------

# Extract Google Sheet Information Object
exitQ.gs <- gs_key(exit_KEY)

# Print worksheet names
gs_ws_ls(exitQ.gs)

# Extract Exit Questionnaire and tidy (This should now work after changing permissions)
exitQ  <- exitQ.gs  %>% gs_read(ws = "Form Responses 1") %>%
	select(-X10,-X11)
names(exitQ) <- sub("\\?","",names(exitQ))
setnames(exitQ,"X18","README_Quality")
setnames(exitQ,"X19","README_Comments")


# Save
saveRDS(exitQ,file = file.path(interwrk,"exitQ.Rds"))
write.csv(exitQ,file = file.path(interwrk,"exitQ.csv"))

# -------------------------------------
# Extract Replication Sheets and Save
# -------------------------------------

# Extract Google Sheet Information Object
replication_list.gs <- gs_key(replication_list_KEY)

# Print worksheet names
gs_ws_ls(replication_list.gs)

# Iterate over each of the multiple sheets
ws <- gs_ws_ls(replication_list.gs)
for (x in 1:length(ws)) {

  # Extract list and tidy
	tmp.ws <- gs_read(replication_list.gs,ws=x)
	tmp.ws$worksheet <- ws[x]
	names(tmp.ws) <- sub("\\?","",names(tmp.ws))

	# Save
	saveRDS(tmp.ws,file = file.path(interwrk,paste0("replication_list_",x,".Rds")))
	write.csv(tmp.ws,file = file.path(interwrk,paste0("replication_list_",x,".csv")))

	# Pause so Google doesn't freak out
	Sys.sleep(10)
	rm(tmp.ws)

}

# Export the worksheet names to be used in a later data cleaning step
# This allows us to skip the "2009 missing online material" sheet, which
# has a different structure, in the next program.
ws <- as.data.frame(ws)
ws$date <- Sys.Date()
saveRDS(ws,file=file.path(interwrk,"mapping_ws_nums.Rds"))


