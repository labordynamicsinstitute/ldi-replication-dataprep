# This program will anonymize the data, creating a lookup database of names, then hashing them.
# Author: Sylverie Herbert

tmp_repllist <- readRDS(file=file.path(interwrk,"repllist2.Rds"))
entryQ <- readRDS(file = file.path(interwrk,"entryQ.Rds"))
entryQ2011 <- readRDS(file = file.path(interwrk,"entryQ2011.Rds"))
exitQ <- readRDS(file = file.path(interwrk,"exitQ.Rds"))

# Compile a list of NetID, names, across the three datasets
repllistnames <- tmp_repllist %>%
  select(DOI,assessor, Replicator1 , Replicator2 ,worksheet) %>%
	filter(!(is.na(assessor) & is.na(Replicator1) & is.na(Replicator2)))

# Merge the two entry questionnaires list of NetID-DOI
entryQ2011.names <- entryQ2011 %>%
  select(DOI,NetID)

entryQ.names <- entryQ %>%
  select(DOI,NetID)

entryQnames_complete <- rbind(entryQ.names,entryQ2011.names)

# clean up possible alternate labels on exitQ
setnames(exitQ,"NetID or email","NetID",skip_absent = TRUE)

# Create data set to flag people who use alternatively name or netID in the replication list
candidates <- merge(x = repllistnames, y = entryQnames_complete, by = "DOI", all = TRUE) %>% filter(!is.na(worksheet))
write.csv(candidates, file = file.path(interwrk,"maplist_entry.csv"))

### We reviewed the list of candidates to find the mapping, and added any manual ones
### Names are mapped to NETIDs
### 
mapping_nametoID <-read.csv(file.path(confidential,"mapping_name_ID.csv")) %>% 
	select(Name,NetID) %>% mutate(Name=gsub(" $","",Name))



# Generate anonymous ID for each NETID in entry questionnaire
anonymise <- function(data, cols_to_mask, algo = "sha256")
{
	if(!require(digest)) stop("digest package is required")
	to_anon <- subset(data, select = cols_to_mask)
	unname(apply(to_anon, 1, digest, algo = algo))
}

entryQnames_list <- unique(entryQnames_complete[,c("NetID")])
entryQnames_list$ID <- anonymise(entryQnames_list, c("NetID"))



#============================================
# Rewrite the data with anonymous ID
# ===========================================
# we anonymize the original data directly, since they only contain NetIDs
entryQ$ID <- anonymise(entryQ,c("NetID"))
exitQ$ID <- anonymise(exitQ,c("NetID"))

mapping_nametoID$ID <- anonymise(mapping_nametoID,c("NetID"))


# bring in the generated ID (I verified and exit and entry only have NetID to my knowledge)
test.entryQ <- entryQ %>% 	filter(is.na(ID) & !is.na(NetID))

test.exitQ<- exitQ %>% 	filter(is.na(ID) & !is.na(NetID))

#====================================================================
# Same exercise for the replication list Replicator 1 and Replicator 2

tmp_repllist$Replicator1a <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator1,mapping_nametoID$NetID)])
tmp_repllist$Replicator1b <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator1,mapping_nametoID$Name)])
tmp_repllist$Replicator1c <- as.character(entryQnames_list$ID[match(tmp_repllist$Replicator1,entryQnames_list$NetID)])
tmp_repllist$Replicator1_anon <-pmax(tmp_repllist$Replicator1a, tmp_repllist$Replicator1b,tmp_repllist$Replicator1c,na.rm = TRUE)

tmp_repllist$Replicator2a <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator2,mapping_nametoID$NetID)])
tmp_repllist$Replicator2b <- as.character(mapping_nametoID$ID[match(tmp_repllist$Replicator2,mapping_nametoID$Name)])
tmp_repllist$Replicator2c <- as.character(entryQnames_list$ID[match(tmp_repllist$Replicator2,entryQnames_list$NetID)])
tmp_repllist$Replicator2_anon <-pmax(tmp_repllist$Replicator2a, tmp_repllist$Replicator2b,tmp_repllist$Replicator2c,na.rm = TRUE)

tmp_repllist$assessora <- as.character(mapping_nametoID$ID[match(tmp_repllist$assessor,mapping_nametoID$NetID)])
tmp_repllist$assessorb <- as.character(mapping_nametoID$ID[match(tmp_repllist$assessor,mapping_nametoID$Name)])
tmp_repllist$assessorc <- as.character(entryQnames_list$ID[match(tmp_repllist$assessor,entryQnames_list$NetID)])
tmp_repllist$assessor_anon <-pmax(tmp_repllist$assessora, tmp_repllist$assessorb,tmp_repllist$Replicator2c,na.rm = TRUE)

#######################################
# Test that there are no missed fields

test.repllist.var1 <- tmp_repllist %>% 	filter(is.na(Replicator1_anon) & !is.na(Replicator1))
test.repllist.var2 <- tmp_repllist %>% 	filter(is.na(Replicator2_anon) & !is.na(Replicator2))
test.repllist.var3 <- tmp_repllist %>% 	filter(is.na(assessor_anon) & !is.na(assessor))

# EAch test file should have zero obs
# 
nrow(test.entryQ)
nrow(test.exitQ)
nrow(test.repllist.var1)
nrow(test.repllist.var2)
nrow(test.repllist.var3)

# Remove the original and temporary variables
tmp_repllist <- tmp_repllist %>% select(-starts_with("assessor"),-starts_with("Replicator"),ends_with("_anon"))


