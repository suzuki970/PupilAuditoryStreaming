#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 18:00:46 2020

@author: yuta
"""

import numpy as np
import matplotlib.pyplot as plt
from pre_processing import moving_avg
import json
import os
import pandas as pd

# saveFileLocs = '/Users/yutasuzuki/Desktop/Pxx_auditoryIllusion/e2_baseLinePupil_Switch/'
saveFileLocs = '/Users/yutasuzuki/Desktop/Python/Pxx_auditoryIllusion/e2_baseLinePupil_Switch/analysis/data/'

f = open(os.path.join(saveFileLocs + str('/data.json')))
# f = open(os.path.join(str('../data/data2.json')))
dat = json.load(f)
f.close()

dat['PDR'] = np.mean(np.array(dat['PDR'])[:,600:800],axis=1)

mSaccade = dat['mSaccade']

freqmSaccade = []
for ms in mSaccade:
    tmp_ms = np.array(ms)
    tmp_ms[tmp_ms != 0] = 1
    freqmSaccade.append(list(tmp_ms))

plot_timeCourse = {'n0':[],'n1':[],'n2':[]}
mmName = list(plot_timeCourse.keys())

# for iSub in np.unique(dat['sub']):
#     ind = np.argwhere((np.array(dat['sub']) == iSub) &
#                       (np.array(dat['numOfSwitch']) == 0)).reshape(-1)
#     plot_timeCourse['n0'].append(np.sum(np.array([ms for i,ms in enumerate(freqmSaccade) if i in ind]),axis=0))
    
#     ind = np.argwhere((np.array(dat['sub']) == iSub) &
#                       (np.array(dat['numOfSwitch']) == 1)).reshape(-1)
#     plot_timeCourse['n1'].append(np.sum(np.array([ms for i,ms in enumerate(freqmSaccade) if i in ind]),axis=0))
    
#     ind = np.argwhere((np.array(dat['sub']) == iSub) &
#                       (np.array(dat['numOfSwitch']) > 1)).reshape(-1)
#     plot_timeCourse['n2'].append(np.sum(np.array([ms for i,ms in enumerate(freqmSaccade) if i in ind]),axis=0))

# mmName = ['PDR','PDR_size','ampOfSaccade',
#           'numOfBlink','numOfSaccade',
#           'ampOfmSaccade','numOfmSaccade','numOfSwitch']

# mmName2 = ['Transient','Baseline','ampOfSaccade',
#           'numOfBlink','numOfSaccade',
#           'ampOfmSaccade','numOfmSaccade','numOfSwitch']

mmName = ['dilation_time','PDR','PDR_size','ampOfSaccade',
          'numOfBlink','numOfSaccade',
          'ampOfmSaccade','numOfmSaccade','numOfSwitch']

mmName2 = ['TransientPD','pupil changes','Baseline','ampOfSaccade',
          'numOfBlink','numOfSaccade',
          'ampOfmSaccade','numOfmSaccade','numOfSwitch']

train = pd.DataFrame(dat['sub'], columns=['sub'])
for mm,mm2 in zip(mmName,mmName2):
    ind = np.argwhere(np.isnan(dat[mm]) == True).reshape(-1) 
    if len(ind) > 0:
        for i in ind:
            dat[mm][i] = 0
    train[mm2] = dat[mm]
 
# train['numOfSwitch'][train['numOfSwitch'] > 0] = 1

train.to_pickle('./train_data.pkl')
