import numpy as np
import os,sys
#print a.shape
flag = 0
A = []
with open(sys.argv[1],'r') as f:
	for i in f:
		flag = flag + 1
		print flag
		B = i.strip().split()
		F = []
		print len(B)
		for j in B:
			F.append(float(j)/10)
		A.append(F)
np.save(sys.argv[2],A)
