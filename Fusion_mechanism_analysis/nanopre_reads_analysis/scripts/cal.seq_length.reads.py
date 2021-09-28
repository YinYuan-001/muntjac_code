#!/bin/env python

import click
@click.command()
@click.option('--filein')
@click.option('--filetel')
@click.option('--fileout')

def main(filein,filetel,fileout):
    file_out=open(fileout,'w')
    file_out.write('id\tsal_I\tmon_980\tsal_II\tsal_IV\ttelomere\n')
    Reads={}
    Tel={}
    with open(filein,'r') as file_in:
        for line in file_in:
            Line=line.strip().split()
            id=Line[0]
            query=Line[1]
            length=int(Line[3])

            if id not in Reads:
               Reads[id]={}
            if query not in Reads[id]:
               Reads[id][query]=0
            Reads[id][query]=Reads[id][query]+length
    with open(filetel,'r') as file_tel:
        for line in file_tel:
            Line=line.strip().split()
            id=Line[0]
            start=int(Line[1])
            end=int(Line[2])
            length=end-start+1
            if id not in Tel:
               Tel[id]=0
            Tel[id]=Tel[id]+length


    Tel_Sal=[]
    types=['sal_I','mon_980','sal_II','sal_IV']
    for id in Reads:
        out_line=id
        for type in types:
            if type in Reads[id]:
               length=Reads[id][type]
            else:
                length=0
            out_line=out_line+'\t'+str(length)
        if id in Tel:
           tel_lenght=Tel[id]
           Tel_Sal.append(id)
        else:
            tel_lenght=0
        out_line=out_line+'\t'+str(tel_lenght)+'\n'
        file_out.write(out_line)
    for id in Tel:
        if id not in Tel_Sal:
           length=Tel[id]
           out_line=id+'\t0\t0\t0\t0\t'+str(length)+'\n'
           file_out.write(out_line)


if __name__=='__main__':
    main()

