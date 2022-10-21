import numpy as np
import matplotlib.pyplot as plt


width_bar = 0.4

x = np.array([1, 2, 3, 4, 5])
x1 = x - width_bar/2
x2 = x + width_bar/2

y1 = np.array([10, 20, 30, 40, 50])
y2 = np.array([10, 15, 10, 15, 10])


fig = plt.figure(figsize = (5,5), facecolor='lightblue')

plt.xlabel('X')
plt.ylabel('Y')

plt.bar(x=x1, height=y1, label='y1', width=width_bar, align="center")
plt.bar(x=x2, height=y2, label='y2', width=width_bar, align="center")
plt.savefig("./output/each_characteristic_result/sample.png")