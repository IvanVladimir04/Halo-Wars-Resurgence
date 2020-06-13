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
	VJ.AddNPC("Infected Elite","npc_vj_hw_flood_elite",vCat )
	VJ.AddNPC("Flood Bomber Form","npc_vj_hw_flood_bomber",vCat )
	VJ.AddNPC("Flood Infection Form","npc_vj_hw_flood_infection",vCat )
	
end