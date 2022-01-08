local assets =
{
    Asset("ANIM", "anim/books_add.zip"),
    Asset("ATLAS", "images/inventoryimages/achivbook_meteor.xml"),
    Asset("ATLAS", "images/inventoryimages/achivbook_shakespeare.xml"),

}

local prefabs =
{
    "splash_ocean",
    "book_fx",
}




local STAGE_PETRIFY_PREFABS =
{
    "rock_petrified_tree_short",
    "rock_petrified_tree_med",
    "rock_petrified_tree_tall",
    "rock_petrified_tree_old",
}
local STAGE_PETRIFY_FX =
{
    "petrified_tree_fx_short",
    "petrified_tree_fx_normal",
    "petrified_tree_fx_tall",
    "petrified_tree_fx_old",
}
local function dopetrify(inst, stage, instant)
    local x, y, z = inst.Transform:GetWorldPosition()
    local r, g, b = inst.AnimState:GetMultColour()
    inst:Remove()
    local rock = SpawnPrefab(STAGE_PETRIFY_PREFABS[stage])
    if rock ~= nil then
        rock.AnimState:SetMultColour(r, g, b, 1)
        rock.Transform:SetPosition(x, 0, z)
        if not instant then
            local fx = SpawnPrefab(STAGE_PETRIFY_FX[stage])
            fx.Transform:SetPosition(x, y, z)
            fx:InheritColour(r, g, b)
        end
    end 
end

local book_defs =
{
    {
        name = "achivbook_meteor",
        anim = "book_meteor",
        images = "achivbook_meteor",
        uses = 2,
        fn = function(inst, reader)

            reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

            reader:StartThread(function()

                local delay = 0.0
                for i = 1, 25, 1 do
                    local pos = Vector3(reader.Transform:GetWorldPosition())
                    local x, y, z = math.random(-10,10)  + pos.x, pos.y, math.random(-10,10) + pos.z
                    reader:DoTaskInTime(delay, function(inst)
                        local firerain = SpawnPrefab("shadowmeteor_ai") 
                        firerain.Transform:SetPosition(x, y, z)
                        
                    end)
                    delay = delay + 0.5
                end


            end)
            return true
        end,
    },

    {
        name = "achivbook_shakespeare",
        anim = "book_shakespeare",
        images = "achivbook_shakespeare",
        uses = 2,
        fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 40
            local ents = TheSim:FindEntities(x, y, z, range, nil, "stump")
            for i, v in ipairs(ents) do
                if (v:HasTag("evergreens")) and not v:HasTag("stump") and v.components.growable and v.components.growable.stage then
                    local stage = v.components.growable.stage
                    dopetrify(v, stage, true)
                end
            end
            return true
        end
    },

    
}

local function MakeBook(def)


    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("books_add")
        inst.AnimState:SetBuild("books_add")
        inst.AnimState:PlayAnimation(def.anim)
        MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book.onread = def.fn

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/"..def.images..".xml"

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(def.name, fn, assets, prefabs)
end

local books = {}
for i, v in ipairs(book_defs) do
    table.insert(books, MakeBook(v))
end
book_defs = nil
return unpack(books)
