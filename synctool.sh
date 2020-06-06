#!/bin/bash

FILEDB="/home/dada/projects/synctool/file.db"
SYNCDB="/home/dada/projects/synctool/sync.db"
MENU="[NUM] Manage single Backup\n[b] Backup all Paths\n[a] Add new Path\n[e] Exit\n"
IP="3.124.181.124"

function title {
	TITLE="SyncTool $TITLE1 $TITLE2"
	NUM=`echo $TITLE | wc -m`
	NUM=`expr $NUM - 1`
	arr=()
	for ((i=1; i<=$NUM; i++)) ; do 
		arr+=( "$i" ) 
	done
	echo -e "$TITLE" 
	/usr/bin/printf '-%.0s' "${arr[@]}" ; echo -e "\n"
}

function main_menu {
	clear
	title
	cat $SYNCDB 
	echo -e $MENU
        read -p "Choose an Option: " OPTION
}

function version_menu {
	FOLDER=`sed $OPTION'q;d' $SYNCDB | awk '{print $2}' | awk -F "/" '{print $NF}'`
	TITLE1=`echo "-> $FOLDER"`
	VER_MENU=`sudo -u sync ssh $IP "ls -ltr /tmp/backup | grep -w $FOLDER" | awk -F " " '{print $9}'`
	VER_ARR=($VER_MENU)
	TOT_VER=${#VER_ARR[@]}

	clear	
	while [[ $VER_OPT != "m" ]] && [[ $VER_OPT != "M" ]] ; do
		title 
		COUNTER=1
                for VER in $VER_MENU ; do
                	echo -e "$COUNTER|\t$VER"
                        COUNTER=$((COUNTER+1))
                done

                echo -e "\n[NUM] View version files\n[m] Return to Main Menu\n"
                read -p "Choose an Option: " VER_OPT ; echo
		file_menu
	done

	unset VER_OPT
	unset TITLE1
}

function file_menu {
	clear
	if [ $VER_OPT -le $TOT_VER 2> /dev/null ] ; then
		TITLE2=`echo "-> ${VER_ARR[$VER_OPT-1]}"`
		clear
		title
		sudo -u sync ssh $IP "ls -ltr /tmp/backup/${VER_ARR[$VER_OPT-1]}" ; echo
		read -p "[KEY] Return to version Menu "
		clear
	elif [ $VER_OPT != "m" ] && [ $VER_OPT != "M" ] ; then
		echo "Invalid"
	fi
	unset TITLE2
}

function backup_all {
	echo
}

function add_backup {
	echo
}

function exit_ {
	echo "Exiting..."
}

function invalid {
	read -p "Invalid option"
}

while [[ $OPTION != "e" ]] && [[ $OPTION != "E" ]] ; do
	main_menu
	if [[ $OPTION =~ ^[0-9]+$ ]] ; then
		version_menu
	elif [ $OPTION = "b" ] || [ $OPTION = "B" ] ; then
		backup_all
	elif [ $OPTION = "a" ] || [ $OPTION = "A" ] ; then
		add_backup
	elif [[ $OPTION = "e" ]] || [[ $OPTION = "E" ]] ; then
		exit_
	else
		invalid
	fi
done
