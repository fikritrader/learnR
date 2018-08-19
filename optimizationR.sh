# place this file in svn:learnR, i.e. packages/

DATE=`date +%Y-%m-%d`

###

cp ../learn-r/package/LICENSE optimizationR/LICENSE
cat ../learn-r/package/DESCRIPTION | sed "s/learn-r.net/optimization-r.com/" > optimizationR/DESCRIPTION1
cat optimizationR/DESCRIPTION1 | sed "s/learnRversion/2.0-0/" > optimizationR/DESCRIPTION2
cat optimizationR/DESCRIPTION2 | sed "s|learnRdate|$DATE|" > optimizationR/DESCRIPTION3
cat optimizationR/DESCRIPTION3 | sed "s/learnR/optimizationR/" > optimizationR/DESCRIPTION4
cat optimizationR/DESCRIPTION4 | sed "s/LearnR/Decision Optimization with R/" > optimizationR/DESCRIPTION
rm optimizationR/DESCRIPTION?

cat ../learn-r/package/R/learnR.R | sed "s/learn-r.net/optimization-r.com/" > optimizationR/R/optimizationR.R1
cat optimizationR/R/optimizationR.R1 | sed "s/LearnR/Decision Optimization with R/" > optimizationR/R/optimizationR.R
rm optimizationR/R/optimizationR.R?

cat ../learn-r/package/R/setup.R | sed "s/learnR/optimizationR/" > optimizationR/R/setup.R

cat ../learn-r/package/R/tutorial.R | sed "s/learn-r.net/optimization-r.com/" > optimizationR/R/tutorial.R1
cat optimizationR/R/tutorial.R1 | sed "s/learnR/optimizationR/" > optimizationR/R/tutorial.R
rm optimizationR/R/tutorial.R?

cat ../learn-r/package/R/tutorials.R | sed "s/learnR/optimizationR/" > optimizationR/R/tutorials.R

cat ../learn-r/package/R/update.R | sed "s/learn-r.net/optimization-r.com/" > optimizationR/R/update.R1
cat optimizationR/R/update.R1 | sed "s/learnR/optimizationR/" > optimizationR/R/update.R
rm optimizationR/R/update.R?

###

cp ../optimization-r/packages.rda optimizationR/inst/packages.rda
cp ../optimization-r/tutorials.csv optimizationR/inst/tutorials.csv
cp ../optimization-r/codes/*.R optimizationR/inst/
rm optimizationR/inst/header.R

cp ../optimization-r/packages.rda optimizationR/data/packages.rda
cp ../learn-r/package/R/datasets.R optimizationR/R/datasets.R
