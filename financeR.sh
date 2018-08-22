# place this file in svn:learnR, i.e. packages/

DATE=`date +%Y-%m-%d`
VERSION="2.0-0"

cp ../learn-r/package/LICENSE financeR/LICENSE
cat ../learn-r/package/DESCRIPTION | sed "s/learn-r.net/finance-r.com/" > financeR/DESCRIPTION1
cat financeR/DESCRIPTION1 | sed "s|learnRversion|$VERSION|" > financeR/DESCRIPTION2
cat financeR/DESCRIPTION2 | sed "s|learnRdate|$DATE|" > financeR/DESCRIPTION3
cat financeR/DESCRIPTION3 | sed "s/learnR/financeR/" > financeR/DESCRIPTION4
cat financeR/DESCRIPTION4 | sed "s/LearnR/Finance with R/" > financeR/DESCRIPTION
rm financeR/DESCRIPTION?

cat ../learn-r/package/R/learnR.R | sed "s/learn-r.net/finance-r.com/" > financeR/R/financeR.R1
cat financeR/R/financeR.R1 | sed "s/LearnR/Finance with R/" > financeR/R/financeR.R
rm financeR/R/financeR.R?

cat ../learn-r/package/R/setup.R | sed "s/learnR/financeR/" > financeR/R/setup.R

cat ../learn-r/package/R/tutorial.R | sed "s/learn-r.net/finance-r.com/" > financeR/R/tutorial.R1
cat financeR/R/tutorial.R1 | sed "s/learnR/financeR/" > financeR/R/tutorial.R
rm financeR/R/tutorial.R?

cat ../learn-r/package/R/tutorials.R | sed "s/learnR/financeR/" > financeR/R/tutorials.R

cat ../learn-r/package/R/update.R | sed "s/learn-r.net/finance-r.com/" > financeR/R/update.R1
cat financeR/R/update.R1 | sed "s/learnR/financeR/" > financeR/R/update.R
rm financeR/R/update.R?

###

cp ../finance-r/packages.rda financeR/inst/packages.rda
cp ../finance-r/tutorials.csv financeR/inst/tutorials.csv
cp ../finance-r/codes/*.R financeR/inst/
rm financeR/inst/header.R

cp ../finance-r/packages.rda financeR/data/packages.rda
cp ../learn-r/package/R/datasets.R financeR/R/datasets.R
