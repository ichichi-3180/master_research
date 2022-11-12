import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import json
import matplotlib.patches as patches

#データをインポート
file_path = "../output/response_time/"
input_file_name = "20221026174420_remote"

response_time_each_endpoint = json.load(open(file_path+input_file_name+'.json', 'r'))

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
# print(df.index)
for index, row in df.iterrows():
    print(index)
    fig, ax = plt.subplots()
    print(row)
    print('\n')
    query_type_result = row[7:].sort_values()
    print(np.array(query_type_result.index))
    print(np.array(query_type_result))
    ax.bar(np.array(query_type_result.index), np.array(query_type_result))
    ax.set_title(row['label'])
    ax.set_xticks(np.array(query_type_result.index))
    ax.tick_params(labelsize=8)
    plt.xticks(rotation=90)
    plt.tight_layout()
    # ax.barh(np.array(query_type_result.index), np.array(query_type_result))

    if not os.path.exists("../output/bar/by_SPARQLendpoint/" + input_file_name):
        os.makedirs("../output/bar/by_SPARQLendpoint/" + input_file_name)
    fig.savefig("../output/bar/by_SPARQLendpoint/" + input_file_name + "/" + row['label'] + ".png")


