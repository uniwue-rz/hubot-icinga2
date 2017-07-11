# hubot-icinga2

A hubot script that receives and shows icinga2 notification in the chat-room

## Installation
In hubot project repo, run:

```bash
npm install hubot-icinga2 --save
```

or add hubot-icinga2 to the hubot package.json dependency file:

```json
dependencies:{
  "hubot-icinga2" : "^0.0.1"
}
```

Then add **hubot-icinga2** to your `external-scripts.json`:

```json
[
  "hubot-icinga2"
]
```

## Configuration
The configuration for the this bot has two parts, one should add the bot in hubot settings and the other configure icinga2 for the notification.

### Hubot
On hubot server you should set the `HUBOT_ICINGA2_TOKEN` environment variable so your icinga2 notifier can send queries. You can also set custom prefixes for the messages posted in the room using `HUBOT_ICINGA2_NOTIFICATION_PRE`. The first variable is mandatory, the second is optional. You should also make hubot to listen on the ip address of your designation and given port using:
```bash
"PORT=8090"
"BIND_ADDRESS=...."
```
Make sure your firewall is not blocking the queries. The hubot will be listening on `/hubot/icinga2/:room` address and it is waiting for the notifications.  

### Icinga2
On Incinga2 server to make the configuration easier, you should have the `icinga2 director` installed. Then you must create a notification command using the notification.sh file. The command can look like this:

```conf
object NotificationCommand "notify-hubot" {
    import "plugin-notification-command"
    command = [ "/etc/icinga2/scripts/service-by-curl.sh" ]
    arguments += {
        "-a" = {
            required = true
            value = "$address$"
        }
        "-b" = "$notification.author$"
        "-c" = "$notification.comment$"
        "-d" = {
            required = true
            value = "$icinga.short_date_time$"
        }
        "-e" = {
            required = true
            value = "\"$service.name$\""
        }
        "-l" = {
            required = true
            value = "$host.name$"
        }
        "-o" = {
            required = true
            value = "$service.output$"
        }
        "-r" = {
            required = true
            value = "$rocketchat_room$"
        }
        "-s" = "$service.state$"
        "-t" = {
            required = true
            value = "$notification.type$"
        }
        "-v" = "$notification_logtosyslog$"
        "-x" = "$hubot_host$"
        "-z" = {
            required = true
            value = "$hubot_token$"
        }
    }
}
```
Add the following parameters in icinga2 director as fields:
```bash
hubot_token (string)
hubot_host (string)
rocketchat_room (string)
```

Then add the command as notification using icinga director by adding a notification template:

```conf
template Notification "generic-service-hubot" {
    command = "notify-hubot"
}
```

and the notification itself:

```conf
apply Notification "Status Alarm to Hubot" to Service {
    import "generic-service-hubot"

    interval = 0s
    assign where match("*", service.name)
    types = [ Problem, Recovery ]
    users = [ "admin" ]
    vars.hubot_host = "http://yourhost:8090/hubot/icinga2/"
    vars.hubot_token = "token"
    vars.rocketchat_room = "general"
}

```

## NPM Module
https://www.npmjs.com/package/hubot-icinga2

## License
See LICENSE file
