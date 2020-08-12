AddCSLuaFile()
ENT.Base 			= "npc_iv04_hw_marine"
ENT.PrintName = "Rebel"
ENT.Models  = {"models/halowars1/rebel/rebel_infantry.mdl"}
ENT.StartHealth = 60
ENT.Faction = "FACTION_REBELS"

function ENT:OnInitialize()
	if !self.Color then
		self:SetColor(Color(74,0,0,255))
	end
end

list.Set( "NPC", "npc_iv04_hw_rebel", {
	Name = "Rebel",
	Class = "npc_iv04_hw_rebel",
	Category = "Halo Wars Resurgence"
} )