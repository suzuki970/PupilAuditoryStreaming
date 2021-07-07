#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 20 12:32:21 2020

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

# saveFileLocs = '/Users/yuta/Desktop/e2_baseLinePupil_Switch/'
# saveFileLocs = 'C:/Users/NTT/Desktop/e2_baseLinePupil_Switch/'
# saveFileLocs = '/Users/yutasuzuki/Desktop/Pxx_auditoryIllusion/e2_baseLinePupil_Switch/'
saveFileLocs = 'data/'
# saveFileLocs = '/Users/yuta/Desktop/box/e2_baseLinePupil_Switch/'

## ########## data loading ###################

# f = open(os.path.join(str( saveFileLocs +'data_original.json')))
# f = open(os.path.join(str(saveFileLocs + 'data_original_normalized.json')))
f = open(os.path.join(str(saveFileLocs + 'data_original20210405.json')))
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

################## artifact rejection ##########################

y,rejectNum = pre_processing(np.array(dat['PDR_baseline'].copy()),cfg)

rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

mmName = list(dat.keys())
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
y = np.delete(y,rejectNum,axis=0)
tmp_base = np.delete(tmp_base,rejectNum,axis=0)


################## PCA ##########################
# pca_x,pca_y,rejectNumPCA = rejectBlink_PCA(y)

# y = np.delete(y,rejectNumPCA,axis=0)
# mmName = list(dat.keys())
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNumPCA]

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
tmp_base = np.delete(tmp_base,rejectOutlier,axis=0)


################## blink and saccade ##########################
# ind_baseline = [rt*cfg['SAMPLING_RATE'] for rt in dat['RT']]
ind_baseline = tmp_base*cfg['SAMPLING_RATE']

d_bk=[]
d_sc=[]
for i,(bk,sc) in enumerate(zip(dat['Blink'],dat['Saccade'])):
    d_bk.append([bk_data for bk_data in bk if bk_data > ind_baseline[i]])
    d_sc.append([float(sc_data[1]) for sc_data in sc if sc_data[0] > ind_baseline[i]])

dat['numOfBlink'] = [len(e) for e in d_bk]   
dat['ampOfSaccade'] = [np.mean(e) if len(e)>0 else 0 for e in d_sc]   
dat['numOfSaccade'] = [len(e) for e in d_sc]   

################## microsaccade ##########################
gazeX = np.array(dat['gazeX'].copy())
gazeY = np.array(dat['gazeY'].copy())
gazeY[gazeY<0]=0

for iTrial in np.arange(len(gazeX)):
    ind = np.argwhere(abs(np.diff(gazeX[iTrial,:])) > 50)
    gazeX[iTrial,ind] = 0  
    
    ind = np.argwhere(abs(np.diff(gazeY[iTrial,:])) > 50)
    gazeY[iTrial,ind] = 0  

fs = 250
gazeX = zeroInterp(gazeX.copy(),fs,10)
gazeX = gazeX['pupilData']

# gazeY = zeroInterp(gazeY.copy(),fs,10)
# gazeY = gazeY['pupilData']

gazeX = gazeX[:,4000:]
gazeY = gazeY[:,4000:]

gazeX = re_sampling(gazeX,int(gazeX.shape[1]/4)).tolist()
gazeY = re_sampling(gazeY,int(gazeY.shape[1]/4)).tolist()

events = {'MSpos':[],'MSneg':[]}
    
test_x_pos=[]
test_x_neg=[]

for tx,ty in zip(gazeX,gazeY):

    vx = np.zeros(len(tx))
    vy = np.zeros(len(ty))
    for i in np.arange(2,len(tx)-2):
        if tx[i+2]*tx[i+1]*tx[i-2]*tx[i-1] == 0:
            vx[i] = np.nan
        else:
            vx[i] = (tx[i+2]+tx[i+1]-tx[i-2]-tx[i-1]) / (6*(1/fs))
            
        # vx[i] = (tx[i+2]+tx[i+1]-tx[i-2]-tx[i-1]) / (6*(1/fs))
        # vy[i] = (ty[i+2]+ty[i+1]-ty[i-2]-ty[i-1]) / (6*(1/fs))
    
    sigma_x = (np.median(vx**2)-np.median(vx)**2) / 3
    # sigma_y = (np.median(vy**2)-np.median(vy)**2)
    
    # a = (sigma_x/2)**2
    # b = (sigma_y/2)**2
    
    # x = vx**2
    # y = vy**2
    
    # P = (x/a)+(y/b)-1
     
    # ind = np.argwhere(P > 0).reshape(-1).tolist()
    
    ind_pos = np.argwhere(vx > sigma_x).reshape(-1).tolist()
    ind_neg = np.argwhere(-vx > sigma_x).reshape(-1).tolist()
     
    cFlag = False
    tmp = []
    for iNum in np.arange(len(ind_pos)-1):
        if not cFlag:
            sTime = ind_pos[iNum]
          
        if ind_pos[iNum]+3 > ind_pos[iNum+1]:
            cFlag = True
        else:
            eTime = ind_pos[iNum]

            x = np.array(tx[sTime-50:sTime+50])
            # x = x - np.median(x)
            
            if len(x) > 0:
                # x = max(x)-min(x)
            
                # y = np.array(ty[sTime-50:sTime+50])
                # y = max(y)-min(y)
                
                # if not len(np.argwhere(np.array(tx[sTime-50:sTime+50]) == 0)) > 0:
                #     if not len(np.argwhere(np.array(ty[sTime-50:sTime+50]) > 700)) > 0:
                # test_x_pos.append(tx[sTime-50:eTime+50])
                # test_y.append(ty[sTime-50:eTime+50])
                # tmp.append([sTime,eTime,x,y,math.atan2(y,x)*(180/np.pi),np.sqrt(x**2+y**2)])
                amp = (tx[sTime+2]+tx[sTime+1]-tx[sTime-2]-tx[sTime-1])
                tmp.append([sTime,eTime,tx[sTime-50:eTime+50],amp])
                    
            cFlag = False
            
    events['MSpos'].append(tmp)
 
    cFlag = False
    tmp = []

    for iNum in np.arange(len(ind_neg)-1):
        if not cFlag:
            sTime = ind_neg[iNum]
          
        if ind_neg[iNum]+3 > ind_neg[iNum+1]:
            cFlag = True
        else:
            eTime = ind_neg[iNum]

            x = np.array(tx[sTime-50:sTime+50])
            # x = x - np.median(x)
            
            if len(x) > 0:
                # x = max(x)-min(x)
            
                # y = np.array(ty[sTime-50:sTime+50])
                # y = max(y)-min(y)
                
                # if not len(np.argwhere(np.array(tx[sTime-50:sTime+50]) == 0)) > 0:
                #     if not len(np.argwhere(np.array(ty[sTime-50:sTime+50]) > 700)) > 0:
                # test_x_neg.append()
                # test_y.append(ty[sTime-50:eTime+50])
                # tmp.append([sTime,eTime,x,y,math.atan2(y,x)*(180/np.pi),np.sqrt(x**2+y**2)])
                amp = (tx[sTime+2]+tx[sTime+1]-tx[sTime-2]-tx[sTime-1])
                tmp.append([sTime,eTime,tx[sTime-50:sTime+50],amp])
                    
            cFlag = False
            
    events['MSneg'].append(tmp) 


for iTrial,(pos,neg) in enumerate(zip(events['MSpos'],events['MSneg'])):
    
    rejectNum = []
    for iNumOfMs,p in enumerate(pos):
        if len(np.argwhere(abs(np.diff(p[2])) > 10)) > 0:
            rejectNum.append(iNumOfMs)
            
        if len(np.argwhere(np.array(p[2]) > 900)) > 0:
            rejectNum.append(iNumOfMs)
        
        if len(np.argwhere(np.array(p[2]) < 700)) > 0:
            rejectNum.append(iNumOfMs)

    if len(rejectNum) > 0:
        # print(rejectNum)
        events['MSpos'][iTrial] = [d for i,d in enumerate(pos) if not i in rejectNum]

    rejectNum = []
    for iNumOfMs,p in enumerate(neg):
        if len(np.argwhere(abs(np.diff(p[2])) > 10)) > 0:
            rejectNum.append(iNumOfMs)
        
        if len(np.argwhere(np.array(p[2]) > 900)) > 0:
            rejectNum.append(iNumOfMs)
        
        if len(np.argwhere(np.array(p[2]) < 700)) > 0:
            rejectNum.append(iNumOfMs)
    if len(rejectNum) > 0:
        # print(1)
        events['MSneg'][iTrial] = [d for i,d in enumerate(neg) if not i in rejectNum]

        
dat['numOfmSaccade'] = [len(e) for e in events['MSpos']]
dat['ampOfmSaccade'] = []
for pos in events['MSpos']:
    numOfms = []
    if len(pos)>0:
        for p in pos:
            numOfms.append(p[3])
    else:
        numOfms.append(0)
     
    dat['ampOfmSaccade'].append(np.mean(numOfms))

del dat["gazeX"], dat["gazeY"],dat['Blink'],dat['Saccade']
mmName = list(dat.keys())

################## NAN reject ##########################
rejectNAN=[]
for mm in mmName:
    ind = np.argwhere(np.isnan(np.array(dat[mm])) == True)
    if len(ind)>0:
        rejectNAN.append(ind)        
rejectNAN = list(itertools.chain.from_iterable(rejectNAN))
rejectNAN = np.unique(rejectNAN)
rejectNAN = np.array(rejectNAN, dtype='int')
y = np.delete(y,rejectNAN,axis=0)  
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNAN]

################## reject subject (N < 40%) ##########################

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
    
    # if min(numOftrials_res[iSub-1]) ==1:
    #         reject.append(iSub)
    if (len(ind0)+len(ind1)+len(ind2)) < NUM_TRIAL * 0.4:
            reject.append(iSub)
            
reject = np.unique(reject)

print('# of trials = ' + str(numOftrials))

rejectSub = [i for i,d in enumerate(dat['sub']) if d in reject]
print('rejected subject = ' + str(reject))

# y = np.delete(y,rejectSub,axis=0)  
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectSub]
  
################## Tertile ##########################
diam = np.array(dat['PDR'].copy())

tmp_diam = diam[:,-1000:]
plt.plot(tmp_diam.T)
plt.plot(np.diff(tmp_diam).T)

rejectNum = []
for iTrial in np.arange(tmp_diam.shape[0]):
    if len(np.argwhere(abs(np.diff(tmp_diam[iTrial,:])) > 0.04)) > 0:
        rejectNum.append(iTrial)
        
y = np.delete(y,rejectNum,axis=0)  
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
        
diam = np.array(dat['PDR'].copy())
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

dat['PDR_size'] = [np.mean(p) for p in diam.tolist()]

numOfSwitch = np.array(dat['numOfSwitch'].copy())

dat['tertile'] = []
dat['tertile_dummy'] = []

for iSub in np.arange(1,max(dat['sub'])+1):
    ind = [i for i,s in enumerate(dat['sub']) if s == iSub]
    tmp_switch = numOfSwitch[ind].copy()
    tmp_PDR = diam[ind,].copy()
        
    aftSort = np.argsort(np.mean(tmp_PDR,axis=1))
    
    numOfSwitch[ind] = tmp_switch[aftSort].copy()
    diam[ind,] = tmp_PDR[aftSort,].copy()
    
    x = list(split_list(np.mean(tmp_PDR,axis=1),5))
    
    rn = []
    for i,xVal in enumerate(x):
        dat['tertile'] = np.r_[dat['tertile'],np.ones(len(xVal))*(i+1)]
        rn = np.r_[rn,np.ones(len(xVal))*(i+1)]

    rn = list(rn)
    random.shuffle(rn)
    dat['tertile_dummy'] = np.r_[dat['tertile_dummy'],rn]

dat['numOfSwitch_sorted'] = numOfSwitch.tolist()

for i in np.arange(1,6):
    ind = np.argwhere(dat['tertile'] == i).reshape(-1)
    print('Total # of trials (bin:' + str(i) + ') = ' + str(len(ind)))

################## trial number ##########################
dat['numOfTrial'] = np.zeros(len(dat['PDR']))   
                      
for iSub in np.arange(1,max(dat['sub'])+1):
    for nSwitch in np.arange(6):
        ind = [i for i,(nums,sub) in enumerate(zip(dat['numOfSwitch'],dat['sub'])) if nums == nSwitch and sub == iSub ]
        dat['numOfTrial'][ind] = np.arange(len(ind))+1

ave = np.array(original_numOfTrial)-np.array(numOftrials)
ave = 1-(np.array(numOftrials)/np.array(original_numOfTrial))

print('rejected num ave = ' + str(round(np.mean(ave),3)) + ', sd = ' + str(round(np.std(ave),3)))

################## data plot ##########################
plt.figure()
for i in np.arange(1,6):
    ind = np.argwhere(dat['tertile'] == i).reshape(-1)
    # ind = np.argwhere(dat['tertile_dummy'] == i).reshape(-1)
    
    yy = [s for i,s in enumerate(dat['numOfSwitch_sorted']) if i in ind]
    # plt.subplot(1,2,1)
    plt.plot(i,np.mean(yy),'o')
    

plt.figure(figsize=(10.0, 6.5))
plt.rcParams["font.size"] = 28
plt.rcParams["font.family"] = "Times New Roman"
plt.title('Pupil size around task response',fontsize=30)
x = np.linspace(cfg['TIME_START'],cfg['TIME_END'],np.array(dat['PDR_baseline']).shape[1])
plt.plot(x,np.mean(np.array(dat['PDR_baseline']),axis=0))
ind0 = np.argwhere((np.array(dat['numOfSwitch'])==0))
ind1 = np.argwhere((np.array(dat['numOfSwitch'])==1))
ind2 = np.argwhere((np.array(dat['numOfSwitch'])>1))
plt.plot(x,np.mean(np.array(dat['PDR_baseline'])[ind0],axis=0).reshape(-1),label='0')
plt.plot(x,np.mean(np.array(dat['PDR_baseline'])[ind1],axis=0).reshape(-1),label='1')
plt.plot(x,np.mean(np.array(dat['PDR_baseline'])[ind2],axis=0).reshape(-1),label='2+')
plt.legend()
plt.savefig("timecourse.pdf")

# plt.subplot(1,2,2)
plt.vlines(-np.mean(np.array(dat['RT'])), -0.5, 0.5, "black", linestyles='dashed')
# plt.vlines(cfg['WID_BASELINE'][0], -0.5, 0.5, "red", linestyles='dashed')
# plt.vlines(cfg['WID_BASELINE'][1], -0.5, 0.5, "red", linestyles='dashed')
plt.ylim(-0.1,0.2)
plt.ylabel('Pupil size [z-scored]')
plt.xlabel('Time [sec]')
# plt.savefig(saveFileLocs+"pupilRes.pdf")
# plt.figure()
# plt.rcParams["font.size"] = 18
# plt.subplot(1,2,1)
# plt.plot(y.T)
# plt.subplot(1,2,2)
# plt.plot(np.diff(y).T)

# plt.figure()
# plt.plot(x,np.mean(y,axis=0))
# plt.vlines(np.mean(np.array(dat['RT'])), -0.5, 0.5, "black", linestyles='dashed')
# plt.vlines(cfg['WID_BASELINE'][0], -0.5, 0.5, "red", linestyles='dashed')
# plt.vlines(cfg['WID_BASELINE'][1], -0.5, 0.5, "red", linestyles='dashed')
# plt.ylim(-0.1,0.3)


################ number of dilation/constriction events ##########################

test_y = moving_avg(y.copy(),1000)
fs = 1000

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

plt.figure()
plt.rcParams["font.size"] = 18
plt.subplot(1,2,1)
plt.plot(y.T)
plt.subplot(1,2,2)
plt.plot(np.diff(y).T)
      
mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()
   
A = []
B = []
C = []
for iSub in np.unique(np.array(dat['sub'])):
    ind = np.argwhere((np.array(dat['numOfSwitch']) == 0) & 
                      (np.array(dat['sub']) == iSub)).reshape(-1)
    A.append(np.mean(np.array(dat['PDR_size'])[ind]))
    
    ind = np.argwhere((np.array(dat['numOfSwitch']) == 1) & 
                      (np.array(dat['sub']) == iSub)).reshape(-1)
    B.append(np.mean(np.array(dat['PDR_size'])[ind]))
    ind = np.argwhere((np.array(dat['numOfSwitch']) > 1) & 
                      (np.array(dat['sub']) == iSub)).reshape(-1)
    C.append(np.mean(np.array(dat['PDR_size'])[ind]))
    
    
from scipy import stats
print(stats.ttest_rel(np.array(A), np.array(B)))
print(stats.ttest_rel(np.array(A), np.array(C)))
print(stats.ttest_rel(np.array(B), np.array(C)))

# with open(os.path.join(saveFileLocs + "data20210610.json"),"w") as f:
#         json.dump(dat,f)
