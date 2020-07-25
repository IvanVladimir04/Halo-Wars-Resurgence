AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models  = {"models/halowars1/unsc/spartan.mdl"}
ENT.StartHealth = 300
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.RunAnim = {ACT_RUN}
ENT.SightType = 2
ENT.BehaviourType = 3
ENT.Faction = "FACTION_UNSC"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 80
ENT.MoveSpeedMultiplier = 2 -- When running, the move speed will be x times faster

ENT.PrintName = "Spartan"

ENT.AttackRange = 512

ENT.FriendlyToPlayers = true

ENT.SightDistance = 1024

ENT.PossibleWeapons = {
	[1] = "DualSMG",
	[2] = "Rocket",
	[3] = "SpartanLaser",
	[4] = "Minigun"
}

ENT.AnimsList = {
	["Attack"] = {
		["DualSMG"] = {"Attack Dual SMG's 3","Attack Dual SMG's 2","Attack Dual SMG's 1"},
		["Minigun"] = {"Attack Minigun Loop"},
		["SpartanLaser"] = {"Attack Spartan Laser"},
		["Rocket"] = {"Attack Spartan Laser"}
	},
	["Evade"] = {
		["DualSMG"] = {["Right"] = {"Evade Dual Left"}, ["Left"] = {"Evade Dual Right"}},
		["Minigun"] = {["Right"] = {"Evade Minigun Left"}, ["Left"] = {"Evade Minigun Right"}},
		["SpartanLaser"] = {["Right"] = {"Evade Spartan Laser Left"}, ["Left"] = {"Evade Spartan Laser Right"}},
		["Rocket"] = {["Right"] = {"Evade Spartan Laser Left"}, ["Left"] = {"Evade Spartan Laser Right"}}
	},
	["Idle"] = {
		["DualSMG"] = {"Idle Dual"},
		["Minigun"] = {"Idle Minigun"},
		["SpartanLaser"] = {"Idle Spartan Laser"},
		["Rocket"] = {"Idle Spartan Laser"}
	},
	["Run"] = {
		["DualSMG"] = {"Run Dual 1","Run Dual 2","Run Dual 3"},
		["Minigun"] = {"Run Minigun"},
		["SpartanLaser"] = {"Run Spartan Laser"},
		["Rocket"] = {"Run Spartan Laser"}
	}
}

ENT.Muzzles = {
	[1] = {1,2},
	[2] = {4},
	[3] = {3},
	[4] = {5}
}

function ENT:GetShootPos()
	local tbl = self.Muzzles[self.MuzzleTyp]
	return self:GetAttachment(tbl[math.random(#tbl)]).Pos
end

function ENT:OnInitialize()
	if !self.Color then
		self:SetColor(Color(155,166,90,255))
	end
	local r = math.random(1,4)
	self.MuzzleTyp = r
	local typ = self.PossibleWeapons[r]
	self.WeaponType = typ
	self:SetBodygroup(1,r-1)
	local list = self.AnimsList
	local run = list["Run"]
	self.RunAnim = self:TranslateStringToAct(run[typ])
	self.WanderAnim = self.RunAnim
	self.WalkAnim = self.RunAnim
	local idle = list["Idle"]
	self.IdleAnim = self:TranslateStringToAct(idle[typ])
	local attack = list["Attack"]
	self.AttackAnim = self:TranslateStringToAct(attack[typ])
	local evade = list["Evade"]
	self.EvadeAnimLeft = self:TranslateStringToAct(evade[typ]["Left"])
	self.EvadeAnimRight = self:TranslateStringToAct(evade[typ]["Right"])
end

function ENT:TranslateStringToAct(tbl)
	local tb = {}
	for i = 1, #tbl do
		local id, len = self:LookupSequence(tbl[i])
		local act = self:GetSequenceActivity(id)
		tb[#tb+1] = act
	end
	return tb
end

function ENT:Wander()
	if self.IsControlled then return end
	if math.random(1,2) == 1 then
		self:WanderToPosition( (self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * self.WanderDistance), self.RunAnim[math.random(1,#self.RunAnim)], self.MoveSpeed*self.MoveSpeedMultiplier )
		if self:GetActivity() != self.IdleAnim[math.random(1,#self.IdleAnim)] then
			self:StartActivity(self.IdleAnim[math.random(1,#self.IdleAnim)])
			self:ResetSequence(self:SelectWeightedSequence(self.IdleAnim[math.random(1,#self.IdleAnim)]))
		end
	else
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
end

function ENT:CustomBehaviour(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	--print(ent)
	local range = self:GetRangeSquaredTo(ent)
	if range < self.AttackRange^2 then
		return self:FireAt(ent)
	else
		--self:StopParticles()
		self.Attacking = false
		self:StartMovingAnimations(self.RunAnim[math.random(1,#self.RunAnim)],self.MoveSpeed*self.MoveSpeedMultiplier)
		return self:ChaseEnt(ent)
	end
end

ENT.IsUpgraded = false

function ENT:Face(ent)
	if !IsValid(ent) then return end
	local ang = (ent:GetPos()-self:GetPos()):GetNormalized():Angle()
	self:SetAngles(Angle(self:GetAngles().p,ang.y,self:GetAngles().r))
end

function ENT:FireFromAttachment(attch,dmg)
	local prop = ents.Create("prop_dynamic")
	local att = self:GetAttachment(attch)
	local start = att.Pos
	local normal = att.Ang:Forward()
	prop:SetPos(start)
	prop:SetModel(self:GetModel())
	prop:SetAngles(self:GetAngles())
	prop:SetNoDraw(true)
	prop:Spawn()
	local bullet = {}
	bullet.Num = 1
	bullet.Src = prop:GetPos()
	bullet.Dir = self:GetAimVector()
	bullet.Spread =  Vector( 0, 0 )
	bullet.Tracer = 1
	bullet.Force = 1
	--bullet.TracerName = self.TracerName
	bullet.Damage = dmg or 5
	bullet.Callback = function(attacker, tr, info) -- Small function to set it as we are who caused the damage

	end
	prop:Remove()
	self:FireBullets(bullet)
end

function ENT:FireAt()
	self:Face(self.Enemy)
	if self.WeaponType == "Minigun" then
		self:PlaySequenceAndWait("Attack Minigun Start")
		local stop = false
		while (!stop) do
			if !self.Checked then
				self.Checked = true
				timer.Simple( 0.5, function()
					if IsValid(self) then
						self.Checked = false
					end
				end )
				if IsValid(self.Enemy) then
					if !self:IsLineOfSightClear(self.Enemy) then stop = true end
					if self:GetRangeSquaredTo(self.Enemy:GetPos()) > self.AttackRange^2 then stop = true end
				else
					stop = true
				end
			end
			self:FireFromAttachment(5)
			coroutine.wait(0.1)
		end
		self:PlaySequenceAndWait("Attack Minigun Loop")
		self:PlaySequenceAndWait("Attack Minigun End")
	elseif self.WeaponType == "DualSMG" then -- Prepare for timer hell
		local r = math.random(1,3)
		if r == 1 then
			for i = 1, 5 do
				timer.Simple( i*0.1, function()
					if IsValid(self) then
						self:FireFromAttachment(2,3)
					end
				end )
			end
			for i = 1, 3 do
				timer.Simple( 0.7+(i*0.1), function()
					if IsValid(self) then
						self:FireFromAttachment(1,3)
					end
				end )
			end
			timer.Simple( 1.3, function()
				if IsValid(self) then
					self:FireFromAttachment(1,3)
				end
			end )
			timer.Simple( 1.4, function()
				if IsValid(self) then
					self:FireFromAttachment(2,3)
				end
			end )
			self:PlaySequenceAndWait("Attack Dual SMG's 1")
		elseif r == 2 then
			for i = 1, 3 do
				timer.Simple( i*0.2, function()
					if IsValid(self) then
						self:FireFromAttachment(2,3)
					end
				end )
			end
			for i = 1, 3 do
				timer.Simple( (i*0.2)-0.1, function()
					if IsValid(self) then
						self:FireFromAttachment(1,3)
					end
				end )
			end
			self:PlaySequenceAndWait("Attack Dual SMG's 2")
		elseif r == 3 then
			for i = 1, 5 do
				timer.Simple( i*0.1, function()
					if IsValid(self) then
						self:FireFromAttachment(2,3)
					end
				end )
			end
			for i = 1, 3 do
				timer.Simple( (i*0.2)+1, function()
					if IsValid(self) then
						self:FireFromAttachment(2,3)
					end
				end )
			end
			for i = 1, 3 do
				timer.Simple( ((i*0.2)-0.1)+1, function()
					if IsValid(self) then
						self:FireFromAttachment(1,3)
					end
				end )
			end
			self:PlaySequenceAndWait("Attack Dual SMG's 3")
		end
	elseif self.WeaponType == "Rocket" then 
		timer.Simple( 0.7, function()
			if IsValid(self) then
				local prop = ents.Create("prop_physics")
				prop:SetPos(self:GetAttachment(4).Pos)
				prop:SetAngles(self:GetAngles())
				prop:SetModel("models/weapons/w_missile_closed.mdl")
				prop:Spawn()
				prop:GetPhysicsObject():SetVelocity(self:GetAimVector()*1000)
				prop:AddCallback( "OnAngleChange", function( entity, newangle )
					if IsValid(self) then
						entity:GetPhysicsObject():SetVelocity(prop:GetVelocity()+self:GetAimVector()*50)
					else
						entity:GetPhysicsObject():SetVelocity(prop:GetVelocity()+entity:GetAngles():Forward()*50)
					end
				end )
				prop:AddCallback( "PhysicsCollide", function( entity, data )
					data.HitEntity:TakeDamage(100,self,self)
					prop:Remove()
				end )
			end
		end )
		self:PlaySequenceAndWait("Attack Spartan Laser")
	elseif self.WeaponType == "SpartanLaser" then
		timer.Simple( 0.7, function()
			if IsValid(self) then
				local tr = util.TraceLine( { start = self:GetAttachment(5).Pos, endpos = self:GetAttachment(5).Pos+self:GetAimVector()*9999, filter = self } )
				if IsValid(tr.Entity) then
					tr.Entity:TakeDamage(120, self, self)
				end
				local prop = ents.Create("prop_dynamic")
				local att = self:GetAttachment(5)
				local start = att.Pos
				local normal = att.Ang:Forward()
				prop:SetPos(start)
				prop:SetModel(self:GetModel())
				prop:SetAngles(self:GetAngles())
				prop:SetNoDraw(true)
				prop:Spawn()
				local bullet = {}
				bullet.Num = 1
				bullet.Src = prop:GetPos()
				bullet.Dir = self:GetAimVector()
				bullet.Spread =  Vector( 0, 0 )
				bullet.Tracer = 1
				bullet.Force = 1
				bullet.TracerName = "effect_omo_tracer_generic"
				bullet.Damage = 0
				prop:Remove()
				self:FireBullets(bullet)
			end
		end )
		self:PlaySequenceAndWait("Attack Spartan Laser")
	end
end

function ENT:Burn()
	local att = self:GetAttachment(1)
	local start = att.Pos
	local normal = att.Ang:Forward()
	for k, v in pairs(ents.FindInCone(start,normal,self.AttackRange,math.cos( math.rad( 30 ) ))) do
		if v:Health() > 1 and self:CheckRelationships(v) != "friend" then
			local num = math.random(2,5)
			if self.IsUpgraded then
				num = num+math.random(2,5)
			end
			dm = DamageInfo()
			dm:SetDamage( num/2 )
			dm:SetAttacker(self)
			dm:SetInflictor(self)
			dm:SetDamageType( DMG_BURN )
			v:TakeDamageInfo( dm )
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
			if dist < self.AttackRange^2 and see then
				return self:FireAt(ent)
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
	self:CreateRagdoll(dmginfo)
end

list.Set( "NPC", "npc_iv04_hw_spartan", {
	Name = "Spartan",
	Class = "npc_iv04_hw_spartan",
	Category = "Halo Wars Resurgence"
} )

function ENT:BodyUpdate()
	local act = self:GetActivity()
	self:FrameAdvance()
end

function ENT:DetermineDeath(dmg)
	local seq
	--print(dmg:GetDamageType())

		seq = "Death "..math.random(1,2)..""

	return seq
end

function ENT:CreateRagdoll(dmg)
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
	corpse:SetBodygroup(1,self:GetBodygroup(1))
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