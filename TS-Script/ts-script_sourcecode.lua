local ip,port,servername,username,password,tickrate,folder_path,channel_id = nil, nil, nil, nil, nil, nil, nil, nil, nil
local clid, clid_check = nil, nil
local name, var = {}, {}
local tickdelay = nil
local socket, server = nil, nil

require("io")

--------------benutzerdefinierte Funktionen---------------

function initialising()

	local file = io.open("config.txt", "r")
	for line in file:lines() do
		var[#var + 1] = line
		var[#var] = tostring(var[#var])
	end
	file:close()
	ip = string.sub(var[1], string.find(var[1], ":")+1, string.find(var[1], ";")-1)
	port = string.sub(var[2], string.find(var[2], ":")+1, string.find(var[2], ";")-1)
	servername = string.sub(var[3], string.find(var[3], ":")+1, string.find(var[3], ";")-1)
	username = string.sub(var[4], string.find(var[4], ":")+1, string.find(var[4], ";")-1)
	password = string.sub(var[5], string.find(var[5], ":")+1, string.find(var[5], ";")-1)
	tickrate = string.sub(var[6], string.find(var[6], ":")+1, string.find(var[6], ";")-1)
	tickrate = 1000/tickrate
	tickdelay = tickrate/1000
	folder_path = string.sub(var[7], string.find(var[7], ":")+1, string.find(var[7], ";")-1)
	channel_id = string.sub(var[8], string.find(var[8], ":")+1, string.find(var[8], ";")-1)
	socket = require("socket")
	server = socket.connect(ip, port)
	server:send("login "..username.." "..password.."\n") 	--Meldet sich als Admin an
	server:send("use "..servername.."\n")	--legt fest, welchen vServer er benutzen soll (Standard: 1)
	server:receive("*l")
	server:receive("*l")
	server:receive("*l")
	server:receive("*l") --überspringt die ersten Zeilen der Antwort des Servers, damit die richtige ID ausgelesen wird
end

function process_players(filename)

	local file = io.open(filename, "r")
	for line in file:lines() do
		name[#name + 1] = line
	end
	file:close()
	if #name == 0 then
		print("Datei hat keinen Inhalt, breche ab\n")
		return
	end
	for k,v in pairs(name) do

		clid = readuserid(name, k, clid)

		if clid ~= nil then
			print("Client-ID lautet: "..clid.."\n")
			if filename == folder_path.."\\alive.txt" then
				server:send("clientedit clid="..clid.." client_is_talker=1\n") --Unmutet Client
				server:receive("*l")
				server:send("clientmove clid="..clid.." cid="..channel_id.."\n") --Verschiebt den Client in den TTT-Channel
				server:receive("*l")
			elseif filename == folder_path.."\\dead.txt" then
				server:send("clientedit clid="..clid.." client_is_talker=0\n") --Mutet Client
				server:receive("*l")
			end
		else
			print("Es wurde auf dem Teamspeak kein Client mit diesem Namen gefunden!\n")
		end
	end
	name = nil
	name = {}
end

function readuserid(name, k, clid)
		print("Suche nach: "..name[k])
		server:send("clientfind pattern="..name[k].."\n")
		clid = server:receive("*l")

		clid_check = clid
		clid_check = tostring(clid_check)
		clid_check = string.match(clid_check, "clid=") --Pr�ft, ob auch wirklich die ID eines Clients vom Teamspeak zur�ckgegeben wird

		if clid_check ~= nil then
			clid = tostring(clid)
			clid=string.sub(clid, 6, string.find(clid, " "))
			server:receive("*l") --überspringt je nachdem, ob die ClientID vorhanden ist oder nicht, Zeilen, damit er nachfolgenden Werte korrekt ausliest
		else
			return nil
		end

	return clid
end

---------------------Hauptprogramm----------------------
initialising()
while true do
		os.execute("cls") --leert die Konsolenausgabe, damit sie lesbar bleibt auch bei hoher tickrate
		process_players(folder_path.."\\alive.txt")
		process_players(folder_path.."\\dead.txt")
		print("Check beendet, warte "..tickdelay.." Sekunde\(n\)")
		--os.execute("timeout 1") --für ältere Windows-Versionen oder wenn man nur ganze Sekunden braucht
		os.execute("echo WScript.Sleep^(WScript.Arguments^(0^)^) >\"%temp%sleep.vbs\" && cscript \"%temp%sleep.vbs\" "..tickrate.." >nul") --für neuere Versionen. Schneller, Präziser, und in Millisekunden
end
