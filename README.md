Steam-Auto-Update-Disabler
==========================

Disables auto updates for all steam games in a steam library. It should save you some time when you have a large library in which you would like to prevent all automatic updates.

Note:
This will not disable Steam client updates. It only changes each game's auto update setting to "Do not automatically update this game.". Also it's been said on internet forums that the built in method to disable steam auto updates may not be working properly. This script just automates using that feature.

Instructions For use:
Just drop a steam library onto the script "disable.cmd" or if you have file extensions hidden, "disable". The steam library would be the folder which contains both steamapps and userdata folders.

It will create backups of the files it makes changes to. The backups will go in an "acf-backups" folder in the library you dropped on the script.


KNOWN ISSUES:

- If a game is set to "High Priority - Always update this game ASAP" in Steam, it's update setting will not be changed. This is both a security feature in case you really must update those games and an oversight. ;p
