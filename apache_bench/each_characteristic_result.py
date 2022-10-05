import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

#データをインポート
file_path = "./output/return_time_from_SPARQLendpoint/20221004161613.csv"
df = pd.read_csv(file_path)
# print(df.columns.values)

for e in df.columns.values[2:]: #トリプル数以降でfor文を回す
    df[["endpoint_url",e]].plot()
    plt.xticks(np.array(df.index), np.array(df["triple_num"])) 
    plt.xlabel("triple num")
    plt.ylabel("return time(s)")
    plt.savefig(f"./output/each_characteristic_result/{e}.png")