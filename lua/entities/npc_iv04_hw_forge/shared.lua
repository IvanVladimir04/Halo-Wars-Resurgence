AddCSLuaFile()
ENT.Base 			= "npc_iv04_hw_marine"
ENT.PrintName = "Sergeant Forge"
ENT.Models  = {"models/halowars1/unsc/forge.mdl"}
ENT.StartHealth = 120

ENT.IsUpgraded = true

function ENT:PreInit()
	self.Quotes["SpecialRocket"] = {
		"halowars1/characters/Sergeant Forge/forge_ anytime.mp3",
		"halowars1/characters/Sergeant Forge/forge_ hog_smash em.mp3",
		"halowars1/characters/Sergeant Forge/forge_ firing.ogg"
	}
	self.Quotes["Created"] = {
		"halowars1/characters/Sergeant Forge/forge_hog ready to roll.mp3",
		"halowars1/characters/Sergeant Forge/forge_ lets roll.mp3"
	}
	self.Quotes["Selected"] = {
		"halowars1/characters/Sergeant Forge/forge_ what you need.mp3",
		"halowars1/characters/Sergeant Forge/forge_ where to.mp3",
		"halowars1/characters/Sergeant Forge/forge_ yeah (question).mp3",
		"halowars1/characters/Sergeant Forge/forge_ orders (question).mp3",
		"halowars1/characters/Sergeant Forge/forge_ ready.mp3",
		"halowars1/characters/Sergeant Forge/forge_ yes (question).mp3"
	}
	self.Quotes["Attack"] = {
		"halowars1/characters/Sergeant Forge/forge_ blast em.mp3",
		"halowars1/characters/Sergeant Forge/forge_ attacking.mp3",
		"halowars1/characters/Sergeant Forge/forge_ going in.mp3",
		"halowars1/characters/Sergeant Forge/forge_ hog_smash em.mp3",
		"halowars1/characters/Sergeant Forge/forge_ rip em up.mp3",
		"halowars1/characters/Sergeant Forge/forge_ take em down.mp3",
		"halowars1/characters/Sergeant Forge/forge_hog knock em down.mp3",
		"halowars1/characters/Sergeant Forge/forge_quick fire.mp3",
		"halowars1/characters/Sergeant Forge/forge_ on the target.mp3",
		"halowars1/characters/Sergeant Forge/forge_ ill get them.mp3",
		"halowars1/characters/Sergeant Forge/forge_ ill get them.mp3",
		"halowars1/characters/Sergeant Forge/forge_ firing.ogg"
	}
	self.Quotes["Move"] = {
		"halowars1/characters/Sergeant Forge/forgee_ you got it.mp3",
		"halowars1/characters/Sergeant Forge/forge_ on the move.mp3",
		"halowars1/characters/Sergeant Forge/forge_ moving out.mp3",
		"halowars1/characters/Sergeant Forge/forge_ lets roll.mp3",
		"halowars1/characters/Sergeant Forge/forge_ lets move.mp3",
		"halowars1/characters/Sergeant Forge/forge_ lets go 3.mp3",
		"halowars1/characters/Sergeant Forge/forge_ lets go 2.mp3",
		"halowars1/characters/Sergeant Forge/forge_ im on it.mp3",
		"halowars1/characters/Sergeant Forge/forge_ HANG ON MARINE WE ARE ON OUR WAY.mp3",
		"halowars1/characters/Sergeant Forge/forge_ ill do it.mp3",
		"halowars1/characters/Sergeant Forge/forge_ im going.mp3"
	}
	self.Quotes["Death"] = {
		"halowars1/characters/odst/odst death noise.mp3"
	}
end

function ENT:OnInitialize()
	if !self.Color then
		self:SetColor(Color(255,255,255,255))
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
	local seq = "Attack Assault Rifle "..math.random(1,2)..""
	--local effect = "flame_halowars_flame"
	--if self.IsUpgraded then seq = "Attack Napalm" effect = "flame_halowars_napalm" end
	--ParticleEffectAttach( effect, PATTACH_POINT_FOLLOW, self, 1 )
	local id, len = self:LookupSequence(seq)
	timer.Simple( 0.2, function()
		if IsValid(self) then
			self:Speak("FireEffectShotgun")
			self:FireAt()
		end
	end )
	timer.Simple( 0.8, function()
		if IsValid(self) then
			self:Speak("CockShotgun")
		end
	end )
	self:PlaySequenceAndWait(id)
	if math.random(1,2) == 1 then
		self:Speak("ReloadShotgun")
		self:PlaySequenceAndWait("Idle Combat 3")
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
	bullet.Num = 10
	bullet.Src = start
	bullet.Dir = self:GetAimVector()
	bullet.Spread =  Vector( 0.25, 0.25 )
	bullet.Tracer = 1
	bullet.Force = 1
	--bullet.TracerName = self.TracerName
	bullet.Damage = 4
	bullet.Callback = function(attacker, tr, info) -- Small function to set it as we are who caused the damage

	end
	self:FireBullets(bullet)
end


list.Set( "NPC", "npc_iv04_hw_forge", {
	Name = "Forge",
	Class = "npc_iv04_hw_forge",
	Category = "Halo Wars Resurgence"
} )