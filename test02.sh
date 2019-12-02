#!/bin/sh


./legit.pl init
echo onefile >test02_1
echo twofiles >test02_2
./legit.pl add test02_1 test02_2
./legit.pl commit -m '1st commit'
echo threefiles >test02_3
echo fourfiles >test02_4
./legit.pl add test02_1 test02_2 test02_3 test02_4
./legit.pl commit -m '2nd commit'
./legit.pl log
echo onefilechanged >>test02_1
./legit.pl add test02_1 test02_2 test02_3 test02_4
./legit.pl commit -m '3rd commit'
./legit.pl log