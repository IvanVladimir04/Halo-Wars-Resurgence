AddCSLuaFile()
ENT.Base 			= "npc_iv04_hw_marine"
ENT.PrintName = "Infected Marine"
ENT.Models  = {"models/hc/halo-wars/flood/infectedmarine_01/infectedmarine_01.mdl"}
ENT.StartHealth = 40

ENT.Faction = "FACTION_FLOOD"

ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}

ENT.IsUpgraded = true

ENT.FriendlyToPlayers = false

ENT.LoseEnemyDistance = 15000

function ENT:PreInit()
	self.Quotes = {
		["Created"] = {
			"halowars1/characters/The Flood/Flood Mutate.mp3",
			"halowars1/characters/The Flood/flood mutate 2.mp3",
			"halowars1/characters/The Flood/flood mutate 3.mp3",
		},
		["FireEffectSmall"] = {
			"halowars1/characters/Marine/assault_rifle_fire short.mp3"
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

function ENT:Shoot(ent)
	ent = ent or self.Enemy
	if !IsValid(ent) then return end
	if !self.Shooting then
		self.Shooting = true
		--self:PlaySequenceAndWait("Prefire")
	end
	self:Face(ent)
	local seq = "Attack_01"
	--local effect = "flame_halowars_flame"
	--if self.IsUpgraded then seq = "Attack Napalm" effect = "flame_halowars_napalm" end
	--ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )
	local id, len = self:LookupSequence(seq)
	timer.Simple( 0.2, function()
		if IsValid(self) then
			self:Speak("FireEffectSmall")
			self:FireAt()
		end
	end )
	self:PlaySequenceAndWait(id)
	--[[if !IsValid(self.Enemy) then
		self:StopParticles()
	end]]
end

function ENT:DetermineDeath(dmg)
	local seq = "Death_01"
	
	return seq
end

list.Set( "NPC", "npc_iv04_hw_flood_marine", {
	Name = "Infected Marine",
	Class = "npc_iv04_hw_flood_marine",
	Category = "Halo Wars Resurgence"
} )