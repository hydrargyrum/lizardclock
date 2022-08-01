# Lizard Clock

Lizard Clock is an open-source shell reimplementation of Chameleon Clock.

It's a themable app for creating wallpapers with date and time information.
Themes are available as files with .wcz extension.

## usage

`lizardclock-currenttime.sh FILE.WCZ` renders theme from `FILE.WCZ` to a wallpaper in `output.png`.

## periodic run

Run lizardclock-currenttime.sh every minute with this crontab entry:

```
* * * * * /path/to/lizardclock-currenttime.sh /path/to/file.wcz
```

Setting the wallpaper is done differently depending on the desktop environment.
Some DEs will even notice when the wallpaper file has changed and update the desktop immediately.
