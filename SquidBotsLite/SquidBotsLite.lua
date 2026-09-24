-- SquidBots Lite: the minimal take. No window: a thin bar of six buttons (five orders and "+" to
-- recruit), the bots' roles and alerts drawn on the game's own party frames, and the offers bots
-- whisper as small toasts above the bar, each with an Invite button.

SquidBotsLiteDB = SquidBotsLiteDB or {}

local STRINGS = {
	en = {
		FOLLOW = "Follow", STAY = "Stay", ATTACK = "Target", PASSIVE = "Passive", DUNGEON = "Dungeon", RECRUIT = "Bots",
		TIP_FOLLOW = "Bots follow you.", TIP_STAY = "Bots stay where they are.", TIP_ATTACK = "Bots attack your target.",
		TIP_PASSIVE = "Bots do not start fights. Click again to end.",
		TIP_DUNGEON = "Dungeon mode: bots stick to you, avoid ground effects, engage with you.",
		TIP_RECRUIT = "Ask for a tank, a healer or damage. Offers pop up above this bar.",
		TIP_MOVE = "Shift-drag to move the bar.",
		TIP_PROFILES = "Right click: profiles (farm, strict follow, dungeon).",
		PROFILES = "Profiles", P_FARM = "Farm (hunt, loot, eat)", P_STRICT = "Strict follow",
		P_DUNGEON = "Dungeon mode", P_LEAVE_DUNGEON = "Leave dungeon mode",
		ASK_TANK = "Ask for a tank", ASK_HEAL = "Ask for a healer", ASK_DPS = "Ask for damage", ASK_ALL = "Ask for all three",
		GM_ON = "GM mode on: bots are called with .playerbots coa.",
		GM_OFF = "GM mode off: bots are called with lfg bot, like any player.",
		GEAR = "Best gear for the group", REPAIR = "Repair the group",
		INVITE = "Invite", ASKED = "Asked in %s: %s", NO_CHANNEL = "Join the Zone or Newcomers channel first (or /sbl channel <name>).",
		NOT_IN_GROUP = "You are not in a group with bots.",
		LOW_MANA = "Low mana", PULLING = "Pulling", REZ = "Rez",
		M_FOLLOW = "Follow me", M_STAY = "Stay here", M_ATTACK = "Attack my target", M_SUMMON = "Come to me",
		M_AUTOPULL_ON = "Auto pull on", M_AUTOPULL_OFF = "Auto pull off", M_KICK = "Remove from group",
		HELP = "SquidBots Lite: /sbl (show/hide), /sbl lang fr|en, /sbl channel <name>, /sbl gm (GM only), /sbl reset",
		LANG_SET = "SquidBots Lite language: English.", CHANNEL_SET = "SquidBots Lite asks in: %s",
	},
	fr = {
		FOLLOW = "Suivre", STAY = "Rester", ATTACK = "Cible", PASSIVE = "Passif", DUNGEON = "Donjon", RECRUIT = "Bots",
		TIP_FOLLOW = "Les bots vous suivent.", TIP_STAY = "Les bots restent sur place.", TIP_ATTACK = "Les bots attaquent votre cible.",
		TIP_PASSIVE = "Les bots n'engagent plus le combat. Recliquez pour arrêter.",
		TIP_DUNGEON = "Mode donjon : les bots restent avec vous, évitent les zones au sol, engagent avec vous.",
		TIP_RECRUIT = "Demandez un tank, un soigneur ou des DPS. Les offres s'affichent au-dessus de la barre.",
		TIP_MOVE = "Maj + glisser pour déplacer la barre.",
		TIP_PROFILES = "Clic droit : les profils (farm, suivi strict, donjon).",
		PROFILES = "Profils", P_FARM = "Farm (chasse, butin, repas)", P_STRICT = "Suivi strict",
		P_DUNGEON = "Mode donjon", P_LEAVE_DUNGEON = "Quitter le mode donjon",
		ASK_TANK = "Demander un tank", ASK_HEAL = "Demander un soigneur", ASK_DPS = "Demander des DPS", ASK_ALL = "Demander les trois",
		GM_ON = "Mode GM activé : les bots sont appelés avec .playerbots coa.",
		GM_OFF = "Mode GM désactivé : les bots sont appelés avec lfg bot, comme tout le monde.",
		GEAR = "Meilleur équipement du groupe", REPAIR = "Réparer le groupe",
		INVITE = "Inviter", ASKED = "Demandé dans %s : %s", NO_CHANNEL = "Rejoignez le channel Zone ou Newcomers (ou /sbl channel <nom>).",
		NOT_IN_GROUP = "Vous n'êtes pas en groupe avec des bots.",
		LOW_MANA = "Mana bas", PULLING = "Pull", REZ = "Rez",
		M_FOLLOW = "Me suivre", M_STAY = "Rester ici", M_ATTACK = "Attaquer ma cible", M_SUMMON = "Venir à moi",
		M_AUTOPULL_ON = "Auto pull activé", M_AUTOPULL_OFF = "Auto pull désactivé", M_KICK = "Retirer du groupe",
		HELP = "SquidBots Lite : /sbl (afficher/cacher), /sbl lang fr|en, /sbl channel <nom>, /sbl gm (MJ), /sbl reset",
		LANG_SET = "Langue de SquidBots Lite : français.", CHANNEL_SET = "SquidBots Lite demande dans : %s",
	},
}

local L
local CLASSES = {
	"Barbarian", "Witch Doctor", "Felsworn", "Witch Hunter", "Stormbringer", "Knight of Xoroth", "Guardian",
	"Templar", "Bloodmage", "Ranger", "Chronomancer", "Necromancer", "Pyromancer", "Cultist", "Starcaller",
	"Sun Cleric", "Tinker", "Venomancer", "Reaper", "Primalist", "Runemaster",
}
local ROLE_ICON = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"
local ROLE_COORDS = {
	tank = { 0, 19 / 64, 22 / 64, 41 / 64 },
	heal = { 20 / 64, 39 / 64, 1 / 64, 20 / 64 },
	dps = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
}
local CHANNELS = { "Zone", "Newcomers", "World" }
local OFFER_SECONDS = 300
local MAX_TOASTS = 5

local roleByName, badges, toasts = {}, {}, {}
local state = { order = "follow", passive = false }
local bar, buttons, overlays, toastFrames = nil, {}, {}, {}

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text)
end

local function SetLanguage(lang)
	if lang ~= "fr" and lang ~= "en" then
		lang = (GetLocale() == "frFR") and "fr" or "en"
	end
	SquidBotsLiteDB.lang = lang
	L = STRINGS[lang]
end

local function SendGroup(...)
	if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
		Print(L.NOT_IN_GROUP)
		return false
	end
	local channel = GetNumRaidMembers() > 0 and "RAID" or "PARTY"
	for i = 1, select("#", ...) do
		SendChatMessage(select(i, ...), channel)
	end
	return true
end

local function Whisper(name, message)
	SendChatMessage(message, "WHISPER", nil, name)
end

local function SetRoleIcon(texture, role)
	local c = role and ROLE_COORDS[role]
	if c then
		texture:SetTexture(ROLE_ICON)
		texture:SetTexCoord(c[1], c[2], c[3], c[4])
		texture:Show()
	else
		texture:Hide()
	end
end

local function FindChannel()
	local list = { GetChannelList() }
	local joined, i = {}, 1
	while i <= #list do
		if type(list[i]) == "number" and type(list[i + 1]) == "string" then
			table.insert(joined, { id = list[i], name = list[i + 1] })
			i = i + 2
		else
			i = i + 1
		end
	end
	local wanted = {}
	if SquidBotsLiteDB.channel and SquidBotsLiteDB.channel ~= "" then
		table.insert(wanted, SquidBotsLiteDB.channel)
	end
	for _, name in ipairs(CHANNELS) do
		table.insert(wanted, name)
	end
	for _, want in ipairs(wanted) do
		for _, channel in ipairs(joined) do
			if string.lower(channel.name):find("^" .. string.lower(want)) then
				return channel.id, channel.name
			end
		end
	end
end

local function Ask(roles)
	if SquidBotsLiteDB.gm then
		for role in roles:gmatch("%a+") do
			SendChatMessage(".playerbots coa " .. role, "SAY")
		end
		return
	end
	local id, name = FindChannel()
	if not id then
		Print(L.NO_CHANNEL)
		return
	end
	local message = "lfg bot " .. roles
	SendChatMessage(message, "CHANNEL", nil, id)
	Print(string.format(L.ASKED, name, message))
end

local menuFrame = CreateFrame("Frame", "SquidBotsLiteMenu", UIParent, "UIDropDownMenuTemplate")
local function ShowMenu(items)
	EasyMenu(items, menuFrame, "cursor", 0, 0, "MENU")
end

local function RecruitMenu()
	return {
		{ text = L.RECRUIT, isTitle = true, notCheckable = true },
		{ text = L.ASK_TANK, notCheckable = true, func = function() Ask("tank") end },
		{ text = L.ASK_HEAL, notCheckable = true, func = function() Ask("heal") end },
		{ text = L.ASK_DPS, notCheckable = true, func = function() Ask("dps") end },
		{ text = L.ASK_ALL, notCheckable = true, func = function() Ask("tank heal dps") end },
		{ text = L.GEAR, notCheckable = true, func = function() SendGroup("autogear") end },
		{ text = L.REPAIR, notCheckable = true, func = function() SendGroup("repair") end },
	}
end

local function ProfileMenu()
	return {
		{ text = L.PROFILES, isTitle = true, notCheckable = true },
		{ text = L.P_FARM, notCheckable = true, func = function() SendGroup("nc +grind,+loot,+food") end },
		{ text = L.P_STRICT, notCheckable = true, func = function() SendGroup("nc +follow,-grind,-rpg,-move random", "follow") end },
		{ text = L.P_DUNGEON, notCheckable = true, func = function() SendGroup("co -wait for attack,+avoid aoe", "follow") end },
		{ text = L.P_LEAVE_DUNGEON, notCheckable = true, func = function() SendGroup("co -wait for attack,-avoid aoe,-mark rti") end },
		{ text = L.GEAR, notCheckable = true, func = function() SendGroup("autogear") end },
		{ text = L.REPAIR, notCheckable = true, func = function() SendGroup("repair") end },
	}
end

local function BotMenu(name)
	local items = {
		{ text = name, isTitle = true, notCheckable = true },
		{ text = L.M_FOLLOW, notCheckable = true, func = function() Whisper(name, "follow") end },
		{ text = L.M_STAY, notCheckable = true, func = function() Whisper(name, "stay") end },
		{ text = L.M_ATTACK, notCheckable = true, func = function() Whisper(name, "attack") end },
		{ text = L.M_SUMMON, notCheckable = true, func = function() Whisper(name, "summon") end },
	}
	if roleByName[name] == "tank" then
		table.insert(items, { text = L.M_AUTOPULL_ON, notCheckable = true, func = function() Whisper(name, "nc +coa auto pull") end })
		table.insert(items, { text = L.M_AUTOPULL_OFF, notCheckable = true, func = function() Whisper(name, "nc -coa auto pull") end })
	end
	table.insert(items, { text = L.M_KICK, notCheckable = true, func = function() UninviteUnit(name) end })
	return items
end

-- ---------------------------------------------------------------------------
-- The bar
-- ---------------------------------------------------------------------------
local function Highlight()
	for key, button in pairs(buttons) do
		local active = key == state.order or (key == "passive" and state.passive)
		button.ring:SetVertexColor(active and 1 or 0.35, active and 0.82 or 0.35, active and 0 or 0.35)
	end
end

local function BarButton(key, icon, label, tip, onClick)
	local button = CreateFrame("Button", nil, bar)
	button:SetWidth(34)
	button:SetHeight(34)
	local texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture(icon)
	texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.ring = button:CreateTexture(nil, "OVERLAY")
	button.ring:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	button.ring:SetBlendMode("ADD")
	button.ring:SetWidth(62)
	button.ring:SetHeight(62)
	button.ring:SetPoint("CENTER")
	button.ring:SetAlpha(0.8)
	button.caption = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	button.caption:SetPoint("TOP", button, "BOTTOM", 0, -1)
	button.label, button.tip = label, tip
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", function() if IsShiftKeyDown() then bar:StartMoving() end end)
	button:SetScript("OnDragStop", function()
		bar:StopMovingOrSizing()
		local point, _, relativePoint, x, y = bar:GetPoint()
		SquidBotsLiteDB.point = { point, relativePoint, x, y }
	end)
	button:SetScript("OnClick", function(self, mouse)
		-- Right click anywhere on the bar: the profiles (farm, strict follow, dungeon...).
		if mouse == "RightButton" then
			ShowMenu(ProfileMenu())
		else
			onClick(self, mouse)
		end
	end)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(L[self.label])
		GameTooltip:AddLine(L[self.tip], 1, 1, 1, true)
		GameTooltip:AddLine(L.TIP_PROFILES, 0.6, 0.6, 0.6, true)
		GameTooltip:AddLine(L.TIP_MOVE, 0.6, 0.6, 0.6, true)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	buttons[key] = button
	return button
end

local function RefreshTexts()
	for _, button in pairs(buttons) do
		button.caption:SetText(L[button.label])
	end
	for _, toast in ipairs(toastFrames) do
		toast.invite:SetText(L.INVITE)
	end
end

local function BuildBar()
	bar = CreateFrame("Frame", "SquidBotsLiteBar", UIParent)
	bar:SetWidth(6 * 40)
	bar:SetHeight(48)
	bar:SetMovable(true)
	bar:SetClampedToScreen(true)
	if SquidBotsLiteDB.point then
		local p = SquidBotsLiteDB.point
		bar:SetPoint(p[1], UIParent, p[2], p[3], p[4])
	else
		bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
	end
	local defs = {
		{ "follow", "Interface\\Icons\\Ability_Hunter_Pathfinding", "FOLLOW", "TIP_FOLLOW", function()
			local sent = state.passive and SendGroup("follow", "co -passive") or SendGroup("follow")
			if sent then state.passive = false; state.order = "follow"; Highlight() end
		end },
		{ "stay", "Interface\\Icons\\Spell_Nature_TimeStop", "STAY", "TIP_STAY", function()
			if SendGroup("stay") then state.order = "stay"; Highlight() end
		end },
		{ "attack", "Interface\\Icons\\Ability_DualWield", "ATTACK", "TIP_ATTACK", function()
			if SendGroup("attack") then state.order = "attack"; Highlight() end
		end },
		{ "passive", "Interface\\Icons\\Spell_Nature_Sleep", "PASSIVE", "TIP_PASSIVE", function()
			if SendGroup(state.passive and "co -passive" or "co +passive") then state.passive = not state.passive; Highlight() end
		end },
		{ "dungeon", "Interface\\Icons\\Achievement_Dungeon_ClassicDungeonMaster", "DUNGEON", "TIP_DUNGEON", function()
			if SendGroup("co -wait for attack,+avoid aoe", "follow") then state.order = "dungeon"; Highlight() end
		end },
		{ "recruit", "Interface\\Icons\\Spell_Frost_SummonWaterElemental", "RECRUIT", "TIP_RECRUIT", function()
			ShowMenu(RecruitMenu())
		end },
	}
	for i, def in ipairs(defs) do
		local button = BarButton(def[1], def[2], def[3], def[4], def[5])
		button:SetPoint("TOPLEFT", 3 + (i - 1) * 40, 0)
	end
	RefreshTexts()
	Highlight()
	if SquidBotsLiteDB.hidden then
		bar:Hide()
	end
end

-- ---------------------------------------------------------------------------
-- Party frame overlays: role icon (click for the bot's menu) and alert text
-- ---------------------------------------------------------------------------
local function BuildOverlays()
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame" .. i]
		if frame then
			local overlay = CreateFrame("Button", nil, frame)
			overlay:SetWidth(18)
			overlay:SetHeight(18)
			overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
			overlay:SetFrameLevel(frame:GetFrameLevel() + 5)
			overlay.icon = overlay:CreateTexture(nil, "OVERLAY")
			overlay.icon:SetAllPoints()
			overlay.badge = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			overlay.badge:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 46, 10)
			overlay.unit = "party" .. i
			overlay:SetScript("OnClick", function(self)
				local name = UnitName(self.unit)
				if name then ShowMenu(BotMenu(name)) end
			end)
			overlays[i] = overlay
		end
	end
end

local function RefreshOverlays()
	local now = GetTime()
	for _, overlay in pairs(overlays) do
		local name = UnitName(overlay.unit)
		if name then
			overlay:Show()
			SetRoleIcon(overlay.icon, roleByName[name] or "none")
			if not roleByName[name] then
				overlay.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				overlay.icon:SetTexCoord(0, 1, 0, 1)
				overlay.icon:Show()
			end
			local badge = badges[name]
			if badge and badge.untilTime > now then
				overlay.badge:SetText(badge.text)
				overlay.badge:SetTextColor(badge.r, badge.g, badge.b)
			else
				overlay.badge:SetText("")
			end
		else
			overlay:Hide()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Offer toasts
-- ---------------------------------------------------------------------------
local function BuildToasts()
	for i = 1, MAX_TOASTS do
		local toast = CreateFrame("Frame", nil, bar)
		toast:SetWidth(330)
		toast:SetHeight(34)
		toast:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
		toast:SetBackdropColor(0, 0, 0, 0.85)
		toast:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 8 + (i - 1) * 36)
		toast.role = toast:CreateTexture(nil, "ARTWORK")
		toast.role:SetWidth(16)
		toast.role:SetHeight(16)
		toast.role:SetPoint("LEFT", 6, 0)
		toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		toast.text:SetPoint("TOPLEFT", 28, -4)
		toast.text:SetWidth(200)
		toast.text:SetJustifyH("LEFT")
		toast.info = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		toast.info:SetPoint("TOPLEFT", 28, -18)
		toast.info:SetWidth(200)
		toast.info:SetJustifyH("LEFT")
		toast.invite = CreateFrame("Button", nil, toast, "UIPanelButtonTemplate")
		toast.invite:SetWidth(56)
		toast.invite:SetHeight(18)
		toast.invite:SetPoint("RIGHT", -22, 0)
		toast.invite:SetScript("OnClick", function(self)
			local name = self:GetParent().offerName
			if name then InviteUnit(name) end
		end)
		toast.close = CreateFrame("Button", nil, toast, "UIPanelCloseButton")
		toast.close:SetWidth(20)
		toast.close:SetHeight(20)
		toast.close:SetPoint("RIGHT", 0, 0)
		toast.close:SetScript("OnClick", function(self)
			local name = self:GetParent().offerName
			for i = #toasts, 1, -1 do
				if toasts[i].name == name then table.remove(toasts, i) end
			end
		end)
		toast:Hide()
		toastFrames[i] = toast
	end
end

local function RefreshToasts()
	local now = GetTime()
	local members = {}
	for i = 1, 4 do
		local name = UnitName("party" .. i)
		if name then members[name] = true end
	end
	for i = #toasts, 1, -1 do
		if toasts[i].expires < now or members[toasts[i].name] then
			table.remove(toasts, i)
		end
	end
	for i, toast in ipairs(toastFrames) do
		local offer = toasts[i]
		if offer then
			toast.offerName = offer.name
			toast.text:SetText(offer.name)
			toast.info:SetText("|cffaaaaaa" .. offer.class .. " " .. offer.level .. "|r")
			SetRoleIcon(toast.role, offer.role)
			toast:Show()
		else
			toast.offerName = nil
			toast:Hide()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Chat
-- ---------------------------------------------------------------------------
local function OnWhisper(message, sender)
	local level = message:match("[Ll]evel (%d+)")
	if not level then return end
	local class
	for _, name in ipairs(CLASSES) do
		if message:find(name, 1, true) then class = name break end
	end
	local lower = string.lower(message)
	if not class or not (lower:find("invite") or lower:find("service") or lower:find("ready") or lower:find("available") or lower:find("looking")) then
		return
	end
	-- "I'll keep your tank alive" is a healer talking: the healer words win.
	local role = (lower:find("heal") or lower:find("keep your tank alive")) and "heal"
		or (lower:find("tank") and "tank" or "dps")
	roleByName[sender] = role
	for i = #toasts, 1, -1 do
		if toasts[i].name == sender then table.remove(toasts, i) end
	end
	table.insert(toasts, { name = sender, level = level, class = class, role = role, expires = GetTime() + OFFER_SECONDS })
	while #toasts > MAX_TOASTS do table.remove(toasts, 1) end
	if not bar:IsShown() then bar:Show(); SquidBotsLiteDB.hidden = false end
	RefreshToasts()
end

local function OnGroupChat(message, sender)
	if message:find("Low on mana", 1, true) then
		badges[sender] = { text = L.LOW_MANA, r = 1, g = 0.75, b = 0.2, untilTime = GetTime() + 30 }
		return
	end
	local mob = message:match("^Pulling (.+)%.$")
	if mob then
		roleByName[sender] = "tank"
		badges[sender] = { text = L.PULLING .. " " .. mob, r = 0.4, g = 0.8, b = 1, untilTime = GetTime() + 6 }
		return
	end
	local dead = message:match("^Resurrecting (.+)%.$")
	if dead then
		badges[sender] = { text = L.REZ .. " " .. dead, r = 0.5, g = 1, b = 0.5, untilTime = GetTime() + 8 }
	end
end

-- ---------------------------------------------------------------------------
-- Events and slash command
-- ---------------------------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "ADDON_LOADED" and arg1 == "SquidBotsLite" then
		SquidBotsLiteDB = SquidBotsLiteDB or {}
		SetLanguage(SquidBotsLiteDB.lang)
	elseif event == "PLAYER_LOGIN" then
		BuildBar()
		BuildOverlays()
		BuildToasts()
		RefreshTexts()
		for _, e in ipairs({ "CHAT_MSG_WHISPER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID",
			"CHAT_MSG_RAID_LEADER", "CHAT_MSG_SYSTEM" }) do
			self:RegisterEvent(e)
		end
		local elapsed = 0
		self:SetScript("OnUpdate", function(_, delta)
			elapsed = elapsed + delta
			if elapsed < 0.3 then return end
			elapsed = 0
			RefreshOverlays()
			RefreshToasts()
		end)
	elseif event == "CHAT_MSG_WHISPER" then
		OnWhisper(arg1, arg2)
	elseif event == "CHAT_MSG_SYSTEM" then
		local name, role = arg1:match("^(%S+) joins as (%a+)")
		if name and ROLE_COORDS[role] then roleByName[name] = role end
	elseif arg1 and arg2 then
		OnGroupChat(arg1, arg2)
	end
end)

SLASH_SQUIDBOTSLITE1 = "/sbl"
SLASH_SQUIDBOTSLITE2 = "/squidlite"
SlashCmdList["SQUIDBOTSLITE"] = function(message)
	local command, rest = string.match(message or "", "^(%S*)%s*(.-)$")
	command = string.lower(command or "")
	if command == "lang" then
		SetLanguage(string.lower(rest))
		RefreshTexts()
		Print(L.LANG_SET)
	elseif command == "channel" then
		SquidBotsLiteDB.channel = rest
		Print(string.format(L.CHANNEL_SET, rest ~= "" and rest or table.concat(CHANNELS, ", ")))
	elseif command == "gm" then
		-- No entry in the menu: a player without the right would only see an error.
		SquidBotsLiteDB.gm = not SquidBotsLiteDB.gm
		Print(SquidBotsLiteDB.gm and L.GM_ON or L.GM_OFF)
	elseif command == "reset" then
		SquidBotsLiteDB.point = nil
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
		bar:Show()
	elseif command == "help" or command == "?" then
		Print(L.HELP)
	elseif bar:IsShown() then
		bar:Hide()
		SquidBotsLiteDB.hidden = true
	else
		bar:Show()
		SquidBotsLiteDB.hidden = false
	end
end
