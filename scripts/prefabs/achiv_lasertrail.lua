local assets =
{
	 Asset("ANIM", "anim/lavaarena_staff_smoke_fx.zip"),
	Asset("SOUND", "sound/common.fsb"),
}


local function kill_fx(inst)

    inst:DoTaskInTime(.2, inst.Remove)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("lavaarena_staff_smoke_fx")
    inst.AnimState:SetBuild("lavaarena_staff_smoke_fx")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetAddColour(1, 0, 0, 0)
    inst.AnimState:SetMultColour(1, 0, 0, 1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.Transform:SetScale(1.6,1.6,0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.kill_fx = kill_fx

    return inst
end



return Prefab( "achiv_lasertrail", fn, assets) 
