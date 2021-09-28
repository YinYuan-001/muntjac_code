##在Rsudio中分析差异基因###
#setwd('C:\\YinYuan\\documents\\work_dir\\muntjac\\04-neo-sex\\05-RNA')
library("DESeq2")
directory <-'C:\\YinYuan\\documents\\work_dir\\muntjac\\04-neo-sex\\05-RNA\\'
directory
sampleFiles <- c("BMF4toBMF.counts.txt ","BMM4toBMF.counts.txt ")
sampleFiles
###注意control要放在前面####
sampleCondition <- c("control","KO")
sampleCondition
sampleTable <- data.frame(sampleName= sampleFiles,fileName = sampleFiles,condition = sampleCondition)
sampleTable
dds <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,directory = directory,design= ~ condition)
dds
dds <- dds [ rowSums(counts(dds)) > 1, ]
#PCA#
rld<-rlog(dds)
plotPCA(rld)
dds<-DESeq(dds)
res <- results(dds)
head(res)
summary(res)
resOrdered <- res[order(res$padj),]
resOrdered=as.data.frame(resOrdered)
head(resOrdered)
resOrdered=na.omit(resOrdered)
DEmiRNA=resOrdered[abs(resOrdered$log2FoldChange)>log2(1.5) & resOrdered$padj <0.01 ,]
head(resOrdered)
write.csv(resOrdered,"hisat2_samtools_htseq_DESeq2_output.csv")
##volcano.plot###
alpha <- 0.01 # Threshold on the adjusted p-value
cols <- densCols(res$log2FoldChange, -log10(res$pvalue))
plot(res$log2FoldChange, -log10(res$padj), col=cols, panel.first=grid(),
     main="Volcano plot", xlab="Effect size: log2(fold-change)", ylab="-log10(adjusted p-value)",
     pch=20, cex=0.6)
abline(v=0)
abline(v=c(-1,1), col="brown")
abline(h=-log10(alpha), col="brown")
gn.selected <- abs(res$log2FoldChange) > 2.5 & res$padj < alpha
text(res$log2FoldChange[gn.selected],
     -log10(res$padj)[gn.selected],
     lab=rownames(res)[gn.selected ], cex=0.7)

#MA图#
library("geneplotter")
plotMA(res,main="DESeq2",ylim=c(-2,2))
#heatmap#
select<-order(rowMeans(counts(dds,normalized=TRUE)),decreasing = TRUE)[1:666]
nt<-normTransform(dds)
log2.norm.counts<-assay(nt)[select,]
df<-as.data.frame(colData(dds))
library(pheatmap)
pheatmap(log2.norm.counts,cluster_rows = TRUE,show_rownames = FALSE,cluster_cols = TRUE,annotation_col = df)