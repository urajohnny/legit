#!/bin/sh


./legit.pl init
echo onefile >test03_1
echo twofiles >test03_2
./legit.pl add test03_1 test03_2
./legit.pl commit -m '1st commit'
echo threefiles >test03_3
echo fourfiles >test03_4
./legit.pl add test03_1 test03_2 test03_3 test03_4
./legit.pl commit -m '2nd commit'
echo onefilechanged >>test03_1
./legit.pl add test03_1 test03_2 test03_3 test03_4
./legit.pl commit -m '3rd commit'
./legit.pl show 0:test03_1
./legit.pl show 2:test03_1
./legit.pl show :test03_1
./legit.pl show :test03_2
./legit.pl show 1:test03_3