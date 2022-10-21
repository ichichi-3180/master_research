#TO DO Endpointごとのcount, distinctなどの各特徴を頂点としたレーダーチャートをとりあえず作成してみる

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import urllib.parse
import os

#データをインポート

file_path = "../output/return_time_from_SPARQLendpoint/"
input_file_name = "20221005154419"
df = pd.read_csv(file_path + input_file_name + ".csv")

for index, row in df.iterrows():
    labels = row[2:].keys()
    values = row[2:].values
    angles =  np.linspace(start=0, stop=2*np.pi, num=len(values)+1, endpoint=True)
    values = np.concatenate((values, [values[0]]))

    rgrids = [0, 20, 40, 60, 80, 100]

    fig = plt.figure(facecolor="w")
    # 極座標でaxを作成。
    ax = fig.add_subplot(1, 1, 1, polar=True)
    # レーダーチャートの線を引く
    ax.plot(angles, values)
    #　レーダーチャートの内側を塗りつぶす
    ax.fill(angles, values, alpha=0.2)
    # 項目ラベルの表示
    ax.set_thetagrids(angles[:-1] * 180 / np.pi, labels)
    # # 円形の目盛線を消す
    # ax.set_rgrids([])
    # # 一番外側の円を消す
    # ax.spines['polar'].set_visible(False)
    # 始点を上(北)に変更
    ax.set_theta_zero_location("N")
    # 時計回りに変更(デフォルトの逆回り)
    ax.set_theta_direction(-1)
    # # ax.set_thetagrids(angles[:-1] * 180 / np.pi, labels, fontsize=15)

    # # 多角形の目盛線を引く
    # for grid_value in rgrids:
    #     grid_values = [grid_value] * (len(labels)+1)
    #     ax.plot(angles, grid_values, color="gray",  linewidth=0.5)

    # # メモリの値を表示する
    # for t in rgrids:
    #     # xが偏角、yが絶対値でテキストの表示場所が指定される
    #     ax.text(x=0, y=t, s=t)

    # # rの範囲を指定
    # ax.set_rlim([min(rgrids), max(rgrids)])

    ax.set_title(f"endpoint : {row['endpoint_url']}\ntriple_num : {row['triple_num']}", pad=0, loc='left', fontsize=10)

    file_name = urllib.parse.urlparse(row["endpoint_url"]).netloc + urllib.parse.urlparse(row["endpoint_url"]).path 
    file_name = file_name.replace("/", "_")
    output_path = "../output/rador_chart/" + input_file_name 
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    fig.savefig(output_path + "/" + file_name + ".png")