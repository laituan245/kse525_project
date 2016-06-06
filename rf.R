set.seed(2405)
library(randomForest)
library(Matrix)

train <- read.csv('preprocessed_data/train.csv', header = T)
test <- read.csv('preprocessed_data/test.csv', header = T)
train$ageuponoutcome <- factor(train$ageuponoutcome, levels=c(levels(train$ageuponoutcome), "22 years"))
train$year <- as.factor(train$year)
train$month <- as.factor(train$month)
test$year <- as.factor(test$year)
test$month <- as.factor(test$month)

rf1=randomForest(outcometype ~ ., data=train, importance=TRUE, ntree=500, do.trace = 5)

ypred <- predict(rf1, test, type="vote")
res <- data.frame('ID' = 1:nrow(test), ypred)
write.csv(res, 'submission.csv', quote = F, row.names = F)