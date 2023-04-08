# Summary
This bot is fully written in linux shell (`.sh scripting`) and will run natively on most systems. Developed and running on a RaspberryPI and has been feeding discord servers for over a year. The only dependencies in place are pulling from nitter sites (Twitter mirror's, kind of. Check out `https://github.com/zedeus/nitter`) and using sqlite by preference, although you can tweak the code to simply store your servers/webhooks in a text file if you'd rather not install sqlite.

Why nitter? Because twitter itself is locked down pretty tightly, but nitter sites are up to date to the second and re-use tweet/content identifiers, so the script pulls what it needs from nitter sites then uses those identifiers to post direct twitter links to discord. Unavoidable requirement so far, but if you manage to figure out a way to skip nitter, let me know, I'd love to remove that dependency.

# Where do the images get sourced from?
Any twitter profile you specify

# Can I see the bot in action?
Yea, the bot is currently feeding many servers, but you can see it in action on my discord server ([DISCORD.D4NG3R.COM](https://discord.d4ng3r.com)) in `PATREON > #demo-twitter-cnn`

# Usage 
(Under the assumption you installed sqlite and have created a database structured like `DiscordBotDB.png`)
- Ensure you add your discord webhook URL to your sqlite db (See `DiscordBotDB.png`)
- Pull the SH script to your run location (I just run it from user folder `/home/<user>/projects/discord_bots/twitter` but you can run it from anywhere.)
- Set the `hooks` var (line 4) to specify DB/Table/Data selections
- Set the `bot_files` var (line 8), this tells the bot where to cache used URLs
- Set the bot to run however you like. I have it set to run every 5 minutes via CRON (Example below)
-- Cron file: `/etc/cron.d/run_all_discord_bots`
-- Cron file contents: `*/5 * * * * root /home/admin/projects/discord_bots/reddit/bot_twitter.sh`

***NOTE: If using sqlite, see `DiscordBotDB.png` for table structure this bot expects
