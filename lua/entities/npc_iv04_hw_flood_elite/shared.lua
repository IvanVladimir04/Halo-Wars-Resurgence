AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.StartHealth = 100
ENT.Models  = {"models/hc/halo-wars/flood/infectedelite_01/infectedelite_01.mdl"}
ENT.Relationship = 4
ENT.MeleeDamage = 20
--ENT.RunAnim = {ACT_WALK}
ENT.SightType = 1
ENT.BehaviourType = 1
ENT.Faction = "FACTION_FLOOD"
--ENT.MeleeSound = { "doom_3/zombie2/zombie_attack1.ogg", "doom_3/zombie2/zombie_attack2.ogg", "doom_3/zombie2/zombie_attack3.ogg" }
ENT.MoveSpeed = 250
ENT.MoveSpeedMultiplier = 1 -- When running, the move speed will be x times faster
ENT.PrintName = "Infected Elite"

ENT.MeleeRange = 100

ENT.IdleSoundDelay = 8

ENT.NPSound = 0

ENT.NISound = 0

ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}

ENT.UseLineOfSight = false

ENT.SearchJustAsSpawned = true

ENT.VJ_EnhancedFlood = true

ENT.LoseEnemyDistance = 15000

ENT.Voices = {
	["Created"] = {
		"halowars1/characters/The Flood/Flood Mutate.mp3",
		"halowars1/characters/The Flood/flood mutate 2.mp3",
		"halowars1/characters/The Flood/flood mutate 3.mp3",
	},
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
	self:SetCollisionBounds(Vector(20,20,80),Vector(-20,-20,0))
	self:Speak("Created")
	local func = function()
		self:PlaySequenceAndWait("Birth_01")
	end
	table.insert(self.StuffToRunInCoroutine,func)
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
	timer.Simple( len*0.6, function()
		if IsValid(self) then
			self:DoMeleeDamage()
		end
	end )
	self:PlaySequenceAndWait( id )
end

ENT.MeleeCheckDelay = 0.5

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
	path:Compute(self,ent:GetPos())
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
			local dist = self:GetPos():DistToSqr(ent:NearestPoint(self:GetPos()))
			if dist > self.LoseEnemyDistance^2 then 
				self:OnLoseEnemy()
				self:SetEnemy(nil)
				self.State = "Idle"
				return "Lost Enemy"
			end
			if self:IsInMeleeRange(dist) then
				return self:Melee(self.MeleeDamage)
			end
		end
		if ent:IsPlayer() then
			if GetConVar( "ai_ignoreplayers" ):GetInt() == 1 or !ent:Alive() then	
				self:SetEnemy(nil)
				return "Ignore players on"
			end
		end
		if path:GetAge() > self.RebuildPathTime then
			path:Compute(self,ent:GetPos())
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
	deadguy:SetPos(self:GetPos())
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

list.Set( "NPC", "npc_iv04_hw_flood_elite", {
	Name = "Infected Elite",
	Class = "npc_iv04_hw_flood_elite",
	Category = "Halo Wars Resurgence"
} )