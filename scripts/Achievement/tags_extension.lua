local mod = "DSTAchievement"
local tags_enum =
{
	--basic
    "reader",

    --wilson
    "bearded",
    "alchemist",
    "gem_alchemistI",
    "gem_alchemistII",
    "gem_alchemistIII",
    "ore_alchemistI",
    "ore_alchemistII",
    "ore_alchemistIII",
    "ick_alchemistI",
    "ick_alchemistII",
    "ick_alchemistIII",
    "skill_wilson_allegiance_shadow",
    "player_shadow_aligned",
    "player_lunar_aligned",

    --willow
    "pyromaniac",
    "heatresistant",
    "controlled_burner",
    "ember_master",
    
    --wolfgang
    "wolfgang_coach",
    "wolfgang_dumbbell_crafting",
    "wolfgang_overbuff_1",
    "wolfgang_overbuff_2",
    "wolfgang_overbuff_3",
    "wolfgang_overbuff_4",
    "wolfgang_overbuff_5",
    "mightiness_normal",

    --wendy
    "ghostlyfriend",
    "elixirbrewer",

    --wx78
    "electricdamageimmune",
    "chessfriend",
    "HASHEATER",
    "soulless",

    --wickerbottom
    "insomniac",
    "bookbuilder",

    --woodie
    "wereplayer",
    "inherentshadowdominance",
    "shadowdominance",
    "woodcutter",
    "polite",
    "werehuman",
    "wereness",
    "beaver",
    "cursemaster",
    "toughworker",
    "weremoosecombo",
    "woodcarver1",
    "woodcarver2",
    "woodcarver3",
    "woodiequickpicker",
    "leifidolcrafter",

    --wes


    --waxwell
    "shadowmagic",
    "dappereffects",
    "magician",

    --wathgrithr
    "valkyrie",
    "battlesinger",
    "battlesongshadowalignedmaker",
    "battlesonglunaralignedmaker",
    "spearwathgrithrlightningmaker",
    "wathgrithrimprovedhatmaker",
    "saddlewathgrithrmaker",
    "battlesongcontainermaker",
    "battlesonginstantrevivemaker",

    --webber
    "playermonster",
    "monster",
    "dualsoul",
    "fastpicker",

    --winona
    "handyperson",
    "fastbuilder",
    "hungrybuilder",

    --warly
    "professionalchef",
    "expertchef",
    
    --wortox
    "soulstealer",
    "souleater",

    --wormwood
    "plantkin",
    "self_fertilizable",
    "farmplantidentifier",
    "saplingcrafter",
    "berrybushcrafter",
    "juicyberrybushcrafter",
    "reedscrafter",
    "lureplantcrafter",
    "syrupcrafter",
    "farmplantfastpicker",
    "carratcrafter",
    "lightfliercrafter",
    "fruitdragoncrafter",

    --wurt
    "playermerm",
    "merm",
    "mermguard",
    "mermfluent",
    "merm_builder",
    "wet",
    "stronggrip",
    "aspiring_bookworm",

    --walter
    "pebblemaker",
    "pinetreepioneer",
    "allergictobees",
    "efficient_sleeper",
    "dogrider",
    "nowormholesanityloss",
    "storyteller",

    --wanda
    "slowbuilder",
    "clockmaker",
    "health_as_oldage",

}

-- 去重 避免上面手误多添加了重复tag
local dst_tags = {}
for _,v in ipairs(tags_enum) do
    dst_tags[v] = true
end

local function AddTag(inst, tag, ...)
    if not inst or not tag then return end
    if dst_tags[tag] then
        inst[mod].Tags[tag]:set_local(false)
        inst[mod].Tags[tag]:set(true)
    else
        return inst[mod].AddTag(inst, tag, ...)
    end
end

local function RemoveTag(inst, tag, ...)
    if not inst or not tag then return end
    if dst_tags[tag] then
        inst[mod].Tags[tag]:set_local(true)
        inst[mod].Tags[tag]:set(false)
    else
        return inst[mod].RemoveTag(inst, tag, ...)
    end
end

local function HasTag(inst, tag, ...)
    if not inst or not tag then return end
    if dst_tags[tag] then
        return inst[mod].Tags[tag]:value()
    else
        return inst[mod].HasTag(inst, tag, ...)
    end
end

function ReplaceOriginTag(inst)
    inst[mod] = {
        AddTag = inst.AddTag,
        HasTag = inst.HasTag,
        RemoveTag = inst.RemoveTag,
        Tags = {}
    }
    inst.AddTag = AddTag
    inst.HasTag = HasTag
    inst.RemoveTag = RemoveTag
    for tag, _ in pairs(dst_tags) do
        inst[mod].Tags[tag] = net_bool(inst.GUID, mod .. "." .. tag,
                                     mod .. "." .. tag .. "dirty")
        if inst[mod].HasTag(inst, tag) then
            inst[mod].RemoveTag(inst, tag)
            inst[mod].Tags[tag]:set_local(false)
            inst[mod].Tags[tag]:set(true)
        else
            inst[mod].Tags[tag]:set(false)
        end
    end

end

AddPlayerPostInit(function(inst) 
    ReplaceOriginTag(inst)
end)
