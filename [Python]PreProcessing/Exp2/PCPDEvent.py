#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  9 15:07:55 2021

@author: yutasuzuki
"""

import numpy as np
import matplotlib.pyplot as plt
from pre_processing import pre_processing,re_sampling,getNearestValue,moving_avg
from band_pass_filter import lowpass_filter
from rejectBlink_PCA import rejectBlink_PCA
import json
import os
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
'THRES_DIFF':0.04
}

saveFileLocs = './data/'
saveFileLocs = '/Users/yutasuzuki/Desktop/Python/Pxx_auditoryIllusion/e1_endogenous_Switching/analysis/data/'

## ########## data loading ###################
f = open(os.path.join(str(saveFileLocs + 'data_original.json')))
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

################## artifact rejection ##########################

y,rejectNum = pre_processing(np.array(dat['PDR_baseline'].copy()),cfg)

rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

mmName = list(dat.keys())
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
y = np.delete(y,rejectNum,axis=0)

################## Outlier ##########################

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

################## reject subject (N < 40%) ##########################
reject=[]
NUM_TRIAL = 80
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
    
    # if min(numOftrials_res[iSub-1]) < (len(ind0)+len(ind1)) * 0.2:
    #         reject.append(iSub)
    if (len(ind0)+len(ind1)) < NUM_TRIAL * 0.4:
            reject.append(iSub)

reject = np.unique(reject)
# print('# of trials = ' + str(numOftrials))

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

########################################################################
test_y = moving_avg(y.copy(),1000)

events = {'indices':[],'event':[]}
for iTrial in np.arange(test_y.shape[0]):
    
    pv = np.gradient(test_y[iTrial,:])
    indices = np.where(np.diff(np.sign(pv)))[0]
    
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

events['sub'] = dat['sub']
events['responses'] = dat['responses']

events['dilation'] = []
events['constriction'] = []
events['dilation_time'] = []
events['constriction_time'] = []
# events['sub_time'] =[]
# events['condition_time'] =[]

for indSwitch in np.arange(2):
    for iSub in np.unique(events['sub']):
        ind = np.argwhere((np.array(events['responses']) == indSwitch) &
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
        
events["responses_norm"] = np.float32(np.array(events["responses"]))
for iSub in np.unique(events['sub']):
    ind = np.argwhere(np.array(events["sub"] == iSub)).reshape(-1)
    events["responses_norm"][ind] = sp.zscore(np.array(events["responses"])[ind])
    
events["responses_norm"] = events["responses_norm"].tolist() 

events['dilation'] = moving_avg(np.array(events['dilation']),500).tolist()
events['constriction'] = moving_avg(np.array(events['constriction']),500).tolist()
    
events['dilation'] = re_sampling(events['dilation'],90).tolist()
events['constriction'] = re_sampling(events['constriction'],90).tolist()

################# trial number ##########################
events['numOfTrial'] = np.zeros(y.shape[0])

currentNum = 0
for indSwitch in np.arange(2):

    ind = np.argwhere((np.array(events['responses']) == indSwitch)).reshape(-1)

    events['numOfTrial'][ind] = np.arange(len(ind))+1+currentNum
    currentNum = currentNum + len(ind)+1
    
events['numOfTrial'] = events['numOfTrial'].tolist()

# with open(os.path.join(saveFileLocs + "PDPCevents.json"),"w") as f:
#         json.dump(events,f)
        
numOfSub = len(np.unique(events['sub']))
plt.figure(figsize=(6,8))
y = np.array(events['dilation_time'])
for i in np.arange(2):
    ind = np.argwhere(np.array(events['responses']) == i)       
    plt.plot(i,y[ind].mean(axis=0),'o',linewidth=1,alpha=0.5)