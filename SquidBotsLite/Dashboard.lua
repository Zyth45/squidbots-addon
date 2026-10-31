-- SquidBots Lite, the alts dashboard (CoA Bots 2.8.4): the whole team in one window. On top, a band: alts logged
-- in, alts out on a mission, the team's gold, what needs doing. Then a card per alt of the account: class, level,
-- xp, gold, state, its mission (Recall) or Send, its professions with the next rank a trainer teaches, its alerts.
-- Contract: release/v2.8.4/CONTRAT-ALTS-2.8.4.md, section 11. Each logged-in alt sends (prefix "SQBA"):
--   STAT <level> <xp> <xp of the level, 0 at the cap> <copper> <free bag slots> <bag slots> <lowest durability %>
--        <class id> <rested xp>                                               (looked at every 30 s, sent on change)
--   PROF <free primary profession slots> <skill>:<value>:<max>:<rank>:<next rank>:<its level>,...   (every 10 s)
-- after HELLO, and on "sheet" (sent by Refresh, only when HELLO's 5th field said the server knows it).
-- What an alt sent last is kept in SquidBotsLiteDB.dashboard[realm][name] with the time: offline, its card shows it.

local A, M, UI = SquidBotsLite_Alts, SquidBotsLite_Missions, SquidBotsLite_UI

local STRINGS = {
	en = {
		TITLE = "Alts Dashboard", SUB = "SquidBots Lite  ·  %s", REFRESH = "Refresh",
		TIP_REFRESH = "Ask each alt logged in for its level, gold, bags and professions again.",
		ONLINE = "Logged in", OUT = "On a mission", GOLD = "Team gold", ALERTS = "To do",
		TIP_GOLD = "Your alts' gold: the last amount each one sent for those logged out.", NONE = "Nothing",
		ALERT_COUNT = "%d bags  ·  %d gear  ·  %d trainer",
		EMPTY = "No alt known yet: open My alts (or log one in) and your alts appear here.",
		MORE = "Mouse wheel: %d more", NO_DATA = "No data yet: log it in once",
		ST_follow = "Follows", ST_stay = "Stays", ST_far = "Far", ST_dead = "Dead", ST_mission = "On a mission",
		ST_offline = "Offline", ST_online = "Logged in",
		SEEN = "Last seen %s", FREE = "Free: no mission", LEVEL = "Level %d", MAX_LEVEL = "Max level",
		M_WORK = "%s in %s  ·  %d min  ·  %d items", M_TRAVEL = "On the way to %s  ·  %d min", M_DELIVER = "Mailing the loot  ·  %d items",
		SEND = "Send on a mission", TIP_SEND = "%s, %d min (the choice of the Missions window). Full: %d/%d alts out.",
		RECALL = "Recall", TIP_RECALL = "Ends its mission: it comes back and mails what it gathered.",
		AUTO = "its gathering skill", FULL = "Already %d alts out on a mission.",
		NEXT_GO = "%s: see a trainer", NEXT_LEVEL = "%s: level %d needed", TOP = "Highest rank",
		A_BAGS = "Bags full", A_BAGS_LOW = "Bags almost full (%d left)", A_DURA = "Durability %d%%: repair",
		A_TRAIN = "%s: %s at the trainer", A_SLOTS = "No room for another primary profession (%d/%d)",
		ENCH = "Disenchanter of the team", BAGS = "Bags %d/%d", DURA = "Lowest durability %d%%", XP = "XP %d / %d (%d%%)",
		RESTED = "rested +%d%%", CLICK = "Click: its bot sheet.", OFFLINE_DATA = "Last data: %s",
		PROFS = "Professions",
	},
	fr = {
		TITLE = "Dashboard Alts", SUB = "SquidBots Lite  ·  %s", REFRESH = "Actualiser",
		TIP_REFRESH = "Redemander à chaque alt connecté son niveau, son or, ses sacs et ses métiers.",
		ONLINE = "Connectés", OUT = "En mission", GOLD = "Or de l'équipe", ALERTS = "À faire",
		TIP_GOLD = "L'or de vos alts : le dernier montant connu pour ceux qui sont déconnectés.", NONE = "Rien",
		ALERT_COUNT = "%d sacs  ·  %d équip.  ·  %d entraîneur",
		EMPTY = "Aucun alt connu : ouvrez Mes alts (ou connectez-en un) et vos alts apparaissent ici.",
		MORE = "Molette : %d de plus", NO_DATA = "Pas encore de données : connectez-le une fois",
		ST_follow = "Suit", ST_stay = "Reste", ST_far = "Loin", ST_dead = "Mort", ST_mission = "En mission",
		ST_offline = "Hors ligne", ST_online = "Connecté",
		SEEN = "Vu le %s", FREE = "Libre : pas de mission", LEVEL = "Niveau %d", MAX_LEVEL = "Niveau max",
		M_WORK = "%s à %s  ·  %d min  ·  %d objets", M_TRAVEL = "En route vers %s  ·  %d min", M_DELIVER = "Envoi du butin  ·  %d objets",
		SEND = "Envoyer en mission", TIP_SEND = "%s, %d min (le choix de la fenêtre Missions). Plein : %d/%d alts partis.",
		RECALL = "Rappeler", TIP_RECALL = "Arrête sa mission : il revient et poste ce qu'il a récolté.",
		AUTO = "son métier de récolte", FULL = "Déjà %d alts en mission.",
		NEXT_GO = "%s : va voir un entraîneur", NEXT_LEVEL = "%s : niveau %d requis", TOP = "Rang le plus haut",
		A_BAGS = "Sacs pleins", A_BAGS_LOW = "Sacs presque pleins (%d places)", A_DURA = "Durabilité %d %% : à réparer",
		A_TRAIN = "%s : %s chez l'entraîneur", A_SLOTS = "Plus de place pour un métier principal (%d/%d)",
		ENCH = "Désenchanteur de l'équipe", BAGS = "Sacs %d/%d", DURA = "Durabilité la plus basse %d %%", XP = "XP %d / %d (%d %%)",
		RESTED = "reposé +%d %%", CLICK = "Clic : sa fiche de bot.", OFFLINE_DATA = "Dernières données : %s",
		PROFS = "Métiers",
	},
}
local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

-- The profession ranks (the server's step, 1 = Apprentice).
local RANKS = {
	en = { "Apprentice", "Journeyman", "Expert", "Artisan", "Master", "Grand Master" },
	fr = { "Apprenti", "Compagnon", "Expert", "Artisan", "Maître", "Grand maître" },
}
local function Rank(step)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (RANKS[lang] or RANKS.en)[step] or tostring(step)
end

local PRIMARY = { [171] = true, [164] = true, [333] = true, [202] = true, [182] = true, [773] = true, [755] = true,
	[165] = true, [186] = true, [393] = true, [197] = true }
local SKILL_ICON = { [171] = "Trade_Alchemy", [164] = "Trade_BlackSmithing", [333] = "Trade_Engraving",
	[202] = "Trade_Engineering", [182] = "Trade_Herbalism", [773] = "INV_Inscription_Tradeskill01",
	[755] = "INV_Misc_Gem_01", [165] = "Trade_LeatherWorking", [186] = "Trade_Mining", [393] = "INV_Misc_Pelt_Wolf_01",
	[197] = "Trade_Tailoring", [185] = "INV_Misc_Food_15", [129] = "Spell_Holy_SealOfSacrifice", [356] = "Trade_Fishing" }
-- The class id of STAT, for an alt never seen in the group (CoA's own classes: their token comes from the group).
local CLASS_TOKEN = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", nil, "DRUID" }

-- The colours of the addon (Alts.lua, Missions.lua).
local GREEN, GOLD, ORANGE, RED, GREY, BLUE = { 0.3, 0.85, 0.3 }, { 1, 0.82, 0 }, { 1, 0.6, 0.1 }, { 1, 0.3, 0.3 },
	{ 0.6, 0.6, 0.6 }, { 0.4, 0.7, 1 }
local STATE_COLOR = { follow = GREEN, stay = BLUE, far = GREY, dead = RED, mission = GOLD, offline = GREY, online = GREEN }
local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
local SEND_ICON, RECALL_ICON = "Interface\\Icons\\Ability_Hunter_Pathfinding", "Interface\\Icons\\INV_Misc_Rune_01"
local LOGO = "Interface\\Icons\\INV_Misc_GroupNeedMore"

local COLS, ROWS, CARD_W, CARD_H, GAP, TOP, PROF_ROWS = 2, 4, 330, 124, 8, 124, 5
local SHEET_WAIT = 0.4

local D = { cards = {}, offset = 0, asks = {} }
SquidBotsLite_Dashboard = D

local function Hex(color)
	return string.format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
end

local function Money(copper)
	copper = tonumber(copper) or 0
	local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
	local parts = {}
	if g > 0 then table.insert(parts, g .. "|TInterface\\MoneyFrame\\UI-GoldIcon:10:10:1:0|t") end
	if s > 0 and g < 100 then table.insert(parts, s .. "|TInterface\\MoneyFrame\\UI-SilverIcon:10:10:1:0|t") end
	if (c > 0 and g == 0) or #parts == 0 then table.insert(parts, c .. "|TInterface\\MoneyFrame\\UI-CopperIcon:10:10:1:0|t") end
	return table.concat(parts, " ")
end

local function Small(fs, size)
	local font = fs:GetFont()
	if font then fs:SetFont(font, size or 9) end
end

local function SkillName(skill)
	local names = A and A.SKILLS
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return names and ((names[lang] or names.en)[skill] or names.en[skill]) or tostring(skill)
end

-- ---------------------------------------------------------------------------
-- What the alts sent, kept per realm
-- ---------------------------------------------------------------------------
function D.Store()
	SquidBotsLiteDB.dashboard = SquidBotsLiteDB.dashboard or {}
	local realm = GetRealmName() or "?"
	SquidBotsLiteDB.dashboard[realm] = SquidBotsLiteDB.dashboard[realm] or {}
	return SquidBotsLiteDB.dashboard[realm]
end

function D.Entry(name)
	local store = D.Store()
	store[name] = store[name] or {}
	return store[name]
end

-- The level each rank asks on this server, from the alts' PROF: the player's own card uses it.
local function NoteRankLevel(step, level)
	if step > 0 and level > 0 then
		SquidBotsLiteDB.dashboardRanks = SquidBotsLiteDB.dashboardRanks or {}
		SquidBotsLiteDB.dashboardRanks[step] = level
	end
end

local function NoteClass(name, classId)
	local token = CLASS_TOKEN[classId or 0]
	if not token then return end
	SquidBotsLiteDB.altInfo = SquidBotsLiteDB.altInfo or {}
	local info = SquidBotsLiteDB.altInfo[name] or {}
	if not info.token then
		info.token = token
		info.class = info.class or (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token])
		SquidBotsLiteDB.altInfo[name] = info
	end
end

function D.OnStat(name, f)
	local e = D.Entry(name)
	e.level, e.xp, e.xpMax = tonumber(f[2]), tonumber(f[3]) or 0, tonumber(f[4]) or 0
	e.money, e.free, e.slots = tonumber(f[5]) or 0, tonumber(f[6]), tonumber(f[7])
	e.dura, e.class, e.rest = tonumber(f[8]), tonumber(f[9]), tonumber(f[10]) or 0
	e.at = time()
	NoteClass(name, e.class)
	D.Changed()
end

function D.OnProf(name, f)
	local e = D.Entry(name)
	e.profFree = tonumber(f[2])
	e.profs = {}
	for entry in (f[3] or ""):gmatch("[^,]+") do
		local skill, value, max, step, nextStep, level = entry:match("^(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)$")
		if skill then
			local p = { skill = tonumber(skill), value = tonumber(value), max = tonumber(max), step = tonumber(step),
				next = tonumber(nextStep), level = tonumber(level) }
			NoteRankLevel(p.next, p.level)
			table.insert(e.profs, p)
		end
	end
	e.at = time()
	D.Changed()
end

if A and A.Handle then
	A.Handle.STAT = D.OnStat
	A.Handle.PROF = D.OnProf
end

-- The character played now: its own card when another one of the account is played (game API, no server).
function D.NoteSelf()
	if not SquidBotsLiteDB then return end
	local name = UnitName("player")
	if not name or name == UNKNOWNOBJECT then return end
	local e = D.Entry(name)
	local level = UnitLevel("player")
	e.level = level
	local max = UnitXPMax("player") or 0
	local capped = level >= (MAX_PLAYER_LEVEL or 60)
	e.xp, e.xpMax = capped and 0 or (UnitXP("player") or 0), capped and 0 or max
	e.rest = capped and 0 or (GetXPExhaustion() or 0)
	e.money = GetMoney() or 0
	local free, slots = 0, 0
	for bag = 0, 4 do
		local count = GetContainerNumSlots(bag) or 0
		local freeHere, family = GetContainerNumFreeSlots(bag)
		if count > 0 and (family or 0) == 0 then
			slots = slots + count
			free = free + (freeHere or 0)
		end
	end
	e.free, e.slots = free, slots
	local lowest = 100
	for slot = 1, 18 do
		local cur, top = GetInventoryItemDurability(slot)
		if cur and top and top > 0 then lowest = math.min(lowest, math.floor(cur * 100 / top)) end
	end
	e.dura = lowest
	local _, token = UnitClass("player")
	e.token = token
	-- Its professions, from the skill list (its names, read back to ids); the next rank from what the alts said.
	local byName = {}
	for _, names in pairs(A and A.SKILLS or {}) do
		for id, skillName in pairs(names) do byName[skillName] = id end
	end
	local ranks = SquidBotsLiteDB.dashboardRanks or {}
	e.profs, e.profFree = {}, nil
	local primaries = 0
	for i = 1, (GetNumSkillLines and GetNumSkillLines() or 0) do
		local skillName, header, _, value, _, _, top = GetSkillLineInfo(i)
		local id = not header and byName[skillName]
		if id and (PRIMARY[id] or id == 185 or id == 129 or id == 356) then
			local step = math.min(6, math.floor((top or 0) / 75))
			local nextLevel = ranks[step + 1]
			table.insert(e.profs, { skill = id, value = value or 0, max = top or 0, step = step,
				next = nextLevel and step + 1 or 0, level = nextLevel or 0 })
			if PRIMARY[id] then primaries = primaries + 1 end
		end
	end
	table.sort(e.profs, function(a, b)
		if (PRIMARY[a.skill] and 1 or 0) ~= (PRIMARY[b.skill] and 1 or 0) then return PRIMARY[a.skill] ~= nil end
		return a.skill < b.skill
	end)
	if primaries >= 2 then e.profFree = 0 end
	e.at = time()
end

-- ---------------------------------------------------------------------------
-- The team
-- ---------------------------------------------------------------------------
-- Every alt: logged in first, then the highest level. The player itself is not on the dashboard.
function D.Names()
	local online, list, have = {}, {}, {}
	for _, name in ipairs(A and A.Online() or {}) do online[name] = true end
	local me = UnitName("player")
	local store = D.Store()
	local function Add(name)
		if name and name ~= me and not have[name] then
			have[name] = true
			table.insert(list, name)
		end
	end
	for name in pairs(online) do Add(name) end
	for name in pairs(store) do Add(name) end
	for name in pairs(SquidBotsLiteDB.alts or {}) do Add(name) end
	table.sort(list, function(a, b)
		if (online[a] or false) ~= (online[b] or false) then return online[a] ~= nil end
		local la, lb = (store[a] and store[a].level) or 0, (store[b] and store[b].level) or 0
		if la ~= lb then return la > lb end
		return a < b
	end)
	return list, online
end

function D.Mission(name)
	return SquidBotsLite_MissionOf and SquidBotsLite_MissionOf(name) or nil
end

function D.State(name, online)
	if not online then return "offline" end
	if D.Mission(name) then return "mission" end
	local member = A and A.members[name]
	if member and STATE_COLOR[member.state] then return member.state end
	return "online"
end

-- What needs doing for an alt: { kind = "bags"|"dura"|"train"|"slots", icon, color, text }.
function D.Alerts(name, e)
	local list = {}
	if e.free and e.slots and e.slots > 0 then
		if e.free == 0 then
			table.insert(list, { kind = "bags", icon = "Interface\\Icons\\INV_Misc_Bag_08", color = RED, text = T("A_BAGS") })
		elseif e.free <= 3 then
			table.insert(list, { kind = "bags", icon = "Interface\\Icons\\INV_Misc_Bag_08", color = ORANGE,
				text = string.format(T("A_BAGS_LOW"), e.free) })
		end
	end
	if e.dura and e.dura <= 30 then
		table.insert(list, { kind = "dura", icon = "Interface\\Icons\\Trade_BlackSmithing", color = e.dura <= 10 and RED or ORANGE,
			text = string.format(T("A_DURA"), e.dura) })
	end
	local primaries = 0
	for _, p in ipairs(e.profs or {}) do
		if PRIMARY[p.skill] then primaries = primaries + 1 end
		if p.max > 0 and p.value >= p.max and p.next > 0 and (e.level or 0) >= p.level then
			table.insert(list, { kind = "train", icon = "Interface\\Icons\\INV_Misc_Book_11", color = GOLD,
				text = string.format(T("A_TRAIN"), SkillName(p.skill), Rank(p.next)) })
		end
	end
	if e.profFree == 0 and primaries > 0 then
		table.insert(list, { kind = "slots", icon = "Interface\\Icons\\INV_Misc_Note_01", color = GREY,
			text = string.format(T("A_SLOTS"), primaries, primaries) })
	end
	return list
end

-- ---------------------------------------------------------------------------
-- The window
-- ---------------------------------------------------------------------------
local function Bar(parent, width, height)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetWidth(width)
	bar:SetHeight(height)
	bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
	bar:SetMinMaxValues(0, 1)
	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
	bar.bg:SetVertexColor(1, 1, 1, 0.07)
	bar.bg:SetAllPoints()
	bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bar.text:SetPoint("LEFT", 4, 0)
	bar.text:SetPoint("RIGHT", -4, 0)
	bar.text:SetJustifyH("LEFT")
	Small(bar.text, 9)
	return bar
end

local function Tile(f, i, label)
	local width = (COLS * CARD_W + (COLS - 1) * GAP - 3 * GAP) / 4
	local t = CreateFrame("Frame", nil, f)
	t:SetWidth(width)
	t:SetHeight(48)
	t:SetPoint("TOPLEFT", 16 + (i - 1) * (width + GAP), -64)
	UI.Card(t)
	t.label = t:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	t.label:SetPoint("TOPLEFT", 10, -7)
	t.label:SetText(label)
	t.value = t:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	t.value:SetPoint("TOPLEFT", 10, -22)
	t.value:SetJustifyH("LEFT")
	t.detail = t:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	t.detail:SetPoint("BOTTOMRIGHT", -8, 7)
	t.detail:SetJustifyH("RIGHT")
	Small(t.detail, 9)
	t:SetScript("OnEnter", function(self)
		if not self.tip then return end
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(self.label:GetText(), 1, 0.82, 0)
		for _, line in ipairs(self.tip) do GameTooltip:AddLine(line[1], line[2][1], line[2][2], line[2][3], true) end
		GameTooltip:Show()
	end)
	t:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return t
end

function D.BuildCard(i)
	local f = D.frame
	local c = CreateFrame("Button", nil, f)
	c:SetWidth(CARD_W)
	c:SetHeight(CARD_H)
	UI.Card(c)
	c.icon = c:CreateTexture(nil, "ARTWORK")
	c.icon:SetWidth(34)
	c.icon:SetHeight(34)
	c.icon:SetPoint("TOPLEFT", 8, -8)
	c.star = c:CreateTexture(nil, "OVERLAY")
	c.star:SetWidth(14)
	c.star:SetHeight(14)
	c.star:SetPoint("TOPLEFT", c.icon, "TOPLEFT", -5, 5)
	c.star:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
	c.level = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	c.level:SetPoint("BOTTOMRIGHT", c.icon, "BOTTOMRIGHT", 3, -2)
	c.level:SetFont(c.level:GetFont(), 10, "OUTLINE")
	c.name = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	c.name:SetPoint("TOPLEFT", 50, -8)
	c.name:SetWidth(130)
	c.name:SetHeight(14)
	c.name:SetJustifyH("LEFT")
	c.state = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	c.state:SetPoint("TOPRIGHT", -10, -9)
	-- The alerts: small icons left of the state word.
	c.alerts = {}
	for j = 1, 4 do
		local a = CreateFrame("Frame", nil, c)
		a:SetWidth(14)
		a:SetHeight(14)
		a.icon = a:CreateTexture(nil, "ARTWORK")
		a.icon:SetAllPoints()
		a.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		a.ring = a:CreateTexture(nil, "BACKGROUND")
		a.ring:SetTexture("Interface\\Buttons\\WHITE8X8")
		a.ring:SetPoint("TOPLEFT", -1, 1)
		a.ring:SetPoint("BOTTOMRIGHT", 1, -1)
		if j == 1 then a:SetPoint("RIGHT", c.state, "LEFT", -6, 0) else a:SetPoint("RIGHT", c.alerts[j - 1], "LEFT", -4, 0) end
		a:EnableMouse(true)
		a:SetScript("OnEnter", function(self)
			if not self.alert then return end
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(self.alert.text, self.alert.color[1], self.alert.color[2], self.alert.color[3])
			GameTooltip:Show()
		end)
		a:SetScript("OnLeave", function() GameTooltip:Hide() end)
		c.alerts[j] = a
	end
	c.xp = Bar(c, 150, 10)
	c.xp:SetPoint("TOPLEFT", 50, -26)
	c.xp:SetStatusBarColor(BLUE[1], BLUE[2], BLUE[3], 0.85)
	c.rest = c.xp:CreateTexture(nil, "ARTWORK")
	c.rest:SetTexture("Interface\\Buttons\\WHITE8X8")
	c.rest:SetVertexColor(BLUE[1], BLUE[2], BLUE[3], 0.3)
	c.rest:SetHeight(10)
	c.rest:SetPoint("LEFT", c.xp:GetStatusBarTexture(), "RIGHT", 0, 0)
	c.gold = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	c.gold:SetPoint("TOPRIGHT", -10, -26)
	c.line = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	c.line:SetPoint("TOPLEFT", 50, -42)
	c.line:SetWidth(240)
	c.line:SetHeight(12)
	c.line:SetJustifyH("LEFT")
	Small(c.line, 10)
	c.action = UI.IconButton(c, 18, SEND_ICON, function(self) return self.title, self.tipLine end, function(self)
		if self.run then self.run() end
	end)
	c.action:SetPoint("TOPRIGHT", -10, -39)
	c.rule = c:CreateTexture(nil, "ARTWORK")
	c.rule:SetTexture("Interface\\Buttons\\WHITE8X8")
	c.rule:SetVertexColor(1, 0.82, 0, 0.12)
	c.rule:SetHeight(1)
	c.rule:SetPoint("TOPLEFT", 8, -59)
	c.rule:SetPoint("TOPRIGHT", -8, -59)
	c.empty = c:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	c.empty:SetPoint("TOPLEFT", 10, -68)
	c.profs = {}
	for j = 1, PROF_ROWS do
		local row = CreateFrame("Frame", nil, c)
		row:SetWidth(CARD_W - 16)
		row:SetHeight(10)
		row:SetPoint("TOPLEFT", 8, -65 - (j - 1) * 11)
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(10)
		row.icon:SetHeight(10)
		row.icon:SetPoint("LEFT", 0, 0)
		row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		row.bar = Bar(row, 140, 10)
		row.bar:SetPoint("LEFT", 14, 0)
		row.badge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.badge:SetPoint("LEFT", row.bar, "RIGHT", 8, 0)
		row.badge:SetWidth(CARD_W - 16 - 14 - 140 - 8)
		row.badge:SetHeight(10)
		row.badge:SetJustifyH("LEFT")
		Small(row.badge, 9)
		c.profs[j] = row
	end
	c:RegisterForClicks("LeftButtonUp")
	c:SetScript("OnClick", function(self)
		if self.alt and self.online and SquidBotsLite_OpenSheet then
			D.frame:Hide()
			SquidBotsLite_OpenSheet(self.alt)
		end
	end)
	c:SetScript("OnMouseWheel", function(_, delta) D.Scroll(delta) end)
	c:EnableMouseWheel(true)
	c:HookScript("OnEnter", function(self) D.CardTip(self) end)
	c:HookScript("OnLeave", function() GameTooltip:Hide() end)
	D.cards[i] = c
	return c
end

function D.CardTip(c)
	local name, e = c.alt, c.data
	if not name then return end
	GameTooltip:SetOwner(c, "ANCHOR_RIGHT")
	GameTooltip:SetText(UI.ClassName(name))
	if e and e.level then
		GameTooltip:AddLine(string.format(T("LEVEL"), e.level), 1, 1, 1)
		if e.xpMax and e.xpMax > 0 then
			GameTooltip:AddLine(string.format(T("XP"), e.xp, e.xpMax, math.floor(100 * e.xp / e.xpMax)) ..
				((e.rest or 0) > 0 and ("  " .. string.format(T("RESTED"), math.floor(100 * e.rest / e.xpMax))) or ""), BLUE[1], BLUE[2], BLUE[3])
		end
		if e.slots then GameTooltip:AddLine(string.format(T("BAGS"), e.slots - (e.free or 0), e.slots), 1, 1, 1) end
		if e.dura then GameTooltip:AddLine(string.format(T("DURA"), e.dura), 1, 1, 1) end
	end
	if c.ench then GameTooltip:AddLine(T("ENCH"), BLUE[1], BLUE[2], BLUE[3]) end
	for _, alert in ipairs(c.alertList or {}) do GameTooltip:AddLine(alert.text, alert.color[1], alert.color[2], alert.color[3]) end
	if not c.online and e and e.at then GameTooltip:AddLine(string.format(T("OFFLINE_DATA"), date("%d/%m %H:%M", e.at)), GREY[1], GREY[2], GREY[3]) end
	if c.online and SquidBotsLite_OpenSheet then GameTooltip:AddLine(T("CLICK"), BLUE[1], BLUE[2], BLUE[3]) end
	GameTooltip:Show()
end

function D.Build()
	local width = 16 * 2 + COLS * CARD_W + (COLS - 1) * GAP
	local f = CreateFrame("Frame", "SquidBotsLiteDashboard", UIParent)
	f:SetWidth(width)
	f:SetHeight(TOP + ROWS * (CARD_H + GAP) + 18)
	f:SetBackdrop(BACKDROP)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.96)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relative, x, y = self:GetPoint()
		SquidBotsLiteDB.dashboardAt = { point, relative, x, y }
	end)
	local saved = SquidBotsLiteDB.dashboardAt
	if saved then f:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4]) else f:SetPoint("CENTER") end
	f:EnableMouseWheel(true)
	f:SetScript("OnMouseWheel", function(_, delta) D.Scroll(delta) end)
	table.insert(UISpecialFrames, "SquidBotsLiteDashboard")
	-- The header: the logo and its name.
	f.logo = f:CreateTexture(nil, "ARTWORK")
	f.logo:SetWidth(34)
	f.logo:SetHeight(34)
	f.logo:SetPoint("TOPLEFT", 18, -16)
	f.logo:SetTexture(LOGO)
	f.logo:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.logoRing = f:CreateTexture(nil, "BORDER")
	f.logoRing:SetTexture("Interface\\Buttons\\WHITE8X8")
	f.logoRing:SetVertexColor(1, 0.82, 0, 0.6)
	f.logoRing:SetPoint("TOPLEFT", f.logo, "TOPLEFT", -1, 1)
	f.logoRing:SetPoint("BOTTOMRIGHT", f.logo, "BOTTOMRIGHT", 1, -1)
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	f.title:SetPoint("TOPLEFT", f.logo, "TOPRIGHT", 10, -1)
	f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.sub:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -3)
	f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.close:SetPoint("TOPRIGHT", -4, -4)
	f.refresh = UI.IconButton(f, 22, "Interface\\Buttons\\UI-RefreshButton", function() return T("REFRESH"), T("TIP_REFRESH") end,
		function() D.Ask() end)
	f.refresh.icon:SetTexCoord(0, 1, 0, 1)
	f.refresh:SetPoint("TOPRIGHT", -36, -18)
	UI.Rule(f, -56)
	-- The band: four tiles.
	f.tiles = { Tile(f, 1, ""), Tile(f, 2, ""), Tile(f, 3, ""), Tile(f, 4, "") }
	UI.Rule(f, -118)
	f.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	f.empty:SetPoint("TOP", 0, -TOP - 30)
	f.empty:SetWidth(width - 60)
	f.more = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.more:SetPoint("BOTTOMRIGHT", -18, 10)
	-- The cards take D.frame as their parent: set it before they are built, or they hang off nothing.
	D.frame = f
	for i = 1, COLS * ROWS do
		local c = D.BuildCard(i)
		c:SetPoint("TOPLEFT", f, "TOPLEFT", 16 + ((i - 1) % COLS) * (CARD_W + GAP), -TOP - math.floor((i - 1) / COLS) * (CARD_H + GAP))
	end
	f:SetScript("OnUpdate", function(_, delta) D.OnUpdate(delta) end)
	f:Hide()
	D.frame = f
end

function D.Scroll(delta)
	local rows = math.ceil(#(D.names or {}) / COLS)
	local top = math.max(0, rows - ROWS)
	D.offset = math.max(0, math.min(top, D.offset - delta))
	D.Refresh()
end

local function SetAction(c, icon, enabled, title, line, run)
	UI.SetIcon(c.action, icon, enabled)
	c.action.title, c.action.tipLine, c.action.run = title, line, run
	c.action:Show()
end

function D.FillCard(c, name, online)
	local e = D.Store()[name] or {}
	c.alt, c.online, c.data = name, online, e
	UI.ClassIcon(c.icon, name)
	c.icon:SetDesaturated(not online)
	c.icon:SetAlpha(online and 1 or 0.75)
	c.ench = A and A.ench and A.ench.name == name
	if c.ench then c.star:Show() else c.star:Hide() end
	c.level:SetText(e.level and e.level > 0 and e.level or "")
	c.name:SetText(UI.ClassName(name))
	local state = D.State(name, online)
	local color = STATE_COLOR[state] or GREY
	c.state:SetText(T("ST_" .. state))
	c.state:SetTextColor(color[1], color[2], color[3])
	-- XP: the bar, the rested part after it.
	if e.xpMax and e.xpMax > 0 then
		local part = math.min(1, e.xp / e.xpMax)
		c.xp:SetValue(part)
		c.xp.text:SetText(string.format("%d %%", math.floor(100 * part)))
		local rest = math.min(1 - part, (e.rest or 0) / e.xpMax)
		c.rest:SetWidth(math.max(0.01, rest * 150))
		if rest > 0 then c.rest:Show() else c.rest:Hide() end
		c.xp:Show()
	elseif e.level then
		c.xp:SetValue(1)
		c.xp.text:SetText(T("MAX_LEVEL"))
		c.rest:Hide()
		c.xp:Show()
	else
		c.xp:Hide()
	end
	c.gold:SetText(e.money and Money(e.money) or "")
	-- Its mission, else Send while it is logged in, else when it was seen.
	local mission = online and D.Mission(name)
	c.action:Hide()
	if mission then
		local skill = mission.skill or (SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name])
		local icon = UI.SKILL_ICON[skill]
		local prefix = icon and ("|T" .. icon .. ":12:12:0:0|t ") or ""
		if mission.state == "TRAVEL" then
			c.line:SetText(prefix .. string.format(T("M_TRAVEL"), mission.zone or "?", mission.minutes or 0))
		elseif mission.state == "WORK" then
			local what = M and M.ActivityName and M.ActivityName(skill) or (skill or "?")
			c.line:SetText(prefix .. string.format(T("M_WORK"), what, mission.zone or "?", mission.minutes or 0, mission.items or 0))
		else
			c.line:SetText(prefix .. string.format(T("M_DELIVER"), mission.items or 0))
		end
		c.line:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
		if M and M.Recall then SetAction(c, RECALL_ICON, true, T("RECALL"), T("TIP_RECALL"), function() M.Recall(name) end) end
	elseif online then
		c.line:SetText(T("FREE"))
		c.line:SetTextColor(GREY[1], GREY[2], GREY[3])
		if M and M.Go then
			local out, max = M.Count(), M.MAX_OUT or 4
			local skill, minutes = M.Pick(name), M.Minutes(name)
			local what = skill and M.ActivityName(skill) or T("AUTO")
			SetAction(c, SEND_ICON, out < max, T("SEND"), out < max and string.format(T("TIP_SEND"), what, minutes, out, max)
				or string.format(T("FULL"), out), function() M.Go(name, minutes, skill) end)
		end
	elseif e.at then
		c.line:SetText(string.format(T("SEEN"), date("%d/%m %H:%M", e.at)))
		c.line:SetTextColor(GREY[1], GREY[2], GREY[3])
	else
		c.line:SetText(T("NO_DATA"))
		c.line:SetTextColor(GREY[1], GREY[2], GREY[3])
	end
	-- Alerts, the most urgent on the right.
	c.alertList = D.Alerts(name, e)
	for j, a in ipairs(c.alerts) do
		local alert = c.alertList[j]
		a.alert = alert
		if alert then
			a.icon:SetTexture(alert.icon)
			a.icon:SetDesaturated(alert.color == GREY)
			a.ring:SetVertexColor(alert.color[1], alert.color[2], alert.color[3], 0.9)
			a:Show()
		else
			a:Hide()
		end
	end
	-- Professions: value/max, and at the cap the next rank, with the level it asks.
	local profs = e.profs or {}
	for j, row in ipairs(c.profs) do
		local p = profs[j]
		if p then
			row.icon:SetTexture("Interface\\Icons\\" .. (SKILL_ICON[p.skill] or "INV_Misc_QuestionMark"))
			local part = p.max > 0 and math.min(1, p.value / p.max) or 0
			row.bar:SetValue(part)
			row.bar.text:SetText(SkillName(p.skill) .. "  " .. p.value .. "/" .. p.max)
			local capped = p.max > 0 and p.value >= p.max
			local barColor, badge, badgeColor = GREEN, Rank(p.step), GREY
			if capped and p.next > 0 then
				if (e.level or 0) >= p.level then
					barColor, badge, badgeColor = GOLD, string.format(T("NEXT_GO"), Rank(p.next)), GOLD
				else
					barColor, badge, badgeColor = ORANGE, string.format(T("NEXT_LEVEL"), Rank(p.next), p.level), ORANGE
				end
			elseif capped then
				barColor, badge = GREY, Rank(p.step) .. "  ·  " .. T("TOP")
			end
			row.bar:SetStatusBarColor(barColor[1], barColor[2], barColor[3], 0.75)
			row.badge:SetText(badge)
			row.badge:SetTextColor(badgeColor[1], badgeColor[2], badgeColor[3])
			row:Show()
		else
			row:Hide()
		end
	end
	if #profs == 0 then
		c.empty:SetText("")
		c.empty:Show()
	else
		c.empty:Hide()
	end
	c:Show()
end

function D.Refresh()
	local f = D.frame
	if not f or not f:IsShown() then return end
	f.title:SetText(T("TITLE"))
	f.sub:SetText(string.format(T("SUB"), GetRealmName() or ""))
	local names, online = D.Names()
	D.names = names
	-- The band.
	local store = D.Store()
	local count, out, gold, bags, gear, train = 0, 0, 0, 0, 0, 0
	for _, name in ipairs(names) do
		local e = store[name] or {}
		if online[name] then count = count + 1 end
		if online[name] and D.Mission(name) then out = out + 1 end
		gold = gold + (e.money or 0)
		for _, alert in ipairs(D.Alerts(name, e)) do
			if alert.kind == "bags" then bags = bags + 1
			elseif alert.kind == "dura" then gear = gear + 1
			elseif alert.kind == "train" then train = train + 1 end
		end
	end
	local tiles = f.tiles
	tiles[1].label:SetText(T("ONLINE"))
	tiles[1].value:SetText(count .. " / " .. #names)
	tiles[1].value:SetTextColor(count > 0 and GREEN[1] or GREY[1], count > 0 and GREEN[2] or GREY[2], count > 0 and GREEN[3] or GREY[3])
	tiles[2].label:SetText(T("OUT"))
	tiles[2].value:SetText(out .. " / " .. ((M and M.MAX_OUT) or 4))
	tiles[2].value:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
	tiles[3].label:SetText(T("GOLD"))
	tiles[3].value:SetText(Money(gold))
	tiles[3].value:SetTextColor(1, 1, 1)
	tiles[3].tip = { { T("TIP_GOLD"), { 1, 1, 1 } } }
	tiles[4].label:SetText(T("ALERTS"))
	local alerts = bags + gear + train
	tiles[4].value:SetText(alerts > 0 and alerts or T("NONE"))
	local alertColor = alerts > 0 and RED or GREEN
	tiles[4].value:SetTextColor(alertColor[1], alertColor[2], alertColor[3])
	tiles[4].detail:SetText(alerts > 0 and string.format(T("ALERT_COUNT"), bags, gear, train) or "")
	tiles[4].detail:SetTextColor(RED[1], RED[2], RED[3])
	-- The cards.
	local rows = math.ceil(#names / COLS)
	D.offset = math.max(0, math.min(D.offset, rows - ROWS))
	for i, c in ipairs(D.cards) do
		local name = names[D.offset * COLS + i]
		if name then D.FillCard(c, name, online[name]) else c.alt = nil c:Hide() end
	end
	local hidden = #names - (D.offset * COLS + #D.cards)
	f.more:SetText((hidden > 0 or D.offset > 0) and string.format(T("MORE"), math.max(0, hidden) + D.offset * COLS) or "")
	f.empty:SetText(#names == 0 and T("EMPTY") or "")
end

-- New data: drawn again on the next update, once.
function D.Changed()
	D.dirty = true
end

-- Refresh: STAT and PROF of each alt logged in, one message apart (only when the server knows "sheet").
function D.Ask()
	D.NoteSelf()
	if A and A.hello and A.hello.sheet then
		D.asks = {}
		for _, name in ipairs(A.Online()) do table.insert(D.asks, name) end
		D.nextAsk = GetTime()
	end
	if M and M.Poll then M.Poll() end
	D.Changed()
end

local elapsed = 0
function D.OnUpdate(delta)
	local now = GetTime()
	if D.asks[1] and now >= (D.nextAsk or 0) then
		A.Send(table.remove(D.asks, 1), "sheet")
		D.nextAsk = now + SHEET_WAIT
	end
	elapsed = elapsed + delta
	if elapsed < 1 and not D.dirty then return end
	elapsed, D.dirty = 0, nil
	D.Refresh()
end

function SquidBotsLite_ShowDashboard()
	UI = UI or SquidBotsLite_UI
	A, M = A or SquidBotsLite_Alts, M or SquidBotsLite_Missions
	if not D.frame then D.Build() end
	if D.frame:IsShown() then D.frame:Hide() return end
	-- The Alts window shares the DIALOG strata and its rows sit at higher frame levels: it would cover the cards.
	if SquidBotsLiteAlts and SquidBotsLiteAlts:IsShown() then SquidBotsLiteAlts:Hide() end
	D.frame:Show()
	D.frame:Raise()
	if SquidBotsLite_AskRoster then SquidBotsLite_AskRoster() end
	if M and M.Refresh then M.Refresh() end
	D.Ask()
	D.Refresh()
end

-- Missions keeps polling the alts' missions while the dashboard is open.
if M then M.watcher = function() return D.frame and D.frame:IsShown() end end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:SetScript("OnEvent", function()
	if SquidBotsLiteDB then D.NoteSelf() end
end)
