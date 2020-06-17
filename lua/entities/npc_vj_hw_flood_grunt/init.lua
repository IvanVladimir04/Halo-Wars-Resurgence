AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/infectedgrunt_01/infectedgrunt_01.mdl"} 
ENT.StartHealth = 30 
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.HasDeathAnimation = true
ENT.DeathAnimationTime = 10
ENT.AnimTbl_Death = {"Death_01","Death_02"} 
ENT.HasMeleeAttack = false
ENT.HasRangeAttack = true
--ENT.RangeAttackEntityToSpawn = "obj_vj_blasterrod"
ENT.DisableDefaultRangeAttackCode = true
ENT.RangeAttackAnimationStopMovement = true 
ENT.RangeDistance = 600 
ENT.RangeToMeleeDistance = 1 
ENT.NoChaseAfterCertainRange = true
ENT.NoChaseAfterCertainRange_FarDistance = 600
ENT.NoChaseAfterCertainRange_CloseDistance = 1
--custom
ENT.InfectedGrunt_Fired = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(18, 18, 65), Vector(-18, -18, 0))	
self:VJ_ACT_PLAYACTIVITY("vjseq_Birth_01",true,5,true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:InfectedGrunt_ShootEffects()
	local flash = ents.Create("env_muzzleflash")
	--flash:SetPos(self:GetAttachment(self:LookupAttachment(1)).Pos)
	flash:SetKeyValue("scale","1")
	flash:SetKeyValue("angles",tostring(self:GetForward():Angle()))
	flash:Fire("Fire",0,0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode()
	local bullet = {}
		bullet.Num = 1
		bullet.Src = self:GetPos()+self:OBBCenter() //self:GetAttachment(self:LookupAttachment(1)).Pos
		bullet.Dir = (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()+self:GetEnemy():GetUp()*-45) -self:GetPos()
		bullet.Spread = 2.5
		bullet.Tracer = 1
		bullet.TracerName = "AR2Tracer"
		bullet.Force = 5
		bullet.Damage = math.Rand(6,8)
		bullet.AmmoType = "AR2"
	self:FireBullets(bullet)
	self.InfectedGrunt_Fired = true
	self:InfectedGrunt_ShootEffects()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleRangeAttacks()
	local randattack = math.random(1,3)

	if randattack == 1 then
		self.AnimTbl_RangeAttack = {"vjseq_Attack_01"}
		self.TimeUntilRangeAttackProjectileRelease = 0.5
		self.RangeAttackExtraTimers = {0.7,0.9}
		self.NextRangeAttackTime = 1.8
		
	elseif randattack == 2 then
		self.AnimTbl_RangeAttack = {"vjseq_Attack_02"}
		self.TimeUntilRangeAttackProjectileRelease = 1.0
		self.RangeAttackExtraTimers = {1.3}
		self.NextRangeAttackTime = 1.8
		
	elseif randattack == 3 then
		self.AnimTbl_RangeAttack = {"vjseq_Attack_03"}
		self.TimeUntilRangeAttackProjectileRelease = 1.0
		self.RangeAttackExtraTimers = {}
		self.NextRangeAttackTime = 1.8	
end
end

/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/