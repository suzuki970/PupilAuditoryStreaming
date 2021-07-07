#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  3 16:15:28 2021

@author: yutasuzuki
"""

import numpy as np
import seaborn as sns
import pandas as pd
from matplotlib import pyplot as plt
from pylab import rcParams
from scipy import stats
import json
import os

def corr_sig(df=None):
    p_matrix = np.zeros(shape=(df.shape[1],df.shape[1]))
    for col in df.columns:
        for col2 in df.drop(col,axis=1).columns:
            _ , p = stats.pearsonr(df[col],df[col2])
            p_matrix[df.columns.to_list().index(col),df.columns.to_list().index(col2)] = p
    return p_matrix


data = pd.read_pickle('./train_data.pkl')

data['numOfSwitch'][data['numOfSwitch'] > 1] = 2
data = data.groupby(['numOfSwitch','sub'],as_index=False)
data = data.mean()
data = data.drop(['sub'], axis=1)
data = data.drop(['ampOfSaccade'], axis=1)
data = data.drop(['numOfSaccade'], axis=1)

corr = data.corr()
p_values = corr_sig(data)

rcParams['figure.figsize'] = 14,12
sns.set(color_codes=True, font_scale=1.2)

mask = np.triu(np.ones_like(corr, dtype=np.bool))

ax = sns.heatmap(
    corr, 
    vmin=-1, vmax=1, center=0,
    mask=mask,
    # cmap=sns.diverging_palette(20, 220, n=200),
    cmap=sns.color_palette("coolwarm", as_cmap=True),
    square=True, annot=True
)

ax.set_xticklabels(
    ax.get_xticklabels(),
    rotation=45,
    horizontalalignment='right'
)

# plt.savefig('simple_heatmap.pdf')
plt.show()

corr[mask==True] = 0
corr.to_json(os.path.join("./corr2.json"))

p_values = pd.DataFrame(p_values)
p_values[mask==True] = 1
p_values.to_json(os.path.join("./p_values2.json"))
