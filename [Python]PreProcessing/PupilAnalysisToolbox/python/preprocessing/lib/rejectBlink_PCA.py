"""
Input:    
y   - vector array of data (N trials x time series)

Output:
values     - principal components
rejctNum   - dreject trial(s) based on PCA

Example:
    pc,rejectNumPCA = rejectBlink_PCA(y)
"""

import numpy as np
#import sklearn
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def rejectBlink_PCA(y):
    
    # cov_matrix = np.cov(y, rowvar=False)
    
    # l, v = np.linalg.eig(cov_matrix)
    # l = abs(l)
    # v = abs(v)
    
    # l_index = np.argsort(l)[::-1]
    # l_ = l[l_index]
    # v_ = v[:, l_index] 
    # data_trans = np.dot(y, v_)
    # data_trans = abs(data_trans)
    
    # vec_s = [0, 0]
    # vec_1st_e = [2*v[0, 0], 2*v[0, 1]]
    # vec_2nd_e = [2*v[1, 0], 2*v[1, 1]]
   
    # plt.figure(figsize=[8, 8])
    # plt.xlim(-4, 4)
    # plt.ylim(-4, 4)
    # plt.quiver(vec_s[0], vec_s[1], vec_1st_e[0], vec_1st_e[1],
    #            angles='xy', scale_units='xy', scale=1, color='r', label='1st')
    # plt.quiver(vec_s[0], vec_s[1], vec_2nd_e[0], vec_2nd_e[1],
    #            angles='xy', scale_units='xy', scale=1, color='b', label='2nd')
    # plt.grid()
    # plt.legend()
    # # plt.scatter(y[:, 0], y[:, 1])
    # plt.xlim([-0.1,0.1])
    # plt.ylim([-0.1,0.1])
    
    ## calcurating average and standard deviation
#    ave = np.mean(y, axis=1)
    # stdVal = np.std(y, axis=1)
    # stdVal = stdVal ** 2

    ## PCA analysis
    pca = PCA(n_components=2).fit(y)
    values = pca.transform(y)
    # pca.components_
    #    plt.plot(values[:,0],values[:,1],'.')
#    plt.xlim(-50,50)
#    plt.ylim(-50,50)
#    
    stdX = np.std(values[:,0])*3
    stdY = np.std(values[:,1])*3

     ## caluclation Euclidean distance from the center of whole value
    a = stdX**2
    b = stdY**2
    
    x = values[:,0]**2
    y = values[:,1]**2
    
    P = (x/a)+(y/b)-1
    
    rejctNum = np.argwhere(P > 0)
    
    fig = plt.figure()
    ax = plt.axes()
    
    # fc = face color, ec = edge color
    e = patches.Ellipse(xy=(0,0), width=stdX*2, height=stdY*2, fill=False, ec='r')
    ax.add_patch(e)
    plt.plot(values[:,0],values[:,1],'.')
    plt.plot(values[rejctNum,0],values[rejctNum,1],'r.')
    plt.axis('scaled')
    ax.set_aspect('equal')
   # rejctNum = np.argwhere(abs(values[:,0]) > stdX*2)
    # rejctNum = np.r_[rejctNum,np.argwhere(abs(values[:,1]) > stdY*2)]
    
    # rejctNum = np.unique(rejctNum)
    
    return values,rejctNum
    # ## plotting first and second CP    
#    averageX=mean(score(arange(),1))
#    averageY=mean(score(arange(),2))
#    stdX=std(score(arange(),1),[],1)
#    stdY=std(score(arange(),2),[],1)

    # ellipsoid(0,0,0,stdX*3,stdY*3,0,50);hold on
# figure;
# plot(score(:,1),score(:,2),'.','MarkerSize',10);hold on
# title(['Transformed data']);
# xlabel('PC1');
# ylabel('PC2');

# viscircles([averageX averageY],stdX*2)
# set(gca,'FontName','Times New Roman','FontSize',14);
# axis equal;
# box on;
    
   