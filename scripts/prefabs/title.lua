local function RGB(r, g, b)
    return { r / 255, g / 255, b / 255, 1 }
end
local ColorTitle = {
	RGB( 157,  157, 157),
	RGB( 255,  255, 255),
	RGB( 30, 255, 0),
	RGB( 0,  129, 255),
	RGB( 198,  0, 255),
	RGB( 255,  128, 0),
	RGB( 229,  204, 128),
	RGB( 229,  204, 128),
	RGB(96,0,96),
	RGB(96,0,96),
	RGB(255,215,0),
	RGB(191,0,0),
}
local function SetText(inst, str,level)
	if inst and str and type(str) == "string" then
		inst.titleInfo:set(str)
		inst.level = level
		inst.textColor:set(level)
	end
end


local function OnSetText(inst)
	if inst then
		if inst._showTitle == nil then
			inst._showTitle = inst.entity:AddLabel()
		end
		inst._showTitle:SetFont(BODYTEXTFONT)
		inst._showTitle:SetFontSize(24)
		inst._showTitle:SetWorldOffset(0,4,0)
		local color = inst.textColor:value() or 0
		local phase = math.floor(color/10) + 1
		local docolor = ColorTitle[phase] or ColorTitle[#ColorTitle]
		inst._showTitle:SetColour(docolor[1],docolor[2],docolor[3],docolor[4])
		inst._showTitle:SetText(inst.titleInfo:value() or "")
		inst._showTitle:Enable(true)
	end
end
local function SetTexture(inst, level)
	if inst and level and type(level) == "number" then
		inst.imgTitleInfo:set(level + 1)
	end
end

local function OnSetTexture(inst)
	if inst._showImgTitle == nil then
		inst._showImgTitle = inst.entity:AddImage()
	end
	local level = inst.imgTitleInfo:value() or 0
	local sprite = math.floor((level-1)/23)
	local image = resolvefilepath("images/title/title.xml")
	if sprite > 0 then
		if sprite > 4 then sprite = 4 end
		inst._showImgTitle:SetTexture(image,  sprite ..".tex")	
	end
    inst._showImgTitle:SetTint(1, 1, 1, 0.9)
    inst._showImgTitle:SetWorldOffset(0,5.5,0)
    inst._showImgTitle:SetUIOffset(0, 10, 0)
    inst._showImgTitle:Enable(true)
end


local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	inst._showTitle = nil
	inst._showImgTitle = nil
	inst.level = 0
	inst.textColor = net_smallbyte(inst.GUID, "textColor", "textColor")
	inst.imgTitleInfo = net_smallbyte(inst.GUID, "imgtitle","imagetitle")
	inst:ListenForEvent("imagetitle", OnSetTexture)	
	inst:AddTag("NOCLICK")
	inst.titleInfo = net_string(inst.GUID, "texttitle", "title")
	inst:ListenForEvent("title", OnSetText)

	inst.entity:SetPristine()
	inst.SetText = SetText
	inst.SetTexture = SetTexture
	inst.persists = false
	return inst
end

return Prefab("title", fn)
