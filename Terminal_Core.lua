-- Terminal (GitHub working version) - The first SRB2 server hosting overhaul utility!
-- Created by Wolfy and RedEnchilada
-- Special thanks to Steel Titanium, Puppyfaic, and SonicX8000 for testing!

-- Core file, contains base framework for Terminal functions.

-- Declare terminal library in global namespace
rawset(_G, "terminal", {})


-- Helper function for identifying a player
terminal.GetPlayerFromString = function(src)
	if tonumber(src) ~= nil then
		return players[tonumber(src)]
	else
		src = src:lower()
		for player in players.iterate do
			if player.name:lower() == src then return player end
		end
	end
end

-- Function to turn a decimal number string into a fixed! (Wrote my own so we don't need to ask JTE for his c: -Red)
terminal.FloatFixed = function(src)
	if src == nil then return nil end
	if not src:find("^-?%d+%.%d+$") then -- Not a valid number!
		--print("FAK U THIS NUMBER IS SHITE")
		if tonumber(src) then
			return tonumber(src)*FRACUNIT
		else
			return nil
		end
	end
	local decPlace = src:find("%.")
	local whole = tonumber(src:sub(1, decPlace-1))*FRACUNIT
	--print(whole)
	local dec = src:sub(decPlace+1)
	--print(dec)
	local decNumber = tonumber(dec)*FRACUNIT
	for i=1,dec:len() do
		decNumber = $1/10
	end
	if src:find("^-") then
		return whole-decNumber
	else
		return whole+decNumber
	end
end

--[[ Test command for above
COM_AddCommand("getfixed", function(p, a)
	CONS_Printf(p, terminal.FloatFixed(a))
end)]]

-- Convenience function to build a safe string to put as a console command
terminal.ConsoleCommand = function(...)
	local cmd = ""
	for _,i in ipairs({...}) do
		if i:find(" ") or i:find(";") then
			cmd = $1..' "'..i..'"'
		else
			cmd = $1.." "..i
		end
	end -- You could theoretically remove the leading space from cmd, but it doesn't actually affect the execution, so let's not. :)
	-- (Plus now that the code's also used for the changemap command...)
	
	return cmd
end

-- Helper function for ternary statements
rawset(_G, "tern", function(cond, t, f)
	if cond return t else return f end
end)

-- Function to return the map name of a specified map - errors out if the map header isn't set
terminal.MapName = function(i)
	if not mapheaderinfo[i] then error("MapName cannot be called with an empty map's index!", 2) end
	return mapheaderinfo[i].lvlttl:gsub("%z.*", ""):lower():gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
		..tern(mapheaderinfo[i].levelflags & LF_NOZONE, "", " Zone")
		..tern(mapheaderinfo[i].actnum == 0, "", " "..mapheaderinfo[i].actnum)
	-- Really long formula to generate the name string. Auto-capitalizes the first letter of each word.
end

-- Similar to above, but returns multiple variations for searching purposes, all regulated to lowercase
terminal.MapSearchNames = function(i)
	if not mapheaderinfo[i] then error("MapSearchNames cannot be called with an empty map's index!", 2) end
	local ret = {}
	
	-- Full name, always returned
	table.insert(ret, 
		mapheaderinfo[i].lvlttl:gsub("%z.*", ""):lower()
			..tern(mapheaderinfo[i].levelflags & LF_NOZONE, "", " zone")
			..tern(mapheaderinfo[i].actnum == 0, "", " act "..mapheaderinfo[i].actnum)
	)
	
	-- Without act keyword, only returned if an act was set
	if mapheaderinfo[i].actnum ~= 0 then
		table.insert(ret, 
			mapheaderinfo[i].lvlttl:gsub("%z.*", ""):lower()
				..tern(mapheaderinfo[i].levelflags & LF_NOZONE, "", " zone")
				.." "..mapheaderinfo[i].actnum
		)
	end
	
	-- Without zone keyword, only returned if "ZONE" was set
	if not (mapheaderinfo[i].levelflags & LF_NOZONE) then
		table.insert(ret, 
			mapheaderinfo[i].lvlttl:gsub("%z.*", ""):lower()
				..tern(mapheaderinfo[i].levelflags & LF_NOZONE, "", " zone")
				..tern(mapheaderinfo[i].actnum == 0, "", " act "..mapheaderinfo[i].actnum)
		)
	
		-- Without act keyword, only returned if an act was set
		if mapheaderinfo[i].actnum ~= 0 then
			table.insert(ret, 
				mapheaderinfo[i].lvlttl:gsub("%z.*", ""):lower()
					.." "..mapheaderinfo[i].actnum
			)
		end
	end
	
	-- TODO add abbreviation?
	
	return ret
end

-- Permissions system! -Red
terminal.permissions = {
	SELFCHEATS   = 1,
	OTHERCHEATS  = 2,
	GLOBALCHEATS = 4,
	PLAYERMANAGE = 8,
	GAMEMANAGE   = 16,
	FULLCONTROL  = 32
}

-- Colors!
terminal.colors = {
	-- proper names
	white  = "\x80",
	purple = "\x81",
	yellow = "\x82",
	green  = "\x83",
	blue   = "\x84",
	red    = "\x85",
	grey   = "\x86",
	orange = "\x87",
	
	-- indexes
	[1] = "\x80",
	[2] = "\x81",
	[3] = "\x82",
	[4] = "\x83",
	[5] = "\x84",
	[6] = "\x85",
	[7] = "\x86",
	[8] = "\x87",
}

-- Can use OR to check for multiple permissions - must have all of them!
terminal.HasPermission = function(p, permflags)
	if p == server --[[or p == admin]] then return true end -- Server has ALL the permissions!
	if not p.servperm then
		p.servperm = 0
	end
	return (p.servperm & permflags) == permflags
end

terminal.GivePermission = function(p, permflags)
	if not p.servperm then
		p.servperm = 0
	end
	p.servperm = $1|permflags
end

terminal.RemovePermission = function(p, permflags)
	if not p.servperm then
		p.servperm = 0
	end
	p.servperm = $1&~permflags
end

-- Raw console commands for permissions
terminal.permissions.text = {
	cheatself     = terminal.permissions.SELFCHEATS,
	--cheatothers   = terminal.permissions.OTHERCHEATS,
	cheatglobal   = terminal.permissions.GLOBALCHEATS,
	allcheat      = terminal.permissions.SELFCHEATS|terminal.permissions.OTHERCHEATS|terminal.permissions.GLOBALCHEATS,
	moderator     = terminal.permissions.PLAYERMANAGE,
	manager       = terminal.permissions.GAMEMANAGE,
	operator      = terminal.permissions.PLAYERMANAGE|terminal.permissions.GAMEMANAGE,
	admin         = terminal.permissions.FULLCONTROL,
	all           = ~0 -- EVERYTHING! MWAHAHA
}

COM_AddCommand("givepermission", function(p, arg1, arg2)
	if not terminal.HasPermission(p, terminal.permissions.text.admin) then
		CONS_Printf(p, "You need \"admin\" permissions to use this!")
		return
	end
	if arg2 == nil then
		if arg1 == nil then -- No arguments passed!
			CONS_Printf(p, "givepermission <user> <permission>: Give a user a server permission!")
			-- Get available permissions
			local str = "Available permissions:"
			for i,_ in pairs(terminal.permissions.text) do
				str = $1.." "..i
			end
			CONS_Printf(p, str)
			-- /perm
			CONS_Printf(p, "If user is not given, it will give permissions to all players.")
			return
		end
		arg2 = arg1
		arg1 = nil
	end
	
	if not terminal.permissions.text[arg2] then
		CONS_Printf(p, ("Invalid parameter \"%s\"."):format(arg2))
		return
	end
	
	do (function(func)
		if arg1 == nil then
			for player in players.iterate do func(player) end
		else
			local player = terminal.GetPlayerFromString(arg1)
			if not player then
				CONS_Printf(p, "Player "..arg1.." does not exist!")
				return
			end
			func(player)
		end
	end)(function(player)
		print(player.name.." has been awarded \""..arg2.."\" permissions.")
		terminal.GivePermission(player, terminal.permissions.text[arg2])
	end) end
end)

COM_AddCommand("removepermission", function(p, arg1, arg2)
	if not terminal.HasPermission(p, terminal.permissions.text.admin) then
		CONS_Printf(p, "You need \"admin\" permissions to use this!")
		return
	end
	if arg2 == nil then
		if arg1 == nil then -- No arguments passed!
			CONS_Printf(p, "removepermission <user> <permission>: Remove a server permission from a user!")
			-- Get available permissions
			local str = "Available permissions:"
			for i,_ in pairs(terminal.permissions.text) do
				str = $1.." "..i
			end
			CONS_Printf(p, str)
			-- /perm
			CONS_Printf(p, "If player is not given, it will take permissions from all players.")
			return
		end
		arg2 = arg1
		arg1 = nil
	end
	
	if not terminal.permissions.text[arg2] then
		CONS_Printf(p, ("Invalid parameter %s."):format(arg2))
		return
	end

	do (function(func)
		if arg1 == nil then
			for player in players.iterate do func(player) end
		else
			local player = A_MServ_getPlayerFromString(arg1)
			if not player then
				CONS_Printf(p, "Player "..arg1.." does not exist!")
				return
			end
			func(player)
		end
	end)(function(player)
		print(player.name.." has lost \""..arg2.."\" permissions.")
		terminal.RemovePermission(player, terminal.permissions.text[arg2])
	end) end
end)

-- Outdated hack for dedicated servers. Thanks to 2.1.10+, we don't need any of this shit!
-- local dediServer

--[[COM_AddCommand("iamtheserver", function(p)
	if p == server or p == admin then return end -- Dedicated servers only!
	dediServer = p
	--COM_BufInsertText(p, "wait 15;wait 15;wait 15;iamtheserver") -- To keep syncing it for players! (lol NetVars hook still being broken)
end, 1)]]

-- Deprecated synchronization code
--[[addHook("PlayerJoin", do
	if dediServer and dediServer.valid then
		COM_BufInsertText(dediServer, "wait 1;iamtheserver")
	end
end)]]

-- Change the color of permission symbols. TODO: Option for permission color to be determined by team
local cv_permcolor = CV_RegisterVar({"permissioncolor", "green", 0, {white = 1, purple = 2, yellow = 3, green = 4, blue = 5, red = 6, grey = 7, orange = 8}}) 

-- Player symbol management. The ... argument is only used for /me.
local function getSymbol(player)
	local function c(s) return terminal.colors[cv_permcolor.value]..s..terminal.colors.white end
	if player == server then return c("~") end -- Server
	local p = player.servperm
	if not p then return "" end -- No permissions! D:
	if (p & terminal.permissions.FULLCONTROL) then return c("&") end -- Admin
	if (p & terminal.permissions.PLAYERMANAGE) then return c("@") end -- Operator
	if (p & terminal.permissions.GAMEMANAGE) then return c("%") end -- Half-Op
	if (p & terminal.permissions.text.allcheat) then return c("+") end -- Cheater
end

-- Function for retrieving the current team color.
local function getTeamColor(p) 
	if G_GametypeHasTeams() then
		if p.ctfteam == 0 return terminal.colors.white end
		if p.ctfteam == 1 then return terminal.colors.red end 
		if p.ctfteam == 2 then return terminal.colors.blue end 
	else return ""
	end
end

-- Grabs Terminal names, so the pMsg hook below isn't a clustered mess.
local function getTermName(p) 
	return getSymbol(p)..getTeamColor(p)..p.name..terminal.colors.white
end

-- Manage player names - Wolfs
addHook("PlayerMsg", function(source, msgtype, target, message)
	-- Moved this check to the start of the function so csays can start with / because why the fuck would you use csay to execute a console command
	if msgtype == 3 then return false end -- TODO override cechos to allow cool shit like colors? -Red
	
	if (message:sub(1, 1) == "/") and not (message:sub(1, 3) == "/me") then 
		if message:sub(1, 2) == "//" then -- Slash escaping; remove the first slash and parse msg as normal
			message = message:sub(2)
		elseif message:sub(1, 3) == "/t " then -- Alias chat to a saytem
			message = message:sub(4)
			msgtype = 1
		elseif message:sub(1, 3) == "/w " then -- Alias chat to a sayto; this is gonna be fucking complicated
			msgtype = 2
			message = message:sub(4)
			
			-- CHEAP HACK
			COM_BufInsertText(source, "sayto "..message)
			return true
			
			--[[ TODO: finish this
			local stop = false
			if message:sub(1, 1) == "#" then -- Get player number
				message:sub(1, 2) == "##" then -- Never mind, just escaped the symbol
					message = message:sub(2)
				else
				end
			end
			if not stop then -- Wasn't a number, so let's test for a name with an increasing number of words from the message
			end]]
		else -- Execute whatever in the player's console
			COM_BufInsertText(source, message:sub(2))
			return true
		end
	end
	
	if msgtype == 0 then 
		if message:sub(1, 3) == "/me" then
			print(terminal.colors.yellow.."* "..getSymbol(source)..terminal.colors.yellow..getTeamColor(source)..source.name..terminal.colors.yellow..""..message:sub(4)) -- I didn't want to turn this into a clusterfuck. Unfortunately, it still is.
		else
			print("<"..getTermName(source).."> "..message)
		end
		S_StartSound(nil, sfx_radio)
	elseif msgtype == 1 then 
		for player in players.iterate do
			if player.ctfteam == source.ctfteam then
				CONS_Printf(player, ">>"..getTermName(source).."<< (team) "..message)
				S_StartSound(nil, sfx_radio, player)
			end
		end
	elseif msgtype == 2 then 
		CONS_Printf(source, "->*"..getTermName(target).."* "..message)
		CONS_Printf(target, "*"..getTermName(source).."* "..message)
		S_StartSound(nil, sfx_radio, source)
		S_StartSound(nil, sfx_radio, target)
	end
	return true
end)

-- Spectate yourself!
COM_AddCommand("spectate", function(p)
	if p.spectator or not p.mo then CONS_Printf(p, "You're already spectating!") return end
	P_KillMobj(p.mo)
	p.ctfteam = 0
	p.spectator = true
	print(p.name.." became a spectator.")
end)

--Player tracking! -Red
local function R_GetScreenCoords(p, c, mx, my, mz)
	local camx, camy, camz, camangle, camaiming
	if p.awayviewtics then
		camx = p.awayviewmobj.x
		camy = p.awayviewmobj.y
		camz = p.awayviewmobj.z
		camangle = p.awayviewmobj.angle
		camaiming = p.awayviewaiming
	elseif c.chase then
		camx = c.x
		camy = c.y
		camz = c.z
		camangle = c.angle
		camaiming = c.aiming
	else
		camx = p.mo.x
		camy = p.mo.y
		camz = p.mo.z+p.viewheight
		camangle = p.mo.angle
		camaiming = p.aiming
	end
	
	local x = camangle-R_PointToAngle2(camx, camy, mx, my)
	local distfact = FixedMul(FRACUNIT, cos(x))
	if x > ANGLE_90 or x < ANGLE_270 then
		x = 9999*FRACUNIT
	else
		x = FixedMul(tan(x+ANGLE_90), 160<<FRACBITS)+160<<FRACBITS
	end
	
	local y = camz-mz
	--print(y/FRACUNIT)
	y = FixedDiv(y, FixedMul(distfact, R_PointToDist2(camx, camy, mx, my)))
	y = (y*160)+100<<FRACBITS
	y = y+camaiming
	
	local scale = FixedDiv(160*FRACUNIT, FixedMul(distfact, R_PointToDist2(camx, camy, mx, my)))
	--print(scale)
	
	return x, y, scale
end

-- Complicated shit that Wolfy will never understand
hud.add(function(v, p, c)
	if p.spectator then return end
	if p.showPOn then
		local patch = v.cachePatch("CROSHAI1")
		do (function(func)
			if G_PlatformGametype() then
				for player in players.iterate do
					if player ~= p then
						func(player)
					end
				end
			elseif G_GametypeHasTeams() then
				for player in players.iterate do
					if player ~= p and player.ctfteam == p.ctfteam then
						func(player)
					end
				end
			end
		end)(function(player)
			if not player.mo then return end
			local x, y = R_GetScreenCoords(p, c, player.mo.x, player.mo.y, player.mo.z + 20*player.mo.scale)
			if x < 0 or x > 320*FRACUNIT or y < 0 or y > 200*FRACUNIT then return end
			v.drawScaled(x, y, FRACUNIT/2, patch, V_40TRANS)
			v.drawString(x/FRACUNIT+1, y/FRACUNIT+1, player.name, V_ALLOWLOWERCASE|V_40TRANS, "small-left")
		end) end
	end
end, "game")

-- Previously part of Terminal_Cheats. Showplayers is awesome though, so it's in Core now.
COM_AddCommand("showplayers", function(p)
	if not p.showPOn
		p.showPOn = true
		--CONS_Printf(p, "The Eggman Empire is ALWAYS watching its subjects...")
		CONS_Printf(p, "Player location display enabled.")
	else 
		p.showPOn = false
		--CONS_Printf(p, "Getting these names out of your face.")
		CONS_Printf(p, "Player location display disabled.")
	end
end)

-- Change the current map
COM_AddCommand("changemap", function(p, ...)
	if not terminal.HasPermission(p, terminal.permissions.text.manager) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	if not ... then -- TODO: open a menu that can be operated with game controls?
		CONS_Printf(p, "changemap <MAPxx>: Change the game map!")
		return
	end
	
	local cmd = "map"..terminal.ConsoleCommand(...)
	
	-- TODO make this less of a lazy hack
	COM_BufInsertText(server, cmd)
	CONS_Printf(p, "Changing map... (If nothing happens, try -force or -gametype!)")
end)

-- Kill other players! 
COM_AddCommand("kill", function(p, arg1)
	if not terminal.HasPermission(p, terminal.permissions.text.moderator) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		COM_BufInsertText(p, "suicide")
		return
	end
	if arg1 == nil then
		CONS_Printf(p, "kill <player>: Kill another player!")
		return
	end
	local player = terminal.GetPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	if player.mo and player.mo.health > 0
		P_DamageMobj(player.mo, nil, nil, 10000)
		print(p.name+" has slain "..player.name..".")
	else
		CONS_Printf(p, "Player "..player.name.." is not alive!")
	end
end)

-- Kick and ban players
COM_AddCommand("dokick", function(p, arg1, ...)
	if not terminal.HasPermission(p, terminal.permissions.text.moderator) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		return
	end
	if arg1 == nil then
		CONS_Printf(p, "dokick <player> [<reason>]: Kick a player from the server.")
		return
	end
	local player = terminal.GetPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	
	if terminal.HasPermission(player, terminal.permissions.text.admin) and not terminal.HasPermission(p, terminal.permissions.text.admin) then
		CONS_Printf(p, "Only admins can kick other admins.")
		return
	end
	
	CONS_Printf(player, terminal.colors.red..("FULL KICK REASON FROM %s:"):format(p.name)..terminal.ConsoleCommand(...))
	COM_BufInsertText(server, ("kick %s <%s>"):format(#player, p.name)..terminal.ConsoleCommand(...))
end)

-- SRB2 seriously needs a super() function for replaced commands.
COM_AddCommand("doban", function(p, arg1, ...)
	if not terminal.HasPermission(p, terminal.permissions.text.moderator) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		return
	end
	if arg1 == nil then
		CONS_Printf(p, "doban <player> [<reason>]: Ban a player from the server.")
		return
	end
	local player = terminal.GetPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	
	if terminal.HasPermission(player, terminal.permissions.text.admin) then
		CONS_Printf(p, "Admins cannot be banned.")
		return
	end
	
	CONS_Printf(player, terminal.colors.red..("FULL BAN REASON FROM %s:"):format(p.name)..terminal.ConsoleCommand(...))
	COM_BufInsertText(server, ("ban %s <%s>"):format(#player, p.name)..terminal.ConsoleCommand(...))
end)

-- "do" command, for ultimate power! (And this one doesn't need the command to be wrapped in quotes! -Red)
COM_AddCommand("do", function(p, ...)
	--print(_VERSION)
	if not terminal.HasPermission(p, terminal.permissions.text.admin) then
		CONS_Printf(p, "You need \"admin\" permissions to use this!")
		return
	end
	if not ... then
		CONS_Printf(p, "do <command>: Execute a command remotely as the host.")
		return
	end
	
	-- Command blacklist
	local blacklist = { "loadhash", -- Terminal internal commands - alter this part as needed
	"quit", "setcontrol", "vid_mode", "exitgame", "say", "sayteam", "sayto", "startmovie", "screenshot", "stopmovie", "setcontrol2", "bind", "alias", "loadcfg", "savecfg", "cpusleep", "apng_compress_level", "apng_memory_level", "apng_strategy", "apng_window_size", "apng_speed", "gif_optimize", "gif_downscale", "moviemode_mode", "png_window_size", "png_compress_level", "png_memory_level", "png_strategy", "screenshot_folder", "screenshot_option", "allcaps", "controlperkey", "con_textsize", "con_speed", "con_hudtime", "con_hudlines", "con_height", "con_backpic", "skin", "chasecam", "cam_speed", "cam_still", "cam2_speed", "cam_rotate", "cam_height", "cam_dist", "autorecord", "crosshair", "cpuaffinity", "gr_fov", "gr_filtermode", "gr_fovchange", "invertmouse", "joyaxis_fire", "joyaxis2_fire", "joyaxis_firenormal", "joyaxis2_firenormal", "joyaxis_look", "joyaxis2_look", "joyaxis_side", "joyaxis2_side", "joyaxis_turn", "joyaxis2_turn", "masterserver", "name", "ontop", "scr_depth", "scr_height", "scr_width", "use_joystick", "use_joystick2", "use_mouse", "use_mouse2", "useranalog", "useranalog2", "viewheight", "soundvolume", "midimusicvolume", "digmusicvolume", "allowjoin", "echo"}
	local firstcmd = ...
	for _,i in ipairs(blacklist) do
		if firstcmd == i then
			CONS_Printf(p, ("Command \"%s\" has been blacklisted from the \"do\" command."):format(i))
			return
		end
	end
	
	local cmd = terminal.ConsoleCommand(...)
	--print(cmd)
	CONS_Printf(p, "Executing"..terminal.colors.yellow..cmd..terminal.colors.white.." in the server console.")
	CONS_Printf(server, terminal.colors.yellow..p.name.." executed the following in the server console: "..terminal.colors.blue..">"..cmd:sub(2))
	COM_BufInsertText(server, cmd)
end)

-- "findmap" command; go to a map by name! :O
-- Start with a helper function, for Levenshtein distance (thanks https://gist.github.com/Badgerati/3261142 !)
terminal.LevenshteinDistance = function(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0
	
        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	
        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
	
        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0
			else
				cost = 1
			end
			
			matrix[i][j] = min(min(matrix[i-1][j] + 1, matrix[i][j-1] + 1), matrix[i-1][j-1] + cost)
		end
	end
	
        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end

-- A function to search the available maps for one by name. Returns the maplist sorted in order of closeness, each entry in the following struct:
--[[
	name = map name
	maptext = MAPxx
	dist = lev distance
]]
-- If exact match is found, fuck everything else and return a table with *JUST* this entry
terminal.SortMapsByName = function(name, alwaysall)
	local ret = {}
	name = $1:lower()
	
	for i=1, #mapheaderinfo do
		if not mapheaderinfo[i] then continue end
		
		local block = {}
		
		local names = terminal.MapSearchNames(i)
		
		block.name = names[1]
		block.maptext = G_BuildMapName(i)
		
		local dist = 9999*FRACUNIT
		
		for _,v in ipairs(names) do
			dist = min($1, (terminal.LevenshteinDistance(name, v)*FRACUNIT)/v:len())
			
			if (not alwaysall) and dist == 0 then -- Quick escape!
				block.dist = 0
				return {block}
			end
		end
		
		block.dist = dist
		table.insert(ret, block)
	end
	
	table.sort(ret, function(a, b) return a.dist < b.dist end)
	
	--[[ debug
	for _,v in ipairs(ret) do
		print(v.dist.." "..v.maptext.." "..v.name)
	end --]]
	
	return ret
end

-- Now the actual console command!
COM_AddCommand("findmap", function(p, name, ...)
	local nowarp
	if ... == "-nowarp" then
		nowarp = true
	elseif not terminal.HasPermission(p, terminal.permissions.text.manager) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	if not name then -- TODO: open a menu that can be operated with game controls?
		CONS_Printf(p, "findmap \"<level name>\": Change the game map!")
		return
	end
	
	local names = terminal.SortMapsByName(name, nowarp)
	
	if nowarp then
		CONS_Printf(p, "Closest matches for \""..name.."\":")
		for i = 1,5 do
			CONS_Printf(p, i..") "..names[i].maptext..": "..names[i].name)
		end
		return
	end
	
	if names[1].dist > FRACUNIT/2 or (names[2] and FixedDiv(names[1].dist, names[2].dist) > 60000) then
		CONS_Printf(p, "No close enough match for \""..name.."\" found! Closest matches:")
		for i = 1,5 do
			CONS_Printf(p, i..") "..names[i].maptext..": "..names[i].name)
		end
		return
	end
	
	local cmd = "map "..names[1].maptext..terminal.ConsoleCommand(...)
	
	-- TODO make this less of a lazy hack
	COM_BufInsertText(server, cmd)
	CONS_Printf(p, "Changing map... (If nothing happens, try -force or -gametype!)")
end)

-------------------
-- Terminal Help --
-------------------

-- Keeps track of how long the player has been on the server
addHook("ThinkFrame", do
	for p in players.iterate do
		p.serverlogintime = ($1 or 0)+1
	end
end)

-- Alias for splash screen graphics
local function welcomeDraw(v, patch, trans)
	v.drawScaled(0, 0, FRACUNIT/2, patch, trans)
end

-- Draws the server's custom splash screen if you've just joined
hud.add(function(v, p)
	if (not p.serverlogintime) or p.serverlogintime < 10*TICRATE then
		local customgraphics = false
		
		if v.patchExists("TERMHI3") then -- Enable custom greeting graphics, at a resolution of 640x400
			welcomeDraw(v, v.cachePatch("TERMHI3"), V_60TRANS) -- 60% transparency
			customgraphics = true
		end
		
		if v.patchExists("TERMHI2") then -- Enable custom greeting graphics, at a resolution of 640x400
			welcomeDraw(v, v.cachePatch("TERMHI2"), V_30TRANS) -- 30% transparency
			customgraphics = true
		end
		
		if v.patchExists("TERMHI") then -- Enable custom greeting graphics, at a resolution of 640x400
			welcomeDraw(v, v.cachePatch("TERMHI"), 0) -- No transparency
			customgraphics = true
		end
		
		if not customgraphics then -- Fallback if you have no sick graphics
			v.drawString(20, 60, "Welcome to this SRB2\nTerminal-powered server!\n\n\n\n\n\nType \"term_help\" in the console to\nlearn more about this server.", V_ALLOWLOWERCASE, "left")
		end
	end
end, "game")

-- Display help information
local helpindex = {
	polls = [[Terminal has support for polls of many types, including functional polls to change the current map. For more information on how to start a poll, type "startvote" in the console.

To vote in a currently active poll, type "vote <option>" in the console. (option must be the number of your choice, not the choice itself.) Managers can also force polls to end by typing "resolvepoll" in the console, or "removepoll" to end without executing the results of the poll.]],
	permissions = [[SRB2's old permission system is out. Terminal's new permission system is in! This permission system allows the server to give different permissions to different users, and have multiple permissions at a time.

The "givepermission" and "removepermission" commands are used to set permissions. More info about each permission:
cheatself (+): Players can use cheats that affect themselves, such as "god" and "noclip".
]]-- cheatothers: Players can use cheats that affect other players. (These are not yet implemented.)
..[[cheatglobal (+): Players can use cheats that affect the entire server, such as "setrings".
allcheat (+): Players get all of the above permissions.
moderator (@): Players can kick and ban others from the game, using the "dokick" and "doban" commands.
manager (%): Players can change the game map and change other options.
operator (@): Players get moderator and manager permissions.
admin (&): Players can execute any command from the server's end using the "do" command.]],

	credits = [[Terminal development credits:

Script development:
  RedEnchilada
  Wolfy

]]--[[Supplementary executable development: -- Hasn't happened yet, leaving out for now
  LightningDragon96
  SonicFreak94]]

..[[Server testing assistance:
  Steel Titanium

Testers:
  Blue Warrior, CoatRack, Iceman404,
  Puppyfaic, SeventhSentinel, Sonict,
  SonicX8000, Katmint

The latest vanilla release can always be found at http://terminal.lightdash.org/!]]
-- Do not remove these credits. Uncomment the below line if you've modified Terminal and wish to state this.
		--.."\n\nModifications for this server:\n  <name(s) here>"
}

terminal.AddHelp = function(topic, text)
	helpindex[topic] = text
end

COM_AddCommand("term_help", function(p, arg1)
	local disp = [[Welcome to SRB2 Terminal!
This mod for SRB2 servers adds lots of additional functionality to improve the netplay experience, such as votes for map changing or kicking obnoxious players, a brand-new permissions system, and optional multiplayer cheats!

To learn more, type "term_help <topic>". The following topics are available:
]]
	
	if helpindex[arg1] then
		disp = helpindex[arg1]
	else
		for k,_ in pairs(helpindex) do
			if k ~= "credits" then
				disp = $1..k..", "
			end
		end
		disp = $1.."credits" -- This ensures credits is the last help topic
	end
	CONS_Printf(p, disp)
end)

-- Show that Terminal is being run on the scores screen!
hud.add(function(v)
	v.drawString(320, 192, "Server running Terminal (GitHub version)", V_ALLOWLOWERCASE|V_40TRANS, "right")
end, "scores")
