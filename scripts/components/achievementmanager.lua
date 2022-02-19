local achievement_config = require("Achievement.achievement_config")

local function InitAllAchievement(inst)
    for _,v in pairs(achievement_config.idconfig) do
        inst[v.check] = false
        inst[v.current] = v.default_current or 0
    end
end

local function InitPropsTable()
    local props_table = {}
    for k,v in pairs(achievement_config.idconfig) do 
        props_table[v.check] =function(self,value) 
            self.inst[v.check]:set(value and 1 or 0) 
        end
        props_table[v.current] = function(self,value) 
            self.inst[v.current]:set(value) 
        end
    end
    return props_table
end

local achievementmanager = Class(function(self, inst)
    self.inst = inst
    InitAllAchievement(self)
end,
nil,InitPropsTable())

local function SaveData(src)
    local data = {}
    for k,v in pairs(achievement_config.idconfig) do
        data[v.check] = src[v.check] 
        data[v.current] = src[v.current] 
    end
    return data
end

local function LoadData(inst,data)
    for _,v in pairs(achievement_config.idconfig) do
        inst[v.check] = data[v.check] or false
        inst[v.current] = data[v.current] or v.default_current or 0
    end
end
--保存
function achievementmanager:OnSave()
    return SaveData(self)
end

--载入
function achievementmanager:OnLoad(data)
    LoadData(self,data)
    self:OnLoadedPost()
end

function achievementmanager:OnLoadedPost()
    self.inst:PushEvent("updateTitle", 
    {level = self.currenta_a4amount,
    cur_exp = self.currenta_a2amount,
    next_exp = self.currenta_a3amount,
    })
end


----100exp的食物
local foods_normal_exp = {
    "butterflymuffin",
    "frogglebunwich",
    "honeyham",
    "dragonpie",
    "taffy",
    "pumpkincookie",
    "kabobs",
    "baconeggs",
    "bonestew",
    "perogies",
    "fruitmedley",
    "fishtacos",
    "waffles",
    "turkeydinner",
    "fishsticks",
    "stuffedeggplant",
    "honeynuggets",
    "jammypreserves",
    "monsterlasagna",
    "unagi",
    "flowersalad",
    "icecream",
    "watermelonicle",
    "trailmix",
    "hotchili",
    "guacamole",
    "freshfruitcrepes",
    "pancakefruit",
    "bisque",
    "coffeeham",
    "surfnturf",
    "bananapop",
    "coffee",
    "californiaroll",
    "cave_chocolate",
    "caviar",
    "bs_food_03",
    "bs_food_08",
    "bs_food_16",
    "bs_food_26",
    "food_aicopy",
    "yotp_food2",
    "yotp_food1",
    "potatotornado",
    "mashedpotatoes",
    "asparagussoup",
    "vegstinger",
    "bananapop",
    "ceviche",
    "salsa",
    "pepperpopper",
    "bs_food_04",
    "bs_food_22",
    "orfeijoada", 
    "seafoodgumbo",   
    "nettlelosange",   
    "meatballs",
    "jellybean",

    "lobsterdinner",
    "lobsterbisque",
}
local medium_exp_post = {"_spice_chili","_spice_sugar","_spice_garlic","_spice_salt"}

local foods_high_exp = 
{
    food = 
    {
        "bs_food_33", 
        "bs_food_34",
        "bs_food_40",
        "bs_food_53",
        "bs_food_56",
        "bs_food_67",
        "bs_food_69",

        "glommerfuel",
        "bs_food_03",
        "bs_food_05",
        "bs_food_08",
        "bs_food_32",
        "bs_food_37",
        "bs_food_49",
        "bs_food_54",
        "bs_food_59",
        "bs_food_63",
        "bs_food_65",

        "bs_food_27",
        "bs_food_36",
        "bs_food_38",
        "bs_food_47",
        "bs_food_52",
        "bs_food_55",
        "bs_food_57",
        "bs_food_58",
        "bs_food_64",
    },
    tag = 
    {
        "nightmarepie_ai",
        "voltgoatjelly_ai",
        "glowberrymousse_ai",
        "frogfishbowl_ai",
        "dragonchilisalad_ai",
        "gazpacho_ai",
        "potatosouffle_ai",
        "monstertartare_ai",
        "freshfruitcrepes_ai",
        "bonesoup_ai",
        "moqueca_ai",
    }
}

local foods_very_high_exp =
{
    "gears",
    "deerclops_eyeball",
    "minotaurhorn",
    "trunk_summer",
    "trunk_winter",
    "mandrake",
    "cookedmandrake",
    "lobsterdinner",
    "trunk_cooked",
}
local FOOD_EXP_BASIC = 5
local FOOD_EXP_NORMAL = 100
local FOOD_EXP_MEDIUM = 200
local FOOD_EXP_HIGH = 350
local FOOD_EXP_VERY_HIGH = 500
local FOOD_EXP_EXPBEAN = 2000

local  function checkfoodexp(food)
    if table.contains(foods_normal_exp,food.prefab) then
        return FOOD_EXP_NORMAL
    end

    for _,v in ipairs(medium_exp_post) do
        if string.match(food.prefab,v) then
            return FOOD_EXP_MEDIUM
        end
    end

    if table.contains(foods_high_exp.food,food.prefab) then
        return FOOD_EXP_HIGH
    end
    for _,v in ipairs(foods_high_exp.tag) do
        if food:HasTag(v) then
            return FOOD_EXP_HIGH
        end
    end
    if table.contains(foods_very_high_exp,food.prefab) or food:HasTag("mandrakesoup_ai")  then
        return FOOD_EXP_VERY_HIGH
    end

    if food.prefab == "expbean" then
        return FOOD_EXP_EXPBEAN
    end
    return FOOD_EXP_BASIC
end

--检查灵魂携带上限
local function IsSoul(item)
    return item.prefab == "wortox_soul"
end
local function GetStackSize(item)
    return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
end

local function SortByStackSize(l, r)
    return GetStackSize(l) < GetStackSize(r)
end
local function CheckSoulsAdded(inst)
    local souls = inst.components.inventory:FindItems(IsSoul)
    local count = 0
    for i, v in ipairs(souls) do
        count = count + GetStackSize(v)
    end
    if count > 30 then
        --convert count to drop count
        count = count - math.floor(20) + math.random(0, 2) - 1
        table.sort(souls, SortByStackSize)
        local pos = inst:GetPosition()
        for i, v in ipairs(souls) do
            local vcount = GetStackSize(v)
            if vcount < count then
                inst.components.inventory:DropItem(v, true, true, pos)
                count = count - vcount
            else
                if vcount == count then
                    inst.components.inventory:DropItem(v, true, true, pos)
                else
                    v = v.components.stackable:Get(count)
                    v.Transform:SetPosition(pos:Get())
                    v.components.inventoryitem:OnDropped(true)
                end
                break
            end
        end
        inst.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE*2)
    end
    --移除玩家身上的灵魂
    if inst.prefab ~= "wortox" and  inst.components.achievementability.soulhopcopy ~= true  then
        for k,v in pairs(inst.components.inventory.itemslots) do
            if v and v.prefab == "wortox_soul"  then
                v:Remove()
            end
        end
    end
end
local function OnRestoreSoul(victim)
    victim.nosoultask = nil
end

local function OnRestoreExp(victim)
    victim.noexptask = nil
end

local function OnRestoreExpbean(victim)
    victim.noexpbeantask = nil
end

local function SpawnSoulAt(x, y, z, victim)
    local fx = SpawnPrefab("wortox_soul_spawn")
    fx.Transform:SetPosition(x, y, z)
    fx:Setup(victim)
end
local function SpawnSoulsAt(victim, numsouls)
    local x, y, z = victim.Transform:GetWorldPosition()
    if numsouls == 2 then
        local theta = math.random() * 2 * PI
        local radius = .4 + math.random() * .1
        SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim)
        theta = GetRandomWithVariance(theta + PI, PI / 15)
        SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim)
    else
        SpawnSoulAt(x, y, z, victim)
        if numsouls > 1 then
            numsouls = numsouls - 1
            local theta0 = math.random() * 2 * PI
            local dtheta = 2 * PI / numsouls
            local thetavar = dtheta / 10
            local theta, radius
            for i = 1, numsouls do
                theta = GetRandomWithVariance(theta0 + dtheta * i, thetavar)
                radius = 1.6 + math.random() * .4
                SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim)
            end
        end
    end
end

--通用效果器
function achievementmanager:seffc(inst, tag)
    if achievement_config.idconfig[tag] and STRINGS.ACHIEVEMENT_LIST[tag] and achievement_config.idconfig[tag] and achievement_config.idconfig[tag].point then
        SpawnPrefab("seffc").entity:SetParent(inst.entity)
        local name = tag
        local description = tag
        if STRINGS.ACHIEVEMENT_LIST[tag] then
            name = STRINGS.ACHIEVEMENT_LIST[tag].name
            description = STRINGS.ACHIEVEMENT_LIST[tag].desc
        end
        local desc = string.format(description,achievement_config.idconfig[tag].need_amount )
        TheNet:Announce(string.format(STRINGS.ACHIEVEMENT_FINISH,inst:GetDisplayName(),desc, name))
        local str_get_point = string.format( STRINGS.ACHIEVEMENT_AWARD, name,achievement_config.idconfig[tag].point)
        inst.components.achievementability:coinDoDelta(achievement_config.idconfig[tag].point)
        if achievement_config.idconfig[tag].award then
            local award_item = SpawnPrefab(achievement_config.idconfig[tag].award)
            if award_item ~= nil then
                inst.components.inventory:GiveItem(award_item, nil, inst:GetPosition())
            end
        end
    else
        print("+++++++++++++++no tag ", tag)
    end
end

function achievementmanager:seffc_boss(inst, bossname, killnums)
    if bossname and killnums then
        SpawnPrefab("seffc").entity:SetParent(inst.entity)
        TheNet:Announce(string.format(STRINGS.ACHIEVEMENT_TOTAL_KILL_AWARD,inst:GetDisplayName(),bossname,killnums))
        inst.components.achievementability:coinDoDelta(1)
    end
end

--经验增加计算
function achievementmanager:sumexp(inst, foodexp)
	self.currenta_a2amount = self.currenta_a2amount + foodexp
	while(self.currenta_a2amount >= self.currenta_a3amount)
	do
   		self.currenta_a2amount = self.currenta_a2amount - self.currenta_a3amount
        self.currenta_a3amount = self.currenta_a3amount  + 100    --升级需要de经验
        self.currenta_a4amount = self.currenta_a4amount + 1    --等级 
        self:seffc(inst, "a_a4")
    end
    self.inst:PushEvent("updateTitle", 
    {level = self.currenta_a4amount,
    cur_exp = self.currenta_a2amount,
    next_exp = self.currenta_a3amount,
    })
	if  inst.components.achievementability and inst.components.achievementability.levelswitch then
    	inst.components.talker:Say( string.format(STRINGS.LEVLE_INFO,self.currenta_a4amount,self.currenta_a2amount,self.currenta_a3amount,foodexp))
    end
end

function achievementmanager:getExp()
    return self.currenta_a2amount,self.currenta_a3amount
end
function achievementmanager:getLevel()
    return self.currenta_a4amount
end

local function checkfood(config,food)
    if config.tag then
        if type(config.tag) == "table" then
            for _,v in pairs(config.tag) do
                if food:HasTag(v) then
                    return true
                end
            end
            return false
        elseif config.tag then
            if food:HasTag(config.tag) then
                return true
            else
                return false
            end
        end
    elseif config.food then
        if type(config.food) == "table" then
            if table.contains(config.food,food.prefab) then
                return true
            else
                return false
            end
        elseif food.prefab == config.food then
            return true
        else 
            return false
        end
    end
    return true
end

local no_drop_souls_tag =
{   
    "structure",
    "wall",
    "balloon",
    "soulless",
    "chess",
    "shadow",
    "shadowcreature",
    "shadowminion",
    "shadowchesspiece",
    "groundspike",
    "smashable",
}



function achievementmanager:CheckGetSoul(inst,data)
    if inst.components.achievementability.soulhopcopy == true then
      local victim = data.victim
      local hassoul = true
      for _,v in pairs(no_drop_souls_tag) do
          if victim:HasTag(v) then
              hassoul = false
          end
      end
      if victim and hassoul and victim.components.combat ~= nil and victim.components.health ~= nil then
          if  victim.nosoultask == nil and victim:IsValid() and  not inst.components.health:IsDead()  then
              victim.nosoultask = victim:DoTaskInTime(5, OnRestoreSoul)
              if inst.components.inventory and inst.components.inventory:Has("wortox_soul", 1) then
                  SpawnSoulsAt(victim,((victim:HasTag("dualsoul") and 2) or (victim:HasTag("epic") and math.random(7, 8)) or 1) * (data.stackmult or 1))
              else
                  local soul = SpawnPrefab("wortox_soul")
                  if soul.components.stackable ~= nil then
                      soul.components.stackable:SetStackSize(((victim:HasTag("dualsoul") and 2) or (victim:HasTag("epic") and math.random(7, 8)) or 1) * (data.stackmult or 1))
                  end
                  inst.components.inventory:GiveItem(soul, nil, inst:GetPosition())
                  CheckSoulsAdded(inst)
              end
          end
      end
  end
end

--新的开始
function achievementmanager:intogamefn(inst)
    inst:DoTaskInTime(3, function()
        if self.checkintogame ~= true then
            self.checkintogame = true
            self:seffc(inst, "intogame")
            if self.all ~= true and TUNING.CHECKSTART then
                inst:DoTaskInTime(1, function()
                	if inst.prefab ~= "wathgrithr" then
        				local item3 = SpawnPrefab("spear_wathgrithr", "spear_wathgrithr_wrestle", nil,inst.userid)
        				if item3 ~= nil then 
                    		inst.components.inventory:GiveItem(item3, nil, inst:GetPosition())
                    	end
                    	local item4 = SpawnPrefab("wathgrithrhat", "wathgrithrhat_wrestle", nil,inst.userid)
                    	if item4 ~= nil then
                    		inst.components.inventory:GiveItem(item4, nil, inst:GetPosition())
                    	end
    				end
                    local item1 = SpawnPrefab("halloweenpotion_health_large")
                    item1.components.stackable:SetStackSize(2)
                    inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
                    local item2 = SpawnPrefab("redlantern2")
                    inst.components.inventory:GiveItem(item2, nil, inst:GetPosition())
                    local item5 = SpawnPrefab("pumpkin_lantern")
                    inst.components.inventory:GiveItem(item5, nil, inst:GetPosition())
                end)
            end
        end
    end)
end

local function _cook_action()
    local COOK = ACTIONS.COOK
    local old_cook_fn = COOK.fn
    COOK.fn = function(act, ...)
        local result = old_cook_fn(act)
        local stewer = act.target.components.stewer
        local achievementability = act.doer.components.achievementability
        local achievementmanager = act.doer.components.achievementmanager
        if result and stewer ~= nil then
            for k,v in pairs(achievement_config.category_config["cook"]) do
                if not achievementmanager[v.check] then
                    if not v.product then
                        achievementmanager[v.current] = achievementmanager[v.current] + 1
                    elseif v.product == stewer.product then
                        achievementmanager[v.current] = achievementmanager[v.current] + 1
                    end
                    if achievementmanager[v.current] >= v.need_amount then
                        achievementmanager[v.check] = true
                        achievementmanager:seffc(act.doer, v.id)
                    end
                end
            end
            if achievementability.cookmaster and achievementability.cookmasterswitch then
                local fn = stewer.task.fn
                stewer.task:Cancel()
                fn(act.target, stewer)
            end
        end
    end
end

local function _give_action()
    local GIVE = ACTIONS.GIVE
    local old_give_fn = GIVE.fn
    GIVE.fn = function(act)
        local achievementmanager = act.doer.components.achievementmanager
        local result =  old_give_fn(act)
        if result then
            for _,v in pairs(achievement_config.category_config["give"]) do
                if not achievementmanager[v.check] then
                    if act.target.prefab == v.target and (not v.item  or v.item == act.invobject.prefab) then
                        achievementmanager[v.current] = achievementmanager[v.current] + 1
                    end
                    if achievementmanager[v.current] >= v.need_amount then
                        achievementmanager[v.check] = true
                        achievementmanager:seffc(act.doer, v.id)
                    end
                end
            end
        end
        return result
    end
end

local function DealAction()
    _cook_action()
    _give_action()
    --风滚草 
    local PICK = ACTIONS.PICK
    local old_pick_fn = PICK.fn
    PICK.fn = function(act, ...)
        local result =  old_pick_fn(act)
        if act.doer.components.achievementmanager then
            local achievementmanager = act.doer.components.achievementmanager
            if result and act.target and act.target.prefab  == "tumbleweed"  then
                if achievementmanager and  achievementmanager.checka_a70 ~= true then
                    achievementmanager.currenta_a70amount = achievementmanager.currenta_a70amount + 1
                    if achievementmanager.currenta_a70amount >= achievement_config.idconfig["a_a70"].need_amount then
                        achievementmanager.checka_a70 = true
                        achievementmanager:seffc(act.doer, "a_a70")
                    end
                end
            end
            if result and act.target and ( act.target.prefab  == "carrat_planted" or act.target.prefab  == "carrat" ) then  --carrat_planted   
                if achievementmanager and  achievementmanager.checkmoon_46 ~= true then
                    achievementmanager.currentmoon_46amount = achievementmanager.currentmoon_46amount + 1
                    if achievementmanager.currentmoon_46amount >= achievement_config.idconfig["moon_46"].need_amount then
                        achievementmanager.checkmoon_46 = true
                        achievementmanager:seffc(act.doer, "moon_46")
                    end
                end
            end
        end
        return  result
    end

    --填充蚊子血袋
    local FILL = ACTIONS.FILL
    local old_fill_fn = FILL.fn
    FILL.fn = function(act, ...)
        local result =  old_fill_fn(act)
        if act.doer.components.achievementmanager then
            local achievementmanager = act.doer.components.achievementmanager
            if result and act.invobject  and act.invobject.prefab  == "mosquitosack"  then 
                if achievementmanager and  achievementmanager.checkmoon_49 ~= true and act.invobject.onlytask == nil then
                    achievementmanager.currentmoon_49amount = achievementmanager.currentmoon_49amount + 1
                    act.invobject.onlytask = act.invobject:DoTaskInTime(1, function()  act.invobject.onlytask = nil  end )
                    if achievementmanager.currentmoon_49amount >= achievement_config.idconfig["moon_49"].need_amount then
                        achievementmanager.checkmoon_49 = true
                        achievementmanager:seffc(act.doer, "moon_49")
                    end
                end
            end
        end
        return  result
    end

    --修理 
    local REPAIR = ACTIONS.REPAIR
    local old_repair_fn = REPAIR.fn
    REPAIR.fn = function(act, ...)
        local result =   old_repair_fn(act)
        if act.doer.components.achievementmanager then
            local achievementmanager = act.doer.components.achievementmanager
            --修理废弃机械
            if result and act.target  and act.target:HasTag("chess") and act.target:HasTag("mech") and act.target.repaired == true then  
                if achievementmanager and  achievementmanager.checkmoon_47 ~= true  then
                    achievementmanager.currentmoon_47amount = achievementmanager.currentmoon_47amount + 1
                    if achievementmanager.currentmoon_47amount >= achievement_config.idconfig["moon_47"].need_amount then
                        achievementmanager.checkmoon_47 = true
                        achievementmanager:seffc(act.doer, "moon_47")
                    end
                end
            end

            -- 修理 坏的远古科技 c_spawn("ancient_altar_broken", 1) 
            if result and  act.target  and  act.target.prefab and act.target.prefab == "ancient_altar_broken" then
                local pos = Vector3(act.target.Transform:GetWorldPosition())
                    act.doer:DoTaskInTime(.1, function()
                        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 3)
                        for k,v in pairs(ents) do
                            if v.prefab == "ancient_altar" and v.components.ksmark.mark == false then
                                v.components.ksmark.mark = true
                                if achievementmanager and  achievementmanager.checkmoon_48 ~= true then
                                    achievementmanager.currentmoon_48amount = achievementmanager.currentmoon_48amount + 1
                                    if achievementmanager.currentmoon_48amount >= achievement_config.idconfig["moon_48"].need_amount then
                                        achievementmanager.checkmoon_48 = true
                                        achievementmanager:seffc(act.doer, "moon_48")
                                    end
                                end
                            end
                        end
                    end)
                if  act.target.components.workable and act.target.components.workable.workleft >= act.target.components.workable.maxwork  then
                    if achievementmanager and  achievementmanager.checkmoon_48 ~= true and act.doer.onlytask == nil then
                        achievementmanager.currentmoon_48amount = achievementmanager.currentmoon_48amount + 1
                        act.doer.onlytask = act.doer:DoTaskInTime(.5, function()  act.doer.onlytask = nil  end )
                        if achievementmanager.currentmoon_48amount >= achievement_config.idconfig["moon_48"].need_amount then
                            achievementmanager.checkmoon_48 = true
                            achievementmanager:seffc(act.doer, "moon_48")
                        end
                    end
                end
            end
        end
        return  result
    end

    --跳入    
    local JUMPIN = ACTIONS.JUMPIN
    local old_jumpin_fn = JUMPIN.fn
    JUMPIN.fn = function(act, ...)
        local result =   old_jumpin_fn(act)
        if  act.doer.components.achievementmanager then
            local achievementmanager = act.doer.components.achievementmanager
            --跳入虫洞   
            if result  and act.target  and act.target.prefab and act.target.prefab=="wormhole" then  
            
                if achievementmanager and  achievementmanager.checkmoon_35 ~= true and act.doer.onlytask == nil then
                    achievementmanager.currentmoon_35amount = achievementmanager.currentmoon_35amount + 1
                    act.doer.onlytask = act.doer:DoTaskInTime(1, function()  act.doer.onlytask = nil  end )
                    if achievementmanager.currentmoon_35amount >= achievement_config.idconfig["moon_35"].need_amount then
                        achievementmanager.checkmoon_35 = true
                        achievementmanager:seffc(act.doer, "moon_35")
                    end
                end
            end

            --跳入触手洞 
            if result  and act.target  and act.target.prefab and act.target.prefab=="tentacle_pillar_hole" then  
            
                if achievementmanager and  achievementmanager.checkmoon_36 ~= true and act.doer.onlytask == nil then
                    achievementmanager.currentmoon_36amount = achievementmanager.currentmoon_36amount + 1
                    act.doer.onlytask = act.doer:DoTaskInTime(1, function()  act.doer.onlytask = nil  end )
                    if achievementmanager.currentmoon_36amount >= achievement_config.idconfig["moon_36"].need_amount then
                        achievementmanager.checkmoon_36 = true
                        achievementmanager:seffc(act.doer, "moon_36")
                    end
                end
            end
        end
        return  result
    end
    ---随便说句话
    local Achiv_Old_Networking_Say = Networking_Say
    Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
        Achiv_Old_Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
        local anything_message = string.lower(message)
        if anything_message ~= nil and userid ~= nil then
            local player = UserToPlayer(userid)
            if player and player.components.achievementmanager then
                if player.components.achievementmanager.checkmoon_51 ~= true  then
                    player.components.achievementmanager.currentmoon_51amount = player.components.achievementmanager.currentmoon_51amount + 1
                    if player.components.achievementmanager.currentmoon_51amount == achievement_config.idconfig["moon_51"].need_amount then
                        player.components.achievementmanager.checkmoon_51 = true
                    end
                end
                if player.components.achievementmanager.checkmoon_56 ~= true  then
                    if message == "祈福" then
                        player.components.achievementmanager.currentmoon_56amount = player.components.achievementmanager.currentmoon_56amount + 1
                        if player.components.achievementmanager.currentmoon_56amount == achievement_config.idconfig["moon_56"].need_amount then
                            player.components.achievementmanager.checkmoon_56 = true
                        end
                    end
                end
            end
        end
    end

    --作祟    
    local HAUNT = ACTIONS.HAUNT
    local old_haunt_fn = HAUNT.fn
    HAUNT.fn = function(act, ...)
        local result =   old_haunt_fn(act)
        if  act.doer.components.achievementmanager then
            local achievementmanager = act.doer.components.achievementmanager  
            if result  and act.target  and act.target.prefab  then  
            
                if achievementmanager and  achievementmanager.checkseas_06 ~= true and act.doer.onlyhaunttask == nil then
                    achievementmanager.currentseas_06amount = achievementmanager.currentseas_06amount + 1
                    act.doer.onlyhaunttask = act.doer:DoTaskInTime(.21, function()  act.doer.onlyhaunttask = nil  end )
                    if achievementmanager.currentseas_06amount >= achievement_config.idconfig["seas_06"].need_amount then
                        achievementmanager.checkseas_06 = true
                        achievementmanager:seffc(act.doer, "seas_06")
                    end
                end
            end
        end
        return  result
    end
    --瞬移法杖 传送
    local BLINK = ACTIONS.BLINK
    local old_blink_fn = BLINK.fn
    BLINK.fn = function(act, ...)
        local result =   old_blink_fn(act)
        if  act.doer.components.achievementmanager then
            local achievementmanager = act.doer.components.achievementmanager
            if result  and act.invobject ~= nil  and act.invobject.components.blinkstaff ~= nil   then  
                if achievementmanager and  achievementmanager.checkseas_13 ~= true and act.doer.onlyblinktask == nil then
                    achievementmanager.currentseas_13amount = achievementmanager.currentseas_13amount + 1
                    act.doer.onlyblinktask = act.doer:DoTaskInTime(.21, function()  act.doer.onlyblinktask = nil  end )
                    if achievementmanager.currentseas_13amount >= achievement_config.idconfig["seas_13"].need_amount then
                        achievementmanager.checkseas_13 = true
                        achievementmanager:seffc(act.doer, "seas_13")
                    end
                end
            end
        end
        return  result
    end
end

function achievementmanager:OnEatAchievementCheck(inst)
    -- check eat
    inst:DoTaskInTime(1, function()
        local oldeatfn = inst.components.eater.oneatfn
        function inst.components.eater.oneatfn(inst, food)
            --第一口饭
            if self.checkfirsteat ~= true then
                self.checkfirsteat = true
                self:seffc(inst, "firsteat")
            end
            if inst.components.achievementability.level == true  then
                self:sumexp(inst,checkfoodexp(food))
            end
            for k,v in pairs(achievement_config.category_config["eat"]) do
                if inst.components.achievementmanager[v.check] ~= true and checkfood(v,food) then
                    inst.components.achievementmanager[v.current] = inst.components.achievementmanager[v.current] + 1
                    if inst.components.achievementmanager[v.current] >= v.need_amount then
                        inst.components.achievementmanager[v.check] = true
                        self:seffc(inst, v.id)
                    end
                end
            end
            if oldeatfn ~= nil then
                oldeatfn(inst, food)
            end
        end
    end)
end

function achievementmanager:_periodic_task(inst)
    for k,v in pairs(achievement_config.category_config["periodic_task"]) do
        if not self[v.check] then
            if v.sub_finish_type and v.sub_finish_type == "equip" then
                local items = {}
                items[#items + 1] = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                items[#items + 1] = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                items[#items + 1] = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
                for _, item in ipairs(items) do
                    if not self[v.check] and not inst:HasTag("playerghost") and  item ~= nil and item.prefab == v.equip then
                        self[v.current] = self[v.current] + 1
                    end
                end
            elseif v.sub_finish_type == "consume" then
                if type(v.item) == "table" then
                    local has = true
                    for _,item in pairs(v.item) do
                        if inst.replica and inst.replica.inventory and not inst.replica.inventory:Has(item,v.need_amount) then
                            has = false
                        end
                    end
                    if has then
                        for _,item in pairs(v.item) do
                            inst.components.inventory:ConsumeByName(item, v.need_amount) 
                        end
                        self[v.current] = v.need_amount
                    end
                else
                    if inst.replica and inst.replica.inventory and inst.replica.inventory:Has(v.item,v.need_amount) then 
                        inst.components.inventory:ConsumeByName(v.item, v.need_amount) 
                        self[v.current] = v.need_amount
                    end
                end
            elseif v.sub_finish_type == "hold" then
                if type(v.item) == "table" then
                    local has = true
                    for _,item in pairs(v.item) do
                        if inst.replica and inst.replica.inventory and not inst.replica.inventory:Has(item,v.need_amount) then
                            has = false
                        end
                    end
                    if has then
                        self[v.current] = v.need_amount
                    end
                else
                    if inst.replica and inst.replica.inventory and inst.replica.inventory:Has(v.item,v.need_amount) then 
                        self[v.current] = v.need_amount
                    end
                end
            elseif v.special_condition and v.special_condition(self,inst,v) then
                 self[v.current] = self[v.current] + 1
            end
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end
        end
    end
end

function achievementmanager:TimingTask(inst)
    inst:DoPeriodicTask(1, function()
        CheckSoulsAdded(inst)
        self:_periodic_task(inst)
        -----随便说句话
        if self.checkmoon_51 == true  and self.currentmoon_51amount == achievement_config.idconfig["moon_51"].need_amount then
            self.currentmoon_51amount = self.currentmoon_51amount + 1 
            self:seffc(inst, "moon_51")
        end
        -- 祈福
        if self.checkmoon_56 == true  and self.currentmoon_56amount == achievement_config.idconfig["moon_56"].need_amount then
            self.currentmoon_56amount = self.currentmoon_56amount + 1 
            self:seffc(inst, "moon_56")
        end

        --月圆靠近插有唤星杖的月台 6
        if   self.checkmoon_30 ~= true and inst.components.health.currenthealth > 0 and inst:HasTag("player") and not  inst:HasTag("playerghost") then
            local pos = Vector3(inst.Transform:GetWorldPosition())
            local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 10)
            for k,v in pairs(ents) do
                if v and  v.prefab and  v.prefab == "moonbase"  and TheWorld.state.isfullmoon  and  v.components.pickable and  v.components.pickable.caninteractwith then
                    if (v._staffinst ~= nil and v._staffinst.prefab == "yellowstaff") or  v.components.pickable.product == "yellowstaff" then
                        self.currentmoon_30amount = self.currentmoon_30amount + 1
                        if self.currentmoon_30amount >= achievement_config.idconfig["moon_30"].need_amount then
                            self.checkmoon_30 = true
                            self:seffc(inst, "moon_30")
                        end
                    end
                end
            end
        end

        --携带冰切
        if  self.checkmoon_33 ~= true and inst.components.health.currenthealth > 0  and inst:HasTag("player") and not  inst:HasTag("playerghost") then
            if  inst.replica and inst.replica.inventory and   inst.replica.inventory:Has("chester_eyebone", 1)  then
                local check_chester_eyebone = false
                for k,v in pairs(inst.components.inventory.itemslots) do
                    if v.prefab == "chester_eyebone"  and   v.EyeboneState == "SNOW"  and v.isOpenEye == true  then
                        check_chester_eyebone = true
                    end
                end
                for k,v in pairs(inst.components.inventory.opencontainers) do
                    if k and k:HasTag("backpack") and k.components.container then
                        for i,j in pairs(k.components.container.slots) do
                            if j.prefab == "chester_eyebone"  and   j.EyeboneState == "SNOW" and j.isOpenEye == true then
                                check_chester_eyebone = true
                            end
                        end
                    end
                end
                if check_chester_eyebone then
                    self.currentmoon_33amount = self.currentmoon_33amount + 1
                    if self.currentmoon_33amount >= achievement_config.idconfig["moon_33"].need_amount then
                        self.checkmoon_33 = true
                        self:seffc(inst, "moon_33")
                    end
                end
            end
        end

    end)
end

function achievementmanager:_check_pick(inst,data)
    for k,v in pairs(achievement_config.category_config["picksomething"]) do
        if data.object and data.object.components.pickable and not data.object.components.trader then
            if not  self[v.check] then
                if not v.pickitem then
                    self[v.current] = self[v.current] + 1
                elseif type(v.pickitem) == "table" then
                    if table.contains(v.pickitem,data.object.prefab) then
                        self[v.current] = self[v.current] + 1
                    end
                elseif v.pickitem == data.object.prefab then
                    if (not v.animname) or (v.animname and v.animname == data.object.animname) then
                        self[v.current] = self[v.current] + 1
                    end
                end
                if self[v.current] >= v.need_amount then
                    self[v.check] = true
                    self:seffc(inst, v.id)
                end
        	end
        end
    end
end

function achievementmanager:OnPickAchievementCheck(inst)
    inst:ListenForEvent("picksomething", function(inst, data)
        self:_check_pick(inst,data)
    end)
end

function achievementmanager:_death_check(inst,data)
    local attacker = inst.components.combat.lastattacker
    for k,v in pairs(achievement_config.category_config["death"]) do
        if not self[v.check] and data then
            if v.attacker and attacker then
                if type(v.attacker) == "table"then 
                    if table.contains(v.attacker, attacker.prefab) then
                        self[v.current] = self[v.current] + 1
                    end
                elseif attacker and attacker == inst then
                    self[v.current] = self[v.current] + 1
                end
            elseif v.cause then
                if type(v.cause) == "table"then 
                    if table.contains(v.cause, data.cause) then
                        self[v.current] = self[v.current] + 1
                    end
                elseif v.cause == data.cause then
                    self[v.current] = self[v.current] + 1
                end
            elseif not v.cause and not v.attacker then
                self[v.current] = self[v.current] + 1
            end
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end
        end
    end
end

--被击杀
function achievementmanager:onkilled(inst)
    inst:ListenForEvent("death", function(inst, data)
        self:_death_check(inst,data)
    end)
end

function achievementmanager:_check_deploy_item(inst,data)
    for k,v in pairs(achievement_config.category_config["deployitem"]) do
        if not self[v.check] then
            if type(v.deployitem) == "table" then
                if table.contains(v.deployitem,data.prefab) then
                    self[v.current] = self[v.current] + 1
                end
            elseif data.prefab == v.deployitem then
                self[v.current] = self[v.current] + 1
            end
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end
        end
    end
end
function achievementmanager:OnDeployItemAchievementCheck(inst)
    inst:ListenForEvent("deployitem", function(inst, data)
        self:_check_deploy_item(inst,data)
    end)
end

function achievementmanager:checkkill(inst,victim) 
    for k,v in pairs(achievement_config.category_config["kill"]) do
        if v and (not self[v.check] or type(v.need_amount) == "table")  then
            local killedfind = false 
            if type(v.victim) == "table" then
                if table.contains(v.victim,victim.prefab) and (not v.special_condition or v.special_condition(victim,inst)) then
                    self[v.current] = self[v.current] + 1
                    killedfind = true
                end
            else
                if v.victim == victim.prefab and (not v.special_condition or v.special_condition(victim,inst)) then
                    self[v.current] = self[v.current] + 1
                    killedfind = true
                end
            end
            if killedfind then
                if type(v.need_amount) ~= "table" then
                    if self[v.current] >= v.need_amount and not self[v.check] then
                        self[v.check] = true
                        self:seffc(inst, v.id)
                    end
                else
                    -- if self[v.current] == v.need_amount[1] then
                    --     self[v.check] = true
                    --     self:seffc(inst, v.id)
                    if table.contains(v.need_amount,self[v.current]) then
                        self:seffc_boss(inst, victim.name,self[v.current])
                    end
                end
            end
        end
    end
end

function achievementmanager:_recentattack(inst,victim)
    if victim  and  victim.components and  victim.components.health and victim.components.health.currenthealth == 0 and inst.achivhaskill == nil then
        inst.achivhaskill = inst:DoTaskInTime(1.5, function(inst) inst.achivhaskill = nil end)
        local pos = Vector3(victim.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 8)
        for k,v in pairs(ents) do
            if v:HasTag("player") and not v:HasTag("playerghost")  and v ~= inst and v.achivhaskill == nil   then
                local  has_userid = nil
                if victim and victim.attacker_userid  and #victim.attacker_userid > 0 then
                    for i=1, #victim.attacker_userid do 
                        if  victim.attacker_userid[i] == v.userid then
                            has_userid = v.userid
                            break
                        end
                    end
                end
                --if has_userid and victim and victim.components.combat then victim.components.combat:GetAttacked(v, 1) end
                if has_userid then
                    v.achivhaskill = v:DoTaskInTime(1.2, function(v) v.achivhaskill = nil end)
                    v.components.achievementmanager:checkkill(v,victim)
					v.components.achievementmanager:check_kill_exp(v,victim)
                end

            end
        end
    end
end

local KILL_EXP_BASIC = 10
local KILL_EXP_LOW = 30
local KILL_EXP_MEDIUM = 300
local KILL_EXP_HIGH = 1200
local KILL_EXP_VERY_HIGH = 3000

local expbean_probability_basic = 0.02
local expbean_probability_low = 0.09
local expbean_probability_meidum = 0.23
local expbean_probability_high = 0.765
--给与经验豆
function  achievementmanager:giveexpbean(inst,probability)
    local rand1 = math.random()
    if rand1 <= probability then
        local itemexp = SpawnPrefab("expbean")
        inst.components.inventory:GiveItem(itemexp, nil, inst:GetPosition())
    end
end

function achievementmanager:check_kill_exp(inst,victim)
    if  victim:HasTag("wall")  then return end
    if victim  then
        if victim.components.health and victim.components.health.maxhealth <= 450 and victim.components.health.maxhealth > 99 then
            self:giveexpbean(inst,expbean_probability_basic)
            self:sumexp(inst,KILL_EXP_LOW)
        elseif victim.components.health and victim.components.health.maxhealth < 900 and victim.components.health.maxhealth > 450 then
            self:giveexpbean(inst,expbean_probability_low)
            self:sumexp(inst,KILL_EXP_LOW)
        elseif victim and victim.components.health and victim.components.health.maxhealth >=900 and victim.components.health.maxhealth <= 2400 then   
            self:giveexpbean(inst,expbean_probability_meidum)
            self:sumexp(inst,KILL_EXP_MEDIUM)
        elseif victim and victim.components.health and victim.components.health.maxhealth > 2400 then
            self:giveexpbean(inst,expbean_probability_high)
            self:sumexp(inst,KILL_EXP_VERY_HIGH)
        else
            self:sumexp(inst,KILL_EXP_BASIC)
        end
    else
        self:sumexp(inst,KILL_EXP_BASIC)
    end
end

function achievementmanager:OnKillAchievementCheck(inst)
    inst:ListenForEvent("killed", function(inst, data)
        local victim = data.victim
        self:CheckGetSoul(inst,data)
        self:checkkill(inst,victim)
        self:_recentattack(inst,victim)
        self:check_kill_exp(inst,victim)
    end)
end

--击杀单位
function achievementmanager:onkilledother(inst)
    inst:ListenForEvent("killed", function(inst, data)
        local victim = data.victim
        if victim and victim.prefab == "krampus" then
            local pos = Vector3(victim.Transform:GetWorldPosition())
            inst:DoTaskInTime(.1, function()
                local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 3)
                for k,v in pairs(ents) do
                    if v.prefab == "krampus_sack"
                    and v.components.inventoryitem.owner == nil
                    and v.components.ksmark.mark == false then
                        v.components.ksmark.mark = true
                        if self.checkluck ~= true then
                            self.checkluck = true
                            self:seffc(inst, "luck")
                            if self.checka_a2 ~= true  and inst.components.age:GetAge() / TUNING.TOTAL_DAY_TIME <=22 then
                                self.checka_a2 = true
                                self:seffc(inst, "a_a2")
                            end
                        end
                    end
                end
            end)
        end
    end)
end

function achievementmanager:_finish_work(inst,data)
    for k,v in pairs(achievement_config.category_config["finishedwork"]) do
        if not self[v.check] then
            if data and data.target then
                if v.prefab then
                    if type(v.prefab) == "table" and table.contains(v.prefab, data.target.prefab) then
                        self[v.current] = self[v.current] + 1
                    elseif type(v.prefab) == "string" and  data.target.prefab == v.prefab  then
                        self[v.current] = self[v.current] + 1
                    end
                elseif v.tag and data.target:HasTag(v.tag) then
                    self[v.current] = self[v.current] + 1
                end
            end
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end
        end
    end
end

function achievementmanager:OnFinishedworkAchievementCheck(inst)
    inst:ListenForEvent("finishedwork", function(inst, data)
        self:_finish_work(inst,data)
    end)
end


function achievementmanager:_working(inst,data)
    for k,v in pairs(achievement_config.category_config["working"]) do
        if not self[v.check] then
            if data and data.target and data.target.prefab  then
                if v.target and data.target.prefab == v.target or v.tag and data.target:HasTag(v.tag) then
                    if (not v.special_condition) or v.special_condition(data) then 
                        self[v.current] = self[v.current] + 1
                    end
                end
            end
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end
        end
    end
end

function achievementmanager:OnWorkingAchievementCheck(inst)
    inst:ListenForEvent("working", function(inst, data)
        self:_working(inst,data)
    end)
end


--着火冰冻
function achievementmanager:burnorfreeze(inst)
    inst:ListenForEvent("onignite", function(inst)
        if self.checkburn ~= true then
            self.checkburn = true
            self:seffc(inst, "burn")
        end
    end)
    inst:ListenForEvent("freeze", function(inst)
        if self.checkfreeze ~= true then
            self.checkfreeze = true
            self:seffc(inst, "freeze")
        end
    end)
end

function achievementmanager:_check_make_friend(inst)
    function inst.components.leader:AddFollower(follower)
        if self.followers[follower] == nil and follower.components.follower ~= nil then
            local achiev = inst.components.achievementmanager
            for k,v in pairs(achievement_config.category_config["addfollower"]) do
                if not achiev[v.check] then
                    if type(v.follower) == "table" then
                        if table.contains(v.follower,follower.prefab)then
                            achiev[v.current] = achiev[v.current] + 1
                        end
                    else 
                        if v.follower and v.follower == follower.prefab then
                            achiev[v.current] = achiev[v.current] + 1
                        end
                    end
                    if achiev[v.current] >= v.need_amount then
                        achiev[v.check] = true
                        achiev:seffc(inst, v.id)
                    end
                end
            end
            self.followers[follower] = true
            self.numfollowers = self.numfollowers + 1
            follower.components.follower:SetLeader(self.inst)
            follower:PushEvent("startfollowing", { leader = self.inst })
            if not follower.components.follower.keepdeadleader then
                self.inst:ListenForEvent("death", self._onfollowerdied, follower)
            end
            self.inst:ListenForEvent("onremove", self._onfollowerremoved, follower)
            if self.inst:HasTag("player") and follower.prefab ~= nil then
                ProfileStatsAdd("befriend_"..follower.prefab)
            end
        end
    end
end

function achievementmanager:OnMakefriendAchievementCheck(inst)
    self:_check_make_friend(inst)
end

--钓鱼达人
function achievementmanager:onhook(inst)
    inst:ListenForEvent("fishingstrain", function()
        if self.checkfishenthusiast ~= true then
            self.currentfishenthusiastamount = self.currentfishenthusiastamount + 1
            if self.currentfishenthusiastamount >= achievement_config.idconfig["fishenthusiast"].need_amount then
                self.checkfishenthusiast = true
                self:seffc(inst, "fishenthusiast")
            end
        end
    end)
end

--救活
function achievementmanager:respawn(inst)
    inst:ListenForEvent("respawnfromghost", function(inst, data)
        if data and data.user and data.user.components.achievementmanager then
            local achievementmanager = data.user.components.achievementmanager
            if achievementmanager.checkmessiah ~= true then
                achievementmanager.currentmessiahamount = achievementmanager.currentmessiahamount + 1
                if achievementmanager.currentmessiahamount >= achievement_config.idconfig["messiah"].need_amount then
                    achievementmanager.checkmessiah = true
                    achievementmanager:seffc(data.user, "messiah")
                end
            end
        end
        if data and data.source and data.source.prefab == "amulet" and self.checkreviveamulet ~= true then
			self.currentreviveamuletamount = self.currentreviveamuletamount + 1
			if self.currentreviveamuletamount >= achievement_config.idconfig["reviveamulet"].need_amount then
                self.checkreviveamulet = true
                self:seffc(inst, "reviveamulet")
			end
        end
    end)
end

function achievementmanager:_check_build_structure(inst,data)
    for k,v in pairs(achievement_config.category_config["buildstructure"]) do
        if not self[v.check] and data and data.recipe then
            if v.buildstructure == data.recipe.product then
                self[v.current] = self[v.current] + 1
            end
            if  self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end         	
        end
    end
end

function achievementmanager:_check_build_item(inst,data)
    for k,v in pairs(achievement_config.category_config["builditem"]) do
        if not self[v.check] and data and data.recipe then
            if v.builditem == data.recipe.product then
                self[v.current] = self[v.current] + 1
            end
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end        	
        end
    end
end

function achievementmanager:_check_consumeing(inst)
    for k,v in pairs(achievement_config.category_config["consumeingredients"]) do
        if not self[v.check] then
            self[v.current] = self[v.current] + 1
            if self[v.current] >= v.need_amount then
                self[v.check] = true
                self:seffc(inst, v.id)
            end        	
        end
    end
end

function achievementmanager:OnBuildAchievementCheck(inst)
    inst:ListenForEvent("buildstructure", function(inst,data)
        self:_check_build_structure(inst,data)
    end)
    inst:ListenForEvent("builditem", function(inst,data)
        self:_check_build_item(inst,data)
    end)
    inst:ListenForEvent("consumeingredients", function(inst)
        self:_check_consumeing(inst)
    end)
end

--人形坦克
function achievementmanager:onattacked(inst)
    inst:ListenForEvent("attacked", function(inst, data)
        if self.checktank ~= true then
            if data.damage and data.damage >= 0 then
                self.currenttankamount = math.ceil(self.currenttankamount + data.damage)
	            if self.currenttankamount >= achievement_config.idconfig["tank"].need_amount then
	                self.checktank = true
	                self:seffc(inst, "tank")
	            end
	        end
        end
        if self.checka_5 ~= true then
            if data.damage and data.damage >= 0 then
                self.currenta_5amount = math.ceil(self.currenta_5amount + data.damage)
	            if self.currenta_5amount >= achievement_config.idconfig["a_5"].need_amount then
	                self.checka_5 = true
	                self:seffc(inst, "a_5")
	            end
	        end
        end
    end)
end

--超凶
function achievementmanager:hitother(inst)
    inst:ListenForEvent("onhitother", function(inst, data)
        if self.checkangry ~= true then
            if data.damage and data.damage >= 0 then
                self.currentangryamount = math.ceil(self.currentangryamount + data.damage)
            end
            if self.currentangryamount >= achievement_config.idconfig["angry"].need_amount then
                self.checkangry = true
                self:seffc(inst, "angry")
            end
        end
        if self.checka_4 ~= true then
            if data.damage and data.damage >= 0 then
                self.currenta_4amount = math.ceil(self.currenta_4amount + data.damage)
            end
            if self.currenta_4amount >= achievement_config.idconfig["a_4"].need_amount then
                self.checka_4 = true
                self:seffc(inst, "a_4")
            end
        end
    end)
end

--预运行
function achievementmanager:Init(inst)
    inst:DoTaskInTime(.1, function()
        self:intogamefn(inst)
        self:OnEatAchievementCheck(inst)
        self:TimingTask(inst)
        self:onkilled(inst)
        self:OnKillAchievementCheck(inst)
        self:OnFinishedworkAchievementCheck(inst)
        self:OnWorkingAchievementCheck(inst)
        self:onkilledother(inst)
        self:OnPickAchievementCheck(inst)
        self:OnDeployItemAchievementCheck(inst)
        if TUNING.ACHIEVEMENT_FIRSTINIT == 0 then
            TUNING.ACHIEVEMENT_FIRSTINIT = 1
            DealAction()
        end
        self:burnorfreeze(inst)
        self:OnMakefriendAchievementCheck(inst)
        self:onhook(inst)
        self:respawn(inst)
        self:OnBuildAchievementCheck(inst)
        self:onattacked(inst)
        self:hitother(inst)
        self:allget(inst)
        self:allgettwo(inst)
    end)

    inst.components.combat.damagemultiplier = inst.components.combat.damagemultiplier or 1
end

function achievementmanager:OnInitSpecialAbility(inst)
     --self:DealAction(inst)
end
--检测是否完成所有成就
function achievementmanager:allget(inst)
    inst:DoPeriodicTask(1, function()
        local allget = true
        for _,v in pairs(achievement_config.idconfig) do
            if v.catagory and v.check ~= "checkall" and not self[v.check] then
                allget = false
            end
        end
        if allget then
            self["checkall"] = true
            self["currentallamount"] = self["currentallamount"] + 1
            self:seffc(inst, "all")
            for _,v in pairs(achievement_config.idconfig) do
                if v.check ~= "checkall" then
                    self[v.check] = v.default_check or false
                    if not v.current_dont_reset then
                        self[v.current] = v.default_current or 0
                    end
                end
            end
            self:allgettwo(inst)
            self:intogamefn(inst)
            for i=1, 1000, 10 do
                inst:DoTaskInTime(i/100*3, function()
                    local pos = Vector3(inst.Transform:GetWorldPosition())
                    SpawnPrefab("explode_firecrackers").Transform:SetPosition(pos.x+math.random(-3,3), pos.y, pos.z+math.random(-3,3))
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local firecrackers_item1 = SpawnPrefab("firecrackers")
                    local firecrackers_item2 = SpawnPrefab("firecrackers")
                    local firecrackers_item3 = SpawnPrefab("firecrackers")
                    local firecrackers_item4 = SpawnPrefab("firecrackers")

                    if firecrackers_item1 ~= nil and firecrackers_item1.components.stackable and firecrackers_item1.components.burnable then
                        firecrackers_item1.components.burnable:Ignite() 
                        firecrackers_item2.components.burnable:Ignite()
                        firecrackers_item3.components.burnable:Ignite()
                        firecrackers_item4.components.burnable:Ignite()
                        
                        firecrackers_item1.Transform:SetPosition(x-3, y, z)
                        firecrackers_item2.Transform:SetPosition(x+3, y, z)
                        firecrackers_item3.Transform:SetPosition(x, y, z-3)
                        firecrackers_item4.Transform:SetPosition(x, y, z+3)
                    end
                end)
            end
        end
    end)
end

function achievementmanager:specific_character_ignore_achievement(inst)
    for k,v in pairs(achievement_config.specific_ignore) do
        if inst.prefab == k then
            for _,achievement in pairs(v) do
                self[achievement] = true
            end
        end
    end
end

function achievementmanager:specific_character_achievement(inst)
    for k,v in pairs(achievement_config.specific_achievement) do
        if inst.prefab ~= k then
            for _,achievement in pairs(v) do
                self[achievement] = true
            end
        end
    end
end

function achievementmanager:allgettwo(inst)
    local achievementmanager = inst.components.achievementmanager
    inst:DoPeriodicTask(3, function()
        self:specific_character_ignore_achievement(inst)
        self:specific_character_achievement(inst)
    end)
end

return achievementmanager