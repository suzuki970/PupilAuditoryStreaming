
import numpy as np
from zeroInterp import zeroInterp
import matplotlib.pyplot as plt
from pixel_size import pixel_size,pixel2angle
import matplotlib.patches as patches
from pre_processing import re_sampling
from operator import itemgetter
import math
import os
from fastdtw import fastdtw
from scipy.spatial.distance import euclidean
from tqdm import tqdm

def gaussian(x, sx, y=None, sy=None):

    """Returns an array of numpy arrays (a matrix) containing values between
    1 and 0 in a 2D Gaussian distribution
    
    arguments
    x		-- width in pixels
    sx		-- width standard deviation
    
    keyword argments
    y		-- height in pixels (default = x)
    sy		-- height standard deviation (default = sx)
    """
    # square Gaussian if only x values are passed
    if y == None:
        y = x
    if sy == None:
        sy = sx
	# centers	
    xo = x/2
    yo = y/2
    # matrix of zeros
    M = np.zeros([y,x],dtype=float)
    # gaussian matrix
    for i in range(x):
        for j in range(y):
            M[j,i] = np.exp(-1.0 * (((float(i)-xo)**2/(2*sx*sx)) + ((float(j)-yo)**2/(2*sy*sy)) ) )
    
    return M


def parse_fixations(fixations):
	
	"""Returns all relevant data from a list of fixation ending events
	
	arguments
	
	fixations		-	a list of fixation ending events from a single trial,
					as produced by edfreader.read_edf, e.g.
					edfdata[trialnr]['events']['Efix']

	returns
	
	fix		-	a dict with three keys: 'x', 'y', and 'dur' (each contain
				a np array) for the x and y coordinates and duration of
				each fixation
	"""
	
	# empty arrays to contain fixation coordinates
	fix = {	'x':np.zeros(len(fixations)),
			'y':np.zeros(len(fixations)),
			'dur':np.zeros(len(fixations))}
	# get all fixation coordinates
	for fixnr in range(len( fixations)):
		stime, etime, dur, ex, ey, pa = fixations[fixnr]
		fix['x'][fixnr] = ex
		fix['y'][fixnr] = ey
		fix['dur'][fixnr] = dur
	
	return fix


def draw_heatmap(fixations, dispsize):

    res_heatmap=[]
    for iTrial_fix in fixations:
        fix = parse_fixations(iTrial_fix)
        
        # IMAGE
    #     fig, ax = draw_display(dispsize, imagefile=imagefile)
        # HEATMAP
        # Gaussian
        gwh = 200
        gsdwh = gwh/6
        gaus = gaussian(gwh,gsdwh)
        # matrix of zeroes
        strt = int(gwh/2)
        heatmapsize = dispsize[1] + 2*strt, dispsize[0] + 2*strt
        heatmap = np.zeros(heatmapsize, dtype=float)
        # create heatmap
        for i in range(0,len(fix['dur'])):
            # get x and y coordinates
            #x and y - indexes of heatmap array. must be integers
            x = int(strt + int(fix['x'][i]) - int(gwh/2))
            y = int(strt + int(fix['y'][i]) - int(gwh/2))
            # correct Gaussian size if either coordinate falls outside of
            # display boundaries
            if (not 0 < x < dispsize[0]) or (not 0 < y < dispsize[1]):
                hadj=[0,gwh]
                vadj=[0,gwh]
                if 0 > x:
                    hadj[0] = abs(x)
                    x = 0
                elif dispsize[0] < x:
                    hadj[1] = gwh - int(x-dispsize[0])
                if 0 > y:
                    vadj[0] = abs(y)
                    y = 0
                elif dispsize[1] < y:
                    vadj[1] = gwh - int(y-dispsize[1])
                # add adjusted Gaussian to the current heatmap
                try:
                    heatmap[y:y+vadj[1],x:x+hadj[1]] += gaus[vadj[0]:vadj[1],hadj[0]:hadj[1]] * fix['dur'][i]
                except:
                    # fixation was probably outside of display
                    pass
            else:                
                # add Gaussian to the current heatmap
                heatmap[y:y+gwh,x:x+gwh] += gaus * fix['dur'][i]
        # resize heatmap
        heatmap = heatmap[strt:dispsize[1]+strt,strt:dispsize[0]+strt]/len(fix['dur'])
        # remove zeros
        lowbound = np.mean(heatmap[heatmap>0])
        heatmap[heatmap<lowbound] = 0
        # np.NaN
        res_heatmap.append(heatmap)
    
    return res_heatmap


def makeMicroSaccade(cfg,gazeX,gazeY,fs = 250,VISUALIZE=False):
  
    """
    Input:    
    cfg                    - dict of parameters for analysis
    - 'SAMPLING_RATE'      - int of sampling rate of gaze data
    - 'DOT_PITCH'          - dot pitch of the used monitor
    - 'VISUAL_DISTANCE'    - visual distance from screen to eye
    - 'acceptMSRange'      - relative MS range threshold
    - "SCREEN_RES"         - screen resolution
    - "SCREEN_MM"          - screen size in mm
     
    gazeX   - list of gaze position of x
    gazeX   - list of gaze position of y
    
    Output:
    events   - dict which includes all params of micro-saccades
    dat      - dict which includes MS onset, amplitude and theta of micro-saccades
    fs       - re-sampling rate of the MS analysis
    
    Example:
    cfg={'SAMPLING_RATE':1000,
         'DOT_PITCH':0.271,   
         'VISUAL_DISTANCE':60,
         'acceptMSRange':2,
         'SCREEN_RES':[1600, 1200],
         'SCREEN_MM':[432, 324],
        }
    
    ev,ms,fs = makeMicroSaccade(cfg,gazeX,gazeY)
  
    """
    
    #%%  interpolation
    if isinstance(gazeX, list):
        gazeX_interp = zeroInterp(gazeX,cfg['SAMPLING_RATE'],10)
        gazeX_interp = gazeX_interp['pupilData']
        
        gazeY_interp = zeroInterp(gazeY,cfg['SAMPLING_RATE'],10)
        gazeY_interp = gazeY_interp['pupilData']
        
        numOfLen = []
        for x in gazeX_interp:
            numOfLen.append(int(len(x)*(fs/cfg['SAMPLING_RATE'])))
        
        gazeX_interp = re_sampling(gazeX_interp,numOfLen).tolist()
        gazeY_interp = re_sampling(gazeY_interp,numOfLen).tolist()
   
    else:
        gazeX_interp = zeroInterp(np.array(gazeX),cfg['SAMPLING_RATE'],10)
        gazeX_interp = gazeX_interp['pupilData']
        
        gazeY_interp = zeroInterp(np.array(gazeY),cfg['SAMPLING_RATE'],10)
        gazeY_interp = gazeY_interp['pupilData']
        
        gazeX_interp = re_sampling(gazeX_interp,(cfg['TIME_END']-cfg['TIME_START'])*fs).tolist()
        gazeY_interp = re_sampling(gazeY_interp,(cfg['TIME_END']-cfg['TIME_START'])*fs).tolist()
    
    gazeX_deg = (180/np.pi)*np.arctan2(np.array(gazeX_interp) - cfg["SCREEN_RES"][0]/2,
                                       (cfg['VISUAL_DISTANCE']*10 * cfg["SCREEN_RES"][0]) / cfg["SCREEN_MM"][0])
    gazeY_deg = (180/np.pi)*np.arctan2(np.array(gazeY_interp) - cfg["SCREEN_RES"][1]/2,
                                       (cfg['VISUAL_DISTANCE']*10 * cfg["SCREEN_RES"][1]) / cfg["SCREEN_MM"][1])
    
    
    #%%  micro-saccade(MS) detection and noise screening
    events = []
    win = int(fs*0.2)
    
    for iTrial,(tx,ty) in enumerate(tqdm(zip(gazeX_deg,gazeY_deg))):
    
        vx = np.zeros(len(tx))
        vy = np.zeros(len(ty))
        for i in np.arange(2,len(tx)-2):
            if tx[i+2]*tx[i+1]*tx[i-2]*tx[i-1] == 0:
                vx[i] = np.nan
            else:
                vx[i] = (tx[i+2]+tx[i+1]-tx[i-2]-tx[i-1]) * fs
                # / (6*(1/fs))
            
            if ty[i+2]*ty[i+1]*ty[i-2]*ty[i-1] == 0:
                vy[i] = np.nan
            else:
                vy[i] = (ty[i+2]+ty[i+1]-ty[i-2]-ty[i-1]) * fs
                # / (6*(1/fs))
            
        VFAC = 5
        medx = np.median(vx)
        msdx = np.sqrt(np.median((vx-medx)**2)) * VFAC
        medy = np.median(vy)
        msdy = np.sqrt(np.median((vy-medy)**2)) * VFAC
 
        P = (vx/msdx)+(vy/msdy)-1
       
        # sigma_x = (np.median(vx**2)-np.median(vx)**2) / 6
        # sigma_y = (np.median(vy**2)-np.median(vy)**2) / 100
        
        sigma_x = np.std(vx)
        sigma_x = np.std(vx[(vx!=0) & (vx>-sigma_x) & (vx<sigma_x)])*3
        
        sigma_y = np.std(vy)
        sigma_y = np.std(vy[(vy!=0) & (vy>-sigma_y) & (vx<sigma_y)])*3
        
        # if iTrial == 1:
        #     plt.hist(vx,bins=100)
        #     plt.axvline(x=sigma_x, ls = "--", color='#2ca02c', alpha=0.7)
        #     plt.axvline(x=-sigma_x, ls = "--", color='#2ca02c', alpha=0.7)
        
       
        # plt.hist(vy,bins=100)
        # plt.axvline(x=sigma_y, ls = "--", color='#2ca02c', alpha=0.7)
        # plt.axvline(x=-sigma_y, ls = "--", color='#2ca02c', alpha=0.7)
        
        ## determined as micro-saccades
        ind_ms={}
        ind_ms['x'] = np.argwhere((vx > sigma_x) | (vx < -sigma_x)).reshape(-1).tolist()
        ind_ms['y'] = np.argwhere((vy > sigma_y) | (vy < -sigma_y)).reshape(-1).tolist()
        
        ind_ms['test'] = np.argwhere(P > 0).reshape(-1)
        
        indx = np.argwhere(P > 0).reshape(-1)
        MINDUR = 3
        # nsac = 0
        dur = 1
        sTime = 0
        c = 20 # * SAMPLING/1000
        d = 20 #* SAMPLING/1000
        currentTime = 0
        
        tmp = []
        # Loop over saccade candidates
        while ( currentTime < (len(indx)-1) ):
            if indx[currentTime+1]-indx[currentTime]==1:
                dur = dur + 1
            else:
                # Minimum duration criterion (exception: last saccade
                # print(dur)
                # print(d)
                if (dur>=MINDUR) & (d >= 20):
                    # nsac = nsac + 1
                    eTime = currentTime
                    
                    # sac.append([indx[sTime],indx[eTime]])
                    amp_x = np.c_[np.array(tx)[indx[sTime]+2],np.array(tx)[indx[sTime]+1],np.array(tx)[indx[sTime]-2],np.array(tx)[indx[sTime]-1]].mean(axis=1)
                    amp_x = amp_x-np.mean(tx)
                    
                    amp_y = np.c_[np.array(ty)[indx[sTime]+2],np.array(ty)[indx[sTime]+1],np.array(ty)[indx[sTime]-2],np.array(ty)[indx[sTime]-1]].mean(axis=1)
                    amp_y = amp_y-np.mean(ty)
                    theta = np.arctan2(amp_y, amp_x) * (180 / np.pi)
            
                    tmp.append({"onset":int(indx[sTime]),
                                "offset":int(indx[eTime]),
                                "gaze_x":tx[indx[sTime]-win:indx[sTime]+win],
                                "gaze_y":ty[indx[sTime]-win:indx[sTime]+win],
                                "vel_x":vx[indx[sTime]-win:indx[sTime]+win],
                                "vel_y":vy[indx[sTime]-win:indx[sTime]+win],
                                "thre" :[msdx,msdy],
                                # "sig":sig,
                                "amplitude":np.r_[amp_x, amp_y, np.sqrt(amp_x**2+amp_y**2)],
                                "theta":float(theta)
                                })
                    c = indx[eTime]
                
                sTime = currentTime + 1
                d = indx[sTime] - c
                dur = 1
          
            currentTime += 1
        # Check minimum duration for last microsaccade
        if dur>=MINDUR :
            # nsac <- nsac + 1
            eTime = currentTime
            amp_x = np.c_[np.array(tx)[indx[sTime]+2],np.array(tx)[indx[sTime]+1],np.array(tx)[indx[sTime]-2],np.array(tx)[indx[sTime]-1]].mean(axis=1)
            amp_x = amp_x-np.mean(tx)
            
            amp_y = np.c_[np.array(ty)[indx[sTime]+2],np.array(ty)[indx[sTime]+1],np.array(ty)[indx[sTime]-2],np.array(ty)[indx[sTime]-1]].mean(axis=1)
            amp_y = amp_y-np.mean(ty)
            theta = np.arctan2(amp_y, amp_x) * (180 / np.pi)
    
            tmp.append({"onset":int(indx[sTime]),
                        "offset":int(indx[eTime]),
                        "gaze_x":tx[indx[sTime]-win:indx[sTime]+win],
                        "gaze_y":ty[indx[sTime]-win:indx[sTime]+win],
                        "vel_x":vx[indx[sTime]-win:indx[sTime]+win],
                        "vel_y":vy[indx[sTime]-win:indx[sTime]+win],
                        "thre" :[msdx,msdy],
                        # "sig":sig,
                        "amplitude":np.r_[amp_x, amp_y, np.sqrt(amp_x**2+amp_y**2)],
                        "theta":float(theta)
                        })
     
        ## look at the time course of MS
        # tmp = []
        # for ind_ms_name in ['test']:
        #     cFlag = False
            
        #     sTime = np.r_[0,np.argwhere(np.diff(ind_ms[ind_ms_name]) > MINDUR).reshape(-1)]
            
        #     eTime = np.r_[np.argwhere(np.diff(ind_ms[ind_ms_name]) > MINDUR).reshape(-1)]-1
        #     eTime = np.r_[eTime,sTime[-1]+1]
            
        #     sTime = np.array(ind_ms[ind_ms_name])[sTime]
        #     eTime = np.array(ind_ms[ind_ms_name])[eTime]
 
        #     amp_x = np.c_[np.array(tx)[sTime+2],np.array(tx)[sTime+1],np.array(tx)[sTime-2],np.array(tx)[sTime-1]].mean(axis=1)
        #     amp_x = amp_x-np.mean(tx)
            
        #     amp_y = np.c_[np.array(ty)[sTime+2],np.array(ty)[sTime+1],np.array(ty)[sTime-2],np.array(ty)[sTime-1]].mean(axis=1)
        #     amp_y = amp_y-np.mean(ty)
                    
        #     ## MS amplitde and 
        #     amp = np.sqrt(amp_x**2+amp_y**2)
        #     theta = np.arctan2(amp_y, amp_x) * (180 / np.pi)
            
        #     tmp_tx = np.array(tx)
        #     tmp_ty = np.array(ty)
            
        #     for ims,(s,e) in enumerate(zip(sTime.tolist(),eTime.tolist())):
        #         if ind_ms_name == 'x':
        #             if np.mean(tmp_tx[s-win:s]) > np.mean(tmp_tx[s:s+win]):
        #                 sig=0
        #             else:
        #                 sig=1
        #         else:
        #             if np.mean(tmp_ty[s-win:s]) > np.mean(tmp_ty[s:s+win]):
        #                 sig=0
        #             else:
        #                 sig=1
        #         if (s > win) and (s < len(tmp_tx)-win):
        #             tmp.append({"cood":ind_ms_name,
        #                         "onset":s,
        #                         "offset":e,
        #                         "gaze_x":tmp_tx[s-win:s+win],
        #                         "gaze_y":tmp_ty[s-win:s+win],
        #                         "vel_x":vx[s-win:s+win],
        #                         "vel_y":vy[s-win:s+win],
        #                         "thre" :[sigma_x,sigma_y],
        #                         "sig":sig,
        #                         "amplitude":[amp_x[ims], amp_y[ims], amp[ims]],
        #                         "theta":theta[ims]
        #                         })
                
        events.append(sorted(tmp, key=lambda x:x['onset']))

    print(str(len(events[0])) + " microsaccade was found for trial 1")
    
    #%% reject outlier of 2 degrees 
    # acceptRange = pixel_size(cfg['DOT_PITCH'],cfg['acceptMSRange'],cfg['VISUAL_DISTANCE'])
    # for iTrial,ms_ind in enumerate(events):
    #     rejectNum = []
    #     ind_sTime = []
        
    #     ## reject likely blink ones
    #     for iNumOfMs,p in enumerate(ms_ind):
    #         ind_sTime.append(p["onset"])
    #         if p["cood"]=='x':
    #             if len(np.argwhere(abs(np.array(p["gaze_x"])-cfg["SCREEN_RES"][0]/2) > acceptRange)) > 0:
    #                 rejectNum.append(iNumOfMs)
    #         else:
    #             if len(np.argwhere(abs(np.array(p["gaze_y"])-cfg["SCREEN_RES"][1]/2) < acceptRange)) > 0:
    #                 rejectNum.append(iNumOfMs)
     
    # if len(rejectNum) > 0:
    #      events[iTrial] = [d for i,d in enumerate(ms_ind) if not i in rejectNum]
       
    #%%  reject outlier of overlapping MS 
    # itr=1
    # test_distance_x=[]
    # test_distance_y=[]
    # # while True:
    # #     print("Iteration..." + str(itr))
    # for iTrial,ms_ind in enumerate(tqdm(events)):
    #     ## delete too high corr. (as they are the same MS)
    #     if len(ms_ind) > 0:
    #         cval = {'x':[],'y':[]}
    #         iNumOfMs0=0
    #         indAll=[]
    #         indAll_dist=[]
    #         while True: 
    #             # print(iNumOfMs0)
    #             rejectNumWin =[]
    #             tmp_ax0 = ms_ind[iNumOfMs0]["gaze_x"]
    #             tmp_ay0 = ms_ind[iNumOfMs0]["gaze_y"]
                
    #             ind = []
    #             ind_dist=[]
    #             if iNumOfMs0 > len(ms_ind)-10:
    #                 ed = len(ms_ind)
    #             else:
    #                 ed = iNumOfMs0+10
                    
    #             for iNumOfMs1 in np.arange(iNumOfMs0+1,ed):
    #                 tmp_bx0 = ms_ind[iNumOfMs1]["gaze_x"]
    #                 tmp_by0 = ms_ind[iNumOfMs1]["gaze_y"]
                    
    #                 p_a = abs(np.mean(tmp_ax0 - tmp_bx0))
    #                 p_b = abs(np.mean(tmp_ay0 - tmp_by0))
                    
    #                 if (p_a < 50) and (p_b < 50):
    #                     distance_x, path = fastdtw(tmp_ax0, tmp_bx0, dist=euclidean)
    #                     distance_y, path = fastdtw(tmp_ay0, tmp_by0, dist=euclidean)
    #                     test_distance_x.append(distance_x)
    #                     test_distance_y.append(distance_y)
                    
    #                     if distance_y < 2000:
    #                         ind_dist.append(iNumOfMs1)
                        
    #                     tmp_ax = tmp_ax0-np.mean(tmp_ax0)
    #                     tmp_ay = tmp_ay0-np.mean(tmp_ay0)
    #                     tmp_bx = tmp_bx0-np.mean(tmp_bx0)
    #                     tmp_by = tmp_by0-np.mean(tmp_by0)
                    
    #                     npts = len(tmp_ax)
    #                     ccov_x = np.correlate(tmp_ax, tmp_bx, mode='full')
    #                     t1 = ccov_x / (npts * tmp_ax.std() * tmp_bx.std())
    #                     t1 = max(t1)
                       
    #                     ccov_y = np.correlate(tmp_ay, tmp_by, mode='full')
    #                     t2 = ccov_y / (npts * tmp_ay.std() * tmp_by.std())
    #                     t2 = max(t2)
            
    #                     if (t1 > 0.8) and (t2 > 0.8):
    #                         ind.append(iNumOfMs1)
                        
    #             indAll = indAll+ind
    #             indAll_dist = indAll_dist+ind_dist
                
    #             if not len(ind+ind_dist) > 0:
    #                 iNumOfMs0+=1
    #             else:
    #                 ind = np.unique(indAll+indAll_dist)
    #                 iNumOfMs0 = ind[-1]+1       
            
    #             if iNumOfMs0 >= len(ms_ind)-1:
    #                 break

    #         # rejectNumAll = np.unique(rejectNum + rejectNumWinAll)
    #         # print(str(len(rejectNum)) + " microsaccade was rejected ")
    #         # print(str(len(np.unique(indAll + indAll_dist))) + " microsaccade was rejected ")
    #         if len(indAll) > 0:
    #             events[iTrial] = [d for i,d in enumerate(ms_ind) if not i in np.unique(indAll + indAll_dist)]
  
        # if len(rejectNumAll) == 0:
        #     break
        # else:
        #     itr+=1
            
    #%%
    if VISUALIZE:
        count = 1
        # plt.figure(figsize=(7,7))
        for ev in events[:3]:
           for e in ev:
               # plt.subplot(5,5,count)
               if len(e["gaze_x"])>0:
                   fig = plt.figure()
                   ax = plt.axes()
                    
                   el = patches.Ellipse(xy=(0,0), width=e["thre"][0], height=e["thre"][1], fill=False, ec='r')
                   ax.add_patch(el)
                   plt.plot(e["vel_x"],e["vel_y"],'.-')
                   plt.plot(e["vel_x"][50],e["vel_y"][50],'r.')
                   plt.axis('scaled')
                   ax.set_aspect('equal')
                   # plt.plot(e["gaze_x"],e["gaze_y"],'o-')
                   count+=1
               
    #%% results summary
    dat = {'MSonset':[],
           'ampOfMS':[],
           'thetaOfMS':[],
           'sTimeOfMS':[]
           }
    for iTrial,ind_ms in enumerate(events):
        tmp1=[]
        tmp2=[]
        tmp3=[]
        empty = np.zeros(len(gazeX_deg[iTrial]))
        for ms in ind_ms:
            if ms["onset"]>0:
                empty[ms["onset"]] = 1
            tmp1.append(ms["amplitude"][-1])
            tmp2.append(ms["theta"])
            tmp3.append(ms["onset"])
        
        dat['sTimeOfMS'].append(empty.tolist())
        if len(tmp1) > 0:
            dat['ampOfMS'].append(np.mean(tmp1))
        else:
            dat['ampOfMS'].append(-1)
        
        if len(tmp2) > 0:
            dat['thetaOfMS'].append(np.mean(tmp2))
        else:
            dat['thetaOfMS'].append(-1)
        
        if len(tmp3) > 0:
            dat['MSonset'].append(np.mean(tmp3))
        else:
            dat['MSonset'].append(-1)
            
    # dat['dist'] = np.c_[np.array(test_distance_x),np.array(test_distance_y)]
    for iTrial,ind_ms in enumerate(events):
        for mm in ["gaze_x","gaze_y","vel_x","vel_y"]:
            for ms in ind_ms:
                    if not isinstance(ms[mm],list):
                        ms[mm] = ms[mm].tolist()
   
    return events,dat,int(fs)
