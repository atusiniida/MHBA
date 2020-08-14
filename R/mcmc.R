inFile <- commandArgs(trailingOnly=TRUE)[1]
outDir <- commandArgs(trailingOnly=TRUE)[2]
stanFile <- commandArgs(trailingOnly=TRUE)[3]

D<-read.table(inFile)
i<-as.vector(t(D["i",]))
e<-as.vector(t(D["e",]))
m<-as.vector(t(D["m",]))

dir.create(outDir)

library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

d <- list(n = length(i), I = max(i), 
          e = e, i = i,m = m)
fit <- stan(file = stanFile, data = d, chains = 4, iter = 2000, warmup = 1000, thin = 1, 
#fit <- stan(file = stanFile, data = d, chains = 4, iter = 200000, warmup = 100000, thin = 1, 
#fit <- stan(file = stanFile, data = d, chains = 4, iter = 400000, warmup = 200000, thin = 2, 
#fit <- stan(file = stanFile, data = d, chains = 4, iter = 1000000, warmup = 500000, thin = 5, 
#            sample_file = paste(outDir,"/samp",sep=""),
#            diagnostic_file = paste(outDir,"/diag",sep="")
            )

#save(fit, file=paste(outDir,"/data.RData",sep=""))
#pdf(file=paste(outDir,"/alpha_m__trace.pdf",sep=""))
#stan_trace(fit, pars="alpha_m", inc_warmup =T, nrow=3, ncol=1)
#dev.off()
pdf(file=paste(outDir,"/alpha_m__density.pdf",sep=""))
stan_plot(fit, pars="alpha_m", 
          ci_level=0.95, outer_level=1,
          show_density=T, show_outer_line=T)
dev.off()
pdf(file=paste(outDir,"/delta__density.pdf",sep=""))
stan_plot(fit, pars="delta", 
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





