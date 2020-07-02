AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted, 
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.SingleSpawner = true
ENT.Model = {"models/props_junk/popcan01a.mdl"} 
ENT.EntitiesToSpawn = {
	{EntityName = "NPC2",SpawnPosition = {vForward=0,vRight=50,vUp=0},Entities = {"npc_iv04_hw_flood_flamer"}},
	{EntityName = "NPC5",SpawnPosition = {vForward=0,vRight=-50,vUp=0},Entities = {"npc_iv04_hw_flood_flamer"}},
}
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted, 
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/