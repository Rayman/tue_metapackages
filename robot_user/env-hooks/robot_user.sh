alias local-core='unset ROS_MASTER_URI'

####################
#
# Robocup
#
####################

alias topic-monitor='rosrun robot_launch_files topic_monitor */scan */rgbd */joint_states */base/measurements'

####################
# git prompt
#
####################

# source ~/Documents/tools/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
# Explicitly unset color (default anyhow). Use 1 to set it.
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_DESCRIBE_STYLE="branch"
GIT_PS1_SHOWUPSTREAM="auto git"

# PROMPT_COMMAND='__git_ps1 "[\[\033[01;34m\]\w\[\033[00m\]]" "\n'\
# '${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\$ "'


function ROS_MASTER_NAME {
    ROS_MASTER=$(echo $ROS_MASTER_URI | sed 's#http://\(.*\):.*#\1#')
    if [ "$ROS_MASTER" == "localhost" ] || [ "$ROBOT_REAL" == "true" ]; then
        echo ""
    else
        echo "($ROS_MASTER-core) "
    fi
}

PS1='[\[\033[01;34m\]\w\[\033[00m\]]$(__git_ps1)\n'\
'$(ROS_MASTER_NAME)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \$ '

alias scores='scp amigo@192.168.44.110:/home/amigo/database/per_challenge/scores.html /tmp/scores.html && google-chrome /tmp/scores.html'

function github-cache-credentials() {
    if [[ -z $1 ]]
    then
        echo -e "Usage: github-cache-credentials <counter><minutes,hours,days,weeks> like 10m, 1h,..."
    else
    input=$1
		counter=${input//[^0-9]/} #keep number
		time_type=${input//[^a-zA-Z]/} #keep letters

		if [ $time_type == "m" ] || [ $time_type == "min" ]
		then
			echo -e "I will remember your credentials for $counter minutes"
			counter=$(( counter * 60 ))
			git config --global credential.helper "cache --timeout=$counter"
		elif [ $time_type == "h" ] || [ $time_type == "hour" ] || [ $time_type == "hours" ]
		then
			echo -e "I will remember your credentials for $counter hours"
			counter=$(( counter * 60 * 60 ))
			git config --global credential.helper "cache --timeout=$counter"
		elif [ $time_type == "d" ] || [ $time_type == "day" ] || [ $time_type == "days" ]
		then
			echo -e "I will remember your credentials for $counter days"
			counter=$(( counter * 60 * 60 *24 ))
			git config --global credential.helper "cache --timeout=$counter"
		elif [ $time_type == "w" ] || [$time_type == "week" ] || [ $time_type == "weeks" ]
		then
			echo -e "I will remember your credentials for $counter weeks"
			counter=$(( counter * 60 * 60 * 24 * 7 ))
			git config --global credential.helper "cache --timeout=$counter"
		else
			echo -e "Incorrect inputs"
		fi
	fi
}

####################
#
# ROS_IP
#
####################

# Set the ROS_IP if we are on the 192.168.*.* range and not on the real robot
if [ ! $ROBOT_REAL ] ; then
	if `hostname -I | grep -q 192.168.` ; then
		export ROS_IP=`hostname -I | sed 's/.*\(192\.168\.[0-9]\+\.[0-9]\+\).*/\1/'`
	fi
fi

# DECLARE ALIAS FOR QUICK SSHf
alias quickssh='echo "ControlMaster auto
ControlPath /tmp/%r@%h:%p
ControlPersist yes" > ~/.ssh/config'
