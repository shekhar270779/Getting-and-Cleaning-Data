#sets working dir
#setwd("C:/Users/Shekhar2707/Documents/Coursera/GettingandCleaningData/data/UCI HAR Dataset")


#read activity_labels file
activityLabels <- read.table("activity_labels.txt", stringsAsFactors = F)

#rename columns of activityLabels
names(activityLabels) <- c("activityid", "activityname")

#Read features.txt file 
features <- read.table("features.txt", stringsAsFactors = F)

#rename features DF 
names(features) <- c("id", "featurename")


#from test subdirectory read 3 files -
## i    x_test.txt 
## ii   y_test.txt
### iii subject_test.txt

#x_test contains values
xTest <- read.table("./test/x_test.txt", stringsAsFactors = F)

#y_test contains activityid
yTest <- read.table("./test/y_test.txt", stringsAsFactors = F)

#subject_test contains subjectid who performed activity
subTest <- read.table("./test/subject_test.txt", stringsAsFactors = F)

#combine data into TestData
TestData <- cbind(subTest, yTest, xTest )

#Rename column names of Test Data
names(TestData) <- c("subjectid", "activity", features$featurename)

#convert subjectid and activity to factors and set levels of activity factor
TestData$subjectid <- as.factor(TestData$subjectid)
TestData$activity <- as.factor(TestData$activity)
levels(TestData$activity) <- activityLabels$activityname

#from train subdirectory read 3 files -
#  x_train.txt , y_train.txt, subject_train.txt


xTrain <- read.table("./train/x_train.txt", stringsAsFactors = F)
yTrain <- read.table("./train/y_train.txt", stringsAsFactors = F)
subTrain <- read.table("./train/subject_train.txt", stringsAsFactors = F)

#combine data into TrainData
TrainData <- cbind(subTrain, yTrain, xTrain )

#Rename column names of Train Data
names(TrainData) <- c("subjectid", "activity", features$featurename)

#convert subjectid and activity  to factors and set levels of activity factor
TrainData$subjectid <- as.factor(TrainData$subjectid)
TrainData$activity <- as.factor(TrainData$activity)
levels(TrainData$activity) <- activityLabels$activityname


# Merge the training and the test sets to create one data set.
data <- rbind(TestData, TrainData)

#remove object variables which  are not needed anymore to clear memory
rm(TrainData, TestData, xTrain, yTrain, subTrain, xTest, yTest, subTest)

#Correct column names of data, remove unwanted characters

valid_column_names <- make.names(names=names(data), unique=TRUE, allow_ = TRUE)

#remove all . (dots) from colnames, and assign names to data set

names(data) <- gsub("\\.", "", valid_column_names)

#load dplyr package
suppressMessages(library(dplyr))

#convert it to tbl_df
data <- tbl_df(data)

#Extract measurement cols which contain mean and standard deviation.

subdata <- data %>%
    select(subjectid, activity, matches('mean|std'))

#for each subject, activity, find mean of all columns , display in sorted order

finaldata <-subdata %>% 
              group_by(subjectid, activity) %>% 
                summarise_each(funs(mean)) %>%
                  arrange(subjectid, activity) 

#write finaldata in a file
write.table(finaldata, "finaldata.txt", row.names = FALSE)