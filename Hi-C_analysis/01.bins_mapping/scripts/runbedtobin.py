import os
import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import sys,getopt,os
shortargs = 'i:o:s:h'
opts, args = getopt.getopt(sys.argv[1:],shortargs)
input_file=""
output_file=""
find_seq = ""
for op, value in opts:
        if op == "-i":
                input_file = value
                print str("inputfile:"+str(input_file))
        elif op == "-o":
                output_file = value
        elif op == "-s":
                be_set_file = value
                print str("outputfile:"+str(output_file))
        elif op == "-h":
                print("example:python run.py -i dirin -o dirout -s resolution")
                sys.exit()
allloc = {}
resolution = int(be_set_file)
ax = open(output_file,'w')
F = []
all = []
with open(input_file,'r') as f:
	for i in f:
		tmp = []
		left =int(i.strip().split()[1])/resolution+1
		right = int(i.strip().split()[2])/resolution+1
		#if len(range(left,right)) == 1:
		#	print len(range(left,right)),i.strip(),left,right
		if len(range(left,right+1)) >=3:
			ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(left+1),i.strip().split()[-1]))
			#if i.strip().split()[0]+"_"+str(left+1) not in F:
			F.append(i.strip().split()[0]+"_"+str(left+1))
			#else:
			#	print 1,i.strip(),left,right
			continue
		#if len(range(left,right)) > 3:
		#	print 2,i.strip(),left,right
		#	continue
		if len(range(left,right+1)) ==1:
			ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(range(left,right+1)[0]),i.strip().split()[-1]))
			#if i.strip().split()[0]+"_"+str(range(left,right+1)[0]) not in F:
			F.append(i.strip().split()[0]+"_"+str(range(left,right+1)[0]))
			#else:
			#print 3,i.strip(),left,right
			continue
		'''
		if len(range(left,right)) ==2:
			leftlen = resolution - (int(i.strip().split()[1])%resolution)
                	leftlenright = int(i.strip().split()[2]) - int(i.strip().split()[1]) - leftlen
                	if leftlenright*1.0/(int(i.strip().split()[2])-int(i.strip().split()[1])) > 0.6:
                        	bin = right
				ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(bin),i.strip().split()[-1]))
				if i.strip().split()[0]+"_"+str(bin) not in F:
					F.append(i.strip().split()[0]+"_"+str(bin))
				else:
					print 4,i.strip(),left,right
				continue
                	if leftlenright*1.0/(int(i.strip().split()[2])-int(i.strip().split()[1])) > 0.6:
                        	bin = left
				ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(bin),i.strip().split()[-1]))
				if i.strip().split()[0]+"_"+str(bin) not in F:
					F.append(i.strip().split()[0]+"_"+str(bin))
				else:
					print 5,i.strip(),left,right
				continue
		'''
		all.append(i)
print len(F)
print "################################################################"
for i in all:
	left =int(i.strip().split()[1])/resolution+1
	right = int(i.strip().split()[2])/resolution+1
	leftlen = resolution - (int(i.strip().split()[1])%resolution)
       	rightlen = int(i.strip().split()[2]) - int(i.strip().split()[1]) - leftlen
	if rightlen >= leftlen and i.strip().split()[0]+"_"+str(right) not in F:
		bin = right
		ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(bin),i.strip().split()[-1]))
		F.append(i.strip().split()[0]+"_"+str(bin))
		continue
	if rightlen >= leftlen and i.strip().split()[0]+"_"+str(left) not in F:
		bin = left
                ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(bin),i.strip().split()[-1]))
                F.append(i.strip().split()[0]+"_"+str(bin))
		continue
	if rightlen <= leftlen and i.strip().split()[0]+"_"+str(left) not in F:
		bin = left
		ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(bin),i.strip().split()[-1]))
		F.append(i.strip().split()[0]+"_"+str(bin))
		continue
	if rightlen <= leftlen and i.strip().split()[0]+"_"+str(right) not in F:
                bin = right
                ax.write("%s\t%s\n"%(i.strip().split()[0]+"_"+str(bin),i.strip().split()[-1]))
                F.append(i.strip().split()[0]+"_"+str(bin))
		continue
	print i
ax.close()
