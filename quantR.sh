# place this file in svn:learnR, i.e. packages/

DATE=`date +%Y-%m-%d`

cp ../learn-r/package/LICENSE quantR/LICENSE
cat ../learn-r/package/DESCRIPTION | sed "s/learn-r.net/quant-r.com/" > quantR/DESCRIPTION1
cat quantR/DESCRIPTION1 | sed "s/learnRversion/2.0-0/" > quantR/DESCRIPTION2
cat quantR/DESCRIPTION2 | sed "s|learnRdate|$DATE|" > quantR/DESCRIPTION3
cat quantR/DESCRIPTION3 | sed "s/learnR/quantR/" > quantR/DESCRIPTION4
cat quantR/DESCRIPTION4 | sed "s/LearnR/Become a Quant with R/" > quantR/DESCRIPTION
rm quantR/DESCRIPTION?

cat ../learn-r/package/R/learnR.R | sed "s/learn-r.net/quant-r.com/" > quantR/R/quantR.R1
cat quantR/R/quantR.R1 | sed "s/LearnR/Become a Quant with R/" > quantR/R/quantR.R
rm quantR/R/quantR.R?

cat ../learn-r/package/R/setup.R | sed "s/learnR/quantR/" > quantR/R/setup.R

cat ../learn-r/package/R/tutorial.R | sed "s/learn-r.net/quant-r.com/" > quantR/R/tutorial.R1
cat quantR/R/tutorial.R1 | sed "s/learnR/quantR/" > quantR/R/tutorial.R
rm quantR/R/tutorial.R?

cat ../learn-r/package/R/tutorials.R | sed "s/learnR/quantR/" > quantR/R/tutorials.R

cat ../learn-r/package/R/update.R | sed "s/learn-r.net/quant-r.com/" > quantR/R/update.R1
cat quantR/R/update.R1 | sed "s/learnR/quantR/" > quantR/R/update.R
rm quantR/R/update.R?

###

cp ../quant-r/packages.rda quantR/inst/packages.rda
cp ../quant-r/tutorials.csv quantR/inst/tutorials.csv
cp ../quant-r/codes/*.R quantR/inst/
rm quantR/inst/header.R

cp ../quant-r/packages.rda quantR/data/packages.rda
cp ../learn-r/package/R/datasets.R quantR/R/datasets.R
