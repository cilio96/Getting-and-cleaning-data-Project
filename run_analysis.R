#importing dplyr package 
package(dplyr)

#creating folder if doesn't exist 
if(!file.exists("./data")){dir.create("./data")}

#downloading files needed
filePath <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(filePath, destfile="./data/Dataset.zip")

#unzipping file 
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#reading data
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

features <- read.table("./data/UCI HAR Dataset/features.txt")

activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

#assigning column names 
colnames(x_train) <- features_list$features
colnames(y_train) <-"activity_id"
colnames(subject_train) <- "subject_id"

colnames(x_test) <- features[,2] 
colnames(y_test) <- "activity_id"
colnames(subject_test) <- "subject_id"

colnames(activity_labels) <- c('activity_id','activity_type')

#merging the training and the test sets to create one data set.
merge_train <- cbind(subject_train, y_train, x_train)
merge_test <- cbind(subject_test, y_test, x_test)
final_set <- rbind(merge_train, merge_test)

#Extracting only the measurements on the mean and standard deviation for each measurement

colNames <- colnames(final_set)

mean_and_std <- (grepl("activity_id" , colNames) | 
                   grepl("subject_id" , colNames) | 
                   grepl("mean.." , colNames) | 
                   grepl("std.." , colNames) 
)

setForMeanAndStd <- final_set[ , mean_and_std == TRUE]

#Using descriptive activity names to name the activities in the data set
setwithActivityNames <- merge(setForMeanAndStd, activity_labels,
                              by='activity_id',
                              all.x=TRUE)

setwithActivityNames$subject_id <- as.factor(setwithActivityNames$subject_id)
setwithActivityNames$activity_id <- as.factor(setwithActivityNames$activity_id)


#Making a second tidy data set
tidy_avg <- setwithActivityNames %>%
  group_by(subject_id, activity_id) %>%
  summarise_each(funs(mean))

write.table(tidy_avg, "avgs.txt", row.name=FALSE)


