# Description
#   A hubot script that receives and shows icinga2 notification in the chat-room
#
# Configuration:
#   HUBOT_ICINGA2_TOKEN it is the token set by hubot, and the same should be used by the icinga2 notificaiton 
#   HUBOT_ICINGA2_NOTIFICATION_PRE It is the prefix that should be added to the notification (optianl)
#
# Commands:
#   None
#
# Notes:
#   This script only works with the combination of settings in icinga2, please consult the documentation for
#   furthur information
#
# Author:
#   Pouyan Azari <pouyan.azari@uni-wuerzburg.de>

# Requirements
url = require('url')
querystring = require('querystring')

# ENV variables
token_set = process.env.HUBOT_ICINGA2_TOKEN
notification_pre = if process.env.HUBOT_ICINGA2_NOTIFICATION_PRE then process.env.HUBOT_ICINGA2_NOTIFICATION_PRE else "Icinga2 Norification: " 

module.exports = (robot) ->
  robot.router.post "/hubot/icinga2/:room", (request, response) ->
    room = request.params.room
    data = if request.body.payload? then JSON.parse request.body.payload else request.body
    token = data.token
    message = data.message
    user = {}
    user.room = room if room
    try
       if token_set == token
        robot.send user, notification_pre  + message
        response.end "{'status':'success', 'message':'your message is successfully propated'}"
       else
        response.end "{'status':'error', 'message':'the given token is wrong'}"

    catch error
      console.log "message-listner error: #{error}."
      response.end "{'status':'error', 'message':'unknown error, check the logs'}"