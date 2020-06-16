AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/infectedflame_01/infectedflame_01.mdl"} 
ENT.StartHealth = 40 
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.HasDeathAnimation = true
ENT.DeathAnimationTime = 10
ENT.AnimTbl_Death = {"Death_01"} 
ENT.HasMeleeAttack = false
ENT.HasRangeAttack = true
ENT.DisableDefaultRangeAttackCode = true
ENT.RangeAttackAnimationStopMovement = true 
ENT.RangeDistance = 250 
ENT.RangeToMeleeDistance = 1 
ENT.NoChaseAfterCertainRange = true
ENT.NoChaseAfterCertainRange_FarDistance = 150
ENT.NoChaseAfterCertainRange_CloseDistance = 1
--custom
ENT.InfectedFlamethrower_Fired = false

ENT.Passive_RunOnDamage = false
ENT.Passive_RunOnTouch = false
ENT.Passive_RunOnDamage = false
ENT.MoveOutOfFriendlyPlayersWay = false
ENT.CallForBackUpOnDamage = false
ENT.RunAwayOnUnknownDamage = false

ENT.FlameRange = 300

ENT.NextRunAwayOnDamageT = math.huge -- Parry this you filthy casual
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(16, 16, 70), Vector(-16, -16, 0))	
self:VJ_ACT_PLAYACTIVITY("vjseq_Birth_01",true,5,true)
end

function ENT:CustomOnDoKilledEnemy(argent,attacker,inflictor) 
	self:StopParticles()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:InfectedFlamethrower_FireEffects()
	--local effect = "flame_halowars_flame"
	--ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )

		--if !IsValid(self.Enemy) then
		--self:StopParticles()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode()
	if !self.Grilling then
		local effect = "flame_halowars_flame"
		ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )
		self.Grilling = true
	end
	self:Burn()
end

function ENT:Burn() -- Straightly recycled from the uninfected n e x t b o t version
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	for k, v in pairs(ents.FindInCone(start,normal,self.FlameRange,math.cos( math.rad( 30 ) ))) do
		if v:Health() > 1 and self:Disposition(v) != D_LI then
			local num = math.random(2,5)
			dm = DamageInfo()
			dm:SetDamage( num/2 )
			dm:SetAttacker(self)
			dm:SetInflictor(self)
			dm:SetDamageType( DMG_BURN )
			v:TakeDamageInfo( dm )
			v:Ignite(num)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleRangeAttacks()
	local randattack = math.random(1,2)

	if randattack == 1 then
		self.AnimTbl_RangeAttack = {"vjseq_Attack_01"}
		self.TimeUntilRangeAttackProjectileRelease = 0.2
		self.RangeAttackExtraTimers = {0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8}
		self.NextRangeAttackTime = 1.5
		
	elseif randattack == 2 then
		self.AnimTbl_RangeAttack = {"vjseq_Attack_02"}
		self.TimeUntilRangeAttackProjectileRelease = 0.2
		self.RangeAttackExtraTimers = {0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8}
		self.NextRangeAttackTime = 1.5	
end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/