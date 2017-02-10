# Gamelinker - v1.0

*This script will allow you to automatically mute players on your [TTT](http://ttt.badking.net/)-Server in Teamspeak³ thus prevent ghosting.*

The current version is fully functional, but has some major flaws (Server side script + client side script) which now can hopefully be resolved because the "[gmod_luasocket](https://github.com/danielga/gmod_luasocket)" library allows GMod to directly connect to your TS Server Query.

# Installation (v 1.0):

* copy "gmod_script.lua" to "...Insert_your_path_here...\garrysmod\lua\autorun\server" (on the server, **not** your PC!)
* copy the rest of the "TS-Script" folder somewhere
* create a channel on your TS-Server which requires join and talk power
* get the ID of the channel (use the "channellist" command)
* all users on your TS have to use the **exact** same name in TTT for the script to work properly (may be changed in the future)
* the moment a players spawns on the TTT-Server he will automatically be moved to the channel you created, preventing players that aren't on your TTT-Server from joining
* now edit the "config.txt" and adjust the variables to your values
* start your TTT-Server
* last, but not least start "ts_script.exe" (located in the "TS-Script" folder)

# Troubleshooting

* If it shows an error like "socket.core" not found, install this: [Lua for Windows](http://luaforge.net/projects/luaforwindows/)
* If the script starts, but doesn't connect to your TS-Query, check if the values in your config.txt are the correct ones
* If the script works fine, but certain players aren't recognized, make sure they have the **exact** same name in TTT and TS

Congrats, youre done :)

Please report bugs, suggestions etc. here in GutHub (under "[issues](https://github.com/grimsi/gamelinker/issues)".

At the moment im pretty busy, so please be patient :)
