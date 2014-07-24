-- Terminal Help
-- Displays information regarding the use of Terminal commands.

-- Colors, could be of use here

local white = "\x80" 
local purple = "\x81" 
local yellow = "\x82" 
local green = "\x83" 
local blue = "\x84" 
local red = "\x85" 
local grey = "\x86" 
local orange = "\x87" 

addHook("ThinkFrame", do
	for p in players.iterate do
		p.serverlogintime = ($1 or 0)+1
	end
end)

local function welcomeDraw(v, patch, trans)
	v.drawScaled(0, 0, FRACUNIT/2, patch, trans)
end

hud.add(function(v, p)
	if (not p.serverlogintime) or p.serverlogintime < 10*TICRATE then
		local customgraphics = false
		
		if v.patchExists("TERMHI3") then -- Enable custom greeting graphics, at a resolution of 640x400
			welcomeDraw(v, v.cachePatch("TERMHI3"), V_60TRANS)
			customgraphics = true
		end
		
		if v.patchExists("TERMHI2") then -- Enable custom greeting graphics, at a resolution of 640x400
			welcomeDraw(v, v.cachePatch("TERMHI2"), V_30TRANS)
			customgraphics = true
		end
		
		if v.patchExists("TERMHI") then -- Enable custom greeting graphics, at a resolution of 640x400
			welcomeDraw(v, v.cachePatch("TERMHI"), 0)
			customgraphics = true
		end
		
		if not customgraphics then
			v.drawString(20, 60, "Welcome to SRB2 Terminal!\n\n\n\n\n\n\nType \"term_help\" in the console to\nlearn more about this server.", V_ALLOWLOWERCASE, "left")
		end
	end
end, "game")

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
cheatself: Players can use cheats that affect themselves, such as "god" and "noclip".
cheatothers: Players can use cheats that affect other players. (These are not yet implemented.)
cheatall: Players can use cheats that affect the entire server, such as "setrings".
allcheat: Players get all of the above permissions.
moderator: Players can kick and ban others from the game, using the "dokick" and "doban" commands.
halfop: Players can change the game map and change other options.
operator: Players get moderator and halfop permissions.
admin: Players can execute any command from the server's end using the "do" command.]],

		credits = [[Terminal development credits:

Script development:
  RedEnchilada
  Wolfy

Supplementary executable development:
  LightningDragon96
  SonicFreak94

Server testing assistance:
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