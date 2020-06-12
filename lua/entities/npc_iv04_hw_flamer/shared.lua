AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models  = {"models/halowars1/unsc/flamer.mdl"}
ENT.StartHealth = 50
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.RunAnim = {ACT_RUN}
ENT.SightType = 3
ENT.BehaviourType = 3
ENT.Faction = "FACTION_UNSC"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 80
ENT.MoveSpeedMultiplier = 2 -- When running, the move speed will be x times faster

ENT.PrintName = "Flamethrower"

ENT.FlameRange = 300

ENT.FriendlyToPlayers = true

function ENT:OnInitialize()
	if !self.Color then
		self:SetColor(Color(0,140,9,255))
	end
end

function ENT:CustomBehaviour(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	--print(ent)
	local range = self:GetRangeSquaredTo(ent)
	if range < self.FlameRange^2 then
		return self:Grill(ent)
	else
		self.Grilling = false
		self:StartMovingAnimations(self.RunAnim[1],self.MoveSpeed*self.MoveSpeedMultiplier)
		return self:ChaseEnt(ent)
	end
end

ENT.IsUpgraded = false

function ENT:Grill(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	if !self.Grilling then
		self.Grilling = true
		self:PlaySequenceAndWait("Prefire")
	end
	self:Face(ent)
	local seq = "Attack "..math.random(1,2)..""
	local effect = "flame_halowars_flame"
	if self.IsUpgraded then seq = "Attack Napalm" effect = "flame_halowars_napalm" end
	ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )
	local id, len = self:LookupSequence(seq)
	for i = 1, len*5 do
		timer.Simple( 0.2*i, function()
			if IsValid(self) then
				self:Burn()
			end
		end )
	end
	self:PlaySequenceAndWait(id)
	if !IsValid(self.Enemy) then
		self:StopParticles()
	end
end

function ENT:Burn()
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	for k, v in pairs(ents.FindInCone(start,normal,self.FlameRange,math.cos( math.rad( 45 ) ))) do
		if v:Health() > 1 and self:CheckRelationships(v) != "friend" then
			local num = math.random(2,5)
			if self.IsUpgraded then
				num = num+math.random(2,5)
			end
			v:TakeDamage( num/2, self, self )
			v:Ignite(num)
		end
	end
end

function ENT:Face(ent)
	if !IsValid(ent) then return end
	local ang = (ent:GetPos()-self:GetPos()):GetNormalized():Angle()
	self:SetAngles(Angle(self:GetAngles().p,ang.y,self:GetAngles().r))
end

function ENT:ChaseEnt(ent) -- Modified MoveToPos to integrate some stuff
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( self.PathMinLookAheadDistance )
	path:SetGoalTolerance( self.PathGoalTolerance )
	if !IsValid(ent) then return end
	path:Compute( self, ent:GetPos() )
	while ( IsValid(ent) and IsValid(path) ) do
		if GetConVar( "ai_disabled" ):GetInt() == 1 then
			self:StartActivity( self.IdleAnim[math.random(1,#self.IdleAnim)] )
			return "Disabled thinking"
		end
		if self.NextMeleeCheck < CurTime() then
			self.NextMeleeCheck = CurTime()+0.3
			if self.loco:GetVelocity():IsZero() and self.loco:IsAttemptingToMove() then
				-- We are stuck, don't bother
				return "Give up"
			end
			local dist = self:WorldSpaceCenter():DistToSqr(ent:NearestPoint(self:WorldSpaceCenter()))
			if dist > self.LoseEnemyDistance^2 then
				self:OnLoseEnemy()
				self:SetEnemy(nil)
				self.State = "Idle"
				return "Lost Enemy"
			end
			local see = self:IsLineOfSightClear(ent)
			if dist < self.FlameRange^2 and see then
				return self:Grill(ent)
			end
		end
		if ent:IsPlayer() then
			if GetConVar( "ai_ignoreplayers" ):GetInt() == 1 or !ent:Alive() then	
				self:SetEnemy(nil)
				return "Ignore players on"
			end
		end
		if path:GetAge() > self.RebuildPathTime then
			path:Compute( self, ent:GetPos() )
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

list.Set( "NPC", "npc_iv04_hw_flamer", {
	Name = "Flamethrower",
	Class = "npc_iv04_hw_flamer",
	Category = "Halo Wars Resurgence"
} )