import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

#データをインポート
file_path = "./output/return_time_from_SPARQLendpoint/"
input_file_name_1 = "20221013090645_mean10times_local_fuseki"
input_file_name_2 = "20221012155250_mean10times_local_virtuoso"
df_1 = pd.read_csv(file_path + input_file_name_1 + ".csv")
df_2 = pd.read_csv(file_path + input_file_name_2 + ".csv")

#トリプル数順でソート
df_1 = df_1.sort_values('triple_num')
df_2 = df_2.sort_values('triple_num')

#ソート後にインデックスを降り直す
df_1 = df_1.reset_index()
df_2 = df_2.reset_index()

triple_num_label = df_1["triple_num"]

#x軸のラベルの作成(SPARQLエンドポイントのURLのドメイン名とトリプル数)
xlabel = np.core.defchararray.add(
    np.core.defchararray.add(
        np.array(df_1["label"],dtype=str),
        np.full(len(df_1.index), '\n', dtype=str)
    ),
    np.array(triple_num_label,dtype=str)
)

for e in df_1.columns.values[7:]: #トリプル数以降でfor文を回す
    print(e)
    width_bar = 0.4
    x = np.array(df_1[e].index)
    x1 = x - width_bar/2
    x2 = x + width_bar/2
    
    y1 = np.array(df_1[e])
    y2 = np.array(df_2[e])
    plt.bar(x=x1,height=y1, tick_label=xlabel, width=width_bar,align="center")
    plt.bar(x=x2,height=y2, tick_label=xlabel, width=width_bar,align="center")
    plt.title(e)
    plt.tick_params(labelsize=5)
    plt.tight_layout()
    if not os.path.exists("./output/each_characteristic_result/" + input_file_name_1 + input_file_name_2):
        os.makedirs("./output/each_characteristic_result/" + input_file_name_1 + input_file_name_2)
    plt.savefig("./output/each_characteristic_result/" + input_file_name_1 + input_file_name_2 + "/" + e + ".png")
    #pltのメモリを解放するために以下を記述(無いとfor文の場合はpltが上書きされ続けた値が保存される)
    plt.clf()
    plt.close()

    # fig, ax = plt.subplots()
    # ax.bar(x=x1,height=y1, width=width_bar,align="center", label="1")
    # ax.bar(x=x2,height=y2, width=width_bar,align="center", label="2")
    # ax.set_xticks(x + 0.2)
    # ax.set_xticklabels(xlabel)
    # if not os.path.exists("./output/each_characteristic_result/" + input_file_name_1 + input_file_name_2):
    #     os.makedirs("./output/each_characteristic_result/" + input_file_name_1 + input_file_name_2)
    # fig.savefig("./output/each_characteristic_result/" + input_file_name_1 + input_file_name_2 + "/" + e + ".png")
    #pltのメモリを解放するために以下を記述(無いとfor文の場合はpltが上書きされ続けた値が保存される)
    # plt.clf()
    # plt.close()