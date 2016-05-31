set.seed(2405)
library(lubridate)

# This function returns the preprocessed version
# of the original data (training dataset or test dataset)
preprocess <- function(data){
    # Make all attribute names to be in lowercase
    names(data) <- tolower(names(data))
    
    # Remove the 'id' and 'name' attributes
    data[[1]] <- NULL
    data[[1]] <- NULL
    
    # Remove the 'outcomesubtype' attribute (if any)
    data$outcomesubtype <- NULL
    
    # Compute the 'year', 'month', and 'isweekend' attributes
    # from the original 'datetime' attribute
    data$datetime <- as.Date(data$datetime)
    data$year <- factor(year(data$datetime))
    data$month <- factor(month(data$datetime))
    data$isweekend <- factor(wday(data$datetime) %in% c(1, 7))
    data$datetime <- NULL
    
    data
}

train_data <- read.csv('original_data/train.csv', header = T, na.strings = c(""))
test_data <- read.csv('original_data/test.csv', header = T, na.strings = c(""))

clean_train_data <- preprocess(train_data)
clean_test_data <- preprocess(test_data)

dir.create("preprocessed_data", showWarnings = F)
write.csv(clean_train_data, "preprocessed_data/train.csv", row.names=FALSE, na="Unknown")
write.csv(clean_test_data, "preprocessed_data/test.csv", row.names=FALSE, na="Unknown")