import gzip,os,sys
ax = open(sys.argv[2],'w')
flag = 0
with gzip.open(sys.argv[1],'r') as f:
	for i in f:
		flag = flag + 1
		if flag == 1:
			continue
		if float(i.split()[6]) <=0.01 and float(i.split()[5]) <=0.01:
			if int(i.split()[4]) >= 9:
				ax.write(i)
ax.close()
