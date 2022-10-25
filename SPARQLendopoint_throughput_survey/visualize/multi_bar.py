import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import json

#データをインポート
file_path = "../output/response_time/"
input_file_name_1 = "20221024233356_local_virtuoso"
input_file_name_2 = "20221025012201_local_fuseki_4.6.1"

response_time_each_endpoint_1 = json.load(open(file_path+input_file_name_1+'.json', 'r'))
response_time_each_endpoint_2 = json.load(open(file_path+input_file_name_2+'.json', 'r'))

df_column = ["server_type", "label", "rdf_store", "url", "graph_uri", "triple_num"]
query_types = [each_query.get('query_type') for each_query in response_time_each_endpoint_1[0]["benchmark_query_result"]]
df_column.extend(query_types)

#jsonファイルをグラフで表示するためのpandasのオブジェクトとして配置するメソッド
def json_to_DataFrame(response_time_each_endpoint):
    df_content = []
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

    return df

df_1 = json_to_DataFrame(response_time_each_endpoint_1)
df_2 = json_to_DataFrame(response_time_each_endpoint_2)

triple_num_label = df_1["triple_num"] #表示に利用するラベル

#x軸のラベルの作成(SPARQLエンドポイントのURLのドメイン名とトリプル数)
xlabel = np.core.defchararray.add(
    np.core.defchararray.add(
        np.array(df_1["label"],dtype=str),
        np.full(len(df_1.index), '\n', dtype=str)
    ),
    np.array(triple_num_label.astype('int'),dtype=str) #int型でキャストした後にstringに
)
for e in df_1.columns.values[7:]: #トリプル数以降でfor文を回す
    width_bar = 0.4
    x1_index = np.array(df_1[e].index)
    x2_index = np.array(df_2[e].index)
    x1 = x1_index-width_bar/2
    x2 = x2_index+width_bar/2
    
    y1 = np.array(df_1[e])
    y2 = np.array(df_2[e])

    fig,ax = plt.subplots()

    ax.bar(x1, y1, width=width_bar, label="virtuoso_4GB")
    ax.bar(x2, y2, width=width_bar, label="fuseki_4GB")
    ax.set_title(e)
    ax.set_xticks(x1_index)
    ax.set_xticklabels(xlabel)
    ax.tick_params(labelsize=5)
    ax.legend(loc='upper left')
    if not os.path.exists("../output/bar/" + input_file_name_1 +"_"+ input_file_name_2):
        os.makedirs("../output/bar/" + input_file_name_1 + "_"+ input_file_name_2)
    fig.savefig("../output/bar/" + input_file_name_1 + "_"+ input_file_name_2 + "/" + e + ".png")