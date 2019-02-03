# ProgrammingAssignment3:
#
#       Getting and Cleaning Data Course Project
#
# "Human Activity Recognition Using Smartphones Dataset"
#
# run_analysis.R is a R script that does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.head(
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# Writes the result of Step 5 in a file called "averages.txt"
#
#
# To run this script, place it in your working directory along with the unzipped dataset files and run 
# source("run_analysis.R")
#
# This scripts uses libraries dplyr and reshape2: remove the comments to install the related packages if not yet available in your environment
#for the features of the tidy data course
#install.packages("dplyr") #uncomment if the paxkage was not yet loaded
library(dplyr)

#to melt and dcast the data
#install.packages("reshape2") #uncomment if the paxkage was not yet loaded
library(reshape2)

#to generate the codebook
#install.packages("dataMaid") #uncomment if the paded 
library(dataMaid)

# Clear the workspace
rm(list=ls()) 

#
#
# Let's start!
#
#
# 1. Merges the training and the test sets to create one data set.
#
# Reading each data file in one corresponding data frame, loading first all test observation then appending all train observations
# As rbind keep the record ordering, the sequence of the records is preserved in each data frame
#
subject     <- read.table("test/subject_test.txt") %>% rbind(read.table("train/subject_train.txt"))
y           <- read.table("test/y_test.txt")       %>% rbind(read.table("train/y_train.txt"))
X           <- read.table("test/X_test.txt")       %>% rbind(read.table("train/X_train.txt"))

# Reading the list of the 561 measurements gi give nice names to X columns
features <- read.table("features.txt")

# Renaming the X variable names with the features names
colnames(X)<-features[,2]

# The data frame "subject" has 10299 observations of 1 variable: the subject who performed the activity for each window sample.
# The data frame "y_labels" has 10299 observations of 2 variable: head(
#                                      V1 is the id and V2 is the description of the activity performed for each window sample.
# The data frame "selected_X" has 10299 observation of 79 mean and std variables recorded by the phone sensor
#                                      tBodyAcc-mean()-Y..fBodyBodyGyroJerkMag-meanFreq()
#
# Binding the subject, activity and features together as one data frame
data<-cbind(subject=subject$V1,activity_id=y$V1,X)

#intermediary verification
#write.table(data,file="data4.txt", row.name=FALSE)


#
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#


# Identifying the columns names for the subject, the activity_id and the features that are in scope
selected_indexes<-grep("subject|activity_id|*mean()|*std()",colnames(data))

# Extracting the columns we want to keep
selected_data<-data[,selected_indexes]


#
# 3. Uses descriptive activity names to name the activities in the data set
#
# Reading the list of activity labels
activity_labels<-read.table("activity_labels.txt",col.names = c("activity_id", "activity"))

# In y and as well in ctivity_labels, the label identifiers are in the column activity_id
# The merge will therefore use activity_id as the key
merged_data<-merge(selected_data,activity_labels)


#
# 4. Appropriately labels the data set with descriptive variable names.
# colnames(

# not needed anymore, the columns names has already been named

#
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
# List the name of the measurements that are in scope
selected_features<-grep("*mean()|*std()",colnames(merged_data))

# To facilicate averaging, we want to have only one measure per record. So we melt our data frame by subject and activity:
dataMelt<-melt(merged_data,id=c("subject","activity"),measure.vars=selected_features)

# Calculating the average by subject and activity for each variable
averages<-dcast(dataMelt,subject + activity ~ variable, mean)

#
# Writes the result of Step 5 in a file called "averages.txt"
#
write.table(averages,file="averages.txt", row.name=FALSE)

# Automatically generates a code book about the averages data file
# Needed only once for documentation purpose
# makeCodebook(averages)




