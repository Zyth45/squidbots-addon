-- SquidBots Manager, the key spells bar (CoA Bots 3.1.1). One row per bot of the group: its big cooldowns
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
-- The quick actions (Heal / CC / Taunt please): asked of one bot of the group by the addon message
--   qa <heal|cc|taunt> [<targetGUID>] -> QA done <action> <bot> <spellId> <cdMs> | QA none <action> <reason>
--   qastate -> QA st <action> <readyBots> <nextReadyMs> ... then QA -
-- The module picks the bot. A realm that never answers: the click says the phrase in group chat instead.
local QUICK, QUICK_ICON, QA_WAIT, QA_STATE_EVERY, QA_RETRY, STATUS_FOR = { "heal", "cc", "taunt" }, 32, 3, 5, 60, 8
local QUICK_SPELL = { heal = 2061, cc = 118, taunt = 355 } -- Flash Heal, Polymorph, Taunt: icons only
local QUICK_PHRASE = { heal = "heal me", cc = "cc please", taunt = "taunt please" }
-- The realm's categories (7th field of KSPELL it), shown on the full bar; anything else is left out.
local SHOWN_CAT = { def = true, burst = true, cc = true }

local STRINGS = {
	en = {
		TITLE = "Key spells", NO_BOT = "No bot of your group has a key spell yet.",
		TIP_CLICK = "Click: %s casts it %s.", ON_TARGET = "on your target, or on you", ON_SELF = "for the group",
		ON_DEAD = "on your dead target", ON_ENEMY = "on your enemy target", TIP_KEEP = "Right-click: keep it (the bot no longer casts it by itself).",
		TIP_UNKEEP = "Right-click: give it back to the bot.", TIP_KEPT = "Kept: only your click casts it.",
		TIP_READY = "Ready.", TIP_CD = "Cooldown: %d s.", TIP_GUESS = "Guessed from its class: the realm did not list it.",
		NEED_DEAD = "Target the dead player first.", NO_KEEP = "Keeping a spell needs the realm's update (keepcd).",
		CAST = "%s: %s...", KEPT = "%s keeps %s for your click.", FREED = "%s may cast %s by itself again.",
		KEEP_ERR = "%s: cannot keep %s (%s).", R_unknown = "unknown spell", R_off = "option off",
		B_BAR = "Key spells bar", B_heal = "Quick action: Heal please", B_cc = "Quick action: CC please", B_taunt = "Quick action: Taunt please",
		Q_heal = "Heal please", Q_cc = "CC please", Q_taunt = "Taunt please",
		TIP_Q_heal = "A healer bot heals your friendly target, or you.", TIP_Q_cc = "A bot crowd-controls your enemy target.",
		TIP_Q_taunt = "A tank bot taunts your enemy target.", TIP_Q_READY = "Bots ready: %d.",
		TIP_Q_OLD = "This realm has no quick actions: the click says \"%s\" in group chat.",
		Q_DONE = "%s: %s", Q_NONE = "%s: %s.", Q_SAID = "Said in group chat: %s", NO_GROUP_BOT = "No bot in your group.",
		N_notank = "no tank bot", N_nocc = "no crowd control ready", N_noheal = "no healer bot", N_cd = "all on cooldown",
		N_notarget = "no target", N_range = "out of range", N_off = "option off", N_unknown = "no bot could do it", N_busy = "the bot could not cast", N_notgroup = "your target is not in your group", N_immune = "the target is immune", N_held = "the tank already holds it", N_full = "the target has full health",
		TIP_FULL = "Show every key spell of your bots.", TIP_SMALL = "Only the three quick actions.",
	},
	fr = {
		TITLE = "Sorts clés", NO_BOT = "Aucun bot du groupe n'a encore de sort clé.",
		TIP_CLICK = "Clic : %s le lance %s.", ON_TARGET = "sur votre cible, ou sur vous", ON_SELF = "pour le groupe",
		ON_DEAD = "sur votre cible morte", ON_ENEMY = "sur votre cible ennemie", TIP_KEEP = "Clic droit : le garder (le bot ne le lance plus de lui-même).",
		TIP_UNKEEP = "Clic droit : le rendre au bot.", TIP_KEPT = "Gardé : seul votre clic le lance.",
		TIP_READY = "Prêt.", TIP_CD = "Recharge : %d s.", TIP_GUESS = "Déduit de sa classe : le royaume ne l'a pas listé.",
		NEED_DEAD = "Ciblez d'abord le joueur mort.", NO_KEEP = "Garder un sort demande la mise à jour du royaume (keepcd).",
		CAST = "%s : %s...", KEPT = "%s garde %s pour votre clic.", FREED = "%s peut de nouveau lancer %s de lui-même.",
		KEEP_ERR = "%s : impossible de garder %s (%s).", R_unknown = "sort inconnu", R_off = "option désactivée",
		B_BAR = "Barre des sorts clés", B_heal = "Action rapide : soin", B_cc = "Action rapide : contrôle", B_taunt = "Action rapide : provocation",
		Q_heal = "Heal please", Q_cc = "CC please", Q_taunt = "Taunt please",
		TIP_Q_heal = "Un bot soigneur soigne votre cible amie, ou vous.", TIP_Q_cc = "Un bot contrôle votre cible ennemie.",
		TIP_Q_taunt = "Un bot tank provoque votre cible ennemie.", TIP_Q_READY = "Bots prêts : %d.",
		TIP_Q_OLD = "Ce royaume n'a pas les actions rapides : le clic dit « %s » au groupe.",
		Q_DONE = "%s : %s", Q_NONE = "%s : %s.", Q_SAID = "Dit au groupe : %s", NO_GROUP_BOT = "Aucun bot dans votre groupe.",
		N_notank = "aucun bot tank", N_nocc = "aucun contrôle prêt", N_noheal = "aucun bot soigneur", N_cd = "tous en recharge",
		N_notarget = "aucune cible", N_range = "hors de portée", N_off = "option désactivée", N_unknown = "aucun bot n'a pu", N_busy = "le bot n'a pas pu lancer", N_notgroup = "votre cible n'est pas dans votre groupe", N_immune = "la cible est insensible", N_held = "le tank la tient déjà", N_full = "la cible a toute sa vie",
		TIP_FULL = "Afficher tous les sorts clés de vos bots.", TIP_SMALL = "Seulement les trois actions rapides.",
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

-- Never on the bar: utilities with a long cooldown that the realm lists too (CoA client ids, from its Spell.dbc),
-- by id, else by their exact English name: Stuck, Summon Friend and the other Refer-A-Friend spells, Hearthstone.
local EXCLUDED_IDS = { [7355] = true, [45927] = true, [48955] = true, [976240] = true, [8690] = true, [54318] = true,
	[304285] = true, [2117125] = true, [2136150] = true }
local EXCLUDED_NAMES = { ["Stuck"] = true, ["Summon Friend"] = true, ["Refer A Friend Summon Effect"] = true,
	["Incantation of Friendship"] = true, ["Hearthstone"] = true }
local function Excluded(id, name)
	return (id and EXCLUDED_IDS[id]) or (name and EXCLUDED_NAMES[name]) or false
end

-- ks.bots[name] = { server = { [spellName] = entry } or nil, seen = { [spellName] = entry }, asked, pending }
-- entry = { id, name, icon, aim, total, readyAt, kept, order, guess }
-- ks.qa: nil = not known yet, true = the realm answers the quick actions, false = it did not (since ks.qaFailAt).
-- ks.quick[action] = { ready, readyAt, total }; ks.qaPending = { action, at, bot } (the click waiting for its answer).
local ks = { bots = {}, byName = nil, status = nil, lastCast = {}, quick = {}, qa = nil }
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
	for i = #list, 1, -1 do
		if Excluded(list[i].id, list[i].name) then table.remove(list, i) end
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
	if f[1] == "QA" then return ks.OnQuick(sender, f) end
	local b = ks.bots[sender]
	if not b then return end
	if f[1] == "KSPELL" then
		if f[2] == "it" then
			local id = tonumber(f[3])
			local name, _, icon = GetSpellInfo(id or 0)
			if not name or Excluded(id, name) then return end
			local key = KeyByName()[name]
			local total = (tonumber(f[5]) or 0) / 1000
			local cat = f[7] ~= "" and f[7] or nil
			-- The realm says the category: def, burst and cc are shown, nothing else. Without it (a 3.1.1 realm), a
			-- spell that is not a key spell is shown only when it is a big cooldown (a CoA class's own).
			if cat then
				if not SHOWN_CAT[cat] then return end
			elseif not key and total < BIG_CD then
				return
			end
			b.pending = b.pending or {}
			b.pending[name] = { id = id, name = name, icon = icon, aim = key and key.aim or (cat == "cc" and "enemy") or "self",
				order = key and key.order or (cat == "cc" and 60) or 50, cat = cat,
				total = total > 0 and total or (key and key.total) or 0, readyAt = GetTime() + (tonumber(f[4]) or 0) / 1000, kept = f[6] == "1" }
		elseif f[2] == "-" then
			b.server = b.pending or {}
			b.pending = nil
			-- The keeps saved for this bot, sent again (the realm forgets them at logout).
			-- Saved by spell id (a client in another language keeps them); a name is a 3.1.1 save.
			local saved = SquidBotsLiteDB and SquidBotsLiteDB.keepcd and SquidBotsLiteDB.keepcd[sender]
			for _, e in pairs(b.server) do
				if saved and (saved[e.id] or saved[e.name]) and not e.kept then
					SendAddonMessage(PREFIX, "keepcd " .. e.id .. " on", "WHISPER", sender)
				end
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
			SquidBotsLiteDB.keepcd[sender][id] = on or nil
			SquidBotsLiteDB.keepcd[sender][name] = nil
			ks.Say(string.format(T(on and "KEPT" or "FREED"), sender, name))
		elseif f[2] == "err" then
			ks.Say(string.format(T("KEEP_ERR"), sender, name or id, T("R_" .. (f[4] or "unknown"))))
		end
		Changed()
	end
end

-- The combat log: a bot of the group casts a key spell (its click or its own choice): cooldown starts.
function ks.OnCast(sourceName, spellId, spellName)
	-- The group's bots only: not every bot casting within reach of the combat log.
	if not sourceName or not IsBot(sourceName) or not (SquidBotsLite_InGroup and SquidBotsLite_InGroup(sourceName)) then return end
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
	elseif e.aim == "enemy" then
		-- A crowd control: on your enemy target ("cast" without "on" = the master's target).
		if not (UnitExists("target") and UnitCanAttack("player", "target")) then
			ks.Say(string.format(T("Q_NONE"), e.name, T("N_notarget")))
			return
		end
	else
		on = bot
	end
	ks.lastCast[bot] = GetTime()
	-- The spell's link: the server reads its id (any client language), then casts the bot's best rank of it.
	SendChatMessage("cast " .. (GetSpellLink(e.id) or e.id) .. (on and " on " .. on or ""), "WHISPER", nil, bot)
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

-- The quick actions.
local function GroupChannel()
	if GetNumRaidMembers() > 0 then return "RAID" end
	if GetNumPartyMembers() > 0 then return "PARTY" end
	return "SAY"
end

local function Quick(action)
	local q = ks.quick[action]
	if not q then
		q = {}
		ks.quick[action] = q
	end
	return q
end

-- Does the realm answer? After a silence, asked again every QA_RETRY seconds (a realm updated meanwhile).
function ks.QuickKnown()
	if ks.qa == false and GetTime() - (ks.qaFailAt or 0) > QA_RETRY then ks.qa = nil end
	return ks.qa
end

-- The phrase in group chat: what an older realm understands (and what you would type yourself).
function ks.QuickSay(action)
	SendChatMessage(QUICK_PHRASE[action], GroupChannel())
	ks.Say(string.format(T("Q_SAID"), QUICK_PHRASE[action]))
end

-- A click (or its key): one bot of the group is asked; the module picks who does it.
function ks.QuickAct(action)
	if not QUICK_PHRASE[action] then return end
	local bots = ks.Bots()
	if #bots == 0 then
		ks.Say(T("NO_GROUP_BOT"))
		return
	end
	if ks.QuickKnown() == false then return ks.QuickSay(action) end
	local guid
	if action == "heal" then
		if UnitExists("target") and UnitIsFriend("player", "target") and not UnitIsDeadOrGhost("target") then
			guid = UnitGUID("target")
		else
			guid = UnitGUID("player")
		end
	elseif UnitExists("target") and UnitCanAttack("player", "target") then
		guid = UnitGUID("target")
	end
	ks.qaPending = { action = action, at = GetTime(), bot = bots[1].name }
	SendAddonMessage(PREFIX, "qa " .. action .. (guid and " " .. guid or ""), "WHISPER", bots[1].name)
	ks.status = T("Q_" .. action) .. "..."
	ks.statusAt = GetTime()
	Changed()
end

-- The state of the three buttons, asked while the bar is up.
function ks.QuickAsk()
	if ks.QuickKnown() == false then return end
	local now = GetTime()
	if ks.qaAsked and now - ks.qaAsked < QA_STATE_EVERY then return end
	local bots = ks.Bots()
	if #bots == 0 then return end
	ks.qaAsked = now
	if ks.qa == nil and not ks.qaProbe then ks.qaProbe = now end
	SendAddonMessage(PREFIX, "qastate", "WHISPER", bots[1].name)
end

-- No answer in time: the realm does not have them. A waiting click is said in group chat instead.
function ks.QuickTick()
	local now = GetTime()
	local p = ks.qaPending
	if p and now - p.at > QA_WAIT then
		ks.qaPending = nil
		if ks.qa ~= true then
			ks.qa, ks.qaFailAt, ks.qaProbe = false, now, nil
			ks.QuickSay(p.action)
		else
			ks.Say(string.format(T("Q_NONE"), T("Q_" .. p.action), T("N_unknown")))
		end
	end
	if ks.qaProbe and now - ks.qaProbe > QA_WAIT then
		ks.qaProbe = nil
		if ks.qa == nil then ks.qa, ks.qaFailAt = false, now; Changed() end
	end
	if ks.statusAt and now - ks.statusAt > STATUS_FOR then
		ks.statusAt, ks.status = nil, nil
		Changed()
	end
end

function ks.OnQuick(sender, f)
	if not IsBot(sender) and not ks.bots[sender] then return end
	ks.qa, ks.qaProbe = true, nil
	local action = f[3]
	if f[2] == "st" and QUICK_PHRASE[action] then
		local q = Quick(action)
		q.ready = tonumber(f[4]) or 0
		local wait = (tonumber(f[5]) or 0) / 1000
		if q.ready == 0 and wait > 0 then
			q.readyAt = GetTime() + wait
			q.total = math.max(q.total or 0, wait)
		else
			q.readyAt, q.total = nil, nil
		end
	elseif f[2] == "done" and QUICK_PHRASE[action] then
		local p = ks.qaPending
		if p and p.action == action then ks.qaPending = nil end
		local spell = GetSpellInfo(tonumber(f[5]) or 0) or f[5] or "?"
		ks.Say(string.format(T("Q_DONE"), f[4] or sender, spell))
		ks.statusAt = GetTime()
		local cd = (tonumber(f[6]) or 0) / 1000
		local q = Quick(action)
		if cd > 0 then q.readyAt, q.total = GetTime() + cd, cd end
	elseif f[2] == "err" then
		-- An action the module does not know (a newer addon on an older module): said in group chat instead.
		local p = ks.qaPending
		ks.qaPending = nil
		if p then ks.QuickSay(p.action) end
	elseif f[2] == "none" and QUICK_PHRASE[action] then
		local p = ks.qaPending
		if p and p.action == action then ks.qaPending = nil end
		local reason = f[4] or "unknown"
		local text = STRINGS.en["N_" .. reason] and T("N_" .. reason) or reason
		ks.Say(string.format(T("Q_NONE"), T("Q_" .. action), text))
		ks.statusAt = GetTime()
	end
	Changed()
end

function SquidBotsLite_Quick(action)
	if SquidBotsLiteDB then ks.QuickAct(action) end
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
	local where = e.aim == "dead" and T("ON_DEAD") or e.aim == "enemy" and T("ON_ENEMY") or e.aim == "ally" and T("ON_TARGET") or T("ON_SELF")
	GameTooltip:AddLine(string.format(T("TIP_CLICK"), bot, where), 0.4, 0.8, 1, true)
	local left = (e.readyAt or 0) - GetTime()
	GameTooltip:AddLine(left > 0 and string.format(T("TIP_CD"), math.ceil(left)) or T("TIP_READY"), 1, 1, 1)
	if e.kept then GameTooltip:AddLine(T("TIP_KEPT"), 1, 0.6, 0.2, true) end
	if e.guess then GameTooltip:AddLine(T("TIP_GUESS"), 0.6, 0.6, 0.6, true) end
	local b = ks.bots[bot]
	if b and b.server and b.server[e.name] then GameTooltip:AddLine(T(e.kept and "TIP_UNKEEP" or "TIP_KEEP"), 0.6, 0.6, 0.6, true) end
	GameTooltip:Show()
end

-- Dragging a bar (or one of its buttons) moves it; the place is saved in SquidBotsLiteDB[key].
local function Movable(f, key, default)
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relative, x, y = self:GetPoint()
		SquidBotsLiteDB[key] = { point, relative, x, y }
	end)
	local saved = SquidBotsLiteDB[key]
	if saved then f:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4]) else f:SetPoint("CENTER", default[1], default[2]) end
end

local function QuickTooltip(self)
	local action = self.action
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(T("Q_" .. action))
	GameTooltip:AddLine(T("TIP_Q_" .. action), 0.4, 0.8, 1, true)
	local q = ks.quick[action]
	if ks.qa == false then
		GameTooltip:AddLine(string.format(T("TIP_Q_OLD"), QUICK_PHRASE[action]), 0.6, 0.6, 0.6, true)
	elseif q and q.ready then
		GameTooltip:AddLine(string.format(T("TIP_Q_READY"), q.ready), 1, 1, 1)
	end
	local left = q and (q.readyAt or 0) - GetTime() or 0
	if left > 0 then GameTooltip:AddLine(string.format(T("TIP_CD"), math.ceil(left)), 1, 1, 1) end
	GameTooltip:Show()
end

-- The three quick action buttons, on a bar (parent); dragging one moves the bar.
local function QuickButtons(parent, size, x, y)
	local list = {}
	for i, action in ipairs(QUICK) do
		local b = CreateFrame("Button", nil, parent)
		b.action = action
		b:SetWidth(size)
		b:SetHeight(size)
		b:SetPoint("TOPLEFT", x + (i - 1) * (size + 4), y)
		b:RegisterForClicks("LeftButtonUp")
		b:RegisterForDrag("LeftButton")
		b:SetScript("OnDragStart", function() parent:StartMoving() end)
		b:SetScript("OnDragStop", function() parent:GetScript("OnDragStop")(parent) end)
		b.icon = b:CreateTexture(nil, "ARTWORK")
		b.icon:SetAllPoints()
		b.icon:SetTexture(select(3, GetSpellInfo(QUICK_SPELL[action])) or "Interface\\Icons\\INV_Misc_QuestionMark")
		b.cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
		b.cd:SetAllPoints()
		b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
		b.count:SetPoint("BOTTOMRIGHT", -1, 1)
		b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		b:SetScript("OnClick", function(self) ks.QuickAct(self.action) end)
		b:SetScript("OnEnter", QuickTooltip)
		b:SetScript("OnLeave", function() GameTooltip:Hide() end)
		list[i] = b
	end
	return list
end

local function DrawQuick(list)
	for _, b in ipairs(list or {}) do
		local q = ks.quick[b.action]
		local left = q and (q.readyAt or 0) - GetTime() or 0
		if left > 0 and (q.total or 0) > 0 then b.cd:SetCooldown(q.readyAt - q.total, q.total) else b.cd:SetCooldown(0, 0) end
		b.count:SetText(ks.qa and q and q.ready and q.ready > 0 and q.ready or "")
	end
end

-- A small text button ("+", "-", "x").
local function TextButton(parent, text, tip, onClick)
	local b = CreateFrame("Button", nil, parent)
	b:SetWidth(14)
	b:SetHeight(14)
	b:SetNormalFontObject(GameFontNormalSmall)
	b:SetHighlightFontObject(GameFontHighlightSmall)
	b:SetText(text)
	b:SetScript("OnClick", onClick)
	if tip then
		b:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(T(tip), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end
	return b
end

local small

local function Tick(self, elapsed)
	self.since = (self.since or 0) + elapsed
	if self.since < 0.5 then return end
	self.since = 0
	if frame and frame:IsShown() then ks.Ask() end
	ks.QuickAsk()
	if ks.dirty then ks.Draw() end
end

local function BuildSmall()
	small = CreateFrame("Frame", "SquidBotsLiteQuickBar", UIParent)
	small:SetWidth(8 + 3 * (QUICK_ICON + 4) + 16)
	small:SetHeight(QUICK_ICON + 8)
	small:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16 })
	small:SetBackdropColor(0, 0, 0, 0.35)
	small:SetFrameStrata("MEDIUM")
	Movable(small, "keyQuick", { 0, -140 })
	small.buttons = QuickButtons(small, QUICK_ICON, 4, -4)
	local more = TextButton(small, "+", "TIP_FULL", function() ks.SetMode("full") end)
	more:SetPoint("TOPRIGHT", -2, -3)
	local close = TextButton(small, "x", nil, function() SquidBotsLite_ToggleKeySpells() end)
	close:SetPoint("BOTTOMRIGHT", -2, 3)
	small.status = small:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	small.status:SetPoint("TOP", small, "BOTTOM", 0, -2)
	small:SetScript("OnShow", function() ks.qaAsked = nil; Changed() end)
	small:SetScript("OnUpdate", Tick)
end

local function Build()
	frame = CreateFrame("Frame", "SquidBotsLiteKeySpells", UIParent)
	frame:SetWidth(NAME_W + MAX_ICONS * (ICON + 3) + 20)
	frame:SetHeight(60)
	frame:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
	frame:SetBackdropColor(0, 0, 0, 0.75)
	frame:SetFrameStrata("MEDIUM")
	Movable(frame, "keyBar", { 0, -180 })
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.title:SetPoint("TOPLEFT", 8, -7)
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetWidth(20)
	close:SetHeight(20)
	close:SetPoint("TOPRIGHT", 0, 0)
	close:SetScript("OnClick", function() SquidBotsLite_ToggleKeySpells() end)
	local less = TextButton(frame, "-", "TIP_SMALL", function() ks.SetMode("small") end)
	less:SetPoint("TOPRIGHT", -22, -4)
	-- The quick actions first, then one row per bot.
	frame.quick = QuickButtons(frame, ICON, 8 + NAME_W, -22)
	local top = -22 - (ICON + 6)
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
		row.label:SetPoint("TOPLEFT", 8, top - (r - 1) * (ICON + 3) - 7)
		for i = 1, MAX_ICONS do
			local b = CreateFrame("Button", nil, frame)
			b:SetWidth(ICON)
			b:SetHeight(ICON)
			b:SetPoint("TOPLEFT", 8 + NAME_W + (i - 1) * (ICON + 3), top - (r - 1) * (ICON + 3))
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
	frame:SetScript("OnShow", function() ks.Ask(true); ks.qaAsked = nil; Changed() end)
	frame:SetScript("OnUpdate", Tick)
end

function ks.Draw()
	ks.dirty = nil
	if small and small:IsShown() then
		DrawQuick(small.buttons)
		small.status:SetText(ks.status or "")
	end
	if not frame or not frame:IsShown() then return end
	DrawQuick(frame.quick)
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
	frame:SetHeight(22 + (ICON + 6) + math.max(#rows, 1) * (ICON + 3) + 22)
end

-- Shown or not, and which bar: the small one (the three quick actions) or the full one. Both are remembered.
-- Plain frames, nothing secure: showing, hiding or moving them in combat is fine.
function ks.Mode()
	return SquidBotsLiteDB and SquidBotsLiteDB.keyMode == "full" and "full" or "small"
end

function ks.Apply()
	local shown, full = SquidBotsLiteDB.keyBarShown, ks.Mode() == "full"
	if shown and full and not frame then Build() end
	if shown and not full and not small then BuildSmall() end
	if frame then if shown and full then frame:Show() else frame:Hide() end end
	-- The combat log (cooldowns seen cast) is read only while the full bar is up.
	if ks.events then
		if shown and full then ks.events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else ks.events:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end
	end
	if small then if shown and not full then small:Show() else small:Hide() end end
	Changed()
end

function ks.SetMode(mode)
	if not SquidBotsLiteDB then return end
	SquidBotsLiteDB.keyMode = mode
	SquidBotsLiteDB.keyBarShown = true
	ks.Apply()
end

function SquidBotsLite_ToggleKeySpells()
	if not SquidBotsLiteDB then return end
	SquidBotsLiteDB.keyBarShown = not SquidBotsLiteDB.keyBarShown
	ks.Apply()
end

local function BindingNames()
	BINDING_NAME_SQUIDBOTSLITE_KEYS = T("B_BAR")
	BINDING_NAME_SQUIDBOTSLITE_QHEAL = T("B_heal")
	BINDING_NAME_SQUIDBOTSLITE_QCC = T("B_cc")
	BINDING_NAME_SQUIDBOTSLITE_QTAUNT = T("B_taunt")
end
BindingNames()
ks.BindingNames = BindingNames

local events = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_LOGIN", "CHAT_MSG_ADDON", "CHAT_MSG_WHISPER", "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE" }) do
	events:RegisterEvent(event)
end
ks.events = events
-- The quick actions' answers are awaited even with the bars hidden (a key binding).
local since = 0
events:SetScript("OnUpdate", function(_, elapsed)
	since = since + elapsed
	if since < 0.25 then return end
	since = 0
	ks.QuickTick()
end)
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
		BindingNames()
		if SquidBotsLiteDB and SquidBotsLiteDB.keyBarShown then ks.Apply() end
	else
		Changed()
	end
end)
