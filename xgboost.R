set.seed(2405)
library(xgboost)
library(Matrix)

train <- read.csv('preprocessed_data/train.csv', header = T, colClasses = 'factor')
test <- read.csv('preprocessed_data/test.csv', header = T, colClasses = 'factor')

train_x <- sparse.model.matrix(outcometype~.-1, data = train)
train_y <- as.integer(train$outcometype)-1
test_x <- sparse.model.matrix(~.-1, data = test)

# parameters
param <- list("objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 5,
              "max_depth" = 5,
              "eta"=0.1,
              "subsample"=0.75,
              "colsample_bytree"=0.85)

# train the model
nround = 300
bst = xgboost(data = train_x, label = train_y, param=param, nrounds = nround)
cv = xgb.cv(data = train_x, label = train_y, param=param, nrounds = nround, nfold = 5)

# doing prediction
ypred = predict(bst, test_x)

# prepare the output
pred_matrix <- data.frame(matrix(ypred, ncol=5, byrow=TRUE))
colnames(pred_matrix) = levels(train$outcometype)
res<-data.frame(ID = 1:nrow(test), pred_matrix)
write.csv(res, 'submission.csv', quote = F, row.names = F)
