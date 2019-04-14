# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- rprojroot::find_rstudio_root_file()

# Main directories
dataloc <- file.path(basepath, "data","replication_data")
interwrk <- file.path(basepath, "data","interwrk")
Outputs <- file.path(basepath, "data","outputs" )
confidential <- file.path(basepath,"data","confidential")

programs <- file.path(basepath,"programs")

for ( dir in list(dataloc,interwrk,Outputs,confidential)){
	if (file.exists(dir)){
	} else {
	dir.create(file.path(dir))
	}
}

# Package lock in
MRAN.snapshot <- "2019-01-01"
options(repos = c(CRAN = paste0("https://mran.revolutionanalytics.com/snapshot/",MRAN.snapshot)))


