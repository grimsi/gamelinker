require("bromsock")
local socket = BromSock(BROMSOCK_TCP)
local packet = BromPacket()

--loads variables from "config.txt"
local config = util.JSONToTable(file.Read("autorun\\server\\ts-automute\\config.txt", "LUA"))
MsgC( Color( 0, 255, 0 ), "[TS-Automute] Loaded config\n" )

local roundHasEnded = false
local roundIsPreparing = true
local playerConnected = ""
local playerDisconnected = ""
local isDebug = false

-- process answer from TeamSpeak
socket:SetCallbackReceive(function(sock, receivedPacket)
    local receivedPacket = receivedPacket:ReadUntil("\n"):Trim()
    if string.find(receivedPacket, "clid") then
        local clid = string.sub(receivedPacket, string.find(receivedPacket, "clid=")+5, string.find(receivedPacket, " "))
        local nick = string.sub(receivedPacket, string.find(receivedPacket, "client_nickname=")+16, string.len(receivedPacket))
        
        -- the player disconnected
        if playerDisconnected ~= "" then
            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=0\n")
            socket:Send(packet, true)
            playerDisconnected = ""
            if isDebug then
                MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] [PlayerDisconnected] Player "..nick.." is no talker.\n")
            end
        -- the player connected
        elseif playerConnected ~= "" then
            packet:WriteStringRaw("clientmove clid="..clid.." cid="..config["channel-id"].."\n")
            socket:Send(packet, true)
            if isDebug then
                MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] [PlayerConnected] Moved Player "..nick.." to right channel.\n")
            end
            
            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=0\n")
            socket:Send(packet, true)
            if isDebug then
                MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] [PlayerConnected] Player "..nick.." is talker.\n")
            end
            playerConnected = ""
        -- the round has ended and all players get talkpower
        elseif roundHasEnded == true then
            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=1\n")
            socket:Send(packet, true)
            if isDebug then
                MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] [RoundHasEnded] Player "..nick.." is talker.\n")
            end
        -- the player is still alive
        elseif playerIsAlive(nick) then
            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=1\n")
            socket:Send(packet, true)
            if isDebug then
                MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] [PlayerIsAlive] Player "..nick.." is talker.\n")
            end
        -- the player is dead
        else
            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=0\n")
            socket:Send(packet, true)
            if isDebug then
                MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Player "..nick.." is no talker.\n")
            end
        end
    -- player could not be found on TeamSpeak
    elseif string.find(receivedPacket, "error id=512") then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] Player could not be found!\n")
    end
    socket:ReceiveUntil("\n")
end)

socket:SetCallbackConnect(function(sock, success, ip, port)
    if (success) then
        socket:ReceiveUntil("\n")

        -- login as admin
        packet:WriteStringRaw("login "..config["username"].." "..config["password"].."\n")
        socket:Send(packet, true)
        
        -- chooses which V-Server to use
        packet:WriteStringRaw("use "..config["server"].."\n")
        socket:Send(packet, true) 

        MsgC( Color( 0, 255, 0 ),"[TS-Automute] Connection to TeamSpeak sucessfully established!\n")
    else
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] Connection to TeamSpeak could not be established!\n")
    end
end)

socket:Connect(config["ip"], tonumber(config["port"]))

-- ---------------
--    functions
-- ---------------

-- Test if player is alive or not
-- @param name
-- @return true if player is alive, nil when player has illegal characters, else false
function playerIsAlive(name)
--    name = convertSpecialChars(name)
    for k, v in pairs(player.GetAll()) do
        if string.find(string.lower(v:Name()), string.lower(tostring(name))) ~= nil then
            if ( v:Alive() ) then  return true
            else return false end
        end
    end
    MsgC( Color( 255, 0, 0 ), "[TS-Automute] Player with nick "..name.." uses illegal Characters in his name!\n")
    return nil
end

-- Convert special characters in names
-- @param name
-- @return name with converted special characters
function convertSpecialChars(name)
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Name before conversion: "..name.."\n")
    end
    -- "specialchars" contains all Special Characters in the form they are sent back by TS Query and "subchars" their substitutes needed to send to the TS Query
    -- (its very strange that TS Query needs a different input than it gives output...)
    -- note: if you find a character thats missing, please report it to me and dont forget to escape the "\" if you want to add it on your own
    local specialchars  = {"\\s", "\\p"}
    local subchars      = {" "  , "|"  }
    for i=1, table.getn(specialchars) do
        name = string.gsub(name, specialchars[i], subchars[i])
    end
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Name after conversion: "..name.."\n")
    end
    return name
end

-- ---------------
--      Hooks
-- ---------------
gameevent.Listen( "PlayerDeath" )
gameevent.Listen( "TTTBeginRound" )
gameevent.Listen( "TTTEndRound" )
gameevent.Listen( "TTTPrepareRound" )
gameevent.Listen( "PlayerDisconnected" )
gameevent.Listen( "PlayerConnect" )
gameevent.Listen( "PlayerSpawn" )

-- round is in preparing phase - all new players can get talkpower when joining
hook.Add("TTTPrepareRound", "", function()
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Round prepartation.\n")
    end
    
    roundHasEnded = false
    roundIsPreparing = true
end)

-- round is starting - new players dont get talkpower anymore and if player dies talkpower gets removed
hook.Add("TTTBeginRound", "", function()
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Round start.\n")
    end

    roundIsPreparing = false

    -- unmute everybody again
    for k, v in pairs( player.GetAll() ) do
        packet:WriteStringRaw("clientfind pattern="..v:GetName().."\n")
        socket:Send(packet, true)
    end

    hook.Add( "PlayerDeath", "PlayerDeath", function(target)
        if isDebug then
            MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Entity got killed.\n")
        end
        
        packet:WriteStringRaw("clientfind pattern="..target:GetName().."\n")
        socket:Send(packet, true)
    end)
        
    hook.Add( "PlayerSpawn", "PlayerSpawn", function(target)
        if isDebug then
            MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Entity spawned/respawned.\n")
        end
        
        packet:WriteStringRaw("clientfind pattern="..target:GetName().."\n")
        socket:Send(packet, true)
    end)
end)

-- give all players talkpower at the end of the round
hook.Add("TTTEndRound", "", function()
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Round end.\n")
    end

    hook.Remove( "PlayerDeath", "PlayerDeath")
    hook.Remove( "PlayerSpawn", "PlayerSpawn")
    
    roundHasEnded = true
    
    for k, v in pairs( player.GetAll() ) do
        packet:WriteStringRaw("clientfind pattern="..v:GetName().."\n")
        socket:Send(packet, true)
    end
end)

-- remove talkpower from player when disconnecting from server
hook.Add("PlayerDisconnected", "", function(player)
    playerDisconnected = player:GetName()
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Player "..playerDisconnected.." disconnected.\n")
    end
    packet:WriteStringRaw("clientfind pattern="..playerDisconnected.."\n")
    socket:Send(packet, true)
end)

-- move player to right channel and give talkpower when connecting to server and round is still in preparing phase
hook.Add("PlayerConnect", "", function(name)
    playerConnected = name
    if isDebug then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Player "..playerConnected.." connected.\n")
    end
    if roundIsPreparing then
        packet:WriteStringRaw("clientfind pattern="..playerConnected.."\n")
        socket:Send(packet, true)
    end
end)
