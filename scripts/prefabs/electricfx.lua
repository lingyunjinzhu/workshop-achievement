local assets =
{
   Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),
   Asset("ANIM", "anim/elec_charged_fx.zip"),
   Asset("ANIM", "anim/halloween_embers_cold.zip"),
}



local function kill_fx(inst)

    inst:DoTaskInTime(.2, inst.Remove)
end

local function kill_fx2(inst)

    inst:DoTaskInTime(1, inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    --inst.AnimState:PlayAnimation("open")
    inst.AnimState:PlayAnimation("crackle_loop", true)
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetScale(1.1, 1.1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kill_fx = kill_fx

    return inst
end


local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("elec_charged_fx")
    inst.AnimState:SetBuild("elec_charged_fx")
    inst.AnimState:PlayAnimation("discharged", true)
    --inst.AnimState:SetFinalOffset(1)
    --inst.AnimState:SetScale(1.1, 1.1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kill_fx = kill_fx2

    return inst
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("halloween_embers_cold")
    inst.AnimState:SetBuild("halloween_embers_cold")
    inst.AnimState:PlayAnimation("bouncy_lrg_pre", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kill_fx = kill_fx2

    return inst
end


return 
Prefab("electricfx", fn, assets),Prefab("electricfx2", fn2, assets),Prefab("electricfx3", fn3, assets)
