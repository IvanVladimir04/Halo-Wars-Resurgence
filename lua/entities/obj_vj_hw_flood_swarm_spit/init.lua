AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/spitball_small.mdl"} 
ENT.DecalTbl_DeathDecals = {"VJ_Blood_Yellow"}
ENT.SoundTbl_Idle = {"physics/flesh/flesh_bloody_impact_hard1.wav"}
ENT.SoundTbl_OnCollide = {"physics/flesh/flesh_squishy_impact_hard3.wav","physics/flesh/flesh_squishy_impact_hard1.wav","physics/flesh/flesh_squishy_impact_hard2.wav","physics/flesh/flesh_squishy_impact_hard4.wav"}
ENT.DoesDirectDamage = true
ENT.DirectDamage = 8
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomPhysicsObjectOnInitialize(phys)
	phys:Wake()
	//phys:SetMass(1)
	phys:SetBuoyancyRatio(0)
	phys:EnableDrag(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	ParticleEffectAttach("vj_impact1_yellow", PATTACH_ABSORIGIN_FOLLOW, self, 0) 
	ParticleEffectAttach("vj_impact1_yellow", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	local dir = self:GetAngles():Forward()
	timer.Simple( 0.3, function()
		if IsValid(self) then
			if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetEnemy()) then
				dir = (self:GetOwner():GetEnemy():WorldSpaceCenter()-self:WorldSpaceCenter()):GetNormalized()
			end
			local bullet = {}
			bullet.Damage = self.DirectDamage
			bullet.Attacker = self:GetOwner()
			bullet.Src = self:GetPos()
			bullet.IgnoreEntity = self:GetOwner()
			bullet.Dir = dir
			--bullet.Tracer = "vj_impact1_yellow"
			self:FireBullets(bullet)
			self:Remove()
		end
	end )
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	ParticleEffectAttach("vj_impact1_yellow", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	ParticleEffectAttach("vj_impact1_yellow", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data,phys)
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	effectdata:SetScale(1)
	util.Effect("StriderBlood",effectdata)
	util.Effect("StriderBlood",effectdata)
	util.Effect("StriderBlood",effectdata)
	ParticleEffect("vj_impact1_yellow", data.HitPos, Angle(0,0,0), nil)
end


/*-----------------------------------------------
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/