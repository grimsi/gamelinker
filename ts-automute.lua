require("bromsock")
local socket = BromSock(BROMSOCK_TCP)
local packet = BromPacket()

local config = util.JSONToTable(file.Read("autorun\\server\\ts-automute\\config.txt", "LUA")) --loads variables from "config.txt"
MsgC( Color( 0, 255, 0 ), "[TS-Automute] Loaded config\n" )

local roundHasEnded = false

socket:SetCallbackReceive(function(sock, receivedPacket)
    local receivedPacket = receivedPacket:ReadUntil("\n"):Trim()
    if string.find(receivedPacket, "clid") then
        local clid = string.sub(receivedPacket, string.find(receivedPacket, "clid=")+5, string.find(receivedPacket, " "))
        local nick = string.sub(receivedPacket, string.find(receivedPacket, "client_nickname=")+16, string.len(receivedPacket))
        if playerIsAlive(nick) or roundHasEnded == true then
            packet:WriteStringRaw("clientmove clid="..clid.." cid="..config["channel-id"].."\n")
            socket:Send(packet, true)

            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=1\n")
            socket:Send(packet, true)
        else
            packet:WriteStringRaw("clientedit clid="..clid.." client_is_talker=0\n")
            socket:Send(packet, true)
        end
    elseif string.find(receivedPacket, "error id=512") then
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] Player could not be found!\n")
    end
    socket:ReceiveUntil("\n")
end)

socket:SetCallbackConnect(function(sock, success, ip, port)
    if (success) then
        socket:ReceiveUntil("\n")

        packet:WriteStringRaw("login "..config["username"].." "..config["password"].."\n")
        socket:Send(packet, true) --logs in as admin

        packet:WriteStringRaw("use "..config["server"].."\n")
        socket:Send(packet, true) --chooses which V-Server to use

        MsgC( Color( 0, 255, 0 ),"[TS-Automute] Connection to Teamspeak sucessfully established!\n")
    else
        MsgC( Color( 255, 0, 0 ), "[TS-Automute] Connection to Teamspeak could not be established!\n")
    end
end)

socket:Connect(config["ip"], tonumber(config["port"]))

function playerIsAlive(name)
    name = convertSpecialChars(name)
    for k, v in pairs(player.GetAll()) do
        if string.find(string.lower(v:Name()), string.lower(tostring(name))) ~= nil then
            if ( v:Alive() ) then  return true
            else return false end
        end
    end
    MsgC( Color( 255, 0, 0 ), "[TS-Automute] Player with nick "..name.." uses illegal Characters in his name!\n")
    return nil
end

function convertSpecialChars(name)
    MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Name before conversion: "..name.."\n")
    -- "specialchars" contains all Special Characters in the form they are sent back by TS Query and "subchars" their substitutes needed to send to the TS Query
    -- (its very strange that TS Query needs a different input than it gives output...)
    -- note: if you find a character thats missing, please report it to me and dont forget to escape the "\" if you want to add it on your own
    local specialchars  = {"\\s", "\\p"}
    local subchars      = {" "  , "|"  }
    for k, v in pairs(specialchars) do
        string.gsub(name, specialchars[v], subchars[v])
    end
    MsgC( Color( 255, 0, 0 ), "[TS-Automute] [Debug] Name after conversion: "..name.."\n")
    return name
end

gameevent.Listen( "entity_killed" )
gameevent.Listen( "TTTBeginRound" )
gameevent.Listen( "TTTEndRound" )

hook.Add("TTTBeginRound", "", function()

    roundHasEnded = false

    hook.Add( "entity_killed", "", function()

        for k, v in pairs( player.GetAll() ) do
            packet:WriteStringRaw("clientfind pattern="..v:GetName().."\n")
            socket:Send(packet, true)
        end
    end)

    for k, v in pairs( player.GetAll() ) do
        packet:WriteStringRaw("clientfind pattern="..v:GetName().."\n")
        socket:Send(packet, true)
    end
end)

hook.Add("TTTEndRound", "", function()

    hook.Remove( "entity_killed", "entity_killed_example")
    roundHasEnded = true
    for k, v in pairs( player.GetAll() ) do
        packet:WriteStringRaw("clientfind pattern="..v:GetName().."\n")
        socket:Send(packet, true)
    end
end)