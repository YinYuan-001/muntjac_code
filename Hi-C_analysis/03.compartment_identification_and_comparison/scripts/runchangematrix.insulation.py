import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import sys,getopt,os
shortargs = 'i:o:s:c:g:h'
opts, args = getopt.getopt(sys.argv[1:],shortargs)
input_file=""
output_file=""
find_seq = ""
chr = ""
sp = ""
for op, value in opts:
        if op == "-i":
                input_file = value
                print str("inputfile:"+str(input_file))
        elif op == "-o":
                output_file = value
        elif op == "-c":
		chr = value
	elif op == "-s":
                be_set_file = value
                print str("outputfile:"+str(output_file))
	elif op == "-g":
		sp = value
        elif op == "-h":
                print("example:python run.py -i inputmatrix -g species -c chr1 -o dirout -s resolution")
                usage()
                sys.exit()
pathfilein = input_file
pathdirout = output_file
resolution = be_set_file
chrset = chr
ax = open("%s/%s_%s_%s.insulation.matrix"%(output_file,sp,chrset,resolution),'w')
ax.write("\t")
with open(pathfilein,'r') as f:
	for i in f:
		num = len(i.split())
		break
for i in range(num-1):
	ax.write("%s|%s|%s:%s-%s\t"%(i+1,sp,chrset,i*int(resolution)+1,(i+1)*int(resolution)))
ax.write("%s|%s|%s:%s-%s\n"%(num,sp,chrset,(num-1)*int(resolution)+1,(num)*int(resolution)))
tmp = -1
with open(pathfilein,'r') as f:
	for i in f:
		tmp=tmp+1
		ax.write("%s|%s|%s:%s-%s"%(tmp+1,sp,chrset,tmp*int(resolution)+1,(tmp+1)*int(resolution)))
		yy = i.strip().split()
		for j in yy:
			if float(j) == 0:
				ax.write("\tnan")
			else:
				ax.write("\t%s"%float(j))
		ax.write("\n")
ax.close()
