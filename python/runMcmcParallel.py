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

rfile = homedir + "/R/mcmc.R"
rfile2 = homedir + "/R/plotHeatmap.R"
stanfile = homedir + "/stan/model.stan"

groupfile = ""
mutfile = ""
expfile = ""
outdir = ""

mem = 24
cpu = 4


if (len(argv) == 5):
    groupfile = argv[1]
    mutfile = argv[2]
    expfile = argv[3]
    outdir = argv[4]
elif (len(argv) != 5):
    print('Usage: # python %s  groupfile mutfile expfile outdir' % argv[0])
    quit()
    #groupfile = "data/groupTest.txt"
    #mutfile = "data/mutTest.tab"
    #expfile = "data/expTest.tab"
    #outdir = "out2"

if not os.path.exists(outdir) :
	os.system("mkdir " + outdir)

expDict ={}
expId = []
f = open(expfile)
line = f.readline()
samp1 = line.strip().split("\t")[1:]
line = f.readline()
while line:
    tmp = line.strip().split("\t")
    tmpDict = {}
    for i in range(len(samp1)):
        tmpDict[samp1[i]] = tmp[i+1]
    expDict[tmp[0]] = tmpDict
    expId.append(tmp[0])
    line = f.readline()
f.close()

mutDict ={}
mutId = []
f = open(mutfile)
line = f.readline()
samp2 = line.strip().split("\t")[1:]
line = f.readline()
while line:
    tmp = line.strip().split("\t")
    tmpDict = {}
    for i in range(len(samp2)):
        tmpDict[samp2[i]] = tmp[i+1]
    mutDict[tmp[0]] = tmpDict
    mutId.append(tmp[0])
    line = f.readline()
f.close()

samp=set(samp1).intersection(set(samp2))

f = open(groupfile)
groupDict = {}
sampId = []
for line in f:
    tmp = line.strip().split("\t")
    if tmp[0] in samp:
        groupDict[tmp[0]] = tmp[1]
        sampId.append(tmp[0])


# define qsub function

def printUGEscript(command, scriptfile):
        env = ["PATH", "PERL5LIB", "R_LIBS", "CLASSPATH", "LD_LIBRARY_PATH"]

        out = []
        out.append('#! /usr//bin/perl')
        out.append('#$ -S /usr/bin/perl')

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

# wait until # of jobs is less than cutoff

def waitForUGEjobFinishing(target, cutoff=1):
    target = target[0:9]
    while True:
        qstat = ""
        try:
            qstat = subprocess.check_output("qstat").decode('utf-8')
        except:
            continue
        qstat = qstat.rstrip().split("\n")
        greped = list(filter( lambda x: re.search(target,x), qstat))
        if len(greped) < cutoff:
            return
        else:
            time.sleep(10)


for e in expId:
    for m in mutId:
        if os.path.isfile(outdir + "/" + e + "_" + m + "/summary.tab"):
            continue
        infile = outdir + "/" + e + "_" + m + ".tab"
        with open(infile, mode='w') as f:
            f.write("\t" + "\t".join(sampId) + "\n")
            f.write("i\t" + "\t".join([groupDict[x] for x in  sampId]) + "\n")
            f.write("m\t" + "\t".join([mutDict[m][x] for x in  sampId]) + "\n")
            f.write("e\t" + "\t".join([expDict[e][x] for x in  sampId]) + "\n")

        rargs = [infile, outdir + "/" +  e + "_" + m, stanfile]
        command = "R --no-save --no-restore-dat --args " + " ".join(rargs) + " < " + rfile
        prefix2 = outdir + "/" + prefix + "."  + e + "_" + m
        scriptfile = prefix2 + ".pl"
        outfile = prefix2 + ".o"
        errfile = prefix2 + ".e"
        #continue
        printUGEscript(command, scriptfile)  # write script
        qsub = " ".join(["qsub", "-cwd",  "-N",   prefix + "."  + e + "_" + m, "-l",
                        "s_vmem=" + str(mem) + "G,mem_req=" + str(mem) + "G",
                        #"-q ljobs.q",
                        "-pe def_slot", str(cpu),
                        "-o",  outfile, "-e", errfile, scriptfile, "> /dev/null"])
        sys.stderr.write(qsub + "\n")
        while os.system(qsub) > 0:
            time.sleep(10)

waitForUGEjobFinishing(prefix)

targetParm = "delta"
outfile = outdir + "/" + targetParm + ".tab"
with open(outfile, mode='w') as f:
    f.write("\t" + "\t".join(mutId) + "\n")
    for e in expId:
        out = []
        for m in mutId:
            if os.path.isfile(outdir + "/" + e + "_" + m + "/summary.tab"):
                f2 = open(outdir + "/" + e + "_" + m + "/summary.tab")
                for line in f2:
                    tmp = line.split("\t")
                    if tmp[0] == targetParm:
                        out.append(tmp[1])
                        f2.close()
                        break
            else:
                out.append("NA")
        f.write(e + "\t" + "\t".join(out) + "\n")

rargs = [outdir + "/" + targetParm + ".tab", outdir + "/" + targetParm + ".pdf"]
command = "R --no-save --no-restore-dat --args " + " ".join(rargs) + " < " + rfile2
os.system(command)
os.system("rm " + outdir + "/" + prefix + "*")
