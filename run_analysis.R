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
#install.packages("dplyr")
library(dplyr)
#install.packages("reshape2")
library(reshape2)

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

#
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
# Reading the list of the 561 measurements
features <- read.table("features.txt")

# Identifying the indexes of the features that are in scope
selected_indexes<-grep("*mean()|*std()",features$V2)
# Getting the indexed and names of the features in scope
selected_features<-features[selected_indexes,]

# Extracting the measurements that are in scope
selected_X<-X[,selected_indexes]


#
# 3. Uses descriptive activity names to name the activities in the data set
#
# Reading the list of activity labels
activity_labels<-read.table("activity_labels.txt")

# In y and as well in ctivity_labels, the label identifiers are in the column V1. The merge will therefore use V1 as the key
y_labels<-merge(y,activity_labels)


#
# 4. Appropriately labels the data set with descriptive variable names.
# 
# Renaming the selected_X variable names with the features names
colnames(selected_X)<-selected_features[,2]

# The data frame "subject" has 10299 observations of 1 variable: the subject who performed the activity for each window sample.
# The data frame "y_labels" has 10299 observations of 2 variable: 
#                                      V1 is the id and V2 is the description of the activity performed for each window sample.
# Binding the subject, activity and features together as one data frame
data<-cbind(subject=subject$V1,activity=y_labels$V2,selected_X)

#
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
# To facilicate averaging, we want to have only one measure per record. So we melt our data frame by subject and activity:
dataMelt<-melt(data,id=c("subject","activity"),measure.vars=selected_features[,2])
# Calculating the average by subject and activity for each variable
averages<-dcast(dataMelt,subject + activity ~ variable, mean)

#
# Writes the result of Step 5 in a file called "averages.txt"
#
write.table(averages,file="averages.txt", row.name=FALSE)






