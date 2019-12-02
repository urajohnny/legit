#!/bin/sh

./legit.pl init
seq 1 100 >100.txt
./legit.pl add 100.txt
./legit.pl commit -m "1st commit"
./legit.pl branch b1
./legit.pl checkout b1
sed s/2/10000/g 100.txt
./legit.pl commit -a -m "2nd commit"
./legit.pl checkout master
./legit.pl commit -a -m "3rd commit"
./legit.pl merge b1 -m merge-message