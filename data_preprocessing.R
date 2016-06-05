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
    
    # Compute breed attributes
    data$breed <- as.character(data$breed)
    for (i in 1:length(all_breeds)) {
        data[all_breeds[i]] <- sapply(data$breed, function(c) {
            tmp_vector <- strsplit(c, "/")[[1]]
            if (tmp_vector[1] == all_breeds[i])
                TRUE
            else if (length(tmp_vector) > 1 && tmp_vector[2] == all_breeds[i])
                TRUE
            else
                FALSE
        })
    }
    data$breed <- NULL

    # Compute color attributes
    data$color <- as.character(data$color)
    for (i in 1:length(all_colors)) {
        data[all_colors[i]] <- sapply(data$color, function(c) {
            tmp_vector <- strsplit(c, "/")[[1]]
            if (tmp_vector[1] == all_colors[i])
                TRUE
            else if (length(tmp_vector) > 1 && tmp_vector[2] == all_colors[i])
                TRUE
            else
                FALSE
        })
    }
    data$color <- NULL

    data
}

train_data <- read.csv('original_data/train.csv', header = T, na.strings = c(""))
test_data <- read.csv('original_data/test.csv', header = T, na.strings = c(""))

# Get all the different individual breeds
tmp_breeds <- c(as.character(train_data$Breed), as.character(test_data$Breed))
breed1 <- sapply(tmp_breeds, function(x) {
    strsplit(x, "/")[[1]][1]
})
breed2 <- sapply(tmp_breeds, function(x) {
    strsplit(x, "/")[[1]][2]
})
all_breeds <- unique(c(breed1, breed2))
all_breeds <- all_breeds[!is.na(all_breeds)]

# Get all the different individual colors
tmp_colors <- c(as.character(train_data$Color), as.character(test_data$Color))
color1 <- sapply(tmp_colors, function(x) {
    strsplit(x, "/")[[1]][1]
})
color2 <- sapply(tmp_colors, function(x) {
    strsplit(x, "/")[[1]][2]
})
all_colors <- unique(c(color1, color2))
all_colors <- all_colors[!is.na(all_colors)]

clean_train_data <- preprocess(train_data)
clean_test_data <- preprocess(test_data)

dir.create("preprocessed_data", showWarnings = F)
write.csv(clean_train_data, "preprocessed_data/train.csv", row.names=FALSE, na="Unknown")
write.csv(clean_test_data, "preprocessed_data/test.csv", row.names=FALSE, na="Unknown")