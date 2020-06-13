AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2020 by DrVrej (VJ Base) and Halo Wars Resurgence developers (Ivan04 and Headcrab), All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/floodtentacle_01/floodtentacle_01.mdl"}
ENT.StartHealth = 300
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

ENT.MeleeAttackDistance = 300

ENT.MeleeAttackDamageDistance = 350

ENT.TimeUntilMeleeAttackDamage = 0

ENT.NextMeleeAttackTime = 4

ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = -100 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = -150

ENT.MeleeAttackKnockBack_Up1 = 100 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 200 

function ENT:CustomOnInitialize()
	--[[
		self.DoFade = GetConVar("imaginary_convar"):GetInt() == 1
	]]
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