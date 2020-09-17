



## multiregion analysisにおいて変異と発現量との相関をとる
### インストール

```
git clone https://github.com/atusiniida/MHBA.git
```

または

```
wget https://github.com/atusiniida/MHBA/archive/master.zip  
unzip  master.zip    
rm master.zip  
mv MHBA-master MHBA  
```

rstanをインストール
https://mc-stan.org/users/interfaces/rstan


### EEMを実行
発現データA.tab、遺伝子セットデータB.gmtに適用
```
perl MHBA/python/runMcmcParallel.py MHBA/data/groupTest.txt MHBA/data/mutTest.tab MHBA/data/expTest.tab result
```
