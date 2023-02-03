library(zip)
library(dplyr)

# Download the dataset
if (!file.exists("dataset.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","dataset.zip", mode="wb")
  unzip("dataset.zip")  
}

# Extract variable (feature) names
# This enables appropriately labelling the data set with descriptive variable names when using read.table() in the next step
varnames <- read.table('UCI HAR Dataset/features.txt', header = FALSE)[,2]

# Read and label the training data. 
xtrain <- read.table('UCI HAR Dataset/train/X_train.txt', header = FALSE, col.names = varnames)
ytrain <- read.table('UCI HAR Dataset/train/y_train.txt', header = FALSE, col.names = c("activity"))
subjtrain <- read.table('UCI HAR Dataset/train/subject_train.txt', header = FALSE, col.names = c("subject"))
# Combine training variables into one dataframe
train <- cbind(subjtrain, xtrain, ytrain)

# Read and label the test data.
xtest <- read.table('UCI HAR Dataset/test/X_test.txt', header = FALSE, col.names = varnames)
ytest <- read.table('UCI HAR Dataset/test/y_test.txt', header = FALSE, col.names = c("activity"))
subjtest <- read.table('UCI HAR Dataset/test/subject_test.txt', header = FALSE, col.names = c("subject"))
# Combine the test variables into one dataframe
test <- cbind(subjtest, xtest, ytest)

# Requirement 1: Merge the training and testing data into one set
combinedset <- rbind(train, test)

# Requirement 2: Extract only the measurements on the mean and standard deviation for each measurement.
# This regular expression will match measurement names that contain either 'mean' or 'std', 
# e.g. 'tBodyGyro.std.' or 'fBodyAcc.mean.X'
# The trailing '.' is required to exclude names containing 'meanFreq'.
meanstdnames <- grep("mean\\.|std\\.", names(combinedset), value = T)
# In addition to the reduced measurements, we still want the 'subject' and 'activity' variables in our tidy dataset
meanstdset <- combinedset[, c("subject", meanstdnames, "activity")]

# Requirement 3: Use descriptive activity names to name the activities in the data set
# Apply the activity labels to convert the activity variable from an <int> to a descriptive <factor> 
activitylbls <- read.table('UCI HAR Dataset/activity_labels.txt', header = FALSE, stringsAsFactors = FALSE)[,2]
meanstdset$activity <- factor(meanstdset$activity, levels = 1:6, labels = activitylbls)


# Requirement 4: Appropriately label the data set with descriptive variable names.
# This requirement was partially addressed by assigning column names while reading in the data.
# What remains to be done is to make the names neater. Due to the non-syntax characters in the names from 'features.txt',
# (like '-' or '(') that where replaced with '.' during reading, the varialbe names at this stage of processing 
# contain too many '.'s: e.g.: "tBodyGyroJerk.std...Z"       "tBodyAccMag.mean..". 
#
# The tidy data lecture (https://github.com/DataScienceSpecialization/courses/blob/master/03_GettingData/04_01_editingTextVariables/index.md)
# recommended variable names be 
#   All lower case when possible
#   Descriptive (Diagnosis versus Dx)
#   Not duplicated
#   Not have underscores or dots or white spaces
#
# In this case, I think that converting the names to all lowercase will reduce readability for the long names too much.
# E.g. 'fbodybodyaccjerkmagstd' is too difficult to read compared to 'fBodyBodyAccJerkMagStd'. 
# Also expanding these variables to be fully descriptive will make them too long:
# E.g. "frequencyBodyBodyAccelerationJerkMagnitudeStandarddeviation' is too difficult to read compared to 'fBodyBodyAccJerkMagStd'. 
# For the final descriptive name, I will remove the '.' and replace 'mean' with 'Mean' and 'std' with 'Std'
nms <- names(meanstdset)
nms <- sub("mean","Mean", nms)  #replace mean with Mean
nms <- sub("std","Std", nms)  #replace std with Std
nms <- gsub("\\.","", nms)  #remove all '.' characters
names(meanstdset) <- nms

# Requirement 5. From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.
# This dataset is tidy, since it:
#   Has one column for each measured variable
#   One row for each different observation (combination of activity and subject)
avgset <- meanstdset %>%
  group_by(activity, subject) %>%
  summarise_all(mean)

write.table(avgset, "avgset.txt", row.names = FALSE)
