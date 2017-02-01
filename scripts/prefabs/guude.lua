
local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {
	"guudebee"
}

-- Custom starting items
local start_inv = {
}

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when reviving from ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "guude_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "guude_speed_mod")
end


-- When loading or spawning the character
local function onload(inst, data)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
	
	if data then
		if data.conifer ~= nil and inst.conifer == nil then
			local conifer = SpawnSaveRecord(data.conifer)
			if conifer ~= nil then
				conifer:LinkToPlayer(inst)
			end
		end
		if data.hasconifer then
			inst.hasconifer = data.hasconifer
		end
	end
end

local function onsave(inst, data)
    if inst.conifer ~= nil and inst.conifer.components.health and inst.conifer.components.health:IsDead() == false then
        data.conifer = inst.conifer:GetSaveRecord()
    end
	if inst.hasconifer then
		data.hasconifer = inst.hasconifer
	end
end

-- Guude suffers a sanity penalty for eating food not cooked in a crockpot, he gets a small bonus from prepared food
local function oneat(inst, food)
	local prepared = require("preparedfoods")
	if (food and food.components.edible) and (
		food.prefab == "berries" or 
		food.prefab == "berries_cooked" or
		food.prefab == "acorn_cooked" or
		food.prefab == "cactus_meat" or
		food.prefab == "cactus_meat_cooked" or
		food.prefab == "cactus_flower" or
		food.prefab == "carrot" or
		food.prefab == "carrot_cooked" or
		food.prefab == "cave_banana" or
		food.prefab == "cave_banana_cooked" or
		food.prefab == "corn" or
		food.prefab == "corn_cooked" or
		food.prefab == "dragonfruit" or
		food.prefab == "dragonfruit_cooked" or
		food.prefab == "drumstick" or
		food.prefab == "drumstick_cooked" or
		food.prefab == "bird_egg" or
		food.prefab == "bird_egg_cooked" or
		food.prefab == "eggplant" or
		food.prefab == "eggplant_cooked" or
		food.prefab == "fish" or
		food.prefab == "fish_cooked" or
		food.prefab == "foliage" or
		food.prefab == "petals" or
		food.prefab == "froglegs" or
		food.prefab == "froglegs_cooked" or
		food.prefab == "honey" or
		food.prefab == "berries_juicy" or
		food.prefab == "berries_juicy_cooked" or
		food.prefab == "meat" or
		food.prefab == "cookedmeat" or
		food.prefab == "meat_dried" or
		food.prefab == "smallmeat" or
		food.prefab == "cookedsmallmeat" or
		food.prefab == "smallmeat_dried" or
		food.prefab == "pomegranate" or
		food.prefab == "pomegranate_cooked" or
		food.prefab == "royal_jelly" or
		food.prefab == "pumpkin" or
		food.prefab == "pumpkin_cooked" or
		food.prefab == "seeds" or
		food.prefab == "seeds_cooked" or
		food.prefab == "carrot_seeds" or
		food.prefab == "corn_seeds" or
		food.prefab == "dragonfruit_seeds" or
		food.prefab == "durian_seeds" or
		food.prefab == "eggplant_seeds" or
		food.prefab == "pomegranate_seeds")
	then
		inst.components.sanity:DoDelta(-2)
	elseif prepared[food.prefab] ~= nil then
		inst.components.talker:Say("Delicious!", 2.5, true)
		inst.components.sanity:DoDelta(2)
	end
	
	if (food and food.components.edible) and (food.prefab == "tallbirdegg_cooked") then
		inst.components.talker:Say("Almost as good as quail eggs!", 2.5, true)
		inst.components.sanity:DoDelta(5)
		inst.components.health:DoDelta(5)
	end
end


-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "guude.tex" )
	
	
end

local function ondespawn(inst)
	if inst.hasconifer ~= nil then
        inst.conifer.components.lootdropper:SetLoot(nil)
        inst.conifer.components.health:SetInvincible(true)
		inst.conifer.AnimState:PlayAnimation("action")
        inst.conifer:DoTaskInTime(2, inst.conifer.Remove)
    end
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	local player = inst;
	-- choose which sounds this character will play
	player.soundsname = "wilson"
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- Set up net_variable that is used to display bee counts in a widget
	player.netBeeTotal = net_ushortint(player.GUID, "beeTotal", "guude_bee_update")
	player.netBeeTotal:set(0)
	
	-- Stats	
	player.components.health:SetMaxHealth(175)
	player.components.hunger:SetMax(175)
	player.components.sanity:SetMax(100)

    player.components.combat.damagemultiplier = .75
	
	player.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	inst.components.eater:SetOnEatFn(oneat)
	
	player:AddComponent("childspawner")
	player.components.childspawner:SetMaxChildren(20)
	player.components.childspawner.childname="guudebee"
	--player.components.childspawner:SetRareChild("guudebee", .1) -- TODO: Use this for Bee Guards
	player.components.childspawner.spawnperiod=1
	player.components.childspawner.regening=true
	player.components.childspawner:SetRegenPeriod(.1,0)
	player.components.childspawner.regenvariance=.01
	player.components.childspawner.spawnoffscreen=false
	player.components.childspawner:SetMaxEmergencyChildren(0)
		
	player.components.childspawner:SetSpawnedFn(function(inst, child)
		if not player:HasTag("playerghost") then
			child.components.follower.leader = inst
		end
	end)

	player:DoPeriodicTask(1, function(inst)
		inst.netBeeTotal:set(inst.components.childspawner.childreninside)
	end)
	
	player.disablespawning=true
	player.components.childspawner:StopSpawning()
	
	-- Prevent spawning constantly to keep retributive spawns from occuring mid-combat (no free bees)
	player:DoPeriodicTask(.1, function(inst)
		inst.components.childspawner:StopSpawning()
	end)
	
	-- When sanity is less than 30 you have a .25% chance to drop your weapon when using it
	player:ListenForEvent("onattackother", function(inst, data)
		if player.components.sanity.current <= 30 and math.random() <= .025 then
			player.components.talker:Say("Whoops...", 2.5, true)
			local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS);
			player.components.inventory:DropItem(weapon)
		end
	end)
	
	local SpawnConiferFn = function(world, player)
		if player then
			player:DoTaskInTime(1,function(player)
				if player.prefab == "guude" and player.hasconifer ~= true then
					player.hasconifer = true
					local conifer = SpawnPrefab("conifer")
					local x,y,z = player.Transform:GetWorldPosition()
					conifer.Transform:SetPosition(x,y,z)
					conifer:LinkToPlayer(player)					
				end
			end)
		end
	end
		
	if TheWorld:HasTag("coniferspawnlistener") ~= true then
		TheWorld:ListenForEvent("ms_playerjoined", SpawnConiferFn) 
		TheWorld:AddTag("coniferspawnlistener")
	end
	
	player:DoPeriodicTask(1, function(inst)
		if not inst:HasTag("playerghost") then
			if inst.components.sanity.current <= 60 and inst.components.moisture:GetMoisture() < 30 and not TheWorld.state.israining then
				inst.components.moisture:DoDelta(.2+inst.components.moisture:GetDryingRate(0))
				
				if not inst:HasTag("nervous_sweating_1") then
					inst:AddTag("nervous_sweating_1")
					
					if not inst:HasTag("sweat_muted") then
						inst.components.talker:Say("I'm getting nervous...", 2.5, true)
						inst:AddTag("sweat_muted")
						inst:DoTaskInTime(10, function(inst)
							inst:RemoveTag("sweat_muted")
						end)
					end
				end
			elseif inst.components.sanity.current <= 25 and inst.components.moisture:GetMoisture() < 65 and not TheWorld.state.israining then
				inst.components.moisture:DoDelta(.3+inst.components.moisture:GetDryingRate(0))
				
				if not inst:HasTag("nervous_sweating_2") then
					inst:AddTag("nervous_sweating_2")
					
					if not inst:HasTag("sweat_muted") then
						inst.components.talker:Say("I'm sweating so much right now!", 2.5, true)
						inst:AddTag("sweat_muted")
						inst:DoTaskInTime(10, function(inst)
							inst:RemoveTag("sweat_muted")
						end)
					end
				end
			elseif inst:HasTag("nervous_sweating_1") and inst.components.sanity.current >= 65 then
				inst:RemoveTag("nervous_sweating_1")
			elseif inst:HasTag("nervous_sweating_2") and inst.components.sanity.current >= 30 then
				inst:RemoveTag("nervous_sweating_2")
			end
		end
	end)
	
	player.OnLoad = onload
    player.OnNewSpawn = onload
	player.OnDespawn = ondespawn
	player.OnSave = onsave
	
end

return MakePlayerCharacter("guude", prefabs, assets, common_postinit, master_postinit, start_inv)
