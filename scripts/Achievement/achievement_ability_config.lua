local achievement_ability_config = {
    ability_cost =
    {
        {ability = "speedup", cost = 15, default_value = 0,},
        {ability = "damageup", cost = 10, default_value = 0,},
        {ability = "absorbup", cost = 15, default_value = 0,},
        {ability = "crit", cost = 20, default_value = 0,},
        {ability = "thornss", cost = 40, default_value = 0,canswitch = true,},
        {ability = "electric", cost = 88, default_value = 0,canswitch = true,},
        {ability = "firmarmor", cost = 25, default_value = 0,},
        {ability = "woodieability", cost = 50, default_value = false,},
        {ability = "healthregen", cost = 25, default_value = 0,},
        {ability = "plantfriend", cost = 40, default_value = false,canswitch = true,},
        {ability = "fireflylight", cost = 50, default_value = false,canswitch = true,},
        {ability = "nomoist", cost = 25, default_value = false,canswitch = true,},
        {ability = "doubledrop", cost = 80, default_value = false,},
        {ability = "goodman", cost = 50, default_value = false,},
        {ability = "fishmaster", cost = 40, default_value = false,},
        {ability = "pickmaster", cost = 40, default_value = false,},
        {ability = "chopmaster", cost = 40, default_value = false,},
        {ability = "cookmaster", cost = 40, default_value = false,canswitch = true,},
        {ability = "buildmaster", cost = 88, default_value = false,},
        {ability = "refresh", cost = 60, default_value = false,},
        {ability = "icebody", cost = 50, default_value = false,},
        {ability = "firebody", cost = 40, default_value = false,},
        {ability = "supply", cost = 50, default_value = false,},
        {ability = "reader", cost = 70, default_value = false,},
        {ability = "justicerain", cost = 15, default_value = false,},
        {ability = "jump", cost = 50, default_value = false,canswitch = true,},
        {ability = "level", cost = 0, default_value = true,canswitch = true,},
        {ability = "fastbuild", cost = 50, default_value = false,},
        {ability = "soulhopcopy", cost = 50, default_value = false,},
        {ability = "morestrongstomach", cost = 25, default_value = false,},
        {ability = "shadowsubmissive", cost = 45, default_value = false,canswitch = true,},
        {ability = "eventtechnology", cost = 30, default_value = false,},
        {ability = "murlocdisguise", cost = 45, default_value = false,canswitch = true,},
        {ability = "fastcollection", cost = 35, default_value = false,},
        {ability = "ghostly_friend", cost = 70, default_value = false,},
        {ability = "waxwellfriend", cost = 50, default_value = false,},
        {ability = "flashy", cost = 20, default_value = false,canswitch = true,},
        {ability = "fearless", cost = 50, default_value = false,},
        {ability = "ancientstation", cost = 20, default_value = false,},
        {ability = "autorepair", cost = 40, default_value = false,},
        {ability = "magicpepair", cost = 30, default_value = false,},
        {ability = "moonstone", cost = 20,default_value = false,},
        {ability = "timemanager", cost = 88, default_value = false,},
        --{ability = "moonaltar", cost = 20,default_value = false,},
    },
    ability_ratio=
    {
        ["thornss"] = 1,
        ["electric"] = 1,
        ["firmarmor"] = 1,
        ["woodieability"] = TUNING.WILSON_HUNGER_RATE*.02,
        ["healthregen"] = .2,
        ["plantfriend"] = .2,
        ["speedup"] = .05,
        ["damageup"] = .05,
        ["absorbup"] = .05,
        ["crit"] = 5,
    },
    attributes_cost = 
    {
        ["hungerup"] = 1,
        ["sanityup"] = 1,
        ["healthup"] = 1,
    },
    
}
local modname = KnownModIndex:GetModActualName("New Achivement")
local cost_ratio  = GetModConfigData("abilityifficulty",modname)
local function PretreatmentAchievementAbilityConfig()
    achievement_ability_config.id2ability = {}
    for _,v in ipairs(achievement_ability_config.ability_cost) do
        v.cost = math.ceil(v.cost * cost_ratio)
        achievement_ability_config.id2ability[v.ability] = v
    end
end
PretreatmentAchievementAbilityConfig()
return achievement_ability_config