#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb  6 14:58:27 2021

@author: yutasuzuki
"""

import numpy as np
import matplotlib.pyplot as plt
from pre_processing import pre_processing,re_sampling,getNearestValue
from band_pass_filter import lowpass_filter
from rejectBlink_PCA import rejectBlink_PCA
import json
import os
from pre_processing import re_sampling
import random
import itertools
import warnings
from pixel_size import pixel2angle
import itertools
import scipy.stats as sp

warnings.simplefilter('ignore')

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
'normFlag':False
# 'THRES_DIFF':300
}

saveFileLocs = 'data/'

## ########## data loading ###################
if not cfg['mmFlag'] and not cfg['normFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_original_au.json')))    
    cfg['THRES_DIFF'] = 20
elif cfg['mmFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_original_mm.json')))
else:
    f = open(os.path.join(str(saveFileLocs + 'data_original.json')))


dat = json.load(f)
f.close()

## ########## answer array move behind ###################
switch = np.array(dat['numOfSwitch'].copy())
rt = np.array(dat['RT'])

for iSub in np.arange(1,max(dat['sub'])+1):
    ind = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
    tmp_switch = np.array(dat['numOfSwitch'].copy())[ind]
    tmp_switch = np.r_[tmp_switch,-1]
    tmp_switch = tmp_switch[1:]
    switch[ind] = tmp_switch
    
    tmp_rt = np.array(dat['RT'].copy())[ind]
    tmp_rt = np.r_[tmp_rt,-1]
    tmp_rt = tmp_rt[1:]
    rt[ind] = tmp_rt
    
dat['numOfSwitch'] = switch.copy().tolist()
dat['RT'] = rt.copy().tolist()

rejectNum = np.argwhere(switch == -1).reshape(-1)

mmName = list(dat.keys())
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]

################## Tertile ##########################
diam = np.array(dat['PDR'].copy())
# diam = diam[:,-1].reshape(len(diam),1)
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

numOfSwitch = np.array(dat['numOfSwitch'].copy())
rt = np.array(dat['RT'].copy())

dat['tertile'] = []
for iSub in np.arange(1,max(dat['sub'])+1):
    ind = [i for i,s in enumerate(dat['sub']) if s == iSub]
    
    tmp_rt = rt[ind].copy()
    tmp_switch = numOfSwitch[ind].copy()
    tmp_PDR = diam[ind,].copy()
        
    aftSort = np.argsort(np.mean(tmp_PDR,axis=1))
    
    rt[ind] = tmp_rt[aftSort].copy()    
    numOfSwitch[ind] = tmp_switch[aftSort].copy()
    diam[ind,] = tmp_PDR[aftSort,].copy()
    
    x = list(split_list(np.mean(tmp_PDR,axis=1),5))
    
    for i,xVal in enumerate(x):
        dat['tertile'] = np.r_[dat['tertile'],np.ones(len(xVal))*(i+1)]
        
dat['numOfSwitch_sorted'] = numOfSwitch.tolist()
dat['RT_sorted'] = rt.tolist()

for i in np.arange(1,6):
    ind = np.argwhere(dat['tertile'] == i).reshape(-1)
    print('Total # of trials (bin:' + str(i) + ') = ' + str(len(ind)))


dat['PDR_size_sorted'] = [np.mean(p) for p in diam.tolist()]
dat['PDR_baseline'] = re_sampling(np.array(dat['PDR_baseline']),
                                  (cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()

del dat['PDR']
del dat["Blink"], dat["Saccade"], dat["mSaccade"]
del dat["gazeX"], dat["gazeY"]
del dat['RT']

################## data plot ##########################

import pandas as pd
df = pd.DataFrame()
df['sub'] = dat['sub']
df['tertile'] = dat['tertile']
df['PDR'] = dat['PDR_size_sorted']
df['numOfSwitch'] = dat['numOfSwitch_sorted']

df = df.groupby(['sub', 'tertile']).mean()

numOfSub = len(np.unique(dat['sub']))

plt.figure()
for i in np.arange(1,6):
    plt.plot(i, df.loc[(slice(None),i), 'numOfSwitch'].values.mean(), marker='o', markersize=5, lw=1.0, zorder=10)
    plt.errorbar(i, df.loc[(slice(None),i), 'numOfSwitch'].values.mean(), 
                 yerr = df.loc[(slice(None),i), 'numOfSwitch'].values.std()/np.sqrt(numOfSub), 
                 xerr=None, fmt="o", ms=2.0, elinewidth=1.0, ecolor='k', capsize=6.0)
plt.title('Tertile')

################## Data save ##########################
if not cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_tertile_au.json"),"w") as f:
            json.dump(dat,f)

elif cfg['mmFlag']:
    with open(os.path.join(saveFileLocs + "data_tertile_mm.json"),"w") as f:
            json.dump(dat,f)


# with open(os.path.join(saveFileLocs+"data_tertile.json"),"w") as f:
#         json.dump(dat,f)
