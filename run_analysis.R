library(zip)
library(dplyr)

# Download data
if (!file.exists("dataset.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","dataset.zip", mode="wb")
  unzip("dataset.zip")  
}

# Extract variable names
variable_names <- read.table('UCI HAR Dataset/features.txt', header = FALSE)[,2]

# Training data. 
x_training <- read.table('UCI HAR Dataset/train/X_train.txt', header = FALSE, col.names = variable_names)
y_training <- read.table('UCI HAR Dataset/train/y_train.txt', header = FALSE, col.names = c("activity"))
subject_training <- read.table('UCI HAR Dataset/train/subject_train.txt', header = FALSE, col.names = c("subject"))
# training variables combined into one dataframe
training <- cbind(subject_training, x_training, y_training)

# Test data.
x_test <- read.table('UCI HAR Dataset/test/X_test.txt', header = FALSE, col.names = variable_names)
y_test <- read.table('UCI HAR Dataset/test/y_test.txt', header = FALSE, col.names = c("activity"))
subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt', header = FALSE, col.names = c("subject"))
# Test variables combined into one dataframe
test <- cbind(subject_test, x_test, y_test)

#Step 1. Merge the training and the test sets to create one data set.
mergedset <- rbind(training, test)

#Step 2. Extract only the measurements on the mean and standard deviation for each measurement.
stdmeannames <- grep("mean\\.|std\\.", names(mergedset), value = T)
stdmeanset <- mergedset[, c("subject", stdmeannames, "activity")]


#Step 3. Use descriptive activity names to name the activities in the data set
activity_names <- read.table('UCI HAR Dataset/activity_labels.txt', header = FALSE, stringsAsFactors = FALSE)[,2]
stdmeanset$activity <- factor(stdmeanset$activity, levels = 1:6, labels = activity_names)


#Step 4. Appropriately label the data set with descriptive variable names.
names(stdmeanset)[2] = "activity"
names(stdmeanset)<-gsub("Acc", "Accelerometer", names(stdmeanset))
names(stdmeanset)<-gsub("Gyro", "Gyroscope", names(stdmeanset))
names(stdmeanset)<-gsub("BodyBody", "Body", names(stdmeanset))
names(stdmeanset)<-gsub("Mag", "Magnitude", names(stdmeanset))
names(stdmeanset)<-gsub("^t", "Time", names(stdmeanset))
names(stdmeanset)<-gsub("^f", "Frequency", names(stdmeanset))
names(stdmeanset)<-gsub("tBody", "TimeBody", names(stdmeanset))
names(stdmeanset)<-gsub("-mean()", "Mean", names(stdmeanset), ignore.case = TRUE)
names(stdmeanset)<-gsub("-std()", "STD", names(stdmeanset), ignore.case = TRUE)
names(stdmeanset)<-gsub("-freq()", "Frequency", names(stdmeanset), ignore.case = TRUE)
names(stdmeanset)<-gsub("angle", "Angle", names(stdmeanset))
names(stdmeanset)<-gsub("gravity", "Gravity", names(stdmeanset))

#Step 5. From the data set in step 4, creates a second, independent tidy data set with the average 

averageset <- stdmeanset %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))
    
write.table(averageset, "averageset.txt", row.names = FALSE)
