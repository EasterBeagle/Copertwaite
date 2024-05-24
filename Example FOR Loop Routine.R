##########################################################################
##########################################################################
####  Example FOR loop routine
####	May 17, 2016
####		Adapted took (literally) 10 min to adapt
####
##########################################################################
##########################################################################

##########################################################################
####
#####	Per email 
####		
####		date 2/24/2012
##########################################################################

#### Files needed
####  ** not neadded
####  ** UCdata 
####  ** Vdata

#### import files 
#### >>>> go to correct directory

UnitCensusData <- readRDS("UCdata")  ## change to allCensus ??
allCensus <- readRDS("All Census All Locations 2010-2015")  ##  Note, this file hasn't been cleaned!
allCensus$Census.Effective_date <- as.Date(allCensus$Census.Effective_date, format = "%m/%d/%Y")
allCensus$Admission_Date <- as.Date(allCensus$Admission_Date, format = "%m/%d/%Y")
allCensus$Discharge_Date <- as.Date(allCensus$Discharge_Date, format = "%m/%d/%Y")

IncidentData <- readRDS("Combined_2010_2015_Data still has ASH duplicates")
ViolenceData <- IncidentData[IncidentData$SubCategoryCode == "A2" | IncidentData$SubCategoryCode == "A4" | IncidentData$SubCategoryCode == "A6",]
aggressors.assault.data <- ViolenceData[ViolenceData$InvolvementType == "Aggressor",]

#### Libraries/packages
library(dplyr)
library(lubridate)


##############################################################################
####  Start working with the files
##############################################################################

####  set the working directory to where you want files to go


####  get the specific hospital and unit you will be looking at
#Atas.census <- UnitCensusData[UnitCensusData$Hospital == "DSH-Atascadero",]
Atas.census <- allCensus[allCensus$Hospital == "DSH-Atascadero",]  ##  changed from UnitCensus to allCensus -- WHY? see next line
####  The WHY! ==> allCensus has ALL LOCATIONS (not just on the unit, but "Out to Court" and "Out to Medical")
####  I need that for a more precise reading of where the patients are, otherwise it looks like going out to Court/Medical & coming back on the unit is counted as 2 admissions, when it really is just 1
nrow(Atas.census)

Atas.census.U4 <- Atas.census[Atas.census$LOCATION_UNIT == "4",]
#Atas.census.NotU4 <- Atas.census[Atas.census$LOCATION_UNIT != "U4",]
nrow(Atas.census.U4)
#Atas.census.U4.order <- Atas.census.U4[order(c(Atas.census.U4$Patient, Atas.census.U4$Census.Effective_date), decreasing=F),]
#Atas.census.U4 <- Atas.census.U4.order  ##  I order things later in the loop, not necessary here

####  get the first date the patient was on the unit, and then the last data
#### >>>> get two separate files, deduplicate, and then join together the needed info

####  get the unique list of patients, which also gives you the first day
Atas.census.U4.dedup <- Atas.census.U4[!duplicated(Atas.census.U4[c("Case_Number")]),]
Atas.census.U4.dedup.noNA <- Atas.census.U4.dedup[!is.na(Atas.census.U4.dedup$Patient),]


Atas.list <- Atas.census.U4.dedup.noNA
## Atas.list <- Atas.list[c(1:10), ]  ##  DEBUG - make it easy to test, remove later

####  Pre-populate variables of interest -- negative numbers should not occur, so if we see one, we goofed!
Atas.list$FirstDayonUnit <- -1
Atas.list$LastDayonUnit <- -1
Atas.list$maxDay <- -1
Atas.list$LastDay_Censored <- -1
Atas.list$DaysLag <- -1  ##  maybe rename to "multiple stays?"
Atas.list$Different_U4_Admits <- -1


Atas.list$PreAssaults <- -1
Atas.list$DuringAssaults <- -1
Atas.list$PostAssaults <- -1
Atas.list$DaysPre <- -1
Atas.list$DaysDuring <- -1
Atas.list$DaysPost <- -1

##############################################################################
####  get data from Violence file
##############################################################################

####
####  this will become a loop -- I'll work out the logic first
####  #### need to have two separate lists, need to have dates in correct format to pull the violence data

for (i in 1 : max(nrow(Atas.list))) {
	print(i)
	
	####  get the first day and last day on the unit -- get this from the U4 only census file
	temp.U4UnitData <- Atas.census.U4[Atas.census.U4$Case_Number == Atas.list$Case_Number[i],]
	temp.U4UnitData.ordered <- arrange(temp.U4UnitData, Census.Effective_date)
	temp.U4UnitData.ordered <- temp.U4UnitData.ordered[!is.na(temp.U4UnitData.ordered$Census.Effective_date),]
	
	Atas.list$FirstDayonUnit[i] <- temp.U4UnitData.ordered$Census.Effective_date[1]  ## get the first row's date
	maxDay <- max(nrow(temp.U4UnitData.ordered))
	Atas.list$LastDayonUnit[i] <- temp.U4UnitData.ordered$Census.Effective_date[maxDay]
	Atas.list$maxDay[i] <- maxDay
	
	####  were there multiple stays/admissions to Unit 4?
	####  this is getting complicated
	temp.U4UnitData.ordered$daysLag <- 0
	lengthLag <- length(temp.U4UnitData.ordered$daysLag)
	temp.U4UnitData.ordered$daysLag[c(2:lengthLag)] <- as.integer(diff(temp.U4UnitData.ordered$Census.Effective_date))
	temp.U4UnitData.ordered$consecutiveDays <- as.logical(ifelse(temp.U4UnitData.ordered$daysLag <= 1, "TRUE", "FALSE"))  ##  get the index where false
	##  then, get the day before...then yau have all the dates you need...need to turn the one entry into a "first" & "second", i.e, two rows
	temp.U4UnitData.ordered.summary <- summary(temp.U4UnitData.ordered$consecutiveDays)
	Atas.list$DaysLag[i] <- as.numeric(temp.U4UnitData.ordered.summary[name = "FALSE"])
	Atas.list$Different_U4_Admits[i] <- Atas.list$DaysLag[i] + 1
}

Atas.list$FirstDayonUnit <- as.Date(Atas.list$FirstDayonUnit, origin = "1970-01-01")
Atas.list$LastDayonUnit <- as.Date(Atas.list$LastDayonUnit, origin = "1970-01-01")

Atas.list$LastDay_Censored <- Atas.list$LastDayonUnit
Atas.list$LastDay_Censored[is.na(Atas.list$LastDay_Censored)] <- "2015-12-31"


for (i in 1 : max(nrow(Atas.list))) {
	print(i)	
	
	####  get assault data
	temp.AssaultData <- aggressors.assault.data[aggressors.assault.data$Case_Number == Atas.list$Case_Number[i],]
	
	assaultSummary.Pre <- summary(temp.AssaultData$Incident_Date < Atas.list$FirstDayonUnit[i])
	assaultSummary.During <- summary(temp.AssaultData$Incident_Date >= Atas.list$FirstDayonUnit[i] & 
										temp.AssaultData$Incident_Date <= Atas.list$LastDay_Censored[i])
	assaultSummary.Post <- summary(temp.AssaultData$Incident_Date > Atas.list$LastDay_Censored[i])
	
	
	Atas.list$PreAssaults[i] <- as.numeric(assaultSummary.Pre[name = "TRUE"])
	Atas.list$DuringAssaults[i] <- as.numeric(assaultSummary.During[name = "TRUE"])
	Atas.list$PostAssaults[i] <- as.numeric(assaultSummary.Post[name = "TRUE"])
	
	
	####  get LOS or days on unit data, for rates
	temp.Atas.allCensus <- Atas.census[Atas.census$Case_Number == Atas.list$Case_Number[i],]
	## >> plot their movement across the hospitals -- visually detect 2 U4 admissions
	#plot(temp.Atas.UnitCensusData$Census.Effective_date, as.character(as.factor(temp.Atas.UnitCensusData$LOCATION_UNIT)))
	## >> need to write that to a file -- like I did the hi-flyers
	
	## >> once I can get the index of the disjoint dates, I can get the discrete time periods by
	## temp.U4UnitData.ordered$Census.Effective_date[c(1,disjoint - 1, disjoint, max)]
	
	days.Pre <- summary(temp.Atas.allCensus$Census.Effective_date < Atas.list$FirstDayonUnit[i])
	days.During <- summary(temp.Atas.allCensus$Census.Effective_date >= Atas.list$FirstDayonUnit[i] & 
										temp.Atas.allCensus$Census.Effective_date <= Atas.list$LastDay_Censored[i])
	days.Post <- summary(temp.Atas.allCensus$Census.Effective_date > Atas.list$LastDay_Censored[i])
	
	Atas.list$DaysPre[i] <- as.numeric(days.Pre[name = "TRUE"])
	Atas.list$DaysDuring[i] <- as.numeric(days.During[name = "TRUE"])
	Atas.list$DaysPost[i] <- as.numeric(days.Post[name = "TRUE"])
	
}

#### finish clean-up 
Atas.list$PreAssaults[is.na(Atas.list$PreAssaults)] <- 0
Atas.list$DuringAssaults[is.na(Atas.list$DuringAssaults)] <- 0
Atas.list$PostAssaults[is.na(Atas.list$PostAssaults)] <- 0

Atas.list$DaysPre[is.na(Atas.list$DaysPre)] <- 0
Atas.list$DaysPost[is.na(Atas.list$DaysPost)] <- 0


####  figure out the rates here with dplyr and mutate
Atas.list$AssaultRatePre <- (Atas.list$PreAssaults / Atas.list$DaysPre) * 1000
Atas.list$AssaultRateDuring <- (Atas.list$DuringAssaults / Atas.list$DaysDuring) * 1000
Atas.list$AssaultRatePost <- (Atas.list$PostAssaults / Atas.list$DaysPost) * 1000

####  output to an Excel .csv file
write.table(Atas.list, "List of U4 residents and Violence Rates from ALL CENSUS to compare.csv", sep = ",", row.names=F)

####  that is full list of everybody
#### >>>> using the criteria of "admitted to ETU after 2/24/2011"
#### >>>> & also using criteria "in hospital longer than 60 days pre- and post"

Atas.list.ETU_Study <- Atas.list[Atas.list$FirstDayonUnit >= "2012-02-24" & Atas.list$DaysPre > 60 & Atas.list$DaysPost > 60,]

summary(Atas.list.ETU_Study$AssaultRatePre)
summary(Atas.list.ETU_Study$AssaultRateDuring)
summary(Atas.list.ETU_Study$AssaultRatePost)

# Atas.list.ETU_Study.ii <- Atas.list[Atas.list$FirstDayonUnit >= "2012-02-24",]  ##  ETU has treated 99 unique patients in just over 4 years
# Atas.list.ETU_Study.iii <- Atas.list[Atas.list$FirstDayonUnit >= "2012-02-24" & Atas.list$DaysPre > 60,]  ##  64 of them had LOS over 60 days pre-admit ot the ETU
# 
####
####  To plot the Unit Census by Day
####
Unit4_preplot <- allCensus %>% filter(Hospital == "DSH-Atascadero", LOCATION_UNIT == "4", Location == "Resident On Unit")  ## prep data

Unit4_forplot <- Unit4_preplot %>% group_by(Census.Effective_date) %>% summarize(Total = length(Case_Number))  ## get ready for plot
head(Unit4_forplot)

plot(Unit4_forplot, type = "line", main = "DSH Atascadero Unit 4 Census by Date\nPre- and During ETU", xlab = "Date", ylab = "Count of Patients")

