#!/bin/bash

tar -czf bck-one.tar.gz ~/Documents ~/.ssh-encrypted 
#scp bck-one.tar.gz christiang@alpha:/mnt/4TB/christiang
scp bck-one.tar.gz one-ofi:/mnt/4TB/christiang
rm bck-one.tar.gz
