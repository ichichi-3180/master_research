import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

#データをインポート
file_path = "./output/return_time_from_SPARQLendpoint/"
input_file_name = "20221013090645_mean10times_local_fuseki"
df = pd.read_csv(file_path + input_file_name + ".csv")
#トリプル数順でソート
df = df.sort_values('triple_num')
#ソート後にインデックスを降り直す
df = df.reset_index()

triple_num_label = df["triple_num"]

#x軸のラベルの作成(SPARQLエンドポイントのURLのドメイン名とトリプル数)
xlabel = np.core.defchararray.add(
    np.core.defchararray.add(
        np.array(df["label"],dtype=str),
        np.full(len(df.index), '\n', dtype=str)
    ),
    np.array(triple_num_label,dtype=str)
)


for e in df.columns.values[5:]: #トリプル数以降でfor文を回す
    ms = df[e]
    print(ms)
    plt.bar(np.array(df.index), np.array(ms), tick_label=xlabel, align="center")
    plt.tick_params(labelsize=5)
    plt.title(e)
    plt.tight_layout()
    if not os.path.exists("./output/each_characteristic_result/" + input_file_name):
        os.makedirs("./output/each_characteristic_result/" + input_file_name)
    plt.savefig("./output/each_characteristic_result/" + input_file_name + "/" + e + ".png")
    #pltのメモリを解放するために以下を記述(無いとfor文の場合はpltが上書きされ続けた値が保存される)
    plt.clf()
    plt.close()