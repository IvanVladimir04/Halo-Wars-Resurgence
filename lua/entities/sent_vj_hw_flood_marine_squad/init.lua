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
	{EntityName = "NPC1",SpawnPosition = {vForward=50,vRight=0,vUp=0},Entities = {"npc_iv04_hw_flood_marine"}},
	{EntityName = "NPC2",SpawnPosition = {vForward=0,vRight=50,vUp=0},Entities = {"npc_iv04_hw_flood_marine"}},
	{EntityName = "NPC3",SpawnPosition = {vForward=100,vRight=50,vUp=0},Entities = {"npc_iv04_hw_flood_marine"}},
	{EntityName = "NPC4",SpawnPosition = {vForward=100,vRight=-50,vUp=0},Entities = {"npc_iv04_hw_flood_marine"}},
	{EntityName = "NPC5",SpawnPosition = {vForward=0,vRight=-50,vUp=0},Entities = {"npc_iv04_hw_flood_marine"}},
}
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted, 
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/