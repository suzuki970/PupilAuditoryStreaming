
import numpy as np
import numpy.matlib
from band_pass_filter import butter_bandpass_filter,lowpass_filter
import pandas
from scipy import interpolate,fftpack
from scipy.fftpack import fft2, ifft2
from scipy import signal,fftpack
import matplotlib.pyplot as plt

# overlap
def ov(data, fs, overlap, frame = 2**12):
    """
    Input:    
    Output:
    Example:
    """
    N = len(data)  
    Ts = N / fs         #data
    Fc = frame / fs     #frame
    x_ol = frame * (1 - (overlap/100)) #overlap
    N_ave = int((Ts - (Fc * (overlap/100))) / (Fc * (1-(overlap/100))))

    array = []

    for i in range(N_ave):
        ps = int(x_ol * i) 
        # dat = zero_padding(data[ps:ps+frame:1],zeropad)
        # array.append(dat) 
        array.append(data[ps:ps+frame:1]) 
    return array, N_ave  

def hanning(data, N_ave, frame = 2**12):
    """
    Input:    
    Output:
    Example:
    """
    #haning
    # han = signal.hann(frame) 
    han = signal.kaiser(frame,2)
    # han = signal.blackman(frame)
    
    acf = 1 / (sum(han) / frame)
    
    data_pad = []
    for i in range(N_ave):
        data[i] = data[i] * han
        data_pad.append(data[i])
        
    return data_pad, acf
# FFT
def fft_ave(data,fs, N_ave, acf, frame = 2**12):
    
    """
    Input:    
    Output:
    Example:
    """
    fft_array = []
    for i in range(N_ave):
        fft_array.append(acf*np.abs(fftpack.fft(data[i])/(frame/2)))
        
    fft_axis = np.linspace(0, fs, frame)
    fft_array = np.array(fft_array)
    fft_mean = np.sqrt(np.mean(fft_array ** 2, axis=0))
    
    return fft_array, fft_mean, fft_axis

def zero_padding(data, len_pad):
    """
    Input:    
    Output:
    Example:
    """
    if data.ndim == 1:
        pad = np.zeros(len_pad)
        data_pad = np.hstack((np.insert(data, 0, pad), pad))
        acf = (sum(np.abs(data)) / len(data)) / (sum(np.abs(data_pad)) / len(data_pad))
        return data_pad * acf
    else:    
        pad = np.zeros((data.shape[0],len_pad))
        data_pad = np.hstack([np.hstack([pad,data]),pad])
        acf = (np.abs(data[0,:]).sum() / data.shape[1]) / (np.abs(data_pad[0,:]).sum() / data_pad.shape[1])
        
        return data_pad

def split_list(l, n):
    windowL = np.round(np.linspace(0, len(l), n+1))
    windowL = [int(windowL[i]) for i in np.arange(len(windowL))]
    for idx in np.arange(len(windowL)-1):
        yield np.arange(windowL[idx],windowL[idx+1]).tolist(),l[windowL[idx]:windowL[idx+1]]

        
def getfft(data, fs):
    # spectrum = fftpack.fft(data)
    # spectrum = []
    # for d in data:
    #     spectrum.append(fftpack.fft(d))
    spectrum = np.fft.fft(data, axis=1, norm=None)   
    spectrum = np.array(spectrum)
                     
    N = len(data[0])
    amp = abs(spectrum)
    amp = amp / (N / 2)
    phase = np.arctan2(spectrum.imag, spectrum.real)
    phase = np.degrees(phase)
    freq = np.linspace(0, fs, N)

    return spectrum[:,:round(N / 2)], amp[:,:round(N / 2)], phase[:,:round(N / 2)], freq[:round(N / 2)]

def rejectDat(dat,rejectNum):
    for mm in list(dat.keys()):
        dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
    return dat
       
def zscore(x, axis = None):
    xmean = x.mean(axis=axis, keepdims=True)
    xstd  = np.std(x, axis=axis, keepdims=True)
    zscore = (x-xmean)/xstd
    return zscore

def re_sampling(dat,num):
    """
    Input:    
        dat  - list of data
        num  - list or int of re-sampling rate
    Output:
    Example:
    """
    re_sampled = []
    for iTrial,d in enumerate(dat):
        t = np.array(d)
        numX = np.arange(len(t))
        yy = interpolate.PchipInterpolator(numX, t)
        if isinstance(num, list):
            t_resample = np.linspace(0, len(t), num[iTrial])
        else:
            t_resample = np.linspace(0, len(t), num)
            
        re_sampled.append(yy(t_resample))
    
    return np.array(re_sampled)

def getNearestValue(in_y, num):
    idx = np.abs(np.asarray(in_y) - num).argmin()
    return idx

def moving_avg(x,windowL):
    
    """
    Input:    
        dat      - list of data
        windowL  - list or int of re-sampling rate
    Output:
    Example:
    """
    if isinstance(x, list):
        tmp_y = x.copy()
        
        for iTrials,d in enumerate(x):
            s = pandas.Series(np.array(d))
            x[iTrials] = np.array(s.rolling(window=windowL).mean())
        
        out_y = []
        for iTrials,d in enumerate(x):
            out_y.append(np.r_[np.array(tmp_y[iTrials])[np.arange(windowL)],
                         np.array(d)[np.arange(windowL,len(d))]].tolist())
            
    else:
    
        if x.ndim == 1:
            x = x.reshape(1,len(x))
            
        tmp_y = x.copy()
        
        for trials in np.arange(len(x)):
            s = pandas.Series(x[trials,])
            x[trials,] = s.rolling(window=windowL).mean()
        
        out_y = []
        for trials in np.arange(len(x)):
            out_y.append(np.r_[np.array(tmp_y[trials])[np.arange(windowL)],
                         x[trials,np.arange(windowL,x.shape[1])]])
        out_y = np.array(out_y)

    return out_y

def reject_trials(y,thres,baselineData):
  
    ## reject trials when the velocity of pupil change is larger than threshold
    rejectNum=[]
    fx = np.diff(y, n=1)
    for trials in np.arange(y.shape[0]):
        ind = np.argwhere(abs(fx[trials,np.arange(baselineData[0],baselineData[2])]) > thres)
        # ind = np.argwhere(abs(fx[trials,np.arange(50,baselineData[2])]) > thres)
        
        if len(ind) > 0:
            plt.plot(fx[trials,:])
            rejectNum.append(trials)
            continue
            
        if sum(np.isnan(y[trials,np.arange(baselineData[0],baselineData[2])])) > 0:
            rejectNum.append(trials)
            continue
    
        ## reject trials when number of 0 > 50#
        # if sum(np.argwhere(y[trials,np.arange(baselineData[0],baselineData[2])] == 0)) > y.shape[0] / 2:
        #     rejectNum.append(trials)
        #     continue
        
    ## reject trials when the NAN includes
    # tmp = np.argwhere(np.isnan(y) == True) 
    # for i in np.arange(tmp.shape[0]):
    #     rejectNum.append(tmp[i,0])
        
    rejectNum = np.unique(rejectNum)
    set(rejectNum)
    return rejectNum.tolist()

    
# def pre_processing(y,fs,thres,windowL,timeLen,method,filt):
def pre_processing(dat,cfg):
    """
    Input:    
        dat  - 
        cfg  -
    Output:
    Example:
    """
    
    filt         = cfg['WID_FILTER']
    fs           = cfg['SAMPLING_RATE']
    windowL      = cfg['windowL']
    TIME_START   = cfg['TIME_START']
    TIME_END     = cfg['TIME_END']
    wid_base     = cfg['WID_BASELINE']
    method       = cfg['METHOD']
    thres        = cfg['THRES_DIFF']
    wid_analysis = cfg['WID_ANALYSIS']
    
    if isinstance(dat, list):
        rejectNum=[]
        out_y = []
        for i,p in enumerate(dat):
            
            timeWin = len(p)
            
            ## Smoothing
            s = pandas.Series(p)
            y = s.rolling(window=windowL).mean()
            y = np.array(y)
            timeWin = len(y)
            
            x = np.linspace(TIME_START[i],TIME_END[i],timeWin)
           
            # filtering
            # if len(filt) > 0:
            #     ave = np.nanmean(y)
            #     y = y - ave
            #     y = butter_bandpass_filter(y, filt[0], filt[1], fs, order=4)
            #     y = y + ave
        
            baselineData = np.array([getNearestValue(x,wid_base[0]),getNearestValue(x,wid_base[1]),getNearestValue(x,wid_analysis[i])])
            baselinePLR = y[np.arange(baselineData[0],baselineData[1])]
            baselinePLR_std = np.std(baselinePLR)
            # baselinePLR_std = np.tile(baselinePLR_std, (1,timeWin)).reshape(1,timeWin).T
            baselinePLR = np.mean(baselinePLR)
            # baselinePLR = np.tile(baselinePLR, (1,timeWin)).reshape(timeWin,dat.shape[0]).T   
           
            if method == 1:
                y = y - baselinePLR
            elif method == 2:
                y = (y - baselinePLR) / baselinePLR_std
            else:
                y = y 
                
            fx = np.diff(y)
            ind = np.argwhere(abs(fx[np.arange(baselineData[0],baselineData[2])]) > thres)
            # ind = np.argwhere(abs(fx) > thres)
        
            if len(ind) > 0:
                rejectNum.append(i)
                # continue
            
            ## reject trials when number of 0 > 50#
            if sum(np.argwhere(y[np.arange(baselineData[0],baselineData[2])] == 0)) > y.shape[0] / 2:
                rejectNum.append(i)
                # continue
                
            ## reject trials when the NAN includes
            if len(np.argwhere(np.isnan(y[windowL:]) == True)) > 0:
                rejectNum.append(i)
                
            out_y.append(y)
            
        rejectNum = np.unique(rejectNum)
        set(rejectNum)
        y = out_y
    else:
        ## Smoothing
        # y = moving_avg(dat.copy(),windowL)
        y = dat.copy()
        ## baseline(-200ms - 0ms)
        x = np.linspace(TIME_START,TIME_END,y.shape[1])
      
        # filtering
        if len(filt) > 0:
            ave = np.mean(y,axis=1)
            y = y - np.tile(ave, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T
            y = butter_bandpass_filter(y, filt[0], filt[1], fs, order=4)
            y = y + np.tile(ave, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T
    
        if wid_base.shape[0] > 2:
            tmp_baseline = np.zeros((y.shape[0],y.shape[1]))
            for iTrial in np.arange(wid_base.shape[0]):
                baselineData = np.array([getNearestValue(x,wid_base[iTrial,0]),getNearestValue(x,wid_base[iTrial,1]),getNearestValue(x,wid_analysis)])
                baselinePLR = y[iTrial,np.arange(baselineData[0],baselineData[1])]
                # baselinePLR_std = np.std(baselinePLR,axis=1)
                # baselinePLR_std = np.tile(baselinePLR_std, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T
                baselinePLR = np.mean(baselinePLR)
                # baselinePLR = np.tile(baselinePLR, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T   
                tmp_baseline[iTrial,:] = np.tile(baselinePLR, (1,y.shape[1]))
            baselinePLR = tmp_baseline
        else:
            baselineData = np.array([getNearestValue(x,wid_base[0]),getNearestValue(x,wid_base[1]),getNearestValue(x,wid_analysis)])
            baselinePLR = y[:,np.arange(baselineData[0],baselineData[1])]
            baselinePLR_std = np.std(baselinePLR,axis=1)
            baselinePLR_std = np.tile(baselinePLR_std, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T
            baselinePLR = np.mean(baselinePLR,axis=1)
            baselinePLR = np.tile(baselinePLR, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T   
       
        if method == 1:
            y = y - baselinePLR
        elif method == 2:
            # y = (y - baselinePLR) / baselinePLR_std
            y = y / baselinePLR
        else:
            ave = np.mean(y,axis=1)
            ave = np.tile(ave, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T
            std = np.std(y,axis=1)
            std = np.tile(std, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T           
            y = (y - ave) / std
            
            baselinePLR = y[:,np.arange(baselineData[0],baselineData[1])]
            baselinePLR = np.mean(baselinePLR,axis=1)
            baselinePLR = np.tile(baselinePLR, (1,y.shape[1])).reshape(y.shape[1],y.shape[0]).T   
            y = y - baselinePLR
            
        if cfg['FLAG_LOWPASS']:
            y = lowpass_filter(y, cfg['TIME_END']-cfg['TIME_START'])
       
        rejectNum = reject_trials(y,thres,baselineData)
 

    return y,rejectNum
