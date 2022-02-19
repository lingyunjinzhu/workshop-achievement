local _G = GLOBAL
local require = GLOBAL.require
local ipairs =GLOBAL.ipairs
local STRINGS = GLOBAL.STRINGS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab
local TimeEvent = GLOBAL.TimeEvent
local FRAMES = GLOBAL.FRAMES
local ActionHandler = GLOBAL.ActionHandler
local ACTIONS = GLOBAL.ACTIONS

local achievement_config = require("Achievement.achievement_config")
local achievement_ability_config = require("Achievement.achievement_ability_config")
local ability_cost = achievement_ability_config.ability_cost
local language  = GetModConfigData("language")
local can_hide_hud = GetModConfigData("can_hide_hud")
local language_package = "Achievement.strings_achievement_" .. language
require(language_package)
require "Achievement.allachivrpc"
TUNING.CHECKCOIN = GetModConfigData("checkcoin")
TUNING.CHECKSTART = GetModConfigData("checkstart")
TUNING.BOSSSUP = GetModConfigData("bossstrengthen")
TUNING.RETRUN_POINT = GetModConfigData("returnpoint")
TUNING.ACHIEVEMENT_FIRSTINIT = 0
local SHOW_TITLE = GetModConfigData("showtitle")
local IsServer = _G.TheNet:GetIsServer() or _G.TheNet:IsDedicated()
PrefabFiles = {
	"seffc",
	"klaussack_placer",
	--"achivbooks",
    "achivbooks_add",
    "shadowmeteor_ai",
	"expbean",
    "redlantern2",
    "wesfx",
    "fernsfx",
    "healflowersfx",
    "deer_ice_flakes_aifx",
    "electricfx",

    "achiv_fire",
    "achiv_sinkhole",
    "achiv_shield",
    "achiv_ice_crystal",
    "achiv_lasertrail",
    "achiv_bramblefx",
    "achiv_altar_placer",
    "achievement_moonbase",
    "achiv_moonbase_placer",
    "achiv_moon_altar_placer",
    "halo",
    "title",
}

Assets = {

    Asset("ATLAS", "images/inventoryimages/achiv_armor_bramble.xml"),
    Asset("IMAGE", "images/inventoryimages/achiv_armor_bramble.tex"),
    Asset("ATLAS", "images/inventoryimages/achiv_trap_bramble.xml"),
    Asset("IMAGE", "images/inventoryimages/achiv_trap_bramble.tex"),
    Asset("ATLAS", "images/inventoryimages/achiv_compostwrap.xml"),
    Asset("IMAGE", "images/inventoryimages/achiv_compostwrap.tex"),
    
	Asset("ATLAS", "images/inventoryimages/expbean.xml"),
    Asset("IMAGE", "images/inventoryimages/expbean.tex"),

	Asset("ATLAS", "images/inventoryimages/klaussack.xml"),
    Asset("IMAGE", "images/inventoryimages/klaussack.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_meteor.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_meteor.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_shakespeare.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_shakespeare.tex"),
 
    Asset("ATLAS", "images/inventoryimages/memorypotion.xml"),
    Asset("IMAGE", "images/inventoryimages/memorypotion.tex"),  

    Asset("ATLAS", "images/inventoryimages/altar.xml"),
    Asset("IMAGE", "images/inventoryimages/altar.tex"), 
    Asset("ATLAS", "images/inventoryimages/moon_altar.xml"),
    Asset("IMAGE", "images/inventoryimages/moon_altar.tex"), 
    Asset("ATLAS", "images/inventoryimages/moonbase.xml"),
    Asset("IMAGE", "images/inventoryimages/moonbase.tex"), 

    Asset("ATLAS", "images/hud/achivbg_act.xml"),
    Asset("IMAGE", "images/hud/achivbg_act.tex"),
    Asset("ATLAS", "images/hud/achivbg_dact.xml"),
    Asset("IMAGE", "images/hud/achivbg_dact.tex"),
    Asset("ATLAS", "images/hud/achivbg_done.xml"),
    Asset("IMAGE", "images/hud/achivbg_done.tex"),
    Asset("ATLAS", "images/title/title.xml"),
    Asset("IMAGE", "images/title/title.tex"), 
    Asset("ANIM", "anim/altar.zip"),
}

local buttonimageslist = {
"last_act","last_dact","next_act","next_dact","close","infobutton",
"checkbutton","checkbuttonglow","coinbutton","coinbuttonglow",
"config_act","config_dact","config_bg","config_bigger","config_smaller","config_drag","config_remove",
"remove_info_cn", "remove_info_en","remove_yes","remove_no",
"item_head_act","item_head_dact", "item_mide_act","item_mide_dact","item_tail_act","item_tail_dact",
}

for k,v in pairs(buttonimageslist) do
    table.insert(Assets, Asset("ATLAS", "images/button/"..v..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/button/"..v..".tex"))
end
local coinlist = {
	"coin_cn0","coin_cn1","coin_cn3","coin_cn_start","coin_cn_change",  "coin_cn_line", 
}

for k,v in pairs(coinlist) do
	table.insert(Assets, Asset("ATLAS", "images/coin_cn/"..v..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/coin_cn/"..v..".tex"))
end

--给食物加上自身tag
local foodnamelist = {
"nightmarepie","voltgoatjelly","glowberrymousse","frogfishbowl","dragonchilisalad",
"gazpacho","potatosouffle","monstertartare","freshfruitcrepes","bonesoup",
"moqueca","potatotornado","mashedpotatoes","asparagussoup","vegstinger",
"bananapop","ceviche","salsa","pepperpopper","baconeggs",
"bonestew","butterflymuffin","dragonpie","fishsticks","fishtacos",
"flowersalad","frogglebunwich","fruitmedley","guacamole","honeyham",
"honeynuggets","hotchili","icecream","jellybean","kabobs",
"mandrakesoup","meatballs","monsterlasagna","perogies","powcake",
"pumpkincookie","ratatouille","stuffedeggplant","taffy","trailmix",
"turkeydinner","unagi","waffles","watermelonicle",

"seafoodgumbo","surfnturf","californiaroll",
"lobsterbisque","lobsterdinner",
"meatysalad","leafymeatsouffle",
}

for k,v in pairs(foodnamelist) do
    AddPrefabPostInit(v, function(inst)
        inst:AddTag(v.."_ai")
    end)
    AddPrefabPostInit(v.."_spice_chili", function(inst)
        inst:AddTag(v.."_ai")
    end)
    AddPrefabPostInit(v.."_spice_sugar", function(inst)
        inst:AddTag(v.."_ai")
    end)
    AddPrefabPostInit(v.."_spice_garlic", function(inst)
        inst:AddTag(v.."_ai")
    end)
    AddPrefabPostInit(v.."_spice_salt", function(inst)
        inst:AddTag(v.."_ai")
    end)
end

--独立同名书本，解决与可做书人物冲突的问题
AddRecipe("achivbook_birds", {Ingredient("papyrus", 2),Ingredient("bird_egg", 2)},
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages.xml", "book_birds.tex",nil,"book_birds")

AddRecipe("achivbook_gardening", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("seeds", 1), GLOBAL.Ingredient("poop", 1)},
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages.xml", "book_gardening.tex" ,nil,"book_gardening")

AddRecipe("achivbook_sleep", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("nightmarefuel", 2)}, 
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages.xml", "book_sleep.tex" ,nil,"book_sleep")

AddRecipe("achivbook_brimstone", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("redgem", 1)}, 
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages.xml", "book_brimstone.tex" ,nil,"book_brimstone")

AddRecipe("achivbook_tentacles", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("tentaclespots", 1)}, 
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages.xml", "book_tentacles.tex" ,nil,"book_tentacles")

AddRecipe("achivbook_meteor2", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("moonrocknugget", 3), GLOBAL.Ingredient("yellowgem", 1)}, 
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages/achivbook_meteor.xml", "achivbook_meteor.tex" ,nil,"achivbook_meteor")

AddRecipe("achivbook_shakespeare2", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("purplegem", 1), GLOBAL.Ingredient("orangegem", 1)}, 
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages/achivbook_shakespeare.xml", "achivbook_shakespeare.tex" ,nil,"achivbook_shakespeare")

--老买的书
AddRecipe("waxwelljournal2", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("nightmarefuel", 2), GLOBAL.Ingredient(GLOBAL.CHARACTER_INGREDIENT.HEALTH, 50)}, 
RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivshadowmagicbuilder_DONT", 
"images/inventoryimages.xml", "waxwelljournal.tex" ,nil,"waxwelljournal")

--老麦的影子
AddRecipe("shadowlumber_builder2", {GLOBAL.Ingredient("nightmarefuel", 2), GLOBAL.Ingredient("axe", 1), GLOBAL.Ingredient(GLOBAL.CHARACTER_INGREDIENT.MAX_SANITY, GLOBAL.TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWLUMBER)}, 
RECIPETABS.MAGIC, SHADOW_TWO, nil, nil, true, nil, "achivshadowmagicbuilder", 
"images/inventoryimages.xml", "shadowlumber_builder.tex" ,nil,"shadowlumber_builder")
AddRecipe("shadowminer_builder2", {GLOBAL.Ingredient("nightmarefuel", 2), GLOBAL.Ingredient("pickaxe", 1), GLOBAL.Ingredient(GLOBAL.CHARACTER_INGREDIENT.MAX_SANITY, GLOBAL.TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWMINER)}, 
RECIPETABS.MAGIC, SHADOW_TWO, nil, nil, true, nil, "achivshadowmagicbuilder", 
"images/inventoryimages.xml", "shadowminer_builder.tex" ,nil,"shadowminer_builder")
AddRecipe("shadowdigger_builder2", {GLOBAL.Ingredient("nightmarefuel", 2), GLOBAL.Ingredient("shovel", 1), GLOBAL.Ingredient(GLOBAL.CHARACTER_INGREDIENT.MAX_SANITY, GLOBAL.TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDIGGER)}, 
RECIPETABS.MAGIC, SHADOW_TWO, nil, nil, true, nil, "achivshadowmagicbuilder", 
"images/inventoryimages.xml", "shadowdigger_builder.tex" ,nil,"shadowdigger_builder")
AddRecipe("shadowduelist_builder2", {GLOBAL.Ingredient("nightmarefuel", 2), GLOBAL.Ingredient("spear", 1), GLOBAL.Ingredient(GLOBAL.CHARACTER_INGREDIENT.MAX_SANITY, GLOBAL.TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDUELIST)}, 
RECIPETABS.MAGIC, SHADOW_TWO, nil, nil, true, nil, "achivshadowmagicbuilder", 
"images/inventoryimages.xml", "shadowduelist_builder.tex" ,nil,"shadowduelist_builder")

--wickerbottom
AddRecipe("achivbook_meteor", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("moonrocknugget", 3), GLOBAL.Ingredient("yellowgem", 1)}, 
GLOBAL.CUSTOM_RECIPETABS.BOOKS, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages/achivbook_meteor.xml", "achivbook_meteor.tex" ,nil,"achivbook_meteor")

AddRecipe("achivbook_shakespeare", {GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("purplegem", 1), GLOBAL.Ingredient("orangegem", 1)}, 
GLOBAL.CUSTOM_RECIPETABS.BOOKS, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder", 
"images/inventoryimages/achivbook_shakespeare.xml", "achivbook_shakespeare.tex" ,nil,"achivbook_shakespeare")

--添加克劳斯背包建造
AddRecipe("klaus_sack", {Ingredient("redmooneye",1),Ingredient("bluemooneye",1),Ingredient("greenmooneye",1)}, RECIPETABS.MAGIC, TECH.NONE, 
"klaussack_placer", --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achiveking", -- builder_tag
"images/inventoryimages/klaussack.xml", -- atlas
"klaussack.tex") -- image

-- name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image, testfn, product, build_mode, build_distance)

--添加克劳斯背包钥匙建造
AddRecipe("deer_antler1", {Ingredient("boneshard",2),Ingredient("houndstooth",5),Ingredient("silk",5)}, RECIPETABS.MAGIC, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achiveking", -- builder_tag
"images/inventoryimages.xml", -- atlas
"deer_antler1.tex") -- image

--添加生命药水
AddRecipe("halloweenpotion_health_large", {Ingredient("red_cap",3),Ingredient("spidergland",2),Ingredient(GLOBAL.CHARACTER_INGREDIENT.HEALTH,10)}, RECIPETABS.REFINE, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"allachivpotion", -- builder_tag
"images/inventoryimages.xml", -- atlas
"halloweenpotion_health_large.tex") -- image

--厨师能吃药水  给药水添加tag
AddPrefabPostInit("halloweenpotion_health_large", function(inst)
	inst:AddTag("preparedfood")
end)
AddPrefabPostInit("halloweenpotion_sanity_large", function(inst)
	inst:AddTag("preparedfood")
end)
--添加精神药水
AddRecipe("halloweenpotion_sanity_large", {Ingredient("petals",3),Ingredient("green_cap",1),Ingredient("blue_cap",1)}, RECIPETABS.REFINE, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"allachivpotion", -- builder_tag
"images/inventoryimages.xml", -- atlas
"halloweenpotion_sanity_large.tex") -- image

--靠谱的胶带
AddRecipe("achiv_sewing_tape", {Ingredient("silk",1),Ingredient("cutgrass",3)}, RECIPETABS.SCIENCE, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achivehandyperson", -- builder_tag
"images/inventoryimages.xml", -- atlas
"sewing_tape.tex",--image
nil, -- testfn
"sewing_tape")  -- product

--添加投石器
AddRecipe("achiv_winona_catapult", {Ingredient("sewing_tape",1),Ingredient("twigs",3),Ingredient("rocks",15)}, RECIPETABS.SCIENCE, TECH.NONE, 
"winona_catapult_placer", --placer
TUNING.WINONA_ENGINEERING_SPACING, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achivehandyperson", -- builder_tag
"images/inventoryimages.xml", -- atlas
"winona_catapult.tex",nil,"winona_catapult")

--聚光灯
AddRecipe("achiv_winona_spotlight", {Ingredient("sewing_tape",1),Ingredient("goldnugget",2),Ingredient("fireflies",1)}, RECIPETABS.SCIENCE, TECH.NONE, 
"winona_spotlight_placer", --placer
TUNING.WINONA_ENGINEERING_SPACING, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achivehandyperson", -- builder_tag
"images/inventoryimages.xml", -- atlas
"winona_spotlight.tex",nil,"winona_spotlight")

--发电机
AddRecipe("achiv_winona_battery_low", {Ingredient("sewing_tape",1),Ingredient("log",2),Ingredient("nitre",2)}, RECIPETABS.SCIENCE, TECH.NONE, 
"winona_battery_low_placer", --placer
TUNING.WINONA_ENGINEERING_SPACING, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achivehandyperson", -- builder_tag
"images/inventoryimages.xml", -- atlas
"winona_battery_low.tex",nil,"winona_battery_low")

--G.E.M发电机
AddRecipe("achiv_winona_battery_high", {Ingredient("sewing_tape",1),Ingredient("boards",2),Ingredient("transistor",2)}, RECIPETABS.SCIENCE, TECH.NONE, 
"winona_battery_high_placer", --placer
TUNING.WINONA_ENGINEERING_SPACING, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achivehandyperson", -- builder_tag
"images/inventoryimages.xml", -- atlas
"winona_battery_high.tex",nil,"winona_battery_high")

--活木
AddRecipe("achiv_livinglog", {Ingredient(GLOBAL.CHARACTER_INGREDIENT.HEALTH, 20)}, RECIPETABS.WAR, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achiveplantkin", -- builder_tag
"images/inventoryimages.xml",
"livinglog.tex",nil,"livinglog")

--荆棘甲
AddRecipe("achiv_armor_bramble", {Ingredient("livinglog",2),Ingredient("boneshard",4)}, RECIPETABS.WAR, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achiveplantkin", -- builder_tag
"images/inventoryimages/achiv_armor_bramble.xml",
"achiv_armor_bramble.tex",nil,"armor_bramble")

--荆棘陷阱
AddRecipe("achiv_trap_bramble", {Ingredient("livinglog",1),Ingredient("stinger",1)}, RECIPETABS.WAR, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achiveplantkin", -- builder_tag
"images/inventoryimages/achiv_trap_bramble.xml",
"achiv_trap_bramble.tex",nil,"trap_bramble")

--肥料包
AddRecipe("achiv_compostwrap", {Ingredient("poop",5),Ingredient("spoiled_food",2), Ingredient("nitre", 1)}, RECIPETABS.WAR, TECH.NONE, 
nil, --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"achiveplantkin", -- builder_tag
"images/inventoryimages/achiv_compostwrap.xml",
"achiv_compostwrap.tex",nil,"compostwrap")

--灯泡
AddRecipe("achiv_winter_ornament_light5", {Ingredient("spore_medium",5),Ingredient("goldnugget",3), Ingredient("transistor", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,nil,"achive_science","images/inventoryimages.xml",
"winter_ornament_light5.tex",nil,"winter_ornament_light5")
AddRecipe("achiv_winter_ornament_light6", {Ingredient("spore_small",5),Ingredient("goldnugget",3), Ingredient("transistor", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,nil,"achive_science","images/inventoryimages.xml",
"winter_ornament_light6.tex",nil,"winter_ornament_light6")
AddRecipe("achiv_winter_ornament_light7", {Ingredient("spore_tall",5),Ingredient("goldnugget",3), Ingredient("transistor", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,nil,"achive_science","images/inventoryimages.xml",
"winter_ornament_light7.tex",nil,"winter_ornament_light7")
AddRecipe("achiv_winter_ornament_light8", {Ingredient("lightbulb",5),Ingredient("goldnugget",3), Ingredient("transistor", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,nil,"achive_science","images/inventoryimages.xml",
"winter_ornament_light8.tex",nil,"winter_ornament_light8")

--羽毛变换
AddRecipe("achiv_feather_robin_winter_b", {Ingredient("feather_crow",1),Ingredient("charcoal",1), Ingredient("ice", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,nil,"achive_science","images/inventoryimages.xml",
"feather_robin_winter.tex",nil,"feather_robin_winter")

--元宝
AddRecipe("achiv_lucky_goldnugget", {Ingredient("goldnugget",5)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,5,"achive_science","images/inventoryimages.xml",
"lucky_goldnugget.tex",nil,"lucky_goldnugget")

--羽毛变换
AddRecipe("achiv_feather_robin_winter_c", {Ingredient("feather_robin",1),Ingredient("charcoal",1), Ingredient("ice", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,nil,"achive_science","images/inventoryimages.xml",
"feather_robin_winter.tex",nil,"feather_robin_winter")

--节日欢愉
AddRecipe("achiv_wintersfeastfuel", {Ingredient("lightbulb",8),Ingredient("moon_tree_blossom",3), Ingredient("purplegem", 1)}, RECIPETABS.REFINE, TECH.NONE, 
nil,nil,nil,3,"achive_science","images/inventoryimages2.xml",
"wintersfeastfuel.tex",nil,"wintersfeastfuel")

--圣诞节食物科技
AddRecipe("achiv_wintersfeastoven", {Ingredient("cutstone", 1), Ingredient("marble", 1), Ingredient("log", 1)}, RECIPETABS.TOWN, TECH.NONE, 
"wintersfeastoven_placer",
nil,nil,nil,"achive_science","images/inventoryimages2.xml",
"wintersfeastoven.tex",nil,"wintersfeastoven")

--餐桌
AddRecipe("achiv_table_winters_feast", {Ingredient("boards", 1), Ingredient("beefalowool", 1)}, RECIPETABS.TOWN, TECH.NONE, 
"wintersfeastoven_placer",
nil,nil,nil,"achive_science","images/inventoryimages2.xml",
"table_winters_feast.tex",nil,"table_winters_feast")

-- --温蒂制造栏里的药水---------------------------------------------------------------------------------
-- AddRecipe("achiv_ghostlyelixir_slowregen", {Ingredient("spidergland",1),Ingredient("ghostflower",1)}, RECIPETABS.REFINE, TECH.NONE, nil,nil,nil,nil,"achive_elixirbrewer","images/inventoryimages1.xml",
-- "ghostlyelixir_slowregen.tex",nil,"ghostlyelixir_slowregen")

-- AddRecipe("achiv_ghostlyelixir_fastregen", {Ingredient("reviver",1),Ingredient("ghostflower",3)}, RECIPETABS.REFINE, TECH.NONE, nil,nil,nil,nil,"achive_elixirbrewer","images/inventoryimages1.xml",
-- "ghostlyelixir_fastregen.tex",nil,"ghostlyelixir_fastregen")

-- AddRecipe("achiv_ghostlyelixir_shield", {Ingredient("log",1),Ingredient("ghostflower",1)}, RECIPETABS.REFINE, TECH.NONE, nil,nil,nil,nil,"achive_elixirbrewer","images/inventoryimages1.xml",
-- "ghostlyelixir_shield.tex",nil,"ghostlyelixir_shield")

-- AddRecipe("achiv_ghostlyelixir_retaliation", {Ingredient("livinglog",1),Ingredient("ghostflower",3)}, RECIPETABS.REFINE, TECH.NONE, nil,nil,nil,nil,"achive_elixirbrewer","images/inventoryimages1.xml",
-- "ghostlyelixir_retaliation.tex",nil,"ghostlyelixir_retaliation")

-- AddRecipe("achiv_ghostlyelixir_attack", {Ingredient("stinger",1),Ingredient("ghostflower",3)}, RECIPETABS.REFINE, TECH.NONE, nil,nil,nil,nil,"achive_elixirbrewer","images/inventoryimages1.xml",
-- "ghostlyelixir_attack.tex",nil,"ghostlyelixir_attack")

-- AddRecipe("achiv_ghostlyelixir_speed", {Ingredient("honey",1),Ingredient("ghostflower",1)}, RECIPETABS.REFINE, TECH.NONE, nil,nil,nil,nil,"achive_elixirbrewer","images/inventoryimages1.xml",
-- "ghostlyelixir_speed.tex",nil,"ghostlyelixir_speed")

AddRecipe("ancient_altar", {Ingredient("thulecite", 15), Ingredient("cutstone", 20), Ingredient("purplegem", 2)}, GLOBAL.RECIPETABS.MAGIC, TECH.NONE, 
"ancient_altar_placer", --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"ancientstation", -- builder_tag
"images/inventoryimages/altar.xml", -- atlas
"altar.tex") -- image

AddRecipe("achievement_moonbase", {Ingredient("moonrocknugget", 20), Ingredient("cutstone", 10), Ingredient("purplegem", 2)}, GLOBAL.RECIPETABS.MAGIC, TECH.NONE, 
"moonbase_placer", --placer
nil, -- min_spacing
nil, -- nounlock
nil, -- numtogive
"moonstone", -- builder_tag
"images/inventoryimages/moonbase.xml", -- atlas
"moonbase.tex") -- image

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil and inst.replica.inventory and inst.replica.inventory:Has("wortox_soul", 1) then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then  --BLINK
            return { GLOBAL.ACTIONS.BLINK }  --伍迪的冲刺 TACKLE
        end
    end
    return {}
end

local function _init_ability_net_var(inst)
    for _,v in pairs(achievement_ability_config.ability_cost) do
        local current = "current" .. v.ability
        inst[current] = GLOBAL.net_shortint(inst.GUID,current)
    end
end

-- local old_CanEntitySeeInStorm = _G.CanEntitySeeInStorm
-- print(old_CanEntitySeeInStorm,"===========================")
-- _G.CanEntitySeeInStorm = function(inst)
--     print(inst.components.achievementability.ignorestorm,"============")
--     return old_CanEntitySeeInStorm(inst) or inst.components.achievementability.ignorestorm
-- end

--预运行
AddPlayerPostInit(function(inst)
    _init_ability_net_var(inst)
    inst.currentcoinamount = GLOBAL.net_shortint(inst.GUID,"currentcoinamount")
    inst.currentkillamount = GLOBAL.net_uint(inst.GUID,"currentkillamount")--杀戮值
    for _,v in pairs(achievement_config.idconfig) do
        if v.id == "a4" or v.id == "angry" then
            inst[v.check] = GLOBAL.net_shortint(inst.GUID,v.check)
            inst[v.current] = GLOBAL.net_uint(inst.GUID,v.current)
        else
            inst[v.check] = GLOBAL.net_shortint(inst.GUID,v.check)
            inst[v.current] = GLOBAL.net_shortint(inst.GUID,v.current)
        end
    end
    inst:AddComponent("achievementability")
    --inst.components.achievementmanager.a_a1=false
    inst:AddComponent("achievementmanager")
	if not GLOBAL.TheNet:GetIsClient() then     
        inst.components.achievementmanager:Init(inst)
        inst.components.achievementability:Init(inst)
    end
    
    --除了温蒂以外  添加 阿比盖尔徽章
    local WendyFlowerOver = require("widgets/wendyflowerover")
    local function OnBondLevelDirty(inst)
        if inst.HUD ~= nil and not inst:HasTag("playerghost") then
            local bond_level = inst._bondlevel:value()
            if bond_level > 1 then
                if inst.HUD.wendyflowerover ~= nil then
                    inst.HUD.wendyflowerover:Play( bond_level )
                end
            end
        end
    end

    local function OnPlayerDeactivated(inst)
        inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
        if not GLOBAL.TheWorld.ismastersim then
            inst:RemoveEventCallback("_bondleveldirty", OnBondLevelDirty)
        end
    end

    local function OnClientPetSkinChanged(inst)
        if inst.HUD ~= nil and inst.HUD.wendyflowerover ~= nil then
            local skinname = GLOBAL.TheInventory:LookupSkinname( inst.components.pethealthbar._petskin:value() )
            inst.HUD.wendyflowerover:SetSkin( skinname ) 
        end
    end
    local function PetHealthbadgeTask(inst)
        if (not inst.currentghostly_friend) or inst.currentghostly_friend:value() == 0 then
            inst.HUD.controls.status.pethealthbadge:Hide()
        else 
            inst.HUD.controls.status.pethealthbadge:Show()
        end
    end
    local function OnPlayerActivated(inst)
        if inst == GLOBAL.ThePlayer then
            if inst.HUD.wendyflowerover == nil and inst.components.pethealthbar ~= nil and inst.currentghostly_friend then
                inst.HUD.wendyflowerover = inst.HUD.overlayroot:AddChild(WendyFlowerOver(inst))
                inst.HUD.wendyflowerover:MoveToBack()
                OnClientPetSkinChanged( inst )
            end

            inst:ListenForEvent("onremove", OnPlayerDeactivated)
            if not GLOBAL.TheWorld.ismastersim then
                inst:ListenForEvent("_bondleveldirty", OnBondLevelDirty)
            end
            inst:DoPeriodicTask(3, PetHealthbadgeTask)
        end
    end
    if  inst.prefab ~= "wendy" then
        inst:AddTag("ghostlyfriend")
        inst:AddTag("elixirbrewer")

        if not inst.components.pethealthbar then
            inst:AddComponent("pethealthbar")
        end
        inst._bondlevel = GLOBAL.net_tinybyte(inst.GUID, "wendy._bondlevel", "_bondleveldirty")
        inst:ListenForEvent("playeractivated", OnPlayerActivated)
        inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
        inst:ListenForEvent("clientpetskindirty", OnClientPetSkinChanged)
    end
    local PetHealthBadge = require "widgets/pethealthbadge"
    AddClassPostConstruct("widgets/statusdisplays", function(self)
        function self:RefreshPetHealth2()
            if self.owner.currentghostly_friend:value() ~= 0 then
                self.pethealthbadge:Show()
            end
            local pethealthbar = self.owner.components.pethealthbar
            self.pethealthbadge:SetValues(pethealthbar:GetSymbol(), pethealthbar:GetPercent(), pethealthbar:GetOverTime(), pethealthbar:GetMaxHealth(), pethealthbar:GetPulse())
            pethealthbar:ResetPulse()
        end

        if not self.owner or self.owner.prefab == "wendy" then return end
        if self.owner.components.pethealthbar ~= nil then
            self.pethealthbadge = self:AddChild(PetHealthBadge(self.owner, { 254 / 255, 253 / 255, 237 / 255, 1 }, "status_abigail"))
            self.pethealthbadge:SetPosition(60, -100, 0)
            self.pethealthbadge:SetValues(0, 0, 1, 1, 1)
            self.pethealthbadge:Hide()
            if self.pethealthbadge ~= nil and self.onpethealthdirty == nil then
                self.onpethealthdirty = function() self:RefreshPetHealth2() end
                inst:ListenForEvent("clientpethealthdirty", self.onpethealthdirty, self.owner)
                inst:ListenForEvent("clientpethealthsymboldirty", self.onpethealthdirty, self.owner)
                inst:ListenForEvent("clientpetmaxhealthdirty", self.onpethealthdirty, self.owner)
                inst:ListenForEvent("clientpethealthpulsedirty", self.onpethealthdirty, self.owner)
                inst:ListenForEvent("clientpethealthstatusdirty", self.onpethealthdirty, self.owner)
                self:RefreshPetHealth2()
            end
        end
    end)

    if inst.prefab ~= "wortox" then
    	inst:DoPeriodicTask(0.1, function()
        	if inst.replica.inventory and inst.replica.inventory:Has("wortox_soul", 1) then
            	inst:AddTag("soulstealer")
        	else
            	inst:RemoveTag("soulstealer")
        	end    
        	if inst.components.playeractionpicker ~= nil  then
            	inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
        	end
    	end)
    end
    if inst.prefab ~= "walter" then
        inst:AddTag("pebblemaker")
    end

    if inst.prefab ~= "wanda" then
        inst:AddTag("clockmaker")
    end
    if inst.OnNewSpawn then
        local function OnPlayerNewSpawn(inst)
            inst.components.achievementability:OnInitSpecialAbility()
           -- inst.components.achievementmanager:OnInitSpecialAbility()
        end
        inst:DoTaskInTime(1, OnPlayerNewSpawn)
    end
    if SHOW_TITLE then
        local function updateTitle(inst)
            local level,cur_exp,next_exp = 0,0,0
            if inst.components.achievementmanager then
                level = inst.components.achievementmanager:getLevel()
                cur_exp,next_exp = inst.components.achievementmanager:getExp()
            end
            if inst.title == nil then 
                inst.title = GLOBAL.SpawnPrefab("title") 
                inst.title.entity:SetParent(inst.entity) 
                inst.title:SetText(inst:GetDisplayName(),level) 
                --inst.title:SetTexture(level)
            end 
            local title = ""
            local phase = math.floor(level/10) + 1
            if phase > #STRINGS.TITLE then
                title = STRINGS.TITLE[#STRINGS.TITLE]
            else
                title =  STRINGS.TITLE[phase]
            end
            local titleinfo = string.format(STRINGS.TITLE_INFO,title,level,cur_exp,next_exp,inst:GetDisplayName())
            inst.title:SetText(titleinfo,level) 
            --inst.title:SetTexture(level)
        end
        inst:DoPeriodicTask(2,function() 
            updateTitle(inst) 
        end) 
        updateTitle(inst) 
    end
end)

--UI尺寸
local function PositionUI(self, screensize)
	local hudscale = self.top_root:GetScale()
	self.uiachievement:SetScale(.75*hudscale.x,.75*hudscale.y,1)
end

--UI
local uiachievement = require("widgets/uiachievement")
local function Adduiachievement(self)
    self.uiachievement = self.top_root:AddChild(uiachievement(self.owner))
    local screensize = {GLOBAL.TheSim:GetScreenSize()}
    PositionUI(self, screensize)
    self.uiachievement:SetHAnchor(0)
    self.uiachievement:SetVAnchor(0)
    --H: 0=中间 1=左端 2=右端
    --V: 0=中间 1=顶端 2=底端
    self.uiachievement:MoveToFront()
    local OnUpdate_base = self.OnUpdate
    self.OnUpdate = function(self, dt)
        OnUpdate_base(self, dt)
        local curscreensize = {GLOBAL.TheSim:GetScreenSize()}
        if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
            PositionUI(self, curscreensize)
            screensize = curscreensize
        end
    end
end

AddClassPostConstruct("widgets/controls", Adduiachievement)
GLOBAL.TheInput:AddKeyDownHandler(
    GLOBAL.KEY_N,
    function()
        if can_hide_hud then
            if not GLOBAL.TheWorld.ismastersim then
                if GLOBAL.ThePlayer.HUD.controls.uiachievement and GLOBAL.ThePlayer.HUD.controls.uiachievement:IsVisible() then
                    GLOBAL.ThePlayer.HUD.controls.uiachievement:Hide()
                else
                    GLOBAL.ThePlayer.HUD.controls.uiachievement:Show()
                    if GLOBAL.ThePlayer.HUD.controls.uiachievement.mainui.bg.allcoin.shown then
                    else
                        GLOBAL.ThePlayer.HUD.controls.uiachievement.mainui.bg.title_1.onclick()
                    end
                end
            end
        end
    end,
    false
)

--欧皇检测
AddPrefabPostInit("krampus_sack", function(inst)
    inst:AddComponent("ksmark")
end)
AddPrefabPostInit("ancient_altar", function(inst)
    inst:AddComponent("ksmark")
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.HARVEST, function(inst,action)
            if inst:HasTag("quagmire_fasthands") then
                return  "domediumaction" 
            elseif   action.target --[[and not action.target.components.stewer]] and inst:HasTag("fastharvester") then
                return  "doshortaction" 
            else
                return "dolongaction"
            end
        end))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.HARVEST, function(inst,action)
            if inst:HasTag("quagmire_fasthands") then
                return  "domediumaction" 
            elseif  action.target --[[and not action.target.components.stewer]]  and inst:HasTag("fastharvester")  then
                return  "doshortaction" 
            else
                return "dolongaction"
            end
        end))

--阿比盖尔杀死怪物   leader也增加exp和killamount
AddPrefabPostInit("abigail", function(inst)
    inst:ListenForEvent("killed", function(inst, data)
        local leader = nil
        if inst.components.follower and  inst.components.follower.leader then
            leader = inst.components.follower.leader
        end
        if leader and  leader.components.achievementability.level == true  and leader:HasTag("player") then
            if data.victim and data.victim.components.combat and data.achivhaskill == nil then 
                -- data.victim.components.combat:GetAttacked(leader, 1) 
                -- local victim_check = data.victim
                -- victim_check.abigailkill_ai = victim_check:DoTaskInTime(1.3, function(victim_check)  victim_check.abigailkill_ai = nil end)
                -- leader.achivhaskill = leader:DoTaskInTime(1.2, function(leader) leader.achivhaskill = nil end)
                leader.components.achievementability:calc_killamount(leader,data)
                leader.components.achievementmanager:check_kill_exp(leader,data.victim)
            end 
        end
    end)
end)

----------------------------------------------------------------------------------------------------
--BOSS SKILL
---是否加强-------------------------------------------------------------------

if TUNING.BOSSSUP  then
    local function AI_DropItem(inst,target,equippeditem)
        if equippeditem then
            local angle_num = -10
            local item_temp = GLOBAL.EQUIPSLOTS.HANDS
            if equippeditem == "HEAD" then
                angle_num = -40
                item_temp =  GLOBAL.EQUIPSLOTS.HEAD
            end
            if equippeditem == "BODY" then
                angle_num = 20
                item_temp =  GLOBAL.EQUIPSLOTS.BODY
            end
            local item = nil
            if target and target.components.inventory then
                item = target.components.inventory:GetEquippedItem(item_temp)
            end
            if item and item.Physics then
                target.components.inventory:DropItem(item)
                local x, y, z = item:GetPosition():Get()
                y = .1
                item.Physics:Teleport(x,y,z)
                local hp = target:GetPosition()
                local pt = inst:GetPosition()
                local vel = (hp - pt):GetNormalized()
                local speed = 5 + (math.random() * 2)
                local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 +angle_num ) * GLOBAL.DEGREES
                item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
            end
        end
    end
    
    local function OnBossOnhitotherCooldown(inst)
        inst._cdtaskboss_onhitother = nil
    end
    
    local function OnBossAttackedCooldown(inst)
        inst._cdtaskboss_attacked = nil
    end
    local function OnBossFireCooldown(inst)
        inst._cdtaskboss_zhaohuan = nil
    end
    
    local function SpawnAchiv_fire(inst, x, z)
        GLOBAL.SpawnPrefab("achiv_fire").Transform:SetPosition(x, 0, z)
    end
    --触手不打
    
    AddPrefabPostInit("tentacle", function(inst)
        local function retargetfn2(inst)
            return GLOBAL.FindEntity(
            inst,
            TUNING.TENTACLE_ATTACK_DIST,
            function(guy) 
                return guy.prefab ~= inst.prefab and not guy:HasTag("dont_target") and guy.entity:IsVisible() and not guy.components.health:IsDead()
                    and (guy.components.combat.target == inst or guy:HasTag("character") or guy:HasTag("monster") or  guy:HasTag("animal"))
            end,
            { "_combat", "_health" },
            { "prey" })
        end
        local function shouldKeepTarget2(inst, target)
            return target ~= nil and not target:HasTag("dont_target")  and target:IsValid()  and target.entity:IsVisible() and target.components.health ~= nil
                and not target.components.health:IsDead() and target:IsNear(inst, TUNING.TENTACLE_STOPATTACK_DIST)
            end
            if inst.components.combat then
                inst.components.combat:SetRetargetFunction(GLOBAL.GetRandomWithVariance(2, 0.5), retargetfn2)
                inst.components.combat:SetKeepTargetFunction(shouldKeepTarget2)
            end
        end)
    
    --龙蝇
    TUNING.DRAGONFLY_SPEED = 7
    TUNING.DRAGONFLY_FIRE_SPEED = 9
    TUNING.DRAGONFLY_BREAKOFF_DAMAGE = 5000
    
    AddPrefabPostInit("dragonfly", function(inst)
        inst:AddTag("dont_target")
        inst:ListenForEvent("onhitother", function(inst, data)
            if   inst._cdtaskboss_onhitother == nil and data ~= nil and not data.redirected  then
                inst._cdtaskboss_onhitother = inst:DoTaskInTime(10, OnBossOnhitotherCooldown)
                --AI_DropItem(inst,data.target,"HANDS")
                AI_DropItem(inst,data.target,"HEAD")
                AI_DropItem(inst,data.target,"BODY")
    
                local pos = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
                local ents = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 5)
                for k,v in pairs(ents) do
                    if v:HasTag("player") and not  v:HasTag("playerghost")   and  v ~= data.target then
                        local  r3 = math.random()
                        if r3 <= 0.33 then
                            AI_DropItem(inst,data.attacker,"HANDS")
                        elseif  r3>0.33 and r3 < 0.66 then
                            AI_DropItem(inst,data.attacker,"HEAD")
                        else
                            AI_DropItem(inst,data.attacker,"BODY")
                        end
                    end
                end
            end
        end)
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil and not data.redirected  then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(5, OnBossAttackedCooldown)
    
                GLOBAL.SpawnPrefab("bramblefx_armor"):SetFXOwner(inst)--22
                local player_num = 0
                local pos = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
                local ents = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 6)
                for k,v in pairs(ents) do
                    if v:HasTag("player") and not  v:HasTag("playerghost")    then
                        player_num= player_num +1
                    end
                end
                if player_num >=3 then
                    GLOBAL.SpawnPrefab("bramblefx_trap"):SetFXOwner(inst)--40
                else
                    if math.random() > .6 then
                        GLOBAL.SpawnPrefab("bramblefx_trap"):SetFXOwner(inst)--40
                    end
                end
                local  r3 = math.random()
                if r3 <= 0.33 then
                    AI_DropItem(inst,data.attacker,"HANDS")
                elseif  r3>0.33 and r3 < 0.66 then
                    AI_DropItem(inst,data.attacker,"HEAD")
                else
                    AI_DropItem(inst,data.attacker,"BODY")
                end
    
                ----------------------------
                if inst._cdtaskboss_zhaohuan == nil then
                    inst._cdtaskboss_zhaohuan = inst:DoTaskInTime(26, OnBossFireCooldown)
                    local pos_inst = inst:GetPosition()
                    local pos_temp = 1
                    local pos_temp2 = 1
                    local dx = 24
                    local dx2 = 16
                    local r = 16
                    local r2 = 10
                    local angle = 0
                    local angle2 = 0
                    for pos_temp=1,dx do
                        inst:DoTaskInTime(.75, SpawnAchiv_fire(inst ,(pos_inst.x + math.cos(angle)*r), (pos_inst.z -math.sin(angle)*r)))
                        angle = angle + (math.pi*2/dx)
                    end
                    if inst.components.health and (inst.components.health.currenthealth < inst.components.health.maxhealth/2) then
                        for pos_temp2=1,dx2 do
                            inst:DoTaskInTime(.75, SpawnAchiv_fire(inst ,(pos_inst.x + math.cos(angle2)*r2), (pos_inst.z -math.sin(angle2)*r2)))
                            angle2 = angle2 + (math.pi*2/dx2)
                        end
                    end
                end
            end
        end)
    end)

    local function AI_DropItemIsInsulated(inst,target,equippeditem)
        if equippeditem then
            local angle_num = -20
            local item_temp = GLOBAL.EQUIPSLOTS.HEAD
            if equippeditem == "BODY" then
                angle_num = 20
                item_temp =  GLOBAL.EQUIPSLOTS.BODY
            end
            local item = nil
            if target and target.components.inventory then
                item = target.components.inventory:GetEquippedItem(item_temp)
            end
            if item and item.Physics and item.components.waterproofer and  item.components.waterproofer.effectiveness>=1  then
                target.components.inventory:DropItem(item)
                local x, y, z = item:GetPosition():Get()
                y = .1
                item.Physics:Teleport(x,y,z)
                local hp = target:GetPosition()
                local pt = inst:GetPosition()
                local vel = (hp - pt):GetNormalized()
                local speed = 5 + (math.random() * 2)
                local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 +angle_num ) * GLOBAL.DEGREES
                item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
            end
        end
    end
    --鹿鸭
    TUNING.MOOSE_HEALTH = 15000
    TUNING.MOOSE_WALK_SPEED = 10
    TUNING.MOOSE_RUN_SPEED = 14
    AddPrefabPostInit("moose", function(inst)
        inst:AddTag("dont_target")
        inst:AddComponent("heater")
        inst.components.heater.heat = -200
        inst.components.heater:SetThermics(false, true)
        if inst.components.health then
            inst.components.health.fire_damage_scale = 0 
        end
        inst:ListenForEvent("onhitother", function(inst, data)
            if data ~= nil and data.target  then
                SpawnPrefab("waterballoon_splash").Transform:SetPosition(data.target.Transform:GetWorldPosition())
                if  data.target.components.moisture ~= nil then
                    data.target.components.moisture:DoDelta(data.target.components.inventory ~= nil and 30 * (1 - math.min(data.target.components.inventory:GetWaterproofness(), 1)) or 20)
                end
    
                if data.target.components.temperature then
                    data.target.components.temperature:DoDelta(-10)
                end
    
                if  inst._cdtaskboss_onhitother == nil then
                    inst._cdtaskboss_onhitother = inst:DoTaskInTime(8, OnBossOnhitotherCooldown)
    
                    if  data.target.components.health ~= nil and not data.target.components.health:IsDead() and data.target.components.combat then
                        data.target.components.health:DoDelta(-15, nil, inst.prefab, nil, inst)
                        if data.target:HasTag("player") and  not  data.target:HasTag("playerghost") then
                            if data.target.components.inventory == nil or not data.target.components.inventory:IsInsulated() then
                                data.target.components.combat:GetAttacked(inst, TUNING.MOOSE_EGG_DAMAGE, nil, "electric")
                            end
                        end
                    end
                end
            end
        end)
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil  then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(6, OnBossAttackedCooldown)
                local pos = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
                local ents = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 6)
                for k,v in pairs(ents) do
                    if v:HasTag("player") and not  v:HasTag("playerghost")   then
                        SpawnPrefab("waterballoon_splash").Transform:SetPosition(v.Transform:GetWorldPosition())
                        if data ~= nil and data.attacker ~= nil and  data.attacker.components.temperature then
                            data.attacker.components.temperature:DoDelta(-10)
                        end
                        if  v.components.moisture ~= nil then
                            v.components.moisture:DoDelta(v.components.inventory ~= nil and 40 * (1 - math.min(v.components.inventory:GetWaterproofness(), 1)) or 20)
                        end
                        
                        if data ~= nil and data.attacker ~= nil and data.attacker.components.health ~= nil and not data.attacker.components.health:IsDead()  then
                            if data.attacker.components.inventory == nil or not data.attacker.components.inventory:IsInsulated() then
                                data.attacker.components.health:DoDelta(-15, nil, inst.prefab, nil, inst)
                                data.attacker.sg:GoToState("electrocute")
                            end
                        end 
                        if math.random() < .55 then
                            AI_DropItemIsInsulated(inst,data.attacker,"HEAD")
                        end
                        if math.random() < .55 then
                            AI_DropItemIsInsulated(inst,data.attacker,"BODY")
                        end
                        
                    end
                end
            end
        end)
    end)
    --熊大
    local function OnSpawnPrefabBearger(inst,pos_x,pos_z)
        SpawnPrefab("achiv_sinkhole").Transform:SetPosition(pos_x, 0, pos_z)
    end
    local function OnSpawnPrefabIcecrystal(inst)
    
        local pos_inst = inst:GetPosition()
        local pos_temp,dx,r,angle = 1,30,8,0
        local pos_temp2,dx2,r2,angle2 = 1,20,5,0
        for pos_temp=1,dx do
            local ice_crystal = SpawnPrefab("achiv_ice_crystal")
            if ice_crystal   then
                ice_crystal.Transform:SetPosition((pos_inst.x + math.cos(angle)*r), 0, (pos_inst.z -math.sin(angle)*r))
                angle = angle + (math.pi*2/dx)
            end
        end
        for pos_temp2=1,dx2 do
            local ice_crystal = SpawnPrefab("achiv_ice_crystal")
            if ice_crystal  then
                ice_crystal.Transform:SetPosition((pos_inst.x + math.cos(angle2)*r2), 0, (pos_inst.z -math.sin(angle2)*r2))
                angle2 = angle2 + (math.pi*2/dx2)
            end
        end
    end
    
    TUNING.BEARGER_HEALTH = 12000
    AddPrefabPostInit("bearger", function(inst)
        inst:AddTag("dont_target")
    
        if inst.components.health then
            inst.components.health.fire_damage_scale = 0 
        end
        inst:ListenForEvent("attacked", function(inst, data)
            if inst.components.combat  and inst.components.health and (inst.components.health.currenthealth < inst.components.health.maxhealth/3)    then
                inst.components.combat:SetDefaultDamage(260)
            end
            if   inst._cdtaskboss_attacked == nil and data ~= nil and data.attacker and data.attacker:HasTag("player") and  not  data.attacker:HasTag("playerghost")  then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(11, OnBossAttackedCooldown)
                local pos = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
                local ents = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 7.8)
    
                local check_fx = true
                for k,v in pairs(ents) do
                    if  v:HasTag("achiv_sinkhole_fx")    then
                        check_fx = false
                    end
                end
                if check_fx then
                    inst:DoTaskInTime(.1, OnSpawnPrefabBearger(inst,pos.x,pos.z))
                end
                if check_fx then
                    inst:DoTaskInTime(.35, OnSpawnPrefabIcecrystal(inst))
                end
            end
        end)
    end)
    --蚁狮 antlion
    TUNING.ANTLION_HEALTH = 17500
    AddPrefabPostInit("antlion", function(inst)
        inst:AddTag("dont_target")
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil   then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(10, OnBossAttackedCooldown)
                local pos = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
                local ents = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 17)
                for k,v in pairs(ents) do
                    if v ~= nil  and v:HasTag("catapult") or  v:HasTag("engineeringbattery")  or v.prefab  == "eyeturret"  or v.prefab  == "lureplant"   then
                        local pos_spawn = GLOBAL.Vector3(v.Transform:GetWorldPosition())
                        SpawnPrefab("sandspike_med").Transform:SetPosition(pos_spawn.x,0,pos_spawn.z)
                    end
                end
                if data.attacker and data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost")   then
                    SpawnPrefab("achiv_shield").Transform:SetPosition(pos.x, 0, pos.z)
                        
                end
                local pos_inst = inst:GetPosition()
                local pos_temp,dx,r,angle = 1,14,2.1,0
                local pos_temp2,dx2,r2,angle2 = 1,28,2.9,0
                for pos_temp=1,dx do
                    local sandblock_small = SpawnPrefab("sandspike_med")
                    if sandblock_small and sandblock_small.components.health  then
                        sandblock_small.components.health:SetMaxHealth(200)
                        sandblock_small.Transform:SetPosition((pos_inst.x + math.cos(angle)*r), 0, (pos_inst.z -math.sin(angle)*r))
                        angle = angle + (math.pi*2/dx)
                    end
                end
                for pos_temp2=1,dx2 do
                    local sandblock_small = SpawnPrefab("sandspike_short")
                    if sandblock_small and sandblock_small.components.health  then
                        sandblock_small.components.health:SetMaxHealth(100)
                        sandblock_small.Transform:SetPosition((pos_inst.x + math.cos(angle2)*r2), 0, (pos_inst.z -math.sin(angle2)*r2))
                        angle2 = angle2 + (math.pi*2/dx2)
                    end
                end
    
            end
        end)
        
    end)
    --巨鹿 deerclops
    TUNING.DEERCLOPS_HEALTH = 8000
    AddPrefabPostInit("deerclops", function(inst)
        inst:AddTag("dont_target")
        if inst.components.health then
            inst.components.health.fire_damage_scale = 0 
        end
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil  and data.attacker and data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost") then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(math.random() * 5 + 8, OnBossAttackedCooldown)
                
                local pos = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
                local ents = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 10)
                for k,v in pairs(ents) do
                    if v:HasTag("player") and not  v:HasTag("playerghost")  then
                        if v._deer_ice_burst_aifx == nil then            
                            v._deer_ice_burst_aifx = SpawnPrefab("deer_ice_burst_aifx") -- deer_ice_burst_aifx
                            v._deer_ice_burst_aifx.entity:SetParent(v.entity)
                            v._deer_ice_burst_aifx.Transform:SetPosition(0, 0.2, 0)
                            v._deer_ice_burst_aifx = v:DoTaskInTime(3, 
                                function(v) 
                                    if v  then v._deer_ice_burst_aifx = nil  end
                                    if math.random()> 0.55 and v and  v.components.freezable then
                                        v.components.freezable:AddColdness(5, 3)
                                        v.components.freezable:SpawnShatterFX()
                                    end
    
                            end)
                        end
                    end
                end
            end
        end)
    
    end)
    local function OnBossAttackedCooldownPlayer(inst)
        inst._cdtaskboss_playerattack = nil
    end
    --蜂后 beequeen
    AddPrefabPostInit("beequeen", function(inst)
        if inst.components.health then
            inst.components.health.fire_damage_scale = 0 
        end
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil  and data.attacker and not data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost") then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(.15, OnBossAttackedCooldown)
                GLOBAL.SpawnPrefab("achiv_bramblefx_armor"):SetFXOwner(inst)
            end
            if   inst._cdtaskboss_playerattack == nil and data ~= nil  and data.attacker and  data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost") then
                inst._cdtaskboss_playerattack = inst:DoTaskInTime(5, OnBossAttackedCooldownPlayer)
                GLOBAL.SpawnPrefab("achiv_bramblefx_armor"):SetFXOwner(inst)
            end
        end)
    
    end)
    --克劳斯
    AddPrefabPostInit("klaus", function(inst)
        if inst.components.health then
            inst.components.health.fire_damage_scale = 0 
        end
    end)
    --蛤蟆  toadstool
    AddPrefabPostInit("toadstool", function(inst)
        if inst.components.freezable then
            inst:RemoveComponent("freezable")
        end
        if inst.components.sleeper ~= nil then
            inst.components.sleeper.resistance = 9999
        end
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil  and data.attacker and  data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost") then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(2, OnBossAttackedCooldown)
                
            end
        end)
    
    end)
    --剧毒蛤蟆  toadstool_dark
    AddPrefabPostInit("toadstool_dark", function(inst)
        if inst.components.freezable then
            inst:RemoveComponent("freezable")
        end
        if inst.components.sleeper ~= nil then
            inst.components.sleeper.resistance = 9999
        end
    end)
    --中庭  stalker_atrium
    AddPrefabPostInit("stalker_atrium", function(inst)
        inst:ListenForEvent("attacked", function(inst, data)
            if   inst._cdtaskboss_attacked == nil and data ~= nil  and data.attacker and not data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost") then
                inst._cdtaskboss_attacked = inst:DoTaskInTime(.15, OnBossAttackedCooldown)
                GLOBAL.SpawnPrefab("achiv_bramblefx_armor"):SetFXOwner(inst)
            end
            if   inst._cdtaskboss_playerattack == nil and data ~= nil  and data.attacker and  data.attacker:HasTag("player") and not  data.attacker:HasTag("playerghost") then
                inst._cdtaskboss_playerattack = inst:DoTaskInTime(5, OnBossAttackedCooldownPlayer)
                GLOBAL.SpawnPrefab("achiv_bramblefx_armor"):SetFXOwner(inst)
            end
        end)
    end)
    --犀牛  minotaur
    --邪天翁   malbatross
end