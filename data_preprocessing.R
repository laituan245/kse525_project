set.seed(2405)
library(lubridate)
library(stringr)

age_as_numeric <- function(age_str){
    tmp_vector <- strsplit(age_str, " ")[[1]]
    if (grepl("year", tmp_vector[2])){
        multiplier <- 365
    } else if (grepl("month", tmp_vector[2])){
        multiplier <- 30
    } else if (grepl("week", tmp_vector[2])){
        multiplier <- 7
    } else
        multiplier <- 1
    as.numeric(tmp_vector[1]) * multiplier
}

# This function returns the preprocessed version
# of the original data (training dataset or test dataset)
preprocess <- function(data){
    # Make all attribute names to be in lowercase
    names(data) <- tolower(names(data))

    # Compute the 'hasname' attributes
    data$hasname <- !is.na(data$name)

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
    data$is_mixed <- sapply(data$breed, function(x) {
        length(grep("Mix", x)) > 0
    })
    data$is_miniature <- sapply(data$breed, function(x) {
        length(grep("Miniature", x)) > 0
    })
    data$is_domestic <- sapply(data$breed, function(x) {
        length(grep("Domestic", x)) > 0
    })
    data$is_aggressive <- sapply(data$breed, function(x) {
        length(grep("Rottweiler", x)) + length(grep("Pit Bull", x)) + length(grep("Siberian Husky", x))> 0
    })
    data$breed_count <- sapply(data$breed, function(x) {
        tmp_vector <- strsplit(x, "/")[[1]]
        length(tmp_vector)
    })
    data$breed <- NULL

    # Compute color attributes
    data$color <- as.character(data$color)
    data$color_count <- sapply(data$color, function(x) {
        tmp_vector <- strsplit(x, "/")[[1]]
        length(tmp_vector)
    })
    for (i in 1:length(all_colors)) {
        data[all_colors[i]] <- sapply(data$color, function(c) {
            length(grep(all_colors[i], c)) > 0
        })
    }
    data$color <- NULL

    # Compute the 'intact' and 'sex' attribute
    data$sexuponoutcome <- as.character(data$sexuponoutcome)
    data$sex <- sapply(data$sexuponoutcome, function(x) {
        strsplit(x, " ")[[1]][2]
    })
    data$intact <- sapply(data$sexuponoutcome, function(x) {
        strsplit(x, " ")[[1]][1]
    })
    data$sexuponoutcome <- NULL
    
    # Convert the 'ageuponoutcome' attribute from categorical attribute to numeric attribute
    data$ageuponoutcome <- as.character(data$ageuponoutcome)
    data$ageuponoutcome[is.na(data$ageuponoutcome)] <- "0 days"
    data$ageuponoutcome <- sapply(data$ageuponoutcome, age_as_numeric)

    data
}

train_data <- read.csv('original_data/train.csv', header = T, na.strings = c(""))
test_data <- read.csv('original_data/test.csv', header = T, na.strings = c(""))

# Get all the different individual simple colors
tmp_colors <- c(as.character(train_data$Color), as.character(test_data$Color))
color1 <- sapply(tmp_colors, function(x) {
    strsplit(strsplit(x, "/")[[1]][1], " ")[[1]][1]
})
color2 <- sapply(tmp_colors, function(x) {
    strsplit(strsplit(x, "/")[[1]][2], " ")[[1]][1]
})
all_colors <- unique(c(color1, color2))
all_colors <- all_colors[!is.na(all_colors)]

clean_train_data <- preprocess(train_data)
clean_test_data <- preprocess(test_data)

dir.create("preprocessed_data", showWarnings = F)
write.csv(clean_train_data, "preprocessed_data/train.csv", row.names=FALSE, na="Unknown")
write.csv(clean_test_data, "preprocessed_data/test.csv", row.names=FALSE, na="Unknown")