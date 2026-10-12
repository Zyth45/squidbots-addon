-- SquidBots Lite, bot sheet (beta): the gear, bags, quests and stats of one bot of the group, for players who
-- keep a long-term party of alts. Everything goes through chat commands a player can whisper to their own
-- bots ("c", "quests all", "stats", "e", "ue", "u", "s", "t", "mount"); the gear is read by the client's own inspect.

local STRINGS = {
	en = {
		TITLE = "Bot sheet", GEAR = "Gear", BAGS = "Bags", QUESTS = "Quests", INFO = "Info", REFRESH = "Refresh",
		BEST_GEAR = "Best gear", TRADE = "Open trade", FOLLOW = "Follow", STAY = "Stay", SUMMON = "Summon",
		LOGOUT = "Log out", WAIT = "Asking the bot...", NO_REPLY = "No answer: is it one of your bots?",
		NOT_IN_GROUP = "Invite it to your group to see its gear.", OUT_OF_RANGE = "Come closer to see its gear.",
		EMPTY_BAGS = "Nothing in the bags.", NO_QUESTS = "No quest.",
		GIVE = "Give it to me", SOULBOUND = "Soulbound: cannot be traded", TRADE_RANGE = "Trade: stand next to the bot (10 yards).", EQUIP = "Equip", USE = "Use", SELL = "Sell (bot next to a vendor)", SELL_GREY = "Sell grey items",
		NO_VENDOR = "Nothing sold: the bot sells only standing right next to a vendor (Summon it there, or walk it there with Follow).", LINK = "Link in chat",
		UNEQUIP = "Unequip", ITEM_HINT = "Click an item for what to do with it. Shift-click: link it in chat.",
		GEAR_HINT = "Right-click a piece to take it off.", TRADE_HINT = "Give it to me opens a trade with the bot: accept it.",
		MOUNTS = "Mounts", AUTO_MOUNT = "Automatic choice", PREFERRED = "preferred",
		GROUND = "ground", FLYING = "flying", BOTH = "ground and flying",
		MOUNT_HINT = "Click a mount: your bot rides it from now on. Automatic choice: the bot picks again.",
		NO_MOUNT_CMD = "No answer: this server's CoA Bots has no mount command yet (2.1 or later).",
		NO_MOUNTS = "This bot knows no mount.",
		USAGE = "/sbl bot <name>, or target a bot of your group and type /sbl bot.",
		NOT_A_MEMBER = "%s is not in your group.",
	},
	fr = {
		TITLE = "Fiche du bot", GEAR = "Équipement", BAGS = "Sacs", QUESTS = "Quêtes", INFO = "Infos", REFRESH = "Actualiser",
		BEST_GEAR = "Meilleur équipement", TRADE = "Ouvrir l'échange", FOLLOW = "Suivre", STAY = "Rester", SUMMON = "Appeler",
		LOGOUT = "Déconnecter", WAIT = "Demande au bot...", NO_REPLY = "Pas de réponse : est-ce bien un de vos bots ?",
		NOT_IN_GROUP = "Invitez-le dans votre groupe pour voir son équipement.", OUT_OF_RANGE = "Approchez-vous pour voir son équipement.",
		EMPTY_BAGS = "Rien dans les sacs.", NO_QUESTS = "Aucune quête.",
		GIVE = "Me le donner", SOULBOUND = "Lié : impossible à échanger", TRADE_RANGE = "Échange : placez-vous à côté du bot (10 mètres).", EQUIP = "Équiper", USE = "Utiliser", SELL = "Vendre (bot à côté d'un marchand)", SELL_GREY = "Vendre les gris",
		NO_VENDOR = "Rien vendu : le bot ne vend que collé à un marchand (appelez-le devant le marchand, ou amenez-le avec Suivre).", LINK = "Lien dans le chat",
		UNEQUIP = "Retirer", ITEM_HINT = "Cliquez un objet pour choisir quoi en faire. Maj-clic : lien dans le chat.",
		GEAR_HINT = "Clic droit sur une pièce pour la retirer.", TRADE_HINT = "Me le donner ouvre un échange avec le bot : acceptez-le.",
		MOUNTS = "Montures", AUTO_MOUNT = "Choix automatique", PREFERRED = "préférée",
		GROUND = "sol", FLYING = "vol", BOTH = "sol et vol",
		MOUNT_HINT = "Cliquez une monture : votre bot la prend désormais. Choix automatique : le bot choisit à nouveau.",
		NO_MOUNT_CMD = "Pas de réponse : le CoA Bots de ce serveur n'a pas encore la commande des montures (2.1 ou plus).",
		NO_MOUNTS = "Ce bot ne connaît aucune monture.",
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
local BAG_COLS, BAG_ROWS, QUEST_ROWS, MOUNT_ROWS = 8, 6, 14, 11
-- Inventory slot ids of the 3.3.5 client, left column, right column, then weapons.
local GEAR_LEFT = { 1, 2, 3, 15, 5, 4, 19, 9 }
local GEAR_RIGHT = { 10, 6, 7, 8, 11, 12, 13, 14 }
local GEAR_BOTTOM = { 16, 17, 18 }

local sheet, current, tab
local capture, hideFrom, lastAsked = nil, {}, {}
local bags, quests, stats, mounts = {}, {}, {}, {}
local mountOffset = 0

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

-- "Mount: |cffffffff|Hspell:ID|h[Name]|h|r ground (preferred)", then "Mounts: N" (CoA Bots 2.1).
local function ParseMounts(lines)
	local list = {}
	for _, line in ipairs(lines) do
		local id = tonumber(line:match("^Mount: .-|Hspell:(%d+)|h"))
		if id then
			table.insert(list, { id = id, name = line:match("|h%[(.-)%]|h") or "?",
				kind = line:match("|h|r (%a+)") or line:match("%] (%a+)"), preferred = line:find("(preferred)", 1, true) ~= nil })
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
	elseif done.kind == "mounts" then
		mounts = ParseMounts(done.lines)
		mountOffset = 0
	else
		stats = done.lines
	end
	if #done.lines == 0 then
		sheet.status:SetText(done.kind == "mounts" and T("NO_MOUNT_CMD") or T("NO_REPLY"))
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
			if capture.kind == "mounts" and message:find("^Mounts: %d+") then Finish() end
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
	-- /sbl sheetdebug shows the sheet's questions and the bot's answers, to see where an action stops.
	if SquidBotsLiteDB and SquidBotsLiteDB.sheetDebug then return false end
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
	local unit = UnitOf(current)
	if not unit or not CheckInteractDistance(unit, 2) then
		Print(T("TRADE_RANGE"))
		return
	end
	Whisper("t " .. link)
	giveAt = { link = link, at = GetTime() + 1.5 }
end
local giveWatch = CreateFrame("Frame")
giveWatch:SetScript("OnUpdate", function()
	if giveAt and GetTime() >= giveAt.at then
		local link = giveAt.link
		giveAt = nil
		Whisper("t " .. link)
	end
end)

local sellCheck
-- One item: silence means no vendor. "gray" with nothing grey is silent too, so it is not checked.
local function Sell(text, unchecked)
	Whisper("s " .. text)
	if not unchecked then sellCheck = { name = current, at = GetTime() + 3 } end
end
local sellWatch = CreateFrame("Frame")
sellWatch:RegisterEvent("CHAT_MSG_WHISPER")
sellWatch:SetScript("OnEvent", function(_, _, message, sender)
	if sellCheck and sender == sellCheck.name and message:find("^Selling ") then sellCheck = nil end
end)
sellWatch:SetScript("OnUpdate", function()
	if sellCheck and GetTime() >= sellCheck.at then
		sellCheck = nil
		Print(T("NO_VENDOR"))
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
			if tab == "bags" then Ask("bags", "c") elseif tab == "mounts" then Ask("mounts", "mount ?") elseif tab == "gear" then Render() end
		end
	end)
end

-- The bot links an item with 7 fields after its id ("item:ID:0:0:0:0:0:0:0"); the 3.3.5 client wants 9 and
-- refuses to send a malformed link (a silent Lua error: no trade, no sale). The client's own link is used.
local function SendableLink(item)
	local _, link = GetItemInfo(item.id)
	if link then return link end
	local color, name = item.link:match("^|c(%x+)|H"), item.link:match("|h%[(.-)%]|h")
	return "|c" .. (color or "ffffffff") .. "|Hitem:" .. item.id .. ":0:0:0:0:0:0:0:0|h[" .. (name or "?") .. "]|h|r"
end

local function ItemMenu(item)
	local link = SendableLink(item)
	EasyMenu({
		{ text = item.link, isTitle = true, notCheckable = true },
		item.soulbound and { text = T("SOULBOUND"), notCheckable = true, disabled = true }
			or { text = T("GIVE"), notCheckable = true, func = function() Give(link); AfterChange() end },
		{ text = T("EQUIP"), notCheckable = true, func = function() Whisper("e " .. link); AfterChange() end },
		{ text = T("USE"), notCheckable = true, func = function() Whisper("u " .. link); AfterChange() end },
		{ text = T("SELL"), notCheckable = true, func = function() Sell(link); AfterChange() end },
		{ text = T("LINK"), notCheckable = true, func = function() ChatEdit_InsertLink(link) end },
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
			if IsShiftKeyDown() then ChatEdit_InsertLink(SendableLink(self.item)) else ItemMenu(self.item) end
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
	page.grey = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.grey:SetWidth(130)
	page.grey:SetHeight(22)
	page.grey:SetPoint("LEFT", page.trade, "RIGHT", 8, 0)
	page.grey:SetScript("OnClick", function() Sell("gray", true); AfterChange() end)
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

local RenderMounts

local function BuildMounts(page)
	page.rows = {}
	for i = 1, MOUNT_ROWS do
		local row = CreateFrame("Button", nil, page)
		row:SetWidth(370)
		row:SetHeight(22)
		row:SetPoint("TOPLEFT", 10, -(i - 1) * 24)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(20)
		row.icon:SetHeight(20)
		row.icon:SetPoint("LEFT", 2, 0)
		row.check = row:CreateTexture(nil, "OVERLAY")
		row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		row.check:SetWidth(18)
		row.check:SetHeight(18)
		row.check:SetPoint("RIGHT", -4, 0)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.name:SetPoint("LEFT", 28, 0)
		row.name:SetWidth(220)
		row.name:SetJustifyH("LEFT")
		row.kind = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		row.kind:SetPoint("LEFT", 252, 0)
		row:SetScript("OnEnter", function(self)
			if self.mount then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink("spell:" .. self.mount.id)
				GameTooltip:Show()
			end
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		row:SetScript("OnClick", function(self)
			if self.mount then Whisper("mount " .. self.mount.id); AfterChange() end
		end)
		page.rows[i] = row
	end
	page.up = CreateFrame("Button", nil, page, "UIPanelScrollUpButtonTemplate")
	page.up:SetPoint("TOPRIGHT", -6, 0)
	page.up:SetScript("OnClick", function() mountOffset = math.max(0, mountOffset - MOUNT_ROWS); RenderMounts(page) end)
	page.down = CreateFrame("Button", nil, page, "UIPanelScrollDownButtonTemplate")
	page.down:SetPoint("TOPRIGHT", -6, -(MOUNT_ROWS * 24) + 16)
	page.down:SetScript("OnClick", function()
		if mountOffset + MOUNT_ROWS < #mounts then mountOffset = mountOffset + MOUNT_ROWS end
		RenderMounts(page)
	end)
	page.auto = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.auto:SetWidth(150)
	page.auto:SetHeight(22)
	page.auto:SetPoint("TOPLEFT", 10, -(MOUNT_ROWS * 24) - 6)
	page.auto:SetScript("OnClick", function() Whisper("mount clear"); AfterChange() end)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", page.auto, "TOPRIGHT", 8, 2)
	page.hint:SetWidth(200)
	page.hint:SetJustifyH("LEFT")
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.note:SetWidth(340)
end

RenderMounts = function(page)
	page.note:SetText(#mounts == 0 and capture == nil and sheet.status:GetText() == "" and T("NO_MOUNTS") or "")
	page.auto:SetText(T("AUTO_MOUNT"))
	page.hint:SetText(T("MOUNT_HINT"))
	local kinds = { ground = T("GROUND"), flying = T("FLYING"), both = T("BOTH") }
	for i, row in ipairs(page.rows) do
		local m = mounts[mountOffset + i]
		row.mount = m
		if m then
			row.icon:SetTexture(select(3, GetSpellInfo(m.id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			row.name:SetText(m.name)
			row.kind:SetText((kinds[m.kind] or m.kind or "") .. (m.preferred and ("  |cffffd100" .. T("PREFERRED") .. "|r") or ""))
			if m.preferred then row.check:Show() else row.check:Hide() end
			row:Show()
		else
			row:Hide()
		end
	end
	if #mounts > MOUNT_ROWS then page.up:Show(); page.down:Show() else page.up:Hide(); page.down:Hide() end
end

local TABS = { { "gear", "GEAR", BuildGear }, { "bags", "BAGS", BuildBags }, { "quests", "QUESTS", BuildQuests },
	{ "mounts", "MOUNTS", BuildMounts }, { "info", "INFO", BuildInfo } }

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
	page.grey:SetText(T("SELL_GREY"))
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
	elseif tab == "mounts" then RenderMounts(pages.mounts)
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
	elseif tab == "mounts" then
		Ask("mounts", "mount ?")
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
		b:SetWidth(74)
		b:SetHeight(22)
		b:SetPoint("TOPLEFT", 16 + (i - 1) * 78, -36)
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
	if current ~= name then bags, quests, stats, mounts = {}, {}, {}, {} end
	current = name
	tab = tab or "gear"
	sheet:Show()
	if not UnitOf(name) and tab == "gear" then tab = "bags" end
	Load()
end

function SquidBotsLite_SheetDebug()
	SquidBotsLiteDB.sheetDebug = not SquidBotsLiteDB.sheetDebug
	Print("sheet debug " .. (SquidBotsLiteDB.sheetDebug and "on" or "off"))
end
