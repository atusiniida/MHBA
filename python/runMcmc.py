import os
import re
import subprocess
import time
import sys

argv = sys.argv
pid = os.getpid()  # get process id
prefix = "tmp" + str(pid)
homedir = os.path.abspath(os.path.dirname(__file__))
homedir = re.sub("/python", "", homedir)


outdir = ""
infile = ""

if (len(argv) == 3):
    infile = argv[1]
    outdir = argv[2]
elif (len(argv) != 3):
	print('Usage: # python %s  infile outdir' % argv[0])
	quit()

rfile = homedir + "/R/mcmc.R"
stanfile = homedir + "/stan/model.stan"
rargs = [infile, outdir, stanfile]

mem = 24
cpu = 4


def printUGEscript(command, scriptfile):
        env = ["PATH", "PERL5LIB", "R_LIBS", "CLASSPATH", "LD_LIBRARY_PATH"]

        out = []
        out.append('#! /usr/local/package/perl/5.26.1/bin/perl')
        out.append('#$ -S /usr/local/package/perl/5.26.1/bin/perl')

        for x in env:
                if x in os.environ:
                        out.append('$ENV{' + x + '}="' + os.environ[x] + '";')

        out.extend([ "warn \"command : " + command + "\\n\";",
                                 "warn \"started @ \".scalar(localtime).\"\\n\";",
                                 "if(system (\"" + command + "\" )){",
                                 "die \"failed @ \".scalar(localtime).\"\\n\";",
                                 "}else{",
                                "warn \"ended @ \".scalar(localtime).\"\\n\";",
                                "}", ])
        with open(scriptfile, "w") as file:
                file.write("\n".join(out) + "\n")

def waitForUGEjobFinishing(target, cutoff=1): # wait until # of jobs is less than cutoff
        target = target[0:9]
        while True:
                qstat = commands.getstatusoutput("qstat")
                if qstat[0] > 0:
                        continue
                qstat = qstat[1].rstrip().split("\n")
                greped = filter( lambda x: re.search(target,x), qstat)
                if len(greped) < cutoff:
                        return
                else:
                        time.sleep(10)



command = "R --no-save --no-restore-dat --args " + " ".join(rargs) + " < " + rfile
scriptfile = prefix + ".pl"
outfile = prefix + ".o"
errfile = prefix + ".e"
printUGEscript(command, scriptfile)  # write script
qsub = " ".join(["qsub", "-cwd",  "-N",  prefix, "-l",
                "s_vmem=" + str(mem) + "G,mem_req=" + str(mem) + "G",
                #"-q ljobs.q",
                "-pe def_slot", str(cpu),
                "-o",  outfile, "-e", errfile, scriptfile, "> /dev/null"])
sys.stderr.write(qsub + "\n")
while os.system(qsub) > 0:
    time.sleep(10)
