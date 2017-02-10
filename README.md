# Gamelinker - v1.0

*This script will allow you to automatically mute players on your TTT-Server in Teamspeak³ thus prevent ghosting.*

The current version is fully functional, but has some major flaws (Server side script + client side script) which now can hopefully be resolved because the "gmod_luasocket" (https://github.com/danielga/gmod_luasocket) library allows GMod to directly connect to your TS Server Query.

# Installation (v 1.0):

* copy "gmod_script.lua" to "...Insert_your_path_here...\Steam\steamapps\common\steamcmd\gmod\garrysmod\lua\autorun\server"
* copy the rest of the "TS-Script" folder somewhere
* create a channel on your TS-Server which requires join and talk power
* get the ID of the channel (use the "channellist" command)
* all users on your TS have to use the # exact# same name in TTT for the script to work properly (may be changed in the future)
* the moment a players spawns on the TTT-Server he will automatically be moved to the channel you created, preventing players that aren't on your TTT-Server from joining
* now edit the "config.txt"
* adjust the variables to your values
* start your TTT-Server
* last, but not least start "ts_script.exe" (located in the "TS-Script" folder)

# Troubleshooting

* If is shows an error like "socket.core" not found, install this: http://luaforge.net/projects/luaforwindows/
* If the script starts, but doesn't connect to your TS-Query, check if the values config.txt are the correct ones
* If the script works fine, but certain players aren't recognized, make sure they have the # exact# same name in TTT and TS


Glückwunsch, nun sollte alles laufen!

Sollte etwas nicht gehen, öffnet eine Issue in GitHub und gebt mir eine möglichst genaue Beschreibung.
Allerdings kann es durchaus dauern, bis ich auf reagiere, da ich oft unterwegs bin aufgrund meines Studiums/Arbeit.
