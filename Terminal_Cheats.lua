-- Terminal Cheats:
-- Optional file. Meant to screw with the game! (Requires Terminal_Core.lua)

assert(terminal, "the Terminal core script must be added first!")

-- If it's a cheat in vanilla, it's here. If it isn't, it probably is anyways.

--SetRings Command
COM_AddCommand("setrings", function(p, health)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatglobal) then
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
		CONS_Printf(p, "setrings <number of rings>: Sets everyone's rings to a specific number.")
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
	if not terminal.HasPermission(p, terminal.permissions.text.cheatglobal) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	lives = tonumber(lives)
	if lives then
		if lives >= 127 then
			lives = 127
		end
		if lives < 0 then
			lives = nil
		end
	else
		CONS_Printf(p, "setlives <number of lives>: Sets the player's lives to a specific number.")
		return
	end
	for player in players.iterate
		player.lives = lives
	end
end)

--God Command
COM_AddCommand("god", function(player)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	if not (player.pflags & PF_GODMODE)
		player.pflags = $1|PF_GODMODE
		CONS_Printf(player, "Sissy mode enabled.")
	else 
		player.pflags = $1 & ~PF_GODMODE
		CONS_Printf(player, "Sissy mode disabled.")
	end
end)

--NoClip Command
COM_AddCommand("noclip", function(player)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	if not (player.pflags & PF_NOCLIP)
		player.pflags = $1|PF_NOCLIP
		CONS_Printf(player, "NoClip enabled.")
	else 
		player.pflags = $1 & ~PF_NOCLIP
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

-- TODO: Add actual devmode things to devmode
COM_AddCommand("devmode", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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

-- Go to another player!
COM_AddCommand("warpto", function(p, arg1)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if arg1 == nil then
		CONS_Printf(p, "warpto <player>: Warp to another player's location!")
		return
	end
	local player = terminal.GetPlayerFromString(arg1)
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
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if player.playerstate ~= PST_LIVE then CONS_Printf(player, "You're dead, stupid.") return end
	CONS_Printf(player, "Fear my overpowered recolor!")
	player.powers[pw_emeralds] = 127
end)

-- Change your scale
COM_AddCommand("scale", function(p, scale)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	local nScale = terminal.FloatFixed(scale)
	if not nScale then
		CONS_Printf(p, "scale <number>: Make yourself bigger or smaller!")
		return
	end
	p.mo.destscale = nScale
	--print(p.name .. " changed size using black magic!")
end)

-- Change your character's ability!
COM_AddCommand("charability", function(player, arg1)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(player, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not arg1 then
		CONS_Printf(player, "charability2 <ability>: Change your secondary ability! Accepts CA2_ arguments or numbers.")
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
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
		player.actionspd = terminal.FloatFixed(arg1)
	end
end)

-- On-demand gravity flip! Whee~
COM_AddCommand("gravflip", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	p.mo.flags2 = $1^^MF2_OBJECTFLIP
end)

-- Summon a shield to aid your quest!
COM_AddCommand("giveshield", function(p, shield)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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

-- Help listing
terminal.AddHelp("cheats",
[[The Terminal cheats module provides various console commands to mess with the game with! Most of the commands need either "cheatself" or "cheatglobal" permissions.

Some useful commands:
  god, noclip, devmode: Same (or similar) functions as in the full game.
  showplayers: Toggles drawing crosshairs pointing at every friendly player in the game.
  warpto: Teleport to another player.
  giveshield: Get a shield.
  setrings, setlives: Self-explanatory.

More commands are available, too.]])

-- BREAKING NEWS: WOLFY ADDS USELESS SILLY THINGS -Red

-- Template function for evaluating psuedo variables in flag strings
local function generateFlags(flags, original)
	local flagtype = original
	local test = pcall(function()
		flags = $1:gsub("$1", original)--[[
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
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not flags then
		CONS_Printf(p, [[skinflags <flags>: Change your current skin flags! You can set multiple flags with the | operator. Flag prefix is SF_. 
Examples: ($1 represents the current value of the flags)
]]..terminal.colors.yellow..[['$1|SF_FLAG']]..terminal.colors.white..[[ will add the specified flag. 
]]..terminal.colors.yellow..[['$1&!SF_FLAG']]..terminal.colors.white..[[ will remove the flag.
]]..terminal.colors.yellow..[['SF_FLAG|SF_FLAG2']]..terminal.colors.white..[[ will give you only the specified flags.]])
		return
	end
	local test = generateFlags(flags, p.charflags)
	if test == nil then
		CONS_Printf(p, "Error occured while parsing "..terminal.colors.yellow..flags..terminal.colors.white..".")
		return
	end
	p.charflags = test
end)

-- Mobj flags, useful for screwing around
COM_AddCommand("mobjflags", function(p, flags)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
		CONS_Printf(p, "Error occured while parsing "..terminal.colors.yellow..flags..terminal.colors.white..".")
		return
	end
	p.mo.flags = test
end)

-- Mobj flags 2, more stuff to mess around with
COM_AddCommand("mobjflags2", function(p, flags)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
		CONS_Printf(p, "Error occured while parsing "..terminal.colors.yellow..flags..terminal.colors.white..".")
		return
	end
	p.mo.flags2 = test
end)

-- Mobj extra flags, you know the drill.
COM_AddCommand("mobjeflags", function(p, flags)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
		CONS_Printf(p, "Error occured while parsing "..terminal.colors.yellow..flags..terminal.colors.white..".")
		return
	end
	p.mo.eflags = test
end)


-- Player flags, for all kinds of things!
COM_AddCommand("pflags", function(p, flags)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
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
		CONS_Printf(p, "Error occured while parsing "..terminal.colors.yellow..flags..terminal.colors.white..".")
		return
	end
	p.pflags = test
end)

-- Kills all enemies in the map, provided they're actually enemies
COM_AddCommand("destroyallenemies", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatglobal) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	for player in players.iterate
		for mobj in thinkers.iterate("mobj") do
			if ((mobj.valid) and ((mobj.flags & MF_ENEMY) or (mobj.flags & MF_BOSS))) then
				P_KillMobj(mobj, player.mo, player.mo)
			end
		end
	end
end)

--Spawn an object by the power of EvalMath!
COM_AddCommand("spawnobject", function(p, objecttype)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatglobal) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	if not objecttype then CONS_Printf(p, "spawnobject <mobj>: Spawns the corresponding mobj 100 fracunits in front of you!") return end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	local call = pcall(do P_SpawnMobj(p.mo.x + 100*cos(p.mo.angle), p.mo.y + 100*sin(p.mo.angle), p.mo.z, EvalMath(objecttype)) end) -- I think this is how you do it?
	if not call then CONS_Printf(p, "Error occurred while parsing "..terminal.colors.yellow..objecttype..terminal.colors.white..".") return end
end)
