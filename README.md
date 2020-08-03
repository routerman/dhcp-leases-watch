# dhcp-leases-watch

lua 5.1.5

## install

   $ git clone https://github.com/routerman/dhcp-leases-watch
   $ cd dhcp-leases-watch/
   $ vim main.lua
   test=false
   slack_url=<Set Slack Webhook Url>

   $ cp ignore.sample ignore
   $ vim ignore

## crontab

   $ crontab -l
   * * * * * cd /path/to/dhcp-leases-watch; lua main.lua > /dev/null

