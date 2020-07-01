AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.StartHealth = 5
ENT.Models  = {"models/hc/halo-wars/flood/infectionform_01/infectionform_01.mdl"}
ENT.Relationship = 4
ENT.MeleeDamage = 5
--ENT.RunAnim = {ACT_WALK}
ENT.SightType = 1
ENT.BehaviourType = 1
ENT.Faction = "FACTION_FLOOD"
--ENT.MeleeSound = { "doom_3/zombie2/zombie_attack1.ogg", "doom_3/zombie2/zombie_attack2.ogg", "doom_3/zombie2/zombie_attack3.ogg" }
ENT.MoveSpeed = 200
ENT.MoveSpeedMultiplier = 1 -- When running, the move speed will be x times faster
ENT.PrintName = "Flood Infection Form"

ENT.MeleeRange = 100

ENT.IdleSoundDelay = 8

ENT.NPSound = 0

ENT.NISound = 0

ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}

ENT.IsHWInfector = true

ENT.IsHWPopcorn = true

ENT.UseLineOfSight = false

ENT.SearchJustAsSpawned = true

ENT.VJ_EnhancedFlood = true

ENT.Voices = {
	["Death"] = {
		"halowars1/characters/The Flood/infection form die 2.mp3",
		"halowars1/characters/The Flood/infection form die.mp3",
		"halowars1/characters/The Flood/infection form die - explode.mp3"
	}
}

function ENT:CustomRelationshipsSetUp()
end

function ENT:Speak(quote)
	local tbl = self.Voices[quote]
	if tbl then
		local snd = tbl[math.random(#tbl)]
		self:EmitSound(snd,100)
	end
end


function ENT:OnInitialize()
	self:SetSkin(math.random(0,1))
	self:SetCollisionBounds(Vector(8,8,15),Vector(-8,-8,0))
	self:SetSolidMask(MASK_NPCSOLID)
	self.DoClimb = GetConVar("hwr_flood_infection_climb"):GetInt() == 1
end

function ENT:BeforeThink()

end

function ENT:OnHaveEnemy(ent)

end

function ENT:OnInjured(dmg)
	local rel = self:CheckRelationships(dmg:GetAttacker())
	if rel == "friend" and !dmg:GetAttacker():IsPlayer() then
		dmg:ScaleDamage(0)
		return 
	end
end

function ENT:FireAnimationEvent(pos,ang,event,name)
	--[[print(pos)
	print(ang)
	print(event)
	print(name)]]
end

function ENT:CanInfectTarget( victim )
	local can = false
	local class
	if victim.IsCEMarine then
		can = true
		class = "npc_vj_hw_flood_marine"
	elseif (  victim.Voices and !victim.GetInfected and (victim.Voices["Grunt"] or victim.Voices["Elite"])) then
		can = true
		if victim.Voices["Elite"] then 
			class = "npc_vj_hw_flood_elite" 
		elseif victim.Voices["Grunt"] then
			class = "npc_vj_hw_flood_grunt"
		end
	end
	return can ,class
end

function ENT:Infect(victim,class)
	local pos = victim:GetPos()
	local ang = victim:GetAngles()
	victim:Remove()
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	self:Remove()
end

function ENT:OnOtherKilled( victim, info )
	if !IsValid(victim) then return end -- Check if the victim is valid
	if self:Health() <= 0 then return end		
	if self.Enemy == victim then
		
		-- On killed enemy
		local found = false
		if !istable(self.temptbl) then self.temptbl = {} end
		for i=1, #self.temptbl do
			local v = self.temptbl[i]
			if istable(v) then
				local ent = v.ent
				if IsValid(ent) then
					if ent:Health() < 1 then
						self.temptbl[v] = nil
						self:SetEnemy(nil)
					end
					if IsValid(ent) and ent != victim then
						found = true
						self:SetEnemy(ent)
						break
					end
				else
					self.temptbl[i] = nil
				end
			end
		end
	end
end

function ENT:HandleAnimEvent(event,eventTime,cycle,type,options)
	--[[print(event)
	print(eventTime)
	print(cycle)
	print(type)
	print(options)]]
	--if options == self.MeleeEvent then
		self:DoMeleeDamage()
	--end
end

function ENT:DoMeleeDamage()
	local damage = self.MeleeDamage
	for	k,v in pairs(ents.FindInCone(self:GetPos()+self:OBBCenter(), self:GetForward(), self.MeleeRange,  math.cos( math.rad( self.MeleeConeAngle ) ))) do
		if v != self and self:CheckRelationships(v) != "friend" and (v:IsNPC() or v.Type == "nextbot" or v.NEXTBOT or v:IsPlayer()) then
			if v:Health() - damage <= 0 and !v.IsInfected then
				v.IsInfected = true
				local can, class = self:CanInfectTarget( v )
				if can then
					return self:Infect( v, class )
				end
			end
			v:TakeDamage( damage, self, self )
			--v:EmitSound( self.OnMeleeSoundTbl[math.random(1,#self.OnMeleeSoundTbl)] )
			if v:IsPlayer() then
				v:ViewPunch( self.ViewPunchPlayers )
			end
			if IsValid(v:GetPhysicsObject()) then
				v:GetPhysicsObject():ApplyForceCenter( v:GetPhysicsObject():GetPos() +((v:GetPhysicsObject():GetPos()-self:GetPos()):GetNormalized())*self.MeleeForce )
			end
			break
		end
	end
end

function ENT:DoKilled( info )

end

function ENT:Melee(damage) -- This section is really cancerous and a mess, if you want a nice melee I suggest you look at the oddworld stranger's wrath ones
	if self.DoingMelee == true then return end
	if !damage then damage = self.MeleeDamage end
	if IsValid(self.Enemy) then
		for i = 1, 30 do
			self.loco:FaceTowards( self.Enemy:GetPos() )
		end
	end
	local sequence = "Attack_0"..math.random(1,3)..""
	local id,len = self:LookupSequence(sequence)
	timer.Simple( len/2, function()
		if IsValid(self) then
			self:DoMeleeDamage()
		end
	end )
	self:PlaySequenceAndWait( id )
end

ENT.MeleeCheckDelay = 0.5

function ENT:ComputeAPath(ent,path)
	if !IsValid(ent) then return end
	path:Compute( self, ent:GetPos(), function( area, fromArea, ladder, elevator, length )
	if ( !IsValid( fromArea ) ) then

		-- first area in path, no cost
		return 0
	
	else
	
		if ( !self.loco:IsAreaTraversable( area ) ) then
			-- our locomotor says we can't move here
			return -1
		end

		-- compute distance traveled along path so far
		local dist = 0

		if ( IsValid( ladder ) ) then
			dist = ladder:GetLength()
		elseif ( length > 0 ) then
			-- optimization to avoid recomputing length
			dist = length
		else
			dist = ( area:GetCenter() - fromArea:GetCenter() ):GetLength()
		end

		local cost = dist + fromArea:GetCostSoFar()

		return cost
	end
end )
end

ENT.DisDelay = 0.3

ENT.ClimbAbleStuff = {
	["prop_physics"] = true,
	["prop_ragdoll"] = true,
	["worldspawn"] = true
}

function ENT:CanClimb()
	local tr = util.TraceLine( {
		start = self:WorldSpaceCenter()+self:GetUp()*20,
		endpos = self:WorldSpaceCenter()+self:GetUp()*20+self:GetForward()*40,
		filter = function(ent)
			if self.ClimbAbleStuff[ent:GetClass()] then
				return true
			else
				return false
			end
		end
	} )
	if tr.Hit then
		self:SetPos(self:GetPos()+self:GetForward()*(tr.Fraction/40))
	end
	return tr.Hit
end

function ENT:Climb(path)
	self.SavedGravity = self.loco:GetGravity()
	self.loco:SetGravity(0)
	self:SetAngles(self:GetAngles()+Angle(-90,0,0))
	self:SetPos(self:GetPos()+self:GetForward()*40)
	local stop = false
	self:StartActivity(self.RunAnim[1])
	--local dx = true
--	local vel
	--print(path:GetCurrentGoal().distanceFromStart)
	local p = self:GetPos()
	while (!stop) do
		if !self.DTr then
			self.DTr = true
			timer.Simple( 0.3, function()
				if IsValid(self) then
					self.DTr = false
				end
			end )
			local tr = util.TraceLine( {
				start = self:WorldSpaceCenter(),
				endpos = self:WorldSpaceCenter()+self:GetUp()*-40,
				filter = function(ent)
					if self.ClimbAbleStuff[ent:GetClass()] or game.GetWorld() == ent then
						return true
					else
						return false
					end
				end
			} )
			stop = !tr.Hit
		end
		--vel = path:GetCurrentGoal().forward*100 --(self:GetUp()*-10)+(Vector(0,0,1)*self.MoveSpeed)
		--if dx then
			--vel = vel+(self:GetUp()*-100)
		--end
	--	self.loco:SetVelocity(vel)
		--if self.loco:GetVelocity().x < 11 then dx = false end
		self:SetPos(p+Vector(0,0,3))
		p = self:GetPos()
		--print(self.loco:GetVelocity())
		coroutine.wait(0.01)
	end
	self:SetAngles(self:GetAngles()+Angle(90,0,0))
	self:SetPos(self:GetPos()+self:GetForward()*40)
	self.loco:SetGravity(600)
end

function ENT:BodyUpdate()
	local act = self:GetActivity()
	if act == self.RunAnim[1] then
		self:BodyMoveXY()
	end
	self:FrameAdvance()
end

function ENT:ChaseEnt(ent) -- Modified MoveToPos to integrate some stuff
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( self.PathMinLookAheadDistance )
	path:SetGoalTolerance( self.PathGoalTolerance )
	if !IsValid(ent) then return end
	self:ComputeAPath(ent,path)
	local goal
	local dis
	while ( IsValid(ent) and IsValid(path) ) do
		if GetConVar( "ai_disabled" ):GetInt() == 1 then
			self:StartActivity( self.IdleAnim[math.random(1,#self.IdleAnim)] )
			return "Disabled thinking"
		end
		if self.NextMeleeCheck < CurTime() then
			self.NextMeleeCheck = CurTime()+self.MeleeCheckDelay
			if self.loco:GetVelocity():IsZero() and self.loco:IsAttemptingToMove() then
				-- We are stuck, don't bother
				return "Give up"
			end
			local dist = self:GetPos():DistToSqr(ent:GetPos())
			if dist > self.LoseEnemyDistance^2 then 
				self:OnLoseEnemy()
				self:SetEnemy(nil)
				self.State = "Idle"
				return "Lost Enemy"
			end
			if dist < self.MeleeRange^2 and self.HasMeleeAttack then
				return self:Melee(self.MeleeDamage)
			end
		end
		if self.DoClimb and	!self.DoneDis then
			self.DoneDis = true
			timer.Simple( self.DisDelay, function()
				if IsValid(self) then
					self.DoneDis = false
				end
			end )
			goal = path:GetCurrentGoal().pos
			dis = math.abs(self:GetPos().x-goal.x)+math.abs(self:GetPos().y-goal.y)
			--print(dis,self.loco:GetVelocity().x,path:GetCurrentGoal().type)
			local climb = self:CanClimb()
			--print(climb)
			if climb then
				self:Climb(path)
			end
		end
		if ent:IsPlayer() then
			if GetConVar( "ai_ignoreplayers" ):GetInt() == 1 or !ent:Alive() then	
				self:SetEnemy(nil)
				return "Ignore players on"
			end
		end
		if path:GetAge() > self.RebuildPathTime then
			self:ComputeAPath(ent,path)
			self:OnRebuiltPath()
		end
		path:Update( self )
		if self.loco:IsStuck() then
			self:OnStuck()
			return "Stuck"
		end
		coroutine.yield()
	end
	return "ok"
end

function ENT:OnKilled(dmginfo)
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	local deadguy = ents.Create("prop_dynamic")
	deadguy:SetPos(self:GetPos()+self:GetUp()*-10)
	deadguy:SetModel(self:GetModel())
	deadguy:SetAngles(self:GetAngles()+Angle(0,math.random(360),0))
	deadguy:SetColor(self:GetColor())
	deadguy:Spawn()
	deadguy:ResetSequenceInfo()
	local id, len = self:LookupSequence("Death_01")
	self:Speak("Death")
	deadguy:SetSequence(id)
	if self:IsOnFire() then deadguy:Ignite(math.random(5,10), 0) end
	self:Remove()
	undo.ReplaceEntity(self, deadguy)
	if GetConVar( "ai_serverragdolls" ):GetInt() == 0 then
		timer.Simple( 15, function()
			if IsValid(deadguy) then
				deadguy:Remove()
			end
		end)
	end
	
	self:Remove()
end

list.Set( "NPC", "npc_iv04_hw_flood_infection", {
	Name = "Flood Infection Form",
	Class = "npc_iv04_hw_flood_infection",
	Category = "Halo Wars Resurgence"
} )