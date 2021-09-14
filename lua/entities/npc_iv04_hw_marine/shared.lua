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

ENT.Quotes = {
	["Created"] = {
		"halowars1/characters/Marine/marines ready sir!.mp3",
		"halowars1/characters/Marine/Marines_good_to_go.mp3",
		"halowars1/characters/Marine/marines_on the ground sir.mp3",
		"halowars1/characters/Marine/Marines_ooh_rah.mp3",
		"halowars1/characters/Marine/marines_reporting_for_duty.mp3",
	},
	["FireEffectBig"] = {
		"halowars1/characters/Marine/Assault rifle 3.mp3",
		"halowars1/characters/Marine/assult_rifle_fire.mp3",
		"halowars1/characters/Marine/Marine_Assault_Rifle.mp3"
	},
	["FireEffectSmall"] = {
		"halowars1/characters/Marine/assault_rifle_fire short.mp3"
	},
	["FireEffectShotgun"] = {
		"halowars1/characters/Marine/shotgun fire.mp3"
	},
	["ReloadShotgun"] = {
		"halowars1/characters/Marine/shotgun load.mp3"
	},
	["CockShotgun"] = {
		"halowars1/characters/Marine/shotgun c0ck.mp3"
	},
	["Selected"] = {
		"halowars1/characters/Marine/marine_standing by 2.mp3"
	},
	["Move"] = {
		"halowars1/characters/Marine/Marines_were going.mp3"
	},
	["Death"] = {
		"halowars1/characters/Marine/Generic_death.mp3",
		"halowars1/characters/Marine/Generic_death 2.mp3",
		"halowars1/characters/Marine/Generic_death 3.mp3",
		"halowars1/characters/Death Screams - Updated/Marine-Rebel - Generic Death Scream 4 (or 5).ogg"
	},
	["Special"] = {
		"halowars1/characters/Marine/marien_ Grenades ON MY MARK.mp3",
		"halowars1/characters/Marine/marine_ GRENADES DO IT.mp3",
		"halowars1/characters/Marine/marine_fire_in_the_hole.mp3",
		"halowars1/characters/Marine/Marine_Grenade out.mp3"
	},
	["SpecialRocket"] = {
		"halowars1/characters/Marine/Marine_Locking on.mp3",
		"halowars1/characters/Marine/marine_rockets out.mp3",
		"halowars1/characters/Marine/marine_rpg OUT.mp3",
		"halowars1/characters/Marine/marine_smoke_em_out.mp3"
	},
	["Attack"] = {
		"halowars1/characters/Marine/marien_were going in.mp3",
		"halowars1/characters/Marine/Marine_fireing.mp3"
	}
}

function ENT:Speak(quote)
	local tbl = self.Quotes[quote]
	if self.CurSound then self.CurSound:Stop() end
	if tbl then
		local snd = tbl[math.random(#tbl)]
		self.CurSound = CreateSound( self, snd )
		self.CurSound:SetSoundLevel( 100 )
		self.CurSound:Play()
	end
end

function ENT:OnSelected(selector)
	self:Speak("Selected")
	return true
end

function ENT:OnMoved(mover)
	self:Speak("Move")
	return true
end

function ENT:OnOrderedToAttack(mover)
	self:Speak("Attack")
	return true
end

function ENT:OnSpecialAttack(mover)
	if self.IsUpgraded then
		self:Speak("SpecialRocket")
	else
		self:Speak("Special")
	end
	return true
end

function ENT:OnInitialize()
	if !self.Color then
		self:SetColor(Color(155,166,90,255))
	end
	self:SetCollisionBounds(Vector(-15,-15,0),Vector(15,15,60))
	self:Speak("Created")
	self:SetSkin(1)
end

function ENT:CustomBehaviour(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	--print(ent)
	local range = self:GetRangeSquaredTo(Vector(ent:GetPos().x,ent:GetPos().y,self:GetPos().z))
	if range < self.AttackRange^2 and self:IsLineOfSightClear(ent) then
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
	local ra = math.random(2,3)
	local r = ra == 2
	for i = 1, ra do
		timer.Simple( 0.2*i, function()
			if IsValid(self) then
				if i == 1 then
					if r then
						self:Speak("FireEffectSmall")
					else
						self:Speak("FireEffectBig")
					end
				end
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
		if math.random(1,2) == 1 then
			self:ResetSequence("Idle Combat "..math.random(1,5).."")
		else
			if self:GetActivity() != ACT_IDLE then
				self:StartActivity(ACT_IDLE)
			end
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

function ENT:GetShootPos()
	return self:GetAttachment(1).Pos
end

function ENT:OnInjured( dmg )
	if self:Health() < 1 then return end
	if dmg:GetAttacker().IsHWPopcorn then
		local func = function()
			coroutine.wait(3)
		end
		table.insert(self.StuffToRunInCoroutine,func)
		self:ResetAI()
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

list.Set( "NPC", "npc_iv04_hw_marine", {
	Name = "Marine",
	Class = "npc_iv04_hw_marine",
	Category = "Halo Wars Resurgence"
} )

function ENT:DieUpdate( fInterval )
	
	if !self.DieThread then return end

	local ok, message = coroutine.resume( self.DieThread )

end

function ENT:BehaveUpdate( fInterval )

	if ( !self.BehaveThread ) then return self:DieUpdate(fInterval) end

	--
	-- Give a silent warning to developers if RunBehaviour has returned
	--
	if ( coroutine.status( self.BehaveThread ) == "dead" and self:Health() > 0 ) then

		self.BehaveThread = nil
		Msg( self, " Warning: ENT:RunBehaviour() has finished executing\n" )

		return

	end
	if self.ShouldResetAI and CurTime() > self.ResetAITime then
		self.ResetAITime = CurTime()+self.ResetAIDelay
		--print("Reseted AI")
		self:ResetAI()
	end
	--
	-- Continue RunBehaviour's execution
	--
	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then

		self.BehaveThread = nil
		ErrorNoHalt( self, " Error: ", message, "\n" )

	end

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

function ENT:BodyUpdate()
	local act = self:GetActivity()
	if self.BeenInfected and !self.loco:GetVelocity():IsZero() then
		self:BodyMoveXY()
	end
	self:FrameAdvance()
end

function ENT:GetInfected(dmg)
	local id, len = self:LookupSequence("Death Flood")
	self.Faction = "FACTION_FLOOD"
	dmg:GetAttacker():Remove()
	if math.random(1,2) == 1 then
		local dir = self:GetForward()*math.Rand(-1,1)+self:GetRight()*math.Rand(-1,1)
		local stop = false
		timer.Simple( math.random(1,3), function()
			if IsValid(self) then
				stop = true
			end
		end )
		self:ResetSequenceInfo()
		self:ResetSequence(self:LookupSequence("Death Flood Jog"))
		self.loco:SetDesiredSpeed(self.MoveSpeed*self.MoveSpeedMultiplier)
		while (!stop) do
			if self:GetCycle() > 0.9 then
				self:SetCycle(0)
			end
			self.loco:FaceTowards(self:GetPos()+dir)
			self.loco:Approach(dir+self:GetPos(),1)
			coroutine.wait(0.01)
		end
		-- Why do you enjoy breaking so fcking much?
		local p = ents.Create("prop_dynamic")
		p:SetPos(self:GetPos())
		p:SetColor(self:GetColor())
		p:SetModel(self:GetModel())
		p:SetAngles(self:GetAngles())
		p:Spawn()
		p:Activate()
		p:ResetSequenceInfo()
		p:SetSequence(id)
		undo.ReplaceEntity(self,p)
		timer.Simple( len, function()
			if IsValid(p) then
				local flood = ents.Create("npc_iv04_hw_flood_marine")
				flood:SetPos(p:GetPos())
				flood:SetAngles(p:GetAngles())
				flood:Spawn()
				undo.ReplaceEntity(p,flood)
				p:Remove()
			end
		end )
		self:Remove()
	else
		timer.Simple( len, function()
			if IsValid(self) then
				local flood = ents.Create("npc_iv04_hw_flood_marine")
				flood:SetPos(self:GetPos())
				flood:SetAngles(self:GetAngles())
				flood:Spawn()
				undo.ReplaceEntity(self,flood)
				self:Remove()
			end
		end )
		self:PlaySequenceAndWait("Death Flood")
	end
end

function ENT:DetermineDeath(dmg)
	local seq
	--print(dmg:GetDamageType())
	if dmg:IsBulletDamage() then
	
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
	if dmg:GetAttacker().IsHWInfector then self.BeenInfected = true return self:GetInfected(dmg) end
	self:Speak("Death")
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