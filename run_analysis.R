
R version 4.2.2 (2022-10-31 ucrt) -- "Innocent and Trusting"
Copyright (C) 2022 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64 (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

[Previously saved workspace restored]

> library(dplyr)

Attaching package: ‘dplyr’

The following objects are masked from ‘package:stats’:

    filter, lag

The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

> # Download data
> if (!file.exists("dataset.zip")) {
+   download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","dataset.zip", mode="wb")
+   unzip("dataset.zip")  
+ }
> 
> # Extract variable names
> variable_names <- read.table('UCI HAR Dataset/features.txt', header = FALSE)[,2]
> 
> # Training data. 
> x_training <- read.table('UCI HAR Dataset/train/X_train.txt', header = FALSE, col.names = variable_names)
> y_training <- read.table('UCI HAR Dataset/train/y_train.txt', header = FALSE, col.names = c("activity"))
> subject_training <- read.table('UCI HAR Dataset/train/subject_train.txt', header = FALSE, col.names = c("subject"))
> # training variables combined into one dataframe
> training <- cbind(subject_training, x_training, y_training)
> 
> # Test data.
> x_test <- read.table('UCI HAR Dataset/test/X_test.txt', header = FALSE, col.names = variable_names)
> y_test <- read.table('UCI HAR Dataset/test/y_test.txt', header = FALSE, col.names = c("activity"))
> subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt', header = FALSE, col.names = c("subject"))
> 
> # Test variables combined into one dataframe
> test <- cbind(subject_test, x_test, y_test)
> 
> #Step 1. Merge the training and the test sets to create one data set.
> mergedset <- rbind(training, test)
> 
> #Step 2. Extract only the measurements on the mean and standard deviation for each measurement.
> stdmeannames <- grep("mean\\.|std\\.", names(mergedset), value = T)
> stdmeanset <- mergedset[, c("subject", stdmeannames, "activity")]
> 
> #Step 3. Use descriptive activity names to name the activities in the data set
> activity_names <- read.table('UCI HAR Dataset/activity_labels.txt', header = FALSE, stringsAsFactors = FALSE)[,2]
> stdmeanset$activity <- factor(stdmeanset$activity, levels = 1:6, labels = activity_names)
> 
> #Step 4. Appropriately label the data set with descriptive variable names.
> 
> names(stdmeanset)<-gsub("Acc", "Accelerometer", names(stdmeanset))
> names(stdmeanset)<-gsub("Gyro", "Gyroscope", names(stdmeanset))
> names(stdmeanset)<-gsub("BodyBody", "Body", names(stdmeanset))
> names(stdmeanset)<-gsub("Mag", "Magnitude", names(stdmeanset))
> names(stdmeanset)<-gsub("^t", "Time", names(stdmeanset))
> names(stdmeanset)<-gsub("^f", "Frequency", names(stdmeanset))
> names(stdmeanset)<-gsub("tBody", "TimeBody", names(stdmeanset))
> names(stdmeanset)<-gsub("-mean()", "Mean", names(stdmeanset), ignore.case = TRUE)
> names(stdmeanset)<-gsub("-std()", "STD", names(stdmeanset), ignore.case = TRUE)
> names(stdmeanset)<-gsub("-freq()", "Frequency", names(stdmeanset), ignore.case = TRUE)
> names(stdmeanset)<-gsub("angle", "Angle", names(stdmeanset))
> names(stdmeanset)<-gsub("gravity", "Gravity", names(stdmeanset))
> 
> #Step 5. From the data set in step 4, creates a second, independent tidy data set with the average 
> 
> averageset <- stdmeanset %>%
+     group_by(subject, activity) %>%
+     summarise_all(funs(mean))
Warning message:
`funs()` was deprecated in dplyr 0.8.0.
ℹ Please use a list of either functions or lambdas:

# Simple named list: list(mean = mean, median = median)

# Auto named with `tibble::lst()`: tibble::lst(mean, median)

# Using lambdas list(~ mean(., trim = .2), ~ median(., na.rm = TRUE))
Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
generated. 
> 
> write.table(averageset, "averageset.txt", row.names = FALSE)
> averageset
# A tibble: 180 × 68
# Groups:   subject [30]
   subject activity    TimeB…¹ TimeBo…² TimeB…³ TimeB…⁴ TimeBo…⁵ TimeB…⁶ TimeG…⁷
     <int> <fct>         <dbl>    <dbl>   <dbl>   <dbl>    <dbl>   <dbl>   <dbl>
 1       1 WALKING       0.277 -0.0174  -0.111  -0.284   0.114   -0.260    0.935
 2       1 WALKING_UP…   0.255 -0.0240  -0.0973 -0.355  -0.00232 -0.0195   0.893
 3       1 WALKING_DO…   0.289 -0.00992 -0.108   0.0300 -0.0319  -0.230    0.932
 4       1 SITTING       0.261 -0.00131 -0.105  -0.977  -0.923   -0.940    0.832
 5       1 STANDING      0.279 -0.0161  -0.111  -0.996  -0.973   -0.980    0.943
 6       1 LAYING        0.222 -0.0405  -0.113  -0.928  -0.837   -0.826   -0.249
 7       2 WALKING       0.276 -0.0186  -0.106  -0.424  -0.0781  -0.425    0.913
 8       2 WALKING_UP…   0.247 -0.0214  -0.153  -0.304   0.108   -0.112    0.791
 9       2 WALKING_DO…   0.278 -0.0227  -0.117   0.0464  0.263   -0.103    0.862
10       2 SITTING       0.277 -0.0157  -0.109  -0.987  -0.951   -0.960    0.940
# … with 170 more rows, 59 more variables:
#   TimeGravityAccelerometer.mean...Y <dbl>,
#   TimeGravityAccelerometer.mean...Z <dbl>,
#   TimeGravityAccelerometer.std...X <dbl>,
#   TimeGravityAccelerometer.std...Y <dbl>,
#   TimeGravityAccelerometer.std...Z <dbl>,
#   TimeBodyAccelerometerJerk.mean...X <dbl>, …
# ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
> 
