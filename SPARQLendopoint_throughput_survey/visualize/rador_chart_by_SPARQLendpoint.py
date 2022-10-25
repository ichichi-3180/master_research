import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import json
import urllib.parse

#データをインポート
file_path = "../output/response_time/"
input_file_name = "20221025012201_local_fuseki_4.6.1"

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

for index, row in df.iterrows():
    print(row["label"])
    labels = row[7:].keys()
    values = row[7:].values
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

    #表示するラベルを作成
    query_labels = labels.to_list()
    time_labels = row[7:].values.tolist()
    for i in range(len(query_labels)):
        query_labels[i] += "\n" + str(round(time_labels[i],2))
    
    # 項目ラベルの表示
    ax.set_thetagrids(angles[:-1] * 180 / np.pi, query_labels)
    # 始点を上(北)に変更
    ax.set_theta_zero_location("N")
    # 時計回りに変更(デフォルトの逆回り)
    ax.set_theta_direction(-1)

    ax.set_title(row["label"] + ":" + str(int(row["triple_num"])) +"triples")
    
    output_path = "../output/rador_chart/by_SPARQLendpoint/" + input_file_name 
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    fig.savefig(output_path + "/" + row["label"] + ".png")
