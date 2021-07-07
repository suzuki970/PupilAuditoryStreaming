#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 29 16:30:53 2021

@author: yutasuzuki
"""

import numpy as np
import matplotlib.pyplot as plt
from pre_processing import pre_processing,re_sampling,getNearestValue,moving_avg
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
from zeroInterp import zeroInterp
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
'THRES_DIFF':0.04
# 'THRES_DIFF':300
}

saveFileLocs = 'data/'

## ########## data loading ###################

f = open(os.path.join(str(saveFileLocs + 'data_original20210630.json')))
dat = json.load(f)
f.close()

rejectFlag = dat['rejectFlag']

original_numOfTrial = []                      
for iSub in np.arange(1,max(dat['sub'])+1):
    ind = [i for i,sub in enumerate(dat['sub']) if sub == iSub ]
    original_numOfTrial.append(len(ind))
        
tmp_base = np.array(dat['RT'])
tmp_base = tmp_base.reshape(len(tmp_base),1)

cfg['WID_BASELINE'] = np.concatenate([-tmp_base-1,-tmp_base],1)

## ########## answer array move behind ###################
switch = np.array(dat['numOfSwitch'].copy())
rt = np.array(dat['RT'])

np.mean(np.array(dat['RT']))
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

tmp_rejectNum = np.argwhere(switch == -1).reshape(-1)

rejectNum = []
rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

mmName = list(dat.keys())
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
# y = np.delete(y,rejectNum,axis=0)

################## reject subject (N < 40%) ##########################
# reject=[]
# NUM_TRIAL = 80
# numOftrials = []
# numOftrials_res = []
# for iSub in np.arange(1,int(max(dat['sub']))+1):
#     if rejectFlag[iSub-1]:
#         reject.append(iSub)
 
#     ind0 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['numOfSwitch'])==0))
#     ind1 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['numOfSwitch'])==1))
#     ind2 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['numOfSwitch'])>1))
#     numOftrials.append(len(ind0)+len(ind1)+len(ind2))
#     numOftrials_res.append([len(ind0),len(ind1),len(ind2)])
    
#     # if min(numOftrials_res[iSub-1]) ==1:
#     #         reject.append(iSub)
#     if (len(ind0)+len(ind1)+len(ind2)) < NUM_TRIAL * 0.4:
#             reject.append(iSub)
            
# reject = np.unique(reject)

# print('# of trials = ' + str(numOftrials))

# rejectSub = [i for i,d in enumerate(dat['sub']) if d in reject]
# print('rejected subject = ' + str(reject))


dat['numOfBlink']=[]

for iTrial in dat['Blink']:
    rejectNum = []
    for i,ibk in enumerate(iTrial):
        if int(ibk[2]) > 1000 or int(ibk[2]) < 50:
            rejectNum.append(i)
            
    iTrial = [d for i,d in enumerate(iTrial) if not i in rejectNum]       
    dat['numOfBlink'].append(len(iTrial))
    
diam = np.array(dat['PDR'].copy())
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

plt.plot(diam,dat['numOfBlink'],'.')

del dat["gazeX"], dat["gazeY"], dat["Blink"]
del dat["PDR"], dat["PDR_baseline"]
del dat["Saccade"], dat['mSaccade']

with open(os.path.join(saveFileLocs + "data_blink.json"),"w") as f:
    json.dump(dat,f)

