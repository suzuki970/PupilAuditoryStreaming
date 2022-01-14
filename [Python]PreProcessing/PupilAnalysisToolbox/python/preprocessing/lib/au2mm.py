#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct  7 16:52:13 2020

@author: yuta
"""

import numpy as np
import glob
import os

def au2mm(visDist):

    fileName = glob.glob(os.path.dirname(os.path.realpath(__file__)) + "/au2mm/data/" + str(visDist) + "/asc/*")
    fileName.sort()
    
    datHash = {}
    for n in [6,8]:
        datHash[str(n)] = []
        
    for file in fileName:
        
        f = open(os.path.join(str(file)))
    
        dat=[]
        for line in f.readlines():
            dat.append(line.split())
            
        f.close()
        
        tmp = []
        for i,line in enumerate(dat):
            if i > 30:
                if line[0].isdecimal():
                    tmp.append(float(line[3]))
       
        datHash[file.split('/')[-1][-7:-6]] .append(tmp[5000:10000])
            
    
    mmName = list(datHash.keys())
    
    dat = []
    for mm in mmName:
        for d in datHash[mm]:
            dat.append( int(mm) / np.sqrt(np.mean(d) ))
        
    return np.mean(dat)
