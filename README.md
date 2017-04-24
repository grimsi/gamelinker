# TS-Automute - beta4

* This script will allow you to automatically mute players on your [TTT](http://ttt.badking.net/)-Server in Teamspeak³ thus prevent ghosting.*

This particular version is still in beta Stage!

# Installation:

* Move "gmsv_bromsock_win32.dll" (Windows) or "gmsv_bromsock_linux.dll" (Linux) to the folder "garrysmod\lua\bin" (you may have to create this folder)
* Move "ts-automute.lua" and the "ts-automute" folder to the folder "garrysmod\lua\autorun\server"
* Edit the "config.txt" in the "ts-automute" folder
* Start the server

If you experience any errors, please look at your server log and create an issue on GitHub

# Known Bugs

* Nicknames with special characters will cause errors (Teamspeak does not support all special characters steam supports)

# Troubleshooting

* If your server uses Linux instead of Windows (very likely if your server is rented), download the correct *.dll from [here](https://github.com/Bromvlieg/gm_bromsock/tree/master/Builds) (please use a "nossl" version)
* "\[TS-Automute\] Player with nick "NICKNAME" uses illegal Characters in his name!" -> Not all special Characters are supported (some may will be in future versions)
* "Couldn't include file 'includes/modules/bromsock.lua' (File not found) (@lua/autorun/server/ts-automute.lua (line 1))" -> Make sure the *.dll is in the correct folder

Congrats, you're done :)

Please report bugs, suggestions etc. here in GutHub (under "[issues](https://github.com/grimsi/gamelinker/issues))".

At the moment im pretty busy, so please be patient :)
