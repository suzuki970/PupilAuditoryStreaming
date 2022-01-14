#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 24 13:19:56 2021

@author: yutasuzuki
"""

import numpy as np
import json
from asc2array import asc2array
import glob
import os
from pre_processing import pre_processing,moving_avg,re_sampling
import matplotlib.pyplot as plt
from itertools import chain
from pre_processing import moving_avg
from matplotlib import cm
from scipy.stats import pearsonr,spearmanr,kendalltau
import scipy.stats as sp
import random
import itertools
import pandas as pd

def split_list(l, n):
    windowL = np.round(np.linspace(0, len(l), n+1))
    windowL = [int(windowL[i]) for i in np.arange(len(windowL))]
    for idx in np.arange(len(windowL)-1):
        yield l[windowL[idx]:windowL[idx+1]]


saveFileLocs = '../data/'

cfg={'mmFlag':False,
     'normFlag':True
     }

################## Data load ##########################
if not cfg['mmFlag'] and not cfg['normFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_CCF_au.json')))    
    cfg['THRES_DIFF'] = 20
elif cfg['mmFlag'] and not cfg['normFlag']:
    f = open(os.path.join(str(saveFileLocs + 'data_CCF_mm.json')))
else:
    f = open(os.path.join(str(saveFileLocs + 'data_CCF_norm.json')))

# f = open(os.path.join(str(saveFileLocs + 'data_base_cross_corr.json')))
datHash = json.load(f)
f.close()

## ########## answer array move behind ###################
queue = np.array(datHash['data_x_queue'].copy())
switch = np.array(datHash['Response'].copy())

resLen = []
for iSub in np.unique(datHash['sub']):
    ind = np.argwhere(np.array(datHash['sub']) == iSub).reshape(-1)
    tmp_queue = np.array(datHash['data_x_queue'].copy())[ind]
    tmp_queue = np.r_[-1,tmp_queue]
    tmp_queue = tmp_queue[:-1]

    tmp_switch = np.array(datHash['Response'].copy())[ind]
    tmp_switch = np.r_[tmp_switch,-1]
    tmp_switch = tmp_switch[1:]
    
    switch[ind] = tmp_switch
    queue[ind] = tmp_queue
    resLen.append(len(tmp_queue)-1)
    
datHash['Response'] = switch.copy().tolist()

tmp_rejectNum = np.argwhere(switch == -1).reshape(-1)

mmName = list(datHash.keys())
del mmName[0] 
del mmName[5]

for mm in mmName:
    datHash[mm] = [d for i,d in enumerate(datHash[mm]) if not i in tmp_rejectNum]

################## reject subject (N < 40%) ##########################
reject=[]
thrTrials = 70
for iSub in np.arange(len(resLen)):
    if resLen[iSub] < thrTrials:
        reject.append(iSub+1)

reject = np.unique(reject)
rejectSub = [i for i,d in enumerate(datHash['sub']) if d in reject]

for mm in mmName:
    datHash[mm] = [d for i,d in enumerate(datHash[mm]) if not i in rejectSub]

################## Data load ##########################

data_cross_corr = {'raw':[],'block':[],
                   'raw_queue':[],'shuffle_trial':[],
                   'sub':[],'sub_block':[],
                   'randFlag_block':[],'randFlag':[]}


for iSub in np.arange(1,int(max(datHash['sub']))+1):
    
    ind = np.argwhere(datHash['sub'] == np.int64(iSub))
    y = sp.zscore(np.array(datHash["PDR"][iSub-1]))
    x_p = np.arange(len(y))/1000
    
    x = np.array(datHash["data_x"])[ind].reshape(-1)
    x = [int(t) for t in x.tolist()]
    x = np.array(x).reshape(-1)
    x = x[:min(resLen)-1]
    
    block_ind = []
    for iSession,se_ind in enumerate(datHash['start_end'][iSub-1]):
        for i in np.arange(len(x)):
            if x[i] > se_ind[0] and x[i] < se_ind[1]:
                block_ind.append(iSession)
        
    sig1 = sp.zscore(np.array(datHash["Response"])[ind]).reshape(-1)
    sig2 = y[x]
    nptsAll = len(sig1)
     
    ################## cross-corr(block shuffle,whole data) ##########################
    ccov2 = []
    for v in list(itertools.permutations([0,1,2,3],4)): 
               
        if v[0] == 3 and v[1] == 0 and v[2] == 1 and v[3] == 2:
            continue
        if v[0] == 2 and v[1] == 3 and v[2] == 0 and v[3] == 1:
            continue
        if v[0] == 1 and v[1] == 2 and v[2] == 3 and v[3] == 0:
            continue
        
        ind = []
        for i in np.arange(4):
            ind = np.r_[ind,np.argwhere(block_ind == np.int64(v[i])).reshape(-1)]
       
        ind = np.array([int(j) for j in ind.tolist()])
        
        sig1_corrected = re_sampling(sig1.reshape(1,len(sig1)),min(resLen)).reshape(-1)
        sig2_corrected = re_sampling(sig2[ind].reshape(1,len(sig2[ind])),min(resLen)).reshape(-1)
        npts = len(sig1_corrected)
    
        ccov = np.correlate(sig1_corrected, sig2_corrected, mode='full')
        ccov = ccov / (npts * sig1_corrected.std() * sig2_corrected.std())
        
        ccov2.append(ccov.tolist())
        data_cross_corr['sub'].append(int(iSub))
        if v[0] == 0 and v[1] == 1 and v[2] == 2 and v[3] == 3:
            data_cross_corr['randFlag'].append(1)
            
        else:
            data_cross_corr['randFlag'].append(0)
            
    # ccov2 = re_sampling(ccov2,min(resLen)*2).tolist()   
    data_cross_corr['raw'].extend(ccov2)
   
    ################## cross-corr(block shuffle,whole data) ##########################
    ind = np.argwhere(datHash['sub'] == iSub)
    x = np.array(datHash["data_x"])[ind].reshape(-1)
    x = [int(t) for t in x.tolist()]
    x = np.array(x).reshape(-1)
    # x = x[:-1]
    
    block_ind = []
    for iSession,se_ind in enumerate(datHash['start_end'][iSub-1]):
        for i in np.arange(len(x)):
            if x[i] > se_ind[0] and x[i] < se_ind[1]:
                block_ind.append(iSession)
    
    sig1 = sp.zscore(np.array(datHash["Response"])[ind]).reshape(-1)
    sig2 = y[x]
    nptsAll = len(sig1)
    
    ccov2 = []
    for v in list(itertools.permutations([0,1,2,3],4)): 
        
        if v[0] == 3 and v[1] == 0 and v[2] == 1 and v[3] == 2:
            continue
        if v[0] == 2 and v[1] == 3 and v[2] == 0 and v[3] == 1:
            continue
        if v[0] == 1 and v[1] == 2 and v[2] == 3 and v[3] == 0:
            continue
        
        ind = []
        for i in np.arange(4):
            ind = np.r_[ind,np.argwhere(block_ind == np.int64(v[i])).reshape(-1)]
       
        ind = np.array([int(j) for j in ind.tolist()])
        
        sig1_corrected = re_sampling(sig1.reshape(1,len(sig1)),90).reshape(-1)
        sig2_corrected = re_sampling(sig2[ind].reshape(1,len(sig2[ind])),90).reshape(-1)
        npts = len(sig1_corrected)
    
        ccov = np.correlate(sig1_corrected, sig2_corrected, mode='full')
        ccov = ccov / (npts * sig1_corrected.std() * sig2_corrected.std())
        
        ccov2.append(ccov.tolist())
            
    ccov2 = re_sampling(ccov2,181).tolist()   
    data_cross_corr['raw_queue'].extend(ccov2)
  
npts = min(resLen)
data_cross_corr['lags_trial'] = np.arange(-min(resLen),min(resLen)-1).tolist()

raw = []
shuffle = []    
raw_queue = []
shuffle_queue = []    
for i in np.arange(len(data_cross_corr['raw'])):
    
    if data_cross_corr['randFlag'][i] == 1:
        raw.append(data_cross_corr['raw'][i])
        raw_queue.append(data_cross_corr['raw_queue'][i])
    else:
        shuffle.append(data_cross_corr['raw'][i])
        shuffle_queue.append(data_cross_corr['raw_queue'][i])


y = np.array(data_cross_corr['raw'])

plt.figure(figsize=(12,12,))
y1 = []
y2 = []
for iSub in np.unique(data_cross_corr['sub']):
    plt.subplot(5,5, iSub)
    
    ind = np.argwhere((np.array(data_cross_corr['sub']) == iSub) &
                      (np.array(data_cross_corr['randFlag']) == 1)).reshape(-1)
    plt.plot(data_cross_corr['lags_trial'],y[ind,:].T,label = 'raw',alpha=0.4)
    y1.append(y[ind,:].reshape(-1))
    
    ind = np.argwhere((np.array(data_cross_corr['sub']) == iSub) &
                      (np.array(data_cross_corr['randFlag']) == 0)).reshape(-1)
    plt.plot(data_cross_corr['lags_trial'],y[ind,:].mean(axis=0).T,label = 'raw',alpha=0.4)
    plt.ylim(-0.6,0.6)
    y2.append(y[ind,:].mean(axis=0).reshape(-1))
   

plt.figure()
plt.plot(data_cross_corr['lags_trial'],np.array(y1).mean(axis=0),label = 'raw',alpha=0.4)
plt.plot(data_cross_corr['lags_trial'],np.array(y2).mean(axis=0),label = 'shuffle',alpha=0.4)
plt.legend()


npts = 180*4
data_cross_corr['lags_second'] = np.linspace(-npts, npts,181).tolist()

# with open(os.path.join(saveFileLocs + "data_cross_corr_trial.json"),"w") as f:
#         json.dump(data_cross_corr,f)
if not cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_CCF_trial_au.json"),"w") as f:
        json.dump(data_cross_corr,f)

elif cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_CCF_trial_mm.json"),"w") as f:
        json.dump(data_cross_corr,f)

else:
    with open(os.path.join(saveFileLocs + "data_CCF_trial_norm.json"),"w") as f:
        json.dump(data_cross_corr,f)
