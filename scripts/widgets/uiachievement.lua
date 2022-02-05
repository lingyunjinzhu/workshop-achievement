local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local AnimButton = require "widgets/animbutton"
local HoverText = require "widgets/hoverer"
local achievement_config = require("Achievement.achievement_config")
local achievement_ability_config = require("Achievement.achievement_ability_config")
local id2ability = achievement_ability_config.id2ability

local modname = KnownModIndex:GetModActualName("New Achivement")
local killAmountFinishAchievement = GetModConfigData("killamount_can_finish_achievement",modname)
local uiachievement = Class(Widget, function(self, owner)
	Widget._ctor(self, "uiachievement")
	self.owner = owner
	self.mainui = self:AddChild(Widget("mainui"))
	self.mainui:SetScale(1.06, 1.06, 1)
	self.mainui.bg = self.mainui:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
	self.mainui.bg:SetPosition(0, 20, 0)
	self.mainui.bg:MoveToFront()
	self.mainui.bg:ScaleToSize(1253, 783)
	self.mainui.bg:Hide()

	self.mainui.bg.allachiv = self.mainui.bg:AddChild(Widget("allachiv"))
	self.mainui.bg.allachiv:SetPosition(0, 0, 0)
	self.mainui.bg.allachiv:Hide()

	self.mainui.bg.allcoin = self.mainui.bg:AddChild(Widget("allcoin"))
	self.mainui.bg.allcoin:SetPosition(0, 0, 0)
	self.mainui.bg.allcoin:Hide()

	--图鉴
	self.mainui.bg.allchart = self.mainui.bg:AddChild(Widget("allchart"))
	self.mainui.bg.allchart:SetPosition(0, 0, 0)
	self.mainui.bg.allchart:Hide()
	--3个分类
	self.mainui.bg.title_1 = self.mainui.bg:AddChild(ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex"))
	self.mainui.bg.title_1:SetPosition(-365, 420, 0)
	self.mainui.bg.title_1:SetNormalScale(1,1,1)
	self.mainui.bg.title_1:SetFocusScale(1,1,1)
	--成就bt
	self.mainui.bg.title_1:SetOnClick(function()
		self.mainui.bg.title_1:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex")
		self.mainui.bg.title_2:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
		self.mainui.bg.title_3:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
		--------------------------------
		if not self.mainui.bg.allachiv.shown then
			self.mainui.bg.allachiv:Show()
			self.mainui.bg:Show()
			self.mainui.infobutton:Show()
			self.mainui.itemclassification:Show()
			self.mainui.bg.allcoin:Hide()
			self.mainui.bg.allchart:Hide()

			self.mainui.infobutton.last:Show()
			self.mainui.infobutton.next:Show()

			self.mainui.infobutton.last2:Hide()
			self.mainui.infobutton.next2:Hide()
			self.mainui.infobutton.last3:Hide()
			self.mainui.infobutton.next3:Hide()
			self.mainui.infobutton.info:Hide()
			self.mainui.infobutton.desc:Hide()
		end
		self.maxnumpage = math.ceil(#self.listitem/14)
		if self.numpage == 1 then
			self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		else
			self.mainui.infobutton.last:SetTextures("images/button/last_act.xml", "last_act.tex")
		end
		if self.numpage >= self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end

	end)
	self.mainui.bg.title_1.lable = self.mainui.bg.title_1:AddChild(Text(NEWFONT_OUTLINE, 50, STRINGS.ALLACHIVUISTRING[1]))
	self.mainui.bg.title_1.lable:SetPosition(0, -5, 0)

	self.mainui.bg.title_2 = self.mainui.bg:AddChild(ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex"))
	self.mainui.bg.title_2:SetPosition(0, 420, 0)
	self.mainui.bg.title_2:SetNormalScale(1,1,1)
	self.mainui.bg.title_2:SetFocusScale(1,1,1)
	--能力BT
	self.mainui.bg.title_2:SetOnClick(function()

		self.mainui.bg.title_1:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
		self.mainui.bg.title_2:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex")
		self.mainui.bg.title_3:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")

		if not self.mainui.bg.allcoin.shown then
			if  TUNING.CHECKCOIN then
				self.mainui.bg.allcoin:Hide()
			else
				self.mainui.bg.allcoin:Show()
			end
			self.mainui.bg:Show()
			self.mainui.infobutton:Show()
				
			self.mainui.itemclassification:Hide()
				
			self.mainui.bg.allachiv:Hide()
			self.mainui.bg.allchart:Hide()
			self.mainui.infobutton.last:Hide()
			self.mainui.infobutton.next:Hide()
			self.mainui.infobutton.last3:Hide()
			self.mainui.infobutton.next3:Hide()
			self.mainui.infobutton.last2:Show()
			self.mainui.infobutton.next2:Show()
			self.mainui.infobutton.info:Hide()
			self.mainui.infobutton.desc:Hide()
		end
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")

		self.maxnumpage2 = math.ceil(#self.coinlist/28)
		if self.numpage2 == 1 then
			self.mainui.infobutton.last2:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		else
			self.mainui.infobutton.last2:SetTextures("images/button/last_act.xml", "last_act.tex")
		end
		if self.numpage2 >= self.maxnumpage2 then
			self.mainui.infobutton.next2:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next2:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		
	end)

	self.mainui.bg.title_2.lable = self.mainui.bg.title_2:AddChild(Text(NEWFONT_OUTLINE, 50, STRINGS.ALLACHIVUISTRING[2]))
	self.mainui.bg.title_2.lable:SetPosition(0, -5, 0)

	self.mainui.bg.title_3 = self.mainui.bg:AddChild(ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex"))
	self.mainui.bg.title_3:SetPosition(365, 420, 0)
	self.mainui.bg.title_3:SetNormalScale(1,1,1)
	self.mainui.bg.title_3:SetFocusScale(1,1,1)
	--图鉴BT
	self.mainui.bg.title_3:SetOnClick(function()
		self.mainui.bg.title_1:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
		self.mainui.bg.title_2:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
		self.mainui.bg.title_3:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex")

		if not self.mainui.bg.allchart.shown then
			self.mainui.bg.allchart:Show()
			self.mainui.bg:Show()
			self.mainui.infobutton:Show()
				
			self.mainui.itemclassification:Hide()
			self.mainui.bg.allcoin:Hide()
			self.mainui.bg.allachiv:Hide()
			self.mainui.infobutton.last:Hide()
			self.mainui.infobutton.next:Hide()
			self.mainui.infobutton.last2:Hide()
			self.mainui.infobutton.next2:Hide()

			self.mainui.infobutton.last3:Show()
			self.mainui.infobutton.next3:Show()
			self.mainui.infobutton.info:Hide()
			self.mainui.infobutton.desc:Hide()
		end


	end)
	self.mainui.bg.title_3.lable = self.mainui.bg.title_3:AddChild(Text(NEWFONT_OUTLINE, 50, STRINGS.ALLACHIVUISTRING[3]))
	self.mainui.bg.title_3.lable:SetPosition(0, -5, 0)

	--线
	self.mainui.bg.line = self.mainui.bg:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line_long.tex"))
	self.mainui.bg.line:SetPosition(0, 325, 0)

	--成就点 显示
	self.mainui.bg.coinamount = self.mainui.bg:AddChild(Text(NEWFONT_OUTLINE, 45,string.format(STRINGS.ACHIEVEMENT_POINT_AMOUNT, self.owner.currentcoinamount:value())))
	self.mainui.bg.coinamount:SetPosition(-180, 350, 0)
	--杀戮值
	self.mainui.bg.killamount = self.mainui.bg:AddChild(Text(NEWFONT_OUTLINE, 45, string.format(STRINGS.ACHIEVEMENT_KILL_AMOUNT, self.owner.currentkillamount:value())))
	self.mainui.bg.killamount:SetPosition(180, 350, 0)

	self.mainbutton = self:AddChild(Widget("mainbutton"))
	self.mainbutton:SetPosition(-850, 460, 0)
	self.mainbutton:SetScale(1,1,1)

	self.mainbutton.checkbuttonglow = self.mainbutton:AddChild(Image("images/button/checkbuttonglow.xml", "checkbuttonglow.tex"))
    self.mainbutton.checkbuttonglow:SetClickable(false)
    self.mainbutton.checkbuttonglow:Hide()

--多少任务
    self.mainbutton.checkbutton = self.mainbutton:AddChild(ImageButton("images/button/checkbutton.xml", "checkbutton.tex"))
    self.mainbutton.checkbutton:MoveToFront()
    self.mainbutton.checkbutton:SetHoverText(STRINGS.ACHIEVEMENT_VIEW)

	self.mainbutton.checkbutton:SetOnGainFocus(function() self.mainbutton.checkbuttonglow:Show() end)
	self.mainbutton.checkbutton:SetOnLoseFocus(function() self.mainbutton.checkbuttonglow:Hide() end)
	self.cooldown = true
	self.mainbutton.checkbutton:SetOnClick(function()
		if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
			if self.cooldown then
				local allnumber = #self.achivlist - 1
				if  not TheInput:IsKeyDown(KEY_CTRL) then
					TheNet:Say(STRINGS.LMB ..string.format(STRINGS.ACHIEVEMENT_PROCESS,self.achivlist[#self.achivlist].current,allnumber), false)
				else
					if  TheInput:IsKeyDown(KEY_CTRL) then
						TheNet:Say(STRINGS.LMB .. string.format(STRINGS.ACHIEVEMENT_PROCESS ,self.achivlist[#self.achivlist].current,allnumber), true)
					end
				end
				self.cooldown = false
				self.owner:DoTaskInTime(3, function() self.cooldown = true end)
			end
		else
			if self.mainui.bg.allachiv.shown then
				self.mainui.bg.allachiv:Hide()
				self.mainui.bg:Hide()
				self.mainui.infobutton:Hide()
				self.mainui.itemclassification:Hide()
				--self.mainbutton.configact:Hide()
				self.mainbutton.configbg:Hide()
				self.mainbutton.configbigger:Hide()
				self.mainbutton.configsmaller:Hide()
				self.mainbutton.configremove:Hide()
				self.mainbutton.removeinfo:Hide()
				self.mainbutton.removeyes:Hide()
				self.mainbutton.removeno:Hide()
			else
				self.mainui.bg.allachiv:Show()
				self.mainui.bg:Show()
				self.mainui.infobutton:Show()
				self.mainui.itemclassification:Show()
				self.mainui.bg.allcoin:Hide()
				self.mainui.infobutton.last:Show()
				self.mainui.infobutton.next:Show()
				self.mainui.infobutton.last2:Hide()
				self.mainui.infobutton.next2:Hide()
				self.mainui.infobutton.last3:Hide()
				self.mainui.infobutton.next3:Hide()

				self.mainui.bg.title_1:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex")
				self.mainui.bg.title_2:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
				self.mainui.bg.title_3:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")

				if TUNING.CHECKCOIN then
					--self.mainbutton.configact:Hide()
				else
					if self.mainbutton.configact.shown then
						self.mainbutton.configact:Show()
					else
						self.mainbutton.configact:SetTextures("images/button/config_dact.xml", "config_dact.tex")
						self.mainbutton.configact:Show()
					end
				end

			end
			self.maxnumpage = math.ceil(#self.listitem/14)
			if self.numpage == 1 then
				self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
			else
				self.mainui.infobutton.last:SetTextures("images/button/last_act.xml", "last_act.tex")
			end
			if self.numpage >= self.maxnumpage then
				self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
			else
				self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
			end
	    end
	end)

	self.mainbutton.coinbuttonglow = self.mainbutton:AddChild(Image("images/button/coinbuttonglow.xml", "coinbuttonglow.tex"))
    self.mainbutton.coinbuttonglow:SetClickable(false)
    self.mainbutton.coinbuttonglow:Hide()
    self.mainbutton.coinbuttonglow:SetPosition(55, -2, 0)
    self.mainbutton.coinbuttonglow:SetScale(1,1,1)
--多少 点
    self.mainbutton.coinbutton = self.mainbutton:AddChild(ImageButton("images/button/coinbutton.xml", "coinbutton.tex"))
    self.mainbutton.coinbutton:MoveToFront()
    self.mainbutton.coinbutton:SetPosition(55, -2, 0)
    self.mainbutton.coinbutton:SetScale(1,1,1)
    self.mainbutton.coinbutton:SetHoverText(STRINGS.ACHIEVEMENT_EXCHANGE_ABILITY)

	self.mainbutton.coinbutton:SetOnGainFocus(function() self.mainbutton.coinbuttonglow:Show() end)
	self.mainbutton.coinbutton:SetOnLoseFocus(function() self.mainbutton.coinbuttonglow:Hide() end)

	if TUNING.CHECKCOIN then
		self.mainbutton.coinbutton:Hide()
	end
	self.mainbutton.coinbutton:SetOnClick(function()
		if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
			if self.cooldown then
				local emoji_link = " "
				local announce = 1
				if self.owner.currentcoinamount:value() < 20 then
					if TheInventory:CheckOwnership("emoji_lightbulb") then emoji_link = ":lightbulb:" end
					announce = 1
				elseif self.owner.currentcoinamount:value() >= 20 and  self.owner.currentcoinamount:value() <= 50 then
					if TheInventory:CheckOwnership("emoji_thumbsup") then emoji_link = ":thumbsup:" end
					announce = 2
				elseif self.owner.currentcoinamount:value() > 50 and  self.owner.currentcoinamount:value() < 90 then
					announce = 3
					if TheInventory:CheckOwnership("emoji_flex") then emoji_link = ":flex:" end
				else 
					announce = 4
					if TheInventory:CheckOwnership("emoji_fire") then emoji_link = ":fire:" end
				end
				TheNet:Say(STRINGS.LMB .. string.format(STRINGS.ACHIEVEMENT_ANNOUNCE_POINT[announce], self.owner.currentcoinamount:value())..emoji_link .. string.format(STRINGS.ACHIEVEMENT_KILL_AMOUNT, self.owner.currentkillamount:value()), false)
				self.cooldown = false
				self.owner:DoTaskInTime(3, function() self.cooldown = true end)
			end
		else
			if self.mainui.bg.allcoin.shown then
				self.mainui.bg.allcoin:Hide()
				self.mainui.bg:Hide()
				self.mainui.infobutton:Hide()
				self.mainui.itemclassification:Hide()
				--self.mainbutton.configact:Hide()

				self.mainbutton.configbg:Hide()
				self.mainbutton.configbigger:Hide()
				self.mainbutton.configsmaller:Hide()
				self.mainbutton.configremove:Hide()
				self.mainbutton.removeinfo:Hide()
				self.mainbutton.removeyes:Hide()
				self.mainbutton.removeno:Hide()
			else
				self.mainui.bg.allcoin:Show()
				self.mainui.bg:Show()
				self.mainui.infobutton:Show()
				
				self.mainui.itemclassification:Hide()
				
				self.mainui.bg.allachiv:Hide()
				self.mainui.infobutton.last:Hide()
				self.mainui.infobutton.next:Hide()

				self.mainui.infobutton.last2:Show()
				self.mainui.infobutton.next2:Show()

				self.mainui.infobutton.last3:Hide()
				self.mainui.infobutton.next3:Hide()

				self.mainui.bg.title_2:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex")
				self.mainui.bg.title_1:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
				self.mainui.bg.title_3:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
				

				if TUNING.CHECKCOIN then
					--self.mainbutton.configact:Hide()
				else
					if self.mainbutton.configact.shown  then
						self.mainbutton.configact:Show()
					else
						self.mainbutton.configact:SetTextures("images/button/config_dact.xml", "config_dact.tex")
						self.mainbutton.configact:Show()
					end
				end
			end
			self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")

			self.maxnumpage2 = math.ceil(#self.coinlist/28)
			if self.numpage2 == 1 then
				self.mainui.infobutton.last2:SetTextures("images/button/last_dact.xml", "last_dact.tex")
			else
				self.mainui.infobutton.last2:SetTextures("images/button/last_act.xml", "last_act.tex")
			end

			if self.numpage2 >= self.maxnumpage2 then
				self.mainui.infobutton.next2:SetTextures("images/button/next_dact.xml", "next_dact.tex")
			else
				self.mainui.infobutton.next2:SetTextures("images/button/next_act.xml", "next_act.tex")
			end
		end
	end)

	self.mainbutton.configbg = self.mainbutton:AddChild(Image("images/button/config_bg.xml", "config_bg.tex"))
	self.mainbutton.configbg:SetPosition(193, -5, 0)
	self.mainbutton.configbg:SetClickable(false)
	self.mainbutton.configbg:Hide()


	self.mainbutton.configact = self.mainbutton:AddChild(ImageButton("images/button/config_dact.xml", "config_dact.tex"))
	self.mainbutton.configact:SetPosition(115, -5, 0)
	self.mainbutton.configact:SetNormalScale(1,1,1)
	self.mainbutton.configact:SetFocusScale(1.1,1.1,1)
	self.mainbutton.configact:SetHoverText(STRINGS.ACHIEVEMENT_OPTION)

	if TUNING.CHECKCOIN then
		--self.mainbutton.configact:Hide()
	end

	--self.mainbutton.configact:Hide()

	self.mainbutton.configact:SetOnClick(function()
		if self.mainbutton.configbg.shown then
			self.mainbutton.configact:SetTextures("images/button/config_dact.xml", "config_dact.tex")
			self.mainbutton.configbg:Hide()
			self.mainbutton.configbigger:Hide()
			self.mainbutton.configsmaller:Hide()
			self.mainbutton.configremove:Hide()
		else
			self.mainbutton.configact:SetTextures("images/button/config_act.xml", "config_act.tex")
			self.mainbutton.configbg:Show()
			self.mainbutton.configbigger:Show()
			self.mainbutton.configsmaller:Show()
			self.mainbutton.configremove:Show()
		end
		self.mainbutton.removeinfo:Hide()
		self.mainbutton.removeyes:Hide()
		self.mainbutton.removeno:Hide()
	end)

	self.size = 1.06
	self.mainbutton.configbigger = self.mainbutton:AddChild(ImageButton("images/button/config_bigger.xml", "config_bigger.tex"))
	self.mainbutton.configbigger:SetPosition(167, -5, 0)
	self.mainbutton.configbigger:Hide()
	self.mainbutton.configbigger:SetNormalScale(1,1,1)
	self.mainbutton.configbigger:SetFocusScale(1.1,1.1,1)
	self.mainbutton.configbigger:SetHoverText(STRINGS.ACHIEVEMENT_ENLARGE)
	self.mainbutton.configbigger:SetOnClick(function()
		if not self.mainui.bg.allachiv.shown and not self.mainui.bg.allcoin.shown then
			self.mainui.bg.allachiv:Show()
			self.mainui.bg:Show()
			self.mainui.infobutton:Show()
		end
		self.size = self.size + .02
		self.mainui:SetScale(self.size, self.size, 1)
	end)

	self.mainbutton.configsmaller = self.mainbutton:AddChild(ImageButton("images/button/config_smaller.xml", "config_smaller.tex"))
	self.mainbutton.configsmaller:SetPosition(219, -5, 0)
	self.mainbutton.configsmaller:Hide()
	self.mainbutton.configsmaller:SetNormalScale(1,1,1)
	self.mainbutton.configsmaller:SetFocusScale(1.1,1.1,1)
	self.mainbutton.configsmaller:SetHoverText(STRINGS.ACHIEVEMENT_SHRINK)
	self.mainbutton.configsmaller:SetOnClick(function()
		if not self.mainui.bg.allachiv.shown and not self.mainui.bg.allcoin.shown then
			self.mainui.bg.allachiv:Show()
			self.mainui.bg:Show()
			self.mainui.infobutton:Show()
		end
		if self.size > .02 then
			self.size = self.size - .02
		end
		self.mainui:SetScale(self.size, self.size, 1)
	end)
	self.mainbutton.removeinfo = self.mainbutton:AddChild(Image("images/button/remove_info_cn.xml", "remove_info_cn.tex"))
	self.mainbutton.removeinfo:SetPosition(230, -180, 0)
	self.mainbutton.removeinfo:SetScale(.95,.95,1)
	
	self.mainbutton.removeinfo.title = self.mainbutton.removeinfo:AddChild(Text(NEWFONT_OUTLINE, 45, STRINGS.ALLACHIEVE_RESET_CONFIRM))
	self.mainbutton.removeinfo.title:SetPosition(-90, 110, 0)
	self.mainbutton.removeinfo.title:SetColour(1, 0, 0, 1)

	self.mainbutton.removeinfo.lable = self.mainbutton.removeinfo:AddChild(Text(NEWFONT_OUTLINE, 30, string.format(STRINGS.ALLACHIEVE_RESET,TUNING.RETRUN_POINT * 100)))
	self.mainbutton.removeinfo.lable:SetPosition(-80, 80, 0)
	self.mainbutton.removeinfo.lable:SetRegionSize(300,80)
	self.mainbutton.removeinfo:Hide()
	self.mainbutton.configremove = self.mainbutton:AddChild(ImageButton("images/button/config_remove.xml", "config_remove.tex"))
	self.mainbutton.configremove:SetPosition(271, -5, 0)
	self.mainbutton.configremove:Hide()
	self.mainbutton.configremove:SetNormalScale(1,1,1)
	self.mainbutton.configremove:SetFocusScale(1.1,1.1,1)
	self.mainbutton.configremove:SetHoverText(STRINGS.ACHIEVEMENT_RESET)
	self.mainbutton.configremove:SetOnClick(function()
		self.mainbutton.removeinfo:Show()
		self.mainbutton.removeyes:Show()
		self.mainbutton.removeno:Show()
	end)

	self.mainbutton.removeyes = self.mainbutton:AddChild(ImageButton("images/button/remove_yes.xml", "remove_yes.tex"))
	self.mainbutton.removeyes:SetPosition(17, -77, 0)
	self.mainbutton.removeyes:Hide()
	self.mainbutton.removeyes:SetNormalScale(1,1,1)
	self.mainbutton.removeyes:SetFocusScale(1.1,1.1,1)
	self.mainbutton.removeyes:SetOnClick(function()
		SendModRPCToServer(MOD_RPC["DSTAchievement"]["removecoin"])
		self.owner:DoTaskInTime(.35, function()
			self:loadcoinlist()
			self:coinbuild()
		end)
		self.mainbutton.removeinfo:Hide()
		self.mainbutton.removeyes:Hide()
		self.mainbutton.removeno:Hide()

		self.mainui.bg.allcoin:Hide()
		self.mainui.bg:Hide()
		self.mainui.infobutton:Hide()
		self.mainui.itemclassification:Hide()
		self.mainui.bg.allachiv:Hide()

		--self.mainbutton.configact:Hide()
		self.mainbutton.configbg:Hide()
		self.mainbutton.configbigger:Hide()
		self.mainbutton.configsmaller:Hide()
		self.mainbutton.configremove:Hide()
	end)

	self.mainbutton.removeno = self.mainbutton:AddChild(ImageButton("images/button/remove_no.xml", "remove_no.tex"))
	self.mainbutton.removeno:SetPosition(257, -77, 0)
	self.mainbutton.removeno:Hide()
	self.mainbutton.removeno:SetNormalScale(1,1,1)
	self.mainbutton.removeno:SetFocusScale(1.1,1.1,1)
	self.mainbutton.removeno:SetOnClick(function()
		self.mainbutton.removeinfo:Hide()
		self.mainbutton.removeyes:Hide()
		self.mainbutton.removeno:Hide()
	end)

	self.mainui.infobutton = self.mainui:AddChild(Widget("infobutton"))
	self.mainui.infobutton:SetPosition(240, -30, 0)
	self.mainui.infobutton:Hide()

	self.mainui.infobutton.info = self.mainui.infobutton:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
	self.mainui.infobutton.info:SetPosition(-240, 50, 0)
	self.mainui.bg:ScaleToSize(1253, 783)
	self.mainui.infobutton.info:Hide()

	self.mainui.infobutton.desc = self.mainui.infobutton:AddChild(Text(NEWFONT, 36, STRINGS.ALLACHIVINFODESC[1] ))
	self.mainui.infobutton.desc:SetColour(0, 0, 0, 1)
	self.mainui.infobutton.desc:SetPosition(-210, 10, 0)
	self.mainui.infobutton.desc:SetHAlign(ANCHOR_LEFT)
	self.mainui.infobutton.desc:SetRegionSize(960,680)
	self.mainui.infobutton.desc:Hide()

	self.mainui.infobutton.question = self.mainui.infobutton:AddChild(ImageButton("images/button/infobutton.xml", "infobutton.tex"))
	self.mainui.infobutton.question:SetPosition(40, -370, 0)
	self.mainui.infobutton.question:SetOnClick(function()
		if self.mainui.infobutton.info.shown then
			self.mainui.infobutton.info:Hide()
			self.mainui.infobutton.desc:Hide()
		else
			self.mainui.infobutton.info:Show()
			self.mainui.infobutton.desc:Show()
		end
	end)

	self.mainui.infobutton.last = self.mainui.infobutton:AddChild(ImageButton("images/button/last_dact.xml", "last_dact.tex"))
	self.mainui.infobutton.last:SetPosition(98, -370, 0)
	self.mainui.infobutton.last:SetOnClick(function()
		if self.numpage > 1 and self.mainui.bg.allachiv.shown then
			self.numpage = self.numpage - 1
			self:build()
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		if self.numpage == 1 then
			self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		end
	end)

	self.mainui.infobutton.last2 = self.mainui.infobutton:AddChild(ImageButton("images/button/last_dact.xml", "last_dact.tex"))
	self.mainui.infobutton.last2:SetPosition(98, -370, 0)
	self.mainui.infobutton.last2:SetOnClick(function()
		if self.numpage2 > 1 and self.mainui.bg.allcoin.shown then
			self.numpage2 = self.numpage2 - 1 
			self:coinbuild()
			self.mainui.infobutton.next2:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		if self.numpage2 == 1 then
			self.mainui.infobutton.last2:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		end
	end)
	self.mainui.infobutton.next2 = self.mainui.infobutton:AddChild(ImageButton("images/button/next_act.xml", "next_act.tex"))
	self.mainui.infobutton.next2:SetPosition(161, -370, 0)
	self.mainui.infobutton.next2:SetOnClick(function()

		if self.numpage2 < self.maxnumpage2 and self.mainui.bg.allcoin.shown then
			self.numpage2 = self.numpage2 + 1
			self:coinbuild()
			self.mainui.infobutton.last2:SetTextures("images/button/last_act.xml", "last_act.tex")
		end
		if self.numpage2 == self.maxnumpage2 then
			self.mainui.infobutton.next2:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		end
	end)

	--第3
	self.mainui.infobutton.last3 = self.mainui.infobutton:AddChild(ImageButton("images/button/last_dact.xml", "last_dact.tex"))
	self.mainui.infobutton.last3:SetPosition(98, -370, 0)
	
	self.mainui.infobutton.next3 = self.mainui.infobutton:AddChild(ImageButton("images/button/next_act.xml", "next_act.tex"))
	self.mainui.infobutton.next3:SetPosition(161, -370, 0)
	
	self.mainui.infobutton.next3:SetOnClick(function()

	end)
	
	self.mainui.infobutton.next = self.mainui.infobutton:AddChild(ImageButton("images/button/next_act.xml", "next_act.tex"))
	self.mainui.infobutton.next:SetPosition(161, -370, 0)
	self.mainui.infobutton.next:SetOnClick(function()

		if self.numpage < self.maxnumpage and self.mainui.bg.allachiv.shown then
			self.numpage = self.numpage + 1
			self:build()
			self.mainui.infobutton.last:SetTextures("images/button/last_act.xml", "last_act.tex")
		end
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		end
	end)

	self.mainui.infobutton.close = self.mainui.infobutton:AddChild(ImageButton("images/button/close.xml", "close.tex"))
	self.mainui.infobutton.close:SetPosition(220, -370, 0)
	self.mainui.infobutton.close:SetOnClick(function()
		self.mainui.bg.allachiv:Hide()
		self.mainui.bg.allcoin:Hide()
		self.mainui.bg:Hide()
		self.mainui.infobutton:Hide()
		self.mainui.itemclassification:Hide()

		--self.mainbutton.configact:Hide()
		self.mainbutton.configbg:Hide()
		self.mainbutton.configbigger:Hide()
		self.mainbutton.configsmaller:Hide()
		self.mainbutton.configremove:Hide()
		self.mainbutton.removeinfo:Hide()
		self.mainbutton.removeyes:Hide()
		self.mainbutton.removeno:Hide()
	end)

	--项目分类 
	self.mainui.itemclassification = self.mainui:AddChild(Widget("itemclassification"))
	self.mainui.itemclassification:SetPosition(-210, -30, 0)
	self.mainui.itemclassification:Hide()

	self.mainui.itemclassification.head = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_head_dact.xml", "item_head_dact.tex"))
	self.mainui.itemclassification.head:SetPosition(-220, -370, 0)
	self.mainui.itemclassification.head:SetOnGainFocus(function() self.mainui.itemclassification.head.item:SetSize(34) end)
	self.mainui.itemclassification.head:SetOnLoseFocus(function() self.mainui.itemclassification.head.item:SetSize(30) end)
	self.mainui.itemclassification.head.item = self.mainui.itemclassification.head:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[1],{0,0,0,1}))
	self.mainui.itemclassification.head.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.head.item:SetRegionSize(60,30)

	self.mainui.itemclassification.head:SetOnClick(function()
		self.numpage = 1
		self.item = 1
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_dact.xml", "item_head_dact.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
	end)

	self.mainui.itemclassification.mid2 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid2:SetPosition(-160, -370, 0)
	self.mainui.itemclassification.mid2:SetOnGainFocus(function() self.mainui.itemclassification.mid2.item:SetSize(34) end)
	self.mainui.itemclassification.mid2:SetOnLoseFocus(function() self.mainui.itemclassification.mid2.item:SetSize(30) end)
	self.mainui.itemclassification.mid2.item = self.mainui.itemclassification.mid2:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[2],{0,0,0,1}))
	self.mainui.itemclassification.mid2.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid2.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid2:SetOnClick(function()
		self.numpage = 1
		self.item = 2
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
	end)

	self.mainui.itemclassification.mid3 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid3:SetPosition(-100, -370, 0)
	self.mainui.itemclassification.mid3:SetOnGainFocus(function() self.mainui.itemclassification.mid3.item:SetSize(34) end)
	self.mainui.itemclassification.mid3:SetOnLoseFocus(function() self.mainui.itemclassification.mid3.item:SetSize(30) end)
	self.mainui.itemclassification.mid3.item = self.mainui.itemclassification.mid3:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[3],{0,0,0,1}))
	self.mainui.itemclassification.mid3.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid3.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid3:SetOnClick(function()
		self.numpage = 1
		self.item = 3
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
	end)

	self.mainui.itemclassification.mid4 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid4:SetPosition(-40, -370, 0)
	self.mainui.itemclassification.mid4:SetOnGainFocus(function() self.mainui.itemclassification.mid4.item:SetSize(34) end)
	self.mainui.itemclassification.mid4:SetOnLoseFocus(function() self.mainui.itemclassification.mid4.item:SetSize(30) end)
	self.mainui.itemclassification.mid4.item = self.mainui.itemclassification.mid4:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[4],{0,0,0,1}))
	self.mainui.itemclassification.mid4.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid4.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid4:SetOnClick(function()
		self.numpage = 1
		self.item = 4
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
	end)

	self.mainui.itemclassification.mid5 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid5:SetPosition(20, -370, 0)
	self.mainui.itemclassification.mid5:SetOnGainFocus(function() self.mainui.itemclassification.mid5.item:SetSize(34) end)
	self.mainui.itemclassification.mid5:SetOnLoseFocus(function() self.mainui.itemclassification.mid5.item:SetSize(30) end)
	self.mainui.itemclassification.mid5.item = self.mainui.itemclassification.mid5:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[5],{0,0,0,1}))
	self.mainui.itemclassification.mid5.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid5.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid5:SetOnClick(function()
		self.numpage = 1
		self.item = 5
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
		
	end)

	self.mainui.itemclassification.mid6 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid6:SetPosition(80, -370, 0)
	self.mainui.itemclassification.mid6:SetOnGainFocus(function() self.mainui.itemclassification.mid6.item:SetSize(34) end)
	self.mainui.itemclassification.mid6:SetOnLoseFocus(function() self.mainui.itemclassification.mid6.item:SetSize(30) end)
	self.mainui.itemclassification.mid6.item = self.mainui.itemclassification.mid6:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[6],{0,0,0,1}))
	self.mainui.itemclassification.mid6.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid6.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid6:SetOnClick(function()
		self.numpage = 1
		self.item = 6
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
	end)

	self.mainui.itemclassification.mid7 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid7:SetPosition(140, -370, 0)
	self.mainui.itemclassification.mid7:SetOnGainFocus(function() self.mainui.itemclassification.mid7.item:SetSize(34) end)
	self.mainui.itemclassification.mid7:SetOnLoseFocus(function() self.mainui.itemclassification.mid7.item:SetSize(30) end)
	self.mainui.itemclassification.mid7.item = self.mainui.itemclassification.mid7:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[7],{0,0,0,1}))
	self.mainui.itemclassification.mid7.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid7.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid7:SetOnClick(function()
		self.numpage = 1
		self.item = 7
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")

	end)

	self.mainui.itemclassification.mid8 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid8:SetPosition(200, -370, 0)
	self.mainui.itemclassification.mid8:SetOnGainFocus(function() self.mainui.itemclassification.mid8.item:SetSize(34) end)
	self.mainui.itemclassification.mid8:SetOnLoseFocus(function() self.mainui.itemclassification.mid8.item:SetSize(30) end)
	self.mainui.itemclassification.mid8.item = self.mainui.itemclassification.mid8:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[8],{0,0,0,1}))
	self.mainui.itemclassification.mid8.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid8.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid8:SetOnClick(function()
		self.numpage = 1
		self.item = 8
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
	end)

	self.mainui.itemclassification.mid9 = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_mide_act.xml", "item_mide_act.tex"))
	self.mainui.itemclassification.mid9:SetPosition(260, -370, 0)
	self.mainui.itemclassification.mid9:SetOnGainFocus(function() self.mainui.itemclassification.mid9.item:SetSize(34) end)
	self.mainui.itemclassification.mid9:SetOnLoseFocus(function() self.mainui.itemclassification.mid9.item:SetSize(30) end)
	self.mainui.itemclassification.mid9.item = self.mainui.itemclassification.mid9:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[10],{0,0,0,1}))
	self.mainui.itemclassification.mid9.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.mid9.item:SetRegionSize(60,30)
	self.mainui.itemclassification.mid9:SetOnClick(function()
		self.numpage = 1
		self.item = 10
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_dact.xml", "item_mide_dact.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_act.xml", "item_tail_act.tex")
		
	end)

	self.mainui.itemclassification.tail = self.mainui.itemclassification:AddChild(ImageButton("images/button/item_tail_act.xml", "item_tail_act.tex"))
	self.mainui.itemclassification.tail:SetPosition(320, -370, 0)
	self.mainui.itemclassification.tail:SetOnGainFocus(function() self.mainui.itemclassification.tail.item:SetSize(34) end)
	self.mainui.itemclassification.tail:SetOnLoseFocus(function() self.mainui.itemclassification.tail.item:SetSize(30) end)
	self.mainui.itemclassification.tail.item = self.mainui.itemclassification.tail:AddChild(Text(NEWFONT, 30, STRINGS.ALLACHIVITEM[9],{0,0,0,1}))
	self.mainui.itemclassification.tail.item:SetHAlign(ANCHOR_MIDDLE)
	self.mainui.itemclassification.tail.item:SetRegionSize(60,30)
	self.mainui.itemclassification.tail:SetOnClick(function()
		self.numpage = 1
		self.item = 9
		self:build()
		self.mainui.infobutton.last:SetTextures("images/button/last_dact.xml", "last_dact.tex")
		self.maxnumpage =  math.ceil(#self.listitem/14)
		if self.numpage == self.maxnumpage then
			self.mainui.infobutton.next:SetTextures("images/button/next_dact.xml", "next_dact.tex")
		else
			self.mainui.infobutton.next:SetTextures("images/button/next_act.xml", "next_act.tex")
		end
		self.mainui.itemclassification.head:SetTextures("images/button/item_head_act.xml", "item_head_act.tex")
		self.mainui.itemclassification.mid2:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid3:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid4:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid5:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid6:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid7:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid8:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.mid9:SetTextures("images/button/item_mide_act.xml", "item_mide_act.tex")
		self.mainui.itemclassification.tail:SetTextures("images/button/item_tail_dact.xml", "item_tail_dact.tex")
	end)
	self.inst:DoTaskInTime(.2, function()
		self.numpage = 1
		self.numpage2 = 1
		self:loadlist()
		self:loadcoinlist()
		self.maxnumpage = math.ceil(#self.achivlist/14)
		self.maxnumpage2 = math.ceil(#self.coinlist/28)
		self.achivlistbg = {}
		self.mainui.bg.allachiv.achivlisttile = {}
		self.mainui.bg.allachiv.achivlisttiledsp = {}
		self.mainui.bg.allachiv.achivlistnumber = {}

		self.mainui.bg.allachiv.achivlisttiledone = {}

		self.item = 1
		self.listitem = {}

		self.coinlistbutton = {}

		self:build()
		self:coinbuild()
		self:StartUpdating()
	end)
end)

function uiachievement:OnUpdate(dt)
	self.mainui.bg.coinamount:SetString(string.format(STRINGS.ACHIEVEMENT_POINT_AMOUNT,self.owner.currentcoinamount:value()))
	self.mainui.bg.killamount:SetString(string.format(STRINGS.ACHIEVEMENT_KILL_AMOUNT,self.owner.currentkillamount:value()))
	self:loadlist()
	self.listitem = {}
	for a = 1, #self.achivlist do
		if self.item == 1 then
			table.insert(self.listitem, self.achivlist[a])
		else
			if self.achivlist[a].item == self.item  then 
				table.insert(self.listitem, self.achivlist[a])
			end
		end
	end
	for i = 1+14*(self.numpage-1), math.min(#self.listitem, 14*(1+self.numpage-1)) do
		local check = "dact"
		--local check = "act"
		if self.listitem[i].check == 1 then 
			check = "act" 
		end
		self.mainui.bg.allachiv.achivlisttile[i].image:SetTexture("images/hud/achivbg_"..check..".xml", "achivbg_"..check..".tex")

		if self.listitem[i].check == 1 then
			self.mainui.bg.allachiv.achivlisttile[i].desc:SetColour(217/255, 170/255, 83/255, 1)
			self.mainui.bg.allachiv.achivlisttile[i].nums:SetColour(217/255, 170/255, 83/255, 1)
			self.mainui.bg.allachiv.achivlisttiledone[i]:Show()
		else
			self.mainui.bg.allachiv.achivlisttile[i].desc:SetColour(0, 0, 0, 1)
			self.mainui.bg.allachiv.achivlisttile[i].nums:SetColour(39/255, 39/255, 39/255, 1)
			self.mainui.bg.allachiv.achivlisttiledone[i]:Hide()
		end
    	
    	if achievement_config.idconfig[self.listitem[i].name] ~= nil  and self.listitem[i].name ~= "all" then
    		self.mainui.bg.allachiv.achivlisttile[i]:SetHoverText(STRINGS.ACHIEVEMENT_ACHIEVEMENT_FINISHED..self.listitem[i].current.."/"..achievement_config.idconfig[self.listitem[i].name].need_amount)
    		self.mainui.bg.allachiv.achivlisttiledone[i]:SetHoverText(STRINGS.ACHIEVEMENT_ACHIEVEMENT_FINISHED..self.listitem[i].current.."/"..achievement_config.idconfig[self.listitem[i].name].need_amount)
    	else
    		self.mainui.bg.allachiv.achivlisttile[i]:SetHoverText(STRINGS.ACHIEVEMENT_ACHIEVEMENT_FINISHED..self.listitem[i].check.."/1")
    		self.mainui.bg.allachiv.achivlisttiledone[i]:SetHoverText(STRINGS.ACHIEVEMENT_ACHIEVEMENT_FINISHED..self.listitem[i].check.."/1")
    	end

    	if self.listitem[i].name == "all" then
    		self.mainui.bg.allachiv.achivlisttile[i]:SetHoverText(STRINGS.ACHIEVEMENT_ACHIEVEMENT_FINISHED..self.achivlist[#self.achivlist].current.."/"..(#self.achivlist-1))
    		self.mainui.bg.allachiv.achivlisttiledone[i]:SetHoverText(STRINGS.ACHIEVEMENT_ACHIEVEMENT_FINISHED..self.achivlist[#self.achivlist].current.."/"..(#self.achivlist-1))
    	end
	end
end

function uiachievement:build()
	self.mainui.bg.allachiv:KillAllChildren()
	self.listitem = {}
	for a = 1, #self.achivlist do
		if self.item == 1 then
			table.insert(self.listitem, self.achivlist[a])
		else
			if self.achivlist[a].item == self.item  then 
				table.insert(self.listitem, self.achivlist[a])
			end
		end
	end

	local x = -313
	local y = 360
	for i = 1+14*(self.numpage-1), math.min(#self.listitem, 14*(1+self.numpage-1)) do
		if math.ceil(i/2) ~= i/2 then x = -265 else x = 265 end
		if math.ceil(i/2) ~= i/2 then y = y-97.3 end

		local check = "dact"
    	if self.listitem[i].check == 1 then check = "act" end

		self.mainui.bg.allachiv.achivlisttile[i] = self.mainui.bg.allachiv:AddChild(ImageButton("images/hud/achivbg_"..check..".xml", "achivbg_"..check..".tex"))
		self.mainui.bg.allachiv.achivlisttile[i]:SetFocusScale(1,1,1)
		self.mainui.bg.allachiv.achivlisttile[i]:SetPosition(x, y, 0)
		local achievement_name = self.listitem[i].name
		local achievement_desc = self.listitem[i].name
		if not STRINGS.ACHIEVEMENT_LIST[self.listitem[i].name] then
			print("error:========",self.listitem[i].name)
		else
			achievement_name = STRINGS.ACHIEVEMENT_LIST[self.listitem[i].name].name
			achievement_desc = STRINGS.ACHIEVEMENT_LIST[self.listitem[i].name].desc
		end
		self.mainui.bg.allachiv.achivlisttile[i].name = self.mainui.bg.allachiv.achivlisttile[i]:AddChild(Text(NEWFONT_OUTLINE, 40, achievement_name))
		self.mainui.bg.allachiv.achivlisttile[i].name:SetPosition(15, 25, 0)
		self.mainui.bg.allachiv.achivlisttile[i].name:SetHAlign(ANCHOR_LEFT)
		self.mainui.bg.allachiv.achivlisttile[i].name:SetRegionSize(320,40)

		self.mainui.bg.allachiv.achivlisttile[i].desc = self.mainui.bg.allachiv.achivlisttile[i]:AddChild(Text(NEWFONT, 28, string.format(achievement_desc,achievement_config.idconfig[self.listitem[i].name].need_amount)))
		self.mainui.bg.allachiv.achivlisttile[i].desc:SetPosition(15, -23, 0)
		self.mainui.bg.allachiv.achivlisttile[i].desc:SetHAlign(ANCHOR_LEFT)
		self.mainui.bg.allachiv.achivlisttile[i].desc:SetRegionSize(320,40)
		 
    	self.mainui.bg.allachiv.achivlisttile[i].nums = self.mainui.bg.allachiv.achivlisttile[i]:AddChild(Text(NEWFONT, 28, "x "..achievement_config.idconfig[self.listitem[i].name].point))
		self.mainui.bg.allachiv.achivlisttile[i].nums:SetPosition(320, -23, 0)
		self.mainui.bg.allachiv.achivlisttile[i].nums:SetHAlign(ANCHOR_LEFT)
		self.mainui.bg.allachiv.achivlisttile[i].nums:SetRegionSize(320,40)

		self.mainui.bg.allachiv.achivlisttile[i].numb = self.mainui.bg.allachiv.achivlisttile[i]:AddChild(Text(NEWFONT, 28, "No:"..i))
		self.mainui.bg.allachiv.achivlisttile[i].numb:SetPosition(320, 33, 0)
		self.mainui.bg.allachiv.achivlisttile[i].numb:SetHAlign(ANCHOR_LEFT)
		self.mainui.bg.allachiv.achivlisttile[i].numb:SetRegionSize(320,40)
		self.mainui.bg.allachiv.achivlisttile[i].numb:SetColour(0/255, 166/255, 51/255, 1) --(41/255, 174/255, 10/255, 1)
		self.mainui.bg.allachiv.achivlisttile[i]:SetOnClick(function()
			if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
				if self.cooldown then
					if achievement_config.idconfig[self.listitem[i].name] ~= nil  and self.listitem[i].name ~= "all" then
						TheNet:Say(string.format(STRINGS.SINGLE_ACHIVEMENT_PROCESS,achievement_name,self.listitem[i].current,achievement_config.idconfig[self.listitem[i].name].need_amount))
					end
					if self.listitem[i].name == "all" then
						TheNet:Say(string.format(STRINGS.SINGLE_ACHIVEMENT_PROCESS,achievement_name,self.achivlist[#self.achivlist].current,(#self.achivlist-1)))
					end

					self.cooldown = false
					self.owner:DoTaskInTime(3, function() self.cooldown = true end)
				end
			else
				if killAmountFinishAchievement == true and achievement_config.idconfig[self.listitem[i].name] ~= nil and self.listitem[i].name ~= "all" and self.listitem[i].check ~= 1  then
					SendModRPCToServer(MOD_RPC["DSTAchievement"]["finishachievement"],self.listitem[i].name)
				end
			end
		end)
		if self.listitem[i].name == "all" then
			self.mainui.bg.allachiv.achivlisttile[i].numb:Hide()
		end

		if self.listitem[i].check == 1 then
			self.mainui.bg.allachiv.achivlisttile[i].desc:SetColour(217/255, 170/255, 83/255, 1)  --(124/255, 64/255, 8/255, 1)
			self.mainui.bg.allachiv.achivlisttile[i].nums:SetColour(217/255, 170/255, 83/255, 1)  --(124/255, 64/255, 8/255, 1)
		else
			self.mainui.bg.allachiv.achivlisttile[i].desc:SetColour(0, 0, 0, 1)  --(39/255, 39/255, 39/255, 1)
			self.mainui.bg.allachiv.achivlisttile[i].nums:SetColour(39/255, 39/255, 39/255, 1)  --(39/255, 39/255, 39/255, 1) 
		end
    	
    	self.mainui.bg.allachiv.achivlisttiledone[i] = self.mainui.bg.allachiv:AddChild(Image("images/hud/achivbg_done.xml", "achivbg_done.tex"))
		self.mainui.bg.allachiv.achivlisttiledone[i]:SetPosition(x, y, 0)
		self.mainui.bg.allachiv.achivlisttiledone[i]:SetTint(1,1,1,0.95)
	
    	if self.mainui.bg.allachiv.achivlisttiledone[i].check == 1 then
			self.mainui.bg.allachiv.achivlisttiledone[i]:Show()
		else
			self.mainui.bg.allachiv.achivlisttiledone[i]:Hide()
		end
	end
end

function uiachievement:coinbuild()
	self.mainui.bg.allcoin:KillAllChildren()
	local x = -313
	local y = 260
	for i = 1+28*(self.numpage2-1), math.min(#self.coinlist, 28*(1+self.numpage2-1)) do
		if math.ceil(i/4) ~= math.ceil((i-1)/4) then x = -360 else x = x + 360*2/3 end
		y = 260-96*(math.ceil((i-28*(self.numpage2-1))/4)-1)
		self.coinlistbutton[i] = self.mainui.bg.allcoin:AddChild(ImageButton("images/coin_cn/coin_cn1.xml", "coin_cn1.tex"))
		if  self.coinlist[i].name == "speedup" or self.coinlist[i].name == "absorbup" or 
			self.coinlist[i].name == "damageup" or self.coinlist[i].name == "crit"  then
			self.coinlistbutton[i]:SetTextures("images/coin_cn/coin_cn0.xml", "coin_cn0.tex")
		end
		self.coinlistbutton[i]:SetPosition(x, y, 0)
    	self.coinlistbutton[i]:SetOnClick(function()
			
			if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
				if self.cooldown then
					if i>=1 and i <=3 then
						TheNet:Say( string.format(STRINGS.HAS_ABILITY_PROCESS,STRINGS.ACHIVABILITYNAME[self.coinlist[i].name],self.coinlist[i].current,5))
					elseif i==4 then
						TheNet:Say( string.format(STRINGS.HAS_ABILITY_PROCESS,STRINGS.ACHIVABILITYNAME[self.coinlist[i].name],self.coinlist[i].current,20))
					else
						if self.coinlist[i].current ~= nil and  self.coinlist[i].current >=  1 then
							TheNet:Say(string.format(STRINGS.HAS_ABILITY,STRINGS.ACHIVABILITYNAME[self.coinlist[i].name]))
						else
							TheNet:Say(string.format(STRINGS.NO_ABILITY,STRINGS.ACHIVABILITYNAME[self.coinlist[i].name]))
						end
					end
					self.cooldown = false
					self.owner:DoTaskInTime(3, function() self.cooldown = true end)
				end
				return 
			end
    		SendModRPCToServer(MOD_RPC["DSTAchievement"][self.coinlist[i].name])
    		self.owner:DoTaskInTime(.3, function()
    			self:loadcoinlist()
    			if i>=1 and i <=3 then
    				self.coinlistbutton[i]:SetHoverText(string.format(STRINGS.ACHIEVEMENT_HAS_AWARD,self.coinlist[i].current,5))
    			elseif i==4 then
    				self.coinlistbutton[i]:SetHoverText(string.format(STRINGS.ACHIEVEMENT_HAS_AWARD,self.coinlist[i].current,20))
    			else
    				if  self.coinlist[i].current ~= nil and  self.coinlist[i].current >=  1 then
    					self.coinlistbutton[i]:SetHoverText(STRINGS.ACHIEVEMENT_HAS_ABILITY)
    					self.coinlistbutton[i].done:Show()
    				else
    					self.coinlistbutton[i]:SetHoverText(string.format(STRINGS.ACHIEVEMENT_ABILITY_NEED, id2ability[self.coinlist[i].name].cost))
    					self.coinlistbutton[i].done:Hide()
    				end
    			end
			end)
		end)

		self.coinlistbutton[i].name = self.coinlistbutton[i]:AddChild(Text(NEWFONT, 40, STRINGS.ACHIVABILITYNAME[self.coinlist[i].name]))
		self.coinlistbutton[i].name:SetPosition(8, 10, 0)
		self.coinlistbutton[i].name:SetHAlign(ANCHOR_LEFT)
		self.coinlistbutton[i].name:SetRegionSize(200,60)
		self.coinlistbutton[i].name:SetColour(1,1,1,1)

		self.coinlistbutton[i].desc = self.coinlistbutton[i]:AddChild(Text(NEWFONT, 26, STRINGS.ACHIVABILITYDSPC[self.coinlist[i].name]))
		self.coinlistbutton[i].desc:SetPosition(8, -20, 0)
		self.coinlistbutton[i].desc:SetHAlign(ANCHOR_LEFT)
		self.coinlistbutton[i].desc:SetRegionSize(200,60)
		self.coinlistbutton[i].desc:SetColour(255/255,255/255,0/255,1)

		self.coinlistbutton[i].nums = self.coinlistbutton[i]:AddChild(Text(NEWFONT, 35,("-"..id2ability[self.coinlist[i].name].cost)))
		self.coinlistbutton[i].nums:SetPosition(50, 8, 0)
		self.coinlistbutton[i].nums:SetHAlign(ANCHOR_RIGHT)
		self.coinlistbutton[i].nums:SetRegionSize(80,30)
		self.coinlistbutton[i].nums:SetColour(253/255, 253/255, 35/255, 1)--(237/255, 235/255, 16/255, 1)

		self.coinlistbutton[i].imge = self.coinlistbutton[i]:AddChild(Image("images/coin_cn/coin_cn_start.xml", "coin_cn_start.tex"))
		self.coinlistbutton[i].imge:SetPosition(5, -5, 0)
    	self.coinlistbutton[i].imge:SetTint(1,1,1,0.95)

		self.coinlistbutton[i].chge = self.coinlistbutton[i]:AddChild(Image("images/coin_cn/coin_cn_change.xml", "coin_cn_change.tex"))
		self.coinlistbutton[i].chge:SetPosition(0, 0, 0)
    	self.coinlistbutton[i].chge:SetTint(1,1,1,0.95)

    	if self.coinlist[i].canswitch then
			self.coinlistbutton[i].chge:Show()
		else
			self.coinlistbutton[i].chge:Hide()
		end

		self.coinlistbutton[i].done = self.coinlistbutton[i]:AddChild(Image("images/coin_cn/coin_cn3.xml", "coin_cn3.tex"))
		self.coinlistbutton[i].done:SetPosition(0, 0, 0)
    	self.coinlistbutton[i].done:SetTint(1,1,1,0.95)

    	--line
    	self.coinlistbutton[i].line = self.coinlistbutton[i]:AddChild(Image("images/coin_cn/coin_cn_line.xml", "coin_cn_line.tex"))
		self.coinlistbutton[i].line:SetPosition(0, 0, 0)
    	self.coinlistbutton[i].line:SetTint(1,1,1,0.95)
    	self.coinlistbutton[i].line:Hide()

    	if self.coinlist[i].name == "speedup" or self.coinlist[i].name == "absorbup" or 
			self.coinlist[i].name == "damageup" or self.coinlist[i].name == "crit"  then
			self.coinlistbutton[i].done:Hide()
		else
			if  self.coinlist[i].current ~= nil and  self.coinlist[i].current >=  1 then
    			self.coinlistbutton[i].done:Show()
    		else
    			self.coinlistbutton[i].done:Hide()
    		end
		end

		self.coinlistbutton[i]:SetNormalScale(1,1,1)
		self.coinlistbutton[i]:SetFocusScale(1,1,1)

		self.coinlistbutton[i]:SetOnGainFocus(function() 
			self.coinlistbutton[i]:SetNormalScale(1,1,1)
			self.coinlistbutton[i].line:Show()

		end)
		self.coinlistbutton[i]:SetOnLoseFocus(function() 
			self.coinlistbutton[i]:SetFocusScale(1,1,1)
			self.coinlistbutton[i].line:Hide()
		end)
		if i>=1 and i <=3 then
    		self.coinlistbutton[i]:SetHoverText(string.format(STRINGS.ACHIEVEMENT_HAS_AWARD,self.coinlist[i].current,5))
    	elseif i==4 then
    		self.coinlistbutton[i]:SetHoverText(string.format(STRINGS.ACHIEVEMENT_HAS_AWARD,self.coinlist[i].current,20))
    	else
    		if  self.coinlist[i].current ~= nil and  self.coinlist[i].current ==  1 then
    			self.coinlistbutton[i]:SetHoverText(STRINGS.ACHIEVEMENT_HAS_ABILITY)
    		else
    			self.coinlistbutton[i]:SetHoverText(string.format(STRINGS.ACHIEVEMENT_ABILITY_NEED, id2ability[self.coinlist[i].name].cost))
    		end
    	end
	end
end

function uiachievement:loadlist()
	self.achivlist = {}
	for _,v in ipairs(achievement_config.config) do
		if v.catagory then
			table.insert(self.achivlist,#self.achivlist + 1,
			{
				name = v.id,
				check = self.owner[v.check]:value(),
				current = self.owner[v.current]:value(),
				item = v.catagory,
			})
		end
	end
	local achivvalue = 0
	for i=1, #self.achivlist do
		if self.achivlist[i].name ~= "all" then
			achivvalue = achivvalue + self.achivlist[i].check
		else
			self.achivlist[i].current = achivvalue
		end
	end
end

function uiachievement:loadcoinlist()
	self.coinlist = {}
	for _,v in ipairs(achievement_ability_config.ability_cost) do
		self.coinlist[#self.coinlist + 1] = 
		{
			name = v.ability,
			current = self.owner["current" .. v.ability]:value(),
			canswitch = v.canswitch,
		}
	end
end

return uiachievement