AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2020 by DrVrej (VJ Base) and Halo Wars Resurgence developers (Ivan04 and Headcrab), All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/floodtentacle_01/floodtentacle_01.mdl"}
ENT.StartHealth = 500
ENT.VJ_IsHugeMonster = true
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.CanTurnWhileStationary = true
ENT.SightDistance = 512
ENT.SightAngle = 180

ENT.CallForHelp = false

ENT.ConstantlyFaceEnemy_IfVisible = false

ENT.HasPoseParameterLooking = false

ENT.BloodColor = "Yellow"

ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}

ENT.HasDeathRagdoll = false

/*-----------------------------------------------
	*** Copyright (c) 2012-2020 by DrVrej (VJ Base) and Halo Wars Resurgence developers (Ivan04 and Headcrab), All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

ENT.DoFade = true

ENT.MeleeAttackDamage = 40

ENT.IsFloodBuilding = true

ENT.MeleeAttackDistance = 300

ENT.MeleeAttackDamageDistance = 350

ENT.TimeUntilMeleeAttackDamage = 0

ENT.NextMeleeAttackTime = 4

ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = -100 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = -150

ENT.MeleeAttackKnockBack_Up1 = 100 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 200 

ENT.StopMeleeAttackAfterFirstHit = true

function ENT:CustomOnInitialize()
	self.DoFade = GetConVar("hwr_flood_buildings_regrow"):GetInt() == 0
	self:SetCollisionBounds(Vector(-50,-50,0),Vector(50,50,170))
	local root = ents.Create("prop_dynamic")
	root:SetOwner(self)
	root:SetParent(self)
	root:SetModel(self:GetModel())
	root:SetAngles(self:GetAngles())
	root:SetPos(self:GetPos())
	root:Spawn()
	local id, len = root:LookupSequence("Emerge_01")
	self:DeleteOnRemove(root)
	root:ResetSequenceInfo()
	root:SetSequence(id)
	self:SetNoDraw(true)
	timer.Simple( len, function()
		if IsValid(self) and IsValid(root) then
			self:SetNoDraw(false)
			self:SetCycle(root:GetCycle())
			root:Remove()
		end
	end )
	if !self.WasSpawned then
		local goal = self:GetPos()
		local navs = navmesh.Find( goal, 1024, 100, 20 )
		local tbl = navs
		for i = 1, #tbl do
			local nv = tbl[i]
			local x = nv:GetSizeX()
			local y = nv:GetSizeY()
			if ( !UsedNavs[nv:GetID()] or !IsValid(UsedNavs[nv:GetID()]) ) and x > 200 and y > 200 then
				UsedNavs[nv:GetID()] = self
				self.UsedNav = nv:GetID()
				break
			end
		end
	end
	--local id, len = self:LookupSequence("Emerge_01")
	--local act = self:GetSequenceActivity(id)
	--self:VJ_ACT_PLAYACTIVITY(act,true,len,false,0)
end

function ENT:GetEnemyType()
	local ent = self:GetEnemy()
	if ent.IsVJBaseSNPC_Tank or ent.HWVehicle then
		return "Vehicle"
	else
		return "Infantry"
	end
end

function ENT:MultipleMeleeAttacks() 
	local tip = self:GetEnemyType()
	if tip == "Vehicle" then
		self.AnimTbl_MeleeAttack = {self:GetSequenceActivity(self:LookupSequence("VehicleAttack_0"..math.random(1,4)..""))}
	else
		local r = math.random(1,3)
		if r == 1 then 
			self.TimeUntilMeleeAttackDamage = 2
			self.MeleeAttackAnimationDecreaseLengthAmount = 0
		elseif r == 2 then
			self.TimeUntilMeleeAttackDamage = 0.8
			self.MeleeAttackAnimationDecreaseLengthAmount = 0
		elseif r == 3 then
			self.TimeUntilMeleeAttackDamage = 1.2
			self.MeleeAttackAnimationDecreaseLengthAmount = 0
		end
		self.AnimTbl_MeleeAttack = {self:GetSequenceActivity(self:LookupSequence("InfantryAttack_0"..r..""))}
	end
end


---------------------- Code hell begins ----------------------------

function ENT:OnKilled(dmginfo,hitgroup)
	if self.VJDEBUG_SNPC_ENABLED == true then if GetConVarNumber("vj_npc_printdied") == 1 then print(self:GetClass().." Died!") end end
	self:CustomOnKilled(dmginfo,hitgroup)
	if math.random(1,self.ItemDropsOnDeathChance) == 1 then self:RunItemDropsOnDeathCode(dmginfo,hitgroup) end -- Item drops on death
	if self.HasDeathNotice == true then PrintMessage(self.DeathNoticePosition, self.DeathNoticeWriting) end -- Death notice on death
	self:ClearEnemyMemory()
	self:ClearSchedule()
	//self:SetNPCState(NPC_STATE_DEAD)
	self:CreateDeathCorpse(dmginfo,hitgroup,self.DoFade)
	self:Remove()
end

function ENT:CreateDeathCorpse(dmginfo,hitgroup,comeback)
	self:CustomOnDeath_BeforeCorpseSpawned(dmginfo,hitgroup)
	--if self.HasDeathRagdoll == true then
		local corpsemodel = self:GetModel()
		local corpsemodel_custom = VJ_PICK(self.DeathCorpseModel)
		if corpsemodel_custom != false then corpsemodel = corpsemodel_custom end
		self.Corpse = ents.Create("prop_dynamic")
		self.Corpse:SetModel(corpsemodel)
		self.Corpse:SetPos(self:GetPos())
		self.Corpse:SetAngles(self:GetAngles())
		self.Corpse:Spawn()
		self.Corpse:Activate()
		self.Corpse:SetColor(self:GetColor())
		self.Corpse:SetMaterial(self:GetMaterial())
		self.Corpse:ResetSequenceInfo()
		local id, len = self.Corpse:LookupSequence("Death_01")
		self.Corpse:SetSequence(id)
		timer.Simple( len-0.01, function()
			if IsValid(self.Corpse) then
				self.Corpse:SetPlaybackRate(0)
			end
		end )
		undo.ReplaceEntity(self,self.Corpse)
		--[[local fadetype = "kill"
		if self.Corpse:GetClass() == "prop_ragdoll" then fadetype = "FadeAndRemove" end
		self.Corpse.FadeCorpseType = fadetype
		self.Corpse.IsVJBaseCorpse = true
		self.Corpse.DamageInfo = dmginfo
		self.Corpse.ExtraCorpsesToRemove = self.ExtraCorpsesToRemove_Transition

		if self.Bleeds == true && self.HasBloodPool == true && GetConVarNumber("vj_npc_nobloodpool") == 0 then
			self:SpawnBloodPool(dmginfo,hitgroup)
		end]]
		local en = self.Corpse
		self.Corpse.UsedNav = self.UsedNav
		UsedNavs[self.Corpse.UsedNav] = nav
		if !comeback then
			local tim = math.random(120,180)
			timer.Simple( tim, function()
				if IsValid(en) then
					local imbackbitch = ents.Create("npc_vj_hw_flood_root")
					imbackbitch:SetPos(en:GetPos())
					imbackbitch:SetModel(en:GetModel())
					imbackbitch:SetAngles(en:GetAngles())
					imbackbitch:Spawn()
					undo.ReplaceEntity(en,imbackbitch)
					en:Remove()
				end
			end )
		else
			self.Corpse.FadeCorpseType = fadetype
			self.FadeCorpse = true
			self.Corpse.FadeCorpseTime = math.random(20,30)
		end

		cleanup.ReplaceEntity(self,self.Corpse) -- Delete on cleanup
		if GetConVarNumber("vj_npc_undocorpse") == 1 then undo.ReplaceEntity(self,self.Corpse) end -- Undoable
		if self.SetCorpseOnFire == true then self.Corpse:Ignite(math.Rand(8,10),0) end -- Set it on fire when it dies
		if self:IsOnFire() then  -- If was on fire then...
			self.Corpse:Ignite(math.Rand(8,10),0)
			self.Corpse:SetColor(Color(90,90,90))
			//self.Corpse:SetMaterial("models/props_foliage/tree_deciduous_01a_trunk")
		end
		//gamemode.Call("CreateEntityRagdoll",self,self.Corpse)
		
		if self.FadeCorpse == true then self.Corpse:Fire(self.Corpse.FadeCorpseType,"",self.FadeCorpseTime) end
		if GetConVarNumber("vj_npc_corpsefade") == 1 then self.Corpse:Fire(self.Corpse.FadeCorpseType,"",GetConVarNumber("vj_npc_corpsefadetime")) end
		self:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,self.Corpse)
		return self.Corpse
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
		--self:MeleeAttackSoundCode()
		if self.StopMeleeAttackAfterFirstHit == true then self.AlreadyDoneMeleeAttackFirstHit = true /*self:StopMoving()*/ end
	else
		self:CustomOnMeleeAttack_Miss()
		if self.MeleeAttackWorldShakeOnMiss == true then util.ScreenShake(self:GetPos(),self.MeleeAttackWorldShakeOnMissAmplitude,self.MeleeAttackWorldShakeOnMissFrequency,self.MeleeAttackWorldShakeOnMissDuration,self.MeleeAttackWorldShakeOnMissRadius) end
		--self:MeleeAttackMissSoundCode()
	end
	//if self.VJ_IsBeingControlled == false && self.MeleeAttackAnimationFaceEnemy == true then self:FaceCertainEntity(MyEnemy,true) end
	if self.AlreadyDoneFirstMeleeAttack == false && self.TimeUntilMeleeAttackDamage != false then
		self:MeleeAttackCode_DoFinishTimers()
	end
	self.AlreadyDoneFirstMeleeAttack = true
end