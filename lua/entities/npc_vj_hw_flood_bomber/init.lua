AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/bomber_01/bomber_01.mdl"}
ENT.StartHealth = 200 
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.HasMeleeAttck = false
ENT.NoChaseAfterCertainRange = false
ENT.NoChaseAfterCertainRange_FarDistance = 1000 
ENT.NoChaseAfterCertainRange_CloseDistance = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
  self:SetCollisionBounds(Vector(60, 60, 150), Vector(-60, -60, 0))
  self.NextEggDrop = CurTime()+10
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
if self.NextEggDrop < CurTime() then
   self.NextEggDrop = CurTime()+20
   self:VJ_ACT_PLAYACTIVITY("vjseq_BombAttack_01",true,2,true)
   VJ_EmitSound(self,{"physics/flesh/flesh_bloody_impact_hard1.wav"},60,math.random(100,100))
   self:DropTheFlood()
end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DropTheFlood()
  local egg = ents.Create("prop_physics")
  egg:SetModel("models/xqm/rails/gumball_1.mdl")
  egg:SetColor(Color(193,163,82,255))
  egg:SetPos(self:GetPos())
  egg:SetOwner(self)
  egg:SetAngles(self:GetAngles())
  egg:AddCallback( "PhysicsCollide", function( ent, data )
	if IsValid(self) then
		VJ_EmitSound(self,{"physics/flesh/flesh_bloody_break.wav"},60,math.random(100,100))
	end
	egg:Remove()
    -- When life gives you eggs, make sure they aren't flood
  for i = 1, 6 do
    local ent = ents.Create("npc_iv04_hw_flood_infection")
    local pos = egg:GetPos()
	local e = i
	 if i > 3 then pos = pos+egg:GetForward()*(40) e = e-3 end
    pos = pos+egg:GetRight()*(40*e)
    ent:SetPos(pos)
    ent:SetAngles(Angle(0,egg:GetAngles().y,0))
    ent:Spawn()
timer.Simple(math.random(120,180),function()

  if IsValid(ent) then ent:TakeDamage(ent:Health(),ent,ent) 
end
end)	
end
end)
    egg:Spawn()
  local prop = egg:GetPhysicsObject()
  if IsValid(prop) then prop:Wake() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)
		self:EmitSound(Sound("vj_gib/gibbing2.wav",250))
		self:EmitSound(Sound("vj_gib/gibbing3.wav",250))
        self:EmitSound(Sound("vj_gib/gibbing1.wav",250))
		
        local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos()+ self:GetUp()*80)
		bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(250)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
	    bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
	    bloodspray:SetScale(1)
	    bloodspray:SetFlags(3)
	    bloodspray:SetColor(1)
	    util.Effect("bloodspray",bloodspray)
	    util.Effect("bloodspray",bloodspray)		
end

function ENT:AAMove_ChaseEnemy(ShouldPlayAnim,UseCalmVariables)
	if self.Dead == true or (self.NextChaseTime > CurTime()) or !IsValid(self:GetEnemy()) then return end
	local ShouldPlayAnim = ShouldPlayAnim or false
	local UseCalmVariables = UseCalmVariables or false
	local Debug = self.AA_EnableDebug
	local MoveSpeed = self.Aerial_FlyingSpeed_Alerted
	if self.MovementType == VJ_MOVETYPE_AQUATIC then
		if Debug == true then
			print("--------")
			print("ME WL: "..self:WaterLevel())
			print("ENEMY WL: "..self:GetEnemy():WaterLevel())
		end
		-- Yete chouri e YEV leman marmine chourin mech-e che, ere vor gena yev kharen kal e
		if self:WaterLevel() <= 2 && self:GetVelocity():Length() > 0 then return end
		if self:WaterLevel() <= 1 && self:GetVelocity():Length() > 0 then self:AAMove_Wander(true,true) return end
		if self:GetEnemy():WaterLevel() == 0 then self:DoIdleAnimation(1) return end -- Yete teshnamin chouren tours e, getsour
		if self:GetEnemy():WaterLevel() <= 1 then -- Yete 0-en ver e, ere vor nayi yete gerna teshanmi-in gerna hasnil
			local trene = util.TraceLine({
				start = self:GetEnemy():GetPos() + self:OBBCenter(),
				endpos = (self:GetEnemy():GetPos() + self:OBBCenter()) + self:GetEnemy():GetUp()*-20,
				filter = self,
				mins = self:OBBMins(),
				maxs = self:OBBMaxs()
			})
			//PrintTable(trene)
			//VJ_CreateTestObject(trene.HitPos,self:GetAngles(),Color(0,255,0),5)
			if trene.Hit == true then return end
		end
		MoveSpeed = self.Aquatic_SwimmingSpeed_Alerted
	end
	
	if UseCalmVariables == true then
		if self.MovementType == VJ_MOVETYPE_AQUATIC then
			MoveSpeed = self.Aquatic_SwimmingSpeed_Calm
		else
			MoveSpeed = self.Aerial_FlyingSpeed_Calm
		end
	end
	self:FaceCertainEntity(self:GetEnemy(),true)

	if ShouldPlayAnim == true && self.NextChaseTime < CurTime() then
		self.AA_CanPlayMoveAnimation = true
		if UseCalmVariables == true then
			self.AA_CurrentMoveAnimationType = "Calm"
		else
			self.AA_CurrentMoveAnimationType = "Alert"
		end
	else
		self.AA_CanPlayMoveAnimation = false
	end

	-- Main Calculations
	local vel_for = 1
	local vel_stop = false
	local nearpos = self:VJ_GetNearestPointToEntity(self:GetEnemy())
	local startpos = nearpos.MyPosition // self:GetPos()
	local endpos = nearpos.EnemyPosition // self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()
	local tr = util.TraceHull({
		start = startpos,
		endpos = endpos,
		filter = self,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})
	local tr_hitpos = tr.HitPos
	local dist_selfhit = startpos:Distance(tr_hitpos)
	if Debug == true then util.ParticleTracerEx("Weapon_Combine_Ion_Cannon_Beam",tr.StartPos,tr_hitpos,false,self:EntIndex(),0) end //vortigaunt_beam
	if dist_selfhit <= 16 && tr.HitWorld == true then
		if Debug == true then print("AA: Forward Blocked! [CHASE]") end
		vel_for = 1
		//vel_for = -200
		//vel_stop = true
	end
	local pos1 = Vector(self:GetEnemy():GetPos().x,self:GetEnemy():GetPos().y,0)
	local pos2 = Vector(self:GetPos().x,self:GetPos().y,0)
	
	local dif = math.abs((math.abs(pos2.x)+math.abs(pos2.y))-(math.abs(pos1.x)+math.abs(pos1.y)))
	
	local dir = self:GetForward()
	
	if dif < 200 then
	
		vel_for = 0
		
	else
	

	end
	
	local vel_up = 0
	
	if dist_selfhit < 100 then -- Yete 100-en var e tive, esel e vor modig e, ere vor gamatsna
		MoveSpeed = math.Clamp(dist_selfhit, 100, MoveSpeed)
	end

	-- Final velocity
	if vel_stop == false then
		self.CurrentTurningAngle = false
		local vel_set = dir*(vel_for*MoveSpeed)
		//local vel_set_yaw = vel_set:Angle().y
		self:SetLocalVelocity(vel_set)
		local vel_len = CurTime() + (dist_selfhit / vel_set:Length())
		self.AA_MoveLength_Wander = 0
		if vel_len == vel_len then -- Check for NaN
			self.AA_MoveLength_Chase = vel_len
			self.NextIdleTime = vel_len
		end
		if Debug == true then ParticleEffect("vj_impact1_centaurspit", enepos, Angle(0,0,0), self) end
	else
		self:AAMove_Stop()
	end
	//self.NextChaseTime = CurTime() + 0.1
end

/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/