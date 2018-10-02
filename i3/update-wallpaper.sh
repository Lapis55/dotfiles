#!/bin/sh
if [ $$ != $(pgrep -fo $(basename $0)) ]; then
    exit 0
fi

interval=1 # update interval
imgPath=~/Dropbox/backdrops/ # backdrops directory
imgs=(`find $imgPath -type f -regextype sed -regex ".*\.\(png\|jpg\|jpeg\)"`)
len=${#imgs[@]}

while true
do
    rand=$(($RANDOM % $len))
    feh --bg-fill ${imgs[$rand]}
    sleep $interval
done
