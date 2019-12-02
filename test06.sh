#!/bin/sh

./legit.pl init
touch a b c d e f g h

./legit.pl add a b c d e f g
./legit.pl commit -m '1st commit'
echo line 1 >a
echo line 1 >b
echo line 1 >c
./legit.pl add a b c
echo line 2 >>a

rm d
./legit.pl rm e
./legit.pl add g
./legit.pl status
./legit.pl commit  -a -m '2nd commit'
./legit.pl status