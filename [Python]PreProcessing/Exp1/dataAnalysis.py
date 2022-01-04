#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 20 12:32:21 2020

@author: yutasuzuki
"""
import os
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
'THRES_DIFF':0.04,
# 'mmFlag':True,
# 'normFlag':False,
'mmFlag':False,
'normFlag':True
}

saveFileLocs = 'data/'

#%% ########## data loading ###################
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

#%% ########## answer array move behind ###################
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

#%% ################# artifact rejection ##########################

y,rejectNum = pre_processing(np.array(dat['PDR_baseline'].copy()),cfg)

rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

mmName = list(dat.keys())
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
y = np.delete(y,rejectNum,axis=0)
tmp_base = np.delete(tmp_base,rejectNum,axis=0)


#%% ################# PCA ##########################
# pca_x,pca_y,rejectNumPCA = rejectBlink_PCA(y)

# y = np.delete(y,rejectNumPCA,axis=0)
# mmName = list(dat.keys())
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNumPCA]

#%% ################# Outlier ##########################

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
tmp_base = np.delete(tmp_base,rejectOutlier,axis=0)


#%% ################# blink and saccade ##########################
# ind_baseline = [rt*cfg['SAMPLING_RATE'] for rt in dat['RT']]
# ind_baseline = tmp_base*cfg['SAMPLING_RATE']

# d_bk=[]
# d_sc=[]
# for i,(bk,sc) in enumerate(zip(dat['Blink'],dat['Saccade'])):
#     d_bk.append([bk_data for bk_data in bk if bk_data > ind_baseline[i]])
#     d_sc.append([float(sc_data[1]) for sc_data in sc if sc_data[0] > ind_baseline[i]])

# dat['numOfBlink'] = [len(e) for e in d_bk]   
# dat['ampOfSaccade'] = [np.mean(e) if len(e)>0 else 0 for e in d_sc]   
# dat['numOfSaccade'] = [len(e) for e in d_sc]   

#%% ################# NAN reject ##########################
# rejectNAN=[]
# for mm in ["gazeX","gazeY","PDR"]:
#     ind = np.argwhere(np.isnan(np.array(dat[mm])) == True)
#     if len(ind)>0:
#         rejectNAN.append(ind)        
# rejectNAN = list(itertools.chain.from_iterable(rejectNAN))
# rejectNAN = np.unique(rejectNAN)
# rejectNAN = np.array(rejectNAN, dtype='int')
# y = np.delete(y,rejectNAN,axis=0)  
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNAN]

#%% ################# reject subject (N < 40%) ##########################

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
  
#%% ################# baseline ##########################
diam = np.array(dat['PDR'].copy())

# Baseline is defined as 1s before the previous task response
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

dat['PDR_size'] = [np.mean(p) for p in diam.tolist()]

#%% ################# trial number ##########################
dat['numOfTrial'] = np.zeros(len(dat['PDR']))   
                      
for iSub in np.arange(1,max(dat['sub'])+1):
    for nSwitch in np.arange(6):
        ind = [i for i,(nums,sub) in enumerate(zip(dat['numOfSwitch'],dat['sub'])) if nums == nSwitch and sub == iSub ]
        dat['numOfTrial'][ind] = np.arange(len(ind))+1

ave = np.array(original_numOfTrial)-np.array(numOftrials)
ave = 1-(np.array(numOftrials)/np.array(original_numOfTrial))

print('rejected num ave = ' + str(round(np.mean(ave),3)) + ', sd = ' + str(round(np.std(ave),3)))


#%% ############## number of dilation/constriction events ##########################

test_y = moving_avg(y.copy(),1000)
fs = 1000

events = {'indices':[],'event':[]}
for iTrial in np.arange(test_y.shape[0]):
    
    pv = np.gradient(test_y[iTrial,:])
    indices = np.where(np.diff(np.sign(pv)))[0]
    
    xv = np.gradient(indices)
    
    # reject PD/PC event within 300ms ()
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
events['numOfSwitch'] = dat['numOfSwitch']

events['dilation'] = []
events['constriction'] = []
events['dilation_time'] = []
events['constriction_time'] = []

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
            
    # sumed PC/PD events from que onset to 5s
    tmp = rateD[4000:].sum()
    events['dilation_time'].append(tmp)
    
    tmp = rateC[4000:].sum()
    events['constriction_time'].append(tmp)
 
events["numOfSwitch_norm"] = np.float32(np.array(events["numOfSwitch"]))
for iSub in np.unique(events['sub']):
    ind = np.argwhere(np.array(events["sub"] == iSub)).reshape(-1)
    events["numOfSwitch_norm"][ind] = sp.zscore(np.array(events["numOfSwitch"])[ind])
    
events["numOfSwitch_norm"] = events["numOfSwitch_norm"].tolist() 
   
dat['dilation_time'] = events['dilation_time']     


dat['PDR_size_sorted'] = [np.mean(p) for p in diam.tolist()]
dat['PDR'] = re_sampling(y,(cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

dat['PDR_baseline'] = re_sampling(np.array(dat['PDR_baseline']),
                                  (cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

# plt.figure()
# plt.rcParams["font.size"] = 18
# plt.subplot(1,2,1)
# plt.plot(y.T)
# plt.subplot(1,2,2)
# plt.plot(np.diff(y).T)
      
mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()

#%% ############### data plot ##########################

import pandas as pd
df = pd.DataFrame()
df['sub'] = dat['sub']
df['PDR'] = dat['PDR_size']
df['numOfSwitch'] = dat['numOfSwitch']
df['numOfSwitch'][df['numOfSwitch'] > 1] = 2

df['taskTimeLen'] = dat['taskTimeLen']

path = os.path.join(saveFileLocs + "numOfSwitch_jitter.json")
df.to_json(path)

df = df.groupby(['sub', 'numOfSwitch']).mean()

fig = plt.figure(figsize=(6,3), dpi=200)

color=["red","green","orange"]

from scipy import stats
print(stats.ttest_rel(df.loc[(slice(None),0), 'PDR'].values, df.loc[(slice(None),1), 'PDR'].values))
print(stats.ttest_rel(df.loc[(slice(None),0), 'PDR'].values, df.loc[(slice(None),2), 'PDR'].values))
print(stats.ttest_rel(df.loc[(slice(None),1), 'PDR'].values, df.loc[(slice(None),2), 'PDR'].values))

xLab = ['0','1','2+']
numOfSub = len(np.unique(dat['sub']))

plt.figure()
for i in range(3):
    plt.plot(xLab[i], df.loc[(slice(None),i), 'PDR'].values.mean(), marker='o', markersize=5, lw=1.0, zorder=10)
    plt.errorbar(i, df.loc[(slice(None),i), 'PDR'].values.mean(), 
                 yerr = df.loc[(slice(None),i), 'PDR'].values.std()/np.sqrt(numOfSub), 
                 xerr=None, fmt="o", ms=2.0, elinewidth=1.0, ecolor='k', capsize=6.0)
plt.title('Baseline pupil size')
 
# plt.figure()
# for i in range(3):
#     plt.plot(xLab[i], df.loc[(slice(None),i), 'taskTimeLen'].values.mean(), marker='o', markersize=5, lw=1.0, zorder=10)
#     plt.errorbar(i, df.loc[(slice(None),i), 'taskTimeLen'].values.mean(), 
#                  yerr = df.loc[(slice(None),i), 'taskTimeLen'].values.std()/np.sqrt(numOfSub), 
#                  xerr=None, fmt="o", ms=2.0, elinewidth=1.0, ecolor='k', capsize=6.0)
# plt.title('Task duration')


#%% ################ Data save ##########################
if not cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_au.json"),"w") as f:
            json.dump(dat,f)

elif cfg['mmFlag'] and not cfg['normFlag']:
    with open(os.path.join(saveFileLocs + "data_mm.json"),"w") as f:
            json.dump(dat,f)

else:
    with open(os.path.join(saveFileLocs+"data_norm.json"),"w") as f:
            json.dump(dat,f)