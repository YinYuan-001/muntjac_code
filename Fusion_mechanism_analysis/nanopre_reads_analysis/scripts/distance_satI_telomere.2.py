#!/bin/env python
import click
@click.command()
@click.option('--fileinfo')
@click.option('--fileblast')
@click.option('--fileout')

def main(fileinfo,fileblast,fileout):
    file_out=open(fileout,'w')
    IdList={}
    with open(filelist,'r') as file_list:
         for line in file_list:
             Line=line.strip().split()
             id=Line[0]
             pattern=Line[6]
             if pattern=="1001":
                IdList[pattern]=Line
    Sat_I={}
    Telo={}
    with open(fileblast,'r') as file_blast:
         for line in file_blast:
             Line=line.strip().split()
             id=Line[0]
             if id in IdList:
                if id not in Sat_I:
                   Sat_I[id]=[]
                   Telo[id]=[]
                query=Line[1]
                start=int(Line[6])
                end=int(Line[7])
                if query=='sal_I' or query=='mon_980':
                   Sat_I[id].append(start)
                   Sat_I[id].append(end)
                if query=='tel1':
                   Telo[id].append(start)
                   Telo[id].append(end)

    for id in Sat_I:
        sat_list=Sat_I[id]
        tel_list=Telo[id]
        sat_list.sort()
        tel_list.sort()
        tel_start=tel_list[0]
        tel_end=tel_list[-1]
        sat_start=sat_list[0]
        sat_end=sat_list[-1]
        if sat_start >= tel_end:
           distance = sat_start - tel_end
           type='tel_sat'
        elif sat_end <= tel_start:
           distance = tel_start - sat_end
           type='sat_tel'
        else:
            last_pos=0
            for pos in sat_list:
                if pos <=tel_start:
                   last_pos=pos
                elif pos >= tel_end:
                     distance_1=tel_start - last_pos
                     distance_2=pos - tel_end
                     distance=min(distance_1,distance_2)
                     type='sat_tel_sat'
                     break
        if distance < 500::
            dis_tag='<500'
        else:
            dis_tag='>=500'
        out_line='\t'.join(IdList[id])+'\t'+str(distance)+'\t'+dis_tag+'\n'
        file_out.write(out_line)

if __name__=='__main__':
   main()

