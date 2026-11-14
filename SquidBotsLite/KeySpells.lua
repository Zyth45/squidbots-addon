-- SquidBots Lite, the key spells bar (CoA Bots 3.1.1). One row per bot of the group: its big cooldowns
-- (Bloodlust or Heroism, Innervate, Power Infusion, a battle res, the big heals and the external saves). A click
-- whispers the bot "cast <spellId> on <name>": the server casts its best rank, on your target or on you (helpful
-- spells), on itself (group spells), on your dead target (a res). A right-click keeps the spell: the bot no longer
-- casts it by itself, only when you click (it needs the realm's keepcd).
-- What each bot knows: the realm's answer to the addon message "keyspells" (prefix SQBA, whispered):
--   KSPELL it <spellId> <cdLeftMs> <cdTotalMs> <kept 0|1> ... then KSPELL - ; KSPELL err off.
--   keepcd <spellId> on|off -> KCD done <spellId> <0|1> | KCD err <spellId> <unknown|off>.
-- A realm without them: the class and level say what a WotLK class bot has, and the combat log adds what any bot
-- (the CoA classes too) is seen casting. The cooldowns come from the combat log either way.
-- Spells are matched by name (the client's own, so any language), which also catches the CoA versions.

local PREFIX, ICON, MAX_ICONS, MAX_ROWS, NAME_W = "SQBA", 26, 8, 10, 92
local ASK_EVERY, ASK_WAIT, REPLY_FOR, BIG_CD = 30, 4, 4, 180

local STRINGS = {
	en = {
		TITLE = "Key spells", NO_BOT = "No bot of your group has a key spell yet.",
		TIP_CLICK = "Click: %s casts it %s.", ON_TARGET = "on your target, or on you", ON_SELF = "for the group",
		ON_DEAD = "on your dead target", TIP_KEEP = "Right-click: keep it (the bot no longer casts it by itself).",
		TIP_UNKEEP = "Right-click: give it back to the bot.", TIP_KEPT = "Kept: only your click casts it.",
		TIP_READY = "Ready.", TIP_CD = "Cooldown: %d s.", TIP_GUESS = "Guessed from its class: the realm did not list it.",
		NEED_DEAD = "Target the dead player first.", NO_KEEP = "Keeping a spell needs the realm's update (keepcd).",
		CAST = "%s: %s...", KEPT = "%s keeps %s for your click.", FREED = "%s may cast %s by itself again.",
		KEEP_ERR = "%s: cannot keep %s (%s).", R_unknown = "unknown spell", R_off = "option off",
		B_BAR = "Key spells bar",
	},
	fr = {
		TITLE = "Sorts clés", NO_BOT = "Aucun bot du groupe n'a encore de sort clé.",
		TIP_CLICK = "Clic : %s le lance %s.", ON_TARGET = "sur votre cible, ou sur vous", ON_SELF = "pour le groupe",
		ON_DEAD = "sur votre cible morte", TIP_KEEP = "Clic droit : le garder (le bot ne le lance plus de lui-même).",
		TIP_UNKEEP = "Clic droit : le rendre au bot.", TIP_KEPT = "Gardé : seul votre clic le lance.",
		TIP_READY = "Prêt.", TIP_CD = "Recharge : %d s.", TIP_GUESS = "Déduit de sa classe : le royaume ne l'a pas listé.",
		NEED_DEAD = "Ciblez d'abord le joueur mort.", NO_KEEP = "Garder un sort demande la mise à jour du royaume (keepcd).",
		CAST = "%s : %s...", KEPT = "%s garde %s pour votre clic.", FREED = "%s peut de nouveau lancer %s de lui-même.",
		KEEP_ERR = "%s : impossible de garder %s (%s).", R_unknown = "sort inconnu", R_off = "option désactivée",
		B_BAR = "Barre des sorts clés",
	},
}

local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Manager|r: " .. text)
end

-- The key spells: WotLK id, base cooldown (s), how it is aimed, and the class and level that give it (nil: a
-- talent, never guessed). aim: "ally" = your friendly target or you, "self" = the bot (group spells), "dead".
local KEYS = {
	{ 2825, 300, "self", "SHAMAN", 70, "Horde" },     -- Bloodlust
	{ 32182, 300, "self", "SHAMAN", 70, "Alliance" }, -- Heroism
	{ 29166, 180, "ally", "DRUID", 40 },              -- Innervate
	{ 10060, 120, "ally" },                           -- Power Infusion
	{ 20484, 600, "dead", "DRUID", 20 },              -- Rebirth
	{ 61999, 600, "dead", "DEATHKNIGHT", 72 },        -- Raise Ally
	{ 633, 1200, "ally", "PALADIN", 10 },             -- Lay on Hands
	{ 1022, 300, "ally", "PALADIN", 10 },             -- Hand of Protection
	{ 6940, 120, "ally", "PALADIN", 46 },             -- Hand of Sacrifice
	{ 31821, 120, "self" },                           -- Aura Mastery
	{ 64843, 480, "self", "PRIEST", 80 },             -- Divine Hymn
	{ 64901, 360, "self", "PRIEST", 60 },             -- Hymn of Hope
	{ 47788, 180, "ally" },                           -- Guardian Spirit
	{ 33206, 180, "ally" },                           -- Pain Suppression
	{ 16190, 300, "self" },                           -- Mana Tide Totem
	{ 740, 480, "self", "DRUID", 30 },                -- Tranquility
	{ 34477, 30, "ally", "HUNTER", 70 },              -- Misdirection
	{ 57934, 30, "ally", "ROGUE", 75 },               -- Tricks of the Trade
}

-- ks.bots[name] = { server = { [spellName] = entry } or nil, seen = { [spellName] = entry }, asked, pending }
-- entry = { id, name, icon, aim, total, readyAt, kept, order, guess }
local ks = { bots = {}, byName = nil, status = nil, lastCast = {} }
SquidBotsLite_KeySpells = ks

local function KeyByName()
	if ks.byName then return ks.byName end
	local by = {}
	for order, key in ipairs(KEYS) do
		local name, _, icon = GetSpellInfo(key[1])
		if name then by[name] = { id = key[1], name = name, icon = icon, total = key[2], aim = key[3], class = key[4],
			level = key[5], faction = key[6], order = order } end
	end
	ks.byName = by
	return by
end

local function GroupUnits()
	local units = {}
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do table.insert(units, "raid" .. i) end
	else
		for i = 1, GetNumPartyMembers() do table.insert(units, "party" .. i) end
	end
	return units
end

local function IsBot(name)
	return name and SquidBotsLite_IsBot and SquidBotsLite_IsBot(name) and true or false
end

-- The group's bots, in group order.
function ks.Bots()
	local list = {}
	for _, unit in ipairs(GroupUnits()) do
		local name = UnitName(unit)
		if name and name ~= UnitName("player") and IsBot(name) then table.insert(list, { name = name, unit = unit }) end
	end
	return list
end

local function Bot(name)
	local b = ks.bots[name]
	if not b then
		b = { seen = {} }
		ks.bots[name] = b
	end
	return b
end

local function Copy(key, id)
	local name, _, icon = GetSpellInfo(id or key.id)
	return { id = id or key.id, name = name or key.name, icon = icon or key.icon, total = key.total, aim = key.aim, order = key.order }
end

-- The spells shown for a bot: the realm's list when it answered; else what its class and level give, plus
-- what it was seen casting.
function ks.Spells(name, unit)
	local b, by, list = Bot(name), KeyByName(), {}
	if b.server then
		for _, e in pairs(b.server) do table.insert(list, e) end
	else
		local have = {}
		local _, token = UnitClass(unit or name)
		local level, faction = UnitLevel(unit or name) or 0, UnitFactionGroup(unit or name)
		for _, key in pairs(by) do
			if key.class and key.class == token and level >= key.level and (not key.faction or key.faction == faction) then
				-- A guess until the combat log shows it cast (ks.OnCast clears the flag).
				if not b.seen[key.name] then
					b.seen[key.name] = Copy(key)
					b.seen[key.name].guess = true
				end
				have[key.name] = true
			end
		end
		for spell, e in pairs(b.seen) do
			if have[spell] or not e.guess then table.insert(list, e) end
		end
	end
	table.sort(list, function(x, y) return (x.order or 99) < (y.order or 99) or ((x.order or 99) == (y.order or 99) and x.name < y.name) end)
	while #list > MAX_ICONS do table.remove(list) end
	return list
end

local function Changed()
	ks.dirty = true
end

-- The realm's list, asked every ASK_EVERY seconds while the bar is up (and at once when it opens).
function ks.Ask(force)
	local now = GetTime()
	for _, bot in ipairs(ks.Bots()) do
		local b = Bot(bot.name)
		if force or not b.asked or now - b.asked > ASK_EVERY then
			b.asked, b.pending = now, nil
			SendAddonMessage(PREFIX, "keyspells", "WHISPER", bot.name)
		end
	end
end

function ks.OnAddon(sender, message)
	local f = {}
	for field in ((message or "") .. "\t"):gmatch("([^\t]*)\t") do table.insert(f, field) end
	local b = ks.bots[sender]
	if not b then return end
	if f[1] == "KSPELL" then
		if f[2] == "it" then
			local id = tonumber(f[3])
			local name, _, icon = GetSpellInfo(id or 0)
			if not name then return end
			local key = KeyByName()[name]
			local total = (tonumber(f[5]) or 0) / 1000
			-- Not a key spell: shown only when it is a big cooldown (a CoA class's own).
			if not key and total < BIG_CD then return end
			b.pending = b.pending or {}
			b.pending[name] = { id = id, name = name, icon = icon, aim = key and key.aim or "self", order = key and key.order or 50,
				total = total > 0 and total or (key and key.total) or 0, readyAt = GetTime() + (tonumber(f[4]) or 0) / 1000, kept = f[6] == "1" }
		elseif f[2] == "-" then
			b.server = b.pending or {}
			b.pending = nil
			-- The keeps saved for this bot, sent again (the realm forgets them at logout).
			local saved = SquidBotsLiteDB and SquidBotsLiteDB.keepcd and SquidBotsLiteDB.keepcd[sender]
			for spell in pairs(saved or {}) do
				local e = b.server[spell]
				if e and not e.kept then SendAddonMessage(PREFIX, "keepcd " .. e.id .. " on", "WHISPER", sender) end
			end
			Changed()
		elseif f[2] == "err" then
			b.server, b.pending = nil, nil
			Changed()
		end
	elseif f[1] == "KCD" then
		local id = tonumber(f[3]) or 0
		local name = GetSpellInfo(id)
		local e = name and b.server and b.server[name]
		if f[2] == "done" and name then
			local on = f[4] == "1"
			if e then e.kept = on end
			SquidBotsLiteDB.keepcd = SquidBotsLiteDB.keepcd or {}
			SquidBotsLiteDB.keepcd[sender] = SquidBotsLiteDB.keepcd[sender] or {}
			SquidBotsLiteDB.keepcd[sender][name] = on or nil
			ks.Say(string.format(T(on and "KEPT" or "FREED"), sender, name))
		elseif f[2] == "err" then
			ks.Say(string.format(T("KEEP_ERR"), sender, name or id, T("R_" .. (f[4] or "unknown"))))
		end
		Changed()
	end
end

-- The combat log: a bot of the group casts a key spell (its click or its own choice): cooldown starts.
function ks.OnCast(sourceName, spellId, spellName)
	if not sourceName or not ks.bots[sourceName] and not IsBot(sourceName) then return end
	local key = KeyByName()[spellName]
	local b = Bot(sourceName)
	local e = b.server and b.server[spellName] or b.seen[spellName]
	if not e then
		if not key then return end
		e = Copy(key, spellId)
		if b.server then b.server[spellName] = e else b.seen[spellName] = e end
	end
	e.guess = nil
	e.readyAt = GetTime() + (e.total or 0)
	Changed()
end

-- The bot's answer to a cast it could not do ("Cannot cast ...", "Unknown spell ..."): said on the bar.
function ks.OnWhisper(sender, message)
	local at = ks.lastCast[sender]
	if not at or GetTime() - at > REPLY_FOR or not message then return end
	if message:find("^Cannot cast") or message:find("^Unknown spell") then
		ks.Say(sender .. ": " .. message)
		ks.lastCast[sender] = nil
	end
end

function ks.Say(text)
	ks.status = text
	Print(text)
	Changed()
end

-- A click: the bot casts it. Helpful spells on your friendly target (a player), else on you; group spells on the
-- bot itself (so an enemy target never turns it around); a res on your dead target.
function ks.Cast(bot, e)
	local on
	if e.aim == "dead" then
		if not (UnitExists("target") and UnitIsPlayer("target") and UnitIsDeadOrGhost("target") and UnitIsFriend("player", "target")) then
			ks.Say(T("NEED_DEAD"))
			return
		end
		on = UnitName("target")
	elseif e.aim == "ally" then
		if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") and not UnitIsDeadOrGhost("target") then
			on = UnitName("target")
		else
			on = UnitName("player")
		end
	else
		on = bot
	end
	ks.lastCast[bot] = GetTime()
	-- The spell's link: the server reads its id (any client language), then casts the bot's best rank of it.
	SendChatMessage("cast " .. (GetSpellLink(e.id) or e.id) .. " on " .. on, "WHISPER", nil, bot)
	ks.status = string.format(T("CAST"), bot, e.name)
	Changed()
end

function ks.Keep(bot, e)
	local b = Bot(bot)
	if not b.server or not b.server[e.name] then
		ks.Say(T("NO_KEEP"))
		return
	end
	SendAddonMessage(PREFIX, "keepcd " .. e.id .. " " .. (e.kept and "off" or "on"), "WHISPER", bot)
end

-- The rows to draw: bots with at least one key spell.
function ks.Rows()
	local rows = {}
	for _, bot in ipairs(ks.Bots()) do
		local spells = ks.Spells(bot.name, bot.unit)
		if #spells > 0 then table.insert(rows, { name = bot.name, unit = bot.unit, spells = spells }) end
		if #rows >= MAX_ROWS then break end
	end
	return rows
end

-- The frame.
local frame

local function ClassName(name, unit)
	local token = unit and select(2, UnitClass(unit))
	local color = token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
	if not color then return name end
	return string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, name)
end

local function Tooltip(self)
	local e, bot = self.entry, self.bot
	if not e then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("spell:" .. e.id)
	local where = e.aim == "dead" and T("ON_DEAD") or e.aim == "ally" and T("ON_TARGET") or T("ON_SELF")
	GameTooltip:AddLine(string.format(T("TIP_CLICK"), bot, where), 0.4, 0.8, 1, true)
	local left = (e.readyAt or 0) - GetTime()
	GameTooltip:AddLine(left > 0 and string.format(T("TIP_CD"), math.ceil(left)) or T("TIP_READY"), 1, 1, 1)
	if e.kept then GameTooltip:AddLine(T("TIP_KEPT"), 1, 0.6, 0.2, true) end
	if e.guess then GameTooltip:AddLine(T("TIP_GUESS"), 0.6, 0.6, 0.6, true) end
	local b = ks.bots[bot]
	if b and b.server and b.server[e.name] then GameTooltip:AddLine(T(e.kept and "TIP_UNKEEP" or "TIP_KEEP"), 0.6, 0.6, 0.6, true) end
	GameTooltip:Show()
end

local function Build()
	frame = CreateFrame("Frame", "SquidBotsLiteKeySpells", UIParent)
	frame:SetWidth(NAME_W + MAX_ICONS * (ICON + 3) + 20)
	frame:SetHeight(60)
	frame:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
	frame:SetBackdropColor(0, 0, 0, 0.75)
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relative, x, y = self:GetPoint()
		SquidBotsLiteDB.keyBar = { point, relative, x, y }
	end)
	local saved = SquidBotsLiteDB.keyBar
	if saved then frame:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4]) else frame:SetPoint("CENTER", 0, -180) end
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.title:SetPoint("TOPLEFT", 8, -7)
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetWidth(20)
	close:SetHeight(20)
	close:SetPoint("TOPRIGHT", 0, 0)
	frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.status:SetPoint("BOTTOMLEFT", 8, 6)
	frame.status:SetPoint("BOTTOMRIGHT", -8, 6)
	frame.status:SetJustifyH("LEFT")
	frame.rows = {}
	for r = 1, MAX_ROWS do
		local row = { buttons = {} }
		row.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetWidth(NAME_W - 4)
		row.label:SetJustifyH("LEFT")
		row.label:SetPoint("TOPLEFT", 8, -22 - (r - 1) * (ICON + 3) - 7)
		for i = 1, MAX_ICONS do
			local b = CreateFrame("Button", nil, frame)
			b:SetWidth(ICON)
			b:SetHeight(ICON)
			b:SetPoint("TOPLEFT", 8 + NAME_W + (i - 1) * (ICON + 3), -22 - (r - 1) * (ICON + 3))
			b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			b.icon = b:CreateTexture(nil, "ARTWORK")
			b.icon:SetAllPoints()
			b.cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
			b.cd:SetAllPoints()
			b.lock = b:CreateTexture(nil, "OVERLAY")
			b.lock:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
			b.lock:SetWidth(14)
			b.lock:SetHeight(14)
			b.lock:SetPoint("TOPRIGHT", 3, 3)
			b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
			b:SetScript("OnClick", function(self, button)
				if not self.entry then return end
				if button == "RightButton" then ks.Keep(self.bot, self.entry) else ks.Cast(self.bot, self.entry) end
			end)
			b:SetScript("OnEnter", Tooltip)
			b:SetScript("OnLeave", function() GameTooltip:Hide() end)
			row.buttons[i] = b
		end
		frame.rows[r] = row
	end
	frame:SetScript("OnShow", function() ks.Ask(true); Changed() end)
	local since = 0
	frame:SetScript("OnUpdate", function(_, elapsed)
		since = since + elapsed
		if since < 0.5 then return end
		since = 0
		ks.Ask()
		if ks.dirty then ks.Draw() end
	end)
end

function ks.Draw()
	ks.dirty = nil
	if not frame then return end
	frame.title:SetText(T("TITLE"))
	local rows = ks.Rows()
	for r, row in ipairs(frame.rows) do
		local data = rows[r]
		row.label:SetText(data and ClassName(data.name, data.unit) or "")
		for i, b in ipairs(row.buttons) do
			local e = data and data.spells[i]
			b.entry, b.bot = e, data and data.name
			if e then
				b.icon:SetTexture(e.icon)
				b.icon:SetDesaturated(e.guess and true or false)
				local left = (e.readyAt or 0) - GetTime()
				if left > 0 and (e.total or 0) > 0 then b.cd:SetCooldown(e.readyAt - e.total, e.total) else b.cd:SetCooldown(0, 0) end
				if e.kept then b.lock:Show() else b.lock:Hide() end
				b:Show()
			else
				b:Hide()
			end
		end
	end
	frame.status:SetText(#rows == 0 and T("NO_BOT") or ks.status or "")
	frame:SetHeight(22 + math.max(#rows, 1) * (ICON + 3) + 22)
end

function SquidBotsLite_ToggleKeySpells()
	if not SquidBotsLiteDB then return end
	if not frame then Build() end
	if frame:IsShown() then frame:Hide() else frame:Show() end
	SquidBotsLiteDB.keyBarShown = frame:IsShown()
end

BINDING_NAME_SQUIDBOTSLITE_KEYS = T("B_BAR")

local events = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_LOGIN", "CHAT_MSG_ADDON", "CHAT_MSG_WHISPER", "COMBAT_LOG_EVENT_UNFILTERED",
	"PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE" }) do
	events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub, _, sourceName, _, _, _, _, spellId, spellName = ...
		if sub == "SPELL_CAST_SUCCESS" or sub == "SPELL_RESURRECT" then ks.OnCast(sourceName, spellId, spellName) end
	elseif event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if prefix == PREFIX and channel == "WHISPER" then ks.OnAddon(sender, message) end
	elseif event == "CHAT_MSG_WHISPER" then
		local message, sender = ...
		ks.OnWhisper(sender, message)
	elseif event == "PLAYER_LOGIN" then
		BINDING_NAME_SQUIDBOTSLITE_KEYS = T("B_BAR")
		if SquidBotsLiteDB and SquidBotsLiteDB.keyBarShown then SquidBotsLite_ToggleKeySpells() end
	else
		Changed()
	end
end)
