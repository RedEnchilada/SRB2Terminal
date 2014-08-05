-- Terminal Cheats:
-- Optional file. Meant to screw with the game! (Requires Terminal_Core.lua)

-- Permissions used in this file
local UP_SELFCHEATS = 1
local UP_OTHERCHEATS = 2
local UP_GLOBALCHEATS = 4

-- Colors:

local white = "\x80" 
local purple = "\x81" 
local yellow = "\x82" 
local green = "\x83" 
local blue = "\x84" 
local red = "\x85" 
local grey = "\x86" 
local orange = "\x87" 

--SetRings Command
COM_AddCommand("setrings", function(p, health)
	if not A_MServ_HasPermission(p, UP_GLOBALCHEATS) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	health = tonumber(health)
	if health and health >= 9999
		health = 9999
	end
	if health and health < 0
		health = nil
	end
	if health == nil
		CONS_Printf(p, "setrings <number of rings>: Sets the player's rings to a specific number.")
		return
	end
	for player in players.iterate
		if player.spectator then continue end
		player.health = health 
		player.mo.health = health 
		P_GivePlayerRings(player, 1)
	end
end)

--SetLives Command
COM_AddCommand("setlives", function(p, lives)
	if not A_MServ_HasPermission(p, UP_GLOBALCHEATS) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	lives = tonumber(lives)
	if lives and lives >= 127
		lives = 127
	end
	if lives and lives < 0
		lives = nil
	end
	if lives == nil
		CONS_Printf(p, "setlives <number of lives>: Sets the player's lives to a specific number.")
		return
	end
	for player in players.iterate
		player.lives = lives
	end
end)

--God Command
COM_AddCommand("god", function(player)
	if not A_MServ_HasPermission(player, UP_SELFCHEATS) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	if not (player.pflags & PF_GODMODE)
		player.pflags = $1|PF_GODMODE
		--CONS_Printf(player, "Skybase mode enabled.")
		CONS_Printf(player, "Sissy mode enabled.")
	else 
		player.pflags = $1 & ~PF_GODMODE
		--CONS_Printf(player, "Skybase mode disabled.")
		CONS_Printf(player, "Sissy mode disabled.")
	end
end)

--NoClip Command
COM_AddCommand("noclip", function(player)
	if not A_MServ_HasPermission(player, UP_SELFCHEATS) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	if not (player.pflags & PF_NOCLIP)
		player.pflags = $1|PF_NOCLIP
		--CONS_Printf(player, "<BlueCore> Walls arent used in good level design.")
		CONS_Printf(player, "NoClip enabled.")
	else 
		player.pflags = $1 & ~PF_NOCLIP
		--CONS_Printf(player, "*Mystic has kicked BlueCore from #srb2fun (There are a lot of things you are not understanding, and this is one of them.)")
		CONS_Printf(player, "NoClip disabled.")
	end
end)

--[[Old devmode stuff.
hud.add(function(v, player)
	if player.devmodeOn then
		v.drawString(320, 168, string.format("X: %6d", player.mo.x>>FRACBITS), V_MONOSPACE, "right")
		v.drawString(320, 176, string.format("Y: %6d", player.mo.y>>FRACBITS), V_MONOSPACE, "right")
		v.drawString(320, 184, string.format("Z: %6d", player.mo.z>>FRACBITS), V_MONOSPACE, "right")
		v.drawString(320, 192, string.format("A: %6d", AngleFixed(player.mo.angle)/FRACUNIT), V_MONOSPACE, "right")
	end
end, "game")]]

-- Devmode ~ Lemme know if it should be done differently. -Red
hud.add(function(v, player)
	if player.devmodeOn then
		local right = "right"
		v.drawString(232, 160, string.format("Pos= %4d,  \n %4d, %4d", player.mo.x/FRACUNIT, player.mo.y/FRACUNIT, player.mo.z/FRACUNIT), V_MONOSPACE|V_RETURN8, "left")
		v.drawString(320, 176, string.format("Ang= %3d", AngleFixed(player.mo.angle)/FRACUNIT), V_MONOSPACE, right)
		v.drawString(320, 184, string.format("Mom= %3d, %3d, %3d", player.mo.momx/FRACUNIT, player.mo.momy/FRACUNIT, player.mo.momz/FRACUNIT), V_MONOSPACE, right)
		v.drawString(320, 192, player.speed/FRACUNIT.." fasts/h", V_MONOSPACE, right)
	end
end, "game")

COM_AddCommand("devmode", function(p)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.devmodeOn
		p.devmodeOn = true
		CONS_Printf(p, "Not actually developer mode enabled.")
	else 
		p.devmodeOn = false
		CONS_Printf(p, "Not actually developer mode disabled.")
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

-- Go to another player!
COM_AddCommand("warpto", function(p, arg1)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if arg1 == nil then
		CONS_Printf(p, "warpto <player>: Warp to another player's location!")
		return
	end
	local player = A_MServ_getPlayerFromString(arg1)
	if not player then
		CONS_Printf(p, "Player "..arg1.." does not exist!")
		return
	end
	if player.spectator then
		CONS_Printf(p, "Cannot warp to spectator \""..player.name.."\".")
		return
	end
	P_TeleportMove(p.mo, player.mo.x, player.mo.y, player.mo.z)
	--print(p.name.." is now touching butts with "..player.name..".")
	P_FlashPal(p, PAL_MIXUP, 10)
	S_StartSound(p.mo, sfx_mixup)
end)

-- Kill urself, loser
COM_AddCommand("suicide", function(player)
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	if player.mo and player.mo.health > 0
		P_DamageMobj(player.mo, nil, nil, 10000)
		print(player.name+" committed seppuku.")
	end
end)

-- Gain overpowered qualities!
COM_AddCommand("getallemeralds", function(player)
	if not A_MServ_HasPermission(player, UP_SELFCHEATS) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	CONS_Printf(player, "Fear my overpowered recolor!")
	player.powers[pw_emeralds] = 127
end)

-- Change your scale
COM_AddCommand("scale", function(p, scale)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	local nScale = A_MServ_floatFixed(scale)
	if not nScale then
		CONS_Printf(p, "scale <number>: Make yourself bigger or smaller!")
		return
	end
	p.mo.destscale = nScale
	--print(p.name .. " changed size using black magic!")
end)

-- Change your character's ability!
COM_AddCommand("charability", function(player, arg1)
	if not A_MServ_HasPermission(player, UP_SELFCHEATS) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not arg1 then
		CONS_Printf(player, "charability <ability>: Change your ability! Accepts CA_ arguments or numbers.")
		return
	end
	if arg1 == "default" then
		player.charability = skins[player.mo.skin].ability
	else
		player.charability = EvalMath(arg1:upper())
	end
end)

-- Can't forget ability2!
COM_AddCommand("charability2", function(player, arg1)
	if not A_MServ_HasPermission(player, UP_SELFCHEATS) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not arg1 then
		CONS_Printf(player, "charability2 <ability>: Change your secondary ability! Accepts CA_ arguments or numbers.")
		return
	end
	if arg1 == "default" then
		player.charability2 = skins[player.mo.skin].ability2
	else
		player.charability2 = EvalMath(arg1:upper())
	end
end)

-- ActionSpeed, for science.
COM_AddCommand("actionspd", function(player, arg1)
	if not A_MServ_HasPermission(player, UP_SELFCHEATS) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not arg1 then
		CONS_Printf(player, "actionspd <value>: Change how fast you can execute abilities.")
		return
	end
	if arg1 == "default" then
		player.actionspd = skins[player.mo.skin].actionspd
	else
		player.actionspd = (tonumber(arg1))*FRACUNIT
	end
end)

-- On-demand gravity flip! Whee~
COM_AddCommand("gravflip", function(p)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	p.mo.flags2 = $1^^MF2_OBJECTFLIP
end)

-- Summon a shield to aid your quest!
COM_AddCommand("giveshield", function(p, shield)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	local sh = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_THOK)
	sh.target = p.mo
	
	if shield == "none" or shield == "remove" then
		P_RemoveShield(p)
	elseif shield == "force" then
		--P_RemoveShield(p)
		A_ForceShield(sh)
	elseif shield == "pity" then
		--P_RemoveShield(p)
		A_PityShield(sh)
	elseif shield == "elemental" or shield == "fire" then
		--P_RemoveShield(p)
		A_WaterShield(sh)
	elseif shield == "attraction" or shield == "ring" then
		--P_RemoveShield(p)
		A_RingShield(sh)
	elseif shield == "whirlwind" or shield == "jump" then
		--P_RemoveShield(p)
		A_JumpShield(sh)
	elseif shield == "armageddon" or shield == "nuke" then
		--P_RemoveShield(p)
		A_BombShield(sh)
	else
		CONS_Printf(p, [[giveshield <type>: Give yourself a shield of a certain type!
Possible values: none (removes your shield), force, elemental AKA fire, attraction AKA ring, whirlwind AKA jump, armageddon AKA nuke, pity]])
		P_RemoveMobj(sh)
		return
	end
	P_RemoveMobj(sh)
	S_StartSound(p.mo, sfx_shield)
	CONS_Printf(p, "Shield changed to \""..shield.."\".")
end)

-- By the power of 2.1.9, RunOnWater!
COM_AddCommand("runonwater", function(p)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not (p.charflags & SF_RUNONWATER) then
		CONS_Printf(p, "Water running enabled.")
		p.charflags = $1|SF_RUNONWATER
	else
		p.charflags = $1 & ~SF_RUNONWATER
		CONS_Printf(p, "Water running disabled.")
	end
end)

local function generateFlags(flags, original)
	local flagtype = original
	local test = pcall(function()
		flags = $1:replace("$1", original)--[[
		if flags:sub(1, 3) == "$1|" then
			flagtype = $1|EvalMath(flags:upper():sub(4))
		elseif flags:sub(1, 3) == "$1&" then
			flagtype = $1&EvalMath(flags:upper():sub(4))
		elseif flags:sub(1, 4) == "$1^^" then
			flagtype = $1^^EvalMath(flags:upper():sub(5))
		else]]
			flagtype = EvalMath(flags:upper())
		--end
	end)
	if not test then
		return nil
	end
	return flagtype
end

-- Skin flags, because why not?
COM_AddCommand("skinflags", function(p, flags)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not flags then
		CONS_Printf(p, [[skinflags <flags>: Change your current skin flags! You can set multiple flags with the | operator. Flag prefix is SF_. 
Examples: ($1 represents the current value of the flags)
]]..yellow..[['$1|SF_FLAG']]..white..[[ will add the specified flag. 
]]..yellow..[['$1&!SF_FLAG']]..white..[[ will remove the flag.
]]..yellow..[['SF_FLAG|SF_FLAG2']]..white..[[ will give you only the specified flags.]])
		return
	end
	local test = generateFlags(flags, p.charflags)
	if test == nil then
		CONS_Printf(p, "Error occured while parsing"..yellow..flags..white..".")
		return
	end
	p.charflags = test
end)

-- Mobj flags, useful for screwing around
COM_AddCommand("mobjflags", function(p, flags)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if not flags then
		CONS_Printf(p, [[mobjflags <flags>: Change your current mobj flags! You can set multiple flags with the | operator. Flag prefix is MF_, see the 'skinflags' command for examples.]])
		return
	end
	local test = generateFlags(flags, p.mo.flags)
	if test == nil then
		CONS_Printf(p, "Error occured while parsing"..yellow..flags..white..".")
		return
	end
	p.mo.flags = test
end)

-- Mobj flags 2, more stuff to mess around with
COM_AddCommand("mobjflags2", function(p, flags)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if not flags then
		CONS_Printf(p, [[mobjflags2 <flags>: Change your current MF2 flags! You can set multiple flags with the | operator. Flag prefix is MF2_, see the 'skinflags' command for examples.]])
		return
	end
	local test = generateFlags(flags, p.mo.flags2)
	if test == nil then
		CONS_Printf(p, "Error occured while parsing"..yellow..flags..white..".")
		return
	end
	p.mo.flags2 = test
end)

-- Mobj extra flags, you know the drill.
COM_AddCommand("mobjeflags", function(p, flags)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if not flags then
		CONS_Printf(p, [[mobjeflags <flags>: Change your current mobj extra flags! You can set multiple flags with the | operator. Flag prefix is MFE_, see the 'skinflags' command for examples.]])
		return
	end
	local test = generateFlags(flags, p.mo.eflags)
	if test == nil then
		CONS_Printf(p, "Error occured while parsing"..yellow..flags..white..".")
		return
	end
	p.mo.eflags = test
end)


-- Player flags, for all kinds of things!
COM_AddCommand("pflags", function(p, flags)
	if not A_MServ_HasPermission(p, UP_SELFCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if not flags then
		CONS_Printf(p, [[pflags <flags>: Change your current player flags! You can set multiple flags with the | operator. Flag prefix is PF_, see the 'skinflags' command for examples.]])
		return
	end
	local test = generateFlags(flags, p.pflags)
	if test == nil then
		CONS_Printf(p, "Error occured while parsing"..yellow..flags..white..".")
		return
	end
	p.pflags = test
end)

-- Kills all enemies in the map, provided they're actually enemies
COM_AddCommand("destroyallenemies", function(p)
	if not A_MServ_HasPermission(p, UP_GLOBALCHEATS) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	for mobj in thinkers.iterate("mobj") do
		if ((mobj.valid) and ((mobj.flags & MF_ENEMY) or (mobj.flags & MF_BOSS))) then
			P_KillMobj(mobj)
			for player in players.iterate do
				P_AddPlayerScore(p, 100)
			end
		end
	end
end)
