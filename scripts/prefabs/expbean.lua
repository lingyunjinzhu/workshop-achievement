local assets=
{
    Asset("ANIM", "anim/expbean.zip"),						-- Animation Zip
    Asset("ATLAS", "images/inventoryimages/expbean.xml"),	-- Atlas for inventory TEX
    Asset("IMAGE", "images/inventoryimages/expbean.tex"),	-- TEX for inventory
}

local function fn(Sim)
	-- Create a new entity
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	
	-- Set animation info
	inst.AnimState:SetBuild("expbean")
	inst.AnimState:SetBank("expbean")
	inst.AnimState:PlayAnimation("expbean")

	inst:AddTag("preparedfood")
    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	-- Make it edible
	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 5	-- Amount to heal
	inst.components.edible.hungervalue =  5	-- Amount to fill belly
	inst.components.edible.sanityvalue = 5	-- Amount to help Sanity
	inst.components.edible.foodtype = "GOODIES"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	-- Make it inspectable
	inst:AddComponent("inspectable")

	-- Make it an inventory item
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "expbean"	-- Use our TEX sprite
    inst.components.inventoryitem.atlasname = "images/inventoryimages/expbean.xml"	-- here's the atlas for our tex
	return inst
end

-- Return our prefab
return Prefab( "common/inventory/expbean", fn, assets)