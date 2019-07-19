#!/bin/bash
if [ "$UPDATE" == "YES" ];then
	list=`wget -qO- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt|awk NF|sed ":a;N;s/\n/,/g;ta"`
	echo $list > /tmp/list.txt
	if [ -e "/tmp/list.txt" ];then
		oldlist=`cat /tmp/oldlist.txt`
		if [ $list == $oldlist ];then
			echo load trackers-list
		else
			if [ -z "`grep "bt-tracker" /config/aria2.conf`" ]; then
				sed -i '$a bt-tracker='${list} /config/aria2.conf
				echo "add trackers-list"
			else
				sed -i "s@bt-tracker.*@bt-tracker=$list@g" /config/aria2.conf
				echo "update trackers-list"
			fi
			mv /tmp/list.txt /tmp/oldlist.txt
		fi
	else
		echo "Network Timeout..."
	fi
else
	echo "load trackers-list"
fi