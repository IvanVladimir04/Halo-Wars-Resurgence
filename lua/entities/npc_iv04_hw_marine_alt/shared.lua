AddCSLuaFile()
ENT.Base 			= "npc_iv04_hw_marine"
ENT.PrintName = "Marine"
ENT.Models  = {"models/halowars1/unsc/marine.mdl"}
ENT.StartHealth = 60
ENT.Faction = "FACTION_UNSC"

ENT.FriendlyToPlayers = true

function ENT:OnInitialize()
	if !self.Color then
		self:SetColor(Color(155,166,90,255))
	end
	self:SetSkin(0)
end

list.Set( "NPC", "npc_iv04_hw_marine_alt", {
	Name = "Marine (Masked)",
	Class = "npc_iv04_hw_marine_alt",
	Category = "Halo Wars Resurgence"
} )