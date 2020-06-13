AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/infectedelite_01/infectedelite_01.mdl"} 
ENT.StartHealth = 120 
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.HasDeathAnimation = true
ENT.DeathAnimationTime = 10
ENT.AnimTbl_Death = {"Death_01"} 
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(21, 21, 82), Vector(-21, -21, 0))	
self:VJ_ACT_PLAYACTIVITY("vjseq_Birth_01",true,4,true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	local randattack = math.random(1,3)

	if randattack == 1 then
		self.MeleeAttackDistance = 60
	    self.MeleeAttackDamageDistance = 100
		self.AnimTbl_MeleeAttack = {"vjseq_Attack_01"}
		self.TimeUntilMeleeAttackDamage = 0.6
		self.NextMeleeAttackTime = 1
		self.MeleeAttackDamage = math.Rand(15,20)
		self.MeleeAttackDamageType = DMG_SLASH	
		
	elseif randattack == 2 then
		self.MeleeAttackDistance = 60
	    self.MeleeAttackDamageDistance = 100
		self.AnimTbl_MeleeAttack = {"vjseq_Attack_02"}
		self.TimeUntilMeleeAttackDamage = 0.7
		self.NextMeleeAttackTime = 1
		self.MeleeAttackDamage = math.Rand(15,20)
		self.MeleeAttackDamageType = DMG_SLASH	
		
	elseif randattack == 3 then
		self.MeleeAttackDistance = 60
	    self.MeleeAttackDamageDistance = 100
		self.AnimTbl_MeleeAttack = {"vjseq_Attack_03"}
		self.TimeUntilMeleeAttackDamage = 0.5
		self.NextMeleeAttackTime = 1
		self.MeleeAttackDamage = math.Rand(15,20)
		self.MeleeAttackDamageType = DMG_SLASH		
end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/