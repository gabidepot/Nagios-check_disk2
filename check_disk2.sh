#!/bin/bash

percentchar="%"
percentarg=""
absolutearg=""

# generate arguments for both command types, percent and absolute disk_check command
for param in $1; do
    if [[ "$param" == *"$percentchar"* ]]; then
        percentarg="$percentarg $param"
    else
        absolutearg="$absolutearg $param"
    fi

    if [[ "$param" == *"--path="* ]]; then
        percentarg="$percentarg $param"
    fi
        if [[ "$param" == *"--exclude"* ]]; then
      percentarg="$percentarg $param"
    fi
done

#get both outputs for percent and absolute disk_check
percentcmd=$(/usr/lib/nagios/plugins/check_disk $percentarg )
absolutecmd=$(/usr/lib/nagios/plugins/check_disk $absolutearg )

#echo percentarg $percentarg
#echo absolutearg $absolutearg
#echo percentcmd $percentcmd
#echo absolutecmd $absolutecmd
#echo .

#obscure algorithm :
# absolute values will always be smaller than percent values, no matter the disk size; for small disks, percent and absolute values are pretty close so either is correct;
# for large disks percent is way larger than absolute value so percent will get trigger first but we want the absolute trigger instead

# if percent is triggered, we choose absolute response since for small disk both are almost the same and for large disks only absolute is ok
# if percent is OK and absolute is not ok, the disk must be very small, otherwise we don't have an alert (percent and absolute is green)

if [[ "$percentcmd" != *"DISK OK"* ]]; then
        echo $absolutecmd | sed 's/; /;\\n/g' | sed 's{: /{: \\n/{g'
        exit
else
  if [[ "$absolutecmd" != *"DISK OK"* ]]; then
    echo $percentcmd | sed 's/; /;\\n/g' | sed 's{: /{: \\n/{g'
    exit
  else
    echo $absolutecmd | sed 's/; /;\\n/g' | sed 's{: /{: \\n/{g'
    exit
  fi
fi
