import re
import sys

argv = sys.argv
mutfile = argv[1]
expfile = argv[2]

f = open(expfile)
line = f.readline()
samp1 = line.strip().split("\t")

f = open(mutfile)
line = f.readline()
samp2 = line.strip().split("\t")

samp=set(samp1).intersection(set(samp2))


pattern = "(.*T)[\d.]+$"

seen = {}
i = 1
for x in samp:
    res = re.match(pattern, x)
    tmp = res.group(1)
    if not tmp in seen:
        seen[tmp] = i
        i += 1
    print(x + "\t" + str(seen[tmp]))
