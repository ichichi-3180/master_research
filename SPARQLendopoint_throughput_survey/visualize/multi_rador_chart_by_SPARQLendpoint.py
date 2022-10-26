import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import json
import pprint

#データをインポート
file_path = "../output/response_time/"
input_file_name_1 = "20221024233356_local_virtuoso"
input_file_name_2 = "20221025012201_local_fuseki_4.6.1"

response_time_each_endpoint_1 = json.load(open(file_path+input_file_name_1+'.json', 'r'))
response_time_each_endpoint_2 = json.load(open(file_path+input_file_name_2+'.json', 'r'))

#inputの要素を比較、少ない方に合わせる(実験結果のSPARQLエンドポイントの数)
endpoint1_label_list = []
endpoint2_label_list = []
for endpoint1 in response_time_each_endpoint_1:
    endpoint1_label_list.append(endpoint1["label"])
for endpoint2 in response_time_each_endpoint_2:
    endpoint2_label_list.append(endpoint2["label"])

endpoint1_remove_list=[]
for endpoint1 in response_time_each_endpoint_1:
    if not endpoint1["label"] in endpoint2_label_list:
        endpoint1_remove_list.append(endpoint1)

endpoint2_remove_list=[]
for endpoint2 in response_time_each_endpoint_2:
    if not endpoint2["label"] in endpoint1_label_list:
        endpoint2_remove_list.append(endpoint2)

for endpoint1_remove in endpoint1_remove_list:
    response_time_each_endpoint_1.remove(endpoint1_remove)
for endpoint2_remove in endpoint2_remove_list:
    response_time_each_endpoint_2.remove(endpoint2_remove)

#順番が合うようにトリプル数でソート
response_time_each_endpoint_1 = sorted(response_time_each_endpoint_1, key=lambda x: x['triple_num'], reverse=True)
response_time_each_endpoint_2 = sorted(response_time_each_endpoint_2, key=lambda x: x['triple_num'], reverse=True)


#出力用のラベルを用意
output_labels = []
for endpoint1 in response_time_each_endpoint_1:
    for query_result in endpoint1["benchmark_query_result"]:
        if not query_result["query_type"] in output_labels:
            output_labels.append(query_result["query_type"])


def multi_json_to_data_per_SPARQLendpoint(json1, json2):
    return_dict = {}
    for endpoint in json1:
        # print(endpoint)
        if not endpoint["label"] in return_dict.keys():
            return_dict[endpoint["label"]] = {}
        if not endpoint["rdf_store"] in return_dict[endpoint["label"]].keys():
            return_dict[endpoint["label"]][endpoint["rdf_store"]] = []
        for query_result in endpoint["benchmark_query_result"]:
            return_dict[endpoint["label"]][endpoint["rdf_store"]].append(query_result["response_time"]["avg_all_session"])

    for endpoint in json2:
        # print(endpoint)
        if not endpoint["label"] in return_dict.keys():
            return_dict[endpoint["label"]] = {}
        if not endpoint["rdf_store"] in return_dict[endpoint["label"]].keys():
            return_dict[endpoint["label"]][endpoint["rdf_store"]] = []
        for query_result in endpoint["benchmark_query_result"]:
            return_dict[endpoint["label"]][endpoint["rdf_store"]].append(query_result["response_time"]["avg_all_session"])

    return return_dict

data_per_SPARQLendpoint =  multi_json_to_data_per_SPARQLendpoint(response_time_each_endpoint_1, response_time_each_endpoint_2)

for endpoint in data_per_SPARQLendpoint:
    print(endpoint)
    data = data_per_SPARQLendpoint[endpoint]
    df = pd.DataFrame(data, index=output_labels)
    
    columns = df.index
    
    rdf_store_list = list(data.keys())
    angles_A = np.linspace(start=0, stop=2*np.pi, num=len(df[rdf_store_list[0]])+1, endpoint=True)
    values_A = np.concatenate((df[rdf_store_list[0]], [df[rdf_store_list[0]][0]]))
    angles_B = np.linspace(start=0, stop=2*np.pi, num=len(df[rdf_store_list[1]])+1, endpoint=True)
    values_B = np.concatenate((df[rdf_store_list[1]], [df[rdf_store_list[1]][0]]))

    fig, ax = plt.subplots(1, 1, figsize=(20, 24), subplot_kw={'projection': 'polar'},tight_layout=True)
    ax.plot(angles_A, values_A, 'o-', color="blue", label=rdf_store_list[0])
    ax.plot(angles_B, values_B, 'o-', color="red", label=rdf_store_list[1])
    ax.fill(angles_A, values_A, alpha=0.3, color="blue")
    ax.fill(angles_B, values_B, alpha=0.3, color="red")
    ax.set_thetagrids(angles_A[:-1] * 180 / np.pi, df.index, fontsize=30)
    ax.set_theta_zero_location('N')
    ax.set_thetagrids(angles_B[:-1] * 180 / np.pi, df.index, fontsize=30)
    ax.set_theta_zero_location('N')
    gridlines = ax.yaxis.get_gridlines()
    ax.set_title(endpoint, fontsize=40)
    ax.legend(bbox_to_anchor=(1, 1), loc='upper right', ncol=2, fontsize=30)
    if not os.path.exists("../output/rador_chart/by_SPARQLendpoint/" + input_file_name_1 +"_" +  input_file_name_2):
        os.makedirs("../output/rador_chart/by_SPARQLendpoint/" + input_file_name_1 +"_"+ input_file_name_2)
    fig.savefig("../output/rador_chart/by_SPARQLendpoint/" + input_file_name_1 + "_" + input_file_name_2+ "/" + endpoint + ".png")