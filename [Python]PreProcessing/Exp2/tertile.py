#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb  6 12:37:48 2021

@author: yutasuzuki
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from pre_processing import pre_processing,re_sampling,getNearestValue
from band_pass_filter import lowpass_filter
from rejectBlink_PCA import rejectBlink_PCA
import json
import os
from sklearn.decomposition import PCA
import random
import itertools
import warnings
from pixel_size import pixel2angle
import sympy as sym
import scipy.stats as sp

def split_list(l, n):
    windowL = np.round(np.linspace(0, len(l), n+1))
    windowL = [int(windowL[i]) for i in np.arange(len(windowL))]
    for idx in np.arange(len(windowL)-1):
        yield l[windowL[idx]:windowL[idx+1]]
  
## ########## initial settings ###################

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
'mmFlag':False,
'normFlag':True
# 'THRES_DIFF':0.3 
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

rejectFlag = dat['rejectFlag']

## ########## answer array move behind ###################
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
rejectNum = np.argwhere(switch == -1).reshape(-1)

mmName = list(dat.keys())

for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
    
################## Tertile ##########################
diam = np.array(dat['PDR'].copy())
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

dat['tertile'] = []
res = np.array(dat['responses'].copy())
rt = np.array(dat['RT'].copy())


for iSub in np.arange(1,max(dat['sub'])+1):
    ind_sub = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
    
    tmp_rt = rt[ind_sub].copy()
    tmp_res = res[ind_sub].copy()
    tmp_PDR = diam[ind_sub,].copy()
     
    aftSort = np.argsort(np.mean(tmp_PDR,axis=1))
    
    rt[ind_sub] = tmp_rt[aftSort].copy()    
    res[ind_sub] = tmp_res[aftSort].copy()    
    diam[ind_sub,] = tmp_PDR[aftSort,].copy()
    
    x = list(split_list(tmp_PDR.tolist(),5))
    for i,xVal in enumerate(x):
        dat['tertile'] = np.r_[dat['tertile'],np.ones(len(xVal))*(i+1)]

dat['responses_sorted'] = res.tolist()
dat['RT_sorted'] = rt.tolist()


dat['PDR_size_sorted'] = [np.mean(p) for p in diam.tolist()]
dat['PDR_baseline'] = re_sampling(np.array(dat['PDR_baseline']),
                                  (cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

theta = sym.Symbol('theta')
x = np.linspace(0,1,100)
theta_hat={'sub':[],
           'tertile':[],
           'hat':[]
           }
responses_zscored = []

for iSub in np.arange(1,max(dat['sub'])+1):
    ind = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
    responses_zscored = np.r_[responses_zscored,
                              sp.zscore( np.array(dat['responses_sorted'])[ind])]
    
dat['responses_sorted'] = responses_zscored

mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()

mmName = list(theta_hat.keys())
for mm in mmName:
    if not isinstance(theta_hat[mm],list):
        theta_hat[mm] = theta_hat[mm].tolist()
       
del dat["Blink"], dat["responses"], dat["Saccade"], dat["mSaccade"]
del dat["gazeX"], dat["gazeY"]
del dat['PDR'],dat['RT']
del dat['PDR_baseline']

################## data plot ##########################

import pandas as pd
df = pd.DataFrame()
df['sub'] = dat['sub']
df['tertile'] = dat['tertile']
df['PDR'] = dat['PDR_size_sorted']
df['responses'] = dat['responses_sorted']

df = df.groupby(['sub', 'tertile']).mean()

numOfSub = len(np.unique(dat['sub']))

plt.figure()
for i in np.arange(1,6):
    plt.plot(i, df.loc[(slice(None),i), 'responses'].values.mean(), marker='o', markersize=5, lw=1.0, zorder=10)
    plt.errorbar(i, df.loc[(slice(None),i), 'responses'].values.mean(), 
                 yerr = df.loc[(slice(None),i), 'responses'].values.std()/np.sqrt(numOfSub), 
                 xerr=None, fmt="o", ms=2.0, elinewidth=1.0, ecolor='k', capsize=6.0)
plt.title('Tertile')

if not cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_tertile_au.json"),"w") as f:
            json.dump(dat,f)

elif cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_tertile_mm.json"),"w") as f:
            json.dump(dat,f)

else:
    with open(os.path.join(saveFileLocs+"data_tertile_norm.json"),"w") as f:
            json.dump(dat,f)


# with open(os.path.join(saveFileLocs+"data_tertile20210610.json"),"w") as f:
#         json.dump(dat,f)
# with open(os.path.join(saveFileLocs+"data_tertile.json"),"w") as f:
#      json.dump(theta_hat,f)      