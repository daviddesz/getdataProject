# require reshapre2 and data.table libraries
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# load activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# load features column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# filter only the measurements on the mean and standard deviation for each measurement
extract_features <- grepl("mean|std", features)

# load X_test, y_test and subject_test data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# load activity labels
y_test[,2] = activity_labels[y_test[,1]]

names(X_test) = features
names(subject_test) = "Subject"
names(y_test) = c("ActivityID", "Activity")

# extract only the measurements on the mean and standard deviation for each measurement
X_test = X_test[,extract_features]


# combine test data by columns
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# load X_train, y_train and subject_train data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# load activity data
y_train[,2] = activity_labels[y_train[,1]]

names(X_train) = features
names(subject_train) = "Subject"
names(y_train) = c("ActivityID", "Activity")

# extract only the measurements on the mean and standard deviation for each measurement
X_train = X_train[,extract_features]


# combine train data by columns
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# combine test and train data by rows
data = rbind(test_data, train_data)

id_labels   = c("Subject", "ActivityID", "Activity")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# create a tidy data set with the average of each variable for each 
# activity and each subject
tidy_dataset   = dcast(melt_data, Subject + Activity ~ variable, mean)

# create a tidy data set as a txt file 
write.table(tidy_dataset, file = "./tidy_dataset.txt", row.name=FALSE)