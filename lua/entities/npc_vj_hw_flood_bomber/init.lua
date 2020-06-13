AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/bomber_01/bomber_01.mdl"}
ENT.StartHealth = 200 
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.HasMeleeAttck = false
ENT.NoChaseAfterCertainRange = true
ENT.NoChaseAfterCertainRange_FarDistance = 1000 
ENT.NoChaseAfterCertainRange_CloseDistance = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
  self:SetCollisionBounds(Vector(60, 60, 150), Vector(-60, -60, 0))
  self.NextEggDrop = CurTime()+20
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
if self.NextEggDrop < CurTime() then
   self.NextEggDrop = CurTime()+20
   self:VJ_ACT_PLAYACTIVITY("vjseq_BombAttack_01",true,2,true)
   VJ_EmitSound(self,{"physics/flesh/flesh_bloody_impact_hard1.wav"},60,math.random(100,100))
   self:DropTheFlood()
end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DropTheFlood()
  local egg = ents.Create("prop_physics")
  egg:SetModel("models/xqm/rails/gumball_1.mdl")
  egg:SetColor(Color(193,163,82,255))
  egg:SetPos(self:GetPos())
  egg:SetOwner(self)
  egg:SetAngles(self:GetAngles())
  egg:AddCallback( "PhysicsCollide", function( ent, data )
  VJ_EmitSound(self,{"physics/flesh/flesh_bloody_break.wav"},60,math.random(100,100))
  egg:Remove()
    -- When life gives you eggs, make sure they aren't flood
  for i = 1, 6 do
    local ent = ents.Create("npc_vj_hw_flood_infection")
    local pos = egg:GetPos()
    if i < 4 then pos = pos+egg:GetRight()*(40*i) end
    if i > 3 then pos = pos+egg:GetForward()*(40*i) end
    ent:SetPos(pos)
    ent:SetAngles(Angle(0,egg:GetAngles().y,0))
    ent:Spawn()
timer.Simple(math.random(120,180),function()

  if IsValid(ent) then ent:TakeDamage(ent:Health(),ent,ent) 
end
end)	
end
end)
    egg:Spawn()
  local prop = egg:GetPhysicsObject()
  if IsValid(prop) then prop:Wake() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)
		self:EmitSound(Sound("vj_gib/gibbing2.wav",250))
		self:EmitSound(Sound("vj_gib/gibbing3.wav",250))
        self:EmitSound(Sound("vj_gib/gibbing1.wav",250))
		
        local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos()+ self:GetUp()*80)
		bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(250)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
	    bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
	    bloodspray:SetScale(1)
	    bloodspray:SetFlags(3)
	    bloodspray:SetColor(1)
	    util.Effect("bloodspray",bloodspray)
	    util.Effect("bloodspray",bloodspray)		
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/