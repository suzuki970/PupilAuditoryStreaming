#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 20 12:32:21 2020

@author: yutasuzuki
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from pre_processing import pre_processing,re_sampling,getNearestValue
from band_pass_filter import lowpass_filter
from rejectBlink_PCA import rejectBlink_PCA
import json
from sklearn.decomposition import PCA
import random
import itertools
import warnings
from pixel_size import pixel2angle

def split_list(l, n):
    windowL = np.round(np.linspace(0, len(l), n+1))
    windowL = [int(windowL[i]) for i in np.arange(len(windowL))]
    for idx in np.arange(len(windowL)-1):
        yield l[windowL[idx]:windowL[idx+1]]
  
#%% ########## initial settings ###################

cfg={
'SAMPLING_RATE':1000,   
'windowL':20,
'TIME_START':-4,
'TIME_END':5,
'WID_ANALYSIS':5,
'WID_FILTER':np.array([]),
'METHOD':1, #subtraction
'FLAG_LOWPASS':False,
'THRES_DIFF':0.04,
# 'mmFlag':True,
# 'normFlag':False
'mmFlag':False,
'normFlag':True
}


saveFileLocs = 'data/'

if not cfg['mmFlag'] and not cfg['normFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_original_au.json')))    
    cfg['THRES_DIFF'] = 20
elif cfg['mmFlag'] and not cfg['normFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_original_mm.json')))
else:
    f = open(os.path.join(str(saveFileLocs + 'data_original_norm.json')))

dat = json.load(f)
f.close()

# plt.plot(np.diff(np.array(y)).T)

rejectFlag = dat['rejectFlag']

original_numOfTrial = []                      
for iSub in np.arange(1,max(dat['sub'])+1):
    ind = [i for i,sub in enumerate(dat['sub']) if sub == iSub ]
    original_numOfTrial.append(len(ind))

tmp_base = np.array(dat['RT'])
tmp_base = tmp_base.reshape(len(tmp_base),1)

cfg['WID_BASELINE'] = np.concatenate([-tmp_base-1,-tmp_base], 1)

#%%  ########## answer array move behind ###################
switch = np.array(dat['responses'].copy())
rt = np.array(dat['RT'])

for iSub in np.arange(1,max(dat['sub'])+1):
    ind = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
    tmp_switch = np.array(dat['responses'].copy())[ind]
    tmp_switch = np.r_[tmp_switch,-1]
    tmp_switch = tmp_switch[1:]
    switch[ind] = tmp_switch
    
    tmp_rt = np.array(dat['RT'].copy())[ind]
    tmp_rt = np.r_[tmp_rt,-1]
    tmp_rt = tmp_rt[1:]
    rt[ind] = tmp_rt
    
dat['responses'] = switch.copy().tolist()
dat['RT'] = rt.copy().tolist()
tmp_rejectNum = np.argwhere(switch == -1).reshape(-1)

#%% ################ artifact rejection ##########################
y,rejectNum = pre_processing(np.array(dat['PDR_baseline'].copy()),cfg)

if cfg['mmFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_original_norm.json')))
    dat_norm = json.load(f)
    f.close()
    y0,rejectNum0 = pre_processing(np.array(dat_norm['PDR_baseline'].copy()),cfg)

    rejectNum = rejectNum0

mmName = list(dat.keys())

rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
y = np.delete(y,rejectNum,axis=0)

################## PCA ##########################
# pca_x,pca_y,rejectNumPCA = rejectBlink_PCA(y)
# y = np.delete(y,rejectNumPCA,axis=0)
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNumPCA]

#%% ################# rejection of outlier ##########################
max_val = [max(abs(y[i,])) for i in np.arange(y.shape[0])]
fx = np.diff(y)
rejectOutlier = []
for i in np.arange(len(y)):
    if len(np.unique(np.round(fx[i,],5))) < 20:
        rejectOutlier.append(i)
    
    # if max(abs(y[i,])) > np.std(max_val)*3:
    #     rejectOutlier.append(i)

y = np.delete(y,rejectOutlier,axis=0)
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectOutlier]

#%% ################# blink and saccade ##########################
ind_baseline = [rt*cfg['SAMPLING_RATE'] for rt in dat['RT']]
d_bk=[]
d_sc=[]
for i,(bk,sc) in enumerate(zip(dat['Blink'],dat['Saccade'])):
    d_bk.append([bk_data for bk_data in bk if int(bk_data) < ind_baseline[i]])
    d_sc.append([float(sc_data[1]) for sc_data in sc if int(sc_data[0]) < ind_baseline[i]])

dat['numOfBlink'] = [len(e) for e in d_bk]   
dat['ampOfSaccade'] = [np.mean(e) if len(e)>0 else 0 for e in d_sc]   
dat['numOfSaccade'] = [len(e) for e in d_sc]   

del dat["gazeX"], dat["gazeY"],dat['Blink'],dat['Saccade']
mmName = list(dat.keys())

#%% ################# NAN reject ##########################
rejectNAN=[]
for mm in mmName:
    ind = np.argwhere(np.isnan(np.array(dat[mm])) == True)
    if len(ind)>0:
        rejectNAN.append(ind)        

rejectNAN = list(itertools.chain.from_iterable(rejectNAN))
rejectNAN = np.unique(rejectNAN)

if len(rejectNAN) > 0:
    y = np.delete(y,rejectNAN,axis=0)  
    for mm in mmName:
        dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNAN]

#%% ################# reject subject (N < 40%) ##########################
reject=[]
numOftrials = []
numOftrials_res = []
for iSub in np.arange(1,int(max(dat['sub']))+1):
    if rejectFlag[iSub-1]:
        reject.append(iSub)
    ind0 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['responses'])==0))
    ind1 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['responses'])==1))
    ind = np.argwhere((np.array(dat['sub'])==iSub))
    
    numOftrials.append(len(ind0)+len(ind1))
    numOftrials_res.append([len(ind0),len(ind1)])
    
    if (len(ind0)+len(ind1)) < original_numOfTrial[iSub-1] * 0.4:
        print('Subject ' + str(iSub) + ', # trial = ' + str((len(ind0)+len(ind1))) + 
              ', # original trial = ' + str(original_numOfTrial[iSub-1]))
        reject.append(iSub)
        
reject = np.unique(reject)

rejectSub = [i for i,d in enumerate(dat['sub']) if d in reject]
print('rejected subject = ' + str(reject))
y = np.delete(y,rejectSub,axis=0)  
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectSub]

original_numOfTrial = [d for i,d in enumerate(original_numOfTrial) if not i in reject]
numOftrials = [d for i,d in enumerate(numOftrials) if not i+1 in reject]
ave = np.array(original_numOfTrial)-np.array(numOftrials)
ave = 1-(np.array(numOftrials)/np.array(original_numOfTrial))

print('rejected num ave = ' + str(round(np.mean(ave),3)) + ', sd = ' + str(round(np.std(ave),3)))

#%% ################# Baseline ##########################
diam = np.array(dat['PDR'].copy())
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

dat['PDR_size'] = [np.mean(p) for p in diam.tolist()]


#%% ################ trial number ##########################
dat['numOfTrial'] = np.zeros(y.shape[0])
for iSub in np.arange(1,max(dat['sub'])+1):
      for i in np.arange(2):
          ind = np.argwhere((dat['responses'] == i) & 
                            (dat['sub'] == iSub)).reshape(-1)
          dat['numOfTrial'][ind] = np.arange(len(ind))+1

dat['numOfTrial'] = dat['numOfTrial'].tolist()

#%% ################# PCA ##########################
# ave = np.mean(y,axis=0)
# pca = PCA(n_components=4).fit(y)
# loadings = pca.components_  # Eigenvector
# var_ratio = pca.explained_variance_ratio_
# plt.figure()
# for i in np.arange(4):
#   plt.plot(x,loadings[i,],label=round(var_ratio[i],3))
# plt.legend()

#%% ################# velocity ##########################

dat['PDRder'] = re_sampling(dat['PDR'],30).tolist()
dat['PDRder'] = (np.diff(dat['PDRder'])*(30/4)).tolist()

dat['PDR_size_sorted'] = [np.mean(p) for p in diam.tolist()]
dat['PDR'] = re_sampling(y,(cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

dat['PDR_baseline'] = re_sampling(np.array(dat['PDR_baseline']),
                                  (cfg['TIME_END']-cfg['TIME_START'])*100).tolist()
mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()
        
#%% ############### data plot ##########################

import pandas as pd
df = pd.DataFrame()
df['sub'] = dat['sub']
df['PDR'] = dat['PDR_size']
df['responses'] = dat['responses']
df['taskTimeLen'] = dat['taskTimeLen']

if not cfg['mmFlag'] and cfg['normFlag']:
    path = os.path.join(saveFileLocs + "numOfSwitch_jitter.json")
    df.to_json(path)


df = df.groupby(['sub', 'responses']).mean()

from scipy import stats
print(stats.ttest_rel(df.loc[(slice(None),0), 'PDR'].values, df.loc[(slice(None),1), 'PDR'].values))

xLab = ['unswitch','switch']
numOfSub = len(np.unique(dat['sub']))

plt.figure()
for i in range(2):
    plt.plot(xLab[i], df.loc[(slice(None),i), 'PDR'].values.mean(), marker='o', markersize=5, lw=1.0, zorder=10)
    plt.errorbar(i, df.loc[(slice(None),i), 'PDR'].values.mean(), 
                  yerr = df.loc[(slice(None),i), 'PDR'].values.std()/np.sqrt(numOfSub), 
                  xerr=None, fmt="o", ms=2.0, elinewidth=1.0, ecolor='k', capsize=6.0)
plt.title('Baseline pupil size')
 
plt.figure()
for i in range(2):
    plt.plot(xLab[i], df.loc[(slice(None),i), 'taskTimeLen'].values.mean(), marker='o', markersize=5, lw=1.0, zorder=10)
    plt.errorbar(i, df.loc[(slice(None),i), 'taskTimeLen'].values.mean(), 
                  yerr = df.loc[(slice(None),i), 'taskTimeLen'].values.std()/np.sqrt(numOfSub), 
                  xerr=None, fmt="o", ms=2.0, elinewidth=1.0, ecolor='k', capsize=6.0)
plt.title('Task duration')


#%% ################# Data save ##########################
if not cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_au.json"),"w") as f:
            json.dump(dat,f)

elif cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_mm.json"),"w") as f:
            json.dump(dat,f)
else:
    with open(os.path.join(saveFileLocs + "data_norm.json"),"w") as f:
            json.dump(dat,f)
        