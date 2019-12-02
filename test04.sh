#!/bin/sh


./legit.pl init
touch a b c d
./legit.pl commit -m '1st commit'
./legit.pl add a b c d
./legit.pl commit -m '1st commit'
echo hello >a
echo hello >b
echo hello >c
./legit.pl commit -a -m '2nd commit'
./legit.pl rm a b c
./legit.pl commit -a -m '3rd commit'
rm d
./legit.pl status