import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import json
import urllib.parse

#データをインポート
file_path = "../output/response_time/"
input_file_name = "20221024203010_local_fuseki"

response_time_each_endpoint = json.load(open(file_path+input_file_name+".json", 'r'))
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

for e in df.columns.values[7:]:
    # print(df[e])
    angles =  np.linspace(start=0, stop=2*np.pi, num=len(df[e])+1, endpoint=True)
    values = np.concatenate((df[e], [df[e][0]]))

    rgrids = [0, 20, 40, 60, 80, 100]

    fig = plt.figure(facecolor="w")
    # 極座標でaxを作成。
    ax = fig.add_subplot(1, 1, 1, polar=True)
    # レーダーチャートの線を引く
    ax.plot(angles, values)
    #　レーダーチャートの内側を塗りつぶす
    ax.fill(angles, values, alpha=0.2)
    label = np.core.defchararray.add(
        np.core.defchararray.add(
            np.array(df["label"],dtype=str),
            np.full(len(df.index), '\n', dtype=str)
        ),
        np.array(df[e].round(2),dtype=str) #表示の桁数指定
    )
    # 項目ラベルの表示
    ax.set_thetagrids(angles[:-1] * 180 / np.pi, label)
    # 始点を上(北)に変更
    ax.set_theta_zero_location("N")
    # 時計回りに変更(デフォルトの逆回り)
    ax.set_theta_direction(-1)

    ax.set_title(e)

    output_path = "../output/rador_chart/by_querytype/" + input_file_name 
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    fig.savefig(output_path + "/" + e + ".png")