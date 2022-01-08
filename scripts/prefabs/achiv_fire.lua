local assets =
{
	Asset("ANIM", "anim/fire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local firelevels = 
{
    {anim="level1", sound="dontstarve/common/campfire", radius=1, intensity=.75, falloff= 1, colour = {207/255,234/255,245/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/campfire", radius=1.5, intensity=.8, falloff=.9, colour = {207/255,234/255,245/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/campfire", radius=2, intensity=.8, falloff=.8, colour = {207/255,234/255,245/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/campfire", radius=2.5, intensity=.9, falloff=.7, colour = {207/255,234/255,245/255}, soundintensity=1},

}

local function OnNextFire(inst)
    --if  inst._firelevels <= 0 then
        inst._killtask = nil
        inst:Remove()
    --else

    --    inst._firelevels = inst._firelevels -1 
    --    inst.components.firefx:SetLevel(inst._firelevels)
   -- end
end


local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fire")
    inst.AnimState:SetBuild("fire")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(-1)

    inst:AddTag("FX")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    
    inst._firelevels = 4

    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels
    inst.components.firefx:SetLevel(4)
    inst.components.firefx.usedayparamforsound = true

    inst:AddComponent("propagator")
    inst.components.propagator.damages = true
    inst.components.propagator.propagaterange = 6
    inst.components.propagator.damagerange = 6
    inst.components.propagator:StartSpreading()


    inst:AddComponent("heater")
    inst.components.heater.heat = 500
    inst.persists = false   

    --inst._killtask = inst:DoPeriodicTask(15, OnNextFire)
    inst._killtask = inst:DoTaskInTime(25, OnNextFire)
    return inst
end


return Prefab( "achiv_fire", fn, assets) 
