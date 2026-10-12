-- SquidBots Lite, bot sheet (beta): the gear, bags, quests and stats of one bot of the group, for players who
-- keep a long-term party of alts. Everything goes through chat commands a player can whisper to their own
-- bots ("c", "quests all", "stats", "e", "ue", "u", "s", "t"); the gear is read by the client's own inspect.

local STRINGS = {
	en = {
		TITLE = "Bot sheet", GEAR = "Gear", BAGS = "Bags", QUESTS = "Quests", INFO = "Info", REFRESH = "Refresh",
		BEST_GEAR = "Best gear", TRADE = "Open trade", FOLLOW = "Follow", STAY = "Stay", SUMMON = "Summon",
		LOGOUT = "Log out", WAIT = "Asking the bot...", NO_REPLY = "No answer: is it one of your bots?",
		NOT_IN_GROUP = "Invite it to your group to see its gear.", OUT_OF_RANGE = "Come closer to see its gear.",
		EMPTY_BAGS = "Nothing in the bags.", NO_QUESTS = "No quest.",
		GIVE = "Give it to me", EQUIP = "Equip", USE = "Use", SELL = "Sell (bot at a vendor)", LINK = "Link in chat",
		UNEQUIP = "Unequip", ITEM_HINT = "Click an item for what to do with it. Shift-click: link it in chat.",
		GEAR_HINT = "Right-click a piece to take it off.", TRADE_HINT = "Give it to me opens a trade with the bot: accept it.",
		MOUNT_NOTE = "Preferred mount: not possible yet, the server has no command for it.",
		USAGE = "/sbl bot <name>, or target a bot of your group and type /sbl bot.",
		NOT_A_MEMBER = "%s is not in your group.",
	},
	fr = {
		TITLE = "Fiche du bot", GEAR = "Équipement", BAGS = "Sacs", QUESTS = "Quêtes", INFO = "Infos", REFRESH = "Actualiser",
		BEST_GEAR = "Meilleur équipement", TRADE = "Ouvrir l'échange", FOLLOW = "Suivre", STAY = "Rester", SUMMON = "Appeler",
		LOGOUT = "Déconnecter", WAIT = "Demande au bot...", NO_REPLY = "Pas de réponse : est-ce bien un de vos bots ?",
		NOT_IN_GROUP = "Invitez-le dans votre groupe pour voir son équipement.", OUT_OF_RANGE = "Approchez-vous pour voir son équipement.",
		EMPTY_BAGS = "Rien dans les sacs.", NO_QUESTS = "Aucune quête.",
		GIVE = "Me le donner", EQUIP = "Équiper", USE = "Utiliser", SELL = "Vendre (bot chez un marchand)", LINK = "Lien dans le chat",
		UNEQUIP = "Retirer", ITEM_HINT = "Cliquez un objet pour choisir quoi en faire. Maj-clic : lien dans le chat.",
		GEAR_HINT = "Clic droit sur une pièce pour la retirer.", TRADE_HINT = "Me le donner ouvre un échange avec le bot : acceptez-le.",
		MOUNT_NOTE = "Monture préférée : pas encore possible, le serveur n'a pas de commande pour ça.",
		USAGE = "/sbl bot <nom>, ou ciblez un bot de votre groupe et tapez /sbl bot.",
		NOT_A_MEMBER = "%s n'est pas dans votre groupe.",
	},
}
local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key]
end

local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
-- The bot answers line by line; a listing is over once it stays quiet this long. The server drops a line it
-- already sent in the last 2 s (AiPlayerbot.RepeatDelay), so a new request waits that long.
local QUIET, GIVE_UP, REPEAT_DELAY = 1.2, 6, 2.2
local BAG_COLS, BAG_ROWS, QUEST_ROWS = 8, 6, 14
-- Inventory slot ids of the 3.3.5 client, left column, right column, then weapons.
local GEAR_LEFT = { 1, 2, 3, 15, 5, 4, 19, 9 }
local GEAR_RIGHT = { 10, 6, 7, 8, 11, 12, 13, 14 }
local GEAR_BOTTOM = { 16, 17, 18 }

local sheet, current, tab
local capture, hideFrom, lastAsked = nil, {}, {}
local bags, quests, stats = {}, {}, {}

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text)
end

local function UnitOf(name)
	if UnitName("target") == name and (UnitInParty("target") or UnitInRaid("target")) then return "target" end
	for i = 1, 4 do
		if UnitName("party" .. i) == name then return "party" .. i end
	end
	for i = 1, 40 do
		if UnitName("raid" .. i) == name then return "raid" .. i end
	end
end

local function Whisper(text)
	if not current then return end
	hideFrom[current] = GetTime() + QUIET + 1
	SendChatMessage(text, "WHISPER", nil, current)
end

-- ---------------------------------------------------------------------------
-- Listings: "c", "quests all", "stats" come back as one whisper per line
-- ---------------------------------------------------------------------------
local Render

local function Ask(kind, command)
	if not current then return end
	local key = current .. ":" .. kind
	if lastAsked[key] and GetTime() - lastAsked[key] < REPEAT_DELAY then return end
	lastAsked[key] = GetTime()
	capture = { name = current, kind = kind, lines = {}, started = GetTime(), last = GetTime() }
	sheet.status:SetText(T("WAIT"))
	Whisper(command)
end

local function ParseBags(lines)
	local list = {}
	for _, line in ipairs(lines) do
		local link = line:match("(|c%x+|Hitem:[^|]+|h%[.-%]|h|r)")
		if link then
			local id = tonumber(link:match("|Hitem:(%d+)"))
			local count = tonumber(line:match("|h|rx(%d+)")) or 1
			table.insert(list, { link = link, id = id, count = count, soulbound = line:find("(soulbound)", 1, true) ~= nil })
		end
	end
	return list
end

local function ParseQuests(lines)
	local list = {}
	for _, line in ipairs(lines) do
		if line:find("|Hquest:", 1, true) then
			table.insert(list, { text = line, link = line:match("|H(quest:[^|]+)|h") })
		elseif line:find("^%-%-%- ") or line:find("^Total: ") then
			table.insert(list, { text = "|cffffd100" .. line:gsub("%-%-%-", ""):gsub("^%s+", "") .. "|r" })
		end
	end
	return list
end

local function Finish()
	local done = capture
	capture = nil
	hideFrom[done.name] = GetTime() + 1
	if done.name ~= current then return end
	if done.kind == "bags" then
		bags = ParseBags(done.lines)
	elseif done.kind == "quests" then
		quests = ParseQuests(done.lines)
	else
		stats = done.lines
	end
	if #done.lines == 0 then
		sheet.status:SetText(T("NO_REPLY"))
	else
		sheet.status:SetText("")
	end
	Render()
end

local watch = CreateFrame("Frame")
watch:RegisterEvent("CHAT_MSG_WHISPER")
watch:RegisterEvent("INSPECT_TALENT_READY")
watch:RegisterEvent("UNIT_INVENTORY_CHANGED")
watch:SetScript("OnEvent", function(_, event, message, sender)
	if event == "CHAT_MSG_WHISPER" then
		if capture and sender == capture.name then
			-- The inventory starts with its own title: earlier chatter of the bot is not part of it.
			if capture.kind == "bags" and message == "=== Inventory ===" then
				capture.lines = {}
			else
				table.insert(capture.lines, message)
			end
			capture.last = GetTime()
		end
	elseif sheet and sheet:IsShown() and tab == "gear" then
		Render()
	end
end)

local elapsed = 0
watch:SetScript("OnUpdate", function(_, delta)
	elapsed = elapsed + delta
	if elapsed < 0.25 then return end
	elapsed = 0
	if capture then
		local now = GetTime()
		if (#capture.lines > 0 and now - capture.last > QUIET) or now - capture.started > GIVE_UP then
			Finish()
		end
	end
end)

-- What the sheet asks and what the bot answers stay out of the chat.
local function Hide(_, _, message, name)
	if (capture and name == capture.name) or (hideFrom[name] and GetTime() < hideFrom[name]) then
		return true
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Hide)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Hide)

-- ---------------------------------------------------------------------------
-- Actions on an item
-- ---------------------------------------------------------------------------
local menuFrame = CreateFrame("Frame", "SquidBotsLiteSheetMenu", UIParent, "UIDropDownMenuTemplate")

-- "t [item]" opens a trade with the master first, and puts the item in only once the trade is open.
local giveAt
local function Give(link)
	Whisper("t " .. link)
	giveAt = { link = link, at = GetTime() + 1 }
end
local giveWatch = CreateFrame("Frame")
giveWatch:SetScript("OnUpdate", function()
	if giveAt and GetTime() >= giveAt.at then
		local link = giveAt.link
		giveAt = nil
		Whisper("t " .. link)
	end
end)

local function AfterChange()
	-- The bags changed: ask again once the server lets the same lines through.
	local name = current
	local again = CreateFrame("Frame")
	local wait = 0
	again:SetScript("OnUpdate", function(self, delta)
		wait = wait + delta
		if wait < REPEAT_DELAY then return end
		self:SetScript("OnUpdate", nil)
		if current == name and sheet:IsShown() then
			if tab == "bags" then Ask("bags", "c") elseif tab == "gear" then Render() end
		end
	end)
end

local function ItemMenu(item)
	EasyMenu({
		{ text = item.link, isTitle = true, notCheckable = true },
		{ text = T("GIVE"), notCheckable = true, func = function() Give(item.link); AfterChange() end },
		{ text = T("EQUIP"), notCheckable = true, func = function() Whisper("e " .. item.link); AfterChange() end },
		{ text = T("USE"), notCheckable = true, func = function() Whisper("u " .. item.link); AfterChange() end },
		{ text = T("SELL"), notCheckable = true, func = function() Whisper("s " .. item.link); AfterChange() end },
		{ text = T("LINK"), notCheckable = true, func = function() ChatEdit_InsertLink(item.link) end },
	}, menuFrame, "cursor", 0, 0, "MENU")
end

-- ---------------------------------------------------------------------------
-- The sheet
-- ---------------------------------------------------------------------------
local function ItemButton(parent, size)
	local b = CreateFrame("Button", nil, parent)
	b:SetWidth(size)
	b:SetHeight(size)
	b:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	b:GetNormalTexture():SetAllPoints()
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetPoint("TOPLEFT", 2, -2)
	b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
	b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	b.count:SetPoint("BOTTOMRIGHT", -2, 2)
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return b
end

local pages = {}

local function BuildGear(page)
	page.slots = {}
	local function Slot(slot, x, y)
		local b = ItemButton(page, 36)
		b:SetPoint("TOPLEFT", x, y)
		b.slot = slot
		b:SetScript("OnEnter", function(self)
			local unit = current and UnitOf(current)
			if unit and GetInventoryItemLink(unit, self.slot) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetInventoryItem(unit, self.slot)
				GameTooltip:Show()
			end
		end)
		b:SetScript("OnClick", function(self, mouse)
			local unit = current and UnitOf(current)
			local link = unit and GetInventoryItemLink(unit, self.slot)
			if not link then return end
			if IsShiftKeyDown() then
				ChatEdit_InsertLink(link)
			elseif mouse == "RightButton" then
				Whisper("ue " .. link)
				AfterChange()
			end
		end)
		page.slots[slot] = b
	end
	for i, slot in ipairs(GEAR_LEFT) do Slot(slot, 10, -(i - 1) * 40) end
	for i, slot in ipairs(GEAR_RIGHT) do Slot(slot, 344, -(i - 1) * 40) end
	for i, slot in ipairs(GEAR_BOTTOM) do Slot(slot, 134 + (i - 1) * 44, -296) end
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.note:SetWidth(240)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOP", 0, -20)
	page.hint:SetWidth(240)
	page.best = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.best:SetWidth(140)
	page.best:SetHeight(22)
	page.best:SetPoint("TOP", 0, -250)
	page.best:SetScript("OnClick", function() Whisper("autogear"); AfterChange() end)
end

local function BuildBags(page)
	page.buttons = {}
	for i = 1, BAG_COLS * BAG_ROWS do
		local b = ItemButton(page, 40)
		b:SetPoint("TOPLEFT", 14 + ((i - 1) % BAG_COLS) * 46, -math.floor((i - 1) / BAG_COLS) * 46)
		b:SetScript("OnEnter", function(self)
			if self.item then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(self.item.link:match("|H(item:[^|]+)|h"))
				GameTooltip:Show()
			end
		end)
		b:SetScript("OnClick", function(self)
			if not self.item then return end
			if IsShiftKeyDown() then ChatEdit_InsertLink(self.item.link) else ItemMenu(self.item) end
		end)
		page.buttons[i] = b
	end
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", 14, -282)
	page.hint:SetWidth(360)
	page.hint:SetJustifyH("LEFT")
	page.trade = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.trade:SetWidth(130)
	page.trade:SetHeight(22)
	page.trade:SetPoint("TOPLEFT", 14, -310)
	page.trade:SetScript("OnClick", function()
		local unit = current and UnitOf(current)
		if unit then InitiateTrade(unit) end
	end)
end

local function BuildQuests(page)
	page.rows = {}
	for i = 1, QUEST_ROWS do
		local row = CreateFrame("Button", nil, page)
		row:SetWidth(360)
		row:SetHeight(18)
		row:SetPoint("TOPLEFT", 14, -(i - 1) * 20)
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.text:SetAllPoints()
		row.text:SetJustifyH("LEFT")
		row:SetScript("OnEnter", function(self)
			if self.quest and self.quest.link then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(self.quest.link)
				GameTooltip:Show()
			end
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		row:SetScript("OnClick", function(self)
			if self.quest and self.quest.link and IsShiftKeyDown() then ChatEdit_InsertLink(self.quest.text) end
		end)
		page.rows[i] = row
	end
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
end

local function BuildInfo(page)
	page.text = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.text:SetPoint("TOPLEFT", 14, 0)
	page.text:SetWidth(360)
	page.text:SetJustifyH("LEFT")
	page.mount = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.mount:SetPoint("TOPLEFT", 14, -240)
	page.mount:SetWidth(360)
	page.mount:SetJustifyH("LEFT")
	page.buttons = {}
	local defs = {
		{ "FOLLOW", function() Whisper("follow") end },
		{ "STAY", function() Whisper("stay") end },
		{ "SUMMON", function() Whisper("summon") end },
		{ "TRADE", function() local u = current and UnitOf(current); if u then InitiateTrade(u) end end },
		{ "LOGOUT", function() if current then SendChatMessage(".playerbots bot remove " .. current, "SAY"); sheet:Hide() end end },
	}
	for i, def in ipairs(defs) do
		local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
		b:SetWidth(112)
		b:SetHeight(22)
		b:SetPoint("TOPLEFT", 14 + ((i - 1) % 3) * 118, -270 - math.floor((i - 1) / 3) * 26)
		b.label = def[1]
		b:SetScript("OnClick", def[2])
		page.buttons[i] = b
	end
end

local TABS = { { "gear", "GEAR", BuildGear }, { "bags", "BAGS", BuildBags }, { "quests", "QUESTS", BuildQuests },
	{ "info", "INFO", BuildInfo } }

local function RenderGear(page)
	local unit = current and UnitOf(current)
	local inRange = unit and CheckInteractDistance(unit, 1)
	page.note:SetText(not unit and T("NOT_IN_GROUP") or (not inRange and T("OUT_OF_RANGE")) or "")
	page.hint:SetText(T("GEAR_HINT"))
	page.best:SetText(T("BEST_GEAR"))
	for slot, b in pairs(page.slots) do
		local texture = unit and GetInventoryItemTexture(unit, slot)
		b.icon:SetTexture(texture)
		if texture then b.icon:Show() else b.icon:Hide() end
	end
end

local function RenderBags(page)
	page.note:SetText(#bags == 0 and capture == nil and T("EMPTY_BAGS") or "")
	page.hint:SetText(T("ITEM_HINT") .. " " .. T("TRADE_HINT"))
	page.trade:SetText(T("TRADE"))
	for i, b in ipairs(page.buttons) do
		local item = bags[i]
		b.item = item
		if item then
			b.icon:SetTexture((GetItemIcon and GetItemIcon(item.id)) or select(10, GetItemInfo(item.id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			b.icon:Show()
			b.count:SetText(item.count > 1 and item.count or "")
			b:Show()
		else
			b:Hide()
		end
	end
end

local function RenderQuests(page)
	page.note:SetText(#quests == 0 and capture == nil and T("NO_QUESTS") or "")
	for i, row in ipairs(page.rows) do
		local q = quests[i]
		row.quest = q
		row.text:SetText(q and q.text or "")
		if q then row:Show() else row:Hide() end
	end
end

local function RenderInfo(page)
	page.text:SetText(table.concat(stats, "\n"))
	page.mount:SetText(T("MOUNT_NOTE"))
	for _, b in ipairs(page.buttons) do b:SetText(T(b.label)) end
end

Render = function()
	if not sheet or not sheet:IsShown() then return end
	sheet.title:SetText("SquidBots Lite - " .. T("TITLE") .. " : " .. (current or "?"))
	sheet.refresh:SetText(T("REFRESH"))
	for _, def in ipairs(TABS) do
		local key = def[1]
		sheet.tabs[key]:SetText(T(def[2]))
		if key == tab then sheet.tabs[key]:LockHighlight() else sheet.tabs[key]:UnlockHighlight() end
		if key == tab then pages[key]:Show() else pages[key]:Hide() end
	end
	if tab == "gear" then RenderGear(pages.gear)
	elseif tab == "bags" then RenderBags(pages.bags)
	elseif tab == "quests" then RenderQuests(pages.quests)
	else RenderInfo(pages.info) end
end

local function Load()
	if tab == "gear" then
		local unit = current and UnitOf(current)
		if unit and CanInspect(unit) then NotifyInspect(unit) end
		Render()
	elseif tab == "bags" then
		Ask("bags", "c")
	elseif tab == "quests" then
		Ask("quests", "quests all")
	else
		Ask("stats", "stats")
	end
	Render()
end

local function Build()
	sheet = CreateFrame("Frame", "SquidBotsLiteSheet", UIParent)
	sheet:SetWidth(420)
	sheet:SetHeight(470)
	sheet:SetPoint("CENTER", 120, 0)
	sheet:SetBackdrop(BACKDROP)
	sheet:SetBackdropColor(0.04, 0.04, 0.05, 1)
	sheet:SetFrameStrata("DIALOG")
	sheet:SetMovable(true)
	sheet:EnableMouse(true)
	sheet:SetClampedToScreen(true)
	sheet:RegisterForDrag("LeftButton")
	sheet:SetScript("OnDragStart", sheet.StartMoving)
	sheet:SetScript("OnDragStop", sheet.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteSheet")
	sheet.title = sheet:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	sheet.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, sheet, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	sheet.tabs = {}
	for i, def in ipairs(TABS) do
		local b = CreateFrame("Button", nil, sheet, "UIPanelButtonTemplate")
		b:SetWidth(90)
		b:SetHeight(22)
		b:SetPoint("TOPLEFT", 16 + (i - 1) * 96, -36)
		b:SetScript("OnClick", function() tab = def[1]; Load() end)
		sheet.tabs[def[1]] = b
		local page = CreateFrame("Frame", nil, sheet)
		page:SetPoint("TOPLEFT", 8, -70)
		page:SetPoint("BOTTOMRIGHT", -8, 40)
		def[3](page)
		pages[def[1]] = page
	end
	sheet.refresh = CreateFrame("Button", nil, sheet, "UIPanelButtonTemplate")
	sheet.refresh:SetWidth(100)
	sheet.refresh:SetHeight(22)
	sheet.refresh:SetPoint("BOTTOMRIGHT", -16, 14)
	sheet.refresh:SetScript("OnClick", function() Load() end)
	sheet.status = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	sheet.status:SetPoint("BOTTOMLEFT", 18, 20)
	sheet:Hide()
end

-- Opened from a bot's menu, the My alts panel, or /sbl bot <name>.
function SquidBotsLite_OpenSheet(name)
	if not name or name == "" then
		name = UnitName("target")
		if not name or not UnitOf(name) then Print(T("USAGE")) return end
	end
	if not sheet then Build() end
	if current ~= name then bags, quests, stats = {}, {}, {} end
	current = name
	tab = tab or "gear"
	sheet:Show()
	if not UnitOf(name) and tab == "gear" then tab = "bags" end
	Load()
end
