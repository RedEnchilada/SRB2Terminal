-- Terminal - Lightdash Miscellaneous Stuff
-- Cool extra things that we have because lol.

--Jump Thok ability, version 2.0
--Porting started by Wolfy, but Sryder13 did pretty much all of 2.0, so he gets all the credit for this one
--Original Riders coding by Chaos Zero 64


-- This function is mostly stuff taken from the exe and converted to lua
local function CheckIfCanUseAbility(player)
	if (player.cmd.buttons & BT_JUMP
	and not (player.previouspflags & PF_JUMPDOWN) -- They aren't holding the jump button down are they?
	and player.previouspflags & PF_JUMPED -- Make sure they have actually jumped already
	and not player.exiting and not P_PlayerInPain(player)
	and not player.powersuper)
		if (P_IsObjectOnGround(player.mo) or player.climbing or (player.previouspflags & (PF_CARRIED|PF_ITEMHANG|PF_ROPEHANG)) or player.groundcheck)
			return false;
		elseif ((player.previouspflags & PF_MACESPIN) and player.previoustracer)
			return false;
		elseif (not (player.previouspflags & PF_SLIDING) and ((gametype != GT_CTF) or (not player.gotflag)))
			return true;
		end
	end
	return false;
end

-- if thoksound is replaced with true, thoksound will play. otherwise, no sound for you.
local function DoPlayerJumpThok(player, thoksound) --performs jumpthok.
	if not (player.previouspflags & (PF_ROPEHANG|PF_CARRIED|PF_ITEMHANG|PF_MACESPIN)) 
		local actionspd = player.actionspd; --for ease of typing
		if (player.mo.eflags & MFE_UNDERWATER) --yay you're underwater! slow down.
			actionspd = $1 >> 1; -- half speed, don't know why bitshift was used
		end
		if (actionspd > player.normalspeed) --if you're too fast
			actionspd = player.normalspeed --SLOW DOWN.
		end
		--actionspd = $1 / 3; --(BALANCE)TD leftover. makes the jumpthok execute slower, so the thrust is less instant.
		
		P_InstaThrust(player.mo, player.mo.angle, FixedMul(actionspd, player.mo.scale)); -- ZOOM
		
		if (not(player.pflags & PF_THOKKED) -- Never do the jump more than once, even if you have multiability
		and player.thokitem == mobjinfo[MT_PLAYER].painchance) -- This is so that custom characters that like to use the thokitem don't break
			player.pflags = $1&~PF_JUMPED
			P_DoJump(player, false)
		end
		if (player.mo.info.attacksound and not player.spectator and thoksound) --if thoksound argument is true
			S_StartSound(player.mo, player.mo.info.attacksound); -- Play the THOK sound
		end
		
		local thok = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_THOK)
		thok.color = player.mo.color
		
		player.pflags = $1&~PF_SPINNING; -- Not spinning or revving anymore
		player.pflags = $1&~PF_STARTDASH
		player.pflags = $1|PF_THOKKED; -- They thokked!
		if (maptol & TOL_2D) --if in 2D/SRB1
			player.mo.momx = $1/2 --slow momentum down, make it more controllable
			player.mo.momy = $1/2 --same with y momentum for balance
		end
	end
end

addHook("MobjThinker", function(mobj)
	if mobj.player --Affects players only.
		local player = mobj.player
		if (player.previouspflags == nil)
			player.previouspflags = PF_JUMPDOWN;
		end
		
		if (player.powersuper == nil) -- Used to check if the player is not already super(just turned super) in LuaSuperReady()
			player.powersuper = 0;
		end
		
		if player.groundcheck == nil
			player.groundcheck = 0 -- you don't want to thok on the ground, do you?
		end
		
		if (player.mo and player.mo.skin == "sonic") -- skin restriction
		and ((gametype == GT_RACE) or (gametype == GT_COMPETITION))
		player.charability = CA_NONE
			if not (player.pflags & PF_NIGHTSMODE)
				if (CheckIfCanUseAbility(player) and (not (player.pflags & PF_THOKKED) or player.ability2 == CA2_MULTIABILITY)) 
					if (not(player.homing)) -- Not already homing, leftover from homing version
						DoPlayerJumpThok(player, true);
					end
				end
			end
		end
	player.previouspflags = player.pflags;
	player.powersuper = P_SuperReady(player);
	player.groundcheck = P_IsObjectOnGround(player.mo)
	end
end, MT_PLAYER)