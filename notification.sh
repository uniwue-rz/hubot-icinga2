#!/bin/bash
##
# The notification script that can be used to send messages to hubot-icinga2
# 
# @author Pouyan Azari <pouyan.azari@uni-wuerzburg.de>
# @license MIT
###

PROG="`basename $0`"
HOSTNAME="`hostname`"

function Usage() {
cat << EOF
hubot-notify-script, this method has one of the following options: \n

-a is the address of the host whose notification is sent \n
-b is the author of the notificaiton \n
-c is the comment for the given notificaiton \n
-d is the date and time of the notification \n
-e is the name of the service getting the notification \n
-h is the usage of the notification \n
-l is the host alis for the notification \n
-o is the output of the service command \n
-x is the hubot host getting the notification \n
-r is the rocketchat room receiveing the notification \n
-s is the state of the service receiveing the notification \n
-t is the type of the notification \n
-z is the hubot token for the given notification \n
EOF
exit 1;
}

while getopts a:b:c:d:e:hi:l:o:r:s:t:x:z: opt
do
  case "$opt" in
    a) HOSTADDRESS=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) DATE=$OPTARG ;;
    e) SERVICENAME=$OPTARG ;;
    h) Usage ;;
    i) HAS_ICINGAWEB2=$OPTARG ;;
    l) HOSTALIAS=$OPTARG ;;
    o) SERVICEOUTPUT=$OPTARG ;;
    r) ROCKETCHATROOM=$OPTARG ;;
    s) SERVICESTATE=$OPTARG ;;
    t) NOTIFICATIONTYPE=$OPTARG ;;
    x) HUBOTHOST=$OPTARG ;;
    z) HUBOTTOKEN=$OPTARG ;;
   \?) echo "ERROR: Invalid option -$OPTARG" >&2
       Usage ;;
    :) echo "Missing option argument for -$OPTARG" >&2
       Usage ;;
    *) echo "Unimplemented option: -$OPTARG" >&2
       Usage ;;
  esac
done

shift $((OPTIND - 1))
NOTIFICATION_MESSAGE=`cat << EOF
***** Icinga 2 Service Monitoring on $HOSTNAME *****

==> $SERVICENAME is $SERVICESTATE! <==

When?    $DATE
Service? $SERVICENAME
Host?    $HOSTALIAS ($HOSTADDRESS)
Info?    $SERVICEOUTPUT
EOF
`

## Are there any comments? Put them into the message!
if [ -n "$NOTIFICATIONCOMMENT" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE

Comment by $NOTIFICATIONAUTHORNAME:
  $NOTIFICATIONCOMMENT"
fi

## Are we using Icinga Web 2? Put the URL into the message!
if [ -n "$HAS_ICINGAWEB2" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE

Get live status:
  $HAS_ICINGAWEB2/monitoring/service/show?host=$HOSTALIAS&service=$SERVICENAME"
fi
URL="$HUBOTHOST/hubot/icinga2/$ROCKETCHATROOM

#/usr/bin/curl -F "token=$HUBOTTOKEN" -F "message=$NOTIFICATION_MESSAGE" -vvvv -X POST $URL  --trace-ascii /dev/stdout  # For debug use this
/usr/bin/curl -F "token=$HUBOTTOKEN" -F "message=$NOTIFICATION_MESSAGE" -X POST $URL
