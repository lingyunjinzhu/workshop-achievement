ChooseTranslationTable = ChooseTranslationTable or function() end
name ="New Achivement"
description = "Achievement and level(Reburn)"
author = "ACLegend"
version = "2.1.7"

forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {}


local MODINFO_NAME = {
    CAN_LEARN = {
        "Can Learn Ability",
        ["zh"] = "是否能学习能力",
        ["en"] = "Can Learn Ability",
    },
    START_AWARD = {
        "Give gifts at the start",
        ["zh"] = "开局是否送物品",
        ["en"] = "Give gifts at the start",
    },
    BOSS_STRENGTHEN = {
        "Boss strengthen",
        ["zh"] = "BOSS加强",
        ["en"] = "Boss strengthen",
    },
    RETRUN_POINT = {
        "Rebate points for reset ability",
        ["zh"] = "重置时返回成就百分比",
        ["en"] = "return points percent",
    },
    SHOW_TITLE = {
        "Show title",
        ["zh"] = "显示称号",
        ["en"] = "Show title",
    },
    LANGUAGE = {
        "Language",
        ["zh"] = "语言",
        ["en"] = "Language",
    },
    DIFFICULTY = {
        "Difficulty",
        ["zh"] = "成就完成难度",
        ["en"] = "Difficulty",
    },
    ABILITYIFFICULTY = {
        "Ability Difficulty",
        ["zh"] = "能力学习消耗点数",
        ["en"] = "Ability Cost",
    },
    MAX_DAMAGE = {
        "Max Damage up",
        ["zh"] = "提升攻击最大学习次数",
        ["en"] = "Max Damage up",
    },
    MAX_SPEED = {
        "Max Speed up",
        ["zh"] = "提升速度最大学习次数",
        ["en"] = "Max Speed up",
    },
    MAX_ABSORB = {
        "Max Absorb up",
        ["zh"] = "提升防御最大学习次数",
        ["en"] = "Max Absorb up",
    },
    MAX_CRIT = {
        "Max Crit up",
        ["zh"] = "提升暴击最大学习次数",
        ["en"] = "Max Crit up",
    },
}
configuration_options =
{
    {
        name = "checkcoin",
        label =  ChooseTranslationTable(MODINFO_NAME.CAN_LEARN),
        hover = "Can learn ability",
        options =   {
     
                        {description = "YES", data = false},
                        {description = "NO", data = true},

                    },
        default = false,
    },
    {
        name = "checkstart",
        label = ChooseTranslationTable(MODINFO_NAME.START_AWARD),
        hover = "give gifts at the start",
        options =   {
                        {description = "YES", data = true},
                        {description = "NO", data = false},
                    },
        default = true,
    },
    {
        name = "bossstrengthen",
        label = ChooseTranslationTable(MODINFO_NAME.BOSS_STRENGTHEN),
        hover = "Boss strengthen",
        options =   {
     
                        {description = "YES", data = true},
                        {description = "NO", data = false},

                    },
        default = false,
    },
    {
        name = "returnpoint",
        label = ChooseTranslationTable(MODINFO_NAME.RETRUN_POINT),
        hover = "Rebate points for reset ability",
        options =   {
     
                        {description = "100%", data = 1.0},
                        {description = "95%", data = 0.95},
                        {description = "90%", data = 0.9},
                        {description = "85%", data = 0.85},
                        {description = "80%", data = 0.8},
                        {description = "75%", data = 0.75},
                        {description = "70%", data = 0.70},
                        {description = "65%", data = 0.65},
                        {description = "60%", data = 0.60},
                        {description = "50%", data = 0.50},
                    },
        default = 0.85,
    },
    {
        name = "showtitle",
        label = ChooseTranslationTable(MODINFO_NAME.SHOW_TITLE),
        hover = "show title",
        options =   {
                        {description = "SHOW", data = true},
                        {description = "HIDE", data = false},
                    },
        default = true,
    },
    {
        name = "language",
        label = ChooseTranslationTable(MODINFO_NAME.LANGUAGE),
        hover = "language",
        options =   {
                        {description = "简体中文", data = "zh"},
                        {description = "English", data = "en"},
                    },
        default = "zh",
    },
    {
        name = "coindifficulty",
        label = ChooseTranslationTable(MODINFO_NAME.DIFFICULTY),
        hover = "Difficulty",
        options =   {
                        {description = "EAZY",hover = "0.5 times", data = 0.5},
                        {description = "NORMAL",hover = "1 times",data = 1},
                        {description = "HARD",hover = "1.5 times", data = 1.5},
                        {description = "NIGHTMARE",hover = "2 times", data = 2},
                    },
        default = 1,
    },
    {
        name = "abilityifficulty",
        label = ChooseTranslationTable(MODINFO_NAME.ABILITYIFFICULTY),
        hover = "Ability learning consumption points multiplier",
        options =   {
                        {description = "CHEAP",hover = "0.5 times", data = 0.5},
                        {description = "NORMAL",hover = "1 times", data = 1},
                        {description = "EXPENSIVE",hover = "1.5 times", data = 1.5},
                        {description = "VERY EXPENSIVE",hover = "2 times", data = 2},
                    },
        default = 1,
    },
    {
        name = "max_damageup",
        label = ChooseTranslationTable(MODINFO_NAME.MAX_DAMAGE),
        hover = "Maximum number of learning damageup",
        options =   {
                        {description = "5",hover = "5", data = 5},
                        {description = "10",hover = "10", data = 10},
                        {description = "15",hover = "15", data = 15},
                        {description = "20",hover = "20", data = 20},
                        {description = "25",hover = "25", data = 25},
                        {description = "30",hover = "30", data = 30},
                        {description = "35",hover = "35", data = 35},
                        {description = "40",hover = "40", data = 40},
                    },
        default = 5,
    },
    {
        name = "max_speedup",
        label = ChooseTranslationTable(MODINFO_NAME.MAX_SPEED),
        hover = "Maximum number of learning speedup",
        options =   {
                        {description = "5",hover = "5", data = 5},
                        {description = "10",hover = "10", data = 10},
                        {description = "15",hover = "15", data = 15},
                        {description = "20",hover = "20", data = 20},
                        {description = "25",hover = "25", data = 25},
                        {description = "30",hover = "30", data = 30},
                        {description = "35",hover = "35", data = 35},
                        {description = "40",hover = "40", data = 40},
                    },
        default = 5,
    },
    {
        name = "max_absorbup",
        label = ChooseTranslationTable(MODINFO_NAME.MAX_ABSORB),
        hover = "Maximum number of learning defenseup",
        options =   {
                        {description = "5",hover = "5", data = 5},
                        {description = "10",hover = "10", data = 10},
                        {description = "15",hover = "15", data = 15},
                        {description = "20",hover = "20", data = 20},
                        {description = "25",hover = "25", data = 25},
                        {description = "30",hover = "30", data = 30},
                        {description = "35",hover = "35", data = 35},
                        {description = "40",hover = "40", data = 40},
                    },
        default = 5,
    },
    {
        name = "max_crit",
        label = ChooseTranslationTable(MODINFO_NAME.MAX_CRIT),
        hover = "Maximum number of learning crit",
        options =   {
                        {description = "5",hover = "5", data = 5},
                        {description = "10",hover = "10", data = 10},
                        {description = "15",hover = "15", data = 15},
                        {description = "20",hover = "20", data = 20},
                    },
        default = 20,
    },
}