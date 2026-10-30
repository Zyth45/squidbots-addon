-- SquidBots Lite, the alts as a team (CoA Bots 2.8.3): what each logged-in alt can do with the quest open at a
-- quest giver, what it can learn at the trainer open, the lines it sends back, and a small team bar.
-- Contract with the server: release/v2.8.3/CONTRAT-ALTS-2.8.3.md. Addon messages, prefix "SQBA", tab-separated
-- fields, the first one the type; the alt whispers them to its player (CHAT_MSG_ADDON, "WHISPER", sender = the alt):
--   HELLO 1 <catch-up on 0|1> <quiet mode on 0|1>
--   Q <questId> <can_take|in_log|done|missing_prev|exclusive|level|class_race|reputation|skill|other> <detail> <catchable 0|1>
--   QR <questId> <taken|caught_up|refused|log_full|bags_full|no_giver> <detail>
--   T_BEGIN <npcEntry> <npc name>, T <spellId> <copper> <name>, T_END <count> <total copper> <its money>
--   L <spellId> <ok|too_expensive|failed>, L_END <learned> <spent copper>, T_ERR no_trainer (no trainer found)
-- The addon sends "HELLO\t1" (at login, when an alt comes, then every 5 min): for 15 min the server sends the
-- repetitive lines ("Can't take", "Quest Available", trainer lists) as these messages instead of whispers.
--   TEAM <level> <hp %> <follow|stay|mission|dead|far> <free bag slots> <zoneId>   (on change, at least once a minute)
--   OBJ <questId> <incomplete|complete|failed|done|none> <current>/<needed>,...   (each quest of the player's log)
-- Commands: "quest <id>", "take <id>", "catchup <id>", "train", "learn all", "learn <spellId>".
-- In quiet mode the alts no longer take a quest the player accepts: they send their Q and wait for "take".

local PREFIX, VERSION = "SQBA", 1
local HELLO_EVERY, HELLO_RETRY, SEEN_FOR, OFFLINE_WAIT, TRAIN_WAIT, ACCEPT_WINDOW = 300, 15, 600, 3, 1.5, 6
local LOG_LINES = 200

local STRINGS = {
	en = {
		QUESTS = "Take for the team", TRAINER = "Trainer", LOG = "Alts' log", TEAM = "Team",
		QUEST_N = "Quest #%d", NO_QUEST = "Open a quest at a quest giver: each alt's state shows here.",
		NO_ALTS = "No alt logged in: log one in from My alts.", ASKING = "Asking...", NO_ANSWER = "No answer yet",
		JUST_ME = "Just me", TAKE_TEAM = "Take for the team", TAKE_ALL = "Take for all", CATCH_UP = "Catch up",
		TIP_JUST_ME = "Accept it for you only: your alts do not take it.",
		TIP_TAKE_TEAM = "Each alt that can takes it too; a chain left behind is caught up first if the server allows it.",
		TIP_CATCH_UP = "Marks the earlier quests of the chain as done (no reward, no xp), then takes this one.",
		TIP_REFRESH_Q = "Ask each alt again.", TIP_QUESTS = "Take for the team: each alt's state for a quest, the last one seen.",
		TIP_LOG = "What your alts said: quests taken, chains caught up, recipes learned, refusals.",
		TIP_TEAM = "Show or hide the team bar.",
		STEP = "Step %d of the chain", STEP_FIRST = "Start of a chain", QLEVEL = "Level %d",
		S_can_take = "Can take it", S_in_log = "Already in its quest log (%s)", S_done = "Already turned in",
		IN_incomplete = "in progress", IN_complete = "complete", IN_failed = "failed",
		S_missing_one = "Chain not done: %s missing", S_missing_more = "Chain not done: %d quests missing, from %s",
		S_exclusive = "Took the other branch: %s", S_level_min = "Level %d needed", S_level_range = "For levels %d to %d",
		S_class_race = "Not for its class or race", S_reputation = "Reputation needed: %s", S_skill = "%s %d needed",
		S_other = "Not available (daily done, condition, next quest started...)", CATCHABLE = "can be caught up",
		PILL_can_take = "Can take", PILL_in_log = "In log", PILL_done = "Done", PILL_missing_prev = "Chain",
		PILL_blocked = "Blocked", PILL_wait = "...",
		FACTION = "faction %d", SKILL_N = "Skill %d",
		QR_taken = "%s took %s.", QR_caught_up = "%s caught up the chain of %s (%d quests).",
		QR_refused = "%s cannot take %s: %s.", QR_log_full = "%s: quest log full, %s not taken.",
		QR_bags_full = "%s: bags full, %s not taken.", QR_no_giver = "%s: no quest giver in range for %s, and you do not have it to share.",
		Q_BLOCKED = "%s cannot take %s: %s.",
		TRAINER_OF = "%s", TRAIN_NOTHING = "Nothing to learn here", ERR_no_trainer = "Talk to the trainer first", TRAIN_SUM = "%d to learn: %s", TRAIN_HAS = "has %s",
		TRAIN_MORE = "+ %d more", LEARN_ALL = "Learn all", TIP_LEARN_ALL = "It learns everything listed, in order, while its money lasts.",
		TIP_LEARN_ONE = "Click: learn only this one.", TIP_REFRESH_T = "Ask again. The server lists what the trainer you target teaches.",
		TRAIN_WAIT = "Asking your alts what they can learn here...", POOR = "Not enough money for all of it.",
		L_ok = "%s learned %s.", L_too_expensive = "%s: not enough money for %s.", L_failed = "%s could not learn %s.",
		L_END = "%s learned %d (%s).",
		MODE = "Alts' messages:", MODE_chat = "Chat", MODE_addon = "Addon", MODE_both = "Both",
		TIP_MODE_chat = "Your alts whisper as before (no handshake with the server).",
		TIP_MODE_addon = "The repetitive lines go to these panels and this log only.",
		TIP_MODE_both = "In this log, and the main ones in the chat too.",
		HELLO_ON = "Server: quiet mode on%s.", HELLO_CATCH = ", chains caught up automatically",
		HELLO_NONE = "The server has not answered the handshake: it needs CoA Bots 2.8.3.", HELLO_OFF = "Handshake off: chat mode.",
		CLEAR = "Clear",
		T_SUMMON = "Regroup", T_FOLLOW = "Recall all", T_LEARN = "Learn all", T_REPAIR = "Repair, sell junk",
		TIP_T_SUMMON = "Each logged-in alt teleports next to you.", TIP_T_FOLLOW = "Calls back every alt out on a mission (after a question).",
		TIP_T_LEARN = "At a trainer: each alt learns all it can here.", TIP_T_REPAIR = "At a vendor: each alt repairs and sells its junk (grey items, gear it cannot use).",
		ST_follow = "Follows", ST_stay = "Stays", ST_far = "Far", ST_bags = "Bags full", ST_mission = "Mission %d min", ST_quest = "Quest missing", ST_dead = "Dead", ST_away = "Away", BADGE_MISSION = "On a mission",
		TEAM_EMPTY = "No alt logged in", TIP_TEAM_DRAG = "Drag to move. Click a portrait: its bot sheet.",
	},
	fr = {
		QUESTS = "Prendre pour l'équipe", TRAINER = "Entraîneur", LOG = "Journal des alts", TEAM = "Équipe",
		QUEST_N = "Quête n°%d", NO_QUEST = "Ouvrez une quête chez un PNJ : l'état de chaque alt s'affiche ici.",
		NO_ALTS = "Aucun alt connecté : connectez-en un depuis Mes alts.", ASKING = "Je demande...", NO_ANSWER = "Pas encore de réponse",
		JUST_ME = "Juste moi", TAKE_TEAM = "Prendre pour l'équipe", TAKE_ALL = "Prendre pour tous", CATCH_UP = "Rattraper",
		TIP_JUST_ME = "L'accepter pour vous seul : vos alts ne la prennent pas.",
		TIP_TAKE_TEAM = "Chaque alt qui le peut la prend aussi ; une chaîne en retard est d'abord rattrapée si le serveur le permet.",
		TIP_CATCH_UP = "Marque faites les quêtes d'avant de la chaîne (sans récompense ni XP), puis prend celle-ci.",
		TIP_REFRESH_Q = "Redemander à chaque alt.", TIP_QUESTS = "Prendre pour l'équipe : l'état de chaque alt pour une quête, la dernière vue.",
		TIP_LOG = "Ce que vos alts ont dit : quêtes prises, chaînes rattrapées, recettes apprises, refus.",
		TIP_TEAM = "Afficher ou cacher la barre d'équipe.",
		STEP = "Étape %d de la chaîne", STEP_FIRST = "Début d'une chaîne", QLEVEL = "Niveau %d",
		S_can_take = "Peut la prendre", S_in_log = "Déjà dans son journal (%s)", S_done = "Déjà rendue",
		IN_incomplete = "en cours", IN_complete = "terminée", IN_failed = "échouée",
		S_missing_one = "Chaîne incomplète : il manque %s", S_missing_more = "Chaîne incomplète : %d quêtes manquent, depuis %s",
		S_exclusive = "A pris l'autre branche : %s", S_level_min = "Niveau %d requis", S_level_range = "Pour les niveaux %d à %d",
		S_class_race = "Pas pour sa classe ou sa race", S_reputation = "Réputation requise : %s", S_skill = "%s %d requis",
		S_other = "Indisponible (journalière faite, condition, quête suivante commencée...)", CATCHABLE = "rattrapable",
		PILL_can_take = "Peut prendre", PILL_in_log = "Au journal", PILL_done = "Faite", PILL_missing_prev = "Chaîne",
		PILL_blocked = "Bloqué", PILL_wait = "...",
		FACTION = "faction %d", SKILL_N = "Métier %d",
		QR_taken = "%s a pris %s.", QR_caught_up = "%s a rattrapé la chaîne de %s (%d quêtes).",
		QR_refused = "%s ne peut pas prendre %s : %s.", QR_log_full = "%s : journal de quêtes plein, %s non prise.",
		QR_bags_full = "%s : sacs pleins, %s non prise.", QR_no_giver = "%s : pas de donneur à portée pour %s, et vous ne l'avez pas à partager.",
		Q_BLOCKED = "%s ne peut pas prendre %s : %s.",
		TRAINER_OF = "%s", TRAIN_NOTHING = "Rien à apprendre ici", ERR_no_trainer = "Parle d'abord à l'entraîneur", TRAIN_SUM = "%d à apprendre : %s", TRAIN_HAS = "a %s",
		TRAIN_MORE = "+ %d autres", LEARN_ALL = "Tout apprendre", TIP_LEARN_ALL = "Il apprend toute la liste, dans l'ordre, tant que son argent suffit.",
		TIP_LEARN_ONE = "Clic : apprendre seulement celle-ci.", TIP_REFRESH_T = "Redemander. Le serveur liste ce qu'enseigne l'entraîneur que vous ciblez.",
		TRAIN_WAIT = "Je demande à vos alts ce qu'ils peuvent apprendre ici...", POOR = "Pas assez d'argent pour tout.",
		L_ok = "%s a appris %s.", L_too_expensive = "%s : pas assez d'argent pour %s.", L_failed = "%s n'a pas pu apprendre %s.",
		L_END = "%s a appris %d (%s).",
		MODE = "Messages des alts :", MODE_chat = "Chat", MODE_addon = "Addon", MODE_both = "Les deux",
		TIP_MODE_chat = "Vos alts chuchotent comme avant (pas de poignée de main avec le serveur).",
		TIP_MODE_addon = "Les lignes répétitives vont seulement dans ces panneaux et ce journal.",
		TIP_MODE_both = "Dans ce journal, et les principales aussi dans le chat.",
		HELLO_ON = "Serveur : mode silencieux actif%s.", HELLO_CATCH = ", chaînes rattrapées automatiquement",
		HELLO_NONE = "Le serveur n'a pas répondu à la poignée de main : il faut CoA Bots 2.8.3.", HELLO_OFF = "Poignée de main coupée : mode chat.",
		CLEAR = "Effacer",
		T_SUMMON = "Regrouper", T_FOLLOW = "Rappeler tous", T_LEARN = "Tout apprendre", T_REPAIR = "Réparer, vendre la camelote",
		TIP_T_SUMMON = "Chaque alt connecté se téléporte près de vous.", TIP_T_FOLLOW = "Rappelle tous les alts partis en mission (après une question).",
		TIP_T_LEARN = "Chez un entraîneur : chaque alt apprend tout ce qu'il peut ici.", TIP_T_REPAIR = "Chez un marchand : chaque alt répare et vend sa camelote (objets gris, équipement qu'il ne peut pas porter).",
		ST_follow = "Suit", ST_stay = "Reste", ST_far = "Loin", ST_bags = "Sacs pleins", ST_mission = "Mission %d min", ST_quest = "Quête manquante", ST_dead = "Mort", ST_away = "Absent", BADGE_MISSION = "En mission",
		TEAM_EMPTY = "Aucun alt connecté", TIP_TEAM_DRAG = "Glisser pour déplacer. Clic sur un portrait : sa fiche de bot.",
	},
}
local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

-- Skill ids of the "skill" refusal (SkillLine.dbc), by language.
local SKILLS = {
	en = { [171] = "Alchemy", [164] = "Blacksmithing", [185] = "Cooking", [333] = "Enchanting", [202] = "Engineering",
		[129] = "First Aid", [356] = "Fishing", [182] = "Herbalism", [773] = "Inscription", [755] = "Jewelcrafting",
		[165] = "Leatherworking", [186] = "Mining", [393] = "Skinning", [197] = "Tailoring", [762] = "Riding" },
	fr = { [171] = "Alchimie", [164] = "Forge", [185] = "Cuisine", [333] = "Enchantement", [202] = "Ingénierie",
		[129] = "Secourisme", [356] = "Pêche", [182] = "Herboristerie", [773] = "Calligraphie", [755] = "Joaillerie",
		[165] = "Travail du cuir", [186] = "Minage", [393] = "Dépeçage", [197] = "Couture", [762] = "Monte" },
}

local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
local GREEN, GOLD, ORANGE, RED, GREY, BLUE = { 0.3, 0.85, 0.3 }, { 1, 0.82, 0 }, { 1, 0.6, 0.1 }, { 1, 0.3, 0.3 },
	{ 0.6, 0.6, 0.6 }, { 0.4, 0.7, 1 }
-- Each state: its pill's word and colour, its icon (the client's own: ready check, LFG lock, quest marks).
local STATE = {
	can_take = { "PILL_can_take", GREEN, "Interface\\RaidFrame\\ReadyCheck-Ready" },
	in_log = { "PILL_in_log", BLUE, "Interface\\GossipFrame\\ActiveQuestIcon" },
	done = { "PILL_done", GREY, "Interface\\Buttons\\UI-CheckBox-Check" },
	missing_prev = { "PILL_missing_prev", ORANGE, "Interface\\LFGFrame\\UI-LFG-ICON-LOCK" },
	blocked = { "PILL_blocked", RED, "Interface\\RaidFrame\\ReadyCheck-NotReady" },
	wait = { "PILL_wait", GREY, "Interface\\RaidFrame\\ReadyCheck-Waiting" },
}

-- seen: alts heard from lately (a message, "add: X - ok"); gone: "No player named" after a message to it.
-- quests[id][alt] = { state, detail, catchable, at }; asked[id][alt] = when asked.
-- train[alt] = { npc, list = { { id, cost, name } }, count, total, money, at }.
-- members[alt] = the last TEAM; obj[questId][alt] = { state, done, needed } from OBJ.
local A = { seen = {}, gone = {}, sent = {}, quests = {}, asked = {}, titles = {}, recent = {}, train = {}, journal = {},
	nextHello = 0, members = {}, obj = {} }
-- An alt that sent TEAM and has been silent this long is gone (TEAM comes at least once a minute).
local TEAM_SILENT = 150
local UI = SquidBotsLite_UI

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text)
end

local function IsAlt(name)
	return name and SquidBotsLiteDB and SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[name]
end

local function Mode()
	return SquidBotsLiteDB and SquidBotsLiteDB.altsMessages or "addon"
end

local function GroupUnits()
	local units = {}
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do table.insert(units, "raid" .. i) end
	else
		for i = 1, 4 do table.insert(units, "party" .. i) end
	end
	return units
end

local function UnitOf(name)
	for _, unit in ipairs(GroupUnits()) do
		if UnitName(unit) == name then return unit end
	end
end

-- The alts logged in now: the My alts roster, the alts in the group, those heard from lately.
function A.Online()
	local list, have, now = {}, {}, GetTime()
	local function Add(name, sure)
		if not name or have[name] or name == UnitName("player") then return end
		if not sure and A.gone[name] and A.gone[name] >= (A.seen[name] or 0) then return end
		have[name] = true
		table.insert(list, name)
	end
	for _, unit in ipairs(GroupUnits()) do
		local name = UnitName(unit)
		if IsAlt(name) and UnitIsConnected(unit) then Add(name, true) end
	end
	for _, name in ipairs(SquidBotsLite_OnlineAlts and SquidBotsLite_OnlineAlts() or {}) do Add(name) end
	for name, at in pairs(A.seen) do
		local member = A.members[name]
		if now - at < SEEN_FOR and not (member and now - member.at > TEAM_SILENT) then Add(name) end
	end
	table.sort(list)
	return list
end

local function Send(name, text)
	A.sent[name] = GetTime()
	SendAddonMessage(PREFIX, text, "WHISPER", name)
end

local function Split(message)
	local fields = {}
	for field in (message .. "\t"):gmatch("([^\t]*)\t") do table.insert(fields, field) end
	return fields
end

local function Money(copper)
	copper = tonumber(copper) or 0
	local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
	local parts = {}
	if g > 0 then table.insert(parts, g .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t") end
	if s > 0 then table.insert(parts, s .. "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t") end
	if c > 0 or #parts == 0 then table.insert(parts, c .. "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t") end
	return table.concat(parts, " ")
end

-- A quest's title: the quest frame, the player's log, else the client's cache through a hidden tooltip.
function A.Title(id)
	id = tonumber(id)
	if not id then return "?" end
	if A.titles[id] then return A.titles[id] end
	for i = 1, GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		if link and tonumber(link:match("|Hquest:(%d+)")) == id then
			A.titles[id] = (GetQuestLogTitle(i))
			return A.titles[id]
		end
	end
	A.scan = A.scan or CreateFrame("GameTooltip", "SquidBotsLiteAltsScan", UIParent, "GameTooltipTemplate")
	A.scan:SetOwner(UIParent, "ANCHOR_NONE")
	A.scan:ClearLines()
	pcall(A.scan.SetHyperlink, A.scan, "quest:" .. id)
	local line = _G.SquidBotsLiteAltsScanTextLeft1
	local text = line and line:GetText()
	A.scan:Hide()
	if text and text ~= "" then
		A.titles[id] = text
		return text
	end
	return string.format(T("QUEST_N"), id)
end

local function QuestLink(id)
	return "|cffffff00[" .. A.Title(id) .. "]|r"
end

-- Why an alt cannot take it, in words.
function A.Reason(s)
	if not s then return "" end
	local state, detail = s.state, s.detail or ""
	if state == "can_take" or state == "done" then return T("S_" .. state) end
	if state == "in_log" then return string.format(T("S_in_log"), T("IN_" .. (detail ~= "" and detail or "incomplete"))) end
	if state == "missing_prev" then
		local ids = {}
		for id in detail:gmatch("(%d+)") do table.insert(ids, tonumber(id)) end
		local text
		if #ids <= 1 then
			text = string.format(T("S_missing_one"), ids[1] and A.Title(ids[1]) or "?")
		else
			text = string.format(T("S_missing_more"), #ids, A.Title(ids[#ids]))
		end
		if s.catchable then text = text .. " (" .. T("CATCHABLE") .. ")" end
		return text
	end
	if state == "exclusive" then return string.format(T("S_exclusive"), A.Title(tonumber(detail) or 0)) end
	if state == "level" then
		local min, max = detail:match("^(%d+)%-(%d+)$")
		min, max = tonumber(min) or 0, tonumber(max) or 0
		if max > 0 then return string.format(T("S_level_range"), min, max) end
		return string.format(T("S_level_min"), min)
	end
	if state == "class_race" then return T("S_class_race") end
	if state == "reputation" then
		local id = tonumber(detail) or 0
		local name = GetFactionInfoByID and GetFactionInfoByID(id)
		return string.format(T("S_reputation"), name or string.format(T("FACTION"), id))
	end
	if state == "skill" then
		local id, value = detail:match("^(%d+):(%d+)$")
		id, value = tonumber(id) or 0, tonumber(value) or 0
		local names = SKILLS[SquidBotsLiteDB.lang] or SKILLS.en
		return string.format(T("S_skill"), names[id] or string.format(T("SKILL_N"), id), value)
	end
	return T("S_other")
end

local function StateOf(s)
	if not s then return STATE.wait end
	return STATE[s.state] or STATE.blocked
end

-- ---------------------------------------------------------------------------
-- The log: what the alts said, with the time; the main lines in the chat too in "both" mode
-- ---------------------------------------------------------------------------
function A.Log(text, chat, r, g, b)
	local line = "|cff9d9d9d" .. date("%H:%M") .. "|r  " .. text
	table.insert(A.journal, { line, r or 1, g or 1, b or 1 })
	if #A.journal > LOG_LINES then table.remove(A.journal, 1) end
	if A.logFrame then A.logFrame.lines:AddMessage(line, r or 1, g or 1, b or 1) end
	if chat and Mode() == "both" then Print(text) end
end

function A.BuildLog()
	local f = CreateFrame("Frame", "SquidBotsLiteAltLog", UIParent)
	f:SetWidth(400)
	f:SetHeight(260)
	f:SetPoint("CENTER", 220, -60)
	f:SetBackdrop(BACKDROP)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.96)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteAltLog")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	-- Chat / Addon / Both, the one in use lit.
	f.modeLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.modeLabel:SetPoint("TOPLEFT", 20, -42)
	f.modes = {}
	local previous
	for _, mode in ipairs({ "chat", "addon", "both" }) do
		local button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		button:SetWidth(66)
		button:SetHeight(20)
		if previous then button:SetPoint("LEFT", previous, "RIGHT", 4, 0) else button:SetPoint("LEFT", f.modeLabel, "RIGHT", 8, 0) end
		button:SetScript("OnClick", function()
			SquidBotsLiteDB.altsMessages = mode
			if mode ~= "chat" then A.nextHello = 0 end
			A.RefreshLog()
		end)
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(T("MODE_" .. mode), 1, 0.82, 0)
			GameTooltip:AddLine(T("TIP_MODE_" .. mode), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function() GameTooltip:Hide() end)
		button.mode = mode
		f.modes[mode] = button
		previous = button
	end
	f.clear = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.clear:SetWidth(70)
	f.clear:SetHeight(20)
	f.clear:SetPoint("TOPRIGHT", -18, -38)
	f.clear:SetScript("OnClick", function()
		A.journal = {}
		f.lines:Clear()
	end)
	UI.Rule(f, -64)
	f.lines = CreateFrame("ScrollingMessageFrame", nil, f)
	f.lines:SetPoint("TOPLEFT", 18, -70)
	f.lines:SetPoint("BOTTOMRIGHT", -18, 40)
	f.lines:SetFontObject(GameFontHighlightSmall)
	f.lines:SetJustifyH("LEFT")
	f.lines:SetFading(false)
	f.lines:SetMaxLines(LOG_LINES)
	f.lines:EnableMouseWheel(true)
	f.lines:SetScript("OnMouseWheel", function(self, delta)
		if delta > 0 then self:ScrollUp() else self:ScrollDown() end
	end)
	for _, entry in ipairs(A.journal) do f.lines:AddMessage(entry[1], entry[2], entry[3], entry[4]) end
	local footer = f:CreateTexture(nil, "ARTWORK")
	footer:SetTexture("Interface\\Buttons\\WHITE8X8")
	footer:SetVertexColor(1, 0.82, 0, 0.18)
	footer:SetHeight(1)
	footer:SetPoint("BOTTOMLEFT", 16, 34)
	footer:SetPoint("BOTTOMRIGHT", -16, 34)
	f.status = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.status:SetPoint("BOTTOMLEFT", 18, 16)
	f.status:SetWidth(364)
	f.status:SetJustifyH("LEFT")
	UI.FlattenAll(f)
	f:Hide()
	A.logFrame = f
end

function A.RefreshLog()
	local f = A.logFrame
	if not f or not f:IsShown() then return end
	f.title:SetText("SquidBots Lite - " .. T("LOG"))
	f.modeLabel:SetText(T("MODE"))
	f.clear:SetText(T("CLEAR"))
	for mode, button in pairs(f.modes) do
		button:SetText(T("MODE_" .. mode))
		if Mode() == mode then button:LockHighlight() else button:UnlockHighlight() end
	end
	if Mode() == "chat" then
		f.status:SetText(T("HELLO_OFF"))
	elseif A.hello then
		f.status:SetText(string.format(T("HELLO_ON"), A.hello.catchup and T("HELLO_CATCH") or ""))
	elseif A.helloAt and GetTime() - A.helloAt > 10 then
		f.status:SetText(T("HELLO_NONE"))
	else
		f.status:SetText("")
	end
end

function SquidBotsLite_ShowAltLog()
	if not A.logFrame then A.BuildLog() end
	if A.logFrame:IsShown() then A.logFrame:Hide() return end
	A.logFrame:Show()
	A.logFrame:Raise()
	A.RefreshLog()
end

-- ---------------------------------------------------------------------------
-- Take for the team: next to the quest frame, a card per logged-in alt with its state for the quest open
-- ---------------------------------------------------------------------------
local QROWS, QROW_H, QTOP = 8, 40, 82

local function Pill(row, key, color)
	row.badge:SetText(T(key))
	row.badge:SetTextColor(color[1], color[2], color[3])
	row.pill:SetVertexColor(color[1], color[2], color[3], 0.18)
end

function A.QuestRow(f, i)
	local row = CreateFrame("Frame", nil, f)
	row:SetWidth(308)
	row:SetHeight(QROW_H - 4)
	row:SetPoint("TOPLEFT", 16, -QTOP - (i - 1) * QROW_H)
	row:SetScript("OnEnter", function(self)
		if not self.alt then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(UI.ClassName(self.alt))
		local s = A.quests[A.current] and A.quests[A.current][self.alt]
		if s then
			GameTooltip:AddLine(A.Reason(s), 1, 1, 1, true)
			if s.state == "missing_prev" then
				for id in (s.detail or ""):gmatch("(%d+)") do GameTooltip:AddLine("- " .. A.Title(tonumber(id)), 0.8, 0.8, 0.8) end
			end
		end
		GameTooltip:Show()
	end)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)
	UI.Card(row)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetWidth(28)
	row.icon:SetHeight(28)
	row.icon:SetPoint("LEFT", 6, 0)
	row.state = row:CreateTexture(nil, "OVERLAY")
	row.state:SetWidth(14)
	row.state:SetHeight(14)
	row.state:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 4, -3)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetPoint("TOPLEFT", 42, -5)
	row.name:SetJustifyH("LEFT")
	row.badge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.badge:SetPoint("LEFT", row.name, "RIGHT", 10, 0)
	row.pill = row:CreateTexture(nil, "BORDER")
	row.pill:SetTexture("Interface\\Buttons\\WHITE8X8")
	row.pill:SetPoint("TOPLEFT", row.badge, "TOPLEFT", -4, 2)
	row.pill:SetPoint("BOTTOMRIGHT", row.badge, "BOTTOMRIGHT", 4, -2)
	row.line = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.line:SetPoint("TOPLEFT", 42, -21)
	row.line:SetWidth(180)
	row.line:SetHeight(12)
	row.line:SetJustifyH("LEFT")
	row.line:SetTextColor(0.75, 0.75, 0.75)
	row.catchup = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	row.catchup:SetWidth(78)
	row.catchup:SetHeight(20)
	row.catchup:SetPoint("RIGHT", -6, 0)
	row.catchup:SetScript("OnClick", function(self)
		local name = self:GetParent().alt
		if name and A.current then A.Ask(name, "catchup", A.current) end
	end)
	row.catchup:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(T("CATCH_UP"), 1, 0.82, 0)
		GameTooltip:AddLine(T("TIP_CATCH_UP"), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	row.catchup:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return row
end

local function Panel(name, width)
	local f = CreateFrame("Frame", name, UIParent)
	f:SetWidth(width)
	f:SetPoint("CENTER", 220, 40)
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
		self.moved = true
	end)
	table.insert(UISpecialFrames, name)
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	f.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.empty:SetWidth(width - 40)
	f.empty:SetJustifyH("LEFT")
	return f
end

function A.BuildQuests()
	local f = Panel("SquidBotsLiteAltQuests", 340)
	-- The quest: its name, the chain step and its level; arrows through the quests seen lately.
	f.quest = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.quest:SetPoint("TOP", 0, -38)
	f.quest:SetWidth(250)
	f.quest:SetTextColor(1, 0.82, 0)
	f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.sub:SetPoint("TOP", f.quest, "BOTTOM", 0, -4)
	f.prev = CreateFrame("Button", nil, f)
	f.prev:SetWidth(24)
	f.prev:SetHeight(24)
	f.prev:SetPoint("TOPLEFT", 16, -36)
	f.prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	f.prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	f.prev:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	f.prev:SetScript("OnClick", function() A.Step(-1) end)
	f.next = CreateFrame("Button", nil, f)
	f.next:SetWidth(24)
	f.next:SetHeight(24)
	f.next:SetPoint("TOPRIGHT", -16, -36)
	f.next:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	f.next:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	f.next:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	f.next:SetScript("OnClick", function() A.Step(1) end)
	UI.Rule(f, -74)
	f.empty:SetPoint("TOPLEFT", 20, -QTOP - 8)
	f.rows = {}
	for i = 1, QROWS do f.rows[i] = A.QuestRow(f, i) end
	local footer = f:CreateTexture(nil, "ARTWORK")
	footer:SetTexture("Interface\\Buttons\\WHITE8X8")
	footer:SetVertexColor(1, 0.82, 0, 0.18)
	footer:SetHeight(1)
	footer:SetPoint("BOTTOMLEFT", 16, 42)
	footer:SetPoint("BOTTOMRIGHT", -16, 42)
	-- Just me (accepts it, at a quest giver only) and Take for the team.
	f.me = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.me:SetWidth(96)
	f.me:SetHeight(22)
	f.me:SetPoint("BOTTOMLEFT", 16, 14)
	f.me:SetScript("OnClick", function() if A.detail then AcceptQuest() end end)
	f.team = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.team:SetWidth(160)
	f.team:SetHeight(22)
	f.team:SetPoint("LEFT", f.me, "RIGHT", 6, 0)
	f.team:SetScript("OnClick", function() A.TakeAll() end)
	for _, def in ipairs({ { f.me, "JUST_ME", "TIP_JUST_ME" }, { f.team, "TAKE_TEAM", "TIP_TAKE_TEAM" } }) do
		def[1]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(self:GetText() or T(def[2]), 1, 0.82, 0)
			GameTooltip:AddLine(T(def[3]), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		def[1]:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end
	f.refresh = UI.IconButton(f, 22, "Interface\\Buttons\\UI-RefreshButton", function() return T("QUESTS"), T("TIP_REFRESH_Q") end,
		function() if A.current then A.AskQuest(A.current) end end)
	f.refresh.icon:SetTexCoord(0, 1, 0, 1)
	f.refresh:SetPoint("BOTTOMRIGHT", -18, 14)
	f:SetScript("OnHide", function() A.manualQuests = nil end)
	UI.FlattenAll(f)
	f:Hide()
	A.questPanel = f
end

-- The chain step and the level, from the player's log when the quest is there (3.3.5 gives no chain from an id).
local function QuestSub(id)
	local s = A.quests[id]
	local level
	for i = 1, GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		if link and tonumber(link:match("|Hquest:(%d+)")) == id then level = select(2, GetQuestLogTitle(i)) end
	end
	-- The longest missing list an alt reported gives the step: the quests before this one.
	local before = 0
	for _, state in pairs(s or {}) do
		if state.state == "missing_prev" then
			local n = 0
			for _ in (state.detail or ""):gmatch("(%d+)") do n = n + 1 end
			if n > before then before = n end
		end
	end
	local parts = {}
	if before > 0 then table.insert(parts, string.format(T("STEP"), before + 1)) end
	if level and level > 0 then table.insert(parts, string.format(T("QLEVEL"), level)) end
	return table.concat(parts, "  ·  ")
end

function A.RefreshQuests()
	local f = A.questPanel
	if not f or not f:IsShown() then return end
	f.title:SetText("SquidBots Lite - " .. T("QUESTS"))
	f.me:SetText(T("JUST_ME"))
	f.team:SetText(A.detail and T("TAKE_TEAM") or T("TAKE_ALL"))
	local alts, id = A.Online(), A.current
	f.quest:SetText(id and A.Title(id) or "")
	f.sub:SetText(id and QuestSub(id) or "")
	local index
	for i, recent in ipairs(A.recent) do if recent == id then index = i end end
	if index and index > 1 then f.prev:Enable() else f.prev:Disable() end
	if index and index < #A.recent then f.next:Enable() else f.next:Disable() end
	if #A.recent > 1 then f.prev:Show() f.next:Show() else f.prev:Hide() f.next:Hide() end
	f.empty:SetText(#alts == 0 and T("NO_ALTS") or (not id and T("NO_QUEST")) or "")
	local shown, takers = 0, 0
	for i, row in ipairs(f.rows) do
		local name = id and alts[i]
		if name then
			shown = shown + 1
			row.alt = name
			row.name:SetText(UI.ClassName(name))
			UI.ClassIcon(row.icon, name)
			local s = A.quests[id] and A.quests[id][name]
			local def = StateOf(s)
			local key = def[1]
			Pill(row, key, def[2])
			row.state:SetTexture(def[3])
			if s then
				row.line:SetText(A.Reason(s))
			else
				local asked = A.asked[id] and A.asked[id][name]
				row.line:SetText("|cff9d9d9d" .. ((asked and GetTime() - asked < 5) and T("ASKING") or T("NO_ANSWER")) .. "|r")
			end
			if s and s.state == "missing_prev" and s.catchable then
				row.catchup:SetText(T("CATCH_UP"))
				row.catchup:Show()
			else
				row.catchup:Hide()
			end
			if not s or s.state == "can_take" or (s.state == "missing_prev" and s.catchable) then takers = takers + 1 end
			row:Show()
		else
			row.alt = nil
			row:Hide()
		end
	end
	if id and takers > 0 then f.team:Enable() else f.team:Disable() end
	if A.detail then f.me:Show() else f.me:Hide() end
	f:SetHeight(QTOP + math.max(1, shown) * QROW_H + 52)
end

function A.Step(delta)
	for i, id in ipairs(A.recent) do
		if id == A.current and A.recent[i + delta] then
			A.current = A.recent[i + delta]
			break
		end
	end
	A.RefreshQuests()
end

-- On the right of the frame shown (quest, gossip, trainer), else next to My alts, else where the player left it.
local ANCHORS = { "QuestFrame", "GossipFrame", "ClassTrainerFrame", "TrainerFrame" }
function A.Place(f, manual)
	if f.moved then return end
	f:ClearAllPoints()
	if not manual then
		for _, name in ipairs(ANCHORS) do
			local frame = _G[name]
			if frame and frame:IsShown() then
				f:SetPoint("TOPLEFT", frame, "TOPRIGHT", -30, -12)
				return
			end
		end
	end
	local alts = _G.SquidBotsLiteAlts
	if alts and alts:IsShown() then
		f:SetPoint("TOPLEFT", alts, "TOPRIGHT", 4, 0)
	else
		f:SetPoint("CENTER", 220, 40)
	end
end

function A.ShowQuests(manual)
	if not A.questPanel then A.BuildQuests() end
	local f = A.questPanel
	if manual then A.manualQuests = true end
	if not f:IsShown() then
		A.Place(f, manual)
		f:Show()
	end
	A.RefreshQuests()
end

function A.HideQuests()
	if A.questPanel and A.questPanel:IsShown() and not A.manualQuests then A.questPanel:Hide() end
end

function A.Seen(id)
	A.current = id
	for i, recent in ipairs(A.recent) do
		if recent == id then table.remove(A.recent, i) break end
	end
	table.insert(A.recent, id)
	if #A.recent > 10 then table.remove(A.recent, 1) end
end

function A.Ask(name, command, id)
	A.asked[id] = A.asked[id] or {}
	A.asked[id][name] = GetTime()
	Send(name, command .. " " .. id)
end

function A.AskQuest(id)
	for _, name in ipairs(A.Online()) do A.Ask(name, "quest", id) end
	A.RefreshQuests()
end

-- Every alt that can (or whose state is not known yet) is told "take"; at a quest giver, the player accepts it too.
function A.TakeAll()
	local id = A.current
	if not id then return end
	for _, name in ipairs(A.Online()) do
		local s = A.quests[id] and A.quests[id][name]
		if not s or s.state == "can_take" or (s.state == "missing_prev" and s.catchable) then A.Ask(name, "take", id) end
	end
	if A.detail == id then AcceptQuest() end
end

function SquidBotsLite_ShowAltQuests()
	if A.questPanel and A.questPanel:IsShown() then A.questPanel:Hide() return end
	-- The quest selected in the player's log, if any; else the last one seen.
	local index = GetQuestLogSelection and GetQuestLogSelection()
	local link = index and index > 0 and GetQuestLink(index)
	local id = link and tonumber(link:match("|Hquest:(%d+)"))
	if id then A.Seen(id) end
	A.ShowQuests(true)
	if A.current then A.AskQuest(A.current) end
end

-- ---------------------------------------------------------------------------
-- Trainer: next to the trainer, a card per alt with what it can learn here
-- ---------------------------------------------------------------------------
local TCARDS, TLINES, TLINE_H, TTOP = 6, 8, 14, 66

function A.TrainCard(f, i)
	local card = CreateFrame("Frame", nil, f)
	card:SetWidth(308)
	UI.Card(card)
	card.icon = card:CreateTexture(nil, "ARTWORK")
	card.icon:SetWidth(28)
	card.icon:SetHeight(28)
	card.icon:SetPoint("TOPLEFT", 6, -5)
	card.name = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	card.name:SetPoint("TOPLEFT", 42, -5)
	card.sum = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	card.sum:SetPoint("TOPLEFT", 42, -21)
	card.sum:SetWidth(170)
	card.sum:SetJustifyH("LEFT")
	card.learn = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
	card.learn:SetWidth(92)
	card.learn:SetHeight(20)
	card.learn:SetPoint("TOPRIGHT", -6, -7)
	card.learn:SetScript("OnClick", function(self)
		local name = self:GetParent().alt
		if name then
			Send(name, "learn all")
			self:Disable()
		end
	end)
	card.learn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(T("LEARN_ALL"), 1, 0.82, 0)
		GameTooltip:AddLine(T("TIP_LEARN_ALL"), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	card.learn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	card.lines = {}
	for j = 1, TLINES do
		local line = CreateFrame("Button", nil, card)
		line:SetHeight(TLINE_H)
		line:SetPoint("TOPLEFT", 42, -36 - (j - 1) * TLINE_H)
		line:SetPoint("RIGHT", card, "RIGHT", -8, 0)
		line:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
		line:GetHighlightTexture():SetVertexColor(1, 0.82, 0, 0.12)
		line.text = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		line.text:SetPoint("LEFT", 0, 0)
		line.text:SetWidth(180)
		line.text:SetJustifyH("LEFT")
		line.cost = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		line.cost:SetPoint("RIGHT", 0, 0)
		line:SetScript("OnClick", function(self)
			local name = card.alt
			if name and self.spell then Send(name, "learn " .. self.spell) end
		end)
		line:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if self.spell and GetSpellInfo(self.spell) then
				pcall(GameTooltip.SetHyperlink, GameTooltip, "spell:" .. self.spell)
			else
				GameTooltip:SetText(self.text:GetText() or "")
			end
			GameTooltip:AddLine(T("TIP_LEARN_ONE"), 0.4, 0.8, 1)
			GameTooltip:Show()
		end)
		line:SetScript("OnLeave", function() GameTooltip:Hide() end)
		card.lines[j] = line
	end
	card.more = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	card:Hide()
	return card
end

function A.BuildTrainer()
	local f = Panel("SquidBotsLiteAltTrainer", 340)
	f.npc = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.npc:SetPoint("TOP", 0, -38)
	f.npc:SetTextColor(1, 0.82, 0)
	UI.Rule(f, -58)
	f.empty:SetPoint("TOPLEFT", 20, -TTOP - 4)
	f.cards = {}
	for i = 1, TCARDS do f.cards[i] = A.TrainCard(f, i) end
	f.refresh = UI.IconButton(f, 22, "Interface\\Buttons\\UI-RefreshButton", function() return T("TRAINER"), T("TIP_REFRESH_T") end,
		function() A.AskTrain() end)
	f.refresh.icon:SetTexCoord(0, 1, 0, 1)
	f.refresh:SetPoint("BOTTOMRIGHT", -18, 14)
	f:SetScript("OnHide", function() A.manualTrainer = nil end)
	UI.FlattenAll(f)
	f:Hide()
	A.trainPanel = f
end

function A.RefreshTrainer()
	local f = A.trainPanel
	if not f or not f:IsShown() then return end
	f.title:SetText("SquidBots Lite - " .. T("TRAINER"))
	f.npc:SetText(A.trainerName or (UnitName("npc")) or "")
	local y, shown = TTOP, 0
	local alts = A.Online()
	for i, card in ipairs(f.cards) do
		local name = alts[i]
		local data = name and A.train[name]
		if name then
			shown = shown + 1
			card.alt = name
			card.name:SetText(UI.ClassName(name))
			UI.ClassIcon(card.icon, name)
			card.learn:SetText(T("LEARN_ALL"))
			local n = 0
			if not data then
				card.sum:SetText("|cff9d9d9d" .. T("ASKING") .. "|r")
				card.learn:Hide()
			elseif data.err then
				card.sum:SetText("|cffff9933" .. T("ERR_" .. data.err) .. "|r")
				card.learn:Hide()
			elseif data.count == 0 then
				card.sum:SetText("|cff9d9d9d" .. T("TRAIN_NOTHING") .. "|r  " .. string.format(T("TRAIN_HAS"), Money(data.money)))
				card.learn:Hide()
			else
				local total = Money(data.total)
				if data.total > data.money then total = "|cffff4d4d" .. total .. "|r" end
				card.sum:SetText(string.format(T("TRAIN_SUM"), data.count, total))
				card.learn:Show()
				card.learn:Enable()
				for j, line in ipairs(card.lines) do
					local entry = data.list[j]
					if entry then
						n = j
						line.spell = entry.id
						line.text:SetText(entry.name ~= "" and entry.name or (GetSpellInfo(entry.id)) or ("#" .. entry.id))
						line.cost:SetText(Money(entry.cost))
						line:Show()
					end
				end
			end
			for j = n + 1, TLINES do card.lines[j]:Hide() end
			local h = 40 + n * TLINE_H
			if data and #data.list > TLINES then
				card.more:ClearAllPoints()
				card.more:SetPoint("TOPLEFT", 42, -36 - n * TLINE_H)
				card.more:SetText(string.format(T("TRAIN_MORE"), #data.list - TLINES))
				card.more:Show()
				h = h + TLINE_H
			else
				card.more:Hide()
			end
			if n > 0 then h = h + 4 end
			card:SetHeight(h)
			card:ClearAllPoints()
			card:SetPoint("TOPLEFT", 16, -y)
			card:Show()
			y = y + h + 4
		else
			card.alt = nil
			card:Hide()
		end
	end
	f.empty:SetText(shown == 0 and T("NO_ALTS") or "")
	f:SetHeight(y + (shown == 0 and 24 or 0) + 44)
end

function A.ShowTrainer()
	if #A.Online() == 0 then return end
	if not A.trainPanel then A.BuildTrainer() end
	if not A.trainPanel:IsShown() then
		A.Place(A.trainPanel)
		A.trainPanel:Show()
	end
	A.RefreshTrainer()
end

function A.AskTrain()
	A.trainAsk = nil
	for _, name in ipairs(A.Online()) do Send(name, "train") end
end

-- ---------------------------------------------------------------------------
-- The team bar: a portrait per logged-in alt (name, level, state) and the orders for all of them
-- ---------------------------------------------------------------------------
local PORTRAITS = 9

local function WhisperAll(text)
	for _, name in ipairs(A.Online()) do SendChatMessage(text, "WHISPER", nil, name) end
end

function A.AltStatus(name)
	local unit = UnitOf(name)
	local member = A.members[name]
	if (member and member.state == "dead") or (unit and UnitIsDeadOrGhost(unit)) then return T("ST_dead"), RED end
	local mission = SquidBotsLite_MissionOf and SquidBotsLite_MissionOf(name)
	if mission then return string.format(T("ST_mission"), mission.minutes or 0), ORANGE end
	if member and member.state == "mission" then return T("BADGE_MISSION"), ORANGE end
	local s = A.current and A.quests[A.current] and A.quests[A.current][name]
	if s and s.state ~= "can_take" and s.state ~= "in_log" and s.state ~= "done" and A.TeamQuest(A.current) then
		return T("ST_quest"), GOLD
	end
	if member and member.free == 0 then return T("ST_bags"), ORANGE end
	if member and member.state == "far" then return T("ST_far"), GREY end
	if member and member.state == "stay" then return T("ST_stay"), BLUE end
	if not unit and not member then return T("ST_away"), GREY end
	return T("ST_follow"), GREEN
end

-- A quest of the player's log: the team is expected to have it too.
function A.TeamQuest(id)
	for i = 1, GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		if link and tonumber(link:match("|Hquest:(%d+)")) == id then return true end
	end
	return false
end

function A.BuildTeam()
	local f = CreateFrame("Frame", "SquidBotsLiteTeam", UIParent)
	f:SetHeight(64)
	f:SetBackdrop(UI.CARD)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.9)
	f:SetBackdropBorderColor(1, 0.82, 0, 0.35)
	f:SetFrameStrata("MEDIUM")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relative, x, y = self:GetPoint()
		SquidBotsLiteDB.teamBar = { point, relative, x, y }
	end)
	local saved = SquidBotsLiteDB.teamBar
	if saved then f:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4]) else f:SetPoint("TOP", 0, -150) end
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(T("TEAM"), 1, 0.82, 0)
		GameTooltip:AddLine(T("TIP_TEAM_DRAG"), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	f.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.empty:SetPoint("LEFT", 12, 0)
	f.portraits = {}
	for i = 1, PORTRAITS do
		local p = CreateFrame("Button", nil, f)
		p:SetWidth(64)
		p:SetHeight(56)
		p:SetPoint("TOPLEFT", 6 + (i - 1) * 66, -4)
		p.icon = p:CreateTexture(nil, "ARTWORK")
		p.icon:SetWidth(26)
		p.icon:SetHeight(26)
		p.icon:SetPoint("TOP", 0, -1)
		p.level = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		p.level:SetPoint("BOTTOMRIGHT", p.icon, "BOTTOMRIGHT", 6, -2)
		p.level:SetFont(p.level:GetFont(), 9, "OUTLINE")
		p.name = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		p.name:SetPoint("TOP", p.icon, "BOTTOM", 0, -2)
		p.name:SetWidth(62)
		p.name:SetHeight(11)
		p.state = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		p.state:SetPoint("TOP", p.name, "BOTTOM", 0, -1)
		p.state:SetWidth(62)
		p.state:SetHeight(10)
		p.state:SetFont(p.state:GetFont(), 9)
		-- Its health, a thin bar under the icon (TEAM, else its unit in the group).
		p.hp = CreateFrame("StatusBar", nil, p)
		p.hp:SetWidth(26)
		p.hp:SetHeight(2)
		p.hp:SetPoint("TOP", p.icon, "BOTTOM", 0, 0)
		p.hp:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
		p.hp:SetStatusBarColor(0.3, 0.85, 0.3)
		p.hp:SetMinMaxValues(0, 100)
		p:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
		p:GetHighlightTexture():SetVertexColor(1, 0.82, 0, 0.08)
		p:RegisterForDrag("LeftButton")
		p:SetScript("OnDragStart", function() f:StartMoving() end)
		p:SetScript("OnDragStop", function() f:GetScript("OnDragStop")(f) end)
		p:SetScript("OnClick", function(self)
			if self.alt and SquidBotsLite_OpenSheet then SquidBotsLite_OpenSheet(self.alt) end
		end)
		p:SetScript("OnEnter", function(self)
			if not self.alt then return end
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
			GameTooltip:SetText(UI.ClassName(self.alt))
			local text, color = A.AltStatus(self.alt)
			GameTooltip:AddLine(text, color[1], color[2], color[3])
			GameTooltip:Show()
		end)
		p:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f.portraits[i] = p
	end
	-- The orders, on the right: square icons as on the bar.
	f.actions = {}
	for _, def in ipairs({
		{ "Interface\\Icons\\Spell_Shadow_Twilight", "T_SUMMON", "TIP_T_SUMMON", function() WhisperAll("summon") end },
		{ "Interface\\Icons\\INV_Misc_Rune_01", "T_FOLLOW", "TIP_T_FOLLOW", function()
			if SquidBotsLite_RecallAll then SquidBotsLite_RecallAll() end
		end },
		{ "Interface\\Icons\\INV_Misc_Book_11", "T_LEARN", "TIP_T_LEARN", function()
			for _, name in ipairs(A.Online()) do Send(name, "learn all") end
		end },
		{ "Interface\\Icons\\Trade_BlackSmithing", "T_REPAIR", "TIP_T_REPAIR", function()
			WhisperAll("repair")
			WhisperAll("s junk")
		end },
	}) do
		local button = UI.IconButton(f, 24, def[1], function() return T(def[2]), T(def[3]) end, def[4])
		table.insert(f.actions, button)
	end
	f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.close:SetWidth(20)
	f.close:SetHeight(20)
	f.close:SetPoint("TOPRIGHT", 2, 2)
	f.close:SetScript("OnClick", function()
		SquidBotsLiteDB.teamHidden = true
		f:Hide()
	end)
	f:Hide()
	A.team = f
end

function A.RefreshTeam()
	if not SquidBotsLiteDB or SquidBotsLiteDB.teamHidden then
		if A.team then A.team:Hide() end
		return
	end
	local alts = A.Online()
	if #alts == 0 then
		if A.team then A.team:Hide() end
		return
	end
	if not A.team then A.BuildTeam() end
	local f, n = A.team, 0
	for i, p in ipairs(f.portraits) do
		local name = alts[i]
		if name then
			n = i
			p.alt = name
			UI.ClassIcon(p.icon, name)
			local unit = UnitOf(name)
			local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[name]
			local member = A.members[name]
			local level = (member and member.level) or (unit and UnitLevel(unit)) or (info and info.level)
			local hp = member and member.hp
			if not hp and unit and UnitHealthMax(unit) > 0 then hp = math.floor(100 * UnitHealth(unit) / UnitHealthMax(unit)) end
			p.hp:SetValue(hp or 0)
			if hp then p.hp:Show() else p.hp:Hide() end
			p.level:SetText(level and level > 0 and level or "")
			p.name:SetText(UI.ClassName(name))
			local text, color = A.AltStatus(name)
			p.state:SetText(text)
			p.state:SetTextColor(color[1], color[2], color[3])
			p:Show()
		else
			p.alt = nil
			p:Hide()
		end
	end
	local x = 6 + n * 66 + 6
	for i, button in ipairs(f.actions) do
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", x + math.floor((i - 1) / 2) * 28, -6 - ((i - 1) % 2) * 28)
	end
	f.empty:SetText("")
	f:SetWidth(x + 2 * 28 + 10)
	f:Show()
end

function SquidBotsLite_ToggleTeam()
	SquidBotsLiteDB.teamHidden = not SquidBotsLiteDB.teamHidden or nil
	A.RefreshTeam()
end

-- ---------------------------------------------------------------------------
-- Objective tracker: a dot per alt on each quest the player follows (green has it, red does not, grey away)
-- ---------------------------------------------------------------------------
-- The server's "Team" messages (objectives done, behind) are not in the contract yet: until then the dots say
-- what the Q states tell (in its log or not), from the last answers.
local DOT = { green = GREEN, orange = ORANGE, red = RED, grey = GREY }
A.objectives = {}   -- [questId][alt] = "green" | "orange" | "red" | "grey", set by the Team messages when they come

-- The player's own progress on a quest of the log: the sum of its objectives' counts.
local function PlayerProgress(index)
	local done = 0
	for i = 1, GetNumQuestLeaderBoards(index) do
		local text = GetQuestLogLeaderBoard(i, index)
		local current = text and text:match("(%d+)%s*/%s*%d+")
		done = done + (tonumber(current) or 0)
	end
	return done
end

-- Green up to date (or complete), orange behind the player, red without the quest; nil: nothing known.
function A.DotOf(id, name, index)
	local set = A.objectives[id] and A.objectives[id][name]
	if set then return DOT[set] end
	local o = A.obj[id] and A.obj[id][name]
	if o then
		if o.state == "complete" then return GREEN end
		if o.state == "none" or o.state == "failed" then return RED end
		if o.state == "done" then return nil end
		if index and o.done < PlayerProgress(index) then return ORANGE end
		return GREEN
	end
	local s = A.quests[id] and A.quests[id][name]
	if not s then return nil end
	if s.state == "in_log" then return s.detail == "complete" and GREEN or GREEN end
	if s.state == "done" then return nil end
	return RED
end

function A.WatchDots()
	local buttons = _G.WATCHFRAME_LINKBUTTONS
	if type(buttons) ~= "table" then return end
	local alts = A.Online()
	for _, button in pairs(buttons) do
		button.sqbDots = button.sqbDots or {}
		local link = button.type == "QUEST" and button.index and button:IsShown() and GetQuestLink(button.index)
		local id = link and tonumber(link:match("|Hquest:(%d+)"))
		local shown = 0
		if id then
			for _, name in ipairs(alts) do
				local color = A.DotOf(id, name, button.index)
				local member = A.members[name]
				if color and (member and (member.state == "far" or member.state == "mission") or (not member and not UnitOf(name))) then
					color = GREY
				end
				if color then
					shown = shown + 1
					local dot = button.sqbDots[shown]
					if not dot then
						dot = button:CreateTexture(nil, "OVERLAY")
						dot:SetTexture("Interface\\Buttons\\WHITE8X8")
						dot:SetWidth(5)
						dot:SetHeight(5)
						button.sqbDots[shown] = dot
					end
					dot:ClearAllPoints()
					dot:SetPoint("TOPRIGHT", button, "TOPLEFT", -2 - (shown - 1) * 7, -4)
					dot:SetVertexColor(color[1], color[2], color[3], 0.9)
					dot:Show()
				end
			end
		end
		for i = shown + 1, #button.sqbDots do button.sqbDots[i]:Hide() end
	end
end

-- ---------------------------------------------------------------------------
-- My alts: two icons after its menus (Take for the team, the log) and the team bar's
-- ---------------------------------------------------------------------------
function SquidBotsLite_AltsButtons(frame, x)
	UI = UI or SquidBotsLite_UI
	local quests = UI.IconButton(frame, 22, "Interface\\GossipFrame\\AvailableQuestIcon",
		function() return T("QUESTS"), T("TIP_QUESTS") end, function() SquidBotsLite_ShowAltQuests() end)
	quests.icon:SetTexCoord(0, 1, 0, 1)
	quests:SetPoint("TOPLEFT", x, -36)
	local log = UI.IconButton(frame, 22, "Interface\\Icons\\INV_Misc_Note_01",
		function() return T("LOG"), T("TIP_LOG") end, function() SquidBotsLite_ShowAltLog() end)
	log:SetPoint("LEFT", quests, "RIGHT", 4, 0)
	local team = UI.IconButton(frame, 22, "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
		function() return T("TEAM"), T("TIP_TEAM") end, function() SquidBotsLite_ToggleTeam() end)
	team.icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
	team:SetPoint("LEFT", log, "RIGHT", 4, 0)
end

-- ---------------------------------------------------------------------------
-- The alts' messages
-- ---------------------------------------------------------------------------
local Handle = {}

function Handle.HELLO(name, f)
	A.hello = { from = name, catchup = f[3] == "1", silent = f[4] == "1", at = GetTime() }
	A.RefreshLog()
end

function Handle.TEAM(name, f)
	A.members[name] = { level = tonumber(f[2]), hp = tonumber(f[3]), state = f[4] or "follow", free = tonumber(f[5]),
		zone = tonumber(f[6]), at = GetTime() }
	A.RefreshTeam()
end

function Handle.OBJ(name, f)
	local id = tonumber(f[2])
	if not id then return end
	local done, needed = 0, 0
	for current, required in (f[4] or ""):gmatch("(%d+)/(%d+)") do
		done, needed = done + tonumber(current), needed + tonumber(required)
	end
	A.obj[id] = A.obj[id] or {}
	A.obj[id][name] = { state = f[3] or "none", done = done, needed = needed }
	A.WatchDots()
	A.RefreshTeam()
end

function Handle.Q(name, f)
	local id = tonumber(f[2])
	if not id then return end
	local s = { state = f[3] or "other", detail = f[4] or "", catchable = f[5] == "1", at = GetTime() }
	A.quests[id] = A.quests[id] or {}
	A.quests[id][name] = s
	local panel = A.questPanel
	local open = panel and panel:IsShown()
	-- At a quest giver (its list, or a quest of it): the panel shows the quests it offers.
	local atGiver = (QuestFrame and QuestFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown())
	-- No GetQuestID on this client: the first Q after the quest opened is that quest (the server sends it then).
	if A.detailPending and QuestFrame and QuestFrame:IsShown() then
		A.detailPending = nil
		A.detail = id
		A.titles[id] = GetTitleText() or A.titles[id]
		A.Seen(id)
	end
	if A.detail then
		if id == A.detail and not open then A.ShowQuests() end
	elseif atGiver or (open and A.manualQuests) then
		if not A.current or not A.quests[A.current] or not open then A.Seen(id) else
			local known = false
			for _, recent in ipairs(A.recent) do if recent == id then known = true end end
			if not known then table.insert(A.recent, id) end
		end
		if atGiver and not open then A.ShowQuests() end
	elseif A.acceptedAt and GetTime() - A.acceptedAt < ACCEPT_WINDOW and s.state ~= "can_take"
		and s.state ~= "in_log" and s.state ~= "done" then
		-- Just accepted, the panel closed: the alts left out go to the log.
		A.Log(string.format(T("Q_BLOCKED"), UI.ClassName(name), QuestLink(id), A.Reason(s)), true, 1, 0.6, 0.3)
	end
	A.RefreshQuests()
	A.RefreshTeam()
	A.WatchDots()
end

function Handle.QR(name, f)
	local id, result, detail = tonumber(f[2]), f[3] or "", f[4] or ""
	if not id then return end
	local who, quest = UI.ClassName(name), QuestLink(id)
	A.quests[id] = A.quests[id] or {}
	if result == "taken" then
		A.quests[id][name] = { state = "in_log", detail = "incomplete", at = GetTime() }
		A.Log(string.format(T("QR_taken"), who, quest), true, 0.5, 1, 0.5)
	elseif result == "caught_up" then
		A.Log(string.format(T("QR_caught_up"), who, quest, tonumber(detail) or 0), true, 1, 0.82, 0)
	elseif result == "refused" then
		local s = A.quests[id][name]
		local reason = (s and s.state == detail) and A.Reason(s) or A.Reason({ state = detail, detail = "" })
		A.Log(string.format(T("QR_refused"), who, quest, reason), true, 1, 0.4, 0.3)
	elseif T("QR_" .. result) ~= "QR_" .. result then
		local text = string.format(T("QR_" .. result), who, quest)
		A.Log(text, true, 1, 0.4, 0.3)
		if UIErrorsFrame then UIErrorsFrame:AddMessage(text, 1, 0.4, 0.3) end
	end
	A.RefreshQuests()
	A.WatchDots()
end

function Handle.T_BEGIN(name, f)
	local npc = tonumber(f[2]) or 0
	-- Another trainer: what the others could learn at the last one no longer holds.
	if A.trainerNpc ~= npc then A.train = {} end
	A.trainerNpc, A.trainerName = npc, (f[3] ~= "" and f[3]) or A.trainerName
	A.building = A.building or {}
	A.building[name] = { npc = npc, list = {} }
end

function Handle.T(name, f)
	local b = A.building and A.building[name]
	local id = tonumber(f[2])
	if not b or not id then return end
	table.insert(b.list, { id = id, cost = tonumber(f[3]) or 0, name = f[4] or "" })
end

function Handle.T_END(name, f)
	local b = A.building and A.building[name] or { list = {} }
	if A.building then A.building[name] = nil end
	A.train[name] = { list = b.list, count = tonumber(f[2]) or #b.list, total = tonumber(f[3]) or 0, money = tonumber(f[4]) or 0,
		at = GetTime() }
	if A.trainerOpen or (GossipFrame and GossipFrame:IsShown()) or (A.trainPanel and A.trainPanel:IsShown()) then A.ShowTrainer() end
	A.RefreshTrainer()
end

-- "train" / "learn" with no trainer found: said on its card instead of a list.
function Handle.T_ERR(name, f)
	local err = (f[2] and f[2] ~= "") and f[2] or "no_trainer"
	if T("ERR_" .. err) == "ERR_" .. err then err = "no_trainer" end
	if A.building then A.building[name] = nil end
	A.train[name] = { err = err, list = {}, count = 0, total = 0, money = 0, at = GetTime() }
	if not (A.trainPanel and A.trainPanel:IsShown()) then A.ShowTrainer() end
	A.RefreshTrainer()
end

local function SpellName(name, id)
	local data = A.train[name]
	for _, entry in ipairs(data and data.list or {}) do
		if entry.id == id and entry.name ~= "" then return entry.name end
	end
	return (GetSpellInfo(id)) or ("#" .. id)
end

function Handle.L(name, f)
	local id, result = tonumber(f[2]), f[3] or ""
	if not id then return end
	local text = string.format(T("L_" .. result) ~= "L_" .. result and T("L_" .. result) or T("L_failed"), UI.ClassName(name),
		"|cff71d5ff[" .. SpellName(name, id) .. "]|r")
	if result == "ok" then A.Log(text, false, 0.5, 1, 0.5) else A.Log(text, true, 1, 0.4, 0.3) end
end

function Handle.L_END(name, f)
	A.Log(string.format(T("L_END"), UI.ClassName(name), tonumber(f[2]) or 0, Money(f[3])), true, 1, 0.82, 0)
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
	local name = message:match("^No player named '(.-)' is currently playing%.$")
	if name and A.sent[name] and GetTime() - A.sent[name] < OFFLINE_WAIT then return true end
end)

local frame = CreateFrame("Frame")
for _, event in ipairs({ "CHAT_MSG_ADDON", "CHAT_MSG_SYSTEM", "CHAT_MSG_WHISPER", "PLAYER_ENTERING_WORLD", "QUEST_DETAIL",
	"QUEST_FINISHED", "QUEST_ACCEPTED", "QUEST_GREETING", "GOSSIP_SHOW", "GOSSIP_CLOSED", "TRAINER_SHOW", "TRAINER_CLOSED",
	"PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE", "UNIT_HEALTH", "QUEST_LOG_UPDATE" }) do
	frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
	UI = UI or SquidBotsLite_UI
	if not SquidBotsLiteDB then return end
	if event == "CHAT_MSG_ADDON" then
		if arg1 ~= PREFIX or arg3 ~= "WHISPER" or not arg4 then return end
		A.seen[arg4], A.gone[arg4] = GetTime(), nil
		local f = Split(arg2 or "")
		local handler = Handle[f[1]]
		if handler then handler(arg4, f) end
	elseif event == "CHAT_MSG_SYSTEM" then
		local added = arg1:match("^add%a*: (.-) %- ok$")
		if added then
			A.seen[added], A.gone[added] = GetTime(), nil
			A.RefreshTeam()
		end
		local gone = arg1:match("^No player named '(.-)' is currently playing%.$")
		if gone and A.sent[gone] and GetTime() - A.sent[gone] < OFFLINE_WAIT then
			A.gone[gone] = GetTime()
			-- The handshake went to an alt gone meanwhile: another one soon.
			if A.helloTo == gone then A.nextHello = GetTime() + 2 end
			A.RefreshTeam()
		end
	elseif event == "CHAT_MSG_WHISPER" then
		if IsAlt(arg2) then A.seen[arg2], A.gone[arg2] = GetTime(), nil end
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- After the loading screen, once the group and the alts are back.
		A.nextHello = math.max(A.nextHello, GetTime() + 5)
		A.RefreshTeam()
	elseif event == "QUEST_DETAIL" then
		local id = GetQuestID and GetQuestID()
		if id and id > 0 then
			A.detail = id
			A.titles[id] = GetTitleText() or A.titles[id]
			A.Seen(id)
			A.detailAt, A.questAsk = GetTime(), GetTime() + 1.5
			if #A.Online() > 0 then A.ShowQuests() end
		else
			A.detailPending = true
		end
	elseif event == "QUEST_FINISHED" then
		A.detail, A.questAsk, A.detailPending = nil, nil, nil
		A.HideQuests()
	elseif event == "QUEST_ACCEPTED" then
		A.acceptedAt = GetTime()
		A.detail = nil
	elseif event == "QUEST_GREETING" or event == "GOSSIP_SHOW" then
		A.detail = nil
		A.recent = {}
		A.current = nil
		if A.questPanel and A.questPanel:IsShown() then A.RefreshQuests() end
	elseif event == "GOSSIP_CLOSED" then
		if not (QuestFrame and QuestFrame:IsShown()) then A.HideQuests() end
		if not A.trainerOpen and A.trainPanel and A.trainPanel:IsShown() and not A.manualTrainer then A.trainPanel:Hide() end
	elseif event == "TRAINER_SHOW" then
		A.trainerOpen, A.trainerOpenedAt = true, GetTime()
		A.trainerName = UnitName("npc") or A.trainerName
		A.ShowTrainer()
		A.trainAsk = GetTime() + TRAIN_WAIT
	elseif event == "TRAINER_CLOSED" then
		A.trainerOpen, A.trainAsk = nil, nil
		if A.trainPanel and A.trainPanel:IsShown() and not A.manualTrainer then A.trainPanel:Hide() end
	elseif event == "QUEST_LOG_UPDATE" then
		A.WatchDots()
	elseif event == "UNIT_HEALTH" then
		if arg1 and (arg1:find("^party%d") or arg1:find("^raid%d")) then A.RefreshTeam() end
	else
		A.RefreshTeam()
	end
end)

if hooksecurefunc and WatchFrame_Update then hooksecurefunc("WatchFrame_Update", function() A.WatchDots() end) end

local elapsed, teamTick = 0, 0
frame:SetScript("OnUpdate", function(_, delta)
	elapsed = elapsed + delta
	if elapsed < 1 then return end
	elapsed = 0
	if not SquidBotsLiteDB then return end
	UI = UI or SquidBotsLite_UI
	local now = GetTime()
	-- The handshake: one alt is enough, the server marks the player for all of them.
	if Mode() ~= "chat" and now >= A.nextHello then
		local alts = A.Online()
		if #alts > 0 then
			A.helloTo, A.helloAt = alts[1], now
			Send(alts[1], "HELLO\t" .. VERSION)
			A.nextHello = now + HELLO_EVERY
		else
			A.nextHello = now + HELLO_RETRY
		end
	end
	-- The server sends Q when the quest opens: ask only the alts that said nothing (an older server).
	if A.questAsk and now >= A.questAsk then
		A.questAsk = nil
		local id = A.detail
		for _, name in ipairs(id and A.Online() or {}) do
			local s = A.quests[id] and A.quests[id][name]
			if not s or s.at < (A.detailAt or 0) then A.Ask(name, "quest", id) end
		end
		A.RefreshQuests()
	end
	-- The trainer opened and an alt said nothing: ask it.
	if A.trainAsk and now >= A.trainAsk then
		A.trainAsk = nil
		for _, name in ipairs(A.Online()) do
			local data = A.train[name]
			if not data or data.at < (A.trainerOpenedAt or 0) then Send(name, "train") end
		end
	end
	teamTick = teamTick + 1
	if teamTick >= 5 then
		teamTick = 0
		A.RefreshTeam()
		A.RefreshLog()
		if A.questPanel and A.questPanel:IsShown() then A.RefreshQuests() end
	end
end)
