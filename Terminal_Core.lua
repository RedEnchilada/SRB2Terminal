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

-- Colors!

local white  = "\x80" 
local purple = "\x81" 
local yellow = "\x82" 
local green  = "\x83" 
local blue   = "\x84" 
local red    = "\x85" 
local grey   = "\x86" 
local orange = "\x87" 

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

-- Outdated hack for dedicated servers. Thanks to 2.1.9+, we can point directly to the struct!
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

-- Deprecated synchronization code
--[[addHook("PlayerJoin", do
	if dediServer and dediServer.valid then
		COM_BufInsertText(dediServer, "wait 1;iamtheserver")
	end
end)]]


-- Player symbol management
local function getSymbol(player)
	if player == server then return green.."~"..white end -- Server
	local p = player.servperm
	if not p then return "" end -- No permissions! D:
	if (p & UP_FULLCONTROL) then return green.."&"..white end -- Admin
	if (p & UP_PLAYERMANAGE) then return green.."@"..white end -- Operator
	if (p & UP_GAMEMANAGE) then return green.."%"..white end -- Half-Op
	if (p & permMap.allcheat) then return green.."+"..white end -- Cheater
end

-- Function for retrieving the current team color
local function getTeamColor(player) 
	if G_GametypeHasTeams() then
		if player.ctfteam == 0 then return white end
		if player.ctfteam == 1 then return red end 
		if player.ctfteam == 2 then return blue end 
	else return ""
	end
end

-- Grabs Terminal names, so the PlayerMsg hook below isn't a clustered mess.
local function getTermName(player) 
	return getSymbol(player)..getTeamColor(player)..player.name..white
end

-- Manage player names
addHook("PlayerMsg", function(source, msgtype, target, message)
	if message:sub(1, 1) == "/" then
		COM_BufInsertText(source, message:sub(2))
		return true
	end
	if msgtype == 0 then 
		print("<"..getTermName(source).."> "..message)
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

--Player tracking! -Red
addHook("ThinkFrame", do
	for player in players.iterate do
		if player.tweenedaiming then
			player.tweenedaiming = $1+(player.aiming-$1)/8
			player.tweenedcamz = $1+(player.viewz+20<<FRACBITS-$1)
		else
			player.tweenedaiming = player.aiming
			player.tweenedcamz = player.viewz+20<<FRACBITS
		end
	end
end)

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
		camz = p.mo.z
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
			v.drawScaled(x, y, FRACUNIT, patch, V_40TRANS)
			v.drawString(x/FRACUNIT+2, y/FRACUNIT+2, player.name, V_ALLOWLOWERCASE|V_40TRANS, "left")
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
		CONS_Printf(p, "kill <player>: Kill another player!")
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

-- SRB2 seriously needs a super() function for replaced commands.
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
	CONS_Printf(p, "Executing"..yellow..cmd..white.." in the server console.")
	CONS_Printf(A_MServ(), yellow..p.name.." executed the following in the server console: "..blue..">"..cmd)
	COM_BufInsertText(A_MServ(), cmd)
end)

-------------------
-- Terminal Help --
-------------------

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
			v.drawString(20, 60, "Welcome to SRB2 Terminal!\n\n\n\n\n\n\nType \"term_help\" in the console to\nlearn more about this server.", V_ALLOWLOWERCASE, "left")
		end
	end
end, "game")

-- Display help information
COM_AddCommand("term_help", function(p, arg1)
	local disp = [[Welcome to SRB2 Terminal!
This mod for SRB2 servers adds lots of additional functionality to improve the netplay experience, such as votes for map changing or kicking obnoxious players, a brand-new permissions system, and optional multiplayer cheats!

To learn more, type "term_help <topic>". The following topics are available:
logins, polls, permissions, credits]]
	
	local helpindex = {
		logins = [[Terminal provides a login system for account registration. Logging in will allow you to keep permissions given to you by the server. (For more info about permissions, type "term_help permissions" in the console.)

To register an account, type "register <password>" into the console. The server admin will have to complete the registration process. Once this is done, you can type "login [<username>] <password>" to log into your account. (username is the name you registered with, and will default to your current username if not given.)]],
		polls = [[Terminal has support for polls of many types, including functional polls to change the current map. For more information on how to start a poll, type "startvote" in the console.

To vote in a currently active poll, type "vote <option>" in the console. (option must be the number of your choice, not the choice itself.) Managers can also force polls to end by typing "resolvepoll" in the console, or "removepoll" to end without executing the results of the poll.]],
		permissions = [[SRB2's old permission system is out. Terminal's new permission system is in! This permission system allows the server to give different permissions to different users, and have multiple permissions at a time.

The "givepermission" and "removepermission" commands are used to set permissions. More info about each permission:
cheatself (+): Players can use cheats that affect themselves, such as "god" and "noclip".
]]-- cheatothers: Players can use cheats that affect other players. (These are not yet implemented.)
..[[cheatall (+): Players can use cheats that affect the entire server, such as "setrings".
allcheat (+): Players get all of the above permissions.
moderator (@): Players can kick and ban others from the game, using the "dokick" and "doban" commands.
halfop (%): Players can change the game map and change other options.
operator (@): Players get moderator and halfop permissions.
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
	
	if helpindex[arg1] then
		disp = helpindex[arg1]
	end
	CONS_Printf(p, disp)
end)

-- Show that Terminal is being run on the scores screen!
hud.add(function(v)
	v.drawString(320, 192, "Server running Terminal (GitHub version)", V_ALLOWLOWERCASE|V_40TRANS, "right")
end, "scores")