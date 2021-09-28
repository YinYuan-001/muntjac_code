import gzip
ax = open("hjf.spline_pass1.res20000.significances.txt.bed",'w')
flag = 0
with gzip.open("hjf.spline_pass1.res20000.significances.txt.gz",'r') as f:
	for i in f:
		flag = flag + 1
		if flag == 1:
			continue
		if float(i.split()[6]) <=0.01 and float(i.split()[5]) <=0.01:
			if int(i.split()[4]) >= 3:
				ax.write(i)
                
ax.close()
