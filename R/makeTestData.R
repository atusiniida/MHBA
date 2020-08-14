frame_files <- lapply(sys.frames(), function(x) x$ofile)
frame_files <- Filter(Negate(is.null), frame_files)
setwd(dirname(frame_files[[length(frame_files)]]))

outfile<-"in.tab"

tmp<-round(runif(20)*10)
tmp<-tmp[tmp>0]
i<-NULL
for(k in 1:length(tmp)){
  i<-c(i,rep(k,tmp[k]))
}
m<-rep(0,length(i))
m[runif(length(m))>0.5] <- 1
e<-0.1*rnorm(length(i))+0.2*rnorm(max(i))[i]+0.5*m

D<-rbind(i,m,e)
colnames(D)<-paste("samp",1:ncol(D), sep="")
write(t(as.matrix(c("", colnames(D)))), outfile,  append=F, sep="\t", ncolumns=ncol(D)+1)
write.table(D, outfile, quote=F, col.names=F, append=T, sep="\t")
barplot(D["e",][names(sort(D["m",]))])
