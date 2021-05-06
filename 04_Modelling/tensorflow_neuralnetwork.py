import os
import numpy as np 
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime

from imblearn.over_sampling import SMOTE
from sklearn.impute import SimpleImputer
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, accuracy_score, \
					confusion_matrix, precision_score, recall_score,  \
					f1_score, roc_curve, auc

from tensorflow import keras
import tensorflow as tf
from tensorflow.keras import layers, regularizers
from tensorflow.keras.backend import clear_session
from keras.models import Sequential
from keras.layers import Dense


# time checkpoint
startTime = datetime.now()
print("Init time: ", startTime)


# init
data_path = "/rds/general/project/hda_students_data/live/Group9/General/david/Data"
work_dir = '/rds/general/user/dt20/projects/hda_students_data/live/Group9/General/david'

df10Colnames = pd.read_csv(os.path.join(work_dir, "Data/hes_10yr_A00Z99_bin.csv"), nrows=0).columns
loadcols = df10Colnames[0:1].append(df10Colnames[5::]).append(df10Colnames[3:4]) #drops age,sex, triplet_id, casecont 
booleans = {name:'float32' for name in df10Colnames[5::]}

df10 = pd.read_csv(os.path.join(work_dir, "Data/hes_10yr_A00Z99_bin.csv"),
									usecols=loadcols, header=0, dtype=booleans)

ukbcols = pd.read_csv(os.path.join(work_dir, "Data/working_dataset_notext.csv"), nrows=0).columns
loadcolsukb = ukbcols[1:-2] #drops melanoma incidence date and index

dfuk = pd.read_csv(os.path.join(work_dir, "Data/working_dataset_notext.csv"),
									usecols=loadcolsukb, header=0)

# merge hes with working dataset 
df_full = pd.merge(dfuk, df10, on='eid', how='left')
print(len(df_full) == len(dfuk)) #make sure no extra rows added

# remember to drop offending cols (data leakage)
# eid, operation, age at cancer diagnosis, self reported cancers
df_full.drop(columns=['eid', 'X40019.0.0', 'X134.0.0', \
				'X20004.0.0', 'X40009.0.0.y', 'X40008.0.0.y'], inplace=True)

# drop columns which are objects and >= 40% missing values
df_full = df_full.select_dtypes(exclude=['object'])          
limitPer = len(df_full) * .40
df_full = df_full.dropna(thresh=limitPer, axis=1)

# train_test_split
X = df_full
Y = df_full["casecont"]
x_train, x_test, y_train, y_test = train_test_split(X, Y, test_size = 0.25, random_state = 289)
x_train = x_train.drop(labels = "casecont", axis = 1)
x_test = x_test.drop(labels = "casecont", axis = 1)

y_train.fillna(value=0, inplace=True)
y_test.fillna(value=0, inplace=True)

print("Initial test_train_split 0.25 and info about test_set:")
print("Number and prop(%) of cases   : ", (y_train == 1).sum(), 
			", % =", round((y_train == 1).sum()/len(y_train), 3))
print("Number and prop(%) of controls: ", (y_train == 0).sum(), 
			", % =", round((y_train == 0).sum()/len(y_train), 3))

# do mode imputation based on trainset, and transform test set
imputer = SimpleImputer(missing_values=np.nan, strategy='mean')
imputer.fit(x_train)

x_train = imputer.transform(x_train)
x_test = imputer.transform(x_test) # avoid data leakage

# SMOTE instead of duplicating
sm = SMOTE(sampling_strategy=0.85, random_state = 777)
x_train, y_train = sm.fit_resample(x_train, y_train)

print("Performing SMOTE on test_set:")
print("Number and prop(%) of cases   : ", (y_train == 1).sum(), 
			", % =", round((y_train == 1).sum()/len(y_train), 3))
print("Number and prop(%) of controls: ", (y_train == 0).sum(), 
			", % =", round((y_train == 0).sum()/len(y_train), 3))

print("x_train dims: ", x_train.shape)
print("x_test dims : ", x_test.shape, "\n")

# check for NAs which could cause problems for keras
if np.isnan(x_train).any() == True:
	print("Missing values in dataframe")
	print("Number missing: ", np.isnan(x_train).sum())
	print(df_full.loc[:, x_train.isnull().any()].columns)  
	x_train.to_csv(os.path.join(work_dir, 'scripts/joboutputs/x_train_missing.csv'), index=False)

# np.savetxt(os.path.join(work_dir, 'Output/xtrain.csv'), x_train, delimiter=",")

## Neural Net Section and Settings ##
# training hyperparameters for NN
MAX_EPOCHS = 300
N_BATCH_SIZE = 32
STEPS_PER_EPOCH = len(x_train) // N_BATCH_SIZE
LEARNING_RATE = 0.001

# models to test
model_01_bn2hl2 = keras.Sequential([
		layers.BatchNormalization(input_shape=(x_train.shape[1],)),		
		layers.Dense(48, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(8, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(1, activation='sigmoid')
])

model_02_1hbnl2 = keras.Sequential([
		layers.Dense(x_train.shape[1], activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.BatchNormalization(),		
		layers.Dense(32, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.BatchNormalization(),
		layers.Dense(1, activation='sigmoid')
])

model_03_bn1hl2 = keras.Sequential([
		layers.BatchNormalization(input_shape=(x_train.shape[1],)),		
		layers.Dense(32, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(1, activation='sigmoid')
])

model_04_bn1hl2 = keras.Sequential([
		layers.BatchNormalization(input_shape=(x_train.shape[1],)),		
		layers.Dense(24, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(1, activation='sigmoid')
])

model_05_bn2hl2 = keras.Sequential([
		layers.BatchNormalization(input_shape=(x_train.shape[1],)),		
		layers.Dense(24, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(4, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(1, activation='sigmoid')
])

model_06_bn2hl2 = keras.Sequential([
		layers.BatchNormalization(input_shape=(x_train.shape[1],)),		
		layers.Dense(16, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(8, activation='relu', kernel_regularizer=regularizers.l2(0.05)),
		layers.Dense(1, activation='sigmoid')
])

model_07_bn1hdo = keras.Sequential([
		layers.BatchNormalization(input_shape=(x_train.shape[1],)),	
		layers.Dropout(0.8),
		layers.Dense(32, activation='relu'),
		layers.Dropout(0.65),
		layers.Dense(1, activation='sigmoid')
])

model_08_1hbndo = keras.Sequential([
		layers.Dense(x_train.shape[1], activation='relu'),
		layers.BatchNormalization(),	
		layers.Dropout(0.9),
		layers.Dense(16, activation='relu'),
		layers.BatchNormalization(),	
		layers.Dropout(0.8),
		layers.Dense(1, activation='sigmoid')
])


model_names = [model_01_bn2hl2, model_02_1hbnl2, model_03_bn1hl2, model_04_bn1hl2, \
				model_05_bn2hl2, model_06_bn2hl2, model_07_bn1hdo, model_08_1hbndo]
model_paths = ['model_01_bn2hl2', 'model_02_1hbnl2', 'model_03_bn1hl2', 'model_04_bn1hl2', \
				'model_05_bn2hl2', 'model_06_bn2hl2', 'model_07_bn1hdo', 'model_08_1hbndo']

# early stopping callback  
early_stopping = tf.keras.callbacks.EarlyStopping(
						monitor='val_loss',
						mode='min', patience=15,
						min_delta=0.005) 


## pipeline of model compile > train > eval > plotting
def get_optimizer():
	return tf.keras.optimizers.SGD(lr=LEARNING_RATE) 

def build_and_compile(model, optimizer=None):

		if optimizer is None:
				optimizer=get_optimizer()

		model.compile(
				loss=keras.losses.BinaryCrossentropy(),
				optimizer=optimizer,
				metrics=[tf.keras.metrics.Accuracy(),
						keras.metrics.AUC(),
						keras.metrics.Precision(),
						keras.metrics.Recall()
				]
		)

		return model

def train_model(model):
	
	dnn_model = build_and_compile(model)

	history = dnn_model.fit(
			x_train, y_train,
			validation_split = 0.15,
			batch_size=N_BATCH_SIZE,
			verbose=2,
			epochs=MAX_EPOCHS,
			callbacks=[early_stopping]
	)

	dnn_model.summary()
	
	return history, dnn_model

def evaluation_plotting(history, model, save_path):

	y_pred = model.predict(x_test)
	y_pred_classes = (model.predict(x_test) > 0.5).astype("int32")

	accuracy = accuracy_score(y_test, y_pred_classes)
	precision = precision_score(y_test, y_pred_classes)
	recall = recall_score(y_test, y_pred_classes)
	f1 = f1_score(y_test, y_pred_classes)
	auc = roc_auc_score(y_test, y_pred)
	matrix = confusion_matrix(y_test, y_pred_classes)

	print('Accuracy: %f' % accuracy)
	print('Precision: %f' % precision)
	print('Recall: %f' % recall)
	print('F1 score: %f' % f1)
	print('ROC AUC: %f' % auc)
	print(matrix)

	history_df = pd.DataFrame(history.history)
	history_df.to_csv(os.path.join(work_dir, 'Output/noleak2', save_path, \
				"{}_history.csv".format(save_path)), index=False)
	model.save(os.path.join(work_dir, 'Output/noleak2', save_path))
	np.savetxt(os.path.join(work_dir, 'Output/noleak2', save_path, \
				"{}_ypred.csv".format(save_path)), y_pred, delimiter=",")
	y_test.to_csv(os.path.join(work_dir, 'Output/noleak2', save_path, \
				"{}_ytest.csv".format(save_path)), index=True)

	# plot loss, accuracy and roc curves
	plot_loss(history, save_path)
	plot_accuracy(history, save_path)
	plot_roc(history, y_pred, save_path)

	return y_pred

## Loss train and val 
def plot_loss(history, save_path):
	plt.plot(history.history['loss'], label='loss')
	plt.plot(history.history['val_loss'], label='val_loss')
	plt.title('Binary Crossentropy Loss')
	plt.xlabel('Epoch')
	plt.ylabel('Error')
	plt.legend(['train', 'val'], loc='best')
	plt.grid(True)
	plt.savefig(os.path.join(work_dir, 'Output/noleak2', save_path, "{}_loss.png".format(save_path)))
	plt.close()

def plot_accuracy(history, save_path):
	plt.plot(history.history['accuracy'])
	plt.plot(history.history['val_accuracy'])
	plt.title('Accuracy Over Epochs')
	plt.xlabel('Epoch')
	plt.ylabel('Accuracy')
	plt.legend(['train', 'val'], loc='best')
	plt.grid(True)
	plt.savefig(os.path.join(work_dir, 'Output/noleak2', save_path, "{}_accuracy.png".format(save_path)))
	plt.close()

def plot_roc(history, y_pred, save_path):

	fpr, tpr, thresholds = roc_curve(y_test, y_pred)
	auc_keras = auc(fpr, tpr)

	plt.plot([0, 1], [0, 1], 'k--')
	plt.plot(fpr, tpr, label='Keras (area = {:.3f})'.format(auc_keras))

	plt.xlabel('False positive rate')
	plt.ylabel('True positive rate')
	plt.title('ROC curve')
	plt.savefig(os.path.join(work_dir, 'Output/noleak2', save_path, "{}_roc.png".format(save_path)))
	plt.close()

## run functions in for loop : train 4 models at once ##

for n in range(len(model_names)):
	print(n, " - Training model {}: ".format(model_paths[n]), datetime.now())
	tempTime = datetime.now()

	history, model = train_model(model_names[n])
	y_pred_l2 = evaluation_plotting(history, model, model_paths[n])

	print("Duration of {} model training: ".format(model_names[n]), datetime.now() - tempTime)
	clear_session() 


print("Experiment ended: ", datetime.now() - startTime)