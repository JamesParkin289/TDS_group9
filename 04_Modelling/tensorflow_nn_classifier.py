import os
import numpy as np 
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.preprocessing import normalize, OneHotEncoder
from sklearn.model_selection import train_test_split, StratifiedKFold, GridSearchCV
from sklearn.metrics import roc_auc_score, accuracy_score, confusion_matrix, precision_score, recall_score, f1_score

from tensorflow import keras
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.layers.experimental import preprocessing
from keras.models import Sequential
from keras.layers import Dense

import tensorflow_docs as tfdocs
import tensorflow_docs.modeling

# init
data_path = "/rds/general/project/hda_students_data/live/Group9/General/Data"
df10 = pd.read_csv(os.path.join(data_path, "hes_10yr_A00Z99_bin_FAMD.csv"))
work_dir = '/rds/general/user/dt20/projects/hda_students_data/live/Group9/General/david'

# edit later for main queue
max_epochs = 10000 
n_batch_size = 512
STEPS_PER_EPOCH = 10000 // 512

# train_test_split
X = df10.drop(columns = ['eid', 'triplet_id', 'Unnamed: 0'])
Y = df10["casecont"]

x_train, x_test, y_train, y_test = train_test_split(X, Y, test_size = 0.25, random_state = 289)

x_train = x_train.append(x_train[x_train["casecont"] == 1])
y_train = y_train.append(y_train[y_train == 1])

x_train = x_train.drop(labels = "casecont", axis = 1)
x_test = x_test.drop(labels = "casecont", axis = 1)

#x_train.describe().transpose()[['mean', 'std']]

normalizer = preprocessing.Normalization()

# setup learning schedule and early stopping callback  

lr_schedule = tf.keras.optimizers.schedules.InverseTimeDecay(
  0.001,
  decay_steps=STEPS_PER_EPOCH*1000,
  decay_rate=1,
  staircase=False)

def get_optimizer():
  return tf.keras.optimizers.Adam(lr_schedule)

def get_callbacks(name):
  return [
    tfdocs.modeling.EpochDots(),
    tf.keras.callbacks.EarlyStopping(monitor='binary_crossentropy', patience=200)
  ]

def build_and_compile(norm, optimizer=None):
    model = keras.Sequential([
        norm,
        layers.Dense(128, activation='relu'),
        layers.Dense(64, activation='relu'),
        layers.Dense(1, activation='sigmoid')
    ])

    if optimizer is None:
        optimizer=get_optimizer()

    model.compile(
        loss=keras.losses.BinaryCrossentropy(),
        optimizer=optimizer,
        metrics=[keras.metrics.BinaryCrossentropy(name='binary_crossentropy'),
                tf.keras.metrics.Accuracy(),
                keras.metrics.AUC(),
                keras.metrics.Precision(),
                keras.metrics.Recall()
        ]
    )

    return model

dnn_model = build_and_compile(normalizer)

history = dnn_model.fit(
    x_train, y_train,
    validation_split = 0.1,
    batch_size=n_batch_size,
    verbose=1,
    epochs=max_epochs
)

dnn_model.summary()


# eval 
y_pred = dnn_model.predict(x_test)
y_pred_classes = dnn_model.predict_classes(x_test)

# reduce to 1d array
y_pred_classes = y_pred_classes[:, 0]
 
# accuracy: (tp + tn) / (p + n)
accuracy = accuracy_score(y_test, y_pred_classes)
print('Accuracy: %f' % accuracy)
# precision tp / (tp + fp)
precision = precision_score(y_test, y_pred_classes)
print('Precision: %f' % precision)
# recall: tp / (tp + fn)
recall = recall_score(y_test, y_pred_classes)
print('Recall: %f' % recall)
# f1: 2 tp / (2 tp + fp + fn)
f1 = f1_score(y_test, y_pred_classes)
print('F1 score: %f' % f1)
# ROC AUC
auc = roc_auc_score(y_test, y_pred)
print('ROC AUC: %f' % auc)
# confusion matrix
matrix = confusion_matrix(y_test, y_pred_classes)
print(matrix)

# save predictions and models
dnn_model.save(os.path.join(work_dir, 'Output/basic_dnn'))
np.savetxt(os.path.join(work_dir, 'Output/basic_dnn/preds.csv'), y_pred, delimiter=",")
y_test.to_csv(os.path.join(work_dir, 'Output/basic_dnn/y_test.csv'), index=True)


## Loss train and val 
def plot_loss(history):
  plt.plot(history.history['loss'], label='loss')
  plt.plot(history.history['val_loss'], label='val_loss')
  plt.title('Binary Crossentropy Loss')
  plt.xlabel('Epoch')
  plt.ylabel('Error')
  plt.ylim(0, 1)
  plt.legend()
  plt.grid(True)
  plt.savefig(os.path.join(work_dir, 'Output/basic_dnn/history_bdnn.png'))

plot_loss(history)