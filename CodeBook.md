The data preparation has been performed and then the required 5 steps has been followed.          


The dataset downloaded and extracted under the folder called UCI HAR Dataset.

Each data was assigned to variables
      The training data was assigned as:
             x_training 
             y_training 
             subject_training
             and bind together as training <- cbind(subject_training, x_training, y_training)
      The test data was assigned as:
            x_test 
            y_test 
            subject_test
            and bind together as test <- cbind(subject_test, x_test, y_test).
      
The training and the test sets are merged as mergedset <- rbind(training, test)
 
The measurements on the mean and standard deviation for each measurement are extracted as stdmeanset, by subsetting Merged_Data and selecting only columns.
 

The data set was labeled with descriptive variable names.

Another independent data set, averageset,  was created with the average of each variable for each activity and each subject 
by sumarizing and taking the means of each variable for each activity and each subject, after groupped by subject and activity.
The data was finally exported as averageset.txt file.
