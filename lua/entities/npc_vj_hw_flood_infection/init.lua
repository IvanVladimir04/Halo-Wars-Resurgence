AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/infectionform_01/infectionform_01.mdl"} 
ENT.StartHealth = 10
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.HasDeathAnimation = false
ENT.DeathAnimationTime = 2
ENT.AnimTbl_Death = {"Death_01","Death_02","Death_03"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(10, 10, 28), Vector(-10, -10, 0))	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	local randattack = math.random(1,3)

	if randattack == 1 then
		self.MeleeAttackDistance = 15
	    self.MeleeAttackDamageDistance = 35
		self.AnimTbl_MeleeAttack = {"vjseq_Attack_01"}
		self.TimeUntilMeleeAttackDamage = 0.3
		self.NextMeleeAttackTime = 1
		self.MeleeAttackDamage = math.Rand(5,10)
		self.MeleeAttackDamageType = DMG_SLASH	
		
	elseif randattack == 2 then
		self.MeleeAttackDistance = 15
	    self.MeleeAttackDamageDistance = 35
		self.AnimTbl_MeleeAttack = {"vjseq_Attack_02"}
		self.TimeUntilMeleeAttackDamage = 0.5
		self.NextMeleeAttackTime = 1
		self.MeleeAttackDamage = math.Rand(5,10)
		self.MeleeAttackDamageType = DMG_SLASH	
		
	elseif randattack == 3 then
		self.MeleeAttackDistance = 15
	    self.MeleeAttackDamageDistance = 35
		self.AnimTbl_MeleeAttack = {"vjseq_Attack_03"}
		self.TimeUntilMeleeAttackDamage = 0.4
		self.NextMeleeAttackTime = 1
		self.MeleeAttackDamage = math.Rand(5,10)
		self.MeleeAttackDamageType = DMG_SLASH		
end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)
		self:EmitSound(Sound("vj_gib/gibbing2.wav",250))
		self:EmitSound(Sound("vj_gib/gibbing3.wav",250))
        self:EmitSound(Sound("vj_gib/gibbing1.wav",250))
		
        local bloodeffect = EffectData()
		bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(10)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
	    bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
	    bloodspray:SetScale(1)
	    bloodspray:SetFlags(3)
	    bloodspray:SetColor(1)
	    util.Effect("bloodspray",bloodspray)
	    util.Effect("bloodspray",bloodspray)	
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/