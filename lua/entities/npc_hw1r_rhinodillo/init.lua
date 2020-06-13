AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
	-- ====== Base Variables ====== --
ENT.Model = {"models/hc/halo-wars/flood/rhinodillo_01/rhinodillo_01.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 300
ENT.HullType = HULL_LARGE
ENT.HasHull = true 
ENT.HullSizeNormal = true
ENT.HasSetSolid = true 
ENT.SightDistance = 10000
ENT.SightAngle = 60 
ENT.TurningSpeed = 20
ENT.Behavior = VJ_BEHAVIOR_AGGRESSIVE
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.VJ_IsHugeMonster = true
	-- ====== Movement/Animation Variables ====== --
ENT.MovementType = VJ_MOVETYPE_GROUND
	-- ====== Misc Variables ====== --
ENT.InvestigateSoundDistance = 15
ENT.CanOpenDoors = false
ENT.AllowPrintingInChat = false
ENT.PushProps = true
ENT.AttackProps = false
ENT.LastSeenEnemyTimeUntilReset = 30
	-- ====== Ally Interaction Variables ====== --
ENT.BringFriendsOnDeath = false
ENT.CallForBackUpOnDamage = true
ENT.DisableCallForBackUpOnDamageAnimation = true
ENT.CallForBackUpOnDamageDistance = 3000
ENT.CallForBackUpOnDamageLimit = 0
ENT.CallForHelp = true 
ENT.CallForHelpDistance = 3000 
ENT.NextCallForHelpTime = 4
ENT.AnimTbl_CallForHelp = {"Roar_01"}
ENT.CallForHelpStopAnimations = true
ENT.CallForHelpAnimationFaceEnemy = false
	-- ====== Blood/Injured/Immunities/Death Variables ====== --
ENT.HasDeathRagdoll = false
ENT.Immune_Physics = true
ENT.ImmuneDamagesTable = {DMG_POISON}
ENT.HasDeathAnimation = true 
ENT.AnimTbl_Death = {"Death_01"} 
ENT.DeathAnimationTime = 30 
ENT.DeathAnimationChance = 1 
	-- ================ Attack Variables ================ --
--==Melee==--
ENT.HasMeleeAttack = true
ENT.HasMeleeAttackKnockBack = true 
--==Range==--
ENT.HasRangeAttack = false
--==Leap==--
ENT.HasLeapAttack = false
	-- ================ Sounds ================ --
--==Sound Variables==--
ENT.HasSounds = true
--==Sound Paths==--
	-- ================ Custom Functions ================ --
--==Custom Variables==--
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(60, 60, 130), Vector(-60, -60, 0))
	self:CapabilitiesRemove(CAP_MOVE_JUMP)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "rhinodillo_01.Attack" then
		self:MeleeAttackCode()
	end
	if key == "rhinodillo_01.BashEffectLeft" then
		util.ScreenShake(self:GetPos(), 200, 100, 0.80, 300)
		ParticleEffectAttach("npc_hw1r_rhinodillo_footstep", PATTACH_POINT, self,2)
	end
	if key == "rhinodillo_01.BashEffectRight" then
		util.ScreenShake(self:GetPos(), 200, 100, 0.80, 300)
		ParticleEffectAttach("npc_hw1r_rhinodillo_footstep", PATTACH_POINT, self,1)
	end
	if key == "rhinodillo_01.Roar" then
		util.ScreenShake(self:GetPos(), 300, 250, 3, 1000)
		--needs sound--
	end
	if key == "rhinodillo_01.Step" then
		util.ScreenShake(self:GetPos(), 100, 80, 0.40, 400)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()	
		local RandomMeleeAttack = math.random(1,3)	
		if RandomMeleeAttack == 1 then
		self.MeleeAttackDistance = 110
		self.MeleeAttackDamage = 18
		self.MeleeAttackDamageType = DMG_SLASH 
		self.AnimTbl_MeleeAttack = {"BashAttack_01"} 
		self.MeleeAttackAnimationDelay = 0 
		self.MeleeAttackAnimationFaceEnemy = false 
		self.MeleeAttackAngleRadius = 50 
		self.MeleeAttackDamageDistance = 180 
		self.MeleeAttackDamageAngleRadius = 100	
		self.NextMeleeAttackTime = 2
		self.TimeUntilMeleeAttackDamage = false
		self.MeleeAttackKnockBack_Forward1 = 70 
		self.MeleeAttackKnockBack_Forward2 = 70 
		self.MeleeAttackKnockBack_Up1 = 90 
		self.MeleeAttackKnockBack_Up2 = 90
		self.MeleeAttackKnockBack_Right1 = 0 
		self.MeleeAttackKnockBack_Right2 = 0
		
		elseif RandomMeleeAttack == 2 then
		self.MeleeAttackDistance = 100
		self.MeleeAttackDamage = 18
		self.MeleeAttackDamageType = DMG_SLASH 
		self.AnimTbl_MeleeAttack = {"MeleeAttack_01"} 
		self.MeleeAttackAnimationDelay = 0 
		self.MeleeAttackAnimationFaceEnemy = false 
		self.MeleeAttackAngleRadius = 50 
		self.MeleeAttackDamageDistance = 180 
		self.MeleeAttackDamageAngleRadius = 100	
		self.NextMeleeAttackTime = 1
		self.TimeUntilMeleeAttackDamage = false
		self.MeleeAttackKnockBack_Forward1 = 200 
		self.MeleeAttackKnockBack_Forward2 = 200 
		self.MeleeAttackKnockBack_Up1 = 300 
		self.MeleeAttackKnockBack_Up2 = 300
		self.MeleeAttackKnockBack_Right1 = 400 
		self.MeleeAttackKnockBack_Right2 = 400
		
		elseif RandomMeleeAttack == 3 then
		self.MeleeAttackDistance = 100
		self.MeleeAttackDamage = 18
		self.MeleeAttackDamageType = DMG_SLASH 
		self.AnimTbl_MeleeAttack = {"MeleeAttack_02"} 
		self.MeleeAttackAnimationDelay = 0 
		self.MeleeAttackAnimationFaceEnemy = false 
		self.MeleeAttackAngleRadius = 50 
		self.MeleeAttackDamageDistance = 180 
		self.MeleeAttackDamageAngleRadius = 100	
		self.NextMeleeAttackTime = 1
		self.TimeUntilMeleeAttackDamage = false
		self.MeleeAttackKnockBack_Forward1 = 200 
		self.MeleeAttackKnockBack_Forward2 = 200 
		self.MeleeAttackKnockBack_Up1 = 300 
		self.MeleeAttackKnockBack_Up2 = 300
		self.MeleeAttackKnockBack_Right1 = -400 
		self.MeleeAttackKnockBack_Right2 = -400
	end 
end 
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialKilled(dmginfo,hitgroup) 
	if dmginfo:GetDamageType() == DMG_BLAST then 
	self.AnimTbl_Death = {"Clamshell_01"} 
	self.DeathAnimationTime = false
	self:SetLocalVelocity(((self:GetEnemy():GetPos() + self:OBBCenter()) -(self:GetPos() + self:OBBCenter())):GetNormal()*400 +self:GetForward()*-1000 +self:GetUp()*200 + self:GetRight()*0)
	end
end 
---------------------------------------------------------------------------------------------------------------------------------------------
-- All functions and variables are located inside the base files. It can be found in the GitHub Repository: https://github.com/DrVrej/VJ-Base

/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/