rs_rf <- read.csv("submission_rf.csv")
rs_xgboost <- read.csv("submission_xgboost.csv")
rs_final <- (rs_rf + rs_xgboost) / 2
write.csv(rs_final, file="submission_simple_voting.csv", row.names=FALSE, quote=FALSE)
