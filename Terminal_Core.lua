-- Terminal (GitHub working version) - The first SRB2 server hosting overhaul utility!
-- Created by Wolfy and RedEnchilada
-- Special thanks to Steel Titanium, Puppyfaic, and SonicX8000 for testing!

-- Core file, contains base framework for Terminal functions.


-- Helper function for identifying a player
function A_MServ_getPlayerFromString(src)
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
function A_MServ_floatFixed(src)
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
	CONS_Printf(p, A_MServ_floatFixed(a))
end)]]

-- Permissions system! -Red
local UP_SELFCHEATS = 1
local UP_OTHERCHEATS = 2
local UP_GLOBALCHEATS = 4
local UP_PLAYERMANAGE = 8
local UP_GAMEMANAGE = 16
local UP_FULLCONTROL = 32

-- Can use OR to check for multiple permissions - must have all of them!
function A_MServ_HasPermission(player, permflags)
	if player == A_MServ() --[[or player == admin]] then return true end -- Server has ALL the permissions!
	if not player.servperm then
		player.servperm = 0
	end
	return (player.servperm & permflags) == permflags
end

local function givePermission(player, permflags)
	if not player.servperm then
		player.servperm = 0
	end
	player.servperm = $1|permflags
end

local function removePermission(player, permflags)
	if not player.servperm then
		player.servperm = 0
	end
	player.servperm = $1&~permflags
end

-- Raw console commands for permissions
local permMap = {
	cheatself = UP_SELFCHEATS,
	--cheatothers = UP_OTHERCHEATS,
	cheatglobal = UP_GLOBALCHEATS,
	allcheat = UP_SELFCHEATS|UP_OTHERCHEATS|UP_GLOBALCHEATS,
	moderator = UP_PLAYERMANAGE,
	halfop = UP_GAMEMANAGE,
	operator = UP_PLAYERMANAGE|UP_GAMEMANAGE,
	admin = UP_FULLCONTROL,
	all = ~0 -- EVERYTHING! MWAHAHA
}

COM_AddCommand("givepermission", function(p, arg1, arg2)
	if not A_MServ_HasPermission(p, UP_FULLCONTROL) then
		CONS_Printf(p, "You need \"admin\" permissions to use this!")
		return
	end
	if arg2 == nil then
		if arg1 == nil then -- No arguments passed!
			CONS_Printf(p, "givepermission <user> <permission>: Give a user a server permission!")
			-- Get available permissions
			local str = "Available permissions:"
			for i,_ in pairs(permMap) do
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
	
	if not permMap[arg2] then
		CONS_Printf(p, ("Invalid parameter \"%s\"."):format(arg2))
		return
	end
	
	local function func(player)
		print(player.name.." has been awarded \""..arg2.."\" permissions.")
		givePermission(player, permMap[arg2])
	end
	
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
end)

COM_AddCommand("removepermission", function(p, arg1, arg2)
	if not A_MServ_HasPermission(p, UP_FULLCONTROL) then
		CONS_Printf(p, "You need \"admin\" permissions to use this!")
		return
	end
	if arg2 == nil then
		if arg1 == nil then -- No arguments passed!
			CONS_Printf(p, "removepermission <user> <permission>: Remove a server permission from a user!")
			-- Get available permissions
			local str = "Available permissions:"
			for i,_ in pairs(permMap) do
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
	
	if not permMap[arg2] then
		CONS_Printf(p, ("Invalid parameter %s."):format(arg2))
		return
	end
	
	local function func(player)
		print(player.name.." has lost \""..arg2.."\" permissions.")
		removePermission(player, permMap[arg2])
	end
	
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
end)

-- Hack for dedicated servers
-- local dediServer

--[[COM_AddCommand("iamtheserver", function(p)
	if p == server or p == admin then return end -- Dedicated servers only!
	dediServer = p
	--COM_BufInsertText(p, "wait 15;wait 15;wait 15;iamtheserver") -- To keep syncing it for players! (lol NetVars hook still being broken)
end, 1)]]

function A_MServ()
	if not netgame then return end -- Just make everything explode in single-player then :v
	return server or dedicatedserver
end

--[[addHook("PlayerJoin", do
	if dediServer and dediServer.valid then
		COM_BufInsertText(dediServer, "wait 1;iamtheserver")
	end
end)]]

-- Player symbol management
local function getSymbol(player)
	if player == server then return "~" end -- Server
	local p = player.servperm
	if not p then return "" end -- No permissions! D:
	if (p & UP_FULLCONTROL) then return "&" end -- Admin
	if (p & UP_PLAYERMANAGE) then return "@" end -- Operator
	if (p & UP_GAMEMANAGE) then return "%" end -- Half-Op
	if (p & permMap.allcheat) then return "+" end -- Cheater
end

local function getTeam(player)
	if player.ctfteam == 0 then return "\x80" end -- white, no team
	if player.ctfteam == 1 then return "\x85" end -- red
	if player.ctfteam == 2 then return "\x84" end -- blue
end

-- Manage player names
addHook("PlayerMsg", function(source, msgtype, target, message)
	if message:sub(1, 1) == "!" then
		COM_BufInsertText(source, message:sub(2))
		return true
	end
	if msgtype == 0 then 
		print("<"..getTeam(source)..getSymbol(source)..source.name.."\x80> "..message)
		S_StartSound(nil, sfx_radio)
	elseif msgtype == 1 then -- TODO: Proper sound starting for players
		for player in players.iterate do
			if player.ctfteam == source.ctfteam then
				CONS_Printf(player, ">>"..getTeam(source)..getSymbol(source)..source.name.."\x80<< "..message)
			end
		end
	elseif msgtype == 2 then -- TODO: Proper sound starting for players
		CONS_Printf(source, "->*"..getTeam(target)..getSymbol(target)..target.name.."\x80* "..message)
		CONS_Printf(target, "*"..getTeam(source)..getSymbol(source)..source.name.."\x80* "..message)
	end
	if msgtype ~= 3
		return true
	end
end)
-- Spectate yourself!
COM_AddCommand("spectate", function(player)
	player.rememberspectator = true
	if not player.spectator == true then
		player.spectator = true
		print(player.name.." became a spectator.")
	end
end)

-- Change the current map
COM_AddCommand("changemap", function(p, ...)
	if not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	if not ... then
		CONS_Printf(p, "changemap <MAPxx>: Change the game map!")
		return
	end
	
	local cmd = "map"
	for _,i in ipairs({...}) do
		if i:find(" ")
			cmd = $1..' "'..i..'"'
		else
			cmd = $1.." "..i
		end
	end
	
	-- TODO make this less of a lazy hack
	COM_BufInsertText(A_MServ(), cmd)
	CONS_Printf(p, "Changing map... (If nothing happens, try -force or -gametype!)")
end)

-- Kill other players! 
COM_AddCommand("kill", function(p, arg1)
	if not A_MServ_HasPermission(p, UP_PLAYERMANAGE) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		COM_BufInsertText(p, "suicide")
		return
	end
	if arg1 == nil then
		CONS_Printf(p, "kill <player>: Stub somebody's toe!")
		return
	end
	local player = A_MServ_getPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	if player.mo and player.mo.health > 0
		P_DamageMobj(player.mo, nil, nil, 10000)
		print(p.name+" has slain "..player.name..".")
	end
end)

-- Kick and ban players
COM_AddCommand("dokick", function(p, arg1, ...)
	if not A_MServ_HasPermission(p, UP_PLAYERMANAGE) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		return
	end
	if arg1 == nil then
		CONS_Printf(p, "dokick <player> [<reason>]: Kick a player from the server.")
		return
	end
	local player = A_MServ_getPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	
	if A_MServ_HasPermission(player, UP_FULLCONTROL) and not A_MServ_HasPermission(p, UP_FULLCONTROL) then
		CONS_Printf(p, "Only admins can kick or ban other admins.")
		return
	end
	
	local cmd = ("kick %s <%s>"):format(#player, p.name)
	for _,i in ipairs({...}) do
		if i:find(" ")
			cmd = $1..' "'..i..'"'
		else
			cmd = $1.." "..i
		end
	end
	
	COM_BufInsertText(A_MServ(), cmd)
end)
COM_AddCommand("doban", function(p, arg1, ...)
	if not A_MServ_HasPermission(p, UP_PLAYERMANAGE) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		return
	end
	if arg1 == nil then
		CONS_Printf(p, "doban <player> [<reason>]: Ban a player from the server.")
		return
	end
	local player = A_MServ_getPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	
	if A_MServ_HasPermission(player, UP_FULLCONTROL) and not A_MServ_HasPermission(p, UP_FULLCONTROL) then
		CONS_Printf(p, "Only admins can kick or ban other admins.")
		return
	end
	
	local cmd = ("ban %s <%s>"):format(#player, p.name)
	for _,i in ipairs({...}) do
		if i:find(" ")
			cmd = $1..' "'..i..'"'
		else
			cmd = $1.." "..i
		end
	end
	
	COM_BufInsertText(A_MServ(), cmd)
end)

-- "do" command, for ultimate power! (And this one doesn't need the command to be wrapped in quotes! -Red)
COM_AddCommand("do", function(p, ...)
	--print(_VERSION)
	if not A_MServ_HasPermission(p, UP_FULLCONTROL) then
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
	
	local cmd = ""
	for _,i in ipairs({...}) do
		if i:find(" ")
			cmd = $1..' "'..i..'"'
		else
			cmd = $1.." "..i
		end
	end -- You could theoretically remove the leading space from cmd, but it doesn't actually affect the execution, so let's not. :)
	--print(cmd)
	CONS_Printf(p, "Executing\x82"..cmd.."\x80 in the server console.")
	CONS_Printf(A_MServ(), "\x82"..p.name.." executed the following in the server console: \x84>"..cmd)
	COM_BufInsertText(A_MServ(), cmd)
end)

-- Show that Terminal is being run on the scores screen!
hud.add(function(v)
	v.drawString(320, 192, "Server running Terminal (GitHub version)", V_ALLOWLOWERCASE|V_40TRANS, "right")
end, "scores")