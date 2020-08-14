frame_files <- lapply(sys.frames(), function(x) x$ofile)
frame_files <- Filter(Negate(is.null), frame_files)
setwd(dirname(frame_files[[length(frame_files)]]))

infile <- "../PDACeem/delta.tab"
nullfile <- "../PDACeem.perm/delta.tab"
P<-as.matrix(read.table(infile))
N<-as.matrix(read.table(nullfile))
dp<-density(P)
dn<-density(N)
plot(dp, xlim=c(range(dn$x,dp$x)), ylim=c(0, max(dn$y,dp$y)), 
      col="red",ann=F,)
par(new=T)
plot(dn, xlim=c(range(dn$x,dp$x)), ylim=c(0, max(dn$y,dp$y)), 
     col="blue",ann=F,)
     
