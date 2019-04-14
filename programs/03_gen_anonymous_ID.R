# This program will anonymize the data, creating a lookup database of names, then hashing them.
# Author: Sylverie Herbert

tmp_repllist <- readRDS(file=file.path(interwrk,"repllist2.Rds"))
entryQ <- readRDS(file = file.path(interwrk,"entryQ.Rds"))
entryQ2011 <- readRDS(file = file.path(interwrk,"entryQ2011.Rds"))
exitQ <- readRDS(file = file.path(interwrk,"exitQ.Rds"))

# Compile a list of NetID, names, across the three datasets
repllistnames <- tmp_repllist %>%
  select(DOI,assessor, Replicator1 , Replicator2 ,worksheet) 

# Merge the two entry questionnaires list of NetID-DOI
entryQ2011.names <- entryQ2011 %>%
  select(DOI,NetID)

entryQ.names <- entryQ %>%
  select(DOI,NetID)

entryQnames_complete <- rbind(entryQ.names,entryQ2011.names)

# clean up possible alternate labels on exitQ
setnames(exitQ,"NetID or email","NetID",skip_absent = TRUE)

# Create data set to flag people who use alternatively name or netID in the replication list
candidates <- merge(x = repllistnames, y = entryQnames_complete, by = "DOI", all = TRUE)
write.csv(candidates, file = file.path(interwrk,"maplist_entry.csv"))

### We reviewed the list of candidates to find the mapping, and added any manual ones
### Names are mapped to NETIDs
### 
mapping_nametoID <-read.csv(file.path(dataloc,"mapping_name_ID.csv")) %>% select(Name,NetID)


# Generate anonymous ID for each NETID in entry questionnaire
anonymise <- function(data, cols_to_mask, algo = "sha256")
{
	if(!require(digest)) stop("digest package is required")
	to_anon <- subset(data, select = cols_to_mask)
	unname(apply(to_anon, 1, digest, algo = algo))
}

entryQnames_complete$ID <- anonymise(entryQnames_complete, c("NetID"))
exitQ$ID <- anonymise(exitQ,c("NetID"))

#============================================
# Rewrite the data with anonymous ID
# ===========================================


entryQnames_list <-subset(entryQnames_complete,select=c("NetID","ID"))
entryQnames_list <- unique(entryQnames_list)

# bring in the generated ID (I verified and exit and entry only have NetID to my knowledge)
entryQ <-merge(x = entryQ_combined, y = entryQnames_list, by = "NetID")
exitQ <- merge(x= exitQ, y=entryQnames_list, by= "NetID",all.x=TRUE)

# Rewrite and replace the data set without NetID
entryQ <-subset(entryQ,select=-c(NetID))
exitQ <-subset(exitQ,select=-c(NetID))


#====================================================================
# Same exercise for the replication list Replicator 1 and Replicator 2

tmp_repllist$Replicator1a <- mapping_nametoID$ID[match(tmp_repllist$Replicator1,mapping_nametoID$NetID)]
tmp_repllist$Replicator1b <- mapping_nametoID$ID[match(tmp_repllist$Replicator1,mapping_nametoID$Name)]
tmp_repllist$Replicator1c <- entryQnames_complete$ID[match(tmp_repllist$Replicator1,entryQnames_complete$NetID)]
tmp_repllist$Replicator2a <- mapping_nametoID$ID[match(tmp_repllist$Replicator2,mapping_nametoID$NetID)]
tmp_repllist$Replicator2b <- mapping_nametoID$ID[match(tmp_repllist$Replicator2,mapping_nametoID$Name)]
tmp_repllist$Replicator2c <- entryQnames_complete$ID[match(tmp_repllist$Replicator2,entryQnames_complete$NetID)]


tmp_repllist$Replicator1a <- as.character(tmp_repllist$Replicator1a)
tmp_repllist$Replicator1b <- as.character(tmp_repllist$Replicator1b)
tmp_repllist$Replicator2a <- as.character(tmp_repllist$Replicator2a)
tmp_repllist$Replicator2b <- as.character(tmp_repllist$Replicator2b)

tmp_repllist$Replicator1a <- ifelse(is.na(tmp_repllist$Replicator1a), "", tmp_repllist$Replicator1a)
tmp_repllist$Replicator1b <- ifelse(is.na(tmp_repllist$Replicator1b), "", tmp_repllist$Replicator1b)
tmp_repllist$Replicator1c <- ifelse(is.na(tmp_repllist$Replicator1c), "", tmp_repllist$Replicator1c)
tmp_repllist$Replicator2a <- ifelse(is.na(tmp_repllist$Replicator2a), "", tmp_repllist$Replicator2a)
tmp_repllist$Replicator2b <- ifelse(is.na(tmp_repllist$Replicator2b), "", tmp_repllist$Replicator2b)
tmp_repllist$Replicator2c <- ifelse(is.na(tmp_repllist$Replicator2c), "", tmp_repllist$Replicator2c)

tmp_repllist$Replicator1 <- with(tmp_repllist, paste0(tmp_repllist$Replicator1a, tmp_repllist$Replicator1b, tmp_repllist$Replicator1c))
tmp_repllist$Replicator1 <-pmax(tmp_repllist$Replicator1a, tmp_repllist$Replicator1b,tmp_repllist$Replicator1c)
tmp_repllist$Replicator2 <- with(tmp_repllist, paste0(tmp_repllist$Replicator2a, tmp_repllist$Replicator2b, tmp_repllist$Replicator2c))
tmp_repllist$Replicator2 <-pmax(tmp_repllist$Replicator2a, tmp_repllist$Replicator2b,tmp_repllist$Replicator2c)

# Save in permanent location
saveRDS(entryQ,file=file.path(dataloc,"entryQ.Rds"))
write.csv(entryQ, file = file.path(dataloc,"entryQ.csv"))

saveRDS(exitQ,file = file.path(dataloc,"exitQ.Rds"))
write.csv(exitQ, file = file.path(dataloc,"exitQ.csv"))

saveRDS(tmp_repllist, file = file.path(dataloc,"replication_list.Rds"))
write.csv(tmp_repllist, file = file.path(dataloc,"replication_list.csv"))




