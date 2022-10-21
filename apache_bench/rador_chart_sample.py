import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

data = {'A': [100, 90, 80, 70, 60],
        'B': [60, 70, 80, 90, 100]
       }
df = pd.DataFrame(data, index=['Math', 'Science', 'Japanese', 'English', 'PE'])

angles_A = np.linspace(start=0, stop=2*np.pi, num=len(df["A"])+1, endpoint=True)
values_A = np.concatenate((df["A"], [df["A"][0]]))
angles_B = np.linspace(start=0, stop=2*np.pi, num=len(df["B"])+1, endpoint=True)
values_B = np.concatenate((df["B"], [df["B"][0]]))

fig, ax = plt.subplots(1, 2, figsize=(20, 24), subplot_kw={'projection': 'polar'})
ax[0].plot(angles_A, values_A, 'o-', color="blue", label="A")
ax[1].plot(angles_B, values_B, 'o-', color="blue", label="B")
ax[0].fill(angles_A, values_A, alpha=0.3, color="blue")
ax[1].fill(angles_B, values_B, alpha=0.3, color="blue")
ax[0].set_thetagrids(angles_A[:-1] * 180 / np.pi, df.index, fontsize=15)
ax[0].set_theta_zero_location('N')
ax[1].set_thetagrids(angles_B[:-1] * 180 / np.pi, df.index, fontsize=15)
ax[1].set_theta_zero_location('N')

fig.savefig("./output/rador_chart/sample.png")