AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models = {"models/hc/halo-wars/flood/infectedflame_01/infectedflame_01.mdl"} 
ENT.StartHealth = 50
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.RunAnim = {ACT_RUN}
ENT.SightType = 2
ENT.BehaviourType = 3
ENT.Faction = "FACTION_FLOOD"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 80
ENT.MoveSpeedMultiplier = 2 -- When running, the move speed will be x times faster

ENT.PrintName = "Infected Flamethrower"

ENT.FlameRange = 300

ENT.FriendlyToPlayers = true

ENT.SightDistance = 512

ENT.LoseEnemyDistance = 15000

ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}

function ENT:PreInit()
	self.Quotes = {
		["Created"] = {
			"halowars1/characters/The Flood/Flood Mutate.mp3",
			"halowars1/characters/The Flood/flood mutate 2.mp3",
			"halowars1/characters/The Flood/flood mutate 3.mp3",
		},
		["FireEffect"] = {
			"halowars1/characters/Flame Thrower/Flamer Thrower Fire sound effect.mp3"
		},
		["Death"] = {
			"halowars1/characters/The Flood/Combat form die.mp3",
			"halowars1/characters/The Flood/Combat form die 2.mp3",
			"halowars1/characters/The Flood/combat form die 3.mp3",
			"halowars1/characters/The Flood/flood die all 1.mp3",
			"halowars1/characters/The Flood/flood die all 2.mp3"
		}
	}
end

function ENT:OnInitialize()
	self:SetCollisionBounds(Vector(-15,-15,0),Vector(15,15,60))
	self:Speak("Created")
	local func = function()
		self:PlaySequenceAndWait("Birth_01")
	end
	table.insert(self.StuffToRunInCoroutine,func)
end

function ENT:Speak(quote)
	local tbl = self.Quotes[quote]
	if tbl then
		local snd = tbl[math.random(#tbl)]
		self:EmitSound(snd,100)
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
	self:Speak("Special")
	return true
end

function ENT:Wander()
	if self.IsControlled then return end
	self:StopParticles()
	self:WanderToPosition( (self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * self.WanderDistance), self.WanderAnim[math.random(1,#self.WanderAnim)], self.MoveSpeed )
end

function ENT:CustomBehaviour(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	--print(ent)
	local range = self:GetRangeSquaredTo(ent)
	if range < self.FlameRange^2 then
		return self:Grill(ent)
	else
		self:StopParticles()
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
		self:Speak("FireEffect")
	end
	self:Face(ent)
	local seq = "Attack_01"
	local effect = "flame_halowars_flame"
	--if self.IsUpgraded then seq = "Attack Napalm" effect = "flame_halowars_napalm" end
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
	for k, v in pairs(ents.FindInCone(start,normal,self.FlameRange,math.cos( math.rad( 30 ) ))) do
		if v:Health() > 0 and self:CheckRelationships(v) != "friend" then
			local num = math.random(2,5)
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

function ENT:OnKilled( dmginfo ) -- When killed
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	self.KilledDmgInfo = dmginfo
	self.BehaveThread = nil
	self.DieThread = coroutine.create( function() self:DoKilledAnim() end )
	coroutine.resume( self.DieThread )
end

list.Set( "NPC", "npc_iv04_hw_flood_flamer", {
	Name = "Infected Flamethrower",
	Class = "npc_iv04_hw_flood_flamer",
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

function ENT:DetermineDeath(dmg)
	local seq = "Death_01"
	
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


function ENT:SearchEnemy()
	if GetConVar( "ai_disabled" ):GetInt() == 1 then return end
	local _ents
	if self:GetValue(self.SightType) == 1 then
		_ents = ents.FindInSphere(self:WorldSpaceCenter(), self.SightDistance)
	end
	if self:GetValue(self.SightType) == 2 then
		_ents = ents.FindInCone(self:WorldSpaceCenter(), self:GetForward(), self.SightDistance,  math.cos( math.rad( self.ConeAngle ) ))
	end
	if self:GetValue(self.SightType) == 3 then
		_ents = ents.GetAll()
	end	
	table.Empty(self.temptbl)
	local p = Path( "Follow" )
	for k, v in pairs( _ents ) do
		if ( (v.IsVJBaseSNPC == true or v.CPTBase_NPC == true or v.IsSLVBaseNPC == true or v:GetNWBool( "bZelusSNPC" ) == true) or (v:IsNPC() && v:GetClass() != "npc_bullseye" ) or (v:IsPlayer() and v:Alive()) or (v:IsNextBot() and v != self ) ) and v:Health() > 0 and v:IsOnGround() then
			if self:CheckRelationships(v) == "foe" then
				p:Invalidate()
				p:Compute(self,v:GetPos())
				local dist = p:GetLength()
				if dist < self.LoseEnemyDistance then
					if self.UseLineOfSight then
						if !self:IsLineOfSightClear(v:GetPos()+v:OBBCenter()) then
							continue
						end
					end
					local tbl = {vector=v:GetPos(),ent=v,distance = dist}
					table.insert(self.temptbl,tbl)
					if (v:IsPlayer() and !v:Alive()) then
						table.remove(self.temptbl,table.Count(self.temptbl))
					end
				end
			end
		end
	end
	if IsValid(self:GetClosestEntity(self.temptbl)) then
		local ent = self:GetClosestEntity(self.temptbl)
		if ent:IsPlayer() and (!ent:Alive() or GetConVar("ai_ignoreplayers"):GetInt() == 1) then return false end
		if self.CustomValidateEnemy == true then
			return self:CustomValidate(ent)
		end
		if !IsValid(self.Enemy) then
			self:SetEnemy(ent)
			self:OnHaveEnemy(ent)
		else
			self:SetEnemy(ent)
		end
		return true
	end
end