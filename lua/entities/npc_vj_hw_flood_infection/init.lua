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

ENT.IsHWInfector = true -- Tag so marines know they were infected
ENT.IsHWPopcorn = true -- Tag so marines know they were stunned
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
	self:SetCollisionBounds(Vector(10, 10, 28), Vector(-10, -10, 0))
	local r = math.random(1,2)
	if r == 2 then r = 0 end
	self:SetSkin(r)
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

function ENT:MeleeAttackCode(IsPropAttack,AttackDist,CustomEnt)
	if self.Dead == true or self.vACT_StopAttacks == true or self.Flinching == true then return end
	if self.StopMeleeAttackAfterFirstHit == true && self.AlreadyDoneMeleeAttackFirstHit == true then return end
	local IsPropAttack = IsPropAttack or false
	if self.MeleeAttack_DoingPropAttack == true then IsPropAttack = true end
	local MyEnemy = CustomEnt or self:GetEnemy()
	local AttackDist = AttackDist or self.MeleeAttackDamageDistance
	//if IsPropAttack == true then AttackDist = (self.MeleeAttackDamageDistance *1.2)/* + 50*/ end
	if /*self.VJ_IsBeingControlled == false &&*/ self.MeleeAttackAnimationFaceEnemy == true && self.MeleeAttack_DoingPropAttack == false then self:FaceCertainEntity(MyEnemy,true) end
	//self.MeleeAttacking = true
	self:CustomOnMeleeAttack_BeforeChecks()
	if self.DisableDefaultMeleeAttackCode == true then return end
	local FindEnts = ents.FindInSphere(self:SetMeleeAttackDamagePosition(), AttackDist)
	local hitentity = false
	local HasHitGoodProp = false
	if FindEnts != nil then
		for _,v in pairs(FindEnts) do
			if (self.VJ_IsBeingControlled == true && self.VJ_TheControllerBullseye == v) or (v:IsPlayer() && v.IsControlingNPC == true) then continue end
			if (v != self && v:GetClass() != self:GetClass()) && (((v:IsNPC() or (v:IsPlayer() && v:Alive() && GetConVarNumber("ai_ignoreplayers") == 0)) && (self:Disposition(v) != D_LI)) or VJ_IsProp(v) == true or v:GetClass() == "func_breakable_surf" or self.EntitiesToDestroyClass[v:GetClass()] or v.VJ_AddEntityToSNPCAttackList == true) then
				if (self:GetForward():Dot((Vector(v:GetPos().x,v:GetPos().y,0) - Vector(self:GetPos().x,self:GetPos().y,0)):GetNormalized()) > math.cos(math.rad(self.MeleeAttackDamageAngleRadius))) then
					//if IsPropAttack == true && self:GetPos():Distance(v:GetPos()) <= AttackDist /2 && v:GetClass() != "prop_physics" && v:GetClass() != "func_breakable_surf" && v:GetClass() != "func_breakable" then continue end
					if IsPropAttack == true && (v:IsPlayer() or v:IsNPC()) then
						//print(self:GetPos():Distance(v:GetPos()))
						//print(self.MeleeAttackDistance)
						//print(self:GetPos():Distance(v:GetPos()) >= self:VJ_GetNearestPointToEntityDistance(v))
						//print(self:VJ_GetNearestPointToEntityDistance(v) <= self.MeleeAttackDistance)
						//if (self:GetPos():Distance(v:GetPos()) <= self:VJ_GetNearestPointToEntityDistance(v) && self:VJ_GetNearestPointToEntityDistance(v) <= self.MeleeAttackDistance) == false then
						if self:VJ_GetNearestPointToEntityDistance(v) > self.MeleeAttackDistance then continue end
					end
					if VJ_IsProp(v) == true then
						local phys = v:GetPhysicsObject()
						if phys:IsValid() && phys != nil && phys != NULL then
							//if VJ_HasValue(self.EntitiesToDestoryModel,v:GetModel()) or self.EntitiesToDestroyClass[v:GetClass()] or VJ_HasValue(self.EntitiesToPushModel,v:GetModel()) then
							if self:PushOrAttackPropsCode({IsSingleValue=v,CustomMeleeDistance=AttackDist}) then
								HasHitGoodProp = true
								phys:EnableMotion(true)
								//phys:EnableGravity(true)
								phys:Wake()
								//constraint.RemoveAll(v)
								//if util.IsValidPhysicsObject(v,1) then
								constraint.RemoveConstraints(v,"Weld") //end
								if self.PushProps == true then
									local phys = v:GetPhysicsObject()
									if MyEnemy != nil then
										local posfor = phys:GetMass() * 700
										local posup = phys:GetMass() * 200
										phys:ApplyForceCenter(MyEnemy:GetPos()+self:GetForward() *posfor +self:GetUp()*posup)
										//phys:ApplyForceCenter(MyEnemy:GetPos()+self:GetForward() *25000 +self:GetUp()*7000)
										/*if v:GetModel() == "models/props_c17/oildrum001.mdl" then
										phys:ApplyForceCenter(MyEnemy:GetPos()+self:GetForward() *25000 +self:GetUp()*7000) end
										if v:GetModel() == "models/props_borealis/bluebarrel001.mdl" then
										phys:ApplyForceCenter(MyEnemy:GetPos()+self:GetForward() *55000 +self:GetUp()*10000) end*/
									end
								end
							end
						end
					end
					if self:CustomOnMeleeAttack_AfterChecks(v) == true then continue end
					if self.HasMeleeAttackKnockBack == true && v.MovementType != VJ_MOVETYPE_STATIONARY then
						if v.VJ_IsHugeMonster != true or v.IsVJBaseSNPC_Tank == true then
							v:SetGroundEntity(NULL)
							v:SetVelocity(self:GetForward()*math.random(self.MeleeAttackKnockBack_Forward1,self.MeleeAttackKnockBack_Forward2) +self:GetUp()*math.random(self.MeleeAttackKnockBack_Up1,self.MeleeAttackKnockBack_Up2) +self:GetRight()*math.random(self.MeleeAttackKnockBack_Right1,self.MeleeAttackKnockBack_Right2))
						end
					end
					if self.DisableDefaultMeleeAttackDamageCode == false then
						local doactualdmg = DamageInfo()
						doactualdmg:SetDamage(self:VJ_GetDifficultyValue(self.MeleeAttackDamage))
						doactualdmg:SetDamageType(self.MeleeAttackDamageType)
						//doactualdmg:SetDamagePosition(self:VJ_GetNearestPointToEntity(v).MyPosition)
						if v:IsNPC() or v:IsPlayer() then doactualdmg:SetDamageForce(self:GetForward()*((doactualdmg:GetDamage()+100)*70)) end
						doactualdmg:SetInflictor(self)
						doactualdmg:SetAttacker(self)
						v:TakeDamageInfo(doactualdmg, self)
					end
					if self.MeleeAttackSetEnemyOnFire == true then v:Ignite(self.MeleeAttackSetEnemyOnFireTime,0) end
					if (v:IsNPC() && (!VJ_IsHugeMonster)) or v:IsPlayer() then
						if self.MeleeAttackBleedEnemy == true then
							self:CustomOnMeleeAttack_BleedEnemy(v)
							if math.random(1,self.MeleeAttackBleedEnemyChance) == 1 then
								timer.Create("timer_melee_bleedply",self.MeleeAttackBleedEnemyTime,self.MeleeAttackBleedEnemyReps,function() if IsValid(v) then v:TakeDamage(self.MeleeAttackBleedEnemyDamage,self,self) end end)
							end
							if !v:IsValid() then timer.Remove("timer_melee_bleedply") end
							if v:IsPlayer() then if !v:Alive() then timer.Remove("timer_melee_bleedply") end end
						end
					end
					if v:IsPlayer() then
						if self.HasMeleeAttackDSPSound == true && ((self.MeleeAttackDSPSoundUseDamage == false) or (self.MeleeAttackDSPSoundUseDamage == true && self.MeleeAttackDamage >= self.MeleeAttackDSPSoundUseDamageAmount && GetConVarNumber("vj_npc_nomeleedmgdsp") == 0)) then
							v:SetDSP(self.MeleeAttackDSPSoundType,false)
						end
						v:ViewPunch(Angle(math.random(-1,1)*self.MeleeAttackDamage,math.random(-1,1)*self.MeleeAttackDamage,math.random(-1,1)*self.MeleeAttackDamage))
						if self.SlowPlayerOnMeleeAttack == true then
							self:VJ_DoSlowPlayer(v,self.SlowPlayerOnMeleeAttack_WalkSpeed,self.SlowPlayerOnMeleeAttack_RunSpeed,self.SlowPlayerOnMeleeAttackTime,{PlaySound=self.HasMeleeAttackSlowPlayerSound,SoundTable=self.SoundTbl_MeleeAttackSlowPlayer,SoundLevel=self.MeleeAttackSlowPlayerSoundLevel,FadeOutTime=self.MeleeAttackSlowPlayerSoundFadeOutTime},{})
							self:CustomOnMeleeAttack_SlowPlayer(v)
						end
					end
					VJ_DestroyCombineTurret(self,v)
					if VJ_IsProp(v) == true then
						if HasHitGoodProp == true then
							hitentity = true
						end
					else
						hitentity = true
						break
					end
				end
			end
		end
	end
	if hitentity == true then
		self:MeleeAttackSoundCode()
		if self.StopMeleeAttackAfterFirstHit == true then self.AlreadyDoneMeleeAttackFirstHit = true /*self:StopMoving()*/ end
	else
		self:CustomOnMeleeAttack_Miss()
		if self.MeleeAttackWorldShakeOnMiss == true then util.ScreenShake(self:GetPos(),self.MeleeAttackWorldShakeOnMissAmplitude,self.MeleeAttackWorldShakeOnMissFrequency,self.MeleeAttackWorldShakeOnMissDuration,self.MeleeAttackWorldShakeOnMissRadius) end
		self:MeleeAttackMissSoundCode()
	end
	//if self.VJ_IsBeingControlled == false && self.MeleeAttackAnimationFaceEnemy == true then self:FaceCertainEntity(MyEnemy,true) end
	if self.AlreadyDoneFirstMeleeAttack == false && self.TimeUntilMeleeAttackDamage != false then
		self:MeleeAttackCode_DoFinishTimers()
	end
	self.AlreadyDoneFirstMeleeAttack = true
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/