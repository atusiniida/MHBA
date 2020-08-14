if(length(commandArgs(trailingOnly=TRUE))!=2){
  initial.options <- commandArgs(trailingOnly = FALSE)
  file.arg.name <- "--file="
  script_name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
  print(paste("usage: R", script_name, "infile outfile", sep=" "))
  quit()
}

infile <- commandArgs(trailingOnly=TRUE)[1]
outfile <- commandArgs(trailingOnly=TRUE)[2]

E<-as.matrix(read.table(inFile))
library(gplots)
pdf(file=outFile)
heatmap(E,Rowv = NA, Colv=NA, scale = "none",col=bluered(256))
dev.off()