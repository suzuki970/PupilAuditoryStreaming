#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  1 10:06:35 2021

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
   
folderName = glob.glob("../results/*")
folderName.sort()

saveFileLocs = '../data/'

def split_list(l, n):
    windowL = np.round(np.linspace(0, len(l), n+1))
    windowL = [int(windowL[i]) for i in np.arange(len(windowL))]
    for idx in np.arange(len(windowL)-1):
        yield l[windowL[idx]:windowL[idx+1]]

datHash={"PDR":[],
         "sub":[],
         "numOfTrial":[],
         "data_x":[],
         "data_x_queue":[],
         "Response":[],
         "start_end":[],
         "rejectFlag":[]
         }

cfg={'THRES_DIFF':10,
     'WID_ANALYSIS':4,
     'useEye':2,
     'WID_FILTER':[],
     'mmFlag':False,
     'normFlag':True,
     's_trg':[]
     }


for iSub,subName in enumerate(folderName):
    fileName = glob.glob(os.path.join(subName+'/*.asc'))
        
    f = open(os.path.join(str(fileName[0])))
    
    dat=[]
    for line in f.readlines():
        dat.append(line.split())
        
    f.close()
    
    eyeData,events,initialTimeVal,fs = asc2array(dat, cfg)
    
    pupilData = eyeData['pupilData']
    gazeX = eyeData['gazeX']
    gazeY = eyeData['gazeY']
    mSaccade = eyeData['mSaccade']
    datHash['rejectFlag'].append(eyeData['rejectFlag'])
    
    start_trial = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'Start_Pesentation']
    end_trial = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'End_Pesentation']
  
    datHash['start_end'].append([[s[0],e[0]] for s,e in zip(start_trial,end_trial)])
  
    events_response = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == '0' or e[1] == '1' or e[1] == '2' or e[1] == '3' or e[1] == '4' or e[1] == '5']
    events_queue = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'task_queue']
    events_queue.append([int(int(events['MSG'][-1][0])- initialTimeVal), "dummy"])
    
    rejectNum_res = []
    rejectNum_queue = []
    for i in np.arange(len(events_queue)-1):
        tmp = []
        for j in np.arange(len(events_response)):
            if events_queue[i] < events_response[j] and events_response[j] < events_queue[i+1]:
                tmp.append(j)
        if len(tmp) > 1:
            for k in np.arange(len(tmp)-1):
                rejectNum_res.append(tmp[k])
            # rejectNum_res.append(tmp[:-1])
        elif len(tmp) == 0:
            rejectNum_queue.append(i)
   
    if events_queue[-1][0] > events_response[-1][0]:
        rejectNum_queue.append(len(events_queue)-1)
        
    events_response = [p for i,p in enumerate(events_response) if not i in rejectNum_res ]
    events_queue = [p for i,p in enumerate(events_queue) if not i in rejectNum_queue ]
       
    ind_fix = [int(int(e[0])-initialTimeVal) for e in events['MSG'] if e[1] == 'Start_Pesentation']
    ind_fix.append(events_response[-1][0])
    
    rt = []
    condition_switch = []
    ave_queueTime = []
    rt_fromq = []
    for iTrial in np.arange(len(ind_fix)-1):
        r  = []
        r.append(ind_fix[iTrial]/1000)
        q = []
        q.append(ind_fix[iTrial]/1000)
        # rq = []
        for iRes,iQueue in zip(events_response,events_queue):
            if iQueue[0] > ind_fix[iTrial] and iQueue[0] < ind_fix[iTrial+1]:
                if int(iRes[1]) > 0:
                    r.append(iRes[0]/1000)
                q.append(iQueue[0]/1000)
                rt_fromq.append((iRes[0]-iQueue[0])/1000)
               
        # rt_fromq .append(rq)
        rt.append(np.diff(r))
        ave_queueTime.append(np.diff(q))
        condition_switch.append(np.ones(len(r)-1)*iTrial)
    
    t1 = [r for i,r in enumerate(rt_fromq) if int(events_response[i][1]) == 0]
    t2 = [r for i,r in enumerate(rt_fromq) if int(events_response[i][1]) > 0]

    condition_switch = list(chain.from_iterable(condition_switch))
    rt = list(chain.from_iterable(rt))

    res = [int(r[1]) for r in events_response]
      
    datHash["PDR"].append(pupilData)
     
    x = [e[0] for e in events_response]
    datHash["data_x"] = np.r_[datHash["data_x"],x]
    
    x = [e[0] for e in events_queue]
    datHash["data_x_queue"] = np.r_[datHash["data_x_queue"],x]
    
    datHash["Response"] = np.r_[datHash["Response"],res]
    datHash['sub'] = np.r_[datHash['sub'],np.ones(len(res))*(iSub+1)]

datHash["PDR"] = [p.tolist() for p in datHash["PDR"]]
mmName = list(datHash.keys())
for mm in mmName:
    if not isinstance(datHash[mm],list):
        datHash[mm] = datHash[mm].tolist()

with open(os.path.join(saveFileLocs + "data_base_cross_corr.json"),"w") as f:
    json.dump(datHash,f)
