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

# cfg={
#      'SAMPLING_RATE':1000,   
#      'windowL':30,
#      'TIME_START':-4,
#      'TIME_END':5,
#      'WID_ANALYSIS':5,
#      'WID_FILTER':np.array([]),
#      'METHOD':1, #subtraction
#      'FLAG_LOWPASS':True
# }
cfg={
'SAMPLING_RATE':1000,   
'windowL':20,
'TIME_START':-4,
'TIME_END':5,
'WID_ANALYSIS':5,
'WID_FILTER':np.array([]),
'METHOD':1, #subtraction
'FLAG_LOWPASS':False,
'THRES_DIFF':0.04
# 'THRES_DIFF':300
}

saveFileLocs = 'data/'

## ########## data loading ###################

# f = open(os.path.join(str( saveFileLocs +'data_original.json')))
# f = open(os.path.join(str(saveFileLocs + 'data_original_normalized.json')))
f = open(os.path.join(str(saveFileLocs + 'data_original20210405.json')))

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

# responses_zscored = []
# for iSub in np.arange(1,max(dat['sub'])+1):
#     ind = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
#     responses_zscored = np.r_[responses_zscored,
#                               sp.zscore( np.array(dat['numOfSwitch_sorted'])[ind])]
# dat['numOfSwitch_sorted'] = responses_zscored

################## data plot ##########################
plt.figure()
for i in np.arange(1,6):
    ind = np.argwhere(dat['tertile'] == i).reshape(-1)
    yy = [s for i,s in enumerate(dat['numOfSwitch_sorted']) if i in ind]
    plt.plot(i,np.mean(yy),'o')

plt.figure()
for i in np.arange(1,6):
    ind = np.argwhere(np.array(dat['tertile']) == i).reshape(-1)
    yy = [s for i,s in enumerate(dat['RT_sorted']) if i in ind]
    plt.plot(i,np.mean(yy),'o',markersize=10)
    
dat['PDR_size_sorted'] = [np.mean(p) for p in diam.tolist()]
dat['PDR_baseline'] = re_sampling(np.array(dat['PDR_baseline']),
                                  (cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()

# del dat["numOfSwitch"]
del dat['PDR']
del dat["Blink"], dat["Saccade"], dat["mSaccade"]
del dat["gazeX"], dat["gazeY"]
del dat['RT']
# del dat['PDR_baseline']

with open(os.path.join(saveFileLocs+"data_tertile20210610.json"),"w") as f:
        json.dump(dat,f)
# with open(os.path.join(saveFileLocs+"data_baseline.json"),"w") as f:
#         json.dump(dat,f)