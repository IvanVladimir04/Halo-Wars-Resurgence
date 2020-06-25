AddCSLuaFile()
ENT.Base 			= "npc_iv04_hw_marine"
ENT.PrintName = "ODST"
ENT.Models  = {"models/halowars1/unsc/odst.mdl"}
ENT.StartHealth = 75

ENT.IsUpgraded = true

function ENT:PreInit()
	self.Quotes["SpecialRocket"] = {
		"halowars1/characters/odst/ODST_ rocket in the air.mp3",
		"halowars1/characters/odst/odst_ rocket luacnhed.mp3",
		"halowars1/characters/odst/odst_ rockets away.mp3"
	}
	self.Quotes["Created"] = {
		"halowars1/characters/odst/odst_ droping in.mp3",
		"halowars1/characters/odst/odst_ on site.mp3"
	}
	self.Quotes["Selected"] = {
		"halowars1/characters/odst/odst_droped_and_ready.mp3",
		"halowars1/characters/odst/odst_give_order.mp3",
		"halowars1/characters/odst/odst_locked_and_loaded.mp3",
		"halowars1/characters/odst/odst_on_the_ground.mp3",
		"halowars1/characters/odst/odst_orders_(question).mp3",
		"halowars1/characters/odst/odst_ready_to_fight.mp3",
		"halowars1/characters/odst/odst_ready_to_rock.mp3",
		"halowars1/characters/odst/odst_ready_to_rock_(excited).mp3",
		"halowars1/characters/odst/odst_standing_by.mp3",
		"halowars1/characters/odst/odst_wating_for_orders.mp3",
		"halowars1/characters/odst/odst_where_to.mp3",
		"halowars1/characters/odst/odst_yes_(monotone).mp3",
		"halowars1/characters/odst/odst_where_to.mp3"
	}
	self.Quotes["Attack"] = {
		"halowars1/characters/odst/odst_engageing.mp3",
		"halowars1/characters/odst/odst_good_as_dead.mp3",
		"halowars1/characters/odst/odst_got_it.mp3",
		"halowars1/characters/odst/odst_I_see_them.mp3",
		"halowars1/characters/odst/odst_im_on_them.mp3",
		"halowars1/characters/odst/odst_makenoise.mp3",
		"halowars1/characters/odst/odst_ooh_rah.mp3",
		"halowars1/characters/odst/odst_were_going_in.mp3",
		"halowars1/characters/odst/odst_yes_sir.mp3",
		"halowars1/characters/odst/odst_ firing.mp3"
	}
	self.Quotes["Move"] = {
		"halowars1/characters/odst/odst_moving.mp3",
		"halowars1/characters/odst/odst_moving_up.mp3",
		"halowars1/characters/odst/odst_moving_out.mp3",
		"halowars1/characters/odst/odst_roger.mp3",
		"halowars1/characters/odst/odst_roger_that.mp3",
		"halowars1/characters/odst/odst_waypoint_recived.mp3",
		"halowars1/characters/odst/odst_were_going.mp3"
	}
	self.Quotes["Death"] = {
		"halowars1/characters/odst/odst death noise.mp3"
	}
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
			if i == 1 then
				self:Speak("FireShotgun")
			end
			self:FireAt()
		end
	end )
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

list.Set( "NPC", "npc_iv04_hw_odst", {
	Name = "ODST",
	Class = "npc_iv04_hw_odst",
	Category = "Halo Wars Resurgence"
} )