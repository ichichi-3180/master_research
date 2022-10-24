import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import json
import matplotlib.patches as patches

#データをインポート
file_path = "../output/response_time/"
input_file_name = "20221023021835_remote_10times.json"

response_time_each_endpoint = json.load(open(file_path+input_file_name, 'r'))

df_content = []
df_column = ["server_type", "label", "rdf_store", "url", "graph_uri", "triple_num"]
query_types = [each_query.get('query_type') for each_query in response_time_each_endpoint[0]["benchmark_query_result"]]
df_column.extend(query_types)

for endpoint in response_time_each_endpoint:
    # print(response_time["benchmark_query_result"])
    endpoint_result = [endpoint["server_type"], endpoint["label"], endpoint["rdf_store"], endpoint["url"],endpoint["graph_uri"], endpoint["triple_num"]]
    for each_query_response_time in endpoint["benchmark_query_result"]:
        endpoint_result.append(each_query_response_time["response_time"]["avg_all_session"]) #タイムアウトが一件もなかった時の平均応答時間
    df_content.append(endpoint_result)


#pandasのオブジェクトとして利用
df = pd.DataFrame(df_content,columns=df_column)
#トリプル数順でソート
df = df.sort_values('triple_num')
#ソート後にインデックスを降り直す
df = df.reset_index()
triple_num_label = df["triple_num"]

for e in df.columns.values[6:]: #トリプル数以降でfor文を回す
    ms = df[e]
    fig,ax = plt.subplots()
    ax.bar(np.array(df.index), np.array(ms), width=0.4)
    ax.set_title(e)
    ax.set_xticks(np.array(df[e].index))

    #x軸のラベルを作成
    xlabel = np.core.defchararray.add(
        np.core.defchararray.add(
            np.array(df["label"],dtype=str),
            np.full(len(df.index), '\n', dtype=str)
        ),
        np.array(ms.round(2),dtype=str) #表示の桁数指定
    )
    ax.set_xticklabels(xlabel)
    ax.tick_params(labelsize=5)

    #TO DO 欠損値(NaN)の時に表示色変えたい. 現在はx軸のラベルに実際の値を格納することで対処
    # xmin, xmax, ymin, ymax = plt.axis()
    # xy = (xmin, ymin)
    # width = xmax - xmin
    # height = ymax - ymin
    # p = patches.Rectangle(xy, width, height, fill=True, color='lightgray', zorder=-10)
    # ax.add_patch(p)
    
    if not os.path.exists("../output/bar/" + input_file_name):
        os.makedirs("../output/bar/" + input_file_name)
    fig.savefig("../output/bar/" + input_file_name + "/" + e + ".png")