-- Terminal Voting - LightDash edition
-- Voting system, for map changes and other useful things! (Requires Terminal_Core.lua, as well as Terminal_Maplist.lua or an equivalent)

-- Stuff from the main Terminal file

-- Colors!

local white  = "\x80" 
local purple = "\x81" 
local yellow = "\x82" 
local green  = "\x83" 
local blue   = "\x84" 
local red    = "\x85" 
local grey   = "\x86" 
local orange = "\x87" 

-- Permissions used in this file
local UP_GAMEMANAGE  = 16
local UP_FULLCONTROL = 32
-- Don't copy-pastarino the above!

-- Map voting! (And other types of voting, while we're here!)

-- Easy way to grab the server's voting table
local function voting()
	local s = A_MServ()
	if not (s and s.valid) then return nil end
	return s.voting
end

-- Create a poll of a certain type!
-- POLL_START should be bitwise OR'd with the type of poll one wishes to start (only used for map and category changes)
-- In case of POLL_KICK, a second arg with the player you wish to kick
-- In case of POLL_CUSTOM, the second arg is a table in the format {question="Blah blah?", answers={"Blah!", "Blah..."}}
-- In case of POLL_PLAYERS, the second arg is the question (answers will be populated with player names at the time of the poll's creation)
local POLL_CHANGEMAP      = 1
local POLL_CHANGECATEGORY = 2
local POLL_TEAMSCRAMBLE   = 3
local POLL_ENDMAP         = 4
local POLL_KICK           = 5
local POLL_CUSTOM         = 6
local POLL_PLAYERS        = 7
local POLL_RESETMAP       = 8
local POLL_START          = 256

local function pollopts()
	local s = A_MServ()
	if not s.pollopts then
		s.pollopts = {
			timeout = 60,
			limiter = 6
		}
	end
	return s.pollopts
end

-------------------
-- Maplist stuff --
-------------------

local function mapoverrides(name)
	if A_MServ_MapOverride then
		local f = A_MServ_MapOverride(name) -- Define this function in a separate script if you want to have your own custom overrides
		if f then return f end
	end
	
	local srb1 = {SRB1 = GT_COOP} -- SRB1 is already a manual override!
	local list = {
		["Knothole Base Zone 1"]      = srb1,
		["Knothole Base Zone 2"]      = srb1,
		["Great Forest Zone 1"]       = srb1,
		["Great Forest Zone 2"]       = srb1,
		["Lake Zone 1"]               = srb1,
		["Lake Zone 2"]               = srb1,
		["Ice Palace Zone 1"]         = srb1,
		["Ice Palace Zone 2"]         = srb1,
		["Volcano Zone 1"]            = srb1,
		["Volcano Zone 2"]            = srb1,
		["Echidnapolis Zone 1"]       = srb1,
		["Echidnapolis Zone 2"]       = srb1,
		["Sky Lab Zone 1"]            = srb1,
		["Sky Lab Zone 2"]            = srb1,
		["Mechanical Madness Zone 1"] = srb1,
		["Mechanical Madness Zone 2"] = srb1,
		["Robotopolis Zone 1"]        = srb1,
		["Robotopolis Zone 2"]        = srb1,
		["Robo Base Zone 1"]          = srb1,
		["Robo Base Zone 2"]          = srb1,
		["Ringsatellite Zone 1"]      = srb1,
		["Ringsatellite Zone 2"]      = srb1,
		["Athenos Zone"]              = srb1,
		["Great Unknown Zone"]        = srb1,
		["Void Zone"]                 = srb1,
		["Woodland Hill Zone"]        = srb1,
		["Rocky Mountain Zone"]       = srb1,
		["Hidden Palace Zone"]        = srb1
	} -- No, I don't space all this shit out manually, I have a plugin that lets me auto-align these. - Wolfs
	
	return list[name]
end

-- Global maplist function
function A_MServ_GetMapList() 
	local maplist = {}
	
	-- Simple function for checking and deciding on conditions on the fly
	local function tern(cond, t, f)
   		if cond return t else return f end
	end
	for i = 1, #mapheaderinfo do
		if mapheaderinfo[i] then
			local lvname = mapheaderinfo[i].lvlttl:gsub("%z.*", ""):lower():gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)..tern(mapheaderinfo[i].levelflags & LF_NOZONE, "", " Zone")..tern(mapheaderinfo[i].actnum == 0, "", " "..mapheaderinfo[i].actnum) -- Really long formula to generate the name string. Auto-capitalizes the first letter of each word.
			--print(i.."=>"..lvname)
			
			local gtlist
			if mapheaderinfo[i]["termcategory1"] then
				gtlist = {}
				local j = 1
				while mapheaderinfo[i]["termcategory"..j] do
					local s = mapheaderinfo[i]["termcategory"..j]
					j = j+1
					
					s:gsub("(.-),(.*)", function(name, category)
						local _ = (pcall(function()
							category = EvalMath(category)
						end) or (function()
							category = GT_COOP
							print("Invalid gametype!")
						end)())
						
						gtlist[name] = category
					end)
				end
			else
				gtlist = mapoverrides(lvname)
				if not gtlist then -- Terminal automatically detects maps and assigns them to a category based on their level types.
					gtlist = {}
					if (mapheaderinfo[i].typeoflevel & TOL_COOP) then
						gtlist["Co-op"] = GT_COOP
					end
					if (mapheaderinfo[i].typeoflevel & TOL_RACE) then
						gtlist["Race"] = GT_RACE
						gtlist["Competition"] = GT_COMPETITION
					end
					if (mapheaderinfo[i].typeoflevel & TOL_MATCH) then
						gtlist["Match"] = GT_MATCH
						gtlist["Team Match"] = GT_TEAMMATCH
					end
					if (mapheaderinfo[i].typeoflevel & TOL_TAG) then -- Yes, tag has its own TOL.
						--gtlist["Tag"] = GT_TAG -- But neither of these gametypes have functional scoring systems, so it looks like we're leaving them commented out.
						--gtlist["Hide and Seek"] = GT_HIDEANDSEEK
					end
					if (mapheaderinfo[i].typeoflevel & TOL_CTF) then
						gtlist["Capture the Flag"] = GT_CTF
					end
					--[[if (mapheaderinfo[i].typeoflevel & TOL_CUSTOM) then -- Custom gametype support!
						gtlist["Custom"] = GT_GAMETYPE -- Uncomment and give a base gametype to enable
					end]]
				end
			end
			
			for k,v in pairs(gtlist) do
				if not maplist[k] then
					maplist[k] = {v, {[i] = lvname}, i}
				else
					maplist[k][2][i] = lvname
				end
			end
		end 
	end
	
	return maplist-- ["Category Name"] = {gametype, maplist, defaultmap},
end
-- /map list

local function getMapChangePoll(poll, polltype)
		local answermaplist = {} -- This will be a list of map commands
		local answerstringlist = {}
		
		-- Get the current map's category
		local currentcategory
		local maplist = A_MServ_GetMapList()
		for category,v in pairs(maplist) do
			local gt = v[1]
			if gt ~= gametype then continue end -- Not in the right gametype, this can't be the right category!
			for mapnum, mapname in pairs(v[2]) do
				if mapnum == gamemap and gt == gametype then
					currentcategory = category
				end
			end
			if currentcategory then break end
		end
		
		-- Not in any category! Default to the first one we see, in case of changing maps
		if polltype == POLL_CHANGEMAP and not currentcategory then
			for k,_ in pairs(maplist) do
				currentcategory = k
				break
			end
		end
		
		-- Branch poll types
		if polltype == POLL_CHANGECATEGORY then
			poll.question = "Change to which gametype?" -- TODO: Category changes shouldn't use a default map, they should start a vote for a specific map too
			for category,v in pairs(maplist) do
				if category == currentcategory then continue end
				local defaultmap = v[3]
				table.insert(answermaplist, ("MAP %s -gametype %s -force"):format(G_BuildMapName(defaultmap), v[1]))
				table.insert(answerstringlist, category)
			end
		else
			poll.question = "Change to which map?"
			local mapnums = {}
			
			local mapnames = maplist[currentcategory][2]
			
			for i,_ in pairs(mapnames) do
				if i ~= gamemap then
					table.insert(mapnums, P_RandomKey(#mapnums)+1, i)
				end
			end
			
			local i = 1
			
			while i <= #mapnums and i <= 8 do
				answerstringlist[i] = mapnames[mapnums[i] ]
				answermaplist[i] = ("MAP %s -force"):format(G_BuildMapName(mapnums[i]))
				i = $1+1
			end
		end
		
		poll.answers = answerstringlist
		poll.done = function(poll, winner)
				COM_BufInsertText(A_MServ(), answermaplist[winner])
		end
		return poll
end

local function startPoll(polltype, arg)
	local poll = {
		votes = {},
		votemap = {},
		answers = {"Eggs", "wolfs", "LOL O HAY GUIZ"},
		question = "Why doesn't this poll have a question set?!",
		timer = pollopts().timeout*TICRATE,
		tiebreaker = function(...) -- This deals with ties. The default functionality is to return a random option from the ones given. (Args are each option in a tie)
			local opts = {...}
			return opts[P_RandomKey(#opts)+1]
		end,
		done = nil -- Set this to a function. Args are the poll itself, and the winning option
	}
	if polltype & POLL_START then
		polltype = $1&~POLL_START
		poll.answers = {"Yes", "No"}
		if polltype == POLL_CHANGEMAP then
			poll.question = "Change map?"
		elseif polltype == POLL_CHANGECATEGORY then
			poll.question = "Change the current gametype?"
		else
			poll.question = "Start doing nothing?"
		end
		poll.tiebreaker = do return 1 end
		poll.done = function(poll, winner)
			if winner == 1 then
				startPoll(polltype)
				return true -- Stop the game from removing the poll right after it starts
			end
		end
	elseif polltype == POLL_CHANGEMAP then
		poll = getMapChangePoll(poll, POLL_CHANGEMAP)
	elseif polltype==POLL_CHANGECATEGORY then
		poll = getMapChangePoll(poll, POLL_CHANGECATEGORY)
	elseif polltype == POLL_TEAMSCRAMBLE then
		poll.answers = {"Yes", "No"}
		poll.question = "Scramble teams?"
		poll.tiebreaker = do return 2 end
		poll.done = function(poll, winner)
			if winner == 1 then
				COM_BufInsertText(A_MServ(), "teamscramble 0;wait 1;teamscramble 1")
			end
		end
	elseif polltype == POLL_ENDMAP then
		poll.answers = {"Yes", "No"}
		poll.question = "End the current map?"
		poll.tiebreaker = do return 2 end
		poll.done = function(poll, winner)
			if winner == 1 then
				COM_BufInsertText(A_MServ(), "exitlevel")
			end
		end
	elseif polltype == POLL_RESETMAP then
		poll.answers = {"Yes", "No"}
		poll.question = "Reset the current map?"
		poll.tiebreaker = do return 2 end
		poll.done = function(poll, winner)
			if winner == 1 then
				COM_BufInsertText(A_MServ(), "map "..G_BuildMapName(gamemap).." -force")
			end
		end
	elseif polltype == POLL_KICK then
		poll.answers = {"Yes", "No"}
		poll.question = ("Kick %s?"):format(arg.name)
		poll.affectedplayer = arg
		poll.tiebreaker = do return 2 end
		poll.done = function(poll, winner)
			if not arg.valid then
				print("Player no longer present. Ignoring votekick results...")
			elseif winner == 1 then
				--print(("kick %s Votekicked from server"):format(#arg))
				COM_BufInsertText(A_MServ(), ("kick %s Votekicked from server"):format(#arg))
			else
				print(("Attempt to kick %s failed."):format(arg.name))
			end
		end
	elseif polltype == POLL_CUSTOM then
		poll.answers = arg.answers
		poll.question = arg.question
		poll.done = function(poll, winner)
			print(("\x82%s %s!"):format(poll.question, poll.answers[winner]))
		end
	elseif polltype == POLL_PLAYERS then
		poll.question = arg
		poll.answers = {}
		for p in players.iterate do
			table.insert(poll.answers, p.name)
		end
		poll.done = function(poll, winner)
			print((yellow.."%s %s!"):format(poll.question, poll.answers[winner]))
		end
	end
	
	A_MServ().voting = poll
end

-- Command to start a vote
COM_AddCommand("startvote", function(p, arg1, ...)
	if voting() then
		CONS_Printf(p, "There's already a vote in progress!")
		return
	end
	if p.polltimeout and not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You've already made a poll recently! Wait a bit.")
		return
	end
	if not arg1 then
		CONS_Printf(p, [[startvote <type> [<args>]: Start a vote to do something in-game!
Available poll types: changemap, changegametype, teamscramble, exitlevel, resetmap, kick]])
		return
	end
	p.polltimeout = pollopts().limiter*TICRATE*60 
	if arg1 == "changemap" then
		startPoll(POLL_START|POLL_CHANGEMAP)
		print(p.name.." wants to change the map.")
	elseif arg1 == "changegametype" then
		startPoll(POLL_START|POLL_CHANGECATEGORY)
		print(p.name.." wants to change the gametype.")
	elseif arg1 == "teamscramble" then
		startPoll(POLL_TEAMSCRAMBLE)
		print(p.name.." wants to scramble teams.")
	elseif arg1 == "exitlevel" then
		startPoll(POLL_ENDMAP)
		print(p.name.." wants to end the current level.")
	elseif arg1 == "resetmap" then
		startPoll(POLL_RESETMAP)
		print(p.name.." wants to reset the current level.")
	elseif arg1 == "kick" then
		if not ... then
			CONS_Printf(p, "startvote kick <player>: Vote to kick a specific player")
			return
		end
		local player = A_MServ_getPlayerFromString(...)
		if not player then
			CONS_Printf(p, ("Player %s doesn't exist!"):format(...))
			p.polltimeout = 0
			return
		end
		if A_MServ_HasPermission(player, UP_FULLCONTROL) then
			CONS_Printf(p, ("Player %s is an admin or host. You can't votekick those!"):format(...))
			p.polltimeout = 0
			return
		end
		startPoll(POLL_KICK, player)
		print(p.name.." wants to kick "..player.name..".")
	end
end)

-- Start a vote using POLL_CUSTOM
COM_AddCommand("startpoll", function(p, question, ...)
	if voting() then
		CONS_Printf(p, "There's already a vote in progress!")
		return
	end
	if p.polltimeout and not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You've already made a poll recently! Wait a bit.")
		return
	end
	if not question then
		CONS_Printf(p, [[startpoll <question> [<answer1> <answer2> <...>]: Start a poll with custom parameters!
If no answers are provided, the names of the current players will be used as answer choices.]])
		return
	end
	p.polltimeout = pollopts().limiter*TICRATE*60
	if not ... then
		startPoll(POLL_PLAYERS, question)
		print(p.name.." has a question about the players in the netgame.")
	else
		local _,check = ...
		if not check then
			CONS_Printf(p, "Polls must have at least two answers.")
			p.polltimeout = 0
			return
		end
		if #{...} > 36 then -- All the brightest lights can be tweaked to
			CONS_Printf(p, "Too many answer options - max is 35.") -- Cover up the worst of my worst intentions
			p.polltimeout = 0
			return -- Crash prevention...
		end
		
		startPoll(POLL_CUSTOM, {question = question, answers = {...}})
		print(p.name.." has a question to ask.")
	end
end)

-- Alias for votekicking
COM_AddCommand("votekick", function(p, arg)
	if arg then
		COM_BufInsertText(p, ("startvote kick %s"):format(arg))
	else
		CONS_Printf(p, "votekick <player>: Alias for startvote kick <player>.")
	end
end)

-- Vote!
COM_AddCommand("vote", function(p, opt)
	if not voting() then
		CONS_Printf(p, "There's no poll in progress!")
		return
	end
	opt = tonumber(opt)
	if opt == nil then
		CONS_Printf(p, "vote <number>: Vote for an option in a poll.")
		return
	end
	local poll = voting()
	if opt < 1 or opt > #poll.answers then
		CONS_Printf(p, "Answer out of range!")
		return
	end
	poll.votes[#p] = opt
	CONS_Printf(p, ("Voted for "..yellow.."%s"..white.."."):format(poll.answers[opt]))
end)

-- Resolve poll
local function resolvePoll(force)
	local winners = {}
	local winningcount = 0
	local poll = voting()
	for k,v in pairs(poll.votemap)
		if v == winningcount then
			table.insert(winners, k)
		elseif v > winningcount then
			winners = {k}
			winningcount = v
		end
	end
	if #winners == 0 then
		if not force then return end -- Give ties a chance to resolve if the time isn't up
		A_MServ().voting = nil -- Just kill the poll if nobody voted before timeup... ._.
		return
	end
	if #winners > 1 then
		if not force then return end 
		winners = {poll.tiebreaker(unpack(winners))}
	end
	winners = winners[1]
	local newpollset = false
	if poll.done then
		newpollset = poll.done(poll, winners)
	end
	if not newpollset then
		A_MServ().voting = nil
	end
end

addHook("ThinkFrame", do
	-- Reduce poll timeouts
	for p in players.iterate do
		if p.polltimeout and p.polltimeout > 0 then
			p.polltimeout = $1-1
		end
	end

	-- Get poll
	local poll = voting()
	if not poll then return end
	
	-- Count votes and compare to player count
	local votes = 0
	local voteMap = {}
	for k,v in pairs(poll.votes) do
		if players[k] and players[k].valid and v then
			votes = $1+1
			voteMap[v] = ($1 or 0)+1
		else
			poll.votes[k] = nil -- Player left, so remove their vote!
		end
	end
	poll.votemap = voteMap -- Used elsewhere for displaying votes on an option
	
	poll.timer = $1-1
	if poll.timer <= 0 then
		resolvePoll(true) -- Force poll to end, resolving tiebreakers if needed
		return
	end
	
	for p in players.iterate do
		votes = $1-1
	end
	if votes >= 0 then
		resolvePoll(false) -- Resolve poll if there's a winner, but give ties a chance to resolve naturally before breaking them
	end
end)

-- Render the poll on the HUD
hud.add(function(v, player)
	local poll = voting()
	if not poll then return end -- No poll in progress!
	local winners = {}
	local winningcount = 0
	for k,v in pairs(poll.votemap)
		if v == winningcount then
			table.insert(winners, k)
		elseif v >= winningcount then
			winners = {k}
			winningcount = v
		end
	end
	
	-- Determine if the player has voted
	local voted = 0
	local voteopt = 0
	for k,v in pairs(poll.votes) do
		if v and k == #player then
			voted = V_70TRANS
			voteopt = v
			break
		end
	end
	
	-- For centering
	local height = #poll.answers*8+12
	height = 96-($1/2)
	if height < 0 then
		height = FixedMul(height, cos(leveltime*(ANG30/height)))+height+3
	end
	
	v.drawString(320, height-12, (poll.timer/TICRATE) .. " seconds remaining", voted|V_ALLOWLOWERCASE, "right")
	v.drawString(320,height, "  "..poll.question,voted|V_ALLOWLOWERCASE,"right")
	for i = 1,#poll.answers do
		local y = i*8+height+4
		local flag = 0
		if i == voteopt then
			flag = V_GREENMAP
		end
		v.drawString(300,y,i..": "..poll.answers[i], flag|voted|V_ALLOWLOWERCASE, "right")
		
		flag = V_REDMAP
		for _,j in ipairs(winners) do
			if i==j then
				flag = V_BLUEMAP
				break
			end
		end
		v.drawString(320,y,poll.votemap[i] or 0, flag|voted|V_ALLOWLOWERCASE, "right")
	end
end, "game")

-- Poll management commands
COM_AddCommand("votetime", function(p, timer)
	if not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	timer = tonumber(timer)
	if not timer then
		CONS_Printf(p, "votetime <time>: Set the time limit to vote on a poll, in seconds.")
		CONS_Printf(p, ("The current value is %s, default is 60"):format(pollopts().timeout))
		return
	end
	pollopts().timeout = timer
	print(p.name.." changed vote time to "..timer.." seconds.")
end)

COM_AddCommand("pollthrottle", function(p, timer)
	if not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	timer = tonumber(timer)
	if not timer then
		CONS_Printf(p, "pollthrottle <time>: Set the minimum wait between a user making polls, in minutes.")
		CONS_Printf(p, ("The current value is %s, default is 6"):format(pollopts().limiter))
		return
	end
	pollopts().limiter = timer
	print(p.name.." changed poll throttle to "..timer.." minutes.")
end)

COM_AddCommand("resolvepoll", function(p)
	if not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	if not voting() then
		CONS_Printf(p, "No poll to resolve!")
		return
	end
	print(p.name.." forced the current poll to close voting.")
	resolvePoll(true) -- Force poll to end, resolving tiebreakers if needed
end)

COM_AddCommand("removepoll", function(p)
	if not A_MServ_HasPermission(p, UP_GAMEMANAGE) then
		CONS_Printf(p, "You need \"manager\" permissions to use this!")
		return
	end
	if not voting() then
		CONS_Printf(p, "No poll to remove!")
		return
	end
	print(p.name.." killed the current poll.")
	A_MServ().voting = nil
end)
