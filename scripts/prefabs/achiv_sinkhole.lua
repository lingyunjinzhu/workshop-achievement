local assets =
{
    Asset("ANIM", "anim/antlion_sinkhole.zip"),
    Asset("MINIMAP_IMAGE", "sinkhole"),
}

local prefabs =
{
    "sinkhole_spawn_fx_1",
    "sinkhole_spawn_fx_2",
    "sinkhole_spawn_fx_3",
    "mining_ice_fx",
    "mining_fx",
    "mining_moonglass_fx",
}

local NUM_CRACKING_STAGES = 3
local COLLAPSE_STAGE_DURATION = 1

local function UpdateOverrideSymbols(inst, state)
    if state == NUM_CRACKING_STAGES then
        inst.AnimState:ClearOverrideSymbol("cracks1")
        if inst.components.unevenground ~= nil then
            inst.components.unevenground:Enable()
        end
    else
        inst.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre"..tostring(state))
        if inst.components.unevenground ~= nil then
            inst.components.unevenground:Disable()
        end
    end
end

local function SpawnFx(inst, stage, scale)
    local theta = math.random() * PI * 2
    local num = 7
    local radius = 1.6
    local dtheta = 2 * PI / num
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(x, y, z)
    for i = 1, num do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))
        dust.Transform:SetPosition(x + math.cos(theta) * radius * (1 + math.random() * .1), 0, z - math.sin(theta) * radius * (1 + math.random() * .1))
        local s = scale + math.random() * .2
        dust.Transform:SetScale(i % 2 == 0 and -s or s, s, s)
        theta = theta + dtheta
    end
    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = math.pow(stage / NUM_CRACKING_STAGES, 2) })
end

-- c_sel():PushEvent("timerdone", {name = "nextrepair"})
local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "nextrepair" then
        inst.remainingrepairs = inst.remainingrepairs - 1
        if inst.remainingrepairs <= 0 then
            inst.components.unevenground:Disable()
            inst.persists = false
            ErodeAway(inst)
        else
            UpdateOverrideSymbols(inst, inst.remainingrepairs)
            inst.components.timer:StartTimer("nextrepair", TUNING.ANTLION_SINKHOLE.REPAIR_TIME[inst.remainingrepairs] + (math.random() * TUNING.ANTLION_SINKHOLE.REPAIR_TIME_VARIANCE))
        end

        if not inst:IsAsleep() then
            SpawnFx(inst, inst.remainingrepairs, .45)
        end
    end
end


local function OnTimerDoneRemove(inst)

    inst._killtask = nil
    inst:Remove()

end

-------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sinkhole")
    inst.AnimState:SetBuild("antlion_sinkhole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre1")
    --inst.MiniMapEntity:SetIcon("sinkhole.png")

    inst.Transform:SetEightFaced()

    inst.Transform:SetScale(1.75,1.75,1.75)

    inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")
    inst:AddTag("achiv_sinkhole_fx")
    

    inst:SetDeployExtraSpacing(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst:AddComponent("timer")
    --inst:ListenForEvent("timerdone", OnTimerDone)

    inst:AddComponent("unevenground")
    inst.components.unevenground.radius = 8.5

    inst.persists = false   
    inst._killtask = inst:DoTaskInTime(10, OnTimerDoneRemove)


    return inst
end

return Prefab("achiv_sinkhole", fn, assets, prefabs)
