import numpy as np
import json
from asc2array import asc2array
import glob
import os
import math

from pre_processing import pre_processing,moving_avg
import matplotlib.pyplot as plt
from itertools import chain
 
def split_list(l, n):
    windowL = np.round(np.linspace(0, len(l), n+1))
    windowL = [int(windowL[i]) for i in np.arange(len(windowL))]
    for idx in np.arange(len(windowL)-1):
        yield l[windowL[idx]:windowL[idx+1]]
   
# folderName = glob.glob("./results/*")
folderName = glob.glob("/Users/yutasuzuki/Desktop/Python/Pxx_auditoryIllusion/e2_baseLinePupil_Switch/analysis/pre_pro/results/*")
folderName.sort()
# saveFileLocs = '/Users/yuta/Desktop/e2_baseLinePupil_Switch'
# saveFileLocs = '/Users/yutasuzuki/Desktop/Python/Pxx_auditoryIllusion/e2_baseLinePupil_Switch/analysis/pre_pro/results/'
# saveFileLocs = 'C:/Users/NTT/Desktop/e2_baseLinePupil_Switch/'
# saveFileLocs = '/Users/yuta/Desktop/box/e2_baseLinePupil_Switch/'


datHash={"PDR":[],
         "PDR_baseline":[],
         "gazeX":[],
         "gazeY":[],
         'mSaccade':[],
         "sub":[],
         "numOfSwitch":[],
         "RT":[],
         "Blink" : [],
         "Saccade":[],
         "rejectFlag":[]
         # "numOfBlink":[],
         # "numOfSaccade":[],
         # "ampOfSaccade":[]
          }

cfg={'THRES_DIFF':10,
     'WID_ANALYSIS':4,
     'useEye':2,
     'WID_FILTER':[],
     'mmFlag':False,
     'normFlag':True,
     's_trg':[]
     }
# mmFlag = False
# normFlag = True
numOfSub = 0
# folderName = folderName[-1:]

# if os.path.exists("./data_original.json"):
#     f = open(os.path.join(str( './data_original.json')))
#     datHash = json.load(f)
#     f.close()
#     folderName = folderName[int(max(datHash['sub'])):]
#     numOfSub = int(max(datHash['sub']))
# else:
#     numOfSub = 0

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

    events_queue = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'task_queue']
    events_response = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == '0' or e[1] == '1' or e[1] == '2' or e[1] == '3' or e[1] == '4' or e[1] == '5']
    
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
  
    ### for heatmap, blink and saccade
    endISI = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'ISI']
    event_data = {'EFIX':[],'ESACC':[],'EBLINK':[]}
    mmName = list(event_data.keys())
    for mm in mmName:
        for i in np.arange(len(events_queue)):       
            tmp = []
            for e in events[mm]:
                if i == len(events_queue)-1:
                    if int(e[1])-initialTimeVal > events_queue[i][0] and int(e[1])-initialTimeVal < endISI[-1][0]:
                        if e[0] == 'L':
                            e[1] = int(e[1])-initialTimeVal-events_queue[i][0]
                            e[2] = int(e[2])-initialTimeVal-events_queue[i][0]
                            tmp.append(e)
                else:
                    if int(e[1])-initialTimeVal > events_queue[i][0] and int(e[1])-initialTimeVal < events_queue[i+1][0]:
                        if e[0] == 'L':
                            e[1] = int(e[1])-initialTimeVal-events_queue[i][0]
                            e[2] = int(e[2])-initialTimeVal-events_queue[i][0]
                            tmp.append(e)
            event_data[mm].append(tmp)
    
    for e in event_data['EBLINK']:      
        # event_data['Blink'].append([e_data[2] for e_data in e])
        datHash['Blink'].append([[e_data[1],e_data[2],e_data[3]] for e_data in e])
    for e in event_data['ESACC']:      
        # event_data['Saccade'].append([[e_data[2],e_data[8]] for e_data in e])
        datHash['Saccade'].append([[e_data[2],e_data[8]] for e_data in e])
    # event_data['numOfEBLINK'] = [len(e) for e in event_data['EBLINK'] if len(e)>0]   
    # event_data['numOfESACC'] = [len(e) for e in event_data['ESACC']]
    # event_data['ampOfESACC']=[]
    # for line in event_data['ESACC']:
    #     tmp = []
    #     for e in line:
    #         tmp.append(float(e[8]))
    #     # event_data['ampOfESACC'].append(np.mean(tmp))
    #     event_data['ampOfESACC'].append(tmp)
        
    tmp_numOfSwitch = np.array([int(r[1]) for r in events_response])
    timeLen = int(cfg['WID_ANALYSIS']*fs)
    
    for i,r in enumerate(events_queue):
        datHash['PDR'].append(pupilData[r[0]-timeLen:r[0]])
    
    sTime = 4
    eTime = 5
    for i,r in enumerate(events_response):
        tmp = pupilData[(r[0]-int(sTime*fs)):(r[0]+int(eTime*fs))]
        tmp_gazeX = gazeX[(r[0]-int(sTime*fs)):(r[0]+int(eTime*fs))]
        tmp_gazeY = gazeY[(r[0]-int(sTime*fs)):(r[0]+int(eTime*fs))]
        tmp_mSaccade = mSaccade[(r[0]-int(sTime*fs)):(r[0]+int(eTime*fs))]
        
        if len(tmp) == int((sTime+eTime)*fs):
            datHash['PDR_baseline'].append(tmp)
            datHash['gazeX'].append(tmp_gazeX)
            datHash['gazeY'].append(tmp_gazeY)
            datHash['mSaccade'].append(tmp_mSaccade)
        else:
            datHash['PDR_baseline'].append(np.zeros(int((sTime+eTime)*fs)))
            datHash['gazeX'].append(np.zeros(int((sTime+eTime)*fs)))
            datHash['gazeY'].append(np.zeros(int((sTime+eTime)*fs)))
            datHash['mSaccade'].append(np.zeros(int((sTime+eTime)*fs)))
               
    for que,res in zip(events_queue,events_response):
        datHash['RT'].append((res[0]-que[0])/fs)
        
    ############ # of switch #########################
    datHash['numOfSwitch'] = np.r_[datHash['numOfSwitch'], tmp_numOfSwitch]
    
    datHash['sub'] = np.r_[datHash['sub'],np.ones(len(events_queue))*(numOfSub+iSub+1)]
    # datHash['numOfBlink'] = np.r_[datHash['numOfBlink'], np.array(event_data['numOfEBLINK'])]
    # datHash['numOfSaccade'] = np.r_[datHash['numOfSaccade'], np.array(event_data['numOfESACC'])]
    # datHash['ampOfSaccade'] = np.r_[datHash['ampOfSaccade'], np.array(event_data['ampOfESACC'])]

datHash['PDR'] = np.array(datHash['PDR']).tolist()
datHash['gazeX'] = np.array(datHash['gazeX']).tolist()
datHash['gazeY'] = np.array(datHash['gazeY']).tolist()
datHash['mSaccade'] = np.array(datHash['mSaccade']).tolist()

datHash['PDR_baseline'] = np.array(datHash['PDR_baseline']).tolist()

mmName = list(datHash.keys())
for mm in mmName:
    if not isinstance(datHash[mm],list):
        datHash[mm] = datHash[mm].tolist()

# if mmFlag:
# with open(os.path.join(saveFileLocs + "/data_original20210405.json"),"w") as f:
#         json.dump(datHash,f)
with open(os.path.join("./data/data_original20210630.json"),"w") as f:
        json.dump(datHash,f)
# elif normFlag:
#     with open(os.path.join(saveFileLocs + "/data_original_normalized.json"),"w") as f:
#             json.dump(datHash,f)