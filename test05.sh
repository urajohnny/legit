#!/bin/sh

./legit.pl init
touch a b c d e
./legit.pl add a b c d e
./legit.pl commit -m '1st commit'
./legit.pl rm a
./legit.pl rm --cached b
./legit.pl rm --force c
./legit.pl commit -m '2nd commit'
./legit.pl rm --force --cached d
./legit.pl commit -m '3rd commit'
rm e
./legit.pl add e
./legit.pl commit -m '4th commit'