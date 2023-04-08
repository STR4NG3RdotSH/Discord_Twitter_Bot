#!/bin/bash
#Set temp file location
bot_files="/home/admin/projects/discord_bots/reddit"
#Enable/Disable showing URL in discord post (1=on, 0=off)
show_url="0"
#Toggle quality vs quantity (Occassional good meme vs endless flow of highly likely unfunny memes)
flow="quality" #(possible values: quality/quantity)
#Collect all required subreddits
subreddits=$(sqlite3 /home/admin/projects/discord_bots/hooks.db "select subreddit from clients where source = 'reddit' and enabled = 'yes';")
for str in ${subreddits[@]}; do
    #Make temp file directory if it doesn't exist
    if [ ! -d "$bot_files/$str" ] 
        then
            mkdir $bot_files/$str
    fi
#Collect hooks that need this subreddit
hooks=$(sqlite3 /home/admin/projects/discord_bots/hooks.db "select discord_webhook from clients where subreddit = '$str' and enabled = 'yes';")
#Pull and isolate latest image: reddit/r/{subreddit}
if [ "$flow" = "quality" ]; then
        wget -L "https://www.reddit.com/r/$str/hot.rss" -O $bot_files/$str/dump
    else
        wget -L "https://www.reddit.com/r/$str/new.rss" -O $bot_files/$str/dump
fi
cat $bot_files/$str/dump | grep -Eo "//(i.redd.it)[a-zA-Z0-9./?=_%:-]*(jpg|gif|png|jpeg)" | uniq > $bot_files/$str/urlcache
url="https:$(head -n 1 $bot_files/$str/urlcache)"
oldurl=$(head -n 1 $bot_files/$str/oldurl)
#Check if show_url is enabled:
if [ "$show_url" = "1" ]; then
        addstr=" : "
    else
        addstr=""
fi
    #Dump latest meme from each source into each listed discord webhook (URL array at top)
    for hook in ${hooks[@]}; do
        if [ "$url" != "$oldurl" ]; then
            curl -d "{\"content\": \"$url$addstr\"}" -H "Content-Type: application/json" "$hook"
        fi
    done
#Set cached URLs to old urls to ensure the same meme's don't get repeatedly added to discord channels
if [ "$url" != "$oldurl" ]; then
    echo "$url" > $bot_files/$str/oldurl
fi
done
