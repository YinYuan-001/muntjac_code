blastall (2.2.26)
UCSC tools (http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/)

#### step 1: We aligned the sequence of three types of Cervidae-specific satellite and telomere onto the nanopore reads using blast.

formatdb -i sate_telomere.fa -p F -n sate_telomere.db
blastall -p blastn -d sate_telomere.db -i nanopore.fa -o nanopore.blast.out -m 8 -F F

#### step2: We filtered the blast outfile and counted the length of  satellite sequences and telomere sequences contained in each read.  Then according to the types of satellite sequences or telomere sequences contained in each read, we obtained the patterns of reads , and counted the number and proportion of reads in each pattern. 

awk '$11<0.001{a=$10-$9;print$0"\t"a}' nanopore.blast.out > nanopore.e0.001.blast.out
awk '$2=="tel1"{print$1"\t"$7"\t"$8}' nanopore.e0.001.blast.out > nanopore.e0.001.telomere.blast.bed
awk '$2!="tel1"{print$0}' nanopore.e0.001.blast.out > nanopore.e0.001.del_telomere.blast.out

python cal.seq_length.reads.py --filein nanopore.e0.001.del_telomere.blast.out --filetel nanopore.e0.001.telomere.blast.bed --fileout nanopore.e0.001.blast.length_detail.txt

python get_pattern_number.py --filein nanopore.e0.001.blast.length_detail.txt --fileout nanopore.e0.001.blast.length_detail.pattern.filter.txt

awk '{print$7}' nanopore.e0.001.blast.length_detail.pattern.filter.txt | sort | uniq -c > nanopore.e0.001.blast.length_detail.pattern.filter.num
total_reads=`awk 'BEGIN{a=0}{a=a+$1}END{print a}'`
awk -v total=$total_reads '{ratio=$1/total;print$0"\t"ratio} nanopore.e0.001.blast.length_detail.pattern.filter.num > nanopore.e0.001.blast.length_detail.pattern.filter.num.ratio





#### step 3: Aliging nanopore read which contains satellite or telomere sequence to itself using blast.

awk '$7!="0000"{print$1}' nanopore.e0.001.blast.length_detail.pattern.filter.txt > alignedby.sate_telomere.list
faSomeRecords nanopore.fa  alignedby.sate_telomere.list alignedby.sate_telomere.fa

mkdir  list_dir fa_dir out_dir
for id in `cat alignedby.sate_telomere.list`
do
echo $id > list_dir/$id.list
faSomeRecords alignedby.sate_telomere.fa list_dir/$id.list fa_dir/$id.fa
formatdb -i fa_dir/$id.fa -p F -n out_dir/$id.db
blastall -p blastn -d out_dir/$id.db -i fa_dir/$id.fa -o out_dir/$id.tmp.out -m 8 -F F -a 12
cat out_dir/$id.tmp.out >> selfblast.out
rm -rf list_dir/$id.list
rm -rf  fa_dir/$id.fa
rm -rf out_dir/$id.*
done

#### step 4: Obtaining the size of nanopore read and the palindromic sequence length.

faSize -detailed nanopore.fa > nanopore.size 
awk '$1==$2{print$1"\t"$7"\t"$8}' selfblast.out | msort -k 1 -k n2  > huiwen.sort.bed
get_huiwen.1.py --filesize nanopore.size --filehuiwen huiwen.sort.bed --fileout huiwen.sort.delfull.bed
bedtools merge -i huiwen.sort.delfull.bed > huiwen.sort.merge.bed
python 20.stat_huiwen.py --filepattern nanopore.e0.001.blast.length_detail.pattern.filter.txt --filehuiwen huiwen.sort.merge.bed --filesize nanopore.size --fileout nanopore.e0.001.blast.length_detail.pattern.filter.size.huiwenlength.txt 

#### step 5: We calculated the distance between satellite I and telomere sequence in nanopore with patthern "1001".  We also checked whether there are palindromic sequence around the telomere sequence in reads with patthern "1001", "0011" and "1011".

##distance between satellite I and telomere sequence
python distance_satI_telomere.2.py --fileinfo nanopore.e0.001.blast.length_detail.pattern.filter.size.huiwenlength.txt  --fileblast nanopore.e0.001.blast.out --fileout nanopore.e0.001.blast.length_detail.pattern.filter.size.huiwenlength.1001_distance_type.txt 

##palindromic sequence around the telomere sequence
cat selfblast.out >> nanopore.e0.001.blast.out
for i in 1001 0011 1011
do
awk -v type=$i '$7==type{print$1}' nanopore.e0.001.blast.length_detail.pattern.filter.txt > $i.pattern.list
python judge_huiwen_near_tel.1.py --fileblast nanopore.e0.001.blast.out --fileidlist $i.pattern.list --filesize nanopore.size --fileout $i.pattern.withhuiwen_near_tel.list
done


