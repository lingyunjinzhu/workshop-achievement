local assets =
{
    Asset("ANIM", "anim/lavaarena_heal_flowers_fx.zip"),
}

local prefabs =
{
    "foliage",
}

local NUM_VARIATIONS = 6

local function KillPlant(inst)
    inst._killtask = nil
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("out_"..inst.variation)
end

local function OnBloomed(inst)
    inst:RemoveEventCallback("animover", OnBloomed)
    inst.AnimState:PlayAnimation("idle_"..inst.variation, true)
   
    inst._killtask = inst:DoTaskInTime(0.2 + math.random(), KillPlant)
end



local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_heal_flowers")
    inst.AnimState:SetBuild("lavaarena_heal_flowers_fx")
    inst.AnimState:PlayAnimation("in_1")
    inst.Transform:SetScale(.6,.6,0)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("heal_flowers_fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end



    inst.variation = math.random(NUM_VARIATIONS)
    if inst.variation > 1 then
        inst.variation = tostring(inst.variation)
        inst.AnimState:PlayAnimation("in_"..inst.variation)
    else
        inst.variation = "1"
        
    end


    inst:ListenForEvent("animover", OnBloomed)


    inst.persists = false

    return inst
end

return Prefab("healflowersfx", fn, assets, prefabs)
