AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models  = {"models/halowars1/unsc/marine.mdl"}
ENT.StartHealth = 50
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.WanderAnim = {ACT_RUN}
ENT.SightType = 2
ENT.BehaviourType = 3
ENT.Faction = "FACTION_UNSC"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 160
ENT.MoveSpeedMultiplier = 1 -- When running, the move speed will be x times faster

ENT.PrintName = "Marine"

ENT.AttackRange = 500

ENT.FriendlyToPlayers = true

ENT.SightDistance = 512

ENT.WepDamage = 7

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
	if range < self.AttackRange^2 then
		return self:Shoot(ent)
	else
		self.Grilling = false
		self:StartMovingAnimations(self.RunAnim[1],self.MoveSpeed*self.MoveSpeedMultiplier)
		return self:ChaseEnt(ent)
	end
end

ENT.IsUpgraded = false

function ENT:Shoot(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	if !self.Shooting then
		self.Shooting = true
		--self:PlaySequenceAndWait("Prefire")
	end
	self:Face(ent)
	local seq = "Attack Assault Rifle "..math.random(1,2)..""
	--local effect = "flame_halowars_flame"
	--if self.IsUpgraded then seq = "Attack Napalm" effect = "flame_halowars_napalm" end
	--ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )
	local id, len = self:LookupSequence(seq)
	for i = 1, len*2 do
		timer.Simple( 0.4*i, function()
			if IsValid(self) then
				self:FireAt()
			end
		end )
	end
	self:PlaySequenceAndWait(id)
	if math.random(1,2) == 1 then
		self:PlaySequenceAndWait("Idle Combat "..math.random(1,5).."")
	end
	--[[if !IsValid(self.Enemy) then
		self:StopParticles()
	end]]
end

function ENT:FireAt()
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	local bullet = {}
	bullet.Num = 1
	bullet.Src = start
	bullet.Dir = self:GetAimVector()
	bullet.Spread =  Vector( 0.01, 0.01 )
	bullet.Tracer = 1
	bullet.Force = 1
	--bullet.TracerName = self.TracerName
	bullet.Damage = self.WepDamage
	bullet.Callback = function(attacker, tr, info) -- Small function to set it as we are who caused the damage

	end
	self:FireBullets(bullet)
end

function ENT:Face(ent)
	if !IsValid(ent) then return end
	local ang = (ent:GetPos()-self:GetPos()):GetNormalized():Angle()
	self:SetAngles(Angle(self:GetAngles().p,ang.y,self:GetAngles().r))
end

function ENT:Wander()
	if self.IsControlled then return end
	if math.random(1,2) == 1 then
		self:WanderToPosition( (self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * self.WanderDistance), self.WanderAnim[math.random(1,#self.WanderAnim)], self.MoveSpeed )
	else
		if self:GetActivity() != ACT_IDLE then
			self:StartActivity(ACT_IDLE)
		end
		for i = 1, 5 do
			self:SearchEnemy()
			if !IsValid(self.Enemy) then
				coroutine.wait(0.3)
			else
				return
			end
		end
	end
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
			if dist < self.AttackRange^2 and see then
				return self:Shoot(ent)
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


function ENT:GetInfected()

end

function ENT:DetermineDeath(dmg)
	local seq
	--print(dmg:GetDamageType())
	if dmg:GetDamageType() == DMG_BULLET then
	
		seq = "Death Machinegun "..math.random(1,3)..""
		
	elseif dmg:GetDamageType() == DMG_SLASH then
	
		seq = "Death Melee "..math.random(1,4)..""
		
	elseif ( dmg:GetDamageType() == DMG_BURN or self:IsOnFire() ) then
	
		seq = "Death Fire "..math.random(1,3)..""
		
		
	else
		
		if math.random(1,2) == 1 then
			seq = "Death "..math.random(1,4)..""
		else
			seq = "Death Headshot "..math.random(1,5)..""
		end
	
	end
	
	return seq
end

function ENT:CreateRagdoll(dmg)
	if dmg:GetAttacker().IsHWPopcorn then return self:GetInfected() end
	local corpse = ents.Create("prop_dynamic")
	corpse:SetPos(self:GetPos())
	corpse:SetModel(self:GetModel())
	corpse:SetAngles(self:GetAngles())
	corpse:Spawn()
	corpse:SetColor(self:GetColor())
	corpse:Activate()
	corpse:ResetSequenceInfo()
	local seq = self:DetermineDeath(dmg)
	corpse:SetSequence(seq)
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

list.Set( "NPC", "npc_iv04_hw_marine", {
	Name = "Marine",
	Class = "npc_iv04_hw_marine",
	Category = "Halo Wars Resurgence"
} )