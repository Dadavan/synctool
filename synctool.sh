#!/bin/bash

MENU="[NUM] Manage single Backup\n[b] Backup all Paths\n[a] Add new Path\n[e] Exit\n"
# Placeholders - will be moved to .cfg file in future
FILEDB="/home/dada/projects/synctool/file.db"
SYNCDB="/home/dada/projects/synctool/sync.db"
IP="18.156.66.217"

# Creates a dynamic title depending on what menu your'e viewing
function title {
	# Sub titles are set in the caller function
	TITLE="SyncTool $TITLE1 $TITLE2" 
	# Number of underline characters needed
	NUM=`echo $TITLE | wc -m`
	NUM=`expr $NUM - 1`
	
	arr=()
	for ((i=1; i<=$NUM; i++)) ; do 
		arr+=( "$i" ) 
	done
	echo -e "$TITLE" 
	/usr/bin/printf '-%.0s' "${arr[@]}" ; echo -e "\n"
}
ש
# Main backup menu based on contents of sync.db
function main_menu {
	clear
	title
	cat $SYNCDB 
	echo -e $MENU
        read -p "Choose an Option: " OPTION
}

# Backup versioning menu - called in the body of the script
function version_menu {
	# Gets backup name from sync.db
	FOLDER=`sed $OPTION'q;d' $SYNCDB | awk '{print $2}' | awk -F "/" '{print $NF}'`
	TITLE1=`echo "-> $FOLDER"`
	# SSH to remote server to get all versions of the backup
	VER_MENU=`sudo -u sync ssh $IP "ls -ltr /tmp/backup | grep -w $FOLDER" | awk -F " " '{print $9}'`
	VER_ARR=($VER_MENU)
	TOT_VER=${#VER_ARR[@]}

	clear	
	# Version menu will loop until user inputs 'm'
	while [[ $VER_OPT != "m" ]] && [[ $VER_OPT != "M" ]] ; do
		title 
		COUNTER=1
		# Prints the version menu
                for VER in $VER_MENU ; do
                	echo -e "$COUNTER|\t$VER"
                        COUNTER=$((COUNTER+1))
                done

                echo -e "\n[NUM] View version files\n[m] Return to Main Menu\n"
                read -p "Choose an Option: " VER_OPT ; echo $VER_OPT
		# Calls file_menu if the input version number is valid
		if [ $VER_OPT -le $TOT_VER 2> /dev/null ] ; then
			file_menu
		elif [ $VER_OPT != "m" ] && [ $VER_OPT != "M" ] ; then
			echo "Invalid"
		fi
	done

	unset VER_OPT
	unset TITLE1
}

# File menu - shows the files contained in the selected version
function file_menu {
	clear
	# File menu will loop until user inputs 'm'
	while [[ $FILE_OPT != "m" ]] && [[ $FILE_OPT != "M" ]] ; do
		echo -e "$VER_OPT"
		TITLE2=`echo "-> ${VER_ARR[$VER_OPT-1]}"`
		clear
		title
		sudo -u sync ssh $IP "ls -ltr /tmp/backup/${VER_ARR[$VER_OPT-1]}" ; echo
		echo -e "\n[d] Delete Files\n[m] Return to version Menu\n"
		read -p "Choose an Option:  " FILE_OPT ; echo
		# Calls file_delete if user inputs 'd'
		if [[ $FILE_OPT == "d" ]] || [[ $FILE_OPT == "D" ]] ; then
			file_delete
		elif [ $FILE_OPT != "m" ] && [ $FILE_OPT != "M" ] ; then
			echo "invalid"
		fi

		clear
		unset TITLE2
	done

	unset FILE_OPT
}

# Deletes input files from selected backup version
function file_delete {
	read -p "Files to be deleted, seperated by Space: " DELETE ; echo
	DEL_ARR=($DELETE)
	# Shows designated files on remote server
	DELCHK=`sudo -u sync ssh $IP "ls -ltr /tmp/backup/${VER_ARR[$VER_OPT-1]}" | awk '{print $9}'`
	DELCHK_ARR=($DELCHK)
	ITER_VER=${VER_ARR[$VER_OPT-1]}
	# Iterates over files to be deleted
	for file in ${DEL_ARR[@]} ; do
		# Deletes the files after checking that they exist on remote server
		if [[ " ${DELCHK_ARR[@]} " =~ " ${file} " ]] ; then
			sudo -u sync ssh $IP "rm -f /tmp/backup/$ITER_VER/$file" && echo -e "$file Deleted"
		else
			echo -e "$file not Found"
		fi
	done

	echo ; read -p "Done, press any key to Return..."
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
	# Enters version menu if user input points to an existing backup
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
