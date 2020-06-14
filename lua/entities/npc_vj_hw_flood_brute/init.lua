AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/infectedbrute_01/infectedbrute_01.mdl"} 
ENT.StartHealth = 140 
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.HasDeathAnimation = true
ENT.DeathAnimationTime = 10
ENT.AnimTbl_Death = {"Death_01","Death_02"} 
ENT.HasMeleeAttack = false
ENT.HasRangeAttack = true
ENT.RangeAttackEntityToSpawn = "obj_vj_grenade_rifle"
ENT.DisableDefaultRangeAttackCode = false
ENT.RangeAttackAnimationStopMovement = true 
ENT.RangeDistance = 600 
ENT.RangeToMeleeDistance = 1 
ENT.NoChaseAfterCertainRange = true
ENT.NoChaseAfterCertainRange_FarDistance = 600
ENT.NoChaseAfterCertainRange_CloseDistance = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(22, 22, 92), Vector(-22, -22, 0))	
--self:VJ_ACT_PLAYACTIVITY("vjseq_Birth_01",true,5,true)
end

function ENT:CustomRangeAttackCode_AfterProjectileSpawn(TheProjectile) 
	TheProjectile.RadiusDamage = 30
end
-------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	return (self:GetEnemy():GetPos() - self:LocalToWorld(Vector(100,0,0)))*2 + self:GetUp()*150
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleRangeAttacks()
	local randattack = math.random(1,3)

	if randattack == 1 then
		self.AnimTbl_RangeAttack = {"vjseq_BruteGunAttack_01"}
		self.TimeUntilRangeAttackProjectileRelease = 0.1
		self.NextRangeAttackTime = 2.5
		
	elseif randattack == 2 then
		self.AnimTbl_RangeAttack = {"vjseq_BruteGunAttack_02"}
		self.TimeUntilRangeAttackProjectileRelease = 0.5
		self.NextRangeAttackTime = 2.5
		
	elseif randattack == 3 then
		self.AnimTbl_RangeAttack = {"vjseq_BruteGunAttack_07"}
		self.TimeUntilRangeAttackProjectileRelease = 0.2
		self.NextRangeAttackTime = 2.5		

end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/