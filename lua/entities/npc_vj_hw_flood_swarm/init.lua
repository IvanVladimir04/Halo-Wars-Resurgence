AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/swarm_01/swarm_01.mdl"} 
ENT.StartHealth = 50 
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.MovementType = VJ_MOVETYPE_AERIAL 
ENT.Aerial_AnimTbl_Calm = {"Fly_01_NoPath","Fly_02_NoPath"} 
ENT.Aerial_AnimTbl_Alerted = {"Fly_01_NoPath","Fly_02_NoPath"}
ENT.HasDeathAnimation = true
ENT.DeathAnimationTime = 1
ENT.AnimTbl_Death = {"Death_01"} 
ENT.HasMeleeAttack = false
ENT.HasRangeAttack = true
ENT.RangeAttackEntityToSpawn = "obj_vj_hw_flood_swarm_spit"
ENT.NoChaseAfterCertainRange = true
ENT.NoChaseAfterCertainRange_FarDistance = 1000 
ENT.NoChaseAfterCertainRange_CloseDistance = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(20, 25, 80), Vector(-20, -25, 0))	
end
-------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	return (self:GetEnemy():GetPos() - self:LocalToWorld(Vector(100,0,0)))*2 + self:GetUp()*250
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleRangeAttacks()
	local randattack = math.random(1,1)

	if randattack == 1 then
		self.AnimTbl_RangeAttack = {"vjseq_Attack_01"}
		self.TimeUntilRangeAttackProjectileRelease = 0.4
		self.NextRangeAttackTime = 1.5	
end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/