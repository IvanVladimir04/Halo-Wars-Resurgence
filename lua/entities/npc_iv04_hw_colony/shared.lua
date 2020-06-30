AddCSLuaFile()
ENT.Base 			= "npc_iv04_base"
ENT.Models  = {"models/halowars1/flood/colony.mdl"}
--ENT.Models = {"models/rotr_blackbear/compiled 0.68/models/rotr_blackbear/blackbear.mdl"}
ENT.StartHealth = 600
ENT.Relationship = 4
ENT.MeleeDamage = 30
ENT.RunAnim = {ACT_RUN}
ENT.SightType = 1
ENT.BehaviourType = 3
ENT.Faction = "FACTION_FLOOD"
--ENT.MeleeSoundTbl = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.MoveSpeed = 160
ENT.MoveSpeedMultiplier = 1 -- When running, the move speed will be x times faster

ENT.PrintName = "Flood Colony"

ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}

ENT.ToastRange = 900

ENT.FriendlyToPlayers = false

ENT.SightDistance = 5000

ENT.LoseEnemyDistance = 15000

ENT.UseLineOfSight = false

ENT.HealthState = 1 -- 1 = normal, 2 = damaged, 3 = critically damaged

ENT.VJ_EnhancedFlood = true

ENT.SpawnableEntities = {
	"npc_iv04_hw_flood_infection",
	"npc_iv04_hw_flood_infection",
	"npc_iv04_hw_flood_infection",
	"npc_iv04_hw_flood_infection",
	"npc_vj_hw_flood_carrier",
	"npc_vj_hw_flood_carrier"
}

ENT.Squad = {
	["npc_iv04_hw_flood_infection"] = 3,
	["npc_vj_hw_flood_carrier"] = 1
}

ENT.Squads = {
}

function ENT:PreInit()
	for i = 1, GetConVar("hwr_flood_buildings_squads"):GetInt() do
		self.Squads[#self.Squads+1] = {}
	end
	if !self.WasSpawned then
		local goal = self:GetPos()
		local navs = navmesh.Find( goal, 1024, 100, 20 )
		local tbl = navs
		for i = 1, #tbl do
			local nv = tbl[i]
			local x = nv:GetSizeX()
			local y = nv:GetSizeY()
			if ( !UsedNavs[nv:GetID()] or !IsValid(UsedNavs[nv:GetID()]) ) and x > 200 and y > 200 then
				UsedNavs[nv:GetID()] = self
				break
			end
		end
	end
end

function ENT:OnInitialize()
	--self.UpgradeLevel = 1
	--self:SetBloodColor(BLOOD_COLOR_MECH)
	--if !self.Color then
	--	self:SetColor(Color(155,166,90,255))
	--end
	self.DoFade = GetConVar("hwr_flood_buildings_regrow"):GetInt() == 0
	self:SetCollisionBounds(Vector(-100,-100,0),Vector(100,100,120))
end

function ENT:StartMovingAnimations( no1, no2 )

end

function ENT:MoveToPos(pos)
	return "NO!"
end

function ENT:CanSpawn()
	if self.HasSpawned then return false end
	local spawn = false
	local sq = self.Squads[1]
	for i = 1, #self.Squads do
		local tbl = self.Squads[i]
		for e = 1, #tbl do
			if IsValid(tbl[e]) then
				sq = self.Squads[i+1]
				break
			end
		end
		if sq == tbl then
			spawn = true
			break
		end
	end
	return spawn, sq
end

function ENT:SpawnSquad(sq)
	local r = self.SpawnableEntities[math.random(#self.SpawnableEntities)]
	local tims = self.Squad[r]
	local att = self:GetAttachment(1)
	local p = att.Pos
	local ag = att.Ang
	for i = 1, tims do
		local ent = ents.Create(r)
		ent:SetPos(p+ag:Forward()*(80*i))
		ent:SetAngles(ag)
		ent:Spawn()
		ent:SetOwner(self)
		--self:DeleteOnRemove(ent)
		self:MoveEnt(ent)
		sq[#sq+1] = ent
	end
end

function ENT:CommandEnt(ent,pos)
	if !IsValid(ent) then return end
	if !pos then return end
	ent.BeingCommanded = true
	if ent:IsNPC() and ent.IsVJBaseSNPC then
		ent:SetLastPosition(pos)
		ent:VJ_TASK_GOTO_LASTPOS()
		timer.Simple( math.random(5,10), function()
			if IsValid(ent) then 
				ent.BeingCommanded = false
			end
		end )
	elseif ent:IsNextBot() and ent.IV04NextBot then
		local func = function()
			ent:StartMovingAnimations(ent.RunAnim[1],ent.MoveSpeed*ent.MoveSpeedMultiplier)
			ent:MoveToPos(pos)
			ent.BeingCommanded = false
		end
		table.insert(ent.StuffToRunInCoroutine,func)
		ent:ResetAI()
	end
end

function ENT:MoveEnt(ent)
	if !IsValid(ent) then return end
	if ent:IsNPC() and ent.IsVJBaseSNPC then
		ent:SetLastPosition(ent:GetPos()+ent:GetForward()*200)
		ent:VJ_TASK_GOTO_LASTPOS()
	elseif ent:IsNextBot() and ent.IV04NextBot then
		local func = function()
			ent:StartMovingAnimations(ent.RunAnim[1],ent.MoveSpeed*ent.MoveSpeedMultiplier)
			ent:MoveToPos(ent:GetPos()+ent:GetForward()*math.random(200)+ent:GetRight()*math.random(-100,100))
		end
		table.insert(ent.StuffToRunInCoroutine,func)
		ent:ResetAI()
	end
end

ENT.Delay = 15

ENT.IsFloodBuilding = true

if SERVER then

	function ENT:Think()
	
		if !self.Scanned then
			self.Scanned = true
			self:SearchEnemy()
			timer.Simple( math.random(15,30), function()
				if IsValid(self) then
					self.Scanned = false
				end
			end )
		end
		
	end
	
end

ENT.DetectedNavs = {}

ENT.CreateDelayMin = 60

ENT.CreateDelayMax = 180

ENT.PossibleBuildings = {
	"npc_iv04_hw_den",
	"npc_iv04_hw_den",
	"npc_iv04_hw_nest",
	"npc_iv04_hw_nest",
	"npc_iv04_hw_colony",
	--"npc_iv04_hw_vent",
	"npc_vj_hw_flood_root",
	"npc_vj_hw_flood_root",
	"npc_vj_hw_flood_root",
	"npc_vj_hw_flood_root"
}

function ENT:DoBuildingAndStuff()
	--print("this is not a gamer moment")
	local r1 = math.random(1,-1)
	--if r1 == 2 then r1 = -1 end
	local r2 = math.random(1,-1)
	if r2 == 0 and r1 == 0 then r2 = 1 end
	local rr1 = math.random(800,1600)
	local rr2 = math.random(800,1600)
	if #self.DetectedNavs > 0 then
		local tbl = self.DetectedNavs
		local nav
		for i = 1, #tbl do
			local nv = tbl[i]
			local x = nv:GetSizeX()
			local y = nv:GetSizeY()
			local p = nv:GetCenter()
			local xy = p.x+p.y
			local xy2 = self:GetPos().x+self:GetPos().y
			local dif = math.abs( xy-xy2 )
			if ( !UsedNavs[nv:GetID()] or !IsValid(UsedNavs[nv:GetID()]) ) and x+y > 400 and dif > 800 then
				local clss = self.PossibleBuildings[math.random(#self.PossibleBuildings)]
				if clss == "npc_iv04_hw_colony" and x < 300 and y < 300 and dif < 1000 then
					clss = "npc_vj_hw_flood_root"
				end
				local ent = ents.Create(clss)
				ent:SetPos( p )
				ent:SetAngles(Angle(0,math.random(360),0))
				ent:Spawn()
				ent.WasSpawned = true
				UsedNavs[nv:GetID()] = ent
				break
			end
		end
		local goal = self:GetPos()+Vector(r1*rr1,r2*rr2,0)
		local navs = navmesh.Find( goal, 1024, 100, 20 )
		self.DetectedNavs = navs
	else
		local goal = self:GetPos()+Vector(r1*rr1,r2*rr2,0)
		local navs = navmesh.Find( goal, 1024, 100, 20 )
		self.DetectedNavs = navs
	end
end

function ENT:Wander()
	local can, squad = self:CanSpawn()
	if can then
		self.HasSpawned = true
		timer.Simple( self.Delay, function()
			if IsValid(self) then
				self.HasSpawned = false
			end
		end )
		self:SpawnSquad(squad)
	end
	if !self.HasCreated and GetConVar( "hwr_flood_buildings_limit" ):GetInt() > #FloodBuildingsTbl then
		self.HasCreated = true
		timer.Simple( 10, function() --math.random(self.CreateDelayMin,self.CreateDelayMax), function()
			if IsValid(self) then
				self.HasCreated = false
			end
		end )
		self:DoBuildingAndStuff()
	end
	local tbl = FloodUnits
	local con = table.Count(tbl)
	if con > 0 then
		if self:HasNoTargets() then
			local c = #self.Scouts
			if c < 1 then
				for k, v in pairs(tbl) do
					local en = k
					if IsValid(en) then
						if !en.BeingCommanded then
							local c = #self.Scouts
							if c == 0 then
								self.Scouts[c+1] = en
							end
						end
					else
						tbl[i] = nil
					end
				end
			end
			for i = 1, #self.Scouts do
				local n = self.Scouts[i]
				local goal = self:GetPos()+Vector(math.random(1,-1)*1600,math.random(1,-1)*1600,0)
				local navs = navmesh.Find( goal, 1024, 100, 20 )
				self.DetectedNavs = navs
				local nav = navs[math.random(#navs)]
				if nav then pos = nav:GetRandomPoint() end
				self:CommandEnt(n,pos)
			end
		else
			local targetss = self.temptbl
			local targets = {}
			for i = 1, #targetss do
				if targetss[i] then
					local t = targetss[i].ent
					if IsValid(t) and t:Health() > 0 then
						targets[#targets+1] = t
					else
						targets[i] = nil
					end
				end
			end
			local r = math.random(#targets)
			local target = targets[r]
			for k, v in pairs(tbl) do
				local en = k
				if IsValid(en) then
					if !en.BeingCommanded then
						en.BeingCommanded = true
						en:SetEnemy(target)
						timer.Simple( math.random(15,20), function()
							if IsValid(en) then
								en.BeingCommanded = false
							end
						end )
					end
				end
			end
		end
	end
	self:PlaySequenceAndWait("Idle"..self.HealthState.."")
end

function ENT:OnInjured(dmg)
	if self:CheckRelationships(dmg:GetAttacker()) == "friend" then
		dmg:ScaleDamage(0)
		return
	end
	local ht = self:Health()-dmg:GetDamage()
	if ht > 0 then
		if ht < self.StartHealth*0.7 and self.HealthState == 1 then
			local func = function()
				self:PlaySequenceAndWait("Shrink1")
			end
			self.HealthState = 2
			table.insert(self.StuffToRunInCoroutine,func)
			self:ResetAI()
		elseif ht < self.StartHealth*0.3 and self.HealthState == 2 then
			local func = function()
				self:PlaySequenceAndWait("Shrink2")
			end
			self.HealthState = 3
			table.insert(self.StuffToRunInCoroutine,func)
			self:ResetAI()
		end
	end
end

ENT.Scouts = {}

function ENT:HasNoTargets()
	local tbl = self.temptbl
	local has = false
	for id, v in SortedPairs( tbl ) do
		if istable(v) then
			local ent = v.ent
			if IsValid(ent) then
				if ent:Health() < 1 then
					table.remove(self.temptbl,id)
				end
				if IsValid(ent) then
					has = true
					if ent != self.Enemy then
						self:SetEnemy(ent)
						break
					end
				end
			else
				table.remove(self.temptbl,id)
			end
		end
	end
	return !has
end

function ENT:CustomBehaviour(ent)
	return self:Wander()
	-- brain.exe has stopped working
end

ENT.IsUpgraded = false

function ENT:Face(ent)
	if !IsValid(ent) then return end
	local ang = (ent:GetPos()-self:GetPos()):GetNormalized():Angle()
	self:SetAngles(Angle(self:GetAngles().p,ang.y,self:GetAngles().r))
end

function ENT:ChaseEnt(ent)
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
	local id, len = self:LookupSequence("Shrink3")
	corpse:SetSequence(id)
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
	timer.Simple(len-0.01, function()
		if IsValid(corpse) then
			corpse:SetPlaybackRate(0)
		end
	end )
	--local snd = table.Random(self.SoundDeath)
	--corpse:EmitSound(snd,100)
	local en = corpse
	if !self.DoFade then
		--local tim = math.random(120,180)
		local tim = math.random(240,300)
		local fr = tim/3
		local imbackbitch
		local ht = self.StartHealth
		timer.Simple( fr, function()
			if IsValid(en) then
				imbackbitch = ents.Create("npc_iv04_hw_colony")
				imbackbitch:SetPos(en:GetPos())
				imbackbitch:SetModel(en:GetModel())
				imbackbitch:SetAngles(en:GetAngles())
				imbackbitch:Spawn()
				undo.ReplaceEntity(en,imbackbitch)
				en:Remove()
				imbackbitch.HealthState = 3
				local func = function()
					imbackbitch:SetHealth(ht/3)
					imbackbitch:PlaySequenceAndWait("Growth3")
				end
				table.insert(imbackbitch.StuffToRunInCoroutine,func)
				imbackbitch:ResetAI()
			end
		end )
		timer.Simple( fr*2, function()
			if IsValid(imbackbitch) then
				imbackbitch.HealthState = 2
				imbackbitch:SetHealth(ht*0.66)
				local func = function()
					imbackbitch:PlaySequenceAndWait("Growth2")
				end
				table.insert(imbackbitch.StuffToRunInCoroutine,func)
				imbackbitch:ResetAI()
			end
		end )
		timer.Simple( fr*3, function()
			if IsValid(imbackbitch) then
				imbackbitch.HealthState = 1
				imbackbitch:SetHealth(ht)
				local func = function()
					imbackbitch:PlaySequenceAndWait("Growth1")
				end
				table.insert(imbackbitch.StuffToRunInCoroutine,func)
				imbackbitch:ResetAI()
			end
		end )
	else
		if GetConVar( "ai_serverragdolls" ):GetInt() == 0 then
			timer.Simple( 30, function()
				if IsValid(corpse) then
					corpse:Remove()
				end
			end)
		end
	end
	undo.ReplaceEntity( self, corpse )
	self:Remove()
	--[[timer.Simple( 15, function()
		if IsValid(corpse) then
			corpse:SetColor(Color(127+math.random(100,-100),95+math.random(100,-100),0,255))
		end
	end)]]
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

list.Set( "NPC", "npc_iv04_hw_colony", {
	Name = "Flood Colony",
	Class = "npc_iv04_hw_colony",
	Category = "Halo Wars Resurgence"
} )