#TO DO Endpointごとのcount, distinctなどの各特徴を頂点としたレーダーチャートをとりあえず作成してみる

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

data = {
        'A': [100, 90, 80, 70, 60],
        'B': [60, 70, 80, 90, 100]
       }

df = pd.DataFrame(data, index=['Math', 'Science', 'Japanese', 'English', 'PE'])
print(df)
fig,ax = plt.subplots(1, 2, figsize=(20, 24), subplot_kw={'projection': 'polar'})

colors = ["red", "blue", "green"]

angles = []
values = []
for url in data:
    angles.append(np.linspace(start=0, stop=2*np.pi, num=len(df[url])+1, endpoint=True))
    values.append(np.concatenate((df[url], [df[url][0]])))
    
for i, url in enumerate(data.keys()):
    print(i, url)
    # angles =  np.linspace(start=0, stop=2*np.pi, num=len(df[url])+1, endpoint=True)
    # values = np.concatenate((df[url], [df[url][0]]))
    for av_i in range(len(angles)):
        ax[i].plot(angles[av_i], values[av_i], 'o-', color=colors[av_i], label=url)
        ax[i].fill(angles[av_i], values[av_i], alpha=0.3, color=colors[av_i])

        columns = df.index

        #各頂点に名前を設定[iに頂点のindexが格納],頂点(MATH)を北側に 
        ax[i].set_thetagrids(angles[av_i][:-1] * 180 / np.pi, columns, fontsize=15)
        ax[i].set_theta_zero_location('N')

    #表示範囲の設定
    ax[i].set_rlim(50, 110)

    #タイトルと凡例の位置を指定
    ax[i].set_title(f"Sample {url}", fontsize=15)
    ax[i].legend(bbox_to_anchor=(1, 1), loc='upper right', ncol=2)

fig.savefig("../output/rador_chart/sample.png")