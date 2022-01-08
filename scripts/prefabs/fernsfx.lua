local assets =
{
    Asset("ANIM", "anim/forest_ferns.zip"),
}

local prefabs =
{
    "foliage",
}

local NUM_VARIATIONS = 4

local function KillPlant(inst)
    inst._killtask = nil
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("wilt"..inst.variation)
end

local function OnBloomed(inst)
    inst:RemoveEventCallback("animover", OnBloomed)
    inst.AnimState:PlayAnimation("idle"..inst.variation, true)
   
    inst._killtask = inst:DoTaskInTime(0.2 + math.random(), KillPlant)
end



local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("forest_fern")
    inst.AnimState:SetBuild("forest_ferns")
    inst.AnimState:PlayAnimation("bloom")
    inst.Transform:SetScale(.6,.6,0)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("ferns_fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.variation = math.random(NUM_VARIATIONS)
    if inst.variation > 1 then
        inst.variation = tostring(inst.variation)
        inst.AnimState:PlayAnimation("bloom"..inst.variation)
    else
        inst.variation = ""
    end



    inst:ListenForEvent("animover", OnBloomed)


    inst.persists = false

    return inst
end

return Prefab("fernsfx", fn, assets, prefabs)
