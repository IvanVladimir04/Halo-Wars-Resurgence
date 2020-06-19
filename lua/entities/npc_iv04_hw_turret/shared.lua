AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models  = {"models/halowars1/unsc/turret.mdl"}
--ENT.Models = {"models/rotr_blackbear/compiled 0.68/models/rotr_blackbear/blackbear.mdl"}
ENT.StartHealth = 400
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.RunAnim = {ACT_RUN}
ENT.SightType = 1
ENT.BehaviourType = 3
ENT.Faction = "FACTION_UNSC"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 160
ENT.MoveSpeedMultiplier = 1 -- When running, the move speed will be x times faster

ENT.PrintName = "Turret"

ENT.ToastRange = 900

ENT.FriendlyToPlayers = true

ENT.SightDistance = 1536

ENT.LoseEnemyDistance = 1736

if CLIENT then

	function ENT:Initialize()

	end

end

function ENT:OnInitialize()
	self.UpgradeLevel = 1
	self:SetBloodColor(BLOOD_COLOR_MECH)
	if !self.Color then
		self:SetColor(Color(0,140,9,255))
	end
	self.Socket = ents.Create("prop_dynamic")
	self.Socket:SetModel("models/halowars1/unsc/turret_socket_01.mdl")
	self.Socket:SetPos(self:GetPos())
	self.Socket:SetAngles(self:GetAngles())
	self.Socket:Spawn()
	self.Socket:SetParent(self)
	self.Socket:SetOwner(game.GetWorld())
	self.Socket:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.Socket:SetCollisionBounds(Vector(0,0,0),Vector(0,0,0))
	self.Socket:SetRenderMode(RENDERMODE_TRANSALPHA)
	local attch = self.Socket:GetAttachment(1)
	self.Clone = ents.Create("prop_dynamic")
	self.Clone:SetModel(self:GetModel())
	self.Clone:SetAngles(self:GetAngles())
	self.Clone:SetPos(attch.Pos)
	self.Clone:SetColor(self:GetColor())
	self.Clone:SetParent(self.Socket,nil)
	self.Clone:SetOwner(self)
	self.Clone:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.Clone:SetCollisionBounds(Vector(0,0,0),Vector(0,0,0))
	self.Clone:SetSequence("Idle")
	self.Clone:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Clone.Draw = function() self.Clone:DrawModel() end
	local id1, len1 = self.Socket:LookupSequence("Door Open")
	local id2, len2 = self.Socket:LookupSequence("Platform Raise")
	self.Socket:ResetSequenceInfo()
	self.Socket:SetPlaybackRate(1)
	self.Socket:SetSequence(id1)
	local pos = self.Clone:GetPos()
	timer.Simple( len1, function()
		if IsValid(self.Socket) then
			self.Socket:SetSequence(id2)
			for i = 1, 2630 do
				timer.Simple( i*0.01, function()
					if IsValid(self.Clone) then
						pos = pos+self.Clone:GetUp()*0.186
						self.Clone:SetPos(pos)
						--print(i)
					end
				end )
			end
		end
	end )
	self:SetNoDraw(true)
	local done = false
	timer.Simple( len1+len2, function()
		if IsValid(self) then
			self.Socket:SetSequence("Idle")
			done = true
		end
	end )
	local func = function()
		while (!done) do
			coroutine.wait(0.01)
		end
		self:SetNoDraw(false)
		if IsValid(self.Clone) then self.Clone:Remove() end
		--if IsValid(self.Socket) then self.Socket:SetSequence("Idle") end
	end
	table.insert(self.StuffToRunInCoroutine,func)
end

function ENT:CustomBehaviour(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	--print(ent)
	self:Attack(ent)
end

ENT.IsUpgraded = false

function ENT:Attack(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	for i = 1, 4 do
		self:FireAt()
		coroutine.wait(0.3)
	end
end

function ENT:Wander()
	if self.IsControlled then return end
	if self:GetActivity() != self.IdleAnim[math.random(1,#self.IdleAnim)] then
		self:StartActivity(self.IdleAnim[math.random(1,#self.IdleAnim)])
		self:ResetSequence(self:SelectWeightedSequence(self.IdleAnim[math.random(1,#self.IdleAnim)]))
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

ENT.ShootAnimations = {
	[1] = "Attack Turret 1",
	[2] = "Attack Turret 2",
	[3] = "Attack Turret 3"
}


function ENT:FireAt()
	if !IsValid(self.Enemy) then return end
	local a = self:LookupSequence(self.ShootAnimations[self.UpgradeLevel])
	local gest = self:AddGestureSequence(a)
	self:SetLayerPriority(gest,2)
	self:SetLayerPlaybackRate(gest,1)
	self:SetLayerCycle(gest,0)
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	local bullet = {}
	bullet.Num = 1
	bullet.Src = start
	bullet.Dir = (self.Enemy:WorldSpaceCenter()-start):GetNormalized()
	bullet.Spread =  Vector( 0, 0 )
	bullet.Tracer = 1
	bullet.Force = 1
	--bullet.TracerName = "effect_osw_tracer_sniper_outlaw"
	bullet.Damage = 10
	bullet.Callback = function(attacker, tr, info) -- Small function to set it as we are who caused the damage
		info:SetAttacker(self)
		info:SetDamageType(DMG_BLAST)
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

function ENT:BodyUpdate()
	local act = self:GetActivity()
	if IsValid(self.Enemy) then
		local ang = self:GetAimVector():Angle()
		--if ang.p < -45 then ang.p = -45 elseif ang.p > 45 then ang.p = 45 end
		local ang1 = self:GetAngles()
		local dif = math.AngleDifference( ang.y, ang1.y )
		local dif2 = math.AngleDifference( ang.p, ang1.p )
		if dif2 < -45 then dif2 = -45 elseif dif2 > 45 then dif2 = 45 end
		self:SetPoseParameter("aim_pitch",dif2)
		self:SetPoseParameter("aim_yaw",dif)
	else
		self:SetPoseParameter("aim_pitch",0)
		self:SetPoseParameter("aim_yaw",0)
	end
	self:FrameAdvance()
end

local thingstoavoid = {
	["prop_physics"] = true,
	["prop_ragdoll"] = true
}

function ENT:OnContact( ent ) -- When we touch someBODY
	if ent == game.GetWorld() then return "no" end
	if (ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door" or ent:GetClass() == "func_door_rotating" ) then
		ent:Fire( "Open" )
	end
	if (thingstoavoid[ent:GetClass()]) then
		local p = ent:GetPhysicsObject()
		if IsValid(p) then
			p:Wake()
			local d = ent:GetPos()-self:GetPos()
			p:SetVelocity(d*5)
		end
	end
	local tbl = {
		HitPos = self:NearestPoint(ent:GetPos()),
		HitEntity = self,
		OurOldVelocity = ent:GetVelocity(),
		DeltaTime = 0,
		TheirOldVelocity = self.loco:GetVelocity(),
		HitNormal = self:NearestPoint(ent:GetPos()):GetNormalized(),
		Speed = ent:GetVelocity().x,
		HitObject = self:GetPhysicsObject(),
		PhysObject = self:GetPhysicsObject()
	}
	if isfunction(ent.DoDamageCode) then
		ent:DoDamageCode(tbl,self:GetPhysicsObject())
	elseif isfunction(ent.PhysicsCollide) then 
		ent:PhysicsCollide(tbl,self:GetPhysicsObject())
	end
end

list.Set( "NPC", "npc_iv04_hw_turret", {
	Name = "Turret",
	Class = "npc_iv04_hw_turret",
	Category = "Halo Wars Resurgence"
} )