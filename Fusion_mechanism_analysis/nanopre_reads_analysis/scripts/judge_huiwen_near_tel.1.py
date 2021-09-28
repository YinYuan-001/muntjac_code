#!/bin/env python

import click
@click.command()
@click.option('--fileblast')
@click.option('--fileidlist')
@click.option('--filesize')
@click.option('--fileout')

def main(fileblast,fileidlist,filesize,fileout):
    file_out=open(fileout,'w')

    IDList=[]            
    with open(fileidlist,'r') as file_idlist:
         for line in file_idlist:
             Line=line.strip()
             IDList.append(Line)
    print(len(IDList))
    
    Size={}
    with open(filesize,'r') as file_size:
	 for line in file_size:
             Line=line.strip().split()
             id=Line[0]
             size=Line[1]
             if id in IDList:
                Size[id]=size
    print(len(Size))

    Tel_Dict={}
    Pal_Dict={}
    with open(fileblast,'r') as file_blast:
         for line in file_blast:
             Line=line.strip().split()
             id=Line[0]
             if id in IDList:
                query=Line[1]
                id_start=int(Line[6])
                id_end=int(Line[7])
                if query=="tel1":
                   if id not in Tel_Dict:
                      Tel_Dict[id]=[]
                   Tel_Dict[id].append(id_start)
                   Tel_Dict[id].append(id_end)         
                if query==id and id_end != Size[id]:
                   if id not in Pal_Dict:
                      Pal_Dict[id]={}
                   Pal_Dict[id][id_start]=id_end
    print(len(Tel_Dict))
    print(len(Pal_Dict))
    for id in IDList:
       pal_list=sorted(Pal_Dict[id].items(),key=lambda x:x[0])
       tel_list=sorted(Tel_Dict[id])

       for i in range(1,5):
           j=i*1000
           tel_start=tel_list[0]-j
           tel_end=tel_list[-1]+j
           for pair in pal_list:
               if pair[0] >= tel_start and pair[1] <= tel_end:
                  out_line=id+'\t'+str(pair[0])+'\t'+str(pair[1])+'\t'+str(j)+'\n'
                  file_out.write(out_line)
if __name__=='__main__':
   main() 
       
