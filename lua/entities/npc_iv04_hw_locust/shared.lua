AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models  = {"models/halowars1/covenant/locust.mdl"}
ENT.StartHealth = 200
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.RunAnim = {ACT_WALK}
ENT.WanderAnim = {ACT_WALK}
ENT.SightType = 2
ENT.BehaviourType = 3
ENT.Faction = "FACTION_COVENANT"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 160
ENT.MoveSpeedMultiplier = 1 -- When running, the move speed will be x times faster

ENT.PrintName = "Locust"

ENT.ToastRange = 900

ENT.FriendlyToPlayers = true

ENT.SightDistance = 1024

function ENT:OnInitialize()
	self:SetBloodColor(BLOOD_COLOR_MECH)
	if !self.Color then
		self:SetColor(Color(193,74,201,255))
	end
end

function ENT:CustomBehaviour(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	--print(ent)
	local range = self:GetRangeSquaredTo(ent)
	if range < self.ToastRange^2 then
		return self:Toast(ent)
	else
		self:StopParticles()
		self.Toasting = false
		self:StartMovingAnimations(self.RunAnim[1],self.MoveSpeed*self.MoveSpeedMultiplier)
		return self:ChaseEnt(ent)
	end
end

ENT.IsUpgraded = false

function ENT:Toast(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	if !self.Toasting then
		self.Toasting = true
		--self:PlaySequenceAndWait("Prefire")
	end
	self:Face(ent)
	--local seq = "Attack "..math.random(1,2)..""
	--local effect = "flame_halowars_flame"
	--if self.IsUpgraded then seq = "Attack Napalm" effect = "flame_halowars_napalm" end
	--ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )
	local id, len = self:LookupSequence("Attack")
	for i = 1, len*10 do
		timer.Simple( 0.1*i, function()
			if IsValid(self) then
				self:FireAt()
			end
		end )
	end
	self:PlaySequenceAndWait(id)
	--[[if !IsValid(self.Enemy) then
		self:StopParticles()
	end]]
end

function ENT:FireAt()
	if !IsValid(self.Enemy) then return end
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	local bullet = {}
	bullet.Num = 1
	bullet.Src = start
	bullet.Dir = (self.Enemy:WorldSpaceCenter()-start):GetNormalized()
	bullet.Spread =  Vector( 0.01, 0.01 )
	bullet.Tracer = 1
	bullet.Force = 1
	bullet.TracerName = "effect_osw_tracer_sniper_outlaw"
	bullet.Damage = 4
	bullet.Callback = function(attacker, tr, info) -- Small function to set it as we are who caused the damage

	end
	self:FireBullets(bullet)
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
			if dist < self.ToastRange^2 and see then
				return self:Toast(ent)
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

function ENT:OnKilled( dmginfo ) -- When killed
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	self.KilledDmgInfo = dmginfo
	self.BehaveThread = nil
	self.DieThread = coroutine.create( function() self:DoKilledAnim() end )
	coroutine.resume( self.DieThread )
end

function ENT:DoKilledAnim()
	--local anim
	--anim = "Death"
	--local len = self:SequenceDuration(self:LookupSequence(anim))
	--timer.Simple(len, function()
		--if IsValid(self) then
			self:CreateRagdoll( self.KilledDmgInfo )
		--end
	--end)
	--self:PlaySequenceAndWait(anim, 1)
end

function ENT:CreateRagdoll(dmg)
	local corpse = ents.Create("prop_dynamic")
	corpse:SetPos(self:GetPos())
	corpse:SetModel(self:GetModel())
	corpse:SetAngles(self:GetAngles())
	corpse:Spawn()
	corpse:Activate()
	corpse:ResetSequenceInfo()
	corpse:SetSequence("Death")
	corpse:SetCycle(1)
	--corpse.IsOSWCorpse = true
	corpse.Faction = self.Faction
	if !corpse:IsOnGround() then
		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos()+self:GetUp()*-999999,
			filter = {self,corpse}
		} )
		if tr.Hit then
			corpse:SetPos(tr.HitPos)
		end
	end
	--local snd = table.Random(self.SoundDeath)
	--corpse:EmitSound(snd,100)
	undo.ReplaceEntity( self, corpse )
	self:Remove()
	--[[timer.Simple( 15, function()
		if IsValid(corpse) then
			corpse:SetColor(Color(127+math.random(100,-100),95+math.random(100,-100),0,255))
		end
	end)]]
	if GetConVar( "ai_serverragdolls" ):GetInt() == 0 then
		timer.Simple( 30, function()
			if IsValid(corpse) then
				corpse:Remove()
			end
		end)
	end
end

list.Set( "NPC", "npc_iv04_hw_locust", {
	Name = "Locust",
	Class = "npc_iv04_hw_locust",
	Category = "Halo Wars Resurgence"
} )