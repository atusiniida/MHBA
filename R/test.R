#if(length(commandArgs(trailingOnly=TRUE))==0){
#  frame_files <- lapply(sys.frames(), function(x) x$ofile)
#  frame_files <- Filter(Negate(is.null), frame_files)
#  setwd(dirname(frame_files[[length(frame_files)]]))
#}

outDir<-"out"
dir.create(outDir)

i<-c(1,1,1,2,2,3,3,3,3,3,4,5,5,5,5,6,6,6,6,6,6)
m<-rep(0,length(i))
m[runif(length(m))>0.5] <- 1
e<-0.1*rnorm(length(i))+0.2*rnorm(max(i))[i]+1.0*m

library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

d <- list(n = length(i), I = max(i), 
          e = e, i = i,m = m)
fit <- stan(file = 'model.stan', data = d, chains = 4, iter = 2000, warmup = 1000, thin = 1, 
#fit <- stan(file = 'model.stan', data = d, chains = 4, iter = 200000, warmup = 100000, thin = 1, 
#fit <- stan(file = 'model.stan', data = d, chains = 4, iter = 400000, warmup = 200000, thin = 2, 
#fit <- stan(file = 'model.stan', data = d, chains = 4, iter = 1000000, warmup = 500000, thin = 5, 
            sample_file = paste(outDir,"/samp",sep=""),
#            diagnostic_file = paste(outDir,"/diag",sep="")
            )

save(fit, file=paste(outDir,"/data.RData",sep=""))
pdf(file=paste(outDir,"/alpha_m__trace.pdf",sep=""))
stan_trace(fit, pars="alpha_m", inc_warmup =T, nrow=3, ncol=1)
dev.off()
pdf(file=paste(outDir,"/alpha_m__density.pdf",sep=""))
stan_plot(fit, pars="alpha_m", 
          ci_level=0.95, outer_level=1,
          show_density=T, show_outer_line=T)
dev.off()
pdf(file=paste(outDir,"/rhat.pdf",sep=""))
stan_rhat(fit)
dev.off()
tmp<-summary(fit)$summary
outfile <- paste(outDir,"/summary.tab",sep="")
write(t(as.matrix(c("", colnames(tmp)))), outfile,  append=F, sep="\t", ncolumns=ncol(tmp)+1)
write.table(tmp, outfile, quote=F, col.names=F, append=T, sep="\t")

#library(shinystan)
#launch_shinystan(fit)





