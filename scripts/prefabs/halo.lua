local assetshalo1 =
{
    Asset("ANIM", "anim/halo1.zip"),
}

local assetshalo2 =
{
    Asset("ANIM", "anim/halo2.zip"),
}


local assetshalo3 =
{
    Asset("ANIM", "anim/halo3.zip"),
}


local assetshalo4 =
{
    Asset("ANIM", "anim/halo4.zip"),
}


local assetshalo5 =
{
    Asset("ANIM", "anim/halo5.zip"),
}


local assetshalo6 =
{
    Asset("ANIM", "anim/halo6.zip"),
}

local prefabs1 = 
{
    "halo1",
}

local prefabs2 = 
{
    "halo2",
}

local prefabs3 = 
{
    "halo3",
}

local prefabs4 = 
{
    "halo4",
}

local prefabs5 = 
{
    "halo5",
}

local prefabs6 = 
{
    "halo6",
}

function fn1()
    return fn(1)
end


function fn2()
    return fn(2)
end


function fn3()
    return fn(3)
end


function fn4()
    return fn(4)
end


function fn5()
    return fn(5)
end


function fn6()
    return fn(6)
end

function fn(num)

    local inst = CreateEntity()
    inst:AddTag("FX")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("halo")
    inst.AnimState:SetBuild("halo" .. num)
    inst.AnimState:SetScale(0.8, 0.8)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:PlayAnimation("rotation",true)

    inst.entity:AddLight()
	inst.Light:SetIntensity(.4)
	inst.Light:SetRadius(.15)
	inst.Light:SetFalloff(.6)	
    inst.Light:Enable(true)
   


    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
    

    inst:ListenForEvent("animover", inst.Remove)

    return inst


end

return Prefab("halo1", fn1, assetshalo1,prefabs1),
    Prefab("halo2", fn2, assetshalo2,prefabs2),
    Prefab("halo3", fn3, assetshalo3,prefabs3),
    Prefab("halo4", fn4, assetshalo4,prefabs4),
    Prefab("halo5", fn5, assetshalo5,prefabs5),
    Prefab("halo6", fn6, assetshalo6,prefabs6),
    MakePlacer("halo1_placer", "halo", "halo1", "rotation",true,nil,nil),
    MakePlacer("halo2_placer", "halo", "halo2", "rotation",true,nil,nil),
    MakePlacer("halo3_placer", "halo", "halo3", "rotation",true,nil,nil),
    MakePlacer("halo4_placer", "halo", "halo4", "rotation",true,nil,nil),
    MakePlacer("halo5_placer", "halo", "halo5", "rotation",true,nil,nil),
    MakePlacer("halo6_placer", "halo", "halo6", "rotation",true,nil,nil)
