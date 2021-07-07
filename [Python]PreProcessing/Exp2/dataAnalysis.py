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
# 'THRES_DIFF':0.3 
}
# saveFileLocs = '/Users/yuta/Desktop/e1_endogenous_Switching/'
saveFileLocs = 'data/'
# saveFileLocs = '/Users/yuta/Desktop/Pxx_auditoryIllusion/e1_endogenous_Switching/'

# f = open(os.path.join(str(saveFileLocs + 'data_original_normalized.json')))
f = open(os.path.join(str(saveFileLocs + 'data_original20210409.json')))
# f = open(os.path.join(str(saveFileLocs + 'data_original.json')))
dat = json.load(f)
f.close()

rejectFlag = dat['rejectFlag']

original_numOfTrial = []                      
for iSub in np.arange(1,max(dat['sub'])+1):
    ind = [i for i,sub in enumerate(dat['sub']) if sub == iSub ]
    original_numOfTrial.append(len(ind))

tmp_base = np.array(dat['RT'])
tmp_base = tmp_base.reshape(len(tmp_base),1)

cfg['WID_BASELINE'] = np.concatenate([-tmp_base-1,-tmp_base], 1)

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
tmp_rejectNum = np.argwhere(switch == -1).reshape(-1)

################## artifact rejection ##########################
y,rejectNum = pre_processing(np.array(dat['PDR_baseline'].copy()),cfg)
mmName = list(dat.keys())

rejectNum = np.r_[rejectNum,tmp_rejectNum]
rejectNum = np.unique(rejectNum)

for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNum]
 
y = np.delete(y,rejectNum,axis=0)

################## PCA ##########################
# pca_x,pca_y,rejectNumPCA = rejectBlink_PCA(y)
# y = np.delete(y,rejectNumPCA,axis=0)
# for mm in mmName:
#     dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectNumPCA]

################## rejection of outlier ##########################
max_val = [max(abs(y[i,])) for i in np.arange(y.shape[0])]
fx = np.diff(y)
rejectOutlier = []
for i in np.arange(len(y)):
    if len(np.unique(np.round(fx[i,],5))) < 20:
        rejectOutlier.append(i)
    
    # if max(abs(y[i,])) > np.std(max_val)*3:
    #     rejectOutlier.append(i)

y = np.delete(y,rejectOutlier,axis=0)
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectOutlier]

################## blink and saccade ##########################
ind_baseline = [rt*cfg['SAMPLING_RATE'] for rt in dat['RT']]
d_bk=[]
d_sc=[]
for i,(bk,sc) in enumerate(zip(dat['Blink'],dat['Saccade'])):
    d_bk.append([bk_data for bk_data in bk if int(bk_data) < ind_baseline[i]])
    d_sc.append([float(sc_data[1]) for sc_data in sc if int(sc_data[0]) < ind_baseline[i]])

dat['numOfBlink'] = [len(e) for e in d_bk]   
dat['ampOfSaccade'] = [np.mean(e) if len(e)>0 else 0 for e in d_sc]   
dat['numOfSaccade'] = [len(e) for e in d_sc]   

################## microsaccade ##########################
# gazeX = dat['gazeX'].copy()
# mSaccade = dat['mSaccade'].copy()

# tmp_data={'all':[],'positive':[],'negative':[]}
# rejectSaccade = {'all':[],'positive':[],'negative':[]}
# showMS={'all':[],'positive':[],'negative':[]}
# for i,ms in enumerate(mSaccade):
#     # ms_base = ms[0:int(ind_baseline[i])]
#     ms_base = ms
#     tmp = {'all':[],'positive':[],'negative':[]}
#     for i_ms,ms_data in enumerate(ms_base):
#         if ms_data != 0:
#             if len(gazeX[i][i_ms-50:i_ms+50]) == 100:
#                 tmp['all'].append(gazeX[i][i_ms-50:i_ms+50])
#                 # if ms_data > 0:
#                 #     tmp['positive'].append(gazeX[i][i_ms-50:i_ms+50])
#                 # else:
#                 #     tmp['negative'].append(gazeX[i][i_ms-50:i_ms+50])
                
#     for posneg in ['all']:
#     # for posneg in ['positive','negative']:
#         tmp_rejectNum=[]
#         tmp2 = np.array(tmp[posneg])
  
#         for iTrial in np.arange(tmp2.shape[0]):
#             if len(np.argwhere(abs(np.diff(tmp2[iTrial,:]))>5)) > 0:
#                 tmp_rejectNum.append(iTrial)
        
#         rejectSaccade[posneg].append(tmp_rejectNum)
#         showMS[posneg].append(np.delete(tmp2,tmp_rejectNum,axis=0))  
#         tmp_data[posneg].append(tmp[posneg])

# upsilon = []
# # plt.figure()
# for iSub in np.unique(dat['sub']):
#     ind = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
#     showMS2 = [ms for i,ms in enumerate(showMS['all']) if i in ind ]
#     showMS2 = np.array(list(itertools.chain.from_iterable(showMS2)))
    
#     # plt.subplot(5,5,iSub);plt.plot(showMS2.T)
#     # plt.subplot(1,3,2);plt.plot(np.diff(showMS2).T)
#     v = np.zeros((showMS2.shape[0],showMS2.shape[1]))        
#     for iTrial in np.arange(showMS2.shape[0]):
#         for i in np.arange(2,len(showMS2[iTrial,:])-2):
#             v[iTrial,i] = (showMS2[iTrial,i+2]+showMS2[iTrial,i+1]-showMS2[iTrial,i-2]-showMS2[iTrial,i-1])
    
#     # tmp_v = v.reshape(-1)
#     # plt.hist(tmp_v,bins=100)
#     sigma_m = np.nanstd(v)
#     ramda = 1
#     upsilon.append(ramda*sigma_m)
    
# rejectSaccade['vel']=[]
# t=[]
# for i,ms in enumerate(tmp_data['all']):
#     tmp_upsilon = upsilon[int(dat['sub'][i]-1)]
#     tmp_reject=[]
#     if len(ms) > 0:
#         for iTrial in np.arange(len(ms)):
#             d = np.array(ms[iTrial])
#             v = np.zeros(d.shape[0])    
#             for i in np.arange(2,len(d)-2):
#                 v[i] = (d[i+2]+d[i+1]-d[i-2]-d[i-1])
#             t.append(max(abs(v)))   
#             if max(abs(v)) < tmp_upsilon:               
#                   tmp_reject.append(iTrial)
#     rejectSaccade['vel'].append(tmp_reject)
  
# d_ms=[]
# for i,(ms,r1,r2) in enumerate(zip(mSaccade,rejectSaccade['all'],rejectSaccade['vel'])):
#     # ms_base = ms[0:int(ind_baseline[i])]
#     ms_base = ms
#     d = []
#     for i_ms,ms_data in enumerate(ms_base):
#         if ms_data != 0:
#             if len(gazeX[i][i_ms-50:i_ms+50]) == 100:
#                 d.append(pixel2angle(0.282,ms_data*1000,70))
#                 # d.append(ms_data)
#     r = r1.copy()
#     r.extend(r2)
#     r = np.unique(r)
#     if len(r)>0:
#         d_ms.append(np.delete(d,r))
#     else:
#         d_ms.append(np.array(d))
    
#     tmp_data['all'][i] = [d for ii,d in enumerate(tmp_data['all'][i]) if not ii in r]

# # plt.figure()
# # for iSub in np.unique(dat['sub']):
# #     ind = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
# #     showMS2 = [ms for i,ms in enumerate(tmp_data['all']) if i in ind ]
# #     showMS2 = np.array(list(itertools.chain.from_iterable(showMS2)))

# #     plt.subplot(5,5,iSub);plt.plot(np.diff(showMS2).T)

# dat['numOfmSaccade'] = [len(e) for e in d_ms]
# dat['ampOfmSaccade'] = [np.mean(e) if len(e) > 0 else 0 for e in d_ms]


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

if len(rejectNAN) > 0:
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
    ind0 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['responses'])==0))
    ind1 = np.argwhere((np.array(dat['sub'])==iSub) & (np.array(dat['responses'])==1))
    ind = np.argwhere((np.array(dat['sub'])==iSub))
    
    numOftrials.append(len(ind0)+len(ind1))
    numOftrials_res.append([len(ind0),len(ind1)])
    
    # if min(numOftrials_res[iSub-1]) < (len(ind0)+len(ind1)) * 0.2:
    #         reject.append(iSub)
    if (len(ind0)+len(ind1)) < NUM_TRIAL * 0.4:
            reject.append(iSub)

reject = np.unique(reject)
# print('# of trials = ' + str(numOftrials))

rejectSub = [i for i,d in enumerate(dat['sub']) if d in reject]
print('rejected subject = ' + str(reject))
y = np.delete(y,rejectSub,axis=0)  
for mm in mmName:
    dat[mm] = [d for i,d in enumerate(dat[mm]) if not i in rejectSub]

original_numOfTrial = [d for i,d in enumerate(original_numOfTrial) if not i in reject]
numOftrials = [d for i,d in enumerate(numOftrials) if not i+1 in reject]
ave = np.array(original_numOfTrial)-np.array(numOftrials)
ave = 1-(np.array(numOftrials)/np.array(original_numOfTrial))

print('rejected num ave = ' + str(round(np.mean(ave),3)) + ', sd = ' + str(round(np.std(ave),3)))

################## Tertile ##########################
diam = np.array(dat['PDR'].copy())
diam = np.mean(diam[:,-1000:],axis=1).reshape(len(diam),1)

dat['PDR_size'] = [np.mean(p) for p in diam.tolist()]

dat['tertile'] = []
res = np.array(dat['responses'].copy())

for iSub in np.arange(1,max(dat['sub'])+1):
    ind_sub = np.argwhere(np.array(dat['sub']) == iSub).reshape(-1)
    
    tmp_res = res[ind_sub].copy()
    tmp_PDR = diam[ind_sub,].copy()
     
    aftSort = np.argsort(np.mean(tmp_PDR,axis=1))
    
    res[ind_sub] = tmp_res[aftSort].copy()    
    diam[ind_sub,] = tmp_PDR[aftSort,].copy()
    
    x = list(split_list(tmp_PDR.tolist(),5))
    for i,xVal in enumerate(x):
        dat['tertile'] = np.r_[dat['tertile'],np.ones(len(xVal))*(i+1)]

dat['responses_sorted'] = res.tolist()

plt.figure()
for i in np.arange(1,6):
    ind = np.argwhere(np.array(dat['tertile']) == i).reshape(-1)
    yy = [s for i,s in enumerate(dat['responses_sorted']) if i in ind]
    plt.plot(i,np.mean(yy),'o')

plt.figure(figsize=(10.0, 6.5))
plt.rcParams["font.size"] = 28
plt.rcParams["font.family"] = "Times New Roman"
plt.title('Pupil size around task response',fontsize=30)
x = np.linspace(cfg['TIME_START'],cfg['TIME_END'],np.array(dat['PDR_baseline']).shape[1])
ind = np.argwhere(np.array(dat['responses']) == 0).reshape(-1)
plt.plot(x,np.mean(np.array(dat['PDR_baseline'])[ind,:],axis=0),label="unswitched")
plt.plot(x,np.mean(np.array(dat['PDR_baseline']),axis=0))

ind = np.argwhere(np.array(dat['responses']) == 1).reshape(-1)
plt.plot(x,np.mean(np.array(dat['PDR_baseline'])[ind,:],axis=0),label="switched")
plt.legend()

# # plt.subplot(1,2,2)
# plt.vlines(-np.mean(np.array(dat['RT'])), -0.5, 0.5, "black", linestyles='dashed')
# # plt.vlines(cfg['WID_BASELINE'][0], -0.5, 0.5, "red", linestyles='dashed')
# # plt.vlines(cfg['WID_BASELINE'][1], -0.5, 0.5, "red", linestyles='dashed')
# plt.ylim(-0.5,0.2)
# plt.ylabel('Pupil size [z-scored]')
# plt.xlabel('Time [sec]')

# 
# plt.savefig(saveFileLocs+"pupilRes.pdf")

################# trial number ##########################
dat['numOfTrial'] = np.zeros(y.shape[0])
for iSub in np.arange(1,max(dat['sub'])+1):
      for i in np.arange(2):
          ind = np.argwhere((dat['responses'] == i) & 
                            (dat['sub'] == iSub)).reshape(-1)
          dat['numOfTrial'][ind] = np.arange(len(ind))+1

dat['numOfTrial'] = dat['numOfTrial'].tolist()

################## PCA ##########################
# ave = np.mean(y,axis=0)
# pca = PCA(n_components=4).fit(y)
# loadings = pca.components_  # Eigenvector
# var_ratio = pca.explained_variance_ratio_
# plt.figure()
# for i in np.arange(4):
#   plt.plot(x,loadings[i,],label=round(var_ratio[i],3))
# plt.legend()

################## velocity ##########################

dat['PDRder'] = re_sampling(dat['PDR'],30).tolist()
dat['PDRder'] = (np.diff(dat['PDRder'])*(30/4)).tolist()


################## Data plot ##########################
# plt.figure(figsize=(12, 15))
# plt.rcParams["font.size"] = 18
# conditionName = ['no switch','switch' ]
# lineCol = ['k','r']
# for iSub in np.arange(1,max(dat['sub'])+1):
#     plt.subplot(round(max(dat['sub'])/2)+1,2,iSub)
    
#     for iAns in np.arange(2):
#         ind = [i for i,c in enumerate(dat['condition_frame']) if dat['sub'][i] == iSub and c == iAns]
#         if len(ind) > 0:
#             plt.plot(y[ind].T,alpha=0.1)
#             plt.plot(np.mean(y[ind],axis=0), color=lineCol[iAns], label = conditionName[iAns])
        
#     # plt.xlim([0,cfg['TIME_END']])
#     # plt.ylim([-cfg['THRES_DIFF'] ,cfg['THRES_DIFF'] ])
#     plt.xlabel('Time from response queue')
# plt.legend()

# x = np.linspace(cfg['TIME_START'],cfg['TIME_END'],y.shape[1]-1)
# plt.figure(figsize=(12, 6))
# plt.rcParams["font.size"] = 18
# plt.subplot(1,2,1)
# plt.plot(x,np.diff(y).T)
# plt.xlim([cfg['TIME_START'],cfg['TIME_END']])
# plt.ylim([-cfg['THRES_DIFF'] ,cfg['THRES_DIFF'] ])
# plt.xlabel('Time from response queue')

# x = np.linspace(cfg['TIME_START'],cfg['TIME_END'],y.shape[1])
# plt.subplot(1,2,2)
# plt.plot(x,y.T)
# plt.xlim([cfg['TIME_START'],cfg['TIME_END']])
# plt.xlabel('Time from response queue')
# plt.ylabel('Changes in pupil size')

dat['PDR_size_sorted'] = [np.mean(p) for p in diam.tolist()]
dat['PDR'] = re_sampling(y,(cfg['TIME_END']-cfg['TIME_START'])*100).tolist()

dat['PDR_baseline'] = re_sampling(np.array(dat['PDR_baseline']),
                                  (cfg['TIME_END']-cfg['TIME_START'])*100).tolist()
mmName = list(dat.keys())
for mm in mmName:
    if not isinstance(dat[mm],list):
        dat[mm] = dat[mm].tolist()
        
A = []
B = []
for iSub in np.unique(np.array(dat['sub'])):
    ind = np.argwhere((np.array(dat['responses']) == 0) & 
                      (np.array(dat['sub']) == iSub)).reshape(-1)
    A.append(np.mean(np.array(dat['PDR_size'])[ind]))
    
    ind = np.argwhere((np.array(dat['responses']) == 1) & 
                      (np.array(dat['sub']) == iSub)).reshape(-1)
    B.append(np.mean(np.array(dat['PDR_size'])[ind]))
         
from scipy import stats
print(stats.ttest_rel(np.array(A), np.array(B)))


################## Data save ##########################
with open(os.path.join(saveFileLocs+"data20210610.json"),"w") as f:
        json.dump(dat,f)
        