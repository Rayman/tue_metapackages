#!/bin/bash

export ROBOT_BRINGUP_PATH=$TUE_SYSTEM_DIR/src/amigo_bringup

alias amigo-get-and-view-pdf-from-amigo1-home='mkdir -p ~/amigo1pdf && cd ~/amigo1pdf && scp amigo1:~/*.pdf . && evince *.pdf'
alias amigo-core='export ROS_MASTER_URI=http://amigo1:11311'

# ----------------------------------------------------------------------------
# - Add scripts directory to PATH
export PATH=~/.tue/installer/targets/amigo-user/scripts:$PATH

####################
#
# LOCAL PUBLISHERS
#
####################

alias amigo-publish-ed='rosrun ed_gui_server ed_rviz_publisher /ed/gui/entities:=/amigo/ed/gui/entities ed/gui/query_meshes:=/amigo/ed/gui/query_meshes ed/rviz:=/amigo/world_model'

alias amigo-publish-point-cloud='rosrun rgbd rgbd_to_ros /amigo/top_kinect/rgbd __ns:=amigo'

####################
#
# AUDIO
#
####################

alias amigo-audio-server='rosnode kill /amigo/audio_player && rosrun text_to_speech player.py play:=audio_player/play __ns:=amigo'

function amigo-audio-play
{
    if [ -z "$1" ]
    then
        echo "Please provide audio file."
        return
    fi

    rosrun text_to_speech play.py $1 /amigo/audio_player/play
}

####################
#
# SSH
#
####################
alias sshamigo1='until ssh -qo ConnectTimeout=1 amigo@amigo1; do echo waiting for amigo1 to come online...; sleep 2; done'
alias sshamigo2='until ssh -qo ConnectTimeout=1 amigo@amigo2; do echo waiting for amigo2 to come online...; sleep 2; done'
function connect-to-amigo-subnet
{
    command="sudo ifconfig $(route | grep '^default' | grep -o '[^ ]*$'):0 $(grep -m1 $(hostname) ~/.tue/installer/targets/hosts/hosts | awk '{print $1}') up"
    echo $command
    eval $command
}

#####################
#
# DIAGNOSTICS
#
#####################
alias diag='rosrun robot_monitor robot_monitor'
alias amigo-dashboard='tue-dashboard amigo1 & sleep 1; disown; wmctrl -r ws://amigo1:9090 -b add,sticky'

alias amigo-show-fitter='rosrun rgbd multitool --rgbd /amigo/ed/viz/fitter'
alias amigo-show-kinect='rosrun rgbd multitool --rgbd /amigo/top_kinect/rgbd'

# --------------------------------------------------------------------------------

alias amigo-show-ed-kinect='rosrun rgbd multitool --rgbd /amigo/ed/kinect/viz/update_request'

# --------------------------------------------------------------------------------


####################
#
# AMIGO STARTUP
#
####################

alias amigo='export ROBOT_BRINGUP_PATH=$TUE_SYSTEM_DIR/src/amigo_bringup'

alias amigo-continui='rosrun hmi_server continue_gui.py __ns:=amigo/hmi'
alias amigo-continui-gpsr='rosrun hmi_server continue_gui.py $TUE_SYSTEM_DIR/src/challenge_gpsr/src/grammar_gui.fcfg __ns:=amigo/hmi'

####################
#
# AMIGO ACTIONS
#
####################

alias say='rostopic pub --once /amigo/text_to_speech/input std_msgs/String'
function zeg() {
        rosservice call /amigo/text_to_speech/speak "{language: 'nl', voice: 'david', character: 'default', emotion: 'neutral', sentence: '$@', blocking_call: false}"
}

function amigo-hear() {
    msg=$@
    echo "Sending trigger: $msg"
    rostopic pub --once /amigo/hmi/string std_msgs/String "data: '$msg'";
}
alias hear='amigo-hear'

alias amigo-high='rostopic pub /amigo/torso/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ""}, name: ["torso_joint"], position: [0.35], velocity: [0], effort: [0]}"  --once'

alias amigo-medium='rostopic pub /amigo/torso/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ""}, name: ["torso_joint"], position: [0.2], velocity: [0], effort: [0]}"  --once'
alias amigo-low='rostopic pub /amigo/torso/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ""}, name: ["torso_joint"], position: [0.085], velocity: [0], effort: [0]}"  --once'
alias amigo-case='rostopic pub /amigo/torso/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ""}, name: ["torso_joint"], position: [0.12], velocity: [0], effort: [0]}"  --once'

alias amigo-head-straight='amigo-head-move 0.0 0.0'
alias move-straight="rostopic pub -r 10 /cmd_vel geometry_msgs/Twist  '{linear:  {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0,y: 0.0,z: 0.0}}'"
alias openleftgripper='rostopic pub --once /amigo/left_arm/gripper/references tue_msgs/GripperCommand -- -1 100'
alias openrightgripper='rostopic pub --once /amigo/right_arm/gripper/references tue_msgs/GripperCommand -- -1 100'
alias closeleftgripper='rostopic pub --once /amigo/left_arm/gripper/references tue_msgs/GripperCommand -- 1 100'
alias closerightgripper='rostopic pub --once /amigo/right_arm/gripper/references tue_msgs/GripperCommand -- 1 100'
alias amigo-teleop='rosrun tue_teleop_keyboard teleop_twist_keyboard.py /cmd_vel:=/amigo/base/references'

alias amigo-base-reset-odom='rostopic pub --once /amigo/base/reset_odometry std_msgs/Bool 1'
alias amigo-top-kinect-show='rosrun image_view image_view image:=/amigo/top_kinect/rgb/image_rect_color'
alias reset-audio="amixer -- sset 'Master' -5dB && amixer -- sset 'Mic Boost' 10dB && amixer -- sset 'Capture' 16.50dB && amixer -- sset 'Digital' 3.5dB && amixer -- sset 'Mic' mute
"

alias amigo-action-server="rosrun action_server main.py amigo __ns:=amigo"

function depcheck
{
  type -P $1 &>/dev/null && return
  echo "Installing $2"
  sudo apt-get -y install $2 && return
  echo "Error installing $2"
  exit 1
}

# --------------------------------------------------------------------------------

function amigo-head-move {
    if [ -z "$2" ]; then
        echo "Usage: amigo-head-move PAN TILT"
        return
    fi

    rostopic pub /amigo/neck/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ''}, name: ['neck_pan_joint', 'neck_tilt_joint'], position: [$1, $2], velocity: [0], effort: [0]}"  --once
}

function amigo-torso-move-joints {
    if [ -z "$1" ]; then
        echo "Usage: amigo-torso-move-joints position"
        return
    fi

    ( rostopic pub /amigo/torso/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ''}, name: ['torso_joint'], position: [$1], velocity: [0], effort: [0]}"  --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-right-arm-move-joints {
    if [ -z "$7" ]; then
        echo "Usage: amigo-right-arm-move-joints q1 q2 q3 q4 q5 q6 q7"
        return
    fi

    ( rostopic pub /amigo/right_arm/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ''}, name: ['shoulder_yaw_joint_right', 'shoulder_pitch_joint_right', 'shoulder_roll_joint_right', 'elbow_pitch_joint_right', 'elbow_roll_joint_right', 'wrist_pitch_joint_right', 'wrist_yaw_joint_right'], position: [$1, $2, $3, $4, $5, $6, $7], velocity: [0], effort: [0]}"  --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-right-arm-move-idle {
    amigo-right-arm-move-joints -0.1 -0.35 0.2 1.2 0 0 0
}

# --------------------------------------------------------------------------------

function amigo-left-arm-move-joints {
    if [ -z "$7" ]; then
        echo "Usage: amigo-left-arm-move-joints q1 q2 q3 q4 q5 q6 q7"
        return
    fi

    ( rostopic pub /amigo/left_arm/references sensor_msgs/JointState "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ''}, name: ['shoulder_yaw_joint_left', 'shoulder_pitch_joint_left', 'shoulder_roll_joint_left', 'elbow_pitch_joint_left', 'elbow_roll_joint_left', 'wrist_pitch_joint_left', 'wrist_yaw_joint_left'], position: [$1, $2, $3, $4, $5, $6, $7], velocity: [0], effort: [0]}"  --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-left-arm-move-idle {
    amigo-left-arm-move-joints -0.1 -0.35 0.2 1.2 0 0 0
}

# --------------------------------------------------------------------------------

function amigo-arms-move-idle {
    amigo-right-arm-move-idle
    amigo-left-arm-move-idle
}

# --------------------------------------------------------------------------------

function amigo-left-gripper-open {
    ( rostopic pub /amigo/left_arm/gripper/references tue_msgs/GripperCommand "{direction: -1, max_torque: 100.0}" --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-left-gripper-close {
    ( rostopic pub /amigo/left_arm/gripper/references tue_msgs/GripperCommand "{direction: 1, max_torque: 100.0}" --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-right-gripper-open {
    ( rostopic pub /amigo/right_arm/gripper/references tue_msgs/GripperCommand "{direction: -1, max_torque: 100.0}" --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-right-gripper-close {
    ( rostopic pub /amigo/right_arm/gripper/references tue_msgs/GripperCommand "{direction: 1, max_torque: 100.0}" --once  &> /dev/null & )
}

# --------------------------------------------------------------------------------

function amigo-top-kinect-record-avi {
    filename=$1

    if [ -z $filename ]
    then
        filename=amigo_top_kinect-`date +"%Y-%m-%d-%H-%M-%S"`.avi
    fi

    # Lossless codec: FFV1
    rosrun rgbd record_to_video rgb:=/amigo/top_kinect/rgb/image_color depth:=/amigo/top_kinect/depth_registered/image _fps:=30 _format:=DIVX _filename:=$filename _size:=1
}

alias amigo-copy-my-id="ssh-copy-id amigo@amigo1; ssh-copy-id amigo@amigo2"

alias amigo-presentation-timer-start='rosrun challenge_final time.py __ns:=amigo'

alias amigo-mount-usb='rosrun challenge_storing_groceries mount_usb'
alias amigo-unmount-usb='sudo umount /dev/sdb1'
