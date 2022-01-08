local assets =
{
   Asset("ANIM", "anim/deer_ice_flakes.zip"),
   Asset("ANIM", "anim/deer_ice_burst.zip"), 
}

local prefabs =
{
    
}


local function KillPlant(inst)
    inst._killtask = nil
    inst:Remove()
    --inst.AnimState:PlayAnimation("pst")
end

local function OnBloomed(inst)
    inst:RemoveEventCallback("animover", OnBloomed)
    inst.AnimState:PlayAnimation("pst")
   
    inst._killtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + .25 + math.random(), KillPlant)
end



local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("deer_ice_flakes")
    inst.AnimState:SetBuild("deer_ice_flakes")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("deer_ice_flakes_aifx")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false   
    

    inst:ListenForEvent("animover", OnBloomed)

    return inst
end

local function OnRemoveFx(inst)
    inst._killtask = nil
    inst:Remove()
end


local function fn_burst()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("deer_ice_burst")
    inst.AnimState:SetBuild("deer_ice_burst")
    inst.AnimState:PlayAnimation("loop", true)

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("deer_ice_burst_aifx")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false   
    

    inst:AddComponent("heater")
    inst.components.heater.heat = -500
    inst.components.heater:SetThermics(false, true)

    inst._killtask = inst:DoTaskInTime(3.5, OnRemoveFx)

    return inst
end

return  Prefab("deer_ice_flakes_aifx", fn, assets, prefabs),
        Prefab("deer_ice_burst_aifx", fn_burst, assets, prefabs)

