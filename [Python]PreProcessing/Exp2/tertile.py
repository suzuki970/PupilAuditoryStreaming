#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb  6 12:37:48 2021

@author: yutasuzuki
"""

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

# cfg={
# 'SAMPLING_RATE':1000,   
# 'windowL':10,
# 'TIME_START':-4,
# 'TIME_END':4,
# 'WID_ANALYSIS':4,
# 'WID_FILTER':np.array([]),
# 'METHOD':1,
# 'FLAG_LOWPASS':True
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
# 'THRES_DIFF':0.3 
}

saveFileLocs = 'data/'

# f = open(os.path.join(str(saveFileLocs + 'data_original_normalized.json')))
f = open(os.path.join(str(saveFileLocs + 'data_original20210409.json')))
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

################## reject subject (N < 40%) ##########################
# reject=[]
# NUM_TRIAL = 80
# numOftrials = []
# numOftrials_res = []
# for iSub in np.arange(1,int(max(dat['sub']))+1):
#     # if rejectFlag[iSub-1]:
#     #     reject.append(iSub)
#     ind0 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['responses'])==0))
#     ind1 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['responses'])==1))
#     ind = np.argwhere((np.array(dat['sub'])==iSub))
    
#     numOftrials.append(len(ind0)+len(ind1))
#     numOftrials_res.append([len(ind0),len(ind1)])
    
#     if min(numOftrials_res[iSub-1]) < (len(ind0)+len(ind1))/2 * 0.4:
#             reject.append(iSub)
#     if (len(ind0)+len(ind1)) < NUM_TRIAL * 0.4:
#             reject.append(iSub)
            
# reject = np.unique(reject)
# print('# of trials = ' + str(numOftrials))

# rejectSub = [i for i,d in enumerate(dat['sub']) if d in reject]
# print('rejected subject = ' + str(reject))
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectSub]

    
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

# plt.figure()
# for i in np.arange(1,6):
#     ind = np.argwhere(np.array(dat['tertile']) == i).reshape(-1)
#     yy = [s for i,s in enumerate(dat['responses_sorted']) if i in ind]
#     plt.plot(i,np.mean(yy),'o',markersize=10)
    # plt.plot(np.repeat(i,len(yy)),np.array(yy),'o',markersize=5)

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
    # ave = np.mean(np.array(dat['responses_sorted'])[ind])
    responses_zscored = np.r_[responses_zscored,
                              sp.zscore( np.array(dat['responses_sorted'])[ind])]

# dat['responses_sorted'][ind] = sp.zscore( np.array(dat['responses_sorted'])[ind])
# for i in np.arange(1,6):
#     ind = np.argwhere((np.array(dat['tertile']) == i) & 
#                       (np.array(dat['sub']) == iSub)).reshape(-1)
#     # a = len(np.argwhere(np.array(dat['responses_sorted'])[ind] == 0))
#     # b = len(np.argwhere(np.array(dat['responses_sorted'])[ind] == 1))      
#     # Z = 1/sym.integrate(((1 - theta)**a) * theta ** b, (theta, 0, 1))
#     # y = Z * ((theta ** b)*((1 - theta) ** a))
#     # EAP = sym.integrate(theta * y, (theta, 0, 1))
#     # log_f = sym.log(y)
#     # eq = sym.Eq(sym.diff(log_f), 0)
#     # MAP = sym.solveset(eq).args[0]
#     theta_hat['hat'].append(np.mean(np.array(dat['responses_sorted'])[ind])-ave)
#     theta_hat['sub'].append(int(iSub))
#     theta_hat['tertile'].append(int(i))
    
dat['responses_sorted'] = responses_zscored
plt.figure()
for i in np.arange(1,6):
    ind = np.argwhere(np.array(dat['tertile']) == i).reshape(-1)
    yy = [s for i,s in enumerate(dat['responses_sorted']) if i in ind]
    plt.plot(i,np.mean(yy),'o',markersize=10)
    # plt.plot(np.repeat(i,len(yy)),np.array(yy),'o',markersize=5)
plt.figure()
for i in np.arange(1,6):
    ind = np.argwhere(np.array(dat['tertile']) == i).reshape(-1)
    yy = [s for i,s in enumerate(dat['RT_sorted']) if i in ind]
    plt.plot(i,np.mean(yy),'o',markersize=10)

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

with open(os.path.join(saveFileLocs+"data_tertile20210610.json"),"w") as f:
        json.dump(dat,f)
# with open(os.path.join(saveFileLocs+"data_tertile.json"),"w") as f:
#      json.dump(theta_hat,f)      