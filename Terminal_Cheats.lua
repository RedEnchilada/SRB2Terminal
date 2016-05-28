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
	if not health or (tonumber(health) < 0) then
		CONS_Printf(p, "setrings <number of rings>: Sets everyone's rings to a specific number.")
		return
	end
	health = tonumber(health)
	if (health >= 9999) then
		health = 9999
	end
	for player in players.iterate do
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
	if not lives or (tonumber(lives) < 0) then 
		CONS_Printf(p, "setlives <number of lives>: Sets the player's lives to a specific number.")
		return
	end
	lives = tonumber(lives)
	if (lives >= 127) then
		lives = 127
	end
	for player in players.iterate do
		player.lives = lives
	end
end)

--God Command
COM_AddCommand("god", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if not (p.pflags & PF_GODMODE) then
		p.pflags = $1|PF_GODMODE
		CONS_Printf(p, "Sissy mode enabled.")
	else 
		p.pflags = $1 & ~PF_GODMODE
		CONS_Printf(p, "Sissy mode disabled.")
	end
end)

--NoClip Command
COM_AddCommand("noclip", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if not (p.pflags & PF_NOCLIP) then
		p.pflags = $1|PF_NOCLIP
		CONS_Printf(p, "NoClip enabled.")
	else 
		p.pflags = $1 & ~PF_NOCLIP
		CONS_Printf(p, "NoClip disabled.")
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
hud.add(function(v, p)
	if p.devmodeOn then
		local right = "right"
		v.drawString(232, 160, string.format("Pos= %4d,  \n %4d, %4d", p.mo.x/FRACUNIT, p.mo.y/FRACUNIT, p.mo.z/FRACUNIT), V_MONOSPACE|V_RETURN8, "left")
		v.drawString(320, 176, string.format("Ang= %3d", AngleFixed(p.mo.angle)/FRACUNIT), V_MONOSPACE, right)
		v.drawString(320, 184, string.format("Mom= %3d, %3d, %3d", p.mo.momx/FRACUNIT, p.mo.momy/FRACUNIT, p.mo.momz/FRACUNIT), V_MONOSPACE, right)
		v.drawString(320, 192, p.speed/FRACUNIT.." fasts/h", V_MONOSPACE, right)
	end
end, "game")

-- TODO: Add actual devmode things to devmode
COM_AddCommand("devmode", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.devmodeOn then
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
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
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
COM_AddCommand("suicide", function(p)
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	if p.mo and p.mo.health > 0 then
		P_DamageMobj(p.mo, nil, nil, 10000)
		print(p.name.." committed seppuku.")
	end
end)

-- Gain overpowered qualities!
COM_AddCommand("getallemeralds", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	CONS_Printf(p, "Fear my overpowered recolor!")
	p.powers[pw_emeralds] = 127
end)

-- Change your scale
COM_AddCommand("scale", function(p, scale)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
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
COM_AddCommand("charability", function(p, arg1)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if not arg1 then
		CONS_Printf(p, "charability <ability>: Change your ability! Accepts CA_ arguments or numbers.")
		return
	end
	if arg1 == "default" then
		p.charability = skins[p.mo.skin].ability
	else
		if tonumber(arg1) then
			p.charability = tonumber(arg1)
		else
			if (arg1:sub(1, 3):upper() == "CA_") then
				p.charability = _G[arg1:upper()]
			else
				p.charability = _G["CA_"..arg1:upper()]
			end
		end
	end
end)

-- Can't forget ability2!
COM_AddCommand("charability2", function(p, arg1)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if not arg1 then
		CONS_Printf(p, "charability2 <ability>: Change your secondary ability! Accepts CA2_ arguments or numbers.")
		return
	end
	if arg1 == "default" then
		p.charability2 = skins[p.mo.skin].ability2
	else
		if tonumber(arg1) then
			p.charability2 = tonumber(arg1)
		else
			if (arg1:sub(1, 4):upper() == "CA2_") then
				p.charability2 = _G[arg1:upper()]
			else
				p.charability2 = _G["CA2_"..arg1:upper()]
			end
		end
	end
end)

-- ActionSpeed, for science.
COM_AddCommand("actionspd", function(p, arg1)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if not arg1 then
		CONS_Printf(p, "actionspd <value>: Change how fast you can execute abilities.")
		return
	end
	if arg1 == "default" then
		p.actionspd = skins[p.mo.skin].actionspd
	else
		p.actionspd = terminal.FloatFixed(arg1)
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

-- By the power of 2.1.9+, RunOnWater!
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

-- Helper function for parsing flag tables
terminal.generateFlags = function(flagtype, flags)
	local ret, flagprefix
	local newflags = {}
	if flagtype == "skin" then
		flagprefix = "SF_"
	elseif flagtype == "mobj" then
		flagprefix = "MF_"
	elseif flagtype == "mobj2" then
		flagprefix = "MF2_"
	elseif flagtype == "extra" then
		flagprefix = "MFE_"
	else
		flagprefix = "PF_"
	end
	for i, v in ipairs(flags) do
		flags[i] = $1:upper()
		if flags[i]:sub(1, flagprefix:len()) ~= flagprefix then
			flags[i] = flagprefix..flags[i]
		end
		newflags[i] = _G[flags[i]]
		if (ret == nil) then
			ret = newflags[i]
		else
			ret = $1|newflags[i]
		end
	end
	return ret
end

-- Add flags to the player!
COM_AddCommand("addflags", function(p, flagtype, ...)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not ... or not flagtype then
		CONS_Printf(p, [[addflags <flagtype> <flags>: Add to your current flags! You can separate multiple flags with a space. Possible flag types are skin, mobj, mobj2, extra, and player. 
Flags don't need prefixes (SF_) and can also be lowercase.
Example usage: 'addflags skin runonwater noskid']])
		return
	end
	
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	
	local setflags = terminal.generateFlags(flagtype, {...})
	local cmd = flagtype.." "..table.concat({...}, " ")
	if setflags == nil then
		CONS_Printf(p, "Error occurred while parsing "..terminal.colors.yellow..cmd..terminal.colors.white..".")
		return
	end
	if flagtype == "skin" then
		p.charflags = $1|setflags
	elseif flagtype == "mobj" then
		p.mo.flags = $1|setflags
	elseif flagtype == "mobj2" then
		p.mo.flags2 = $1|setflags
	elseif flagtype == "extra" then
		p.mo.eflags = $1|setflags
	elseif flagtype == "player" then
		p.pflags = $1|setflags
	end
end)

-- Remove them, too!
COM_AddCommand("removeflags", function(p, flagtype, ...)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatself) then
		CONS_Printf(p, "You need \"cheatself\" permissions to use this!")
		return
	end
	if not ... or not flagtype then
		CONS_Printf(p, [[removeflags <flagtype> <flags>: Remove some of your current flags! You can separate multiple flags with a space. Possible flag types are skin, mobj, mobj2, extra, and player. 
Flags don't need prefixes (SF_) and can also be lowercase.
Example usage: 'removeflags skin runonwater noskid']])
		return
	end
	
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	if p.playerstate ~= PST_LIVE then CONS_Printf(p, "You're dead, stupid.") return end
	
	local setflags = terminal.generateFlags(flagtype, {...})
	local cmd = flagtype.." "..table.concat({...}, " ")
	if setflags == nil then
		CONS_Printf(p, "Error occurred while parsing "..terminal.colors.yellow..cmd..terminal.colors.white..".")
		return
	end
	if flagtype == "skin" then
		p.charflags = $1 & ~setflags
	elseif flagtype == "mobj" then
		p.mo.flags = $1 & ~setflags
	elseif flagtype == "mobj2" then
		p.mo.flags2 = $1 & ~setflags
	elseif flagtype == "extra" then
		p.mo.eflags = $1 & ~setflags
	elseif flagtype == "player" then
		p.pflags = $1 & ~setflags
	end
end)

-- Kills all enemies in the map, provided they're actually enemies
COM_AddCommand("destroyallenemies", function(p)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatglobal) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	for mobj in thinkers.iterate("mobj") do
		if ((mobj.valid) and ((mobj.flags & MF_ENEMY) or (mobj.flags & MF_BOSS))) then
			P_KillMobj(mobj, p.mo, p.mo)
		end
	end
end)

-- Spawn an object!
COM_AddCommand("spawnobject", function(p, objecttype)
	if not terminal.HasPermission(p, terminal.permissions.text.cheatglobal) then
		CONS_Printf(p, "You need \"cheatglobal\" permissions to use this!")
		return
	end
	objecttype = $1:upper()
	if (objecttype:sub(1, 3) ~= "MT_") then
		objecttype = "MT_"..$1
	end
	if not objecttype then CONS_Printf(p, "spawnobject <mobj>: Spawns the corresponding mobj 100 fracunits in front of you!") return end
	if not p.mo then CONS_Printf(p, "You can't use this while you're spectating.") return end
	local call = pcall(do
		local butt = P_SpawnMobj(p.mo.x + 100*cos(p.mo.angle), p.mo.y + 100*sin(p.mo.angle), p.mo.z, _G[objecttype])
		butt.angle = p.mo.angle
	end)
	if not call then CONS_Printf(p, "Error occurred while parsing "..terminal.colors.yellow..objecttype..terminal.colors.white..".") return end
end)
