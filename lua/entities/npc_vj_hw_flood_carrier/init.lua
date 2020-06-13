AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hc/halo-wars/flood/infectedcarrier_01/infectedcarrier_01.mdl"} 
ENT.StartHealth = 25 
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_HALO_FLOOD","CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.HasDeathAnimation = true
ENT.DeathAnimationTime = 10
ENT.AnimTbl_Death = {"Death_01","Death_02"} 
ENT.HasMeleeAttack = true 
ENT.MeleeAttackDistance = 85 
ENT.MeleeAttackDamageDistance = 120 
ENT.MeleeAttackDamage = 50
ENT.MeleeAttackDamageType = DMG_POISON 
--custom
ENT.CarrierExplode = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize() 
self:SetCollisionBounds(Vector(20, 20, 70), Vector(-20, -20, 0))	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	self:TakeDamage(9999999,self)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)

       timer.Simple(1.4,function()
		self:EmitSound(Sound("vj_gib/gibbing2.wav",250))
		self:EmitSound(Sound("vj_gib/gibbing3.wav",250))
        self:EmitSound(Sound("vj_gib/gibbing1.wav",250))
		
        local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos()+ self:GetUp()*50)
		bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(150)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
	    bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
	    bloodspray:SetScale(1)
	    bloodspray:SetFlags(3)
	    bloodspray:SetColor(1)
	    util.Effect("bloodspray",bloodspray)
	    util.Effect("bloodspray",bloodspray)
		--util.VJ_SphereDamage(self,self,self:GetPos(),150,45,DMG_POISON,false,true)
		
	local infectionform1 = ents.Create("npc_vj_hw_flood_infection")
	local infectionform2 = ents.Create("npc_vj_hw_flood_infection")
	local infectionform3 = ents.Create("npc_vj_hw_flood_infection")
	local infectionform4 = ents.Create("npc_vj_hw_flood_infection")
	local infectionform5 = ents.Create("npc_vj_hw_flood_infection")
	infectionform1:SetPos(self:GetPos()+self:GetRight()*34)
	infectionform1:SetAngles(self:GetAngles())
	infectionform1:Spawn()
	infectionform1:Activate()
	infectionform2:SetPos(self:GetPos()+self:GetRight()*-34)
	infectionform2:SetAngles(self:GetAngles())
	infectionform2:Spawn()
	infectionform2:Activate()
	infectionform3:SetPos(self:GetPos()+self:GetForward()*34)
	infectionform3:SetAngles(self:GetAngles())
	infectionform3:Spawn()
	infectionform3:Activate()
	infectionform4:SetPos(self:GetPos()+self:GetForward()*-34)
	infectionform4:SetAngles(self:GetAngles())
	infectionform4:Spawn()
	infectionform4:Activate()
	infectionform5:SetPos(self:GetPos())
	infectionform5:SetAngles(self:GetAngles())
	infectionform5:Spawn()
	infectionform5:Activate()	
end)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/