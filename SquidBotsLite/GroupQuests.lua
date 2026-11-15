-- SquidBots Manager, the group's quests (3.1.2): one row per quest, one column for you and one for each alt of
-- your group (5 at most, a dropdown swaps them), grouped by zone, with filters, counts and actions.
-- From the realm (addon messages, prefix SQBA, whispered to each alt, answers whispered back by the alt):
--   qlog -> QL it <questId> <inprog|done|failed> <cur/need;...> <zone|sort:<id>|> <title> (25 at most), then QL -
--           QL err off when the option is off.
--   qlog watch on|off -> QL watch 1|0; while on (300 s, renewed here) QL it per changed quest, QL gone <id>.
--   turnin <id> [<choice 1..6>] -> QR <id> <turned_in|not_complete|not_in_log|no_ender|bags_full|err>,
--           or QR <id> choose_reward <itemId,itemId,...> (the player picks, "turnin <id> <n>" again).
-- An older realm (no QL within 3 s): each alt's "quests all" whisper (hidden), OBJ for the quests you also have,
-- and "quest <id>" for the reasons an alt cannot take one.
-- The plan (Now, Up/Down, Ignore) is a local reminder only, kept in SquidBotsLiteDB.questPlan: the realm's AI
-- does not follow it (it answers "QP err local" to qplan, so the addon never sends it).

local MAX_ALTS, ROWS, ROW_H, FALLBACK_WAIT, WATCH_RENEW, TICK = 5, 16, 18, 3, 240, 5
local Q_AGAIN, Q_WAIT, TURN_WAIT, OLD_SPACING, OLD_AGAIN, CAPTURE_QUIET, CAPTURE_MAX = 120, 15, 20, 1.1, 60, 2, 15
local W_TITLE, W_ME, W_ALT, X_COLS = 210, 56, 66, 246

local STRINGS = {
	en = {
		TITLE = "Group quests", BUTTON = "Quests", YOU = "You", OTHER = "Other", QUEST = "Quest", GROUP = "Group",
		F_all = "All", F_common = "Shared", F_turnin = "To turn in", F_blocked = "Blocked", F_missing = "Missing",
		IGNORED = "Ignored", S_zone = "Sort: zone", S_plan = "Sort: plan", S_progress = "Sort: progress",
		C_LOG = "Log", C_TURNIN = "Turn in", C_BLOCKED = "Blocked", PICK = "Alts...",
		TIP_PICK = "More than 5 alts in your group: choose the ones shown.",
		SHARE = "Share", DROP = "Drop...", TURNIN = "All turn in", NOW = "Now", REFRESH = "Refresh",
		TIP_SHARE = "To the alts that lack it: shared from your log, else taken at the quest giver.",
		TIP_DROP = "One of your alts abandons this quest (asked first).",
		TIP_TURNIN = "At the quest's ender (10 yd): each alt that has finished it turns it in.",
		TIP_NOW = "Your group's quest now: a star, first in the plan, in your tracker if you have it. A reminder for you only.",
		UP = "Up", DOWN = "Down", IGNORE = "Ignore", ALLOW = "Allow", LINK = "Link in chat",
		TIP_PLAN = "A reminder kept in this addon: your alts' AI does not follow it.",
		DROP_ASK = "%s abandons %s?", NO_SEL = "Select a quest first.", NONE_DONE = "No alt has finished %s.",
		SHARED = "%s shared from your log.", TAKE_SENT = "%s: asked of %s.", NONE_MISSING = "Every alt has %s.",
		CHOOSE = "%s: choose a reward for %s", TR_turned_in = "%s turned in %s.", TR_not_complete = "%s: %s is not finished.",
		TR_not_in_log = "%s does not have %s.", TR_no_ender = "%s: nobody to turn %s in to (within 10 yd).",
		TR_bags_full = "%s: bags full, %s not turned in.", TR_err = "Turning in needs the realm's update (option off).",
		UPDATED = "Updated %d s ago.", OLD = "Older realm: %s (no counts for quests you do not have).",
		SILENT = "No answer from %s.", NO_ALT = "No alt of yours in the group: only your own log is shown.",
		ST_inprog = "In progress", ST_done = "Finished, to turn in", ST_failed = "Failed", ST_can = "Can take it",
		ST_R = "Already turned in", ST_none = "Not in its log", ST_unknown = "Not in its log (asking why...)",
	},
	fr = {
		TITLE = "Quêtes du groupe", BUTTON = "Quêtes", YOU = "Vous", OTHER = "Autres", QUEST = "Quête", GROUP = "Groupe",
		F_all = "Toutes", F_common = "Communes", F_turnin = "À rendre", F_blocked = "Bloquées", F_missing = "Manquantes",
		IGNORED = "Ignorées", S_zone = "Tri : zone", S_plan = "Tri : plan", S_progress = "Tri : avancement",
		C_LOG = "Journal", C_TURNIN = "À rendre", C_BLOCKED = "Bloquées", PICK = "Alts...",
		TIP_PICK = "Plus de 5 alts dans le groupe : choisissez ceux affichés.",
		SHARE = "Partager", DROP = "Abandonner...", TURNIN = "Tous rendent", NOW = "Now", REFRESH = "Actualiser",
		TIP_SHARE = "Aux alts qui ne l'ont pas : partagée depuis votre journal, sinon prise chez le donneur.",
		TIP_DROP = "Un de vos alts abandonne cette quête (après confirmation).",
		TIP_TURNIN = "Chez le PNJ de fin (10 m) : chaque alt qui l'a finie la rend.",
		TIP_NOW = "La quête du groupe maintenant : une étoile, en tête du plan, dans votre suivi si vous l'avez. Un aide-mémoire pour vous seul.",
		UP = "Monter", DOWN = "Descendre", IGNORE = "Ignorer", ALLOW = "Autoriser", LINK = "Lien dans le chat",
		TIP_PLAN = "Un aide-mémoire gardé par l'addon : l'IA de vos alts ne le suit pas.",
		DROP_ASK = "%s abandonne %s ?", NO_SEL = "Sélectionnez d'abord une quête.", NONE_DONE = "Aucun alt n'a fini %s.",
		SHARED = "%s partagée depuis votre journal.", TAKE_SENT = "%s : demandée à %s.", NONE_MISSING = "Tous les alts ont %s.",
		CHOOSE = "%s : choisissez une récompense pour %s", TR_turned_in = "%s a rendu %s.", TR_not_complete = "%s : %s n'est pas finie.",
		TR_not_in_log = "%s n'a pas %s.", TR_no_ender = "%s : personne à qui rendre %s (à 10 m).",
		TR_bags_full = "%s : sacs pleins, %s pas rendue.", TR_err = "Rendre demande la mise à jour du royaume (option désactivée).",
		UPDATED = "Mis à jour il y a %d s.", OLD = "Royaume ancien : %s (pas de chiffres pour les quêtes que vous n'avez pas).",
		SILENT = "Pas de réponse de %s.", NO_ALT = "Aucun de vos alts dans le groupe : seul votre journal est affiché.",
		ST_inprog = "En cours", ST_done = "Finie, à rendre", ST_failed = "Échouée", ST_can = "Peut la prendre",
		ST_R = "Déjà rendue", ST_none = "Pas dans son journal", ST_unknown = "Pas dans son journal (je demande pourquoi...)",
	},
}
local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

-- QuestSort.dbc: a quest with no zone (class, profession, holiday) comes as "sort:<id>". The client has no API to
-- read the table, so the ones a player meets; any other id goes to "Other".
local QUEST_SORT = { [1] = "Epic", [22] = "Seasonal", [24] = "Herbalism", [25] = "Battlegrounds", [41] = "Day of the Dead",
	[61] = "Warlock", [81] = "Warrior", [82] = "Shaman", [101] = "Fishing", [121] = "Blacksmithing", [141] = "Paladin",
	[161] = "Mage", [162] = "Rogue", [181] = "Alchemy", [182] = "Leatherworking", [201] = "Engineering",
	[221] = "Treasure Map", [241] = "Tournament", [261] = "Hunter", [262] = "Priest", [263] = "Druid", [264] = "Tailoring",
	[284] = "Special", [304] = "Cooking", [324] = "First Aid", [344] = "Legendary", [364] = "Darkmoon Faire",
	[365] = "Ahn'Qiraj War", [366] = "Lunar Festival", [367] = "Reputation", [368] = "Invasion", [369] = "Midsummer",
	[370] = "Brewfest", [371] = "Inscription", [372] = "Death Knight", [373] = "Jewelcrafting", [374] = "Noblegarden",
	[375] = "Pilgrim's Bounty", [376] = "Love is in the Air", [377] = "Tutorial", [378] = "Profession", [384] = "Class",
	[385] = "Woodcutting", [386] = "Carpentry", [401] = "Enchanting", [402] = "Mining", [403] = "Skinning" }
-- Q states that mean "cannot take it" (Alts.lua's contract).
local BLOCKED = { missing_prev = true, exclusive = true, level = true, class_race = true, reputation = true, skill = true, other = true }
local DONE_ICON = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12|t"

-- log[name][id] = { state, obj = { {cur, need} }, zone, title, level, index (yours), link (yours) }.
-- mode[name]: "ql" (the realm answers qlog) or "old" (quests all). capture[name]: a "quests all" being read.
local GQ = { log = {}, pending = {}, mode = {}, asked = {}, heard = {}, watchAt = {}, noWatch = {}, turn = {}, choices = {},
	qAsked = {}, qQueue = {}, capture = {}, hideUntil = {}, oldQueue = {}, oldAt = {}, silent = {}, collapsed = {},
	filter = "all", sort = "zone", tick = 0 }
SquidBotsLite_GroupQuests = GQ
local A, UI

local function Me() return UnitName("player") end
local function Status(text) GQ.status, GQ.statusAt = text, GetTime(); if GQ.frame then GQ.Draw() end end

local function Plan()
	local db = SquidBotsLiteDB
	db.questPlan = db.questPlan or {}
	local plan = db.questPlan
	plan.order, plan.ignore = plan.order or {}, plan.ignore or {}
	return plan
end

-- One redraw for a burst of messages (25 QL lines from each alt).
function GQ.Dirty()
	if GQ.dirty or not (GQ.frame and GQ.frame:IsShown()) then return end
	GQ.dirty = true
	UI.After(0.2, function() GQ.dirty = nil; GQ.Draw() end)
end

-- ---------------------------------------------------------------------------
-- Who: you, then the alts of your group (5 at most, the chosen ones first)
-- ---------------------------------------------------------------------------
function GQ.GroupAlts()
	local list, have, units = {}, {}, {}
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do table.insert(units, "raid" .. i) end
	else
		for i = 1, 4 do table.insert(units, "party" .. i) end
	end
	for _, unit in ipairs(units) do
		local name = UnitName(unit)
		if name and not have[name] and name ~= Me() and A.IsAlt(name) and UnitIsConnected(unit) then
			have[name] = true
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

function GQ.Columns()
	local alts, cols, used = GQ.GroupAlts(), { Me() }, {}
	local present = {}
	for _, name in ipairs(alts) do present[name] = true end
	for _, name in ipairs(#alts > MAX_ALTS and SquidBotsLiteDB.questCols or {}) do
		if present[name] and not used[name] and #cols <= MAX_ALTS then used[name] = true; table.insert(cols, name) end
	end
	for _, name in ipairs(alts) do
		if not used[name] and #cols <= MAX_ALTS then used[name] = true; table.insert(cols, name) end
	end
	return cols, alts
end

-- The dropdown: an alt not shown takes the place of the last one shown.
function GQ.Pick(name)
	local cols = GQ.Columns()
	local list = {}
	for i = 2, #cols do if cols[i] ~= name then table.insert(list, cols[i]) end end
	while #list >= MAX_ALTS do table.remove(list) end
	table.insert(list, name)
	SquidBotsLiteDB.questCols = list
	GQ.Ask(name)
	GQ.Draw()
end

-- ---------------------------------------------------------------------------
-- The data: your log, QL, the "quests all" fallback
-- ---------------------------------------------------------------------------
function GQ.ReadPlayer()
	local log, zones, zone = {}, {}, nil
	for i = 1, GetNumQuestLogEntries() do
		local title, level, _, _, header, _, complete = GetQuestLogTitle(i)
		if header then
			zone = title
			table.insert(zones, title)
		else
			local link = GetQuestLink(i)
			local id = link and tonumber(link:match("|Hquest:(%d+)"))
			if id then
				local obj = {}
				for j = 1, GetNumQuestLeaderBoards(i) or 0 do
					local cur, need = (GetQuestLogLeaderBoard(j, i) or ""):match("(%d+)%s*/%s*(%d+)")
					if cur then table.insert(obj, { tonumber(cur), tonumber(need) }) end
				end
				log[id] = { state = complete == 1 and "done" or complete == -1 and "failed" or "inprog", obj = obj,
					zone = zone, title = title, level = level, index = i, link = link }
			end
		end
	end
	GQ.log[Me()], GQ.zoneOrder = log, zones
end

local function Zone(raw)
	if not raw or raw == "" then return nil end
	local sort = tonumber(raw:match("^sort:(%d+)$"))
	if raw:find("^sort:") then return sort and QUEST_SORT[sort] or nil end
	return raw
end

function GQ.OnQL(name, f)
	local now, kind = GetTime(), f[2]
	GQ.heard[name], GQ.silent[name] = now, nil
	if kind == "it" then
		local id = tonumber(f[3])
		if not id then return end
		local obj = {}
		for cur, need in (f[5] or ""):gmatch("(%d+)/(%d+)") do table.insert(obj, { tonumber(cur), tonumber(need) }) end
		local state = (f[4] == "done" or f[4] == "failed") and f[4] or "inprog"
		GQ.mode[name] = "ql"
		local into = GQ.pending[name]
		if not into then GQ.log[name] = GQ.log[name] or {}; into = GQ.log[name] end
		into[id] = { state = state, obj = obj, zone = Zone(f[6]), title = (f[7] and f[7] ~= "") and f[7] or nil }
	elseif kind == "-" then
		GQ.mode[name] = "ql"
		if GQ.pending[name] then GQ.log[name], GQ.pending[name] = GQ.pending[name], nil end
		GQ.updated = now
		GQ.Watch(name)
	elseif kind == "gone" then
		local id = tonumber(f[3])
		if id and GQ.log[name] then GQ.log[name][id] = nil end
		if id and GQ.pending[name] then GQ.pending[name][id] = nil end
	elseif kind == "watch" then
		if f[3] ~= "1" then GQ.watchAt[name] = nil end
	elseif kind == "err" then
		if f[3] == "unknown" then
			GQ.noWatch[name], GQ.watchAt[name] = true, nil
		else
			GQ.pending[name] = nil
			GQ.mode[name] = "old"
			GQ.Old(name)
		end
	end
	GQ.Dirty()
end

-- qlog, or "quests all" for an alt already known to be on an older realm. No QL in 3 s: older realm.
function GQ.Ask(name)
	if GQ.mode[name] == "old" then return GQ.Old(name) end
	local at = GetTime()
	GQ.asked[name], GQ.pending[name] = at, {}
	A.Send(name, "qlog")
	UI.After(FALLBACK_WAIT, function()
		if GQ.asked[name] ~= at or (GQ.heard[name] or 0) >= at then return end
		GQ.pending[name], GQ.mode[name] = nil, "old"
		GQ.Old(name)
	end)
end

function GQ.AskAll()
	local cols = GQ.Columns()
	for i = 2, #cols do GQ.Ask(cols[i]) end
end

-- The watch lasts 300 s on the realm: renewed after 240 s while the window is open.
function GQ.Watch(name)
	if GQ.noWatch[name] or GQ.mode[name] ~= "ql" or not (GQ.frame and GQ.frame:IsShown()) then return end
	if GQ.watchAt[name] and GetTime() - GQ.watchAt[name] < WATCH_RENEW then return end
	GQ.watchAt[name] = GetTime()
	A.Send(name, "qlog watch on")
end

function GQ.Unwatch()
	for name in pairs(GQ.watchAt) do A.Send(name, "qlog watch off") end
	GQ.watchAt = {}
end

-- The older realm: "quests all" whispered to one alt every 1.1 s, its lines read and hidden.
function GQ.Old(name)
	for _, queued in ipairs(GQ.oldQueue) do if queued == name then return end end
	if GQ.capture[name] then return end
	table.insert(GQ.oldQueue, name)
	if not GQ.oldBusy then GQ.OldNext() end
end

function GQ.OldNext()
	local name = table.remove(GQ.oldQueue, 1)
	if not name then GQ.oldBusy = nil return end
	GQ.oldBusy = true
	local now = GetTime()
	GQ.capture[name], GQ.hideUntil[name], GQ.oldAt[name] = { lines = {}, at = now, last = now }, now + CAPTURE_MAX, now
	SquidBotsLite_QuietWhisper("quests all", name)
	GQ.CaptureCheck(name)
	UI.After(OLD_SPACING, GQ.OldNext)
end

function GQ.CaptureCheck(name)
	UI.After(0.5, function()
		local c = GQ.capture[name]
		if not c then return end
		local now = GetTime()
		if (#c.lines > 0 and now - c.last >= CAPTURE_QUIET) or now - c.at >= CAPTURE_MAX then GQ.CaptureEnd(name)
		else GQ.CaptureCheck(name) end
	end)
end

-- Strict on the format, so that a real whisper of the alt is never taken.
local function Ours(text)
	return text and (text:find("|Hquest:", 1, true) or text:find("^%-%-%- ") or text:find("^Total: ")) and true or false
end

function GQ.OnWhisper(name, text)
	local c = GQ.capture[name]
	if not c or not Ours(text) then return end
	table.insert(c.lines, text)
	c.last = GetTime()
	if text:find("^Total: ") then GQ.CaptureEnd(name) end
end

function GQ.CaptureEnd(name)
	local c = GQ.capture[name]
	if not c then return end
	GQ.capture[name], GQ.hideUntil[name] = nil, GetTime() + 1
	if #c.lines == 0 then GQ.silent[name] = true; GQ.Dirty() return end
	local log, state = {}, "inprog"
	for _, line in ipairs(c.lines) do
		local lower = line:lower()
		if line:find("^%-%-%- ") then
			if lower:find("incomplete") then state = "inprog" elseif lower:find("complete") then state = "done" end
		else
			local id, level = line:match("|Hquest:(%d+):?(%-?%d*)")
			id = tonumber(id)
			if id then
				log[id] = { state = state, obj = {}, title = line:match("|h%[(.-)%]|h"), level = tonumber(level) }
			end
		end
	end
	GQ.log[name], GQ.updated, GQ.silent[name] = log, GetTime(), nil
	GQ.Dirty()
end

-- ---------------------------------------------------------------------------
-- The grid: cells, rows, filters, order
-- ---------------------------------------------------------------------------
-- kind: have (in its log), done, failed, can (+), R (turned in), blocked (x), none (-).
function GQ.Cell(id, name)
	local e = GQ.log[name] and GQ.log[name][id]
	if e then
		if e.state == "done" then return "done", DONE_ICON end
		if e.state == "failed" then return "failed", "|cffff4040!|r" end
		local cur, need = 0, 0
		for _, o in ipairs(e.obj or {}) do cur, need = cur + o[1], need + o[2] end
		local obj = need == 0 and A.obj[id] and A.obj[id][name]
		if obj and obj.needed > 0 then cur, need = obj.done, obj.needed end
		if need > 0 then return "have", string.format("%d/%d", cur, need), cur / need end
		return "have", "|cff66b3ff...|r", 0
	end
	if name == Me() then return "none", "|cff808080-|r" end
	local q = A.quests[id] and A.quests[id][name]
	if q then
		if q.state == "can_take" then return "can", "|cff4dd94d+|r" end
		if q.state == "done" then return "R", "|cff999999R|r" end
		if BLOCKED[q.state] then return "blocked", "|cffff4d4dx|r", nil, q end
	end
	return "none", "|cff808080-|r", nil, nil, not q
end

-- The plan order of the quests known (ids), the saved order first.
function GQ.PlanList(known)
	local list, seen = {}, {}
	for _, id in ipairs(Plan().order) do
		if known[id] and not seen[id] then seen[id] = true; table.insert(list, id) end
	end
	local rest = {}
	for id in pairs(known) do if not seen[id] then table.insert(rest, id) end end
	table.sort(rest)
	for _, id in ipairs(rest) do table.insert(list, id) end
	return list
end

-- Every quest of the columns, with its counts; the lines shown (zone headers and quests) after filter and order.
function GQ.Lines(cols)
	local known, rows, plan = {}, {}, Plan()
	for _, name in ipairs(cols) do
		for id in pairs(GQ.log[name] or {}) do known[id] = true end
	end
	local rank = {}
	for i, id in ipairs(GQ.PlanList(known)) do rank[id] = i end
	local counts = { all = 0, common = 0, turnin = 0, blocked = 0, missing = 0 }
	local perCol = {}
	-- "Shared": by every column whose log is in (an alt still silent does not empty the filter).
	local heard = 0
	for i = 1, #cols do
		perCol[i] = { log = 0, turnin = 0, blocked = 0 }
		if GQ.log[cols[i]] then heard = heard + 1 end
	end
	for i, name in ipairs(cols) do
		for _ in pairs(GQ.log[name] or {}) do perCol[i].log = perCol[i].log + 1 end
	end
	for id in pairs(known) do
		local row = { id = id, rank = rank[id], cells = {}, have = 0, done = 0, blocked = 0, missing = 0, sum = 0 }
		for i, name in ipairs(cols) do
			local kind, text, pct, q, unknown = GQ.Cell(id, name)
			row.cells[i] = { kind = kind, text = text, q = q, unknown = unknown }
			if kind == "have" or kind == "done" or kind == "failed" then
				row.have = row.have + 1
				row.sum = row.sum + (kind == "done" and 1 or pct or 0)
			end
			if kind == "done" then row.done = row.done + 1; perCol[i].turnin = perCol[i].turnin + 1 end
			if kind == "blocked" then row.blocked = row.blocked + 1; perCol[i].blocked = perCol[i].blocked + 1 end
			if kind == "can" or (unknown and i > 1) then row.missing = row.missing + 1 end
			local e = GQ.log[name] and GQ.log[name][id]
			if e then
				-- Your log first: its title is in your language, its zone your log's header.
				if not row.title or i == 1 then row.title, row.zone, row.level, row.link = e.title, e.zone, e.level, e.link end
				row.level = row.level or e.level
			end
		end
		-- The realm's titles are English: the client's own (your log, its cache) when it has one.
		local mine = GQ.log[Me()] and GQ.log[Me()][id]
		row.title = (mine and mine.title) or A.titles[id] or row.title or A.Title(id)
		row.zone = row.zone or T("OTHER")
		row.pct = row.have > 0 and row.sum / row.have or 0
		row.ignored = plan.ignore[id] and true or false
		if not row.ignored or GQ.showIgnored then
			row.common = row.have == heard and heard > 1
			counts.all = counts.all + 1
			if row.common then counts.common = counts.common + 1 end
			if row.done > 0 then counts.turnin = counts.turnin + 1 end
			if row.blocked > 0 then counts.blocked = counts.blocked + 1 end
			if row.missing > 0 then counts.missing = counts.missing + 1 end
			local f = GQ.filter
			if f == "all" or (f == "common" and row.common) or (f == "turnin" and row.done > 0)
				or (f == "blocked" and row.blocked > 0) or (f == "missing" and row.missing > 0) then
				table.insert(rows, row)
			end
		end
	end
	local now = plan.now
	local function ByPlan(a, b)
		if (a.id == now) ~= (b.id == now) then return a.id == now end
		return a.rank < b.rank
	end
	local lines = {}
	if GQ.sort == "plan" then
		table.sort(rows, ByPlan)
		lines = rows
	elseif GQ.sort == "progress" then
		table.sort(rows, function(a, b) if a.pct ~= b.pct then return a.pct > b.pct end return ByPlan(a, b) end)
		lines = rows
	else
		-- By zone: your log's order, then the others by name, "Other" last; in a zone, the plan's order.
		local zoneRank = {}
		for i, zone in ipairs(GQ.zoneOrder or {}) do zoneRank[zone] = zoneRank[zone] or i end
		local function ZoneKey(zone)
			if zoneRank[zone] then return string.format("0%04d", zoneRank[zone]) end
			return (zone == T("OTHER") and "2" or "1") .. zone
		end
		table.sort(rows, function(a, b)
			if a.zone ~= b.zone then return ZoneKey(a.zone) < ZoneKey(b.zone) end
			return ByPlan(a, b)
		end)
		local zone, header
		for _, row in ipairs(rows) do
			if row.zone ~= zone then
				zone = row.zone
				header = { header = true, zone = zone, n = 0 }
				table.insert(lines, header)
			end
			header.n = header.n + 1
			if not GQ.collapsed[zone] then table.insert(lines, row) end
		end
	end
	return lines, counts, perCol, known
end

-- ---------------------------------------------------------------------------
-- The plan (local) and the actions
-- ---------------------------------------------------------------------------
function GQ.Move(id, delta)
	local lines, _, _, known = GQ.Lines(GQ.Columns())
	local shown = {}
	for _, line in ipairs(lines) do if not line.header then table.insert(shown, line.id) end end
	local pos
	for i, other in ipairs(shown) do if other == id then pos = i end end
	local neighbour = pos and shown[pos + delta]
	if not neighbour then return end
	local list = GQ.PlanList(known)
	local a, b
	for i, other in ipairs(list) do
		if other == id then a = i elseif other == neighbour then b = i end
	end
	list[a], list[b] = list[b], list[a]
	-- The quests not shown now (an alt out of the group) keep their place after these.
	for _, other in ipairs(Plan().order) do if not known[other] then table.insert(list, other) end end
	while #list > 200 do table.remove(list) end
	Plan().order = list
	GQ.Draw()
end

function GQ.Ignore(id)
	local plan = Plan()
	plan.ignore[id] = not plan.ignore[id] or nil
	GQ.Draw()
end

function GQ.Now(id)
	local plan = Plan()
	plan.now = plan.now ~= id and id or nil
	local mine = plan.now and GQ.log[Me()] and GQ.log[Me()][id]
	if mine and mine.index and IsQuestWatched and not IsQuestWatched(mine.index)
		and GetNumQuestWatches() < (MAX_WATCHABLE_QUESTS or 5) then
		AddQuestWatch(mine.index)
		if WatchFrame_Update then WatchFrame_Update() end
	end
	GQ.Draw()
end

local function Title(id)
	local mine = GQ.log[Me()] and GQ.log[Me()][id]
	return "|cffffff00[" .. (mine and mine.title or A.Title(id)) .. "]|r"
end

function GQ.Share(id)
	local cols = GQ.Columns()
	local mine = GQ.log[Me()] and GQ.log[Me()][id]
	if mine and mine.index then
		SelectQuestLogEntry(mine.index)
		if GetQuestLogPushable() then
			QuestLogPushQuest()
			Status(string.format(T("SHARED"), Title(id)))
			return
		end
	end
	local asked = {}
	for i = 2, #cols do
		local kind = GQ.Cell(id, cols[i])
		if kind == "can" or kind == "none" then
			A.Send(cols[i], "take " .. id)
			table.insert(asked, cols[i])
		end
	end
	Status(#asked > 0 and string.format(T("TAKE_SENT"), Title(id), table.concat(asked, ", "))
		or string.format(T("NONE_MISSING"), Title(id)))
	UI.After(3, GQ.AskAll)
end

function GQ.TurnIn(id)
	local cols, sent = GQ.Columns(), 0
	for i = 2, #cols do
		if GQ.Cell(id, cols[i]) == "done" then
			GQ.turn[cols[i] .. ":" .. id] = GetTime()
			A.Send(cols[i], "turnin " .. id)
			sent = sent + 1
		end
	end
	if sent == 0 then Status(string.format(T("NONE_DONE"), Title(id))) end
end

-- QR of a turnin asked here (the rest is Alts.lua's: take, catchup). True when handled.
function GQ.OnQR(name, f)
	local id = tonumber(f[2])
	local key = name .. ":" .. tostring(id)
	if not id or not GQ.turn[key] or GetTime() - GQ.turn[key] > TURN_WAIT then return false end
	local result = f[3] or ""
	if result == "choose_reward" then
		local items = {}
		for item in (f[4] or ""):gmatch("(%d+)") do table.insert(items, tonumber(item)) end
		table.insert(GQ.choices, { name = name, id = id, items = items })
		GQ.ShowChoice()
		return true
	end
	GQ.turn[key] = nil
	if result == "turned_in" then
		if GQ.log[name] then GQ.log[name][id] = nil end
		A.quests[id] = A.quests[id] or {}
		A.quests[id][name] = { state = "done", detail = "", at = GetTime() }
	end
	local text = T("TR_" .. result)
	if text == "TR_" .. result then text = "%s: %s " .. result end
	Status(string.format(text, UI.ClassName(name), Title(id)))
	return true
end

-- The reward: the n-th item (1-based) of the first choice waiting.
function GQ.Choose(n)
	local c = table.remove(GQ.choices, 1)
	if not c then return end
	GQ.turn[c.name .. ":" .. c.id] = GetTime()
	A.Send(c.name, "turnin " .. c.id .. " " .. n)
	GQ.ShowChoice()
end

function GQ.Drop(id, name)
	local e = GQ.log[name] and GQ.log[name][id]
	local title = (e and e.title) or A.Title(id)
	StaticPopupDialogs.SQUIDBOTSLITE_GQ_DROP.text = string.format(T("DROP_ASK"), name, Title(id))
	local mine = GQ.log[Me()] and GQ.log[Me()][id]
	local level = (e and e.level) or (mine and mine.level) or 0
	local link = string.format("|cffffff00|Hquest:%d:%d|h[%s]|h|r", id, level, title)
	StaticPopup_Show("SQUIDBOTSLITE_GQ_DROP", nil, nil, { name = name, link = link })
end

StaticPopupDialogs.SQUIDBOTSLITE_GQ_DROP = {
	text = "%s", button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
	OnAccept = function(self)
		local data = self.data
		if not data then return end
		SquidBotsLite_QuietWhisper("drop " .. data.link, data.name)
		UI.After(2, function() GQ.Ask(data.name) end)
	end,
}

-- "quest <id>" for the empty cells shown: why the alt does not have it. Four a half second at most.
function GQ.AskWhy(id, name)
	local key = name .. ":" .. id
	if GQ.qAsked[key] and GetTime() - GQ.qAsked[key] < Q_AGAIN then return end
	GQ.qAsked[key] = GetTime()
	table.insert(GQ.qQueue, { name = name, id = id })
	if not GQ.qBusy then GQ.Pump() end
end

function GQ.Pump()
	GQ.qBusy = #GQ.qQueue > 0 or nil
	for _ = 1, 4 do
		local q = table.remove(GQ.qQueue, 1)
		if not q then break end
		A.Send(q.name, "quest " .. q.id)
	end
	if GQ.qBusy then UI.After(0.5, GQ.Pump) end
end

-- ---------------------------------------------------------------------------
-- The window
-- ---------------------------------------------------------------------------
local function Tip(frame, title, line)
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(type(title) == "function" and title() or title, 1, 0.82, 0)
		if line then GameTooltip:AddLine(line, 1, 1, 1, true) end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Button(parent, width, key, onClick, tip)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetWidth(width)
	b:SetHeight(20)
	b.key = key
	b:SetScript("OnClick", onClick)
	if tip then Tip(b, function() return T(key) end, T(tip)) end
	UI.Flatten(b)
	return b
end

local function CellTip(self)
	local row, i = self:GetParent().line, self.index
	if not row or row.header then return end
	local cols = GQ.Columns()
	local name, cell = cols[i], row.cells[i]
	if not name or not cell then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText(row.title or "?", 1, 0.82, 0)
	GameTooltip:AddLine(UI.ClassName(name), 1, 1, 1)
	local e = GQ.log[name] and GQ.log[name][row.id]
	local word = e and ("ST_" .. e.state) or cell.kind == "can" and "ST_can" or cell.kind == "R" and "ST_R"
		or cell.unknown and i > 1 and "ST_unknown" or "ST_none"
	if cell.kind == "blocked" then GameTooltip:AddLine(A.Reason(cell.q), 1, 0.4, 0.3, true)
	else GameTooltip:AddLine(T(word), 0.8, 0.8, 0.8) end
	for _, o in ipairs(e and e.obj or {}) do GameTooltip:AddLine(string.format("%d/%d", o[1], o[2]), 1, 1, 1) end
	GameTooltip:Show()
end

local function RowMenu(row)
	local cols = GQ.Columns()
	local id, plan = row.id, Plan()
	local drop = {}
	for i = 2, #cols do
		if GQ.log[cols[i]] and GQ.log[cols[i]][id] then
			local name = cols[i]
			table.insert(drop, { text = name, notCheckable = true, func = function() GQ.Drop(id, name) end })
		end
	end
	local items = { { text = row.title, isTitle = true, notCheckable = true },
		{ text = T("SHARE"), notCheckable = true, func = function() GQ.Share(id) end },
		{ text = T("TURNIN"), notCheckable = true, func = function() GQ.TurnIn(id) end },
		{ text = T("DROP"), notCheckable = true, hasArrow = #drop > 0, disabled = #drop == 0, menuList = drop },
		{ text = T("NOW"), checked = plan.now == id, func = function() GQ.Now(id) end },
		{ text = T("UP"), notCheckable = true, func = function() GQ.Move(id, -1) end },
		{ text = T("DOWN"), notCheckable = true, func = function() GQ.Move(id, 1) end },
		{ text = plan.ignore[id] and T("ALLOW") or T("IGNORE"), notCheckable = true, func = function() GQ.Ignore(id) end } }
	GQ.menu = GQ.menu or CreateFrame("Frame", "SquidBotsLiteGroupQuestsMenu", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(items, GQ.menu, "cursor", 0, 0, "MENU")
end

local function RowClick(self, button)
	local row = self.line
	if not row then return end
	if row.header then
		GQ.collapsed[row.zone] = not GQ.collapsed[row.zone] or nil
	elseif button == "RightButton" then
		GQ.selected = row.id
		RowMenu(row)
	elseif IsShiftKeyDown() then
		local link = row.link or string.format("|cffffff00|Hquest:%d:%d|h[%s]|h|r", row.id, row.level or 0, row.title or "?")
		if not ChatEdit_InsertLink(link) then ChatFrame_OpenChat(link) end
	else
		GQ.selected = row.id
	end
	GQ.Draw()
end

local function SmallButton(row, x, icon, tipKey, onClick)
	local b = UI.IconButton(row, 14, icon, function() return T(tipKey), T("TIP_PLAN") end, function(self)
		local line = self:GetParent().line
		if line and not line.header then onClick(line.id) end
	end)
	b:SetPoint("LEFT", x, 0)
	return b
end

function GQ.Build()
	local width = X_COLS + W_ME + MAX_ALTS * W_ALT + 70
	local f = CreateFrame("Frame", "SquidBotsLiteGroupQuests", UIParent)
	GQ.frame = f
	f:SetWidth(width)
	f:SetHeight(108 + ROWS * ROW_H + 132)
	f:SetPoint("CENTER")
	f:SetBackdrop(UI.PANEL_BACKDROP)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.96)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetScript("OnHide", function() GQ.Unwatch() end)
	table.insert(UISpecialFrames, "SquidBotsLiteGroupQuests")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	-- The filters, "ignored", the sort and the alts' dropdown.
	f.filters = {}
	local x = 16
	for _, key in ipairs({ "all", "common", "turnin", "blocked", "missing" }) do
		local b = Button(f, key == "all" and 60 or 96, "F_" .. key, function() GQ.filter = key; GQ.offset = 0; GQ.Draw() end)
		b:SetPoint("TOPLEFT", x, -36)
		f.filters[key] = b
		x = x + (key == "all" and 62 or 98)
	end
	f.ignored = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
	f.ignored:SetWidth(22)
	f.ignored:SetHeight(22)
	f.ignored:SetPoint("TOPLEFT", x + 2, -35)
	f.ignored:SetScript("OnClick", function(self) GQ.showIgnored = self:GetChecked() and true or nil; GQ.Draw() end)
	f.ignoredText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.ignoredText:SetPoint("LEFT", f.ignored, "RIGHT", 0, 0)
	f.sortButton = Button(f, 110, "S_zone", function()
		GQ.sort = GQ.sort == "zone" and "plan" or GQ.sort == "plan" and "progress" or "zone"
		GQ.Draw()
	end)
	f.sortButton:SetPoint("TOPRIGHT", -18, -36)
	-- The column headers.
	f.head = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.head:SetPoint("TOPLEFT", 34, -68)
	f.heads = {}
	for i = 1, MAX_ALTS + 1 do
		local h = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		h:SetWidth(i == 1 and W_ME or W_ALT - 2)
		h:SetHeight(12)
		h:SetPoint("TOPLEFT", X_COLS + (i == 1 and 0 or W_ME + (i - 2) * W_ALT), -68)
		f.heads[i] = h
	end
	f.pick = Button(f, 60, "PICK", function() GQ.PickMenu() end, "TIP_PICK")
	f.pick:SetPoint("TOPRIGHT", -18, -62)
	UI.Rule(f, -84)
	f.rows = {}
	for i = 1, ROWS do
		local row = CreateFrame("Button", nil, f)
		row:SetWidth(width - 32)
		row:SetHeight(ROW_H)
		row:SetPoint("TOPLEFT", 16, -90 - (i - 1) * ROW_H)
		row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		row:SetScript("OnClick", RowClick)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row:EnableMouseWheel(true)
		row:SetScript("OnMouseWheel", function(_, delta) GQ.Scroll(delta) end)
		row.sel = row:CreateTexture(nil, "BACKGROUND")
		row.sel:SetAllPoints()
		row.sel:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.sel:SetVertexColor(1, 0.82, 0, 0.12)
		row.star = row:CreateTexture(nil, "ARTWORK")
		row.star:SetWidth(13)
		row.star:SetHeight(13)
		row.star:SetPoint("LEFT", 2, 0)
		row.star:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.text:SetPoint("LEFT", 18, 0)
		row.text:SetWidth(W_TITLE)
		row.text:SetHeight(ROW_H)
		row.text:SetJustifyH("LEFT")
		row.cells = {}
		for j = 1, MAX_ALTS + 1 do
			local cell = CreateFrame("Frame", nil, row)
			cell.index = j
			cell:SetWidth(j == 1 and W_ME or W_ALT - 2)
			cell:SetHeight(ROW_H)
			cell:SetPoint("LEFT", X_COLS - 16 + (j == 1 and 0 or W_ME + (j - 2) * W_ALT), 0)
			cell:EnableMouse(true)
			cell:SetScript("OnEnter", CellTip)
			cell:SetScript("OnLeave", function() GameTooltip:Hide() end)
			cell:SetScript("OnMouseUp", function(self, button) RowClick(self:GetParent(), button) end)
			cell.text = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			cell.text:SetAllPoints()
			cell.text:SetJustifyH("LEFT")
			row.cells[j] = cell
		end
		local bx = X_COLS - 16 + W_ME + MAX_ALTS * W_ALT + 4
		row.up = SmallButton(row, bx, "Interface\\Buttons\\Arrow-Up-Up", "UP", function(id) GQ.Move(id, -1) end)
		row.down = SmallButton(row, bx + 16, "Interface\\Buttons\\Arrow-Down-Up", "DOWN", function(id) GQ.Move(id, 1) end)
		row.ignore = SmallButton(row, bx + 32, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", "IGNORE", GQ.Ignore)
		for _, b in ipairs({ row.up, row.down }) do b.icon:SetTexCoord(0.2, 0.8, 0.1, 0.7) end
		f.rows[i] = row
	end
	f.scroll = CreateFrame("ScrollFrame", "SquidBotsLiteGroupQuestsScroll", f, "FauxScrollFrameTemplate")
	f.scroll:SetPoint("TOPLEFT", 16, -90)
	f.scroll:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -38, -90 - ROWS * ROW_H)
	f.scroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, ROW_H, GQ.Draw) end)
	f.scroll:SetFrameLevel(f:GetFrameLevel())
	local y = -96 - ROWS * ROW_H
	UI.Rule(f, y)
	-- The counts under each column: its log, to turn in, blocked.
	f.counts = {}
	for k, key in ipairs({ "C_LOG", "C_TURNIN", "C_BLOCKED" }) do
		local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		label:SetPoint("TOPLEFT", 34, y - 6 - (k - 1) * 14)
		label.key = key
		f.counts[k] = { label = label }
		for i = 1, MAX_ALTS + 1 do
			local s = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			s:SetPoint("TOPLEFT", X_COLS + (i == 1 and 0 or W_ME + (i - 2) * W_ALT), y - 6 - (k - 1) * 14)
			f.counts[k][i] = s
		end
	end
	f.selection = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.selection:SetPoint("TOPLEFT", 20, y - 52)
	f.selection:SetWidth(width - 40)
	f.selection:SetJustifyH("LEFT")
	f.actions = {}
	x = 16
	for _, def in ipairs({ { "SHARE", GQ.Share, "TIP_SHARE" }, { "TURNIN", GQ.TurnIn, "TIP_TURNIN" },
		{ "NOW", GQ.Now, "TIP_NOW" } }) do
		local b = Button(f, 110, def[1], function()
			if not GQ.selected then Status(T("NO_SEL")) return end
			def[2](GQ.selected)
		end, def[3])
		b:SetPoint("TOPLEFT", x, y - 70)
		x = x + 114
	end
	local drop = Button(f, 110, "DROP", function()
		if not GQ.selected then Status(T("NO_SEL")) return end
		for _, line in ipairs((GQ.Lines(GQ.Columns()))) do if line.id == GQ.selected then RowMenu(line) end end
	end, "TIP_DROP")
	drop:SetPoint("TOPLEFT", x, y - 70)
	local refresh = Button(f, 110, "REFRESH", function() GQ.AskAll(); GQ.Draw() end)
	refresh:SetPoint("TOPLEFT", x + 114, y - 70)
	f.status = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.status:SetPoint("TOPLEFT", 20, y - 98)
	f.status:SetWidth(width - 40)
	f.status:SetJustifyH("LEFT")
	-- The reward choice of a turnin: up to six item icons.
	local c = CreateFrame("Frame", nil, f)
	c:SetWidth(6 * 36 + 24)
	c:SetHeight(76)
	c:SetPoint("BOTTOM", f, "BOTTOM", 0, 40)
	c:SetBackdrop(UI.PANEL_BACKDROP)
	c:SetBackdropColor(0.06, 0.06, 0.08, 1)
	c:SetFrameLevel(f:GetFrameLevel() + 20)
	c.text = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	c.text:SetPoint("TOP", 0, -12)
	c.text:SetWidth(c:GetWidth() - 20)
	c.items = {}
	for i = 1, 6 do
		local b = UI.IconButton(c, 30, UI.UNKNOWN, function() return "" end, function() GQ.Choose(i) end)
		b:SetPoint("TOPLEFT", 12 + (i - 1) * 36, -32)
		b:SetScript("OnEnter", function(self)
			if not self.item then return end
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetHyperlink("item:" .. self.item)
			GameTooltip:Show()
		end)
		c.items[i] = b
	end
	c:Hide()
	f.choice = c
	UI.FlattenAll(f)
end

function GQ.ShowChoice()
	local c = GQ.frame and GQ.frame.choice
	if not c then return end
	local next_ = GQ.choices[1]
	if not next_ then c:Hide() return end
	c.text:SetText(string.format(T("CHOOSE"), UI.ClassName(next_.name), Title(next_.id)))
	for i, b in ipairs(c.items) do
		local item = next_.items[i]
		b.item = item
		if item then
			local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(item)
			b.icon:SetTexture(icon or UI.UNKNOWN)
			b:Show()
		else
			b:Hide()
		end
	end
	c:Show()
end

function GQ.PickMenu()
	local cols, alts = GQ.Columns()
	local shown = {}
	for i = 2, #cols do shown[cols[i]] = true end
	local items = { { text = T("PICK"), isTitle = true, notCheckable = true } }
	for _, name in ipairs(alts) do
		table.insert(items, { text = name, checked = shown[name], func = function() if not shown[name] then GQ.Pick(name) end end })
	end
	GQ.menu = GQ.menu or CreateFrame("Frame", "SquidBotsLiteGroupQuestsMenu", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(items, GQ.menu, "cursor", 0, 0, "MENU")
end

function GQ.Scroll(delta)
	local bar = _G.SquidBotsLiteGroupQuestsScrollScrollBar
	if bar then bar:SetValue(bar:GetValue() - delta * ROW_H * 3) end
end

function GQ.Draw()
	local f = GQ.frame
	if not f or not f:IsShown() then return end
	GQ.ReadPlayer()
	local cols, alts = GQ.Columns()
	local lines, counts, perCol = GQ.Lines(cols)
	f.title:SetText("SquidBots Manager - " .. T("TITLE"))
	for key, b in pairs(f.filters) do
		b:SetText(T("F_" .. key) .. (key ~= "all" and counts[key] > 0 and " " .. counts[key] or ""))
		if GQ.filter == key then b:LockHighlight() else b:UnlockHighlight() end
	end
	f.ignoredText:SetText(T("IGNORED"))
	f.sortButton:SetText(T("S_" .. GQ.sort))
	f.head:SetText(T("QUEST"))
	for i, h in ipairs(f.heads) do
		h:SetText(cols[i] and (i == 1 and T("YOU") or UI.ClassName(cols[i])) or "")
	end
	if #alts > MAX_ALTS then f.pick:Show() else f.pick:Hide() end
	f.pick:SetText(T("PICK"))
	FauxScrollFrame_Update(f.scroll, #lines, ROWS, ROW_H)
	local offset = FauxScrollFrame_GetOffset(f.scroll)
	local now = Plan().now
	for i, row in ipairs(f.rows) do
		local line = lines[offset + i]
		row.line = line
		if not line then
			row:Hide()
		else
			row:Show()
			if line.header then
				row.text:SetText(string.format("|cffffd100%s %s (%d)|r", GQ.collapsed[line.zone] and "+" or "-", line.zone, line.n))
				row.star:Hide()
				row.sel:Hide()
				for _, cell in ipairs(row.cells) do cell:Hide() end
				row.up:Hide(); row.down:Hide(); row.ignore:Hide()
			else
				local level = line.level and line.level > 0 and string.format("[%d] ", line.level) or ""
				local color = line.ignored and "|cff808080" or ""
				row.text:SetText(color .. level .. (line.title or "?") .. (color ~= "" and "|r" or ""))
				if line.id == now then row.star:Show() else row.star:Hide() end
				if line.id == GQ.selected then row.sel:Show() else row.sel:Hide() end
				for j, cell in ipairs(row.cells) do
					local c = line.cells[j]
					if c then
						cell.text:SetText(c.text)
						cell:Show()
						-- Once its log is in: a quest it lacks, not one still on its way.
						local name = cols[j]
						if c.unknown and j > 1 and GQ.log[name] and not GQ.pending[name] and not GQ.capture[name] then
							GQ.AskWhy(line.id, name)
						end
					else
						cell:Hide()
					end
				end
				row.up:Show(); row.down:Show(); row.ignore:Show()
			end
		end
	end
	for k, set in ipairs(f.counts) do
		set.label:SetText(T(set.label.key))
		for i = 1, MAX_ALTS + 1 do
			local c = perCol[i]
			set[i]:SetText(not c and "" or k == 1 and (c.log .. "/25") or k == 2 and c.turnin or c.blocked)
		end
	end
	local selected
	for _, line in ipairs(lines) do if line.id and line.id == GQ.selected then selected = line.title end end
	f.selection:SetText(selected and (T("QUEST") .. ": |cffffffff" .. selected .. "|r") or "")
	-- The status: an action's answer for 10 s, else who is on an older realm or silent, and how old the data is.
	local parts, old, silent = {}, {}, {}
	for i = 2, #cols do
		if GQ.mode[cols[i]] == "old" then table.insert(old, cols[i]) end
		if GQ.silent[cols[i]] then table.insert(silent, cols[i]) end
	end
	if GQ.status and GetTime() - GQ.statusAt < 10 then table.insert(parts, GQ.status) end
	if #alts == 0 then table.insert(parts, T("NO_ALT")) end
	if GQ.updated then table.insert(parts, string.format(T("UPDATED"), GetTime() - GQ.updated)) end
	if #old > 0 then table.insert(parts, string.format(T("OLD"), table.concat(old, ", "))) end
	if #silent > 0 then table.insert(parts, string.format(T("SILENT"), table.concat(silent, ", "))) end
	f.status:SetText(table.concat(parts, " - "))
end

-- Every 5 s while open: renew the watch, read the older realms again each minute, the age of the data.
function GQ.Tick(gen)
	if gen ~= GQ.tick or not (GQ.frame and GQ.frame:IsShown()) then return end
	local cols = GQ.Columns()
	for i = 2, #cols do
		local name = cols[i]
		if GQ.mode[name] == "ql" then GQ.Watch(name)
		elseif GQ.mode[name] == "old" and GetTime() - (GQ.oldAt[name] or 0) >= OLD_AGAIN then GQ.Old(name)
		elseif not GQ.mode[name] and not GQ.asked[name] then GQ.Ask(name) end
	end
	GQ.Draw()
	UI.After(TICK, function() GQ.Tick(gen) end)
end

function SquidBotsLite_ShowGroupQuests()
	A, UI = A or SquidBotsLite_Alts, UI or SquidBotsLite_UI
	if not GQ.frame then GQ.Build() end
	if GQ.frame:IsShown() then GQ.frame:Hide() return end
	if SquidBotsLiteAlts and SquidBotsLiteAlts:IsShown() then SquidBotsLiteAlts:Hide() end
	GQ.frame:Show()
	GQ.frame:Raise()
	GQ.AskAll()
	GQ.tick = GQ.tick + 1
	GQ.Tick(GQ.tick)
end

-- ---------------------------------------------------------------------------
-- Wiring: QL into Alts.lua's dispatcher; its QR, Q and OBJ seen here first
-- ---------------------------------------------------------------------------
A, UI = SquidBotsLite_Alts, SquidBotsLite_UI
local Handle = A.Handle
Handle.QL = GQ.OnQL
local altsQR, altsQ, altsOBJ = Handle.QR, Handle.Q, Handle.OBJ
Handle.QR = function(name, f)
	if GQ.OnQR(name, f) then GQ.Dirty() return end
	altsQR(name, f)
	GQ.Dirty()
end
-- A Q asked here only fills the grid: it does not open the quest giver's panel.
Handle.Q = function(name, f)
	local id = tonumber(f[2])
	local key = name .. ":" .. tostring(id)
	if id and GQ.qAsked[key] and GetTime() - GQ.qAsked[key] < Q_WAIT then
		GQ.qAsked[key] = GetTime() - Q_WAIT
		A.quests[id] = A.quests[id] or {}
		A.quests[id][name] = { state = f[3] or "other", detail = f[4] or "", catchable = f[5] == "1", at = GetTime() }
		GQ.Dirty()
		return
	end
	altsQ(name, f)
	GQ.Dirty()
end
Handle.OBJ = function(name, f)
	altsOBJ(name, f)
	GQ.Dirty()
end

-- The "quests all" lines: read once here, hidden from every chat frame while they are ours.
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:SetScript("OnEvent", function(_, event, text, sender)
	if event == "CHAT_MSG_WHISPER" then
		if A.IsAlt(sender) then GQ.OnWhisper(sender, text) end
	else
		GQ.Dirty()
	end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(_, _, text, sender)
	local until_ = GQ.hideUntil[sender or ""]
	if until_ and GetTime() <= until_ and Ours(text) then return true end
end)
