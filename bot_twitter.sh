#!/bin/bash
#Set temp file location
        bot_files="/home/admin/projects/discord_bots/twitter"
#Collect all required twitter clients
        twitter_profiles=$(sqlite3 /home/admin/projects/discord_bots/hooks.db "select subreddit from clients where source = 'twitter' and enabled = 'yes';")
#Create cache folders for each twitter profile we'll be fetching
        for str in ${twitter_profiles[@]}; do
                if [ ! -d "$bot_files/$str" ]
                then
                        mkdir $bot_files/$str
                fi
#Collect hooks that need this twitter_profile
        hooks=$(sqlite3 /home/admin/projects/discord_bots/hooks.db "select discord_webhook from clients where subreddit = '$str' and enabled = 'yes';")
#Pull dump from nitter. Uncomment one wget line. Swap lines if outage.
#More instances available here: https://github.com/xnaas/nitter-instances/blob/master/README.md
#wget -L "https://nitter.net/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 722
#wget -L "https://nitter.ca/$str/rss" -O $bot_files/$str/dump #Uptime 69.86%, ping 182
#wget -L "https://nitter.fly.dev/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 226
#wget -L "https://twitter.censors.us/$str/rss" -O $bot_files/$str/dump #Uptime 97.4%, ping 539
#wget -L "https://notabird.site/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 186
#wget -L "https://nitter.bus-hit.me/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 228
#wget -L "https://nitter.mint.lgbt/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 473
#wget -L "https://fuckthesacklers.network/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 259
#wget -L "https://nitter.esmailelbob.xyz/$str/rss" -O $bot_files/$str/dump #Uptime 100%, ping 372
        wget -L "https://nitter.1d4.us/$str/rss" -O $bot_files/$str/dump #Uptime 99.6%, ping 284
#Build status ID Cache from nitter dump
        cat $bot_files/$str/dump | grep -Eo "status/[a-zA-Z0-9./?=_%:-]*#m" | sed s/"status\/"// | sed s/"#m"// | uniq > $bot_files/$str/urlcache
#Get latest tweet ID from urlcache
        tweet=$(head -n 1 $bot_files/$str/urlcache)
#Build latest URL
        url="https://twitter.com/$str/status/$tweet"
#Collect old url if it exists
        oldurl=$(head -n 1 $bot_files/$str/oldurl)
#If usedurls file doesn't exist, create it
        if [[ ! -e $bot_files/$str/usedurls ]]; then
                touch $bot_files/$str/usedurls
        fi
#If URL has recently been sent to discord, skip it, otherwise, resume
        for hook in ${hooks[@]}; do
                if ! grep -q "$url" $bot_files/$str/usedurls; then
                        curl -d "{\"content\": \"$url\"}" -H "Content-Type: application/json" "$hook"
                fi
        done
#if usedurls doesn't have current url in it, ad it at top of the file
        if ! grep -q "$url" $bot_files/$str/usedurls; then
                (echo "$url" && cat $bot_files/$str/usedurls) > $bot_files/$str/usedurls.temp && mv $bot_files/$str/usedurls.temp $bot_files/$str/usedurls
        fi
#Set oldurl file to newurl before exiting script
        if [ "$url" != "$oldurl" ]; then
                echo "$url" > $bot_files/$str/oldurl
        fi
#prune usedurls cache. If more than 10 lines, remove last line in the file
        if [[ $(cat $bot_files/$str/usedurls | wc -l) > 10 ]]; then
                sed -i '$ d' $bot_files/$str/usedurls
        fi
        done #Closes for loop started on line 7
#Dumps vars for when manually running/testing script
        echo "Hooks: $hooks"
        echo "URL: $url"
        echo "oldurl: $oldurl"
