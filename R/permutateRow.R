#frame_files <- lapply(sys.frames(), function(x) x$ofile)
#frame_files <- Filter(Negate(is.null), frame_files)
#setwd(dirname(frame_files[[length(frame_files)]]))
#infile <- "../data/PDACeem.tab"
#outfile <- "../data/PDACeem.perm.tab"


if(length(commandArgs(trailingOnly=TRUE))!=2){
  initial.options <- commandArgs(trailingOnly = FALSE)
  file.arg.name <- "--file="
  script_name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
  print(paste("usage: R", script_name, "infile outfile", sep=" "))
  quit()
}

infile <- commandArgs(trailingOnly=TRUE)[1]
outfile <- commandArgs(trailingOnly=TRUE)[2]
E<-as.matrix(read.table(infile))
for(i in 1:nrow(E)){
  E[i,]<-sample(E[i,])
}
write(t(as.matrix(c("", colnames(E)))), outfile,  append=F, sep="\t", ncolumns=ncol(E)+1)
write.table(E, outfile, quote=F, col.names=F, append=T, sep="\t")
