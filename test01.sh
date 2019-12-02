#!/bin/sh


./legit.pl init
echo all >>test01
echo is >>test01
echo well >>test01
./legit.pl add test01
./legit.pl commit -m '1st commit'
./legit.pl commit -m '2nd commit'
echo something >test01
echo changed >>test01
./legit.pl commit -m '2nd commit'
rm test01
./legit.pl add test01
./legit.pl commit -m '3rd commit'

