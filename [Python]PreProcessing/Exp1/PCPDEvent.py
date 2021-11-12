#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr  8 10:31:41 2021

@author: yutasuzuki
"""

import os
import numpy as np
import matplotlib.pyplot as plt
from pre_processing import pre_processing,re_sampling,getNearestValue,moving_avg
from band_pass_filter import lowpass_filter
from rejectBlink_PCA import rejectBlink_PCA
import json
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
  
#%%# ########## initial settings ###################

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
}

saveFileLocs = './data/'

#%%# ########## data loading ###################
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

original_numOfTrial = []                      
for iSub in np.arange(1,max(dat['sub'])+1):
    ind = [i for i,sub in enumerate(dat['sub']) if sub == iSub ]
    original_numOfTrial.append(len(ind))
        
tmp_base = np.array(dat['RT'])
tmp_base = tmp_base.reshape(len(tmp_base),1)

cfg['WID_BASELINE'] = np.concatenate([-tmp_base-1,-tmp_base],1)

#%%# ########## block index ###################
block_ind = []
for iSub in np.unique(dat['sub']):
    
    ind = np.argwhere(dat['sub'] == np.int64(iSub)).reshape(-1)
    x = np.array(dat["data_x"])[ind].reshape(-1)
    x = [int(t) for t in x.tolist()]
    x = np.array(x).reshape(-1)
    
    for iSession,se_ind in enumerate(dat['start_end'][np.int64(iSub-1)]):
        for i in np.arange(len(x)):
            if x[i] > se_ind[0] and x[i] < se_ind[1]:
                block_ind.append(iSession)
dat['block_ind'] = block_ind
    
#%%# ########## answer array move behind ###################
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

tmp_rejectNum = np.argwhere(switch == -1).reshape(-1)

#%%# ##########artifact rejection ##########################

y,rejectNum = pre_processing(np.array(dat['PDR_baseline'].copy()),cfg)

rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

mmName = list(dat.keys())
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
y = np.delete(y,rejectNum,axis=0)

#%%# ##########Outlier ##########################

max_val = [max(abs(y[i,])) for i in np.arange(y.shape[0])]
fx = np.diff(y)
rejectOutlier = []
for i in np.arange(len(y)):
    if len(np.unique(np.round(fx[i,],5))) < 20:
        rejectOutlier.append(i)
    # if max(abs(y[i,])) > np.std(max_val)*3:
    #     rejectOutlier.append(i)

for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectOutlier]

y = np.delete(y,rejectOutlier,axis=0)

#%%# ##########reject subject (N < 40%) ##########################

reject=[]
NUM_TRIAL = 80
numOftrials = []
numOftrials_res = []
for iSub in np.arange(1,int(max(dat['sub']))+1):
    if rejectFlag[iSub-1]:
        reject.append(iSub)
 
    ind0 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['numOfSwitch'])==0))
    ind1 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['numOfSwitch'])==1))
    ind2 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['numOfSwitch'])>1))
    numOftrials.append(len(ind0)+len(ind1)+len(ind2))
    numOftrials_res.append([len(ind0),len(ind1),len(ind2)])
    
    if (len(ind0)+len(ind1)+len(ind2)) < NUM_TRIAL * 0.4:
            reject.append(iSub)
            
reject = np.unique(reject)

print('# of trials = ' + str(numOftrials))

rejectSub = [i for i,d in enumerate(dat['sub']) if d in reject]
print('rejected subject = ' + str(reject))
y = np.delete(y,rejectSub,axis=0)  
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectSub]
ave = 1-(np.array(numOftrials)/np.array(original_numOfTrial))
print('rejected num ave = ' + str(round(np.mean(ave),3)) + ', sd = ' + str(round(np.std(ave),3)))

#%% ############## PC/PD  ###################################
test_y = moving_avg(y.copy(),1000)
fs = 1000
# test_y = re_sampling(test_y,fs)

events = {'indices':[],'event':[]}
for iTrial in np.arange(test_y.shape[0]):
    
    pv = np.gradient(test_y[iTrial,:])
    indices = np.where(np.diff(np.sign(pv)))[0]
    
    # xv = np.r_[0,np.diff(indices)]
    xv = np.gradient(indices)
    
    indices = indices[xv > 300] # < 300ms
    
    events['indices'].append(indices.tolist())
    
    ev = []
    for itr in np.arange(len(indices)):
        if pv[indices[itr]] - pv[indices[itr]+1] > 0:
            ev.append(1)
        else:
            ev.append(0)
    events['event'].append(ev)

    if iTrial == 3:  
        plt.plot(pv*fs)
        plt.plot(test_y[iTrial])
        plt.plot(events['indices'][iTrial],test_y[iTrial][events['indices'][iTrial]],'ro')    
        plt.ylim([-1,1])
        
events['sub'] = dat['sub']
events['numOfSwitch'] = dat['numOfSwitch']
events['block_ind'] = dat['block_ind']

for varName in ['dilation','constriction','dilation_time','constriction_time','dilation_time_each','constriction_time_each']:
    events[varName] = []

# for varName in ['dilation_time_bef','constriction_time_bef']:
#     for t in ['2s_0s','1s_0s','2s_1s']:
#         events[varName+t] = []
       
for indSwitch in np.arange(3):
    for iSub in np.unique(events['sub']):
        
        if indSwitch == 2:
            ind = np.argwhere((np.array(events['numOfSwitch']) > 1) &
                              (np.array(events['sub']) == iSub)).reshape(-1).tolist()        
        else:
            ind = np.argwhere((np.array(events['numOfSwitch']) == np.int64(indSwitch)) &
                              (np.array(events['sub']) == iSub)).reshape(-1).tolist()
            
        rateD = np.zeros((len(ind),test_y.shape[1]))
        rateC = np.zeros((len(ind),test_y.shape[1]))
        
        for i,numSwitch in enumerate(ind):
            for ev,indices in zip(events['event'][numSwitch],events['indices'][numSwitch]):
                if ev == 1:
                    # plt.plot(indices,i,'ro',markersize=1,alpha=0.5)
                    rateD[i,indices] = 1
                else:
                    # plt.plot(indices,i,'ko',markersize=1,alpha=0.5)
                    rateC[i,indices] = 1
        
        events['dilation'].append(rateD.mean(axis=0).tolist())         
        events['constriction'].append(rateC.mean(axis=0).tolist())     
                   
for ev,indices in zip(events['event'],events['indices']):
    rateD = np.zeros(test_y.shape[1])
    rateC = np.zeros(test_y.shape[1])
    for e,i in zip(ev,indices):
        if e == 1:
            # plt.plot(indices,i,'ro',markersize=1,alpha=0.5)
            rateD[i] = 1
        else:
            # plt.plot(indices,i,'ko',markersize=1,alpha=0.5)
            rateC[i] = 1
            
    tmp = rateD[4000:-1000].sum()
    events['dilation_time'].append(tmp)
    
    tmp = rateC[4000:-1000].sum()
    events['constriction_time'].append(tmp)
 
    
    # tmp = rateD[2000:4000].sum()
    # events['dilation_time_bef2s_0s'].append(tmp)
    # tmp = rateD[3000:4000].sum()
    # events['dilation_time_bef1s_0s'].append(tmp)
    # tmp = rateD[2000:3000].sum()
    # events['dilation_time_bef2s_1s'].append(tmp)
   
    # tmp = rateC[2000:4000].sum()
    # events['constriction_time_bef2s_0s'].append(tmp)
    # tmp = rateC[3000:4000].sum()
    # events['constriction_time_bef1s_0s'].append(tmp)
    # tmp = rateC[2000:3000].sum()
    # events['constriction_time_bef2s_1s'].append(tmp)
        
    tmpD = []
    tmpC = []
    for iTime in np.arange(0,9000,1000):
        tmpD.append(rateD[iTime:iTime+1000].sum())
        tmpC.append(rateC[iTime:iTime+1000].sum())

    events['dilation_time_each'].append(tmpD)
    events['constriction_time_each'].append(tmpC)
    
    
events["numOfSwitch_norm"] = np.float32(np.array(events["numOfSwitch"]))
for iSub in np.unique(events['sub']):
    ind = np.argwhere(np.array(events["sub"] == iSub)).reshape(-1)
    events["numOfSwitch_norm"][ind] = sp.zscore(np.array(events["numOfSwitch"])[ind])
    
events["numOfSwitch_norm"] = events["numOfSwitch_norm"].tolist() 
        
# events['dilation'] = moving_avg(np.array(events['dilation']),500).tolist()
# events['constriction'] = moving_avg(np.array(events['constriction']),500).tolist()
    
# events['dilation'] = re_sampling(events['dilation'],90).tolist()
# events['constriction'] = re_sampling(events['constriction'],90).tolist()

#%%# ##########trial number ##########################
events['numOfTrial'] = np.zeros(y.shape[0])
currentNum = 0
for indSwitch in np.arange(3):
    if indSwitch == 2:
        ind = np.argwhere((np.array(events['numOfSwitch']) > 1)).reshape(-1)
    else:
        ind = np.argwhere((np.array(events['numOfSwitch']) == indSwitch)).reshape(-1)

    events['numOfTrial'][ind] = np.arange(len(ind))+1+currentNum
    currentNum = currentNum + len(ind)+1

events['numOfTrial'] = events['numOfTrial'].tolist()

# %% ##%%# ##########Baseline pupil size #################################
diam = np.array(dat['PDR'].copy())
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)
events['Baseline'] = diam.tolist()

#%%# ########## answer array move behind ###################
bp = np.array(events['Baseline'].copy()).reshape(-1)

for iSub in np.unique(events['sub']):
    ind = np.argwhere(np.array(events['sub']) == iSub).reshape(-1)
    tmp_bp = np.array(events['Baseline'].copy())[ind].reshape(-1)
    tmp_bp = np.r_[-100,tmp_bp]
    tmp_bp = tmp_bp[:-1]
    bp[ind] = tmp_bp

events['Baseline_aft'] = bp.copy().tolist()
tmp_rejectNum = np.argwhere(bp == -100).reshape(-1)

mmName = list(events.keys())
for mm in mmName:
    events[mm] = [d for i,d in enumerate(events[mm]) if not i in tmp_rejectNum]

#%%# ##########Data save ##########################
if not cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "PDPCevents_au.json"),"w") as f:
            json.dump(events,f)

elif cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "PDPCevents_mm.json"),"w") as f:
            json.dump(events,f)
else:           
    with open(os.path.join(saveFileLocs + "PDPCevents_norm.json"),"w") as f:
            json.dump(events,f)
            
   
#%%# ########## plot #################################    
numOfSub = len(np.unique(events['sub']))
  
plt.figure(figsize=(6,8))
y = np.array(events['dilation_time'])

for i in np.arange(3):
    if i==2:
        ind = np.argwhere(np.array(events['numOfSwitch']) > 1)
    else:
        ind = np.argwhere(np.array(events['numOfSwitch']) == i)
        
    plt.plot(i,y[ind].mean(axis=0),'o',linewidth=1,alpha=0.5)

#%%# ########## CCF #################################    

# plt.figure(figsize=(6,8))
# tmp = []
# for iSub in np.unique(events['sub']):
    
#     sig1 = sp.zscore(np.array(events["dilation_time"])[np.array(events['sub'])==iSub]).reshape(-1)  
#     # sig2 = sp.zscore(np.array(events["Baseline"])[np.array(events['sub'])==iSub]).reshape(-1)
#     sig2 = np.array(events["Baseline_aft"])[np.array(events['sub'])==iSub].reshape(-1)
#     # sig2 = sp.zscore(np.array(events["numOfSwitch"])[np.array(events['sub'])==iSub]).reshape(-1)
    
#     sig1_corrected = re_sampling(sig1.reshape(1,len(sig1)),80).reshape(-1)
#     sig2_corrected = re_sampling(sig2.reshape(1,len(sig2)),80).reshape(-1)
  
#     npts = len(sig1_corrected)
    
#     ccov = np.correlate(sig1_corrected, sig2_corrected, mode='full')
#     ccov = ccov / (npts * sig1_corrected.std() * sig2_corrected.std())

#     tmp.append(ccov)

# plt.plot(np.array(tmp).mean(axis=0))

# resLen=80
# data_cross_corr = {'raw':[],'raw_queue':[],'randFlag':[],
#                    'shuffle_trial':[],'sub':[]
#                    }
# plt.figure(figsize=(12,12,))

# for iSub in np.unique(events['sub']):
   
#     sig1 = sp.zscore(np.array(events["dilation_time"])[np.array(events['sub'])==iSub]).reshape(-1)  
#     # sig1 = np.array(events["dilation_time"])[np.array(events['sub'])==iSub].reshape(-1)  
#     sig2 = np.array(events["Baseline"])[np.array(events['sub'])==iSub].reshape(-1)
    
#     nptsAll = len(sig1)
    
#     ################## cross-corr(block shuffle,whole data) ##########################
#     ccov2 = []
#     for v in list(itertools.permutations([0,1,2,3],4)): 
               
#         if v[0] == 3 and v[1] == 0 and v[2] == 1 and v[3] == 2:
#             continue
#         if v[0] == 2 and v[1] == 3 and v[2] == 0 and v[3] == 1:
#             continue
#         if v[0] == 1 and v[1] == 2 and v[2] == 3 and v[3] == 0:
#             continue
        
#         block_ind = np.array(events["block_ind"])[np.array(events['sub'])==iSub].reshape(-1)
#         ind = []
#         for i in np.arange(4):
#             ind = np.r_[ind,np.argwhere(block_ind == np.int64(v[i])).reshape(-1)]
       
#         ind = np.array([int(j) for j in ind.tolist()])
        
#         sig1_corrected = re_sampling(sig1[ind].reshape(1,len(sig1)),resLen).reshape(-1)
#         sig2_corrected = re_sampling(sig2.reshape(1,len(sig2)),resLen).reshape(-1)
#         npts = len(sig1_corrected)
    
#         ccov = np.correlate(sig1_corrected, sig2_corrected, mode='full')
#         ccov = ccov / (npts * sig1_corrected.std() * sig2_corrected.std())
        
#         ccov2.append(ccov.tolist())
#         data_cross_corr['sub'].append(int(iSub))
        
#         if v[0] == 0 and v[1] == 1 and v[2] == 2 and v[3] == 3:
#             data_cross_corr['randFlag'].append(1)
#             plt.subplot(5,5, iSub)
#             plt.plot(sig1,sig2,'o')
#         else:
#             data_cross_corr['randFlag'].append(0)
            
#     data_cross_corr['raw'].extend(ccov2)
    

# data_cross_corr['lags_trial'] = np.arange(-resLen,resLen-1).tolist()
# y = np.array(data_cross_corr['raw'])

# plt.figure(figsize=(12,12,))

# y1 = []
# y2 = []
# for iSub in np.unique(data_cross_corr['sub']):
#     plt.subplot(5,5, iSub)
    
#     ind = np.argwhere((np.array(data_cross_corr['sub']) == iSub) &
#                       (np.array(data_cross_corr['randFlag']) == 1)).reshape(-1)
#     plt.plot(data_cross_corr['lags_trial'],y[ind,:].T,label = 'raw',alpha=0.4)
#     y1.append(y[ind,:].reshape(-1))
    
#     ind = np.argwhere((np.array(data_cross_corr['sub']) == iSub) &
#                       (np.array(data_cross_corr['randFlag']) == 0)).reshape(-1)
#     plt.plot(data_cross_corr['lags_trial'],y[ind,:].mean(axis=0).T,label = 'raw',alpha=0.4)
#     y2.append(y[ind,:].mean(axis=0).reshape(-1))
#     # plt.ylim(-0.6,0.6)

# plt.figure()
# plt.plot(data_cross_corr['lags_trial'],np.array(y1).mean(axis=0),label = 'raw',alpha=0.4)
# plt.plot(data_cross_corr['lags_trial'],np.array(y2).mean(axis=0),label = 'shuffle',alpha=0.4)
# plt.legend()

# #%%# ##########Data save ##########################
# if not cfg['mmFlag'] and not cfg['normFlag']:
#     with open(os.path.join(saveFileLocs + "PDPCevents_CFF_au.json"),"w") as f:
#             json.dump(data_cross_corr,f)

# elif cfg['mmFlag'] and not cfg['normFlag']:
#     with open(os.path.join(saveFileLocs + "PDPCevents_CFF_mm.json"),"w") as f:
#             json.dump(data_cross_corr,f)
# else:           
#     with open(os.path.join(saveFileLocs + "PDPCevents_CFF_norm.json"),"w") as f:
#             json.dump(data_cross_corr,f)
            
   