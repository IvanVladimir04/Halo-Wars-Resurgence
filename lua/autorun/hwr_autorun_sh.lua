game.AddParticles( "particles/iv04_halowars_flamers.pcf" )

PrecacheParticleSystem( "flame_halowars_flame" )
PrecacheParticleSystem( "flame_halowars_napalm" )

-- Yes yes there's a literal section of copyright of vrej's here but I'll skip it for now

--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "The public addon name goes here, Example: Dummy SNPCs"
local AddonName = "The addon name goes here, Example: Dummy"
local AddonType = "The addon type(s) Example: SNPC"
local AutorunFile = "autorun/vj_as_autorun.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	local vCat = "Halo Wars Resurgence"
	
	VJ.AddNPC("Flood Root","npc_vj_hw_flood_root",vCat )
	VJ.AddNPC("Flood Bomber Form","npc_vj_hw_flood_bomber",vCat )
	VJ.AddNPC("Flood Swarm Form","npc_vj_hw_flood_swarm",vCat )
	VJ.AddNPC("Flood Infection Form","npc_vj_hw_flood_infection",vCat )
	VJ.AddNPC("Flood Carrier Form","npc_vj_hw_flood_carrier",vCat )
	VJ.AddNPC("Infected Elite","npc_vj_hw_flood_elite",vCat )
	VJ.AddNPC("Thrasher Form","npc_hw1r_rhinodillo",vCat) -- Adds a NPC to the spawnmenu
	VJ.AddNPC("Infected Brute","npc_vj_hw_flood_brute",vCat )
	VJ.AddNPC("Infected Grunt","npc_vj_hw_flood_grunt",vCat )
	--VJ.AddNPC("Infected Jackal","npc_vj_hw_flood_grunt",vCat )
	VJ.AddNPC("Infected Marine","npc_vj_hw_flood_marine",vCat )
	VJ.AddNPC("Infected Flamethrower","npc_vj_hw_flood_flamethrower",vCat )
	
		-- Precache Models
	util.PrecacheModel("models/halowars1/covenant/brute.mdl")
	util.PrecacheModel("models/halowars1/covenant/locust.mdl")
	util.PrecacheModel("models/halowars1/rebel/rebel_infantry.mdl")
	util.PrecacheModel("models/halowars1/unsc/cobra.mdl")
	util.PrecacheModel("models/halowars1/unsc/flamer.mdl")
	util.PrecacheModel("models/halowars1/unsc/hawk.mdl")
	util.PrecacheModel("models/halowars1/unsc/hornet.mdl")
	util.PrecacheModel("models/halowars1/unsc/marine.mdl")
	util.PrecacheModel("models/halowars1/unsc/medic.mdl")
	util.PrecacheModel("models/halowars1/unsc/odst.mdl")
	util.PrecacheModel("models/halowars1/unsc/pelican.mdl")
	util.PrecacheModel("models/halowars1/unsc/spartan.mdl")
	util.PrecacheModel("models/halowars1/unsc/warthog.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/bomber_01/bomber_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/floodtentacle_01/floodtentacle_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectedbrute_01/infectedbrute_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectedcarrier_01/infectedcarrier_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectedelite_01/infectedelite_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectedflame_01/infectedflame_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectedgrunt_01/infectedgrunt_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectedmarine_01/infectedmarine_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/infectionform_01/infectionform_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/rhinodillo_01/rhinodillo_01.mdl")
	util.PrecacheModel("models/hc/halo-wars/flood/swarm_01/swarm_01.mdl")
	
	-- ====== Particles  ====== --
	game.AddParticles("particles/hwr_particles.pcf")
	
end