import matplotlib.pyplot as plt

Q = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]
T = [42.159,2.772,1.356,5.583,140.532,7.282,2.090,80.757,9.172,148.178,127.708,38.419,6.919,97.546,125.050,0.806,4.865,127.150,30.470,1.306,50.226,93.507]

plt.bar(Q, T)
plt.title('Time taken to run each query')
plt.xlabel('Query Number')
plt.ylabel('Time in milliseconds')
plt.savefig('query.png')
plt.show()
