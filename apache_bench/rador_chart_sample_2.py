import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

data = {
        'A': [100, 90, 80, 70, 60],
        'B': [60, 70, 80, 90, 100]
}

df = pd.DataFrame(data, index=['Math', 'Science', 'Japanese', 'English', 'PE'])

angles_A = np.linspace(start=0, stop=2*np.pi, num=len(df["A"])+1, endpoint=True)
values_A = np.concatenate((df["A"], [df["A"][0]]))
angles_B = np.linspace(start=0, stop=2*np.pi, num=len(df["B"])+1, endpoint=True)
values_B = np.concatenate((df["B"], [df["B"][0]]))

fig, ax = plt.subplots(1, 2, figsize=(20, 24), subplot_kw={'projection': 'polar'})
for i, label in enumerate(df.columns):

    #塗りつぶし
    ax[i].plot(angles_A, values_A, 'o-', color="blue", label="A")
    ax[i].fill(angles_A, values_A, alpha=0.3, color="blue")
    ax[i].plot(angles_B, values_B, 'o-', color="red", label="B")
    ax[i].fill(angles_B, values_B, alpha=0.3, color="red")

    columns = df.index

    #各頂点に名前を設定[iに頂点のindexが格納],頂点(MATH)を北側に 
    ax[i].set_thetagrids(angles_A[:-1] * 180 / np.pi, columns, fontsize=15)
    ax[i].set_theta_zero_location('N')

    #表示範囲の設定
    ax[i].set_rlim(50, 110)

    #グリッドラインの設定(2つ目の要素が80点のため、そこにグリッドラインが引かれる)
    gridlines = ax[i].yaxis.get_gridlines()
    gridlines[2].set_color("black")
    gridlines[2].set_linewidth(2)
    gridlines[2].set_linestyle("--")

    #タイトルと凡例の位置を指定
    ax[i].set_title(f"Sample {label}", fontsize=15)
    ax[i].legend(bbox_to_anchor=(1, 1), loc='upper right', ncol=2)
    

fig.savefig("./output/rador_chart/sample2_A.png")