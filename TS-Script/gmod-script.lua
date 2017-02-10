gameevent.Listen( "entity_killed" )

gameevent.Listen( "TTTBeginRound" )
hook.Add("TTTBeginRound", "TTTBeginRound_example", function()

	hook.Add( "entity_killed", "entity_killed_example", function( data )

		file.Write("dead.txt", "")
		file.Write("alive.txt", "")
		for k, v in pairs( player.GetAll() ) do
			if ( v:Alive() ) then
				file.Append("alive.txt",v:GetName().."\n")
			else
				file.Append("dead.txt",v:GetName().."\n")
			end
		end

	end
	)

	file.Write("dead.txt", "")
	file.Write("alive.txt", "")
	for k, v in pairs( player.GetAll() ) do
		if ( v:Alive() ) then
			file.Append("alive.txt",v:GetName().."\n")
		else
			file.Append("dead.txt",v:GetName().."\n")
		end
	end
end
)

gameevent.Listen( "TTTEndRound" )
hook.Add("TTTEndRound", "TTTEndRound_example", function()

	hook.Remove( "entity_killed", "entity_killed_example")
	
	file.Write("dead.txt", "")
	file.Write("alive.txt", "")
	for k, v in pairs( player.GetAll() ) do
			file.Append("alive.txt",v:GetName().."\n")
	end
end
)
