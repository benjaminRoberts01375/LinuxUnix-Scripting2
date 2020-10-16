#!/bin/bash

#date 10/14/20
#file scripting2.sh
#brief Creating/Configuring accounts from emails
#author benjamin.roberts01
#lecture: Scripting Lab 2


#Functions

#Brief: Displays usage of script
displayUsage()
{
        echo "$0 usage: [-f input file]"
}

#Brief: Checks to see if user is root
checkForRoot()
{
        if [ $(id -u) != "0" ]; then
                echo "This script must be run as root."
		exit 1
        fi
}

#Brief: Checks usage of script to ensure proper syntax and provided file
checkConditions()
{
	checkForRoot

	if [ ! $1 ] #No flag provided
	then

		displayUsage
		echo 'Error: No flag provided.'
		exit 1

	else #Some flag was given

		if [ "$1" != "-f" ] #Flag given was not -f
		then

			displayUsage
			echo 'Error: "-f" flag must be used.'
			exit 1

		else

			if [ $2 ] #Some path was given
			then

				if [ -d $2 ] #Provided file is directory
				then

					displayUsage
					echo 'Error: Directory was provided instead of file.'
					exit 1

				elif [ ! -f $2 ] #Provided file does not exist
				then

					displayUsage
					echo 'Error: Provided path is not valid or does not exist.'
					exit 1

				fi

			else

				displayUsage
				echo 'Error: File not provided after -f flag.'
				exit 1
			fi
		fi
	fi
}

#Gets the username from an email address
getUserName()
{
	echo "$(echo $1 | cut -d '@' -f 1)"
}

makePasswd()
{
	echo "$(openssl rand -base64 16)"
}


#Main

#Note: $1 = "-f", and $2 is the directory for user files

checkConditions $1 $2

while read LINE
do
	UNAME="$(getUserName $LINE)"
	PASSWD="$(makePasswd)"

	if [ "(cat /etc/passwd | grep $UNAME | wc -l)" == 0 ] #Checking to see if user already exists
	then
		sudo useradd -m -s /bin/bash $UNAME
		echo "$UNAME:$PASSWD" | chpasswd
	fi

	passwd --expire $UNAME

	echo 'Your password is: $PASSWD' | ssmpt $LINE
done < $2
