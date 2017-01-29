local beecommon = require "brains/beecommon"
--[[
from Bees.lua

bee
Default bee type. Flies around to flowers and pollinates them, generally gets spawned out of beehives or player-made beeboxes

killerbee
Aggressive version of the bee. Doesn't pollinate anythihng, but attacks anything within range. If it has a home to go to and no target,
it should head back there. Killer bees come out to defend beehives when they, the hive or worker bees are attacked
]]--
local assets =
{
    Asset("ANIM", "anim/bee.zip"),
    Asset("ANIM", "anim/bee_build.zip"),
    Asset("ANIM", "anim/bee_angry_build.zip"),
    Asset("SOUND", "sound/bee.fsb"),
}

local prefabs =
{
    "stinger",
    "honey",
}

local workersounds =
{
    takeoff = "dontstarve/bee/bee_takeoff",
    attack = "dontstarve/bee/bee_attack",
    buzz = "dontstarve/bee/bee_fly_LP",
    hit = "dontstarve/bee/bee_hurt",
    death = "dontstarve/bee/bee_death",
}

local function OnWorked(inst, worker)
    inst:PushEvent("detachchild")
    if worker.components.inventory ~= nil then
        inst.SoundEmitter:KillAllSounds()

        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
    end
end

local function OnDropped(inst)
    if inst.buzzing and not inst:IsAsleep() then
        inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    end
    inst.sg:GoToState("catchbreath")
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.brain ~= nil then
        inst.brain:Start()
    end
    if inst.sg ~= nil then
        inst.sg:Start()
    end
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        while inst.components.stackable:IsStack() do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(x, y, z)
            end
        end
    end
end

local function OnPickedUp(inst)
    inst.sg:GoToState("idle")
    inst.SoundEmitter:KillSound("buzz")
    inst.SoundEmitter:KillAllSounds()
end

local function EnableBuzz(inst, enable)
    if enable then
        if not inst.buzzing then
            inst.buzzing = true
            if not (inst.components.inventoryitem:IsHeld() or inst:IsAsleep()) then
                inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
            end
        end
    elseif inst.buzzing then
        inst.buzzing = false
        inst.SoundEmitter:KillSound("buzz")
    end
end

local function OnWake(inst)
    if inst.buzzing and not inst.components.inventoryitem:IsHeld() then
        inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    end
end

local function OnSleep(inst)
    inst.SoundEmitter:KillSound("buzz")
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    local targetshares = 10
    if inst.components.homeseeker and inst.components.homeseeker.home then
        local home = inst.components.homeseeker.home
        if home and home.components.childspawner then
            targetshares = targetshares - home.components.childspawner.childreninside
            --home.components.childspawner:ReleaseAllChildren(attacker, "killerbee")
        end
    end
	
    inst.components.combat:ShareTarget(attacker, 30, function(dude)
        if inst.components.homeseeker and dude.components.homeseeker then  --don't bring bees from other hives
            if dude.components.homeseeker.home and dude.components.homeseeker.home ~= inst.components.homeseeker.home then
                return false
            end
        end
        return dude:HasTag("bee") and not (dude:IsInLimbo() or dude.components.health:IsDead() or dude:HasTag("epic"))
    end, targetshares)
	
end

local function GuudeBeeRetarget(inst)
    return FindEntity(inst, 20,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat", "_health" },
        { "character", "INLIMBO", "glommer", "companion", "shadow" },
        { "monster", "animal", "hostile" })
end

local function commonfn(build, tags)
    local inst = CreateEntity()
	inst.name="Tiny Bee"
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLightWatcher()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeFlyingCharacterPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(.8, .5)
    inst.Transform:SetFourFaced()
	inst.Transform:SetScale(.5, .5, .5)

    inst:AddTag("bee")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")
    inst:AddTag("flying")
    for i, v in ipairs(tags) do
        inst:AddTag(v)
    end

    inst.AnimState:SetBank("bee")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("follower")
	
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED * 3
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 3
    inst:SetStateGraph("SGbee")

    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    -- inst.components.inventoryitem:SetOnDroppedFn(OnDropped) Done in MakeFeedableSmallLivestock
    -- inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickedUp)
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = false


    ------------------
    
    MakeSmallBurnableCharacter(inst, "body", Vector3(0, -1, 1))
    MakeTinyFreezableCharacter(inst, "body", Vector3(0, -1, 1))

    ------------------

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.BEE_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.RARELY)

	inst:DoPeriodicTask(45, function(bee)
		bee.components.health:DoDelta(-1)
	end)
	
    ------------------

    inst:AddComponent("knownlocations")

    ------------------

    inst:AddComponent("inspectable")

    ------------------

    inst:ListenForEvent("attacked", OnAttacked)

    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME*2, OnPickedUp, OnDropped)

    inst.buzzing = true
    inst.EnableBuzz = EnableBuzz
    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep

    return inst
end

local guudebeebrain = require("brains/guudebeebrain")

local function guudebees()
    local inst = commonfn("bee_build", { "worker" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(1)
    inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE*1.5)
    inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD * .1) --(TUNING.BEE_ATTACK_PERIOD * .5)
    inst.components.combat:SetRetargetFunction(2, GuudeBeeRetarget)
    inst:SetBrain(guudebeebrain)
    inst.sounds = workersounds

    return inst
end

local function OnSpawnedFromHaunt(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable:Panic()
    end
end

return Prefab("guudebee", guudebees, assets, prefabs)
