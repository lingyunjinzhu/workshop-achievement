local achievement_config = require("Achievement.achievement_config")
local achievement_ability_config = require("Achievement.achievement_ability_config")
local micellanceous_config = require("Achievement.micellanceous_config")
local ability_cost = achievement_ability_config.id2ability
local ability_ratio = achievement_ability_config.ability_ratio
local function getcoinamount(self,coinamount) self.inst.currentcoinamount:set(coinamount) end
local function getkillamount(self,killamount) self.inst.currentkillamount:set(killamount) end

local function InitPropsTable()
    local props_table = {}
    for k,v in pairs(achievement_ability_config.ability_cost) do 
        props_table[v.ability] = function(self,value) 
            if value and value ~= 0 then
                if type(value) == "number" then
                    self.inst["current" .. v.ability]:set(value) 
                else 
                    self.inst["current" .. v.ability]:set(1) 
                end
            else
                self.inst["current" .. v.ability]:set(0) 
            end
        end
    end
    props_table["coinamount"] = getcoinamount
    props_table["killamount"] = getkillamount
    return props_table
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil and inst.replica.inventory:Has("wortox_soul", 1) then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then
            return { ACTIONS.BLINK }
        end
    end
    return {}
end

local function sanityfn(inst)
    local delta = inst.components.temperature:IsFreezing() and -TUNING.SANITYAURA_LARGE or 0
    local x, y, z = inst.Transform:GetWorldPosition() 
    local max_rad = 10
    local ents = TheSim:FindEntities(x, y, z, max_rad, { "fire" })
    for i, v in ipairs(ents) do
        if v.components.burnable ~= nil and v.components.burnable:IsBurning() then
            local rad = v.components.burnable:GetLargestLightRadius() or 1
            local sz = TUNING.SANITYAURA_TINY * math.min(max_rad, rad) / max_rad
            local distsq = inst:GetDistanceSqToInst(v) - 9
            delta = delta + sz / math.max(1, distsq)
        end
    end
    return delta
end

local function ondeployitem(inst, data)
    if inst and inst.components.sanity and inst.components.achievementability and inst.components.achievementability.plantfriend then
        if data and data.prefab ~= "fossil_piece" then
            inst.components.sanity:DoDelta(TUNING.SANITY_SUPERTINY*5)
        end
    end
end
local function InitAllAbility(inst)
    for _,v in pairs(achievement_ability_config.ability_cost) do
        inst[v.ability] = v.default_value
    end
end

local achievementability = Class(function(self, inst)
        self.inst = inst
        InitAllAbility(self)
        self.coinamount = 0
        self.killamount = 0
        self.a_sleep = true
        self.frozenswitch = true  --冰冻开关
        self.levelswitch = true
        self.fastbuild = false
        self.shadowsubmissiveswitch = true
        self.murlocdisguiseswitch = true
        self.ghostly_friend_maxhealth = 150
        self.ghostly_friend_curhealth = 1
        self.flashyswitch = 1
        self.flashystill_delay = 6
        self.thornsswitch = true --反伤开关
        self.electricswitch = true
        self.effectswitch = true
        self.effectstype = 1
        self.fireflylightswitch = 1
        self.nomoistswitch = true
        self.cookmasterswitch = true
        self.fishtimemin = 4
        self.fishtimemax = 40
        self.hungermax = math.pi
        self.sanitymax = math.pi
        self.healthmax = math.pi
        self.hungerrate = math.pi
        self.speedcheck = math.pi
        self.maxMoistureRate = math.pi
        self.absorb = math.pi
        self.damagemul = math.pi
    end,
    nil,
    InitPropsTable())
--检测非由本mod改变的数据并实时更新，同时负责载入时将奖励生效
function achievementability:onupdate()
    local inst = self.inst
    --血量上限
    if self.healthmax ~= inst.components.health.maxhealth then
        if self.firmarmor == 1  and   inst.components.inventory then  
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if item ~= nil and item.prefab == "armorruins" then
                local health_percent = inst.components.health:GetPercent()
                inst.components.health:SetMaxHealth(inst.components.health.maxhealth + 100)
                inst.components.health:SetPercent(health_percent)
                self.healthmax = inst.components.health.maxhealth
            end
        end
    end

    --移动速度
    if self.speedcheck ~= inst.components.locomotor.externalspeedmultiplier then
        inst.components.locomotor.externalspeedmultiplier = inst.components.locomotor.externalspeedmultiplier + ability_ratio["speedup"]*self.speedup
        self.speedcheck = inst.components.locomotor.externalspeedmultiplier
    end
    --防御力
    if self.absorb ~= inst.components.health.absorb then
        inst.components.health.absorb = inst.components.health.absorb + ability_ratio["absorbup"]*self.absorbup
        if inst.components.health.absorb >= .95 then inst.components.health.absorb = .95 end
        self.absorb = inst.components.health.absorb
    end
    --攻击力
    if self.damagemul ~= inst.components.combat.damagemultiplier then
        inst.components.combat.damagemultiplier = inst.components.combat.damagemultiplier + ability_ratio["damageup"]*self.damageup
        self.damagemul = inst.components.combat.damagemultiplier
    end
    --防水
    if self.maxMoistureRate ~= inst.components.moisture.maxMoistureRate then
        if self.nomoist and self.nomoistswitch then
            inst.components.moisture.maxMoistureRate = 0
        end
    end
    if self.woodieability then
        for k,v in pairs(inst.components.inventory.itemslots) do
            if( v.prefab == "wereitem_goose" or v.prefab  == "wereitem_beaver" or v.prefab == "wereitem_moose" ) and not v:HasTag("preparedfood")  then
                v:AddTag("preparedfood")
            end
        end
        for k,v in pairs(inst.components.inventory.opencontainers) do
            if k and k:HasTag("backpack") and k.components.container then
                for i,j in pairs(k.components.container.slots) do
                    if( j.prefab == "wereitem_goose" or j.prefab  == "wereitem_beaver" or j.prefab == "wereitem_moose" ) and not j:HasTag("preparedfood")   then
                        j:AddTag("preparedfood")
                    end
                end
            end
        end
    end
end

--保存
function achievementability:OnSave()
    local data = {
        coinamount = self.coinamount,
        killamount = self.killamount,
        thornsswitch = self.thornsswitch,
        cookmasterswitch = self.cookmasterswitch,
        frozenswitch = self.frozenswitch,
        levelswitch = self.levelswitch,
        effectswitch = self.effectswitch,
        effectstype = self.effectstype,
        nomoistswitch = self.nomoistswitch,
        shadowsubmissiveswitch = self.shadowsubmissiveswitch, 
        murlocdisguiseswitch = self.murlocdisguiseswitch, 
        ghostly_friend_maxhealth = self.ghostly_friend_maxhealth,
        ghostly_friend_curhealth = self.ghostly_friend_curhealth,
        flashyswitch =  self.flashyswitch,
    }
    for _,v in pairs(achievement_ability_config.ability_cost) do
        data[v.ability] = self[v.ability] 
    end
    return data
end

--载入
function achievementability:OnLoad(data)
    self.coinamount = data.coinamount or 0
    self.killamount = data.killamount or 0
    self.thornsswitch = data.thornsswitch or true --反伤
    self.effectswitch = data.effectswitch or true
    self.effectstype = data.effectstype or 1
    self.nomoistswitch = data.nomoistswitch or true
    self.cookmasterswitch = data.cookmasterswitch or true
    self.frozenswitch = data.frozenswitch or true    --冰冻开关
    self.levelswitch = data.levelswitch or true
    self.shadowsubmissiveswitch = data.shadowsubmissiveswitch or true
    self.murlocdisguiseswitch = data.murlocdisguiseswitch or true
    self.ghostly_friend_maxhealth = data.ghostly_friend_maxhealth or 150
    self.ghostly_friend_curhealth = data.ghostly_friend_curhealth or 1
    self.flashyswitch = data.flashyswitch or 1
    for _,v in pairs(achievement_ability_config.ability_cost) do
        self[v.ability] = data[v.ability] or v.default_value
    end
    self:OnLoadedPost()
end

--通用效果器 获取成功
function achievementability:ongetcoin(inst)
    inst.SoundEmitter:PlaySound("dontstarve/HUD/research_available")
end

function achievementability:coinDoDelta(value)
    self.coinamount = self.coinamount + value
end
function achievementability:killDoDelta(value)
    self.killamount = self.killamount + value
end

--挨打冰冻怪物  
function achievementability:jumpcoin(inst)
    if self.jump then
        if self.frozenswitch then
            self.frozenswitch = false
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_FREEZE_END)
            end
        else
            self.frozenswitch = true
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_FREEZE_START)
            end
        end
    end

    if self.jump ~= true and self.coinamount >= ability_cost["jump"].cost then
        self.jump = true
        self.frozenswitch = true
        self:coinDoDelta(-ability_cost["jump"].cost)
        self:ongetcoin(inst)
    end
end

--
local function OnCooldown(inst)
    inst._cdtaskachiv = nil
end
local function OnCooldown2(inst)
    inst._attackcheck_moon_13 = nil
end
function achievementability:jumpfn(inst)
    inst:ListenForEvent("attacked", function(inst, data)
        if self.jump and data and data.attacker and data.attacker.components and data.attacker.components.freezable  ~= nil and self.frozenswitch then
        	if data.attacker.components.health and data.attacker.components.health.maxhealth >=1000 then
        		local rand1 = math.random()
            	if rand1 <= 0.55 then
                    data.attacker.components.freezable.resistance = 1
            		data.attacker.components.freezable:AddColdness(3, 9)
            		data.attacker.components.freezable:SpawnShatterFX()
            	end	
            else
                data.attacker.components.freezable.resistance = 1
            	data.attacker.components.freezable:AddColdness(3, 19)
            	data.attacker.components.freezable:SpawnShatterFX()
            end	
        end
        --实现反伤  
        if self.thornss >= 1 and  self.thornsswitch  and inst._cdtaskachiv == nil and data ~= nil and not data.redirected    and  inst.components.health and not  inst.components.health:IsDead() and not inst:HasTag("playerghost")   then
            inst._cdtaskachiv = inst:DoTaskInTime(.5, OnCooldown)
            SpawnPrefab("bramblefx_armor"):SetFXOwner(inst)--22

            if data and data.attacker and data.attacker.components.combat and data.attacker.components.combat.defaultdamage >= 45   and   inst.components.health and  not inst.components.health:IsDead() and not inst:HasTag("playerghost")  then
                SpawnPrefab("bramblefx_trap"):SetFXOwner(inst)--40
            end
            
            if data and data.attacker and data.attacker.components.combat and data.attacker.components.combat.defaultdamage >= 60   and  inst.components.health and  not inst.components.health:IsDead() and not inst:HasTag("playerghost")  then
                SpawnPrefab("bramblefx_trap"):SetFXOwner(inst)--40
            end
            if inst.SoundEmitter ~= nil then
                inst.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
            end
        end
        --被青蛙舔20次
        if inst.components and inst.components.achievementmanager.checkmoon_13 ~= true and inst._attackcheck_moon_13 == nil then
            if data and data.attacker and   data.attacker.prefab and data.attacker.prefab == "frog" then
                inst._attackcheck_moon_13 = inst:DoTaskInTime(.1, OnCooldown2)
                inst.components.achievementmanager.currentmoon_13amount = inst.components.achievementmanager.currentmoon_13amount + 1
                if inst.components.achievementmanager.currentmoon_13amount >= achievement_config.idconfig["moon_13"].need_amount then
                    inst.components.achievementmanager.checkmoon_13 = true
                    inst.components.achievementmanager:seffc(inst, "moon_13")
                end
            end
        end
    end)
    inst:ListenForEvent("onhitother", function(inst, data)
        local target = data.target
        if self.jump and target and   target.components.freezable  ~= nil  and not target:HasTag("wall") and self.attackcheck ~= true and self.frozenswitch then
            local rand2 = math.random()
            if rand2 <= 0.15 then
                self.attackcheck = true
                data.target.components.freezable:AddColdness(3, 9)
                data.target.components.freezable:SpawnShatterFX()
                inst:DoTaskInTime(.1, function() self.attackcheck = false end)
            end
        end
        ----攻击时记录5秒内的攻击者-----------------------------------------------------
        if  target and   target.components and   target.components.freezable  ~= nil  and not target:HasTag("wall") and self.attackedcheck ~= true then
            if target.attacker_userid and   #target.attacker_userid >0 then
                local add_userid = true

                for i=1, #target.attacker_userid do
                    if  target.attacker_userid[i]  == inst.userid then
                        add_userid = false
                    end
                end
                if  add_userid then
                    table.insert(target.attacker_userid,inst.userid)
                end
                --5秒后不攻击删除记录
                if  inst.mod_add_userid == nil  then
                    inst.mod_add_userid = inst:DoTaskInTime(8, function(inst,target)
                        if target and target.attacker_userid and   #target.attacker_userid > 0 then
                            local remove_userid = 0
                            for i=1, #target.attacker_userid do
                                if  target.attacker_userid[i]  == inst.userid then
                                    remove_userid = i
                                end
                            end
                            if remove_userid > 0 then
                                table.remove(target.attacker_userid,remove_userid) 
                            end
                            inst.mod_add_userid = nil 
                        end
                    end)
                elseif  inst.mod_add_userid ~= nil  then
                    --5秒内连续攻击 刷新删除记录时间
                    inst.mod_add_userid:Cancel()
                    inst.mod_add_userid = inst:DoTaskInTime(8, function(inst,target)
                        if target and target.attacker_userid and   #target.attacker_userid > 0 then
                            local remove_userid = 0
                            for i=1, #target.attacker_userid do
                                if  target.attacker_userid[i]  == inst.userid then
                                    remove_userid = i
                                end
                            end
                            if remove_userid > 0 then
                                table.remove(target.attacker_userid,remove_userid) 
                            end
                            inst.mod_add_userid = nil 
                        end
                    end)
                end
            else
                target.attacker_userid = {}
                table.insert(target.attacker_userid,inst.userid)
                if  inst.mod_add_userid == nil  then
                    inst.mod_add_userid = inst:DoTaskInTime(8, function(inst,target)
                        if target and target.attacker_userid and   #target.attacker_userid > 0 then
                            local remove_userid = 0
                            for i=1, #target.attacker_userid do
                                if  target.attacker_userid[i]  == inst.userid then
                                    remove_userid = i
                                end
                            end
                            if remove_userid > 0 then
                                table.remove(target.attacker_userid,remove_userid) 
                            end
                            inst.mod_add_userid = nil 
                        end
                    end)
                elseif  inst.mod_add_userid ~= nil  then
                    inst.mod_add_userid:Cancel()
                    inst.mod_add_userid = inst:DoTaskInTime(8, function(inst,target)
                        if target and target.attacker_userid and   #target.attacker_userid > 0 then
                            local remove_userid = 0
                            for i=1, #target.attacker_userid do
                                if  target.attacker_userid[i]  == inst.userid then
                                    remove_userid = i
                                end
                            end
                            if remove_userid > 0 then
                                table.remove(target.attacker_userid,remove_userid) 
                            end
                            inst.mod_add_userid = nil 
                        end
                    end)
                end
            end
            inst:DoTaskInTime(.2, function(target) target.attackedcheck = false end)
        end
    end)
end

--灵魂跳跃  
function achievementability:soulhopcopycoin(inst)
    if self.soulhopcopy ~= true and self.coinamount >= ability_cost["soulhopcopy"].cost and inst.prefab ~= "wortox" then
        self.soulhopcopy = true
        self:coinDoDelta(-ability_cost["soulhopcopy"].cost)
        local itemsoul = SpawnPrefab("wortox_soul")
        itemsoul.components.stackable:SetStackSize(8)
        inst.components.inventory:GiveItem(itemsoul, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

--灵魂跳跃效果拥有
function achievementability:soulhopcopyfn(inst)
    if self.soulhopcopy == true then
        inst:DoPeriodicTask(0.1, function()
            if inst.components.playeractionpicker ~= nil and self.soulhopcopy then
                inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
            end
        end)
    end
end
--升级
function achievementability:levelcoin(inst)
    if   self.level  then
        if self.levelswitch then
            self.levelswitch = false
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_HIDE_EXP)
            end
        else
            self.levelswitch = true
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_SHOW_EXP)
            end
        end
    end

    if self.level ~= true and self.coinamount >= ability_cost["level"].cost then
        self.level = true
        self.levelswitch = true
        self:coinDoDelta(-ability_cost["level"].cost)
        self:ongetcoin(inst)
    end
end

--工程科技
function achievementability:fastbuildcoin(inst)
    if self.fastbuild ~= true then
        if inst.prefab ~= "winona" and  self.coinamount >= ability_cost["fastbuild"].cost  then
            self.fastbuild = true
            self:coinDoDelta(-ability_cost["fastbuild"].cost)
            self:fastbuildfn(inst)
            self:ongetcoin(inst)
        end
    end
end

--快速采集效果
function achievementability:fastbuildfn(inst)
    if self.fastbuild then 
        --inst:AddTag("fastharvester") --快速收获
        inst:AddTag("fastbuilder")
        inst:AddTag("achivehandyperson")
    end
end

--反伤
function achievementability:thornsscoin(inst)
    if self.thornss ~= 0  then
        if self.thornsswitch then
            self.thornsswitch = false
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_THORNS_END)
            end
        else
            self.thornsswitch = true
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_THORNS_START)
            end
        end
    end
    if self.coinamount >= ability_cost["thornss"].cost and self.thornss  == 0 then
        self.thornss = 1
        self.thornsswitch = true
        self:coinDoDelta(-ability_cost["thornss"].cost)
        self:ongetcoin(inst)
    end
end

--电击
function achievementability:electriccoin(inst)
	--选择关闭或打开效果
	if self.electric >= 1 then 
        self.electric = 1
        if self.electricswitch == true then
        	if inst._aifx2 ~= nil then
                inst._aifx2:kill_fx()               
                inst._aifx2 = nil
            end
            self.electricswitch = false
        else
        	if inst._aifx2 == nil then            
                inst._aifx2 = SpawnPrefab("electricfx") -- electricfx  electricfx2      achiv_lasertrail
                inst._aifx2.entity:SetParent(inst.entity)
                inst._aifx2.Transform:SetPosition(0, 0.2, 0)
                self.electricswitch = true
            end

        end
    end
    if self.electric < 1 and  self.coinamount >= ability_cost["electric"].cost then
        self.electric = 1
        self:coinDoDelta(-ability_cost["electric"].cost)
        self:electricfn(inst)
        self:ongetcoin(inst)
        -- if inst.components.debuffable ~= nil and inst.components.debuffable:IsEnabled() and
        --     not (inst.components.health ~= nil and inst.components.health:IsDead()) and
        --     not inst:HasTag("playerghost") then
        --     inst.components.debuffable:AddDebuff("buff_electricattack", "buff_electricattack")
        -- end
        self.electricswitch = true
    end
end
--电击获取
function achievementability:electricfn(inst)
    if  self.electric >= 1  then
        if inst.components.debuffable ~= nil and inst.components.debuffable:IsEnabled() and
            not (inst.components.health ~= nil and inst.components.health:IsDead()) and
            not inst:HasTag("playerghost") then
            inst.components.debuffable:AddDebuff("buff_electricattack", "buff_electricattack")
        end
    end
    inst:DoPeriodicTask(2, function()
        if  self.electric >= 1  then
            if  inst.components.health and inst.components.health.currenthealth > 0 and not inst:HasTag("playerghost") and self.electricswitch then
                if inst._aifx2 == nil then            
                    inst._aifx2 = SpawnPrefab("electricfx") -- 
                    inst._aifx2.entity:SetParent(inst.entity)
                    inst._aifx2.Transform:SetPosition(0, 0.2, 0)
                end
                if  inst:HasTag("playerghost")  then
                    if inst._aifx2 ~= nil then
                        inst._aifx2:kill_fx()               
                        inst._aifx2 = nil
                    end
                end
            end
        end
    end)
    inst:DoPeriodicTask((TUNING.BUFF_ELECTRICATTACK_DURATION*0.9), function()
        if  self.electric >= 1  then
            if inst.components.debuffable ~= nil and inst.components.debuffable:IsEnabled() and
                not (inst.components.health ~= nil and inst.components.health:IsDead()) and
                not inst:HasTag("playerghost") then
                inst.components.debuffable:AddDebuff("buff_electricattack", "buff_electricattack")
            end
        end
    end)
    inst:ListenForEvent("respawnfromghost", function(inst, data)
        if  self.electric >= 1  then
            if inst.components.debuffable ~= nil and inst.components.debuffable:IsEnabled() and
                not (inst.components.health ~= nil and inst.components.health:IsDead()) and
                not inst:HasTag("playerghost") then
                inst.components.debuffable:AddDebuff("buff_electricattack", "buff_electricattack")
            end  
        end
        
    end)
end

function achievementability:firmarmorcoin(inst)
    if self.firmarmor < 1 and self.coinamount >= ability_cost["firmarmor"].cost then
        self.firmarmor = 1
        self:coinDoDelta(-ability_cost["firmarmor"].cost)
        self:ongetcoin(inst)
        self:firmarmorfn(inst)
    end
end

--装备铥甲+100HP
function achievementability:firmarmorfn(inst)
    if self.firmarmor == 1  and inst.components.inventory and self.healthmax ~= inst.components.health.maxhealth  then  
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if item ~= nil and item.prefab == "armorruins" then
                local health_percent = inst.components.health:GetPercent()
                inst.components.health:SetMaxHealth(inst.components.health.maxhealth + 100)
                inst.components.health:SetPercent(health_percent)
                self.healthmax = inst.components.health.maxhealth
            end
    end  
    if inst.firmarmorEvent == nil then
        inst.firmarmorEvent = true
        inst:ListenForEvent("equip", function(inst, data)
            if data.item and data.item.prefab == "krampus_sack" and data.item.components and data.item.components.ksmark then --背过的背包
                data.item.components.ksmark.mark = true
            end
            if  self.firmarmor == 1  and data.item and data.item.prefab == "armorruins" then
                    local health_percent = inst.components.health:GetPercent()
                    inst.components.health:SetMaxHealth(inst.components.health.maxhealth + 100)
                    inst.components.health:SetPercent(health_percent)
                    self.healthmax = inst.components.health.maxhealth
                --end
            end
        end)
        inst:ListenForEvent("unequip", function(inst, data)
            if data.item and data.item.prefab == "krampus_sack" and data.item.components and data.item.components.ksmark then --背过的背包
                data.item.components.ksmark.mark = true
            end
            if self.firmarmor == 1 and data.item and data.item.prefab == "armorruins" then
                local health_percent = inst.components.health:GetPercent()
                inst.components.health:SetMaxHealth(inst.components.health.maxhealth - 100)
                inst.components.health:SetPercent(health_percent)
                self.healthmax = inst.components.health.maxhealth
            end
        end)
    end
end

--人形伍迪
function achievementability:woodieabilitycoin(inst)
    if self.coinamount >= ability_cost["woodieability"].cost and self.woodieability == false and inst.prefab ~= "woodie" then
        self.woodieability = true
        inst:AddTag("werehuman")--伍迪的3个肉
        self:coinDoDelta(-ability_cost["woodieability"].cost)
        self:ongetcoin(inst)
        self:woodieabilityfn(inst)
        local item_wereitem_goose = SpawnPrefab("wereitem_goose")
        inst.components.inventory:GiveItem(item_wereitem_goose, nil, inst:GetPosition())
    end
end  

local function DoRipple2(inst)
    if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() and
     inst.components.achievementability and inst.components.achievementability.woodieability then
        if not inst:HasTag("playerghost") and inst.components.locomotor and inst.components.locomotor.wantstomoveforward then
            SpawnPrefab("weregoose_splash_less"..tostring(math.random(2))).entity:SetParent(inst.entity)
        else
            SpawnPrefab("weregoose_ripple"..tostring(math.random(2))).entity:SetParent(inst.entity)
        end
    end
end
local function DrownableEenabledF(inst)
    if inst.components.drownable ~= nil then
        if inst.components.drownable.enabled ~= false then
            inst.components.drownable.enabled = false
        end
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
        inst.Physics:Teleport(inst.Transform:GetWorldPosition())
    end
end
local function DrownableEenabledT(inst)
    if inst.mod_wereitem_goose_time > 0 then
        inst.mod_wereitem_goose_time =  inst.mod_wereitem_goose_time -1
        if inst.components.hunger ~= nil then
            if inst.components.hunger.current > 0 then
                if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
                    inst.components.hunger:DoDelta(-1)
                end
            end
        end
    end
    if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater()  then
        if inst.mod_wereitem_goose_time == 30 then
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_WATER_WALK_30)
            end
        elseif inst.mod_wereitem_goose_time == 10 then
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_WATER_WALK_10)
            end
        end
    end

    if inst.components.drownable ~= nil and  inst.components.drownable.enabled == false and
     (inst.mod_wereitem_goose_time < 1 or (inst.components.achievementability and not inst.components.achievementability.woodieability) or 
       (inst.components.hunger and inst.components.hunger.current <= 0 )  ) then
        inst.components.drownable.enabled = true
        inst.mod_wereitem_goose_time = 0
        if  inst.check_walkingonwater ~= nil  then
            inst.check_walkingonwater:Cancel()
            inst.check_walkingonwater = nil 
        end
        if  inst.mod_walkingonwater ~= nil  then
            inst.mod_walkingonwater:Cancel()
            inst.mod_walkingonwater = nil 
        end
        if inst.components.talker ~= nil then
            inst.components.talker:Say(STRINGS.ACHIEVEMENT_WATER_WALK_END)
        end
        if not inst:HasTag("playerghost") then
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.WORLD)
            inst.Physics:CollidesWith(COLLISION.OBSTACLES)
            inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.GIANTS)
            inst.Physics:Teleport(inst.Transform:GetWorldPosition())
        end
    end
end

local function RemoveWoodcutterTag(inst)
    inst:RemoveTag("woodcutter")
    if inst.components.talker ~= nil then
        inst.components.talker:Say(STRINGS.ACHIEVEMENT_FAST_CHOP_END)
    end
    if inst.components.debuffable  ~= nil then
        inst.components.debuffable:RemoveDebuff("buff_workeffectiveness")
    end
end

local function AddDamageSetFalse(inst)
    inst.add_damage_set = false
    if inst.components.talker ~= nil then
        inst.components.talker:Say(STRINGS.ACHIEVEMENT_EXTRA_DAMAGE_END)
    end

    if inst.mod_wereitem_moose_absorb == true and  inst.components.health then
        inst.components.health.absorb = inst.components.health.absorb - .1
        if inst.components.health.absorb >= .95 then inst.components.health.absorb = .95 end
        if inst.components.achievementability then inst.components.achievementability.absorb = inst.components.health.absorb end
        inst.mod_wereitem_moose_absorb = false
    end
end

--伍迪的3种能力
function achievementability:woodieabilityfn(inst)
    inst:DoTaskInTime(1, function()
    if self.woodieability then
        inst:AddTag("werehuman")
        local oldeatfn = inst.components.eater.oneatfn
        function inst.components.eater.oneatfn(inst, food)
            if self.woodieability then
                --inst.mod_wereitem_moose_absorb = false
                --鸭子能力 水上行走
                if food.prefab == "wereitem_goose"  then
                    DrownableEenabledF(inst)
                    inst.mod_wereitem_goose_time =  200
                    if  inst.check_walkingonwater == nil  then
                        inst.check_walkingonwater = inst:DoPeriodicTask(1, DrownableEenabledT)
                    end
                    if inst.mod_walkingonwater == nil  then
                        inst.mod_walkingonwater = inst:DoPeriodicTask(.35, DoRipple2)
                    end
                end

                --海狸能力 只增加砍树速度  workeffectiveness
                if food.prefab == "wereitem_beaver"  then
                    inst:AddTag("woodcutter")
                    if inst.components.debuffable  ~= nil then
                        inst.components.debuffable:AddDebuff("buff_workeffectiveness", "buff_workeffectiveness")
                    end
                    if  inst.mod_wereitem_beaver == nil  then
                        inst.mod_wereitem_beaver = inst:DoTaskInTime(200, RemoveWoodcutterTag)
                    elseif  inst.mod_wereitem_beaver ~= nil  then
                        inst.mod_wereitem_beaver:Cancel()
                        inst.mod_wereitem_beaver = inst:DoTaskInTime(200, RemoveWoodcutterTag)
                    end
                end
                
                --麋鹿
                if food.prefab == "wereitem_moose"  then
                    inst.add_damage_set = true
                    if  inst.mod_wereitem_moose == nil  then
                        inst.mod_wereitem_moose = inst:DoTaskInTime(200, AddDamageSetFalse)
                    elseif  inst.mod_wereitem_moose ~= nil  then
                        inst.mod_wereitem_moose:Cancel()
                        inst.mod_wereitem_moose = inst:DoTaskInTime(200, AddDamageSetFalse)
                    end

                    if inst.mod_wereitem_moose_absorb ~= true and inst.components.health then
                        inst.components.health.absorb = inst.components.health.absorb + .1
                        if inst.components.health.absorb >= .95 then inst.components.health.absorb = .95 end
                        self.absorb = inst.components.health.absorb
                        inst.mod_wereitem_moose_absorb = true
                    end
                end
            end
            if oldeatfn ~= nil then
                oldeatfn(inst, food)
            end
        end
    end
    end)

    inst:ListenForEvent("respawnfromghost", function(inst, data)
        if inst.components.achievementability and inst.components.achievementability.woodieability then  
            if inst.mod_wereitem_goose_time  ~= nil and  inst.mod_wereitem_goose_time >= 0 and inst.prefab ~= "woodie" then
                if  inst.mod_goose_respawnfromghost == nil  then
                    inst.mod_goose_respawnfromghost = inst:DoTaskInTime(.2, DrownableEenabledF)
                elseif  inst.mod_goose_respawnfromghost ~= nil  then
                    inst.mod_goose_respawnfromghost:Cancel()
                    inst.mod_goose_respawnfromghost = inst:DoTaskInTime(.2, DrownableEenabledF)
                end
            end
        end
    end)
end

--嗜血
function achievementability:healthregencoin(inst)
    if self.healthregen < 1 and  self.coinamount >= ability_cost["healthregen"].cost and  inst.prefab ~= "wathgrithr"  then
        self.healthregen = 1
        self:coinDoDelta(-ability_cost["healthregen"].cost)
        self:ongetcoin(inst)
        self:healthregenfn(inst)
        inst:AddTag("valkyrie")
        inst:AddTag("allachivpotion") --药水制作tag
        local item1 = SpawnPrefab("halloweenpotion_health_large")
        local item2 = SpawnPrefab("halloweenpotion_sanity_large")
        item1.components.stackable:SetStackSize(2)
        item2.components.stackable:SetStackSize(2)
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        inst.components.inventory:GiveItem(item2, nil, inst:GetPosition())
    end
end

--嗜血效果
function achievementability:healthregenfn(inst)
	if self.healthregen > 0 then
		inst:AddTag("valkyrie")
        inst:AddTag("allachivpotion")    
    end
    if inst.healthregenEvent == nil then
        inst.healthregenEvent = true
        inst:ListenForEvent("onhitother", function(inst, data)
            local damage1 = data.damage
            local target1 = data.target
            if inst.prefab ~= "wathgrithr" and  target1 and not (target1:HasTag("wall") or target1:HasTag("engineering"))  and self.healthregen > 0 then 
                if inst.components.health ~= nil and inst.components.health:GetPercent() < 1 and inst.components.health:GetPercent() > 0 then
                    inst.components.health:DoDelta(0.005 * damage1, false, "batbat")
                end    
                if inst.components.sanity ~= nil and inst.components.sanity:GetPercent() < 1  then
                    inst.components.sanity:DoDelta(0.003 * damage1)
                end    
            end
            if inst.prefab ~= "woodie" and  target1 and not (target1:HasTag("wall") or target1:HasTag("engineering"))  and  inst.add_damage_set  and self.woodieability then 
                if  target1.components.health  and target1.components.health.currenthealth > 0 then
                    target1.components.health:DoDelta(-30.5)
                end
                if inst.components.hunger ~= nil and inst.components.hunger.current > 0  then
                    inst.components.hunger:DoDelta(-1)
                end 
            end
        end)
    end
end

--植物人能力
function achievementability:plantfriendcoin(inst)
    if self.effectswitch == false then
        self.effectswitch = true
        self.effectstype = 1
    elseif self.effectstype == 1 then
        self.effectstype = 2
    elseif self.effectstype == 2 then
        self.effectstype = 3
    else
        self.effectswitch = false
    end
    if self.coinamount >= ability_cost["plantfriend"].cost and self.plantfriend == false and inst.prefab ~= "wormwood" then
        self.plantfriend = true
        self:coinDoDelta(-ability_cost["plantfriend"].cost)
        self:plantfriendfn(inst)
        self:ongetcoin(inst)
        self.effectstype = 1
        self.effectswitch = true
        local item1 = SpawnPrefab("pepper_seeds")
        item1.components.stackable:SetStackSize(2)
        local item2 = SpawnPrefab("dragonfruit_seeds")
        item2.components.stackable:SetStackSize(2)
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        inst.components.inventory:GiveItem(item2, nil, inst:GetPosition())
    end
end


--植物人能力
function achievementability:plantfriendfn(inst)
    if inst and  self.plantfriend and inst.prefab ~= "wormwood" then
        inst:AddTag("plantkin")
        inst:AddTag("healonfertilize")
        inst:AddTag("achiveplantkin")      
        inst:ListenForEvent("deployitem", ondeployitem)
    end
    if inst.prefab ~= "wormwood" then 
        inst.planttask = nil          
        inst.pollenpool = { 1, 2, 3, 4, 5 }
        for i = #inst.pollenpool, 1, -1 do
               --randomize in place
            table.insert(inst.pollenpool, table.remove(inst.pollenpool, math.random(i)))
        end
        inst.plantpool = { 1, 2, 3, 4 }
        for i = #inst.plantpool, 1, -1 do
                --randomize in place
            table.insert(inst.plantpool, table.remove(inst.plantpool, math.random(i)))
        end      
    end 
    local PLANTS_RANGE = 1.5
    local MAX_PLANTS = 20
    --PlantTick 
    inst:DoPeriodicTask(.21, function()
    if  inst.prefab == "wormwood" then
        return
    end
    --开关
    if  self.effectswitch ~= true then
        return
    end
    if not self.plantfriend then
        return
    end
    if inst.sg:HasStateTag("ghostbuild") or inst.components.health:IsDead() or not inst.entity:IsVisible() then
        return
    end

    if  inst.components.drownable ~= nil and inst.components.drownable:IsOverWater()  then
        return
    end
 
    local  fx_name = "wormwood_plant_fx"
    if self.effectstype == 1 then
        fx_name = "wormwood_plant_fx"
    end
    if self.effectstype == 2 then
        fx_name = "fernsfx"   --   fernsfx
    end
    if self.effectstype == 3 then
        fx_name = "healflowersfx"   --   healflowersfx
    end
    local x, y, z = inst.Transform:GetWorldPosition()    
    if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, { fx_name }) < MAX_PLANTS then
        
        local map = TheWorld.Map
        local pt = Vector3(0, 0, 0)
        local offset = FindValidPositionByFan(
            math.random() * 2 * PI,
            math.random() * PLANTS_RANGE,
            3,
            function(offset)
                pt.x = x + offset.x
                pt.z = z + offset.z
                local tile = map:GetTileAtPoint(pt:Get())

                return tile ~= GROUND.IMPASSABLE
                    and tile ~= GROUND.INVALID
                    and #TheSim:FindEntities(pt.x, 0, pt.z, .5, { fx_name}) < 3
                    and map:IsDeployPointClear(pt, nil, .5)
                    and not map:IsPointNearHole(pt, .4)
            end
        )
        if offset ~= nil then
            local plant = SpawnPrefab(fx_name)
            local plant2 = SpawnPrefab(fx_name)
            if self.effectstype == 1 then
                if plant ~= nil then
                    plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
                    local rnd = math.random()
                    rnd = table.remove(inst.plantpool, math.clamp(math.ceil(rnd * rnd * #inst.plantpool), 1, #inst.plantpool))
                    table.insert(inst.plantpool, rnd)
                    plant:SetVariation(rnd)  
                end
                if plant2 ~= nil then
                    plant2.Transform:SetPosition(x - offset.x, 0, z - offset.z)
                    local rnd = math.random()
                    rnd = table.remove(inst.plantpool, math.clamp(math.ceil(rnd * rnd * #inst.plantpool), 1, #inst.plantpool))
                    table.insert(inst.plantpool, rnd)
                    plant2:SetVariation(rnd)  
                end
            elseif plant ~= nil and ( self.effectstype == 2 or self.effectstype == 3  ) then
                plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
            else
                if plant ~= nil and  self.effectstype == 4  then
                    plant.Transform:SetScale(.6,.6,0)
                    plant.Transform:SetPosition(x, 0, z)
                end

            end
        end
    end
    end)
end

local modname = KnownModIndex:GetModActualName("New Achivement")
local max_speedup = GetModConfigData("max_speedup",modname)
local max_damageup = GetModConfigData("max_damageup",modname)
local max_absorbup = GetModConfigData("max_absorbup",modname)
local max_crit = GetModConfigData("max_crit",modname)
local cost_kill_amount = GetModConfigData("cost_kill_amount",modname)
--提升速度获取
function achievementability:speedupcoin(inst)
    if self.coinamount >= ability_cost["speedup"].cost and self.speedup < max_speedup then
        self.speedup = self.speedup + 1
        inst.components.locomotor.externalspeedmultiplier = inst.components.locomotor.externalspeedmultiplier + ability_ratio["speedup"]
        self.speedcheck = inst.components.locomotor.externalspeedmultiplier
        self:coinDoDelta(-ability_cost["speedup"].cost)
        self:ongetcoin(inst)
    end
end

--提升攻击获取
function achievementability:damageupcoin(inst)
    if self.coinamount >= ability_cost["damageup"].cost and self.damageup < max_damageup then
        self.damageup = self.damageup + 1
        inst.components.combat.damagemultiplier = inst.components.combat.damagemultiplier + ability_ratio["damageup"]
        self.damagemul = inst.components.combat.damagemultiplier
        self:coinDoDelta(-ability_cost["damageup"].cost)
        self:ongetcoin(inst)
    end
end

--提升防御获取
function achievementability:absorbupcoin(inst)
    if self.coinamount >= ability_cost["absorbup"].cost and self.absorbup < max_absorbup then
        self.absorbup = self.absorbup + 1
        inst.components.health.absorb = inst.components.health.absorb + ability_ratio["absorbup"]
        if inst.components.health.absorb >= .95 then inst.components.health.absorb = .95 end
        self.absorb = inst.components.health.absorb
        self:coinDoDelta(-ability_cost["absorbup"].cost)
        self:ongetcoin(inst)
    end
end

--暴击奖励获取
function achievementability:critcoin(inst)
    if self.coinamount >= ability_cost["crit"].cost and self.crit < max_crit then
        self.crit = self.crit + 1
        self:coinDoDelta(-ability_cost["crit"].cost)
        self:ongetcoin(inst)
        if self.crit == 1 then
            self:critfn(inst)
        end
    end
end


--暴击奖励效果
function achievementability:critfn(inst)
    inst:ListenForEvent("onhitother", function(inst, data)
        local chance = ability_ratio["crit"]*self.crit
        local damage = data.damage
        local target = data.target
        if target and math.random(1,100) <= chance and not target:HasTag("wall") and self.crit > 0 and self.attackcheck ~= true then
            self.attackcheck = true
            if target.components.combat then
                target.components.combat:GetAttacked(inst, damage)
            end
            local snap = SpawnPrefab("impact")
            snap.Transform:SetScale(3, 3, 3)
            snap.Transform:SetPosition(target.Transform:GetWorldPosition())
            if target.SoundEmitter ~= nil then
                target.SoundEmitter:PlaySound("dontstarve/common/whip_large")
            end
            if target.components.lootdropper and  target.components.health and target.components.health:IsDead() then
                if target.components.freezable or target:HasTag("monster") then
                    target.components.lootdropper:DropLoot()
                end
            end
            inst:DoTaskInTime(.2, function() self.attackcheck = false end)
        end
    end)
end

local intensity = 0.90
--萤火微光获取
function achievementability:fireflylightcoin(inst)
	--inst:AddTag("nightvision")夜视tag 
	--手动开关是否发光
	--[[
	self.fireflylightswitch = 1 发光+效果
	self.fireflylightswitch = 2 发光 +无效果
	self.fireflylightswitch  = 3 不发光 +效果
	self.fireflylightswitch  = 4 不发光 + 无效果
	]]

    if self.fireflylight == true then
        self.fireflylightswitch = self.fireflylightswitch % 4 + 1
        if inst.components.talker ~= nil then
            inst.components.talker:Say(STRINGS.ACHIEVEMENT_FIRE_FLY_LIGHT[self.fireflylightswitch])
        end
		if self.fireflylightswitch ==3 or self.fireflylightswitch==4 then
			if inst._fireflylight ~= nil then
				inst._fireflylight.Light:SetIntensity(0)    
            	inst:DoTaskInTime(0.2, function() inst._fireflylight.Light:Enable(false)  end)
            end
		else
			if inst._fireflylight ~= nil and not TheWorld.components.worldstate.data.isday then
				inst._fireflylight.Light:SetIntensity(intensity)
           		inst:DoTaskInTime(0.2, function() inst._fireflylight.Light:Enable(true)   end)
       		end	
		end
	end
    if self.fireflylight ~= true and self.coinamount >= ability_cost["fireflylight"].cost then
        self.fireflylight = true
        self.fireflylightswitch = 1
        self:coinDoDelta(-ability_cost["fireflylight"].cost)
        self:fireflylightfn(inst)
        self:ongetcoin(inst)
    end
end

--萤火微光效果 fireflylightswitch
local function DoSpawnPrefabFx(inst)
    if ( inst.components.drownable == nil  or (inst.components.drownable ~= nil and not inst.components.drownable:IsOverWater()) ) and
     inst.components.achievementability and inst.components.achievementability.fireflylight and
      (inst.components.achievementability.fireflylightswitch ==1 or inst.components.achievementability.fireflylightswitch ==3 ) and 
     not inst:HasTag("playerghost") and inst.components.locomotor and inst.components.locomotor.wantstomoveforward and  
     not TheWorld.components.worldstate.data.isday   then
     local x,y,z = inst.Transform:GetWorldPosition()
        SpawnPrefab("deer_ice_flakes_aifx").Transform:SetPosition(x, 0, z)
    end
end
function achievementability:fireflylightfn(inst)
    if self.fireflylight then
        inst._fireflylight = SpawnPrefab("minerhatlight")
        inst._fireflylight.Light:SetRadius(2)
        inst._fireflylight.Light:SetFalloff(.36)
        inst._fireflylight.Light:SetIntensity(intensity)
        inst._fireflylight.Light:SetColour(255/255,255/255,255/255)
        --inst._fireflylight.Light:SetColour(0/255, 180/255, 255/255)
      
        inst._fireflylight.entity:SetParent(inst.entity)
        if TheWorld.components.worldstate.data.isday then
            inst._fireflylight.Light:SetIntensity(0)
            inst._fireflylight.Light:Enable(false)
        end
       -- deer_ice_flakes_aifx
        if inst.mod_fireflylightspawnprefab == nil  then
            inst.mod_fireflylightspawnprefab = inst:DoPeriodicTask(.5, DoSpawnPrefabFx)
        elseif  inst.mod_fireflylightspawnprefab ~= nil  then
            inst.mod_fireflylightspawnprefab:Cancel()
            inst.mod_fireflylightspawnprefab = inst:DoPeriodicTask(.5, DoSpawnPrefabFx)
        end
        inst:WatchWorldState("startday", function()
            inst._fireflylight.Light:SetIntensity(0)    
            inst:DoTaskInTime(1, function() inst._fireflylight.Light:Enable(false) end)
            if  inst.mod_fireflylightspawnprefab ~= nil  then
                inst.mod_fireflylightspawnprefab:Cancel()
                inst.mod_fireflylightspawnprefab = nil
            end
        end)
        inst:WatchWorldState("startdusk", function()
        	if self.fireflylightswitch == 1 or self.fireflylightswitch==2 then
           		inst._fireflylight.Light:SetIntensity(intensity)
           		inst:DoTaskInTime(1, function() inst._fireflylight.Light:Enable(true) end)
           	end
                if inst.mod_fireflylightspawnprefab == nil  then
                    inst.mod_fireflylightspawnprefab = inst:DoPeriodicTask(.5, DoSpawnPrefabFx)
                elseif  inst.mod_fireflylightspawnprefab ~= nil  then
                    inst.mod_fireflylightspawnprefab:Cancel()
                    inst.mod_fireflylightspawnprefab = inst:DoPeriodicTask(.5, DoSpawnPrefabFx)
                end
        end)
    end
end

--雨水免疫获取
function achievementability:nomoistcoin(inst)
    if self.nomoist then
        if self.nomoistswitch then
            inst.components.talker:Say(STRINGS.ACHIEVEMENT_NO_MOIST_END)
            self.nomoistswitch = false
            inst.components.moisture.maxMoistureRate = 0.75
        else
            self.nomoistswitch = true
            inst.components.talker:Say(STRINGS.ACHIEVEMENT_NO_MOIST_START)
            inst.components.moisture.maxMoistureRate = 0
        end
    end
    if self.nomoist ~= true and self.coinamount >= ability_cost["nomoist"].cost then
        self.nomoist = true
        self.maxMoistureRate = inst.components.moisture.maxMoistureRate
        inst.components.moisture.maxMoistureRate = 0
        self:coinDoDelta(-ability_cost["nomoist"].cost)
        self:ongetcoin(inst)
    end
end

--双倍掉落获取
function achievementability:doubledropcoin(inst)
    if self.doubledrop ~= true and self.coinamount >= ability_cost["doubledrop"].cost then
        self.doubledrop = true
        self:coinDoDelta(-ability_cost["doubledrop"].cost)
        self:ongetcoin(inst)
        self:doubledropfn(inst)
    end
end

function achievementability:_calc_kill_value(inst)
    inst:ListenForEvent("killed", function(inst, data)
        --杀戮值测试
        if data.victim and  data.victim.nokilltask == nil and data.victim:IsValid()   and data.victim.components.health ~= nil and data.victim.components.health.currenthealth == 0 
            and not ( 
            data.victim:HasTag("veggie") or
            data.victim:HasTag("structure") or
            data.victim:HasTag("wall") or
            data.victim:HasTag("balloon") or
            data.victim:HasTag("groundspike") or
            data.victim:HasTag("smashable") )
        then
        --  1 2 3 5 8 13 21 34 55 89 144 233  377 610 987
        --HP在250]及以下的     kill-- 1  概率获得1点 0.33
            if  data.victim.components.health.maxhealth <=250 and math.random()  < 0.33 then
                self:killDoDelta(1)
            end

            --HP在(250~800]之间的 kill-- 3
            if  data.victim.components.health.maxhealth >250 and data.victim.components.health.maxhealth <= 800  then
                self:killDoDelta(3)
            end

            --HP在(800~1250)之间的 kill-- 5
            if  data.victim.components.health.maxhealth >800 and data.victim.components.health.maxhealth <= 1250  then
                self:killDoDelta(5)
            end

            --HP在[1250,2500]的    kill-- 8
            if  data.victim.components.health.maxhealth >1250 and data.victim.components.health.maxhealth <= 2500  then
                self:killDoDelta(8)
            end

            --HP在(2500,3500]      kill-- 21
            if  data.victim.components.health.maxhealth >2500 and data.victim.components.health.maxhealth <= 3500  then
                self:killDoDelta(21)
            end

            --HP在(3500,5000]      kill-- 34
            if  data.victim.components.health.maxhealth >3500 and data.victim.components.health.maxhealth <= 50800  then
                self:killDoDelta(34)
            end

            --HP在(5000,8000]      kill-- 55
            if  data.victim.components.health.maxhealth >5000 and data.victim.components.health.maxhealth <= 8000  then
                self:killDoDelta(55)
            end

            --HP在(8000,18000]      kill-- 89
            if  data.victim.components.health.maxhealth >8000 and data.victim.components.health.maxhealth < 18000  then
                self:killDoDelta(89)
            end

            --HP在(18000,30000]     kill-- 144
            if  data.victim.components.health.maxhealth >18000 and data.victim.components.health.maxhealth <= 30000  then
                self:killDoDelta(144)
            end

            --HP在(30000,55000]     kill-- 233
            if  data.victim.components.health.maxhealth >30000 and data.victim.components.health.maxhealth <= 55000  then
                self:killDoDelta(233)
            end

            --HP在(55000,+)      kill-- 377
            if  data.victim.components.health.maxhealth >55000   then
                self:killDoDelta(377)
            end
        end
    end)
end

--双倍掉落效果
function achievementability:doubledropfn(inst)
    if inst.doubledropEvent == nil then
        inst.doubledropEvent = true
        inst:ListenForEvent("killed", function(inst, data)
            if self.doubledrop and data.victim.components.lootdropper then
                if data.victim.components.freezable or data.victim:HasTag("monster") then
                    if data.victim ~= nil and  data.victim.nodoubletask == nil and data.victim:IsValid()  then
                        data.victim.components.lootdropper:DropLoot()
                    end
                end
            end
            ------------------------------------------------------------------------------------------------------------------
            --阿比盖尔击杀和玩家击杀唯一性
            if data.victim ~= nil and  data.victim.abigailkill_ai == nil and data.victim:IsValid()  and (  data.victim.components.freezable or data.victim:HasTag("monster") ) then
            --victim and victim.components.combat then victim.components.combat:GetAttacked(v, 1) end
            local victim_check = data.victim
                victim_check.abigailkill_ai = victim_check:DoTaskInTime(1.3, function(victim_check)  victim_check.abigailkill_ai = nil end)
            end
        end)
    end
end

--首领标签获取
function achievementability:goodmancoin(inst)
    if self.goodman ~= true and self.coinamount >= ability_cost["goodman"].cost then
        self.goodman = true
        self:coinDoDelta(-ability_cost["goodman"].cost)
        self:ongetcoin(inst)
        local item1 = SpawnPrefab("hivehat")
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        self:goodmanfn(inst)
    end
end

--首领 标签效果
function achievementability:goodmanfn(inst)
    inst:DoPeriodicTask(1, function()
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if self.goodman and item ~= nil and item.prefab == "hivehat"  then
            local pos = Vector3(inst.Transform:GetWorldPosition())
            local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 6)
            for k,v in pairs(ents) do
                if v.prefab then
                    if v.prefab == "pigman" or v.prefab == "bunnyman" 
                        or v.prefab == "hound"
                        or v.prefab == "firehound"
                        or v.prefab == "icehound"
                        or v.prefab == "spider"
                        or v.prefab == "spider_hider"
                        or v.prefab == "spider_spitter"
                        or v.prefab == "spider_warrior"
                        or v.prefab == "spider_moon" --月岛蜘蛛
                        or v.prefab == "merm" --鱼人
                        or v.prefab == "mermguard" --鱼人守卫
                        --or v.prefab == "catcoon"
                        or v.prefab == "spider_dropper" then
                        if v.components.follower and v.components.follower.leader == nil
                        and not v:HasTag("werepig")
                        --and not v:HasTag("guard")
                         then
                            if v.components.combat:TargetIs(inst) then
                                v.components.combat:SetTarget(nil)
                            end
                            if inst.components.leader and inst.components.leader.numfollowers < 50  then
                                inst.components.leader:AddFollower(v)
                            end
                        end
                    end
                end
            end
        end
    end)
end

--垂钓圣手获取
function achievementability:fishmastercoin(inst)
    if self.fishmaster ~= true and self.coinamount >= ability_cost["fishmaster"].cost then
        self.fishmaster = true
        self:coinDoDelta(-ability_cost["fishmaster"].cost)
        self:ongetcoin(inst)
        self:fishmasterfn(inst)
        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).components
        and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).components.fishingrod then
            local fishingrod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).components.fishingrod
            self.fishtimemin = fishingrod.minwaittime
            self.fishtimemax = fishingrod.maxwaittime
            fishingrod:SetWaitTimes(1, 1)
        end
    end
end

--垂钓圣手效果
function achievementability:fishmasterfn(inst)
    inst:ListenForEvent("equip", function(inst, data)
        if  self.fishmaster and data.item and data.item.components.fishingrod then
            self.fishtimemin = data.item.components.fishingrod.minwaittime
            self.fishtimemax = data.item.components.fishingrod.maxwaittime
            data.item.components.fishingrod:SetWaitTimes(1, 1)
        end
    end)
    inst:ListenForEvent("unequip", function(inst, data)
        if self.fishmaster and data.item and data.item.components.fishingrod then
            data.item.components.fishingrod:SetWaitTimes(self.fishtimemin, self.fishtimemax)
        end
    end)
end

--双倍采集获取
function achievementability:pickmastercoin(inst)
    if self.pickmaster ~= true and self.coinamount >= ability_cost["pickmaster"].cost then
        self.pickmaster = true
        self:coinDoDelta(-ability_cost["pickmaster"].cost)
        self:ongetcoin(inst)
        self:pickmasterfn(inst)
    end
end

--双倍采集效果
function achievementability:pickmasterfn(inst)
    if inst.pickmasterEvent == nil then
        inst.pickmasterEvent = true
        inst:ListenForEvent("picksomething", function(inst, data)
            if self.pickmaster and data.object and data.object.components.pickable and not data.object.components.trader then
                if data.object.components.pickable.product ~= nil then
                    local item = SpawnPrefab(data.object.components.pickable.product)
                    if item.components.stackable then
                        item.components.stackable:SetStackSize(data.object.components.pickable.numtoharvest)
                    end
                    inst.components.inventory:GiveItem(item, nil, data.object:GetPosition())
                    if inst:HasTag("player") and not inst:HasTag("playerghost") and  ( data.object.prefab  == "cactus" or data.object.prefab  == "oasis_cactus" )  and  data.object.has_flower  then 
                        local lootcactus_flower = SpawnPrefab("cactus_flower")
                        if lootcactus_flower ~= nil then
                            inst.components.inventory:GiveItem(lootcactus_flower, nil, data.object:GetPosition())
                        end
                    end
                end
            end
        end)
    end
end

--砍树圣手获取
function achievementability:chopmastercoin(inst)
    if self.chopmaster ~= true and self.coinamount >= ability_cost["chopmaster"].cost and inst.prefab ~= "woodie"  then
        self.chopmaster = true
        self:coinDoDelta(-ability_cost["chopmaster"].cost)
        self:ongetcoin(inst)
        self:chopmasterfn(inst)
    end
end

--砍树圣手效果
function achievementability:chopmasterfn(inst)
    inst:ListenForEvent("working", function(inst, data)
        if self.chopmaster and data.target and data.target.components.workable and data.target:HasTag("tree") then
            local workable = data.target.components.workable
            if data.target.components.workable.action == ACTIONS.CHOP then
            	local equipitem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                --if equipitem ~= nil and (equipitem.prefab == "axe" or equipitem.prefab == "goldenaxe" or equipitem.prefab == "moonglassaxe" or equipitem.prefab == "multitool_axe_pickaxe"    ) then
            	if equipitem ~= nil  and equipitem.components.finiteuses ~= nil then
            
                	local itemuses =   equipitem.components.finiteuses:GetUses() 
                	if  itemuses > 0 then
                		if workable.workleft >= 1 then
                			if equipitem.components.finiteuses.consumption[ACTIONS.CHOP] ~= nil then
                				local uses2 = equipitem.components.finiteuses.consumption[ACTIONS.CHOP]
                				equipitem.components.finiteuses:Use(workable.workleft*uses2)
                			else 
                				equipitem.components.finiteuses:Use(workable.workleft)
                			end
						end
                	end
            	end
            end
            workable.workleft = 0
        end
    end)
end

--烹调圣手获取
function achievementability:cookmastercoin(inst)
    if self.cookmaster then
        if self.cookmasterswitch then
            self.cookmasterswitch = false
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_FAST_COOK_END)
            end
        else
            self.cookmasterswitch = true
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_FAST_COOK_START)
            end
        end
    end
    if self.cookmaster ~= true and self.coinamount >= ability_cost["cookmaster"].cost and inst.prefab ~= "warly" then
        self.cookmaster = true
        self.cookmasterswitch = true
        self:coinDoDelta(-ability_cost["cookmaster"].cost)
        self:ongetcoin(inst)

        inst:AddTag("masterchef")
        inst:AddTag("professionalchef")
        inst:AddTag("expertchef")
        local item1 = SpawnPrefab("portablecookpot_item")
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        self:cookmasterfn(inst)
    end
end

--烹调圣手效果&煮食事件内置
function achievementability:cookmasterfn(inst)
    if self.cookmaster == true  then
        inst:AddTag("masterchef")
        inst:AddTag("professionalchef")
        inst:AddTag("expertchef")
    end
end

--节省材料获取
function achievementability:buildmastercoin(inst)
    if self.buildmaster ~= true and self.coinamount >= ability_cost["buildmaster"].cost then
        self.buildmaster = true
        inst.components.builder.ingredientmod = .5
        self:coinDoDelta(-ability_cost["buildmaster"].cost)
        self:buildmasterfn(inst)
        inst.components.builder.ingredientmod = .5
        self:ongetcoin(inst)
        local item1 = SpawnPrefab("greengem")
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
    end
end

--节省材料效果
function achievementability:buildmasterfn(inst)
    if self.buildmaster then
        inst.components.builder.ingredientmod = .5
    end
    inst:ListenForEvent("equip", function(inst, data)
        if self.buildmaster and data.item and data.item.prefab == "greenamulet" then
            inst.components.builder.ingredientmod = .5
        end
    end)
    inst:ListenForEvent("unequip", function(inst, data)
        if self.buildmaster and data.item and data.item.prefab == "greenamulet" then
            inst.components.builder.ingredientmod = .5
        end
    end)
end

--携带反鲜获取
function achievementability:refreshcoin(inst)
    if self.refresh ~= true and self.coinamount >= ability_cost["refresh"].cost then
        self.refresh = true
        self:coinDoDelta(-ability_cost["refresh"].cost)
        self:ongetcoin(inst)
        self:refreshfn(inst)
        local item1 = SpawnPrefab("ice")
        item1.components.stackable:SetStackSize(6)
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
    end
end

--携带反鲜效果
function achievementability:refreshfn(inst)
    if inst.refreshtask == nil then
        inst.refreshtask = inst:DoPeriodicTask(1, function()
            if self.refresh then
                --物品栏反鲜
                for k,v in pairs(inst.components.inventory.itemslots) do
                    if v and v.components.perishable then
                        v.components.perishable:ReducePercent(-.005)
                    end
                end
                --装备栏反鲜
                for k,v in pairs(inst.components.inventory.equipslots) do
                    if v and v.components.perishable then
                        v.components.perishable:ReducePercent(-.01)
                    end
                end
                --背包反鲜
                for k,v in pairs(inst.components.inventory.opencontainers) do
                    if k and k:HasTag("backpack") and k.components.container then
                        for i,j in pairs(k.components.container.slots) do
                            if j and j.components.perishable then
                                j.components.perishable:ReducePercent(-.005)
                            end
                        end
                    end
                end
            end
        end)
    end
end

--低温免疫获取
function achievementability:icebodycoin(inst)
    if self.icebody ~= true and self.coinamount >= ability_cost["icebody"].cost then
        self.icebody = true
        self:coinDoDelta(-ability_cost["icebody"].cost)
        self:icebodyfn(inst)
        self:ongetcoin(inst)
    end
end

--低温免疫效果  自适应环境 温度  适应季节
local function OnSeasonChangeAdaption(inst)
    if  TheWorld.components.worldstate.data.issummer or TheWorld.components.worldstate.data.isautumn then
        if inst.components.achievementability and inst.components.achievementability.icebody and inst.components.temperature  then
            inst.components.temperature.maxtemp = 60
            inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
        end
    else
        if inst.components.achievementability and inst.components.achievementability.icebody and inst.components.temperature then
            inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP
            inst.components.temperature.mintemp = 10
        end
    end
end


function achievementability:icebodyfn(inst)
    if self.icebody == true then
        if  TheWorld.components.worldstate.data.issummer or TheWorld.components.worldstate.data.isautumn then
            inst.components.temperature.maxtemp = 60
            inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
        else
            inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP
            inst.components.temperature.mintemp = 10
        end
        inst.icebodytemperature = inst:DoPeriodicTask(5, OnSeasonChangeAdaption)
    end
end

--火焰免疫获取
function achievementability:firebodycoin(inst)
    if self.firebody ~= true and self.coinamount >= ability_cost["firebody"].cost and inst.prefab ~= "willow" then
        self.firebody = true
        self:coinDoDelta(-ability_cost["firebody"].cost)
        self:firebodyfn(inst)
        self:ongetcoin(inst)
    end
end

--火焰免疫效果
function achievementability:firebodyfn(inst)
    if self.firebody == true then
        inst:AddTag("pyromaniac")  --制作打火机和伯尼and 快速灭火
        inst:AddTag("bernieowner")
        inst:AddTag("heatresistant")
        inst.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE
        if  inst.components.sanity then
            inst.components.sanity.custom_rate_fn = sanityfn
        end
        inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_SMALL
        inst.components.temperature:SetOverheatHurtRate(0.5)  --过热伤害
    end
end

--补给建造获取
function achievementability:supplycoin(inst)
    if self.supply ~= true and self.coinamount >= ability_cost["supply"].cost then
        self.supply = true
        self:coinDoDelta(-ability_cost["supply"].cost)
        self:supplyfn(inst)
        local item1 = SpawnPrefab("redmooneye")
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        local item2 = SpawnPrefab("bluemooneye")
        inst.components.inventory:GiveItem(item2, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

--补给建造效果
function achievementability:supplyfn(inst)
    if self.supply then
        inst:AddTag("achiveking")
    end
end

--书籍阅读获取
function achievementability:readercoin(inst)
    if self.reader ~= true and self.coinamount >= ability_cost["reader"].cost and inst.prefab ~= "wickerbottom" then
        self.reader = true
        self:coinDoDelta(-ability_cost["reader"].cost)
        self:readerfn(inst)
        local item1 = SpawnPrefab("papyrus")
        item1.components.stackable:SetStackSize(6)
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

--书籍阅读效果
function achievementability:readerfn(inst)
    if self.reader then
        if inst.prefab == "wurt" then
			inst:RemoveTag("aspiring_bookworm")
		end
        if inst.prefab ~= "wickerbottom" and inst.prefab ~= "waxwell" then
            inst:AddComponent("reader")
        end
        inst:AddTag("achivbookbuilder")
    end
end

--天降正义 wickerbottom 专属
function achievementability:justiceraincoin(inst)
    if self.justicerain ~= true and self.coinamount >= ability_cost["justicerain"].cost and inst.prefab == "wickerbottom" then
        self.justicerain = true
        self:coinDoDelta(-ability_cost["justicerain"].cost)
        self:justicerainfn(inst)
        local item1 = SpawnPrefab("papyrus")
        item1.components.stackable:SetStackSize(6)
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

--天降正义 阅读效果
function achievementability:justicerainfn(inst)
    if self.justicerain then
        inst:AddTag("achivbookbuilder")
    end
end

--百无禁忌-
function achievementability:morestrongstomachcoin(inst)
    if self.morestrongstomach ~= true and self.coinamount >= ability_cost["morestrongstomach"].cost then
        self.morestrongstomach = true
        self:coinDoDelta(-ability_cost["morestrongstomach"].cost)
        self:morestrongstomachfn(inst)
        self:ongetcoin(inst)
    end
end
function achievementability:morestrongstomachfn(inst)
    if self.morestrongstomach  then
        if inst.components.eater ~= nil then
            inst.components.eater.ignoresspoilage = true  --无视新鲜
            inst.components.eater.strongstomach = true --吃怪物肉
            inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
            inst.components.eater.preferseatingtags = nil
            inst:RemoveComponent("foodmemory")
        end
        if inst.components.hunger ~= nil then
            inst.components.hunger.burnratemodifiers:SetModifier(inst,TUNING.ARMORSLURPER_SLOW_HUNGER)
        end

        if self.morestrongstomach  and   inst.components.inventory  then  --不能 和饥饿腰带叠加 
            for k,v in pairs(inst.components.inventory.equipslots) do
                if v and v.prefab == "armorslurper"  then
                    if inst.components.hunger ~= nil  then
                        inst.components.hunger.burnratemodifiers:RemoveModifier(inst)
                    end
                end
            end
        end
        inst:ListenForEvent("equip", function(inst, data)
            if data.item and data.item.prefab == "armorslurper"  then --饥饿腰带  时移除MOD添加的
                if  self.morestrongstomach and inst.components.hunger ~= nil  then
                    inst.components.hunger.burnratemodifiers:RemoveModifier(inst)
                end
            end
        end)

        inst:ListenForEvent("unequip", function(inst, data)
            if data.item and data.item.prefab == "armorslurper"  then --饥饿腰带
                if self.morestrongstomach and inst.components.hunger ~= nil then
                    inst.components.hunger.burnratemodifiers:SetModifier(inst,TUNING.ARMORSLURPER_SLOW_HUNGER)
                end
            end
        end)
    end
end

-----------------------------------暗影顺从------------------------------------------- 
function achievementability:shadowsubmissivecoin(inst)
    if self.shadowsubmissive == true then
        if self.shadowsubmissiveswitch == true  then
            self.shadowsubmissiveswitch = false
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_SANITY_END)
            end
            if inst.components.sanity ~= nil then
                inst.components.sanity:SetInducedInsanity(inst, true)
            end
        else
            self.shadowsubmissiveswitch = true
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_SANITY_START)
            end
            if inst.components.sanity ~= nil then
                inst.components.sanity:SetInducedInsanity(inst, false)
            end
        end
    end
    if self.shadowsubmissive ~= true and self.coinamount >= ability_cost["shadowsubmissive"].cost then
        self.shadowsubmissive = true
        self:coinDoDelta(-ability_cost["shadowsubmissive"].cost)
        inst:AddTag("achiv_shadow")
        inst:AddTag("shadowlure")--骨架跟随
        self.shadowsubmissiveswitch = true
        inst:DoPeriodicTask(.1, function()
            if inst:HasTag("achiv_shadow")  then
                local pos = Vector3(inst.Transform:GetWorldPosition())
                local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 10)
                for k,v in pairs(ents) do
                    if v.prefab then
                        if v.prefab == "crawlinghorror" or v.prefab == "terrorbeak"  then
                            if v.brain ~= nil and v.brain.mytarget ~= nil and v.brain.mytarget == inst  and v.components.combat ~= nil then
                                v.brain:OnStop() 
                                v.components.combat.target = nil 
                            end
                        end
                        if  v.prefab == "crawlingnightmare" or v.prefab == "nightmarebeak"  then
                            if  v.components.combat ~= nil and v.components.combat.target == inst then
                                v.components.combat.target = nil
                            end
                            if v.brain ~= nil and v.brain._harasstarget ~= nil and v.brain._harasstarget == inst   then
                                v.brain._harasstarget = nil
                            end
                        end
                    end
                end
            end
        end)

        self:ongetcoin(inst)
    end
end

function achievementability:shadowsubmissivefn(inst)
    if self.shadowsubmissive == true then
        inst:AddTag("achiv_shadow")
        inst:AddTag("shadowlure")--骨架跟随
        inst:DoPeriodicTask(.1, function()
            if inst:HasTag("achiv_shadow")  then
                local pos = Vector3(inst.Transform:GetWorldPosition())
                local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 10)
                for k,v in pairs(ents) do
                    if v.prefab then
                        if v.prefab == "crawlinghorror" or v.prefab == "terrorbeak"  then
                            if v.brain ~= nil and v.brain.mytarget ~= nil and v.brain.mytarget == inst  and v.components.combat ~= nil then
                                v.brain:OnStop() 
                                v.components.combat.target = nil
                            end
                        end
                        if  v.prefab == "crawlingnightmare" or v.prefab == "nightmarebeak"  then
                            if  v.components.combat ~= nil and v.components.combat.target == inst then
                                v.components.combat.target = nil
                            end
                            if v.brain ~= nil and v.brain._harasstarget ~= nil and v.brain._harasstarget == inst   then
                                v.brain._harasstarget = nil
                            end
                        end
                    end
                end
            end
        end)
    end
end

function achievementability:eventtechnologycoin(inst)
    if self.eventtechnology ~= true and self.coinamount >= ability_cost["eventtechnology"].cost then
        self.eventtechnology = true
        self:coinDoDelta(-ability_cost["eventtechnology"].cost)
        inst:AddTag("achive_science")
        local item1 = SpawnPrefab("lucky_goldnugget")
        item1.components.stackable:SetStackSize(10)
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        if inst.components.builder then
            inst.components.builder:UnlockRecipe("giftwrap")--彩色纸
            inst.components.builder:UnlockRecipe("candybag")--糖果袋
            inst.components.builder:UnlockRecipe("winter_treestand")--圣诞树
            inst.components.builder:UnlockRecipe("madscience_lab")--科学实验
            inst.components.builder:UnlockRecipe("perdshrine")--鸡
            inst.components.builder:UnlockRecipe("wargshrine")--狗
            inst.components.builder:UnlockRecipe("pigshrine")--猪
            inst.components.builder:UnlockRecipe("yotc_carratshrine")--鼠
        end  
        self:ongetcoin(inst)
    end
end
function achievementability:eventtechnologyfn(inst)
    if self.eventtechnology  then
        inst:AddTag("achive_science")
        if inst.components.builder then
            inst.components.builder:UnlockRecipe("giftwrap")--彩色纸
            inst.components.builder:UnlockRecipe("candybag")--糖果袋
            inst.components.builder:UnlockRecipe("winter_treestand")--圣诞树
            inst.components.builder:UnlockRecipe("madscience_lab")--科学实验
            inst.components.builder:UnlockRecipe("perdshrine")--鸡
            inst.components.builder:UnlockRecipe("wargshrine")--狗
            inst.components.builder:UnlockRecipe("pigshrine")--猪
            inst.components.builder:UnlockRecipe("yotc_carratshrine")--鼠
        end 
    end
end

-------------------------------鱼人伪装------------------------------------------
function achievementability:murlocdisguisecoin(inst)
    if self.murlocdisguise == true then
        if self.murlocdisguiseswitch == true  then
            self.murlocdisguiseswitch = false
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_MURLOCDISGUISE_END)
            end
            inst:RemoveTag("merm")
            inst:RemoveTag("mermguard")
        else
            self.murlocdisguiseswitch = true
            if inst.components.talker ~= nil then
                inst.components.talker:Say(STRINGS.ACHIEVEMENT_MURLOCDISGUISE_START)
            end
            inst:AddTag("merm")
            inst:AddTag("mermguard")
        end
    end

    if self.murlocdisguise ~= true and self.coinamount >= ability_cost["murlocdisguise"].cost and inst.prefab ~= "wurt"then
        self.murlocdisguise = true
        self:coinDoDelta(-ability_cost["murlocdisguise"].cost)

        inst:AddTag("merm_builder")  --修建tag
        inst:AddTag("stronggrip")  --武器不脱
        inst:AddTag("mermfluent")
        inst:AddTag("merm")
        inst:AddTag("mermguard")
        inst.components.locomotor:SetFasterOnGroundTile(GROUND.MARSH, true)
        inst.components.locomotor:SetFasterOnGroundTile(GROUND.CARPET, true)
        self.murlocdisguiseswitch = true
        local item1 = SpawnPrefab("tentaclespots")
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end
function achievementability:murlocdisguisefn(inst)
    if self.murlocdisguise  then
        inst:AddTag("merm_builder")  --修建tag
        inst:AddTag("stronggrip")  --武器不脱
        inst:AddTag("mermfluent")
        if self.murlocdisguiseswitch  then
            inst:RemoveTag("merm")
            inst:RemoveTag("mermguard")
        else
            inst:AddTag("merm")
            inst:AddTag("mermguard")
        end

        inst.components.locomotor:SetFasterOnGroundTile(GROUND.MARSH, true)
        inst.components.locomotor:SetFasterOnGroundTile(GROUND.CARPET, true)
    end
end
------------------------------快速采集收获------------------------------------------
function achievementability:fastcollectioncoin(inst)
    if self.fastcollection ~= true and self.coinamount >= ability_cost["fastcollection"].cost  then
        self.fastcollection = true
        self:coinDoDelta(-ability_cost["fastcollection"].cost)
        self:fastcollectionfn(inst)
        self:ongetcoin(inst)
    end
end
function achievementability:fastcollectionfn(inst)
    if self.fastcollection == true then
        inst:AddTag("fastpicker")
        inst:AddTag("fastharvester") --快速收获
    end
end

--wendy
local function WendyOnDespawn(inst)
    local abigail = inst.components.ghostlybond.ghost
    if abigail then
        abigail:RemoveFromScene()
    end
    -- if abigail ~= nil and abigail.sg ~= nil and not abigail.inlimbo then
	-- 	if not abigail.sg:HasStateTag("dissipate") then
	-- 		abigail.sg:GoToState("dissipate")
    --     end
    -- end
    -- if abigail ~= nil then
    --     abigail:DoTaskInTime(25 * FRAMES, abigail.Remove) 
    -- end
end

local function WendyOnSave(inst, data)
    if inst.questghost ~= nil then
        data.questghost = inst.questghost:GetSaveRecord()
    end
end

local function WendyOnLoad(inst, data)
    if data ~= nil then
		if data.abigail ~= nil then -- retrofitting
			inst.components.inventory:GiveItem(SpawnPrefab("abigail_flower"))
		end
        if data.questghost ~= nil and inst.questghost == nil then
            local questghost = SpawnSaveRecord(data.questghost)
            if questghost ~= nil then
                if inst.migrationpets ~= nil then
                    table.insert(inst.migrationpets, questghost)
                end
                questghost.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
                questghost:LinkToPlayer(inst)
            end
        end
        if (TheNet:IsDedicated() or TheNet:GetIsServer()) and data.ghostlybond and inst.components.ghostlybond then
            inst.components.ghostlybond:OnLoad(data.ghostlybond)
        end
    end
end

local function WalterOnSave(inst, data)
	data.woby = inst.woby ~= nil and inst.woby:GetSaveRecord() or nil
end

local function WalterOnLoad(inst, data)
	if data ~= nil and data.woby ~= nil then
		inst._woby_spawntask:Cancel()
		inst._woby_spawntask = nil
		local woby = SpawnSaveRecord(data.woby)
		inst.woby = woby
		if woby ~= nil then
			if inst.migrationpets ~= nil then
				table.insert(inst.migrationpets, woby)
			end
			woby:LinkToPlayer(inst)

	        woby.AnimState:SetMultColour(0,0,0,1)
            woby.components.colourtweener:StartTween({1,1,1,1}, 19*FRAMES)
			local fx = SpawnPrefab(woby.spawnfx)
			fx.entity:SetParent(woby.entity)

			inst:ListenForEvent("onremove", inst._woby_onremove, woby)
		end
	end
end

local function WalterOnDespawn(inst)
    if inst.woby ~= nil then
		inst.woby:OnPlayerLinkDespawn()
    end
end

local function OnSave(inst,data)
    if inst.OldOnSave then
        inst:OldOnSave(data)
    end
    if inst.components.achievementability.fearless == true then
        WalterOnSave(inst, data)
    end
    if inst.components.achievementability.ghostly_friend then
        WendyOnSave(inst,data)
    end
end

local function OnLoad(inst, data)
    if inst.OldOnLoad then
        inst:OldOnLoad(data)
    end
    if inst.components.achievementability.fearless == true then
        WalterOnLoad(inst, data)
    end
    if inst.components.achievementability.ghostly_friend then
        WendyOnLoad(inst,data)
    end
end

local function OnDespawn(inst)
    if inst.components.achievementability.fearless == true then
        WalterOnDespawn(inst)
    end
    if inst.components.achievementability.ghostly_friend then
        WendyOnDespawn(inst)
    end
    if inst.OldOnDespawn then
        inst:OldOnDespawn()
    end
end

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

local function ghostlybond_onlevelchange(inst, ghost, level, prev_level, isloading)
	inst._bondlevel:set(level)
	if not isloading and inst.components.talker ~= nil and level > 1 then
		inst.components.talker:Say(GetString(inst, "ANNOUNCE_GHOSTLYBOND_LEVELUP", "LEVEL"..tostring(level)))
		OnBondLevelDirty(inst)
	end
end

local function ghostlybond_onsummon(inst, ghost)
	if inst.components.sanity ~= nil and inst.migration == nil then
		inst.components.sanity:DoDelta(TUNING.SANITY_MED)
	end
end

local function ghostlybond_onrecall(inst, ghost, was_killed)
	if inst.migration == nil then
		if inst.components.sanity ~= nil then
			inst.components.sanity:DoDelta(was_killed and (-TUNING.SANITY_MED * 2) or -TUNING.SANITY_MED)
		end
		if inst.components.talker ~= nil then
			inst.components.talker:Say(GetString(inst, was_killed and "ANNOUNCE_ABIGAIL_DEATH" or "ANNOUNCE_ABIGAIL_RETRIEVE"))
		end
	end
	inst.components.ghostlybond.ghost.sg:GoToState("dissipate")
end
local function ghostlybond_changebehaviour(inst, ghost)
    if ghost.is_defensive then
        ghost:BecomeAggressive()
    else
        ghost:BecomeDefensive()
    end
    return true
end

function achievementability:ghostly_friendcoin(inst)
    if self.ghostly_friend ~= true and self.coinamount >= ability_cost["ghostly_friend"].cost  and inst.prefab ~= "wendy" then
        self.ghostly_friend = true
        self:coinDoDelta(-ability_cost["ghostly_friend"].cost)
        local item1 = SpawnPrefab("ghostflower")
        inst.components.inventory:GiveItem(item1, nil, inst:GetPosition())
        local item2 = SpawnPrefab("nightmarefuel")
        inst.components.inventory:GiveItem(item2, nil, inst:GetPosition())
        self:ongetcoin(inst)
        self:ghostly_friendfn(inst)
    end
end

function achievementability:ghostly_friendfn(inst)
    if self.ghostly_friend then
        inst:AddTag("ghostlyfriend") 
        inst:AddTag("elixirbrewer")--
        inst:AddTag("achive_elixirbrewer")--
        if not inst.components.pethealthbar then
            inst:AddComponent("pethealthbar")
        end
        inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
        inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
        inst.components.sanity:AddSanityAuraImmunity("ghost")
        inst.components.sanity:SetPlayerGhostImmunity(true)
        if not inst.components.ghostlybond then
            inst:AddComponent("ghostlybond")
            inst.components.ghostlybond.onbondlevelchangefn = ghostlybond_onlevelchange
            inst.components.ghostlybond.onsummonfn = ghostlybond_onsummon
            inst.components.ghostlybond.onrecallfn = ghostlybond_onrecall
            inst.components.ghostlybond.changebehaviourfn = ghostlybond_changebehaviour
            inst.components.ghostlybond:Init("abigail", TUNING.ABIGAIL_BOND_LEVELUP_TIME)
        end
        inst.OnDespawn = OnDespawn
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
    else
        if inst.prefab ~= "wendy" then
            inst:RemoveTag("ghostlyfriend") 
            inst:RemoveTag("elixirbrewer")
        end
        --inst:RemoveComponent("pethealthbar")
    end
end

function achievementability:ghostly_friendRemove()
    local inst = self.inst
    if self.ghostly_friend then
       WendyOnDespawn(inst)
       inst:RemoveTag("ghostlyfriend")
       inst:RemoveTag("elixirbrewer")
       inst:RemoveTag("achive_elixirbrewer")
       inst.components.sanity.night_drain_mult = 1
       inst.components.sanity.neg_aura_mult = 1
       inst.components.sanity:RemoveSanityAuraImmunity("ghost")
       inst.components.sanity:SetPlayerGhostImmunity(false)
       --inst:RemoveComponent("ghostlybond")
       --inst:RemoveComponent("pethealthbar")
       inst.components.achievementability.ghostly_friend_maxhealth =  150
       inst.components.achievementability.ghostly_friend_curhealth=1
    end
end

function achievementability:autorepaircoin(inst)
    if self.autorepair ~= true and self.coinamount >=  ability_cost["autorepair"].cost then
        self.autorepair = true
        self:coinDoDelta(-ability_cost["autorepair"].cost)
        self:autorepairfn(inst)
        self:ongetcoin(inst)
    end
end

function achievementability:autorepairfn(inst)
    if inst.autorepairtask == nil then
        inst.autorepairtask = inst:DoPeriodicTask(5, function()
            if self.autorepair then
                local inventory = inst.components.inventory
                if inventory then
                    for _, v in pairs(inventory.equipslots) do
                        if not table.contains(micellanceous_config.magiclist, v.prefab) then
                            if v.components.finiteuses then
                                local duration = v.components.finiteuses:GetPercent()
                                duration = math.min(duration+0.005, 1.0)
                                v.components.finiteuses:SetPercent(duration)
                            end
                            if v.components.armor then
                                local duration = v.components.armor:GetPercent()
                                duration = math.min(duration+0.005, 1.0)
                                v.components.armor:SetPercent(duration)
                            end
                            if v.components.fueled then
                                local duration = v.components.fueled:GetPercent()
                                duration = math.min(duration+0.005, 1.0)
                                v.components.fueled:SetPercent(duration)
                            end
                        end
                    end
                end
            end
        end)
    end
end

function achievementability:magicpepaircoin(inst)
    if self.magicpepair ~= true and self.coinamount >= ability_cost["magicpepair"].cost then
        self.magicpepair = true
        self:coinDoDelta(-ability_cost["magicpepair"].cost)
        self:magicpepairfn(inst)
        self:ongetcoin(inst)
    end
end

function achievementability:magicpepairfn(inst)
    if inst.magicpepairtask == nil then
        inst.magicpepairtask = inst:DoPeriodicTask(10, function()
            if self.magicpepair then
                local inventory = inst.components.inventory
                if inventory then
                    for k, v in pairs(inventory.equipslots) do
                        if table.contains(micellanceous_config.magiclist, v.prefab) then
                            if v.components.finiteuses then
                                local duration = v.components.finiteuses:GetPercent()
                                duration = math.min(duration+0.01, 1.0)
                                v.components.finiteuses:SetPercent(duration)
                            end
                            if v.components.armor then
                                local duration = v.components.armor:GetPercent()
                                duration = math.min(duration+0.01, 1.0)
                                v.components.armor:SetPercent(duration)
                            end
                            if v.components.fueled then
                                local duration = v.components.fueled:GetPercent()
                                duration = math.min(duration+0.02, 1.0)
                                v.components.fueled:SetPercent(duration)
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- function achievementability:ignorestormcoin(inst)
--     if self.ignorestorm ~= true and self.coinamount >=  ability_cost["ignorestorm"].cost then
--         self.ignorestorm = true
--         self:coinDoDelta(-ability_cost["ignorestorm"].cost)
--         self:ignorestormfn(inst)
--         self:ongetcoin(inst)
--     end
-- end

-- function achievementability:ignorestormfn(inst)
--     if self.ignorestorm then
--         self.ignorestorm = true
--     end
-- end

--waxwell
local function WaxwellDoEffects(pet)
    local x, y, z = pet.Transform:GetWorldPosition()
    SpawnPrefab("statue_transition_2").Transform:SetPosition(x, y, z)
end
local function WaxwellKillPet(pet)
    pet.components.health:Kill()
end
local function WaxwellOnSpawnPet(inst, pet)
    if pet:HasTag("shadowminion") then
        --Delayed in case we need to relocate for migration spawning
        pet:DoTaskInTime(0, WaxwellDoEffects)
        if not (inst.components.health:IsDead() or inst:HasTag("playerghost")) then
            inst.components.sanity:AddSanityPenalty(pet, TUNING.SHADOWWAXWELL_SANITY_PENALTY[string.upper(pet.prefab)])
            inst:ListenForEvent("onremove", inst._onpetlost, pet)
        elseif pet._killtask == nil then
            pet._killtask = pet:DoTaskInTime(math.random(), WaxwellKillPet)
        end
    elseif inst._OnSpawnPet ~= nil then
        inst:_OnSpawnPet(pet)
    end
end

local function WaxwellOnDespawnPet(inst, pet)
    if pet:HasTag("shadowminion") then
        WaxwellDoEffects(pet)
        pet:Remove()

    elseif inst._OnDespawnPet ~= nil then
        inst:_OnDespawnPet(pet)
    end
end

local function WaxwellOnDeath(inst)
    if inst.components.petleash:GetPets() then
        for k, v in pairs(inst.components.petleash:GetPets()) do
            if v:HasTag("shadowminion") and v._killtask == nil then
                v._killtask = v:DoTaskInTime(math.random(), WaxwellKillPet)
            end
        end
    end
end

local function WaxwellOnReroll(inst)
    local todespawn = {}
    for k, v in pairs(inst.components.petleash:GetPets()) do
        if v:HasTag("shadowminion") then
            table.insert(todespawn, v)
        end
    end
    for i, v in ipairs(todespawn) do
        inst.components.petleash:DespawnPet(v)
    end
end

function achievementability:waxwellfriendcoin(inst)
    if self.waxwellfriend ~= true and self.coinamount >= ability_cost["waxwellfriend"].cost  and inst.prefab ~= "waxwell" then
        self.waxwellfriend = true
        self:coinDoDelta(-ability_cost["waxwellfriend"].cost)
        local papyrus = SpawnPrefab("papyrus")
        papyrus.components.stackable:SetStackSize(2)
        inst.components.inventory:GiveItem(papyrus, nil, inst:GetPosition())
        local nightmarefuel = SpawnPrefab("nightmarefuel")
        nightmarefuel.components.stackable:SetStackSize(2)
        inst.components.inventory:GiveItem(nightmarefuel, nil, inst:GetPosition())
        self:ongetcoin(inst)
        self:waxwellfriendfn(inst)
    end
end

local function waxwell_common_postinit(inst)
    inst:AddTag("shadowmagic")
    inst:AddTag("dappereffects")
    inst:AddTag("achivshadowmagicbuilder") --制作老麦的影子   不需要做书  直接在魔法栏建造影子
    --reader (from reader component) added to pristine state for optimization
    inst:AddTag("reader")
end

local function waxwell_master_postinit(inst)
    inst:AddComponent("reader")
    if inst.components.petleash ~= nil then
        inst._OnSpawnPet = inst.components.petleash.onspawnfn
        inst._OnDespawnPet = inst.components.petleash.ondespawnfn
        inst.components.petleash:SetMaxPets(inst.components.petleash:GetMaxPets() + 4)
    else
        inst:AddComponent("petleash")
        inst.components.petleash:SetMaxPets(4)
    end
    inst.components.petleash:SetOnSpawnFn(WaxwellOnSpawnPet)
    inst.components.petleash:SetOnDespawnFn(WaxwellOnDespawnPet)

    inst.components.foodaffinity:AddPrefabAffinity("lobsterdinner", TUNING.AFFINITY_15_CALORIES_LARGE)
    inst._onpetlost = function(pet) inst.components.sanity:RemoveSanityPenalty(pet) end
    inst:ListenForEvent("death", WaxwellOnDeath)
    inst:ListenForEvent("ms_becameghost", WaxwellOnDeath)
    inst:ListenForEvent("ms_playerreroll", WaxwellOnReroll)
end


function achievementability:waxwellfriendfn(inst)
    if self.waxwellfriend == true  then
        waxwell_common_postinit(inst)
        waxwell_master_postinit(inst)
    else
        if inst.prefab ~= "waxwell" then
            inst:RemoveTag("shadowmagic")
        end
    end
end

function achievementability:waxwellfriendRemove()
    if self.waxwellfriend then
        local inst = self.inst 
        WaxwellOnDeath(inst)
        inst:RemoveComponent("reader")
        inst:RemoveComponent("petleash")
        inst:RemoveEventCallback("death", WaxwellOnDeath)
        inst:RemoveEventCallback("ms_becameghost", WaxwellOnDeath)
        inst:RemoveEventCallback("ms_playerreroll", WaxwellOnReroll)
        inst:RemoveTag("achivshadowmagicbuilder")
        inst.components.foodaffinity:RemovePrefabAffinity("lobsterdinner")
    end
end

--单独走路效果
function achievementability:flashycoin(inst)
	if self.flashy then
		if self.flashyswitch <  7 then
			self.flashyswitch = self.flashyswitch +1 
		else
			self.flashyswitch = 1
		end
		if self.flashyswitch ~=7 then
    		inst.components.talker:Say(STRINGS.ACHIEVEMENT_FANCY_EFFECT_START..self.flashyswitch)
		else
    		inst.components.talker:Say(STRINGS.ACHIEVEMENT_FANCY_EFFECT_END)
		end
	end
    if self.flashy ~= true and self.coinamount >= ability_cost["flashy"].cost   then
        self.flashy = true
        self:coinDoDelta(-ability_cost["flashy"].cost)
        self:ongetcoin(inst)
        self:flashyfn(inst)
    end
end

local function FxFloatedDownAI(inst)
    if inst.components.achievementability   and  not inst:HasTag("playerghost") and inst.components.locomotor then
    	local fx_num =  inst.components.achievementability.flashyswitch
    	if  inst.components.locomotor.wantstomoveforward  then
     		inst.components.achievementability.flashystill_delay = 6
     		if  fx_num ~= 7 then
     			local name = "slowregen"
     			if fx_num  ==  2 then
     				name = "attack"
     			elseif fx_num  ==  3 then
     				name = "fastregen"
     			elseif fx_num  ==  4 then
     				name = "shield"
     			elseif fx_num  ==  5 then
     				name = "speed"
     			elseif fx_num  == 6 then
     				name = "retaliation"
     			else
     				name = "slowregen"
     			end
     			local x,y,z = inst.Transform:GetWorldPosition()
        		SpawnPrefab("ghostlyelixir_"..name.."_dripfx").Transform:SetPosition(x, 0, z)
        	end
    	end
    end
end
local function FxFloatedDownAI_still(inst)
	if inst.components.achievementability   and  not inst:HasTag("playerghost") and inst.components.locomotor then
    	if not inst.components.locomotor.wantstomoveforward and inst.components.achievementability.flashyswitch ~= 7  then
    		if  inst.components.achievementability.flashystill_delay == 0 then
     			local x,y,z = inst.Transform:GetWorldPosition()
        		SpawnPrefab("crab_king_icefx").Transform:SetPosition(x, 0, z)
        	else
        		inst.components.achievementability.flashystill_delay = (inst.components.achievementability.flashystill_delay - 1 ) > 0  and  (inst.components.achievementability.flashystill_delay - 1 ) or 0
        	end
    	end
    end
end


function achievementability:flashyfn(inst)
    inst:DoTaskInTime(1, function()
		if self.flashy  and  inst.flashyfnset == nil  then
			inst.flashyfnset = inst:DoPeriodicTask(0.22,FxFloatedDownAI)
		else
			if self.flashy  and  inst.flashyfnset ~= nil  then
				inst.flashyfnset:Cancel()
				inst.flashyfnset = inst:DoPeriodicTask(0.22, FxFloatedDownAI)
			end
			if   self.flashy ~= true  and    inst.flashyfnset ~= nil then
				inst.flashyfnset:Cancel()
				inst.flashyfnset = nil
			end
		end
		--still
		if self.flashy  and  inst.flashyfnset_still == nil  then
			inst.flashyfnset_still = inst:DoPeriodicTask(0.65,FxFloatedDownAI_still)
		else
			if self.flashy  and  inst.flashyfnset_still ~= nil  then
				inst.flashyfnset_still:Cancel()
				inst.flashyfnset_still = inst:DoPeriodicTask(0.65, FxFloatedDownAI_still)
			end
			if   self.flashy ~= true  and inst.flashyfnset_still ~= nil then
				inst.flashyfnset_still:Cancel()
				inst.flashyfnset_still = nil
			end
        end
        if self.flashy then
            self:playHalofn(inst)
        end
	end)
end

function achievementability:ancientstationcoin(inst)
    if self.ancientstation ~= true and self.coinamount >= ability_cost["ancientstation"].cost then
        self.ancientstation = true
		--self.starsspent = self.starsspent + ability_cost["ancientstation"].cost
        self:coinDoDelta(-ability_cost["ancientstation"].cost)
        self:ancientstationfn(inst)
		local item = SpawnPrefab("nightmare_timepiece")
        inst.components.inventory:GiveItem(item, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

function achievementability:ancientstationfn(inst)
    if self.ancientstation then
		inst:AddTag("ancientstation")
    end
end

function achievementability:moonstonecoin(inst)
    if self.moonstone ~= true and self.coinamount >= ability_cost["moonstone"].cost then
        self.moonstone = true
        self:coinDoDelta(-ability_cost["moonstone"].cost)
        self:moonstonefn(inst)
		local item = SpawnPrefab("moonrocknugget")
        inst.components.inventory:GiveItem(item, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

function achievementability:moonstonefn(inst)
    if self.moonstone then
		inst:AddTag("moonstone")
    end
end

function achievementability:moonaltarcoin(inst)
    if self.moonaltar ~= true and self.coinamount >= ability_cost["moonaltar"].cost then
        self.moonaltar = true
        self:coinDoDelta(-ability_cost["moonaltar"].cost)
        self:moonaltarfn(inst)
		local item = SpawnPrefab("moonrocknugget")
        inst.components.inventory:GiveItem(item, nil, inst:GetPosition())
        self:ongetcoin(inst)
    end
end

function achievementability:moonaltarfn(inst)
    if self.moonaltar then
		inst:AddTag("moonaltar")
    end
end

function achievementability:playHalofn(inst)
    inst:DoTaskInTime(1, function()
        local fx_num =  inst.components.achievementability.flashyswitch
        if fx_num ~= 7 then
            inst:DoPeriodicTask(90*1/30, function()
                local fx_num =  inst.components.achievementability.flashyswitch
                if self.flashy and fx_num ~= 7 then
                    inst.holo = SpawnPrefab("halo" .. fx_num)
                    inst.holo.entity:SetParent(inst.entity)
                end
            end)
            inst.holo = SpawnPrefab("halo" .. fx_num)
            inst.holo.entity:SetParent(inst.entity)
        end
    end)
end

local function SpawnWoby(inst)
    local player_check_distance = 40
    local attempts = 0
    local max_attempts = 30
    local x, y, z = inst.Transform:GetWorldPosition()
    local woby = SpawnPrefab(TUNING.WALTER_STARTING_WOBY)
	inst.woby = woby
	woby:LinkToPlayer(inst)
    inst:ListenForEvent("onremove", inst._woby_onremove, woby)
    while true do
        local offset = FindWalkableOffset(inst:GetPosition(), math.random() * PI, player_check_distance + 1, 10)
        if offset then
            local spawn_x = x + offset.x
            local spawn_z = z + offset.z
            if attempts >= max_attempts then
                woby.Transform:SetPosition(spawn_x, y, spawn_z)
                break
            elseif not IsAnyPlayerInRange(spawn_x, 0, spawn_z, player_check_distance) then
                woby.Transform:SetPosition(spawn_x, y, spawn_z)
                break
            else
                attempts = attempts + 1
            end
        elseif attempts >= max_attempts then
            woby.Transform:SetPosition(x, y, z)
            break
        else
            attempts = attempts + 1    
        end
    end

    return woby
end

local function OnWobyTransformed(inst, woby)
	if inst.woby ~= nil then
		inst:RemoveEventCallback("onremove", inst._woby_onremove, inst.woby)
	end
	inst.woby = woby
	inst:ListenForEvent("onremove", inst._woby_onremove, woby)
end

local function OnWobyRemoved(inst)
	inst.woby = nil
	inst._replacewobytask = inst:DoTaskInTime(1, function(i) i._replacewobytask = nil if i.woby == nil then SpawnWoby(i) end end)
end

local function OnWalterRemoveEntity(inst)
	-- hack to remove pets when spawned due to session state reconstruction for autosave snapshots
    if inst.woby ~= nil --[[and inst.woby.spawntime == GetTime()]] then
        inst:RemoveEventCallback("onremove", inst._woby_onremove, inst.woby)
        inst.woby:Remove()
        inst.woby = nil
    end
end

local function StoryTellingDone(inst, story)
	if inst._story_proxy ~= nil and inst._story_proxy:IsValid() then
		inst._story_proxy:Remove()
		inst._story_proxy = nil
	end
end

local function StoryToTellFn(inst, story_prop)
	if not TheWorld.state.isnight then
		return "NOT_NIGHT"
	end

	local fueled = story_prop ~= nil and story_prop.components.fueled or nil
	if fueled ~= nil and story_prop:HasTag("campfire") then
		if fueled:IsEmpty() then
			return "NO_FIRE"
		end

		local campfire_stories = STRINGS.STORYTELLER.WALTER["CAMPFIRE"]
		if campfire_stories ~= nil then
			inst._story_proxy = SpawnPrefab("walter_campfire_story_proxy")
			inst._story_proxy:Setup(inst, story_prop)
			local story_id = GetRandomKey(campfire_stories)
			return { style = "CAMPFIRE", id = story_id, lines = campfire_stories[story_id].lines }
		end
	end
	return nil
end

-- walter common
local function warlter_common_postinit(inst)
    inst:AddTag("expertchef")
    inst:AddTag("pebblemaker")
    inst:AddTag("pinetreepioneer")
  --  inst:AddTag("allergictobees")
    inst:AddTag("slingshot_sharpshooter")
    inst:AddTag("efficient_sleeper")
    inst:AddTag("dogrider")
    inst:AddTag("nowormholesanityloss")
	inst:AddTag("storyteller") -- for storyteller component

    if TheNet:GetServerGameMode() == "lavaarena" then
        --do nothing
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    end
    inst._woby_spawntask = inst:DoTaskInTime(0, function(i) 
        i._woby_spawntask = nil 
        SpawnWoby(i)
     end)
    inst._woby_onremove = function(woby) OnWobyRemoved(inst) end
    inst.OnWobyTransformed = OnWobyTransformed
    inst:AddComponent("storyteller")
	inst.components.storyteller:SetStoryToTellFn(StoryToTellFn)
    inst.components.storyteller:SetOnStoryOverFn(StoryTellingDone)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnDespawn = OnDespawn
    inst:ListenForEvent("onremove", OnWalterRemoveEntity)
end

-- walter ability
function achievementability:fearlesscoin(inst)
    if self.fearless ~= true and self.coinamount >= ability_cost["fearless"].cost and inst.prefab ~= "walter"  then
        self.fearless = true
        self:coinDoDelta(-ability_cost["fearless"].cost)
        self:ongetcoin(inst)
        self:fearlessfn(inst)
        
        inst.components.inventory:GiveItem(SpawnPrefab("walterhat"), nil, inst:GetPosition())
        inst.components.inventory:GiveItem(SpawnPrefab("slingshot"), nil, inst:GetPosition())
        local slingshotammo_rock = SpawnPrefab("slingshotammo_rock")
        slingshotammo_rock.components.stackable:SetStackSize(10)
        inst.components.inventory:GiveItem(slingshotammo_rock, nil, inst:GetPosition())
    end
end

function achievementability:fearlessfn(inst)
    if self.fearless then
        warlter_common_postinit(inst)
    else
        if inst.prefab ~= "walter" then
            inst:RemoveTag("pebblemaker")
        end
    end
end

function achievementability:fearlessRemove()
    local inst = self.inst
    if self.fearless then
        inst.woby.components.container:DropEverything()
        OnWalterRemoveEntity(inst)
        inst:RemoveTag("expertchef")
        inst:RemoveTag("pebblemaker")
        inst:RemoveTag("pinetreepioneer")
       -- inst:RemoveTag("allergictobees")
        inst:RemoveTag("slingshot_sharpshooter")
        inst:RemoveTag("efficient_sleeper")
        inst:RemoveTag("dogrider")
        inst:RemoveTag("nowormholesanityloss")
        inst:RemoveTag("storyteller") -- for storyteller component

        if TheNet:GetServerGameMode() == "lavaarena" then
            --do nothing
        elseif TheNet:GetServerGameMode() == "quagmire" then
            inst:RemoveTag("quagmire_shopper")
        end
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip ~= nil and equip.prefab == "slingshot" then
            inst.components.inventory:DropItem(equip,true,true)
        end
        inst._woby_spawntask = nil
        inst._woby_onremove = nil
        inst.OnWobyTransformed = nil
        inst:RemoveComponent("storyteller")
    end
end


local function on_show_warp_marker(inst)
	inst.components.positionalwarp:EnableMarker(true)
end

local function on_hide_warp_marker(inst)
	inst.components.positionalwarp:EnableMarker(false)
end

-- local function DelayedWarpBackTalker(inst)
-- 	-- if the player starts moving right away then we can skip this
-- 	if inst.sg == nil or inst.sg:HasStateTag("idle") then 
-- 		inst.components.talker:Say(GetString(inst, "ANNOUNCE_POCKETWATCH_RECALL"))
-- 	end 
-- end

local function OnWarpBack(inst, data)
	if inst.components.positionalwarp ~= nil then
		if data ~= nil and data.reset_warp then
			inst.components.positionalwarp:Reset()
			--inst:DoTaskInTime(15 * FRAMES, DelayedWarpBackTalker) 
		else
			inst.components.positionalwarp:GetHistoryPosition(true)
		end
	end
end

function achievementability:timemanagercoin(inst)
    if self.timemanager ~= true and self.coinamount >= ability_cost["timemanager"].cost and inst.prefab ~= "wanda"  then
        self.timemanager = true
        self:coinDoDelta(-ability_cost["timemanager"].cost)
        self:ongetcoin(inst)
        self:timemanagerfn(inst)
    end
end

local function CustomCombatDamage(inst, target, weapon, multiplier, mount)
    --return inst.components.combat.customdamagemultfn(inst, target, weapon, multiplier, mount) * 1.2 * (1 - inst.components.health.GetPercent() * 0.375 )
    return (inst.components.combat.old_customdamagemultfn and inst.components.combat.old_customdamagemultfn(inst, target, weapon, multiplier, mount) or 1) * 0.8333
end

function achievementability:timemanagerfn(inst)
    if  self.timemanager then
        inst:AddTag("clockmaker")
        inst:AddTag("pocketwatchcaster")
        inst:AddComponent("positionalwarp")
        inst.components.positionalwarp:SetWarpBackDist(8)
        inst:DoTaskInTime(0, function() inst.components.positionalwarp:SetMarker("pocketwatch_warp_marker") end)
        inst:ListenForEvent("show_warp_marker", on_show_warp_marker)
        inst:ListenForEvent("hide_warp_marker", on_hide_warp_marker)
        inst:ListenForEvent("onwarpback", OnWarpBack)
        inst.components.combat.old_customdamagemultfn = inst.components.combat.customdamagemultfn
        inst:ListenForEvent("equip", function(inst, data)
            if inst.components.inventory then
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if data.eslot == EQUIPSLOTS.HANDS then
                    if equip ~= nil and equip.prefab == "pocketwatch_weapon" then
                        inst.components.combat.customdamagemultfn = CustomCombatDamage
                    else
                        inst.components.combat.customdamagemultfn = inst.components.combat.old_customdamagemultfn
                    end
                end
            end
        end)
        local CAST_POCKETWATCH = ACTIONS.CAST_POCKETWATCH
        local old_cast_pocketwatch_fn = CAST_POCKETWATCH.fn
        CAST_POCKETWATCH.fn = function(act, ...)
            if act and act.invobject.prefab == "pocketwatch_heal"  and  act.doer.prefab ~= "wanda" then 
                return false
            else
                local result = old_cast_pocketwatch_fn(act)
                return result
            end
        end
    else
        if inst.prefab ~= "wanda" then
            inst:RemoveTag("clockmaker")
        end
    end
end

function achievementability:timemanagerRemove()
    local inst = self.inst
    if self.timemanager then
        inst:RemoveTag("clockmaker")
        inst:RemoveTag("pocketwatchcaster")
        inst:RemoveEventCallback("show_warp_marker", on_show_warp_marker)
        inst:RemoveEventCallback("hide_warp_marker", on_hide_warp_marker)
        inst:RemoveEventCallback("onwarpback", OnWarpBack)
        inst:RemoveComponent("positionalwarp")
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip ~= nil and equip.prefab == "pocketwatch_weapon" then
            inst.components.inventory:DropItem(equip,true,true)
        end
        inst.components.combat.customdamagemultfn =  inst.components.combat.old_customdamagemultfn
    end
end

function achievementability:costKillAmountFinishAchievement(inst,id)
    local v = achievement_config.idconfig[id]
    if v.point and inst.components.achievementmanager["check" .. v.id] ~= 1 and self.killamount >= cost_kill_amount then
        inst.components.achievementmanager["check" .. v.id] = 1
        if type(v.need_amount) == "table" then
            inst.components.achievementmanager["current" .. v.id .. "amount"] = v.need_amount[1]
        else
            inst.components.achievementmanager["current" .. v.id .. "amount"] = v.need_amount
        end
        inst.components.achievementability.coinamount = inst.components.achievementability.coinamount + v.point
        inst.components.achievementability:killDoDelta(-cost_kill_amount)
    end
end

function achievementability:resetFunc()
    self.inst.OnSave = self.inst.OldOnSave
    self.inst.OnLoad = self.inst.OldOnLoad
    self.inst.OnDespawn = self.inst.OldOnDespawn
end

--重置奖励
function achievementability:removecoin(inst)
    local returncoin = 0
    for _,v in pairs(achievement_ability_config.ability_cost) do
        if type(self[v.ability]) == "number" then
            returncoin = returncoin + self[v.ability] * v.cost
        elseif self[v.ability] == true then
            returncoin = returncoin + v.cost
        end
        self[v.ability] = v.default_value
    end
    self.absorbup = 0
    self.damageup = 0
    self.speedup = 0
    self.crit = 0
    self.coinamount = self.coinamount + math.ceil(returncoin * TUNING.RETRUN_POINT)
    self:flashyfn(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = nil
    end
    if inst.components.health.currenthealth > 0 and not inst.components.rider:IsRiding() then
        inst.components.locomotor:Stop()
        inst.sg:GoToState("changeoutsidewardrobe")
    end
    SpawnPrefab("shadow_despawn").Transform:SetPosition(inst.Transform:GetWorldPosition())
    SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

--重置属性
function achievementability:resetbuff(inst)
    if self.firmarmor == 1  and inst.components.inventory then  
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        if item ~= nil and item.prefab == "armorruins" then
            local health_percent = inst.components.health:GetPercent()
            inst.components.health:SetMaxHealth(inst.components.health.maxhealth - 100)
            inst.components.health:SetPercent(health_percent)
            self.healthmax = inst.components.health.maxhealth
        end
    end

    inst.components.locomotor.externalspeedmultiplier = inst.components.locomotor.externalspeedmultiplier - ability_ratio["speedup"]*self.speedup
    self.speedcheck = inst.components.locomotor.externalspeedmultiplier
    
    inst.components.health.absorb = inst.components.health.absorb - ability_ratio["absorbup"]*self.absorbup
    self.absorb = inst.components.health.absorb
    
    inst.components.combat.damagemultiplier = inst.components.combat.damagemultiplier - ability_ratio["damageup"]*self.damageup
    self.damagemul = inst.components.combat.damagemultiplier
    if self.fireflylight then inst._fireflylight:Remove() end

    if  inst.mod_fireflylightspawnprefab ~= nil  then
        inst.mod_fireflylightspawnprefab:Cancel()
        inst.mod_fireflylightspawnprefab = nil 
    end

    inst:RemoveTag("achiveking")
    inst:RemoveTag("fastpicker")
    inst:RemoveTag("fastharvester")--快速收获
    if inst.icebodytemperature ~= nil  then
        inst.icebodytemperature:Cancel()
        inst.icebodytemperature = nil
    end
    inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
    inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP

    if inst.prefab ~= "wurt" then
        inst:RemoveTag("merm_builder")  --修建tag
        inst:RemoveTag("stronggrip")  --武器不脱
        inst:RemoveTag("mermfluent")
        inst:RemoveTag("merm")
        inst:RemoveTag("mermguard")
        inst.components.locomotor:SetFasterOnGroundTile(GROUND.MARSH, false)
        inst.components.locomotor:SetFasterOnGroundTile(GROUND.CARPET, false)
    else
        inst:AddTag("aspiring_bookworm")
    end
    
    if inst.components.eater ~= nil then
        if inst.prefab ~= "wx78" then
            inst.components.eater.ignoresspoilage = false  --无视新鲜 
        end
        if inst.prefab ~= "webber" then
            inst.components.eater.strongstomach = false  --吃怪物肉 
        end
    end
    if inst.components.hunger ~= nil then
        inst.components.hunger.burnratemodifiers:RemoveModifier(inst)
    end

    --制作灯泡
    inst:RemoveTag("achive_science")

    --暗影不攻击
    inst:RemoveTag("achiv_shadow")
    inst:RemoveTag("shadowlure")

    --移除植物人的能力
    if inst.prefab ~= "wormwood" then
        inst:RemoveTag("plantkin")
        inst:RemoveTag("healonfertilize")
        inst.planttask = nil
    end
    inst:RemoveTag("achiveplantkin")

    --移除厨师的能力
    if inst.prefab ~= "warly" then
        inst:RemoveTag("masterchef")
        inst:RemoveTag("professionalchef")
    end
    if inst._aifx2 ~= nil then
        inst._aifx2:kill_fx()               
        inst._aifx2 = nil
    end

    if inst.prefab ~= "warly" and  inst.prefab ~= "willow" then
        inst:RemoveTag("expertchef")
    end

    --移除火女的能力
    if inst.prefab ~= "willow" then
        inst:RemoveTag("pyromaniac")
        inst:RemoveTag("bernieowner")
        inst:RemoveTag("heatresistant")
        inst.components.health.fire_damage_scale = 1
        inst.components.sanity.custom_rate_fn = nil
        inst.components.temperature.inherentsummerinsulation = 0
        inst.components.temperature:SetOverheatHurtRate(TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME)
    end
    if inst.components.debuffable then
        inst.components.debuffable:RemoveDebuff("buff_electricattack")
    end

    --移除制作头盔
    if inst.prefab ~= "wathgrithr" then
        inst:RemoveTag("valkyrie")
    end
    inst:RemoveTag("allachivpotion")

    --移除玩家的灵魂
    if inst.prefab ~= "wortox" then
        for k,v in pairs(inst.components.inventory.itemslots) do
            if v and v.prefab == "wortox_soul"  then
                v:Remove()
            end
        end
    end

    if inst.prefab ~= "winona" then
        inst:RemoveTag("fastbuilder")
        inst:RemoveTag("achivehandyperson")
    end
    if inst.prefab ~= "woodie" then
        inst:RemoveTag("werehuman")
    end

    inst:RemoveTag("ancientstation")
    inst:RemoveTag("moonstone")
    if inst.prefab ~= "wickerbottom" and inst.prefab ~= "waxwell" and inst.prefab ~= "wurt"  then
        inst:RemoveComponent("reader")
    end
    inst:RemoveTag("achivbookbuilder")

    inst.components.moisture.maxMoistureRate = .75
    self.maxMoistureRate = inst.components.moisture.maxMoistureRate

    inst.components.builder.ingredientmod = 1

    -- walter ability remove
    if inst.prefab ~= "walter" then
        self:fearlessRemove(inst)
    end
    -- wendy ability remove
    if inst.prefab ~= "wendy" then
        self:ghostly_friendRemove()
    end
    if inst.prefab ~= "waxwell" then
        self:waxwellfriendRemove()
    end

    if inst.prefab ~= "wanda" then
        self:timemanagerRemove()
    end

    if inst.Oldpreferseating and inst.Oldcaneat and inst.components.eater then
        inst.components.eater:SetDiet(inst.Oldcaneat, inst.Oldpreferseating)
    end

    if inst.prefab == "warly" then
        if  inst.components.eater ~= nil then
            inst.components.eater:SetPrefersEatingTag("preparedfood")
            inst.components.eater:SetPrefersEatingTag("pre-preparedfood")
        end
        inst:AddComponent("foodmemory")
    end
end

local function SaveForReroll(inst)
    inst.components.achievementability:resetbuff(inst)
    inst.components.achievementability:removecoin(inst)
    local data = inst.OldSaveForReroll and inst:OldSaveForReroll()
    if not data then  data = {} end
    data.achievementability = inst.components.achievementability ~= nil and inst.components.achievementability:OnSave() or nil
    data.achievementmanager = inst.components.achievementmanager ~= nil and inst.components.achievementmanager:OnSave() or nil
    return next(data) ~= nil and data or nil
end

local function LoadForReroll(inst, data)
    if inst.OldLoadForReroll then 
        inst:OldLoadForReroll(data)
    end
    if data.achievementability ~= nil and inst.components.achievementability ~= nil then
        inst.components.achievementability:OnLoad(data.achievementability)
    end
    if data.achievementmanager ~= nil and inst.components.achievementmanager ~= nil then
        inst.components.achievementmanager:OnLoad(data.achievementmanager)
    end
end

function achievementability:Init(inst)
    inst.OldOnSave = inst.OnSave
    inst.OldOnLoad = inst.OnLoad
    inst.OldOnDespawn = inst.OnDespawn
    inst.OldSaveForReroll = inst.SaveForReroll
    inst.OldLoadForReroll = inst.LoadForReroll
    inst.SaveForReroll = SaveForReroll
    inst.LoadForReroll = LoadForReroll
    if inst.components.eater then
        inst.Oldcaneat = inst.components.eater.caneat
        inst.Oldpreferseating = inst.components.eater.preferseating
        inst.Oldpreferseatingtags = inst.components.eater.preferseatingtags
    end
    self:_calc_kill_value(inst)
    inst:DoPeriodicTask(0.1, function() self:onupdate() end)
end

function achievementability:OnInitSpecialAbility()
    if self.inst.prefab ~= "walter" and not self.fearless then
        self.inst:RemoveTag("pebblemaker")
    end
    if self.inst.prefab ~= "wendy" and not self.ghostly_friend then
        self.inst:RemoveTag("ghostlyfriend") 
        self.inst:RemoveTag("elixirbrewer")
    end

    if self.inst.prefab ~= "wanda" and not self.timemanager then
        self.inst:RemoveTag("clockmaker")
    end
    self:jumpfn(self.inst)
end


function achievementability:OnLoadedPost()
    local inst = self.inst
    for _,v in pairs(achievement_ability_config.id2ability) do
        if (type(v.default_value) == "number" and self[v.ability] > 0)
         or(type(v.default_value) == "boolean" and self[v.ability]) then
            local func = v.ability .. "fn"
            if self[func] then
                self[func](self,inst)
            end
        end
    end
end

return achievementability