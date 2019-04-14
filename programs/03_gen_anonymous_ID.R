# This program will anonymize the data, creating a lookup database of names, then hashing them.
# Author: Sylverie Herbert

repllist2 <- readRDS(file=file.path(interwrk,"repllist2.Rds"))
entryQ <- readRDS(file = file.path(interwrk,"entryQ.Rds"))
entryQ2011 <- readRDS(file = file.path(interwrk,"entryQ2011.Rds"))

# Compile a list of NetID, names
repllistnames <- repllist2 %>%
  select(DOI,`Entry Questionnaire Author`, Replicator1 , Replicator2 ,worksheet)

# Merge the two entry questionnaires list of NetID-DOI
entryQnames2011 <- entryQ2011 %>%
  select(DOI,NetID)

entryQnames <- entryQ %>%
  select(DOI,NetID)

entryQnames_complete <- rbind(entryQnames,entryQnames2011)

# Generate anonymous ID for each NETID in entry questionnaire
anonymise <- function(data, cols_to_mask, algo = "sha256")
{
  if(!require(digest)) stop("digest package is required")
  to_anon <- subset(data, select = cols_to_mask)
  unname(apply(to_anon, 1, digest, algo = algo))
}

cols_to_mask <- c("NetID")

entryQnames_complete$ID <- anonymise(entryQnames_complete, cols_to_mask)

setnames(exitQ,"NetID or email","NetID")

# Create data set to flag people who use alternatively name or netID in the replication list
candidates=merge(x = repllistnames, y = entryQnames_complete, by = "DOI", all = TRUE)
write.csv(candidates, file = file.path(dataloc,"maplist_entry.csv"))

# Rewrite the data with anonymous ID
# combine the two entry questionnaires first
entryQ_combined <- rbind.fill(entryQ,entryQ2011)
# clean variables we don't want from 2011
entryQ_combined <- subset(entryQ_combined, select = -c(X8,OnlineDataInside,DataRunIntermediate,OnlineProgramsDOI_1) )

entryQnames_list <-subset(entryQnames_complete,select=-c(DOI))
entryQnames_list <- unique(entryQnames_list)

# bring in the generated ID (I verified and exit and entry only have NetID to my knowledge)
entryQ <-merge(x = entryQ_combined, y = entryQnames_list, by = "NetID")
exitQ <- merge(x= exitQ, y=entryQnames_list, by= "NetID",all.x=TRUE)

# Rewrite and replace the data set without NetID
entryQ <-subset(entryQ,select=-c(NetID))
exitQ <-subset(exitQ,select=-c(NetID))
write.csv(entryQ, file = file.path(dataloc,"entryQ.csv"))
write.csv(exitQ, file = file.path(dataloc,"exitQ.csv"))

# Same exercise for the replication list Replicator 1 and Replicator 2
mapping_nametoID <-read.csv(file.path(dataloc,"mapping_name_ID.csv"))

repllist2$Replicator1a <- mapping_nametoID$ID[match(repllist2$Replicator1,mapping_nametoID$NetID)]
repllist2$Replicator1b <- mapping_nametoID$ID[match(repllist2$Replicator1,mapping_nametoID$Name)]
repllist2$Replicator1c <- entryQnames_complete$ID[match(repllist2$Replicator1,entryQnames_complete$NetID)]
repllist2$Replicator2a <- mapping_nametoID$ID[match(repllist2$Replicator2,mapping_nametoID$NetID)]
repllist2$Replicator2b <- mapping_nametoID$ID[match(repllist2$Replicator2,mapping_nametoID$Name)]
repllist2$Replicator2c <- entryQnames_complete$ID[match(repllist2$Replicator2,entryQnames_complete$NetID)]


repllist2$Replicator1a <- as.character(repllist2$Replicator1a)
repllist2$Replicator1b <- as.character(repllist2$Replicator1b)
repllist2$Replicator2a <- as.character(repllist2$Replicator2a)
repllist2$Replicator2b <- as.character(repllist2$Replicator2b)

repllist2$Replicator1a <- ifelse(is.na(repllist2$Replicator1a), "", repllist2$Replicator1a)
repllist2$Replicator1b <- ifelse(is.na(repllist2$Replicator1b), "", repllist2$Replicator1b)
repllist2$Replicator1c <- ifelse(is.na(repllist2$Replicator1c), "", repllist2$Replicator1c)
repllist2$Replicator2a <- ifelse(is.na(repllist2$Replicator2a), "", repllist2$Replicator2a)
repllist2$Replicator2b <- ifelse(is.na(repllist2$Replicator2b), "", repllist2$Replicator2b)
repllist2$Replicator2c <- ifelse(is.na(repllist2$Replicator2c), "", repllist2$Replicator2c)

repllist2$Replicator1 <- with(repllist2, paste0(repllist2$Replicator1a, repllist2$Replicator1b, repllist2$Replicator1c))
repllist2$Replicator1 <-pmax(repllist2$Replicator1a, repllist2$Replicator1b,repllist2$Replicator1c)
repllist2$Replicator2 <- with(repllist2, paste0(repllist2$Replicator2a, repllist2$Replicator2b, repllist2$Replicator2c))
repllist2$Replicator2 <-pmax(repllist2$Replicator2a, repllist2$Replicator2b,repllist2$Replicator2c)

# Save in permanent location
saveRDS(repllist2, file = file.path(dataloc,"replication_list.Rds"))
write.csv(repllist2, file = file.path(dataloc,"replication_list.csv"))




