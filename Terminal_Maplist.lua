-- Terminal map list
-- Used with the voting script to generate a map list. Feel free to alter for your own uses.
function A_MServ_GetMapList()
	local coopmaplist = {
		[1] = "Greenflower Zone 1",
		[2] = "Greenflower Zone 2",
		[3] = "Greenflower Zone 3",
		[4] = "Techno Hill Zone 1",
		[5] = "Techno Hill Zone 2",
		[6] = "Techno Hill Zone 3",
		[7] = "Deep Sea Zone 1",
		[8] = "Deep Sea Zone 2",
		[9] = "Deep Sea Zone 3",
		[10] = "Castle Eggman Zone 1",
		[11] = "Castle Eggman Zone 2",
		[12] = "Castle Eggman Zone 3",
		[13] = "Arid Canyon Zone 1",
		[16] = "Red Volcano Zone 1",
		[22] = "Egg Rock Zone 1",
		[23] = "Egg Rock Zone 2",
		[24] = "Egg Rock Zone 3",
		[25] = "Egg Rock Core Zone"
	}
	
	local racemaplist = {
		[1] = "Greenflower Zone 1",
		[2] = "Greenflower Zone 2",
		[4] = "Techno Hill Zone 1",
		[5] = "Techno Hill Zone 2",
		[7] = "Deep Sea Zone 1",
		[8] = "Deep Sea Zone 2",
		[10] = "Castle Eggman Zone 1",
		[11] = "Castle Eggman Zone 2",
		[13] = "Arid Canyon Zone 1",
		[16] = "Red Volcano Zone 1",
		[22] = "Egg Rock Zone 1",
		[23] = "Egg Rock Zone 2"
	}
	
	local srb1maplist = {
		[101] = "Knothole Base Zone",
		[103] = "Great Forest Zone",
		[105] = "Lake Zone",
		[107] = "Ice Palace Zone",
		[109] = "Volcano Zone",
		[111] = "Echidnapolis Zone",
		[113] = "Sky Lab Zone",
		[115] = "Mechanical Madness Zone",
		[117] = "Robotopolis[sic] Zone",
		[119] = "Robo Base Zone",
		[123] = "Ringsatellite Zone",
		[127] = "Super Levels",
		[130] = "Hyper Levels"
	}
	
	local matchmaplist = {
		[532] = "Jade Valley Zone",
		[533] = "Noxious Factory Zone",
		[534] = "Tidal Palace Zone",
		[535] = "Thunder Citadel Zone",
		[536] = "Desolate Twilight Zone",
		[537] = "Infernal Cavern Zone",
		[538] = "Orbital Hangar Zone",
		[539] = "Frost Columns Zone",
		[540] = "Granite Lake Zone",
		[541] = "Diamond Blizzard Zone",
		[542] = "Celestial Sanctuary Zone",
		[543] = "Sapphire Falls Zone",
		[544] = "Meadow Match Zone"
	}
	
	local ctfmaplist = {
		[280] = "Lime Forest Zone",
		[281] = "Cloud Palace Zone",
		[282] = "Silver Cascade Zone",
		[283] = "Icicle Falls Zone",
		[284] = "Twisted Terminal Zone",
		[285] = "Clockwork Towers Zone",
		[286] = "Molten Fissure Zone",
		[287] = "Radiant Caverns Zone",
		[288] = "Iron Turret Zone",
		[289] = "Dual Fortress Zone",
		[290] = "Nimbus Ruins Zone"
	}
	
	return {
		["Co-op"] = {GT_COOP, coopmaplist, 1}, -- ["Category Name"] = {gametype, maplist, defaultmap},
		["Competition"] = {GT_COMPETITION, racemaplist, 1},
		["Race"] = {GT_RACE, racemaplist, 1},
		["Secret levels"] = {GT_COOP, {
			[58] = "Spring Hill Zone",
			[30] = "Pipe Towers Zone",
			[40] = "Aerial Garden Zone",
			[41] = "Azure Temple Zone"
		}, 40},
		["SRB1"] = {GT_COOP, srb1maplist, 101},
		["Match"] = {GT_MATCH, matchmaplist, 532},
		["Team Match"] = {GT_TEAMMATCH, matchmaplist, 532},
		--["Tag"] = {GT_TAG, matchmaplist, 532}, -- Tag's scoring system is broke. You can uncomment these if you want, though.
		--["Hide and Seek"] = {GT_HIDEANDSEEK, matchmaplist, 532},
		["Capture the Flag"] = {GT_CTF, ctfmaplist, 280}
	}
end