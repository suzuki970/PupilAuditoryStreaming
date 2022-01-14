"""
Input:    
dat      - list of asc file transfered from EDF Converter 
              provided from SR-research(https://www.sr-support.com/thread-23.html)
cfg      - dict of parameters for analysis

Output:
eyeData   - dict which includes pupil, gaze and micro-saccades
events    - list of triggers in asc file
initialTimeVal - recordig start timing
fs        - sampling rate of the recording

Example:
    fileName = glob.glob(os.path.join('/xxx.asc'))
    f = open(os.path.join(str(fileName[0])))
    dat=[]
    for line in f.readlines():
        dat.append(line.split())
    f.close()
    cfg={'useEye':2,
        'WID_FILTER':[],
        'mmFlag':False,
        'normFlag':True,
        's_trg':'SYNCTIME',
        'visualization':False
        }
    eyeData,events,initialTimeVal,fs = asc2array(dat, cfg)
    
    pupilData = eyeData['pupilData']
    gazeX = eyeData['gazeX']
    gazeY = eyeData['gazeY']
    mSaccade = eyeData['mSaccade']
"""

import numpy as np
from zeroInterp import zeroInterp
import matplotlib.pyplot as plt
from pre_processing import re_sampling
from band_pass_filter import butter_bandpass_filter,lowpass_filter
from au2mm import au2mm
from makeEyemetrics import makeMicroSaccade,draw_heatmap

def asc2array(dat, cfg):

    print('---------------------------------')
    print('Analysing...')
   
    #%% ------------- data parse from .asc file ------------- %%#
    
    eyes = cfg['useEye']
    filt = cfg['WID_FILTER']
    mmFlag = cfg['mmFlag']
    normFlag = cfg['normFlag']
    vis_trg = cfg['visualization']
    mmName = ['Left','Right']
    
    if len(cfg['s_trg']) > 0:
        s_trg = cfg['s_trg']
    else:
        s_trg = 'Start_Experiment'
    
    events = {'SFIX':[],'EFIX':[],'SSACC':[],'ESACC':[],'SBLINK':[],'EBLINK':[],'MSG':[]}
    eyeData= {'Right':[],'Left':[]}

    msg_type = ['SFIX','EFIX','SSACC','ESACC','SBLINK','EBLINK','MSG']
    
    start = False
    for line in dat:
        if start:
            if len(line) > 3:
                if line[0].isdecimal() and line[1].replace('.','',1).isdigit() :
                    eyeData['Left'].append([float(line[0]),
                                            float(line[1]),
                                            float(line[2]),
                                            float(line[3])])
                if line[0].isdecimal() and line[4].replace('.','',1).isdigit() :
                    eyeData['Right'].append([float(line[0]),
                                             float(line[4]),
                                             float(line[5]),
                                             float(line[6])])
                
            for m in msg_type:
                if line[0] == m:
                     events[m].append(line[1:])
        else:
            if 'RATE' in line:
                fs = float(line[5])
            if s_trg in line:
                start = True
                initialTimeVal = int(line[1])
                if s_trg != 'Start_Experiment':
                    events['MSG'].append(line[1:])
    
    #%% ------------- .asc to array ------------- %%#
    pL = np.array([p[3] for p in eyeData['Left']])
    pR = np.array([p[3] for p in eyeData['Right']])
    
    xL = np.array([p[1] for p in eyeData['Left']])
    xR = np.array([p[1] for p in eyeData['Right']])
    
    yL = np.array([p[2] for p in eyeData['Left']])
    yR = np.array([p[2] for p in eyeData['Right']])
    
    timeStampL = np.array([p[0] for p in eyeData['Left']])
    timeStampR = np.array([p[0] for p in eyeData['Right']])
 
    timeStampL = [int((t - initialTimeVal)*(fs/1000)) for t in timeStampL]
    timeStampR = [int((t - initialTimeVal)*(fs/1000)) for t in timeStampR]
    
    
    timeLen = np.max(timeStampR) if np.max(timeStampR) > np.max(timeStampL) else np.max(timeStampL)

    pupilData = np.zeros((2,timeLen+1))
    pupilData[0,timeStampL] = pL
    pupilData[1,timeStampR] = pR
    
    xData = np.zeros((2,timeLen+1))
    xData[0,timeStampL] = xL
    xData[1,timeStampR] = xR
    
    yData = np.zeros((2,timeLen+1))
    yData[0,timeStampL] = yL
    yData[1,timeStampR] = yR
     
    interpolatedArray = []
    interpolatedArray.append(np.argwhere(pupilData[0,]==0).reshape(-1))
    interpolatedArray.append(np.argwhere(pupilData[1,]==0).reshape(-1))
        
    #%% ------------- blink interpolation ------------- %%#
    figCount = 1
    if vis_trg:
        plt.figure()
        figSize = [3,3]
        
    dataLen = pupilData.shape[1]
    pupil_withoutInterp = pupilData.copy()
    
    pupilData = re_sampling(pupilData.copy(),round(dataLen/4))

    nBins = 201
    thre = []
    for iEyes in np.arange(pupilData.shape[0]): 
        d = np.diff(pupilData[0,:])
        sigma = np.std(d)
        d = d[(d!=0) & (d>-sigma) & (d<sigma)]
        thre.append(np.std(d)*3)
    
        if vis_trg:
            plt.subplot(figSize[0],figSize[1],figCount)
            figCount += 1
            plt.hist(d, bins=nBins)
            plt.axvline(x=thre[iEyes], ls = "--", color='#2ca02c', alpha=0.7)
            plt.axvline(x=-thre[iEyes], ls = "--", color='#2ca02c', alpha=0.7)
    figCount += 1
      
    for iEyes in np.arange(pupilData.shape[0]): 
        ind = np.argwhere(abs(np.diff(pupilData[iEyes,:])) < thre[iEyes]).reshape(-1)
        print('Average without interp.' + mmName[iEyes] + ' pupil size = ' + str(np.round(pupilData[iEyes,ind].mean(),2)))
 
        ind = np.argwhere(abs(np.diff(pupilData[iEyes,])) > thre[iEyes]).reshape(-1)
        pupilData[iEyes,ind] = 0  
    
    if normFlag:
        tmp_p = abs(pupilData.copy())
        if mmFlag:
            tmp_p = (tmp_p/256)**2*np.pi
            tmp_p = np.sqrt(tmp_p) * au2mm(700) 
        
        ind_nonzero = np.argwhere(tmp_p[0,:] != 0).reshape(-1)
        ave_left = np.mean(tmp_p[0,ind_nonzero])
        sigma_left = np.std(tmp_p[0,ind_nonzero])   
        
        ind_nonzero = np.argwhere(tmp_p[1,:] != 0).reshape(-1)
        ave_right = np.mean(tmp_p[1,ind_nonzero])
        sigma_right = np.std(tmp_p[1,ind_nonzero])       
        
        ave = np.mean([ave_left,ave_right])
        sigma = np.mean([sigma_left,sigma_right])
        
        print('Normalized by mu = ' + str(np.round(ave,4)) + ' sigma = ' + str(np.round(sigma,4)))
  
    pupilData = zeroInterp(pupilData.copy(),fs/4,10)
    data_test = pupilData['data_test']
    data_control_bef = pupilData['data_control_bef']
    data_control_aft = pupilData['data_control_aft']
    # interpolatedArray = pupilData['zeroArray']
    print('Interpolated array = ' + str(pupilData['interpolatedArray']) + 
          ' out of ' + str(pupilData['pupilData'].shape[1]))
    
    if (min(np.array(pupilData['interpolatedArray']))/pupilData['pupilData'].shape[1]) > 0.4:
        rejectFlag = True
    else:
        rejectFlag = False
        
    if pupilData['interpolatedArray'][0] < pupilData['interpolatedArray'][1]:
        xData = xData[0,:].reshape(-1)
        yData = yData[0,:].reshape(-1)
    else:
        xData = xData[1,:].reshape(-1)
        yData = yData[1,:].reshape(-1)
       
    if eyes == 1: 
        if pupilData['interpolatedArray'][0] < pupilData['interpolatedArray'][1]:
            pupilData = pupilData['pupilData'][0,:].reshape(1,pupilData['pupilData'].shape[1])
            useEye = 'L'
            mmName = ['Left']
             
        else:
            pupilData = pupilData['pupilData'][1,:].reshape(1,pupilData['pupilData'].shape[1])
            useEye = 'R'
            mmName = ['Right']
    elif eyes == 'L': 
        pupilData = pupilData['pupilData'][0,:].reshape(1,pupilData['pupilData'].shape[1])
        useEye = 'L'
        mmName = ['Left']
        
    elif eyes == 'R':
        pupilData = pupilData['pupilData'][1,:].reshape(1,pupilData['pupilData'].shape[1])
        useEye = 'R'
        mmName = ['Right']
   
    
    else: # both eyes
        pupilData = pupilData['pupilData']
        useEye = 'both'
        mmName = ['Left','Right']
   
        
    pupilData = re_sampling(pupilData.copy(),dataLen)
    
    
    #%% -------------  micro-saccade ------------- %%#
    if cfg["MS"]:
        cfg["SAMPLING_RATE"] = fs
    
        gazeX=[]
        gazeY=[]
        
        gazeX.append(xData.tolist())
        gazeY.append(yData.tolist())
        
        ev,ms,re_sample_fs = makeMicroSaccade(cfg,gazeX,gazeY)
    else:
        ev=[]
        ms=[]
        
    #%% -------------  show results ------------- %%#
     
    st = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if 'Start' in e[1]]       
    ed = [[int(int(e[0])- initialTimeVal),e[1]] for e in events['MSG'] if 'End' in e[1]]       
    
    if (len(st) == 0) | (len(ed) == 0):
        st.append([0])
        ed.append([pupilData.shape[1]])
    
    for iEyes in np.arange(pupilData.shape[0]): 
        print('Average ' + mmName[iEyes] + ' pupil size = ' + str(np.round(pupilData[iEyes,st[0][0]:ed[0][0]].mean(),2)))
        
        if vis_trg:
            plt.subplot(figSize[0],figSize[1],figCount)
            figCount += 1
            plt.plot(pupilData[iEyes,st[0][0]:ed[0][0]].T)
            plt.plot(pupil_withoutInterp[iEyes,st[0][0]:ed[0][0]].T,'k',alpha=0.2)
            plt.ylim([5000,9000])
             
            plt.subplot(figSize[0],figSize[1],figCount)
            figCount += 1
            plt.plot(pupilData[iEyes,st[0][0]:ed[0][0]].T)
            plt.plot(pupil_withoutInterp[iEyes,st[0][0]:ed[0][0]].T,'k',alpha=0.2)
            plt.ylim([5000,9000])
            plt.xlim([45000,50000])
            
            plt.subplot(figSize[0],figSize[1],figCount)
            figCount += 1
            plt.plot(np.diff(pupilData[iEyes,st[0][0]:ed[0][0]]).T)
            
            # plt.hlines(upsilon, 0, len(xData), "red", linestyles='dashed')
            # plt.savefig("./img.pdf")
    # print('upsilon = ' + str(np.round(upsilon,4)) + ', std = ' + str(np.round(np.nanstd(v),4)))

    #%% -------------  data plot ------------- %%#
    
    pupilData = np.mean(pupilData,axis=0)
    # xData = np.mean(xData,axis=0)
    # yData = np.mean(yData,axis=0)
    
    
    # plt.plot(pupilData.T,color="k")
    # plt.ylim([0,10000])
    
    # plt.subplot(2,3,2)
    # plt.plot(np.diff(pupilData).T,color="k")
    # plt.ylim([-50,50])
    
    # plt.subplot(1,3,2)
    # plt.plot(pupilData.T)
    # plt.xlim([200000, 210000])
    # # plt.ylim([20000,10000])
    
    # plt.subplot(1,3,3)
    # plt.plot(np.diff(pupilData).T)
    # plt.xlim([200000, 210000])
    # plt.ylim([-50,50])
    # plt.subplot(2,3,4)
    # plt.plot(pupilData.T,color="k")
    # plt.xlim([500000, 550000])
    # plt.ylim([0,10000])
    
    # plt.subplot(2,3,5)
    # plt.plot(pupilData.T,color="k")
    # plt.xlim([1000000, 1050000])
    # plt.ylim([0,10000])
    
    # plt.subplot(2,3,6)
    # plt.plot(pupilData.T,color="k")
    # plt.xlim([2000000, 2050000])
    # plt.ylim([0,10000])
    
    if mmFlag:
         pupilData = abs(pupilData)
         pupilData = (pupilData/256)**2*np.pi
         pupilData = np.sqrt(pupilData) * au2mm(700)
         # pupilData = 1.7*(10**(-4))*480*np.sqrt(pupilData)
    
    
    if normFlag:
        pupilData = (pupilData - ave) / sigma
              
    if len(filt) > 0:
        pupilData = butter_bandpass_filter(pupilData, filt[0], filt[1], fs, order=4)
       
    #%% -------------  data save ------------- %%#
    eyeData = {'pupilData':pupilData,
               'gazeX':xData,
               'gazeY':yData,
               'MS':ev,
               'MS_events':ms,
               'useEye':useEye,
               'rejectFlag':rejectFlag,
               'data_test':data_test,
               'data_control_bef':data_control_bef,
               'data_control_aft':data_control_aft,
               'interpolatedArray':interpolatedArray
               }
    
    return eyeData,events,initialTimeVal,int(fs)
