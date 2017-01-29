local brain = require("brains/coniferbrain")

local CONIFER_RUN_SPEED = 5
local CONIFER_FLEE_SPEED = 20

local assets =
{
	Asset("ANIM", "anim/catcoon_build.zip"),
	Asset("ANIM", "anim/catcoon_basic.zip"),
	Asset("ANIM", "anim/catcoon_actions.zip"),
	Asset("SOUND", "sound/catcoon.fsb"),
}

local prefabs =
{
	"mole",
	"rabbit",
	"flint",
	"tumbleweed",
	"cutgrass",
	"twigs",
	"berries",
	"goldnugget",
	"smallmeat",
	"silk",
	"coontail",
	"rocks",
	"bee",
	"mosquito",
	"cutreeds",
	"tentaclespots",
	"beefalowool",
	"feather_robin",
	"feather_robin_winter",
	"feather_canary",
	"feather_crow",
	"boneshard",
	"red_cap",
	"blue_cap",
	"green_cap",
	"carrot_seeds",
	"corn_seeds",
	"pumpkin_seeds",
	"eggplant_seeds",
	"durian_seeds",
	"pomegranate_seeds",
	"dragonfruit_seeds",
	"watermelon_seeds",
	"butterfly",
	"robin",
	"robin_winter",
	"canary",
	"crow",
	"fish",
	"transistor",
	"froglegs",
	"batwing",
	"petals",
	"petals_evil",
	"ash",
	"acorn",
	"pinecone",
	"ice",
}

local neutralGiftPrefabs =
{
	{ --tier 1
		"wetgoop",
	},
	{ --tier 2
		"spoiled_food",
		"wetgoop",
	},
	{ --tier 3
		"cutgrass",
		"spoiled_food",
	},
	{ --tier 4
		"cutgrass",
		"spoiled_food",
	},
	{ --tier 5
		"cutgrass",
		"rocks",
		"petals_evil",
	},
	{ --tier 6
		"rocks",
		"flint",
		"petals",
	},
	{ --tier 7
		"ice",
		"flint",
		"pinecone",
	},
	{ --tier 8
		"flint",
		"pinecone",
		"feather_robin",
	},
	{ --tier 9
		"mole",
		"acorn",
	}
}

local friendGiftPrefabs =
{
	{ -- tier 1 (basic seeds)
		"carrot_seeds",
		"corn_seeds",
	},
	{ -- tier 2 (basic, generic stuff)
		"flint",
		"cutgrass",
		"twigs",
		"rocks",
		"ash",
		"pinecone",
		"petals",
		"petals_evil",
	},
	{ -- tier 3 (non-food animal bits)
		"feather_robin",
		"feather_robin_winter",
		"feather_crow",
		"feather_canary",
		"boneshard",
	},
	{ -- tier 4 (better seeds)
		"pumpkin_seeds",
		"eggplant_seeds",
		"durian_seeds",
		"pomegranate_seeds",
		"dragonfruit_seeds",
		"watermelon_seeds",
	},
	{ --tier 5 (food)
		"ice",
		"batwing",
		"acorn",
		"berries",
		"smallmeat",
		"red_cap",
		"blue_cap",
		"green_cap",
		"fish",
		"froglegs",
	},
	{ --tier 6 (live animals + tumbleweed)
		"mole",
		"rabbit",
		"bee",
		"butterfly",
		"robin",
		"robin_winter",
		"canary",
		"crow",
		"tumbleweed",
	},
	{ -- tier 7 (good generic stuff)
		"goldnugget",
		"silk",
		"cutreeds",
		"tentaclespots",
		"beefalowool",
		"transistor",
	},
}

local OG_ACTIONS = {
	HAIRBALL = ACTIONS.HAIRBALL.fn,
	CATPLAYGROUND = ACTIONS.CATPLAYGROUND.fn,
	CATPLAYAIR = ACTIONS.CATPLAYAIR.fn
}

ACTIONS.HAIRBALL.fn = function(act)
    if act.doer and act.doer.prefab == "conifer" then
        return true
	else
		return OG_ACTIONS:HAIRBALL(act)
    end
end

ACTIONS.CATPLAYGROUND.fn = function(act)
    if act.doer and act.doer.prefab == "conifer" then
        if act.target then
            if math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and act.target.components.health and act.target.components.health.maxhealth <= TUNING.RABBIT_HEALTH -- Only bother attacking if it's a rabbit or weaker
            and act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer)
            and not (act.doer.components.follower and act.doer.components.follower:IsLeaderSame(act.target))
            and not act.target:HasTag("player")
			and not act.target:HasTag("bee")
			and not act.target:HasTag("penguin")
			and act.target:HasTag("smallcreature") then
                act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
            elseif math.random() < TUNING.CATCOON_PICKUP_ITEM_CHANCE and act.target.components.inventoryitem and act.target.components.inventoryitem.canbepickedup then
                act.target:Remove()
            end
        end
        return true
	else
		return OG_ACTIONS:CATPLAYGROUND(act)
    end
end

ACTIONS.CATPLAYAIR.fn = function(act)
    if act.doer and act.doer.prefab == "conifer" then
        if act.target and math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE
        and act.target.components.health and act.target.components.health.maxhealth <= TUNING.RABBIT_HEALTH -- Only bother attacking if it's a rabbit or weaker
        and act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer)
        and not (act.doer.components.follower and act.doer.components.follower:IsLeaderSame(act.target)) then
            act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
        end
        act.doer.last_play_air_time = GetTime()
        return true
	else 
		return OG_ACTIONS:CATPLAYAIR(act)
    end
end

local function OnAttacked(inst, data)

end

local function KeepTargetFn(inst, target)
	if target:HasTag("catcoon") then
		return (target
	    	and target.components.combat
	        and target.components.health
	        and not target.components.health:IsDead()
	        and not (inst.components.follower and inst.components.follower:IsLeaderSame(target))
	        and not (inst.components.follower and inst.components.follower.leader == target))
	else
	    return (target
	    	and target.components.combat
	        and target.components.health
	        and not target.components.health:IsDead()
	        and not (inst.components.follower and inst.components.follower.leader == target))
	end
end

local function RetargetFn(inst)
    return FindEntity(inst, TUNING.CATCOON_TARGET_DIST,
        function(guy)
        	if guy:HasTag("catcoon") then
        		return 	not (inst.components.follower and inst.components.follower:IsLeaderSame(guy))
        				and not (inst.components.follower and guy.components.follower and inst.components.follower.leader == nil and guy.components.follower.leader == nil)
        				and guy.components.health
	            		and not guy.components.health:IsDead()
	            		and inst.components.combat:CanTarget(guy)
        	else
            	return 	(guy:HasTag("smallcreature") and not guy:HasTag("penguin") and not guy:HasTag("monster") and not guy:HasTag("bee")
	            		and guy.components.health
	            		and not guy.components.health:IsDead()
	            		and inst.components.combat:CanTarget(guy)
	            		and not (inst.components.follower and inst.components.follower.leader ~= nil and guy:HasTag("abigail")))
            			and not (inst.components.follower and inst.components.follower:IsLeaderSame(guy))
	            	or 	(guy:HasTag("cattoyairborne")
            			and not (inst.components.follower and inst.components.follower:IsLeaderSame(guy)))
	        end
        end)
end

local function SleepTest(inst)
	if not inst.sg:HasStateTag("busy") and (not inst.last_wake_time or GetTime() - inst.last_wake_time >= inst.nap_interval) then
		inst.nap_length = math.random(TUNING.MIN_CATNAP_LENGTH, TUNING.MAX_CATNAP_LENGTH)
		inst.last_sleep_time = GetTime()
		return true
	end
end

local function WakeTest(inst)
	if not inst.last_sleep_time
		or GetTime() - inst.last_sleep_time >= inst.nap_length
		or TheWorld.state.israining then
		inst.nap_interval = math.random(TUNING.MIN_CATNAP_INTERVAL, TUNING.MAX_CATNAP_INTERVAL)
		inst.last_wake_time = GetTime()
		return true
	end
end

local function PickRandomGift(inst, tier)
	local table = (inst.components.follower and inst.components.follower.leader) and 
		friendGiftPrefabs or neutralGiftPrefabs
	-- Neutral and friend tables aren't the same size. Make sure we're in valid range in case loyalty gets added/expired while retching.
	if tier > #table then tier = #table end
	return GetRandomItem(table[tier])
end

local function ShouldAcceptItem(inst, item)
	if item:HasTag("cattoy") or item:HasTag("catfood") or item:HasTag("cattoyairborne") then
		return true
	else
		return false
	end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    if inst.components.combat.target == giver then
        inst.components.combat:SetTarget(nil)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
    elseif giver.components.leader ~= nil then
        giver:PushEvent("makefriend")
        inst.last_hairball_time = GetTime()
        inst.hairball_friend_interval = math.random(2,4) -- Jumpstart the hairball timer (slot machine time!)
        --giver.components.leader:AddFollower(inst)
        --inst.components.follower:AddLoyaltyTime(TUNING.CATCOON_LOYALTY_PER_ITEM)
        if not inst.sg:HasStateTag("busy") then 
            inst:FacePoint(giver.Transform:GetWorldPosition())
            inst.sg:GoToState("pawground") 
       	end
    end
    item:Remove()
end

local function OnRefuseItem(inst, item)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss_pre")
	if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    -- elseif not inst.sg:HasStateTag("busy") then 
    -- 	inst.sg:GoToState("hiss")
    end
end

local function OnIsRaining(inst, raining)
	if raining then
		inst:DoTaskInTime(math.random(2,6), function(inst)
			inst.raining = true
		end)
	end
end

local function LinkToPlayer(inst, player)
    inst.persists = false
    inst._playerlink = player
    player.conifer = inst
	player.components.leader:AddFollower(inst, true)  	
end

local function StayNearPlayer(inst)
	if inst.components.follower.leader and not inst.components.follower:IsNearLeader(35) then
		local pos = inst.components.follower.leader:GetPosition()
		local angle = math.random() * 2 * PI
		local radius = 30
		local x, y, z = pos:Get()
		local result_offset = FindValidPositionByFan(angle, radius, 12, function(offset)
			local x1 = x + offset.x
			local z1 = z + offset.z
			return TheWorld.Map:IsPassableAtPoint(x1, 0, z1)
		end)
		inst.Physics:Teleport(x + result_offset.x, y, z + result_offset.z)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.name = "Conifer"

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(2,0.75)
	inst.Transform:SetScale(.5, .5, .5)
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 1, 0.5)

	inst.AnimState:SetBank("catcoon")
	inst.AnimState:SetBuild("catcoon_build")
	inst.AnimState:PlayAnimation("idle_loop")

	inst:AddTag("smallcreature")
	inst:AddTag("animal")
	inst:AddTag("catcoon")
	inst:AddTag("notarget")
	inst:AddTag("companion")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("health") -- Redundency, since you don't have any way to respawn conifer
	inst.components.health:SetMaxHealth(9999999999)
	inst.components.health:SetInvincible(true)
	inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT * 10, TUNING.CHESTER_HEALTH_REGEN_PERIOD)

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.CATCOON_DAMAGE)
	inst.components.combat:SetRange(TUNING.CATCOON_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.CATCOON_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/catcoon/hurt")
    inst:ListenForEvent("attacked", OnAttacked)
    inst.components.combat.battlecryinterval = 40
	

	inst:AddComponent("lootdropper")
    --inst.components.lootdropper:SetChanceLootTable('catcoon') 

	inst:AddComponent("follower")
	
	inst:AddComponent("inventory")

	inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false
    inst.last_hairball_time = GetTime()
    inst.hairball_friend_interval = math.random(TUNING.MIN_HAIRBALL_FRIEND_INTERVAL * 5, TUNING.MAX_HAIRBALL_FRIEND_INTERVAL * 5)
    inst.hairball_neutral_interval = math.random(TUNING.MIN_HAIRBALL_NEUTRAL_INTERVAL * 5, TUNING.MAX_HAIRBALL_NEUTRAL_INTERVAL * 5)

	inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.last_sleep_time = nil
    inst.last_wake_time = GetTime()
    inst.nap_interval = math.random(TUNING.MIN_CATNAP_INTERVAL, TUNING.MAX_CATNAP_INTERVAL)
    inst.nap_length = math.random(TUNING.MIN_CATNAP_LENGTH, TUNING.MAX_CATNAP_LENGTH)
    inst.components.sleeper:SetWakeTest(WakeTest)
    inst.components.sleeper:SetSleepTest(SleepTest)

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = CONIFER_RUN_SPEED
	inst.components.locomotor.runspeed = CONIFER_FLEE_SPEED
	inst.basespeed = CONIFER_RUN_SPEED
	inst.isrunning = false
	
	--inst:WatchWorldState("israining", OnIsRaining)

	MakeSmallBurnableCharacter(inst, "catcoon_torso", Vector3(1,0,1))
	MakeSmallFreezableCharacter(inst)

	inst:SetBrain(brain)
	inst:SetStateGraph("SGcatcoon")

	inst.neutralGiftPrefabs = neutralGiftPrefabs
	inst.friendGiftPrefabs = friendGiftPrefabs
	inst.PickRandomGift = PickRandomGift

	MakeHauntablePanicAndIgnite(inst)
	
	inst.data = {}
	
	inst.LinkToPlayer = LinkToPlayer
	
	inst:DoPeriodicTask(30, StayNearPlayer)

	return inst
end

return Prefab("conifer", fn, assets, prefabs)
