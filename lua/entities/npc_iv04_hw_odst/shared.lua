AddCSLuaFile()
ENT.Base 			= "npc_iv04_hw_marine"
ENT.PrintName = "ODST"
ENT.Models  = {"models/halowars1/unsc/odst.mdl"}
ENT.StartHealth = 75

function ENT:FireAt()
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	local bullet = {}
	bullet.Num = 10
	bullet.Src = start
	bullet.Dir = self:GetAimVector()
	bullet.Spread =  Vector( 0.25, 0.25 )
	bullet.Tracer = 1
	bullet.Force = 1
	--bullet.TracerName = self.TracerName
	bullet.Damage = 4
	bullet.Callback = function(attacker, tr, info) -- Small function to set it as we are who caused the damage

	end
	self:FireBullets(bullet)
end

list.Set( "NPC", "npc_iv04_hw_odst", {
	Name = "ODST",
	Class = "npc_iv04_hw_odst",
	Category = "Halo Wars Resurgence"
} )