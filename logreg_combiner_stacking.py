import csv
import numpy as np
import random
from sklearn import linear_model
from sklearn.cross_validation import train_test_split
from sklearn.preprocessing import MultiLabelBinarizer

random.seed(245)

outcome_types = ['Adoption', 'Died', 'Euthanasia', 'Return_to_owner', 'Transfer']
data_x = []
data_y = []

# Read the predictions produced by our xgboost model on the
# preprocessed training data
with open('training_predictions_xgboost.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        data_x.append([])
        for outcome_type in outcome_types:
            data_x[-1].append(float(row[outcome_type]))


# Read the predictions produced by our random forest model
# on the preprocessed training data
idx = 0
with open('training_predictions_rf.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        for outcome_type in outcome_types:
            data_x[idx].append(float(row[outcome_type]))
        idx = idx + 1

# Read the true labels
with open('original_data/train.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        data_y.append(outcome_types.index(row['OutcomeType']))

# Split the whole data into two parts
train_x, test_x, train_y, test_y = train_test_split(data_x, data_y, test_size=0.25, random_state=42)

# Validation
logreg = linear_model.LogisticRegression(C=1e5)
logreg.fit(train_x, train_y)

preds = logreg.predict_proba(test_x)
logloss = 0.0
N = len(test_x)
for i in range(N):
    logloss = logloss - np.log(preds[i, test_y[i]])
logloss = logloss / N
print 'logloss = ' + str(logloss)

# Train with the whole dataset
logreg = linear_model.LogisticRegression(C=1e5)
logreg.fit(data_x, data_y)

# Read the predictions produced by our xgboost model on the
# preprocessed test
data_x = []
with open('submission_xgboost.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        data_x.append([])
        for outcome_type in outcome_types:
            data_x[-1].append(float(row[outcome_type]))

# Read the predictions produced by our xgboost model on the
# preprocessed test data
idx = 0
with open('submission_rf.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        for outcome_type in outcome_types:
            data_x[idx].append(float(row[outcome_type]))
        idx = idx + 1

# FINALLY, LET'S DO REAL PREDICTIONS FOR SUBMISSION
preds = logreg.predict_proba(data_x)

# MAKE THE SUBMISSION FILE
idx = 1
with open('submission_logreg_stacking.csv', 'w') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=['ID'] + outcome_types)
    writer.writeheader()
    for i in range(len(data_x)):
        row = {}
        for j in range(len(outcome_types)):
            row[outcome_types[j]] = preds[i, j]
            row['ID'] = idx
        idx = idx + 1
        writer.writerow(row)
