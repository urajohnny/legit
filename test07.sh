#!/bin/sh

./legit.pl init
touch a b c d e f
./legit.pl add a b c
./legit.pl commit -m '1st commit'
echo hello >a
echo hello >b
echo hello >c
./legit.pl commit -m '2nd commit'
./legit.pl status
./legit.pl add e f
./legit.pl add a b c
./legit.pl commit -m '3rd commit'
rm d
./legit.pl rm e
./legit.pl rm g
./legit.pl add g
./legit.pl status