frame_files <- lapply(sys.frames(), function(x) x$ofile)
frame_files <- Filter(Negate(is.null), frame_files)
setwd(dirname(frame_files[[length(frame_files)]]))





tmp<-round(runif(20)*10)
tmp<-tmp[tmp>0]
i<-NULL
for(k in 1:length(tmp)){
  i<-c(i,rep(k,tmp[k]))
}
sampId<-paste("samp",1:length(i), sep="")

m1<-rep(0,length(i))
m1[runif(length(m1))>0.5] <- 1
m2<-rep(0,length(i))
m2[runif(length(m2))>0.5] <- 1
e1<-0.1*rnorm(length(i))+0.2*rnorm(max(i))[i]+0.5*m1
e2<-0.1*rnorm(length(i))+0.3*rnorm(max(i))[i]+0.3*m2
e3<-0.1*rnorm(length(i))+0.3*rnorm(max(i))[i]

E<-rbind(e1,e2,e3)
M<-rbind(m1,m2)
colnames(E)<-sampId
colnames(M)<-sampId
G<-cbind(sampId,i)
outfile<-"../data/expTest.tab"
write(t(as.matrix(c("", colnames(E)))), outfile,  append=F, sep="\t", ncolumns=ncol(E)+1)
write.table(E, outfile, quote=F, col.names=F, append=T, sep="\t")
outfile<-"../data/mutTest.tab"
write(t(as.matrix(c("", colnames(M)))), outfile,  append=F, sep="\t", ncolumns=ncol(M)+1)
write.table(M, outfile, quote=F, col.names=F, append=T, sep="\t")
outfile<-"../data/groupTest.txt"
write.table(G, outfile, quote=F, row.names=F, col.names=F, sep="\t")

