set.seed(2405)
library(xgboost)
library(Matrix)

train <- read.csv('preprocessed_data/train.csv', header = T)
test <- read.csv('preprocessed_data/test.csv', header = T)
train$year <- as.factor(train$year)
train$month <- as.factor(train$month)
test$year <- as.factor(test$year)
test$month <- as.factor(test$month)

train_x <- sparse.model.matrix(outcometype~.-1, data = train)
train_y <- as.integer(train$outcometype)-1
test_x <- sparse.model.matrix(~.-1, data = test)

# parameters
param <- list("objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 5,
              "max_depth" = 6,
              "eta"=0.08,
              "subsample"=0.75,
              "colsample_bytree"=0.85,
              "gamma" = 3)

# train the model
nround = 325
bst = xgboost(data = train_x, label = train_y, param=param, nrounds = nround)
cv = xgb.cv(data = train_x, label = train_y, param=param, nrounds = nround, nfold = 5)

# doing prediction
ypred = predict(bst, test_x)
m = as.data.frame( t ( matrix(ypred, ncol = 11456, nrow = 5) ) )
colnames(m) = c("Adoption","Died","Euthanasia","Return_to_owner","Transfer")
submission = cbind(ID=1:nrow(test), m)
write.csv(submission, file="submission_xgboost.csv", row.names=FALSE, quote=FALSE)
