import numpy as np
import json
from asc2array import asc2array
import glob
import os
from pre_processing import re_sampling

folderName = glob.glob("./results/*")

datHash={"PDR":[],
         "PDR_baseline":[],
         "gazeX":[],
         "gazeY":[],
         'mSaccade':[],
         "RT":[],
         "responses":[],
         "sub":[],
         "numOfTrial":[],
         "Blink":[],
         "Saccade":[],
         "rejectFlag":[]
         # "ampOfSaccade":[]
         }

mmFlag = False
normFlag = True
numOfSub = 0 
# saveFileLocs = '/Users/yuta/Desktop/e1_endogenous_Switching/'
saveFileLocs = '/Users/yutasuzuki/Desktop/Pxx_auditoryIllusion/e1_endogenous_Switching/'
# saveFileLocs = '/Users/yuta/Desktop/Pxx_auditoryIllusion/e1_endogenous_Switching/'

# if mmFlag:
#     if os.path.exists(saveFileLocs + "data_original_mm.json"):
#         f = open(os.path.join(str( saveFileLocs + 'data_original_mm.json')))
#         datHash = json.load(f)
#         f.close()
#         folderName = folderName[int(max(datHash['sub'])):]
#         numOfSub = int(max(datHash['sub']))
# else:
#     if os.path.exists(saveFileLocs + "data_original.json"):
#         f = open(os.path.join(str( saveFileLocs + 'data_original.json')))
#         datHash = json.load(f)
#         f.close()
#         folderName = folderName[int(max(datHash['sub'])):]
#         numOfSub = int(max(datHash['sub']))


for iSub,subName in enumerate(folderName):
    fileName = glob.glob(os.path.join(subName+'/*.asc'))
    
    f = open(os.path.join(str(fileName[0])))
      
    dat=[]
    for line in f.readlines():
        dat.append(line.split())
        
    f.close()

    eyeData,events,initialTimeVal,fs = asc2array(dat, 2, mmFlag, normFlag)
    
    pupilData = eyeData['pupilData']
    gazeX = eyeData['gazeX']
    gazeY = eyeData['gazeY']
    mSaccade = eyeData['mSaccade']
    datHash['rejectFlag'].append(eyeData['rejectFlag'])
    
    coef = fs / 1000
    
    # events_response = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'one_stream' or e[1] == 'two_stream'  or e[1] == 'switch']
    events_response = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'switch' or e[1] == 'no-Switch']
    events_queue = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'task_queue']
    events_queue.append([int(int(events['MSG'][-1][0])- initialTimeVal), "dummy"])
   
    rejectNum = []
    rejectQueNum = []
    for i in np.arange(len(events_queue)-1):
        tmp = []
        for j in np.arange(len(events_response)):
            if events_queue[i] < events_response[j] and events_response[j] < events_queue[i+1]:
                tmp.append(j)
        if len(tmp) > 1:
            for k in np.arange(len(tmp)-1):
                rejectNum.append(tmp[k])
        if len(tmp) == 0:
            rejectQueNum.append(i)
    rejectQueNum.append(i+1)
    # rejectNum = np.array(rejectNum).reshape(-1)
      
    events_response = [p for i,p in enumerate(events_response) if not i in rejectNum ]
    events_queue = [p for i,p in enumerate(events_queue) if not i in rejectQueNum ]
    
    
    endFix = [e[1:6] for e in events['EFIX'] ]
    endISI = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if e[1] == 'ISI']
    
    ### for heatmap, blink and saccade
    event_data = {'EFIX':[],'ESACC':[],'EBLINK':[]}
    mmName = list(event_data.keys())
    for mm in mmName:
        for i in np.arange(len(events_queue)):       
            tmp = []
            for e in events[mm]:
                if i == len(events_queue)-1:
                    if int(e[1])-initialTimeVal > events_queue[i][0] and int(e[1])-initialTimeVal < endISI[-1][0]:
                        if e[0] == 'L':
                            e[2] = int(e[2])-initialTimeVal-events_queue[i][0]
                            tmp.append(e)
                else:
                    if int(e[1])-initialTimeVal > events_queue[i][0] and int(e[1])-initialTimeVal < events_queue[i+1][0]:
                        if e[0] == 'L':
                            e[2] = int(e[2])-initialTimeVal-events_queue[i][0]
                            tmp.append(e)
            event_data[mm].append(tmp)
          
    for e in event_data['EBLINK']:      
        datHash['Blink'].append([e_data[2] for e_data in e])
    for e in event_data['ESACC']:      
        datHash['Saccade'].append([[e_data[2],e_data[8]] for e_data in e])
              
    # # ########## data extraction #########    
    timeLen = 4*fs
    for i,ind in enumerate(events_queue):
        if i < len(events_response):
            ind_s = int((ind[0]*coef) - timeLen)
            ind_e = int(ind[0]*coef)
            datHash['PDR'].append(pupilData[ind_s:ind_e])
            if events_response[i][1] == 'switch':
                datHash['responses'].append(1)
            elif events_response[i][1] == 'no-Switch':
                datHash['responses'].append(0)
         
    datHash['sub'] = np.r_[datHash['sub'], np.ones(len(events_response))*(numOfSub+iSub+1)]
    
    sTime = 4
    eTime = 5
    for i,r in enumerate(events_response):
        # tmp_p.append(pupilData[r[0]-timeLen:r[0]])
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
            
        # plt.plot(np.diff(pupilData[r[0]-timeLen:r[0]]))
        
    for que,res in zip(events_queue,events_response):
        datHash['RT'].append((res[0]-que[0])/fs)
        
    tmp = np.zeros(len(events_response))
    # for i in np.arange(2):
    ind = [i for i,m in enumerate(events_response) if 'switch' in m]
    ind = np.array(ind)
    tmp[ind] = np.arange(len(ind))+1
    ind = [i for i,m in enumerate(events_response) if 'no-Switch' in m]
    ind = np.array(ind)
    tmp[ind] = np.arange(len(ind))+1

    datHash['numOfTrial'] = np.r_[datHash['numOfTrial'], tmp]
    
    # datHash['numOfBlink'] = np.r_[datHash['numOfBlink'], np.array(event_data['numOfEBLINK'])]
    # datHash['numOfSaccade'] = np.r_[datHash['numOfSaccade'], np.array(event_data['numOfESACC'])]
    # datHash['ampOfSaccade'] = np.r_[datHash['ampOfSaccade'], np.array(event_data['ampOfESACC'])]

# datHash['PDR'] = np.array(datHash['PDR']).tolist()
# datHash['gazeX'] = np.array(datHash['gazeX']).tolist()
# datHash['gazeY'] = np.array(datHash['gazeY']).tolist()
# datHash['mSaccade'] = np.array(datHash['mSaccade']).tolist()

# datHash['PDR_baseline'] = np.array(datHash['PDR_baseline']).tolist()

datHash['PDR'] = re_sampling(datHash['PDR'],4000)
datHash['gazeX'] = re_sampling(datHash['gazeX'],9000)
datHash['gazeY'] = re_sampling(datHash['gazeY'],9000)
datHash['mSaccade'] = re_sampling(datHash['mSaccade'],9000)

datHash['PDR_baseline'] = re_sampling(np.array(datHash['PDR_baseline']),(sTime+eTime)*1000)

mmName = list(datHash.keys())
for mm in mmName:
    if not isinstance(datHash[mm],list):
        datHash[mm] = datHash[mm].tolist()
        
with open(os.path.join(saveFileLocs + "/data_original20210409.json"),"w") as f:
    json.dump(datHash,f)

# if mmFlag:
#     with open(os.path.join(saveFileLocs + "data_original.json"),"w") as f:
#             json.dump(datHash,f)
# elif normFlag:
#     with open(os.path.join(saveFileLocs + "data_original_normalized.json"),"w") as f:
#             json.dump(datHash,f)