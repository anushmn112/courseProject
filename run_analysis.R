library(reshape2)

#download the zip file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./rawData.zip", method = "curl")

#unzip the downloaded file
unzip("./rawData.zip")

#read the train and test values
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
s_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
s_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#merge the data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

#read feature and activity labels
feature <- read.table("./UCI HAR Dataset/features.txt")
a_label <- read.table("./UCI HAR Dataset/activity_labels.txt")
a_label[,2] <- as.character(a_label[,2])

#extract mean and std values from feature table
selectedCols <- grep(".*mean.*|.*std.*", feature[,2])
selectedColNames <- feature[selectedCols,2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)

#merge all data and give discriptive names
x_data <- x_data[selectedCols]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("subject","activity", selectedColNames)

allData$activity <- factor(allData$activity, levels = a_label[,1], labels = a_label[,2])
allData$subject <- as.factor(allData$subject)

#create a tidy data set
meltedData <- melt(allData, id = c("subject", "activity"))
tidyData <- dcast(meltedData, subject + activity ~ variable, mean)

#write the tidy set to a new file
write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)