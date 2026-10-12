-- SquidBots Lite, bot sheet (beta): the gear, bags, quests and stats of one bot of the group, for players who
-- keep a long-term party of alts. Everything goes through chat commands a player can whisper to their own
-- bots ("c", "quests all", "stats", "e", "ue", "u", "s", "t", "mount", "bank", "drop", "co ?", "nc ?", "talents ?"); the gear is read
-- by the client's own inspect.

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
		FOR_GROUND = "favourite on the ground", FOR_FLYING = "favourite in the air",
		GROUND = "ground", FLYING = "flying", BOTH = "ground and flying",
		MOUNT_HINT = "Click a mount: your bot rides it from now on. One ground and one flying favourite; a ground-and-flying mount is both. Automatic choice: the bot picks again.",
		NO_MOUNT_CMD = "No answer: this server's CoA Bots has no mount command yet (2.1 or later).",
		NO_MOUNTS = "This bot knows no mount.",
		USAGE = "/sbl bot <name>, or target a bot of your group and type /sbl bot.",
		NOT_A_MEMBER = "%s is not in your group.",
		STRATS = "Strategies", COMBAT = "In combat", NONCOMBAT = "Out of combat", ADD = "Add...",
		STRAT_HINT = "Click a strategy to remove it; Add... to give one. The server resets them on a specialization switch.",
		BANK = "Bank", BAGS_BTN = "Bags", DEPOSIT = "Put in the bank", WITHDRAW = "Take from the bank",
		NO_BANKER = "No banker next to the bot: the bank opens only when the bot stands by a banker.",
		ABANDON = "Abandon this quest", ABANDON_ASK = "%s abandons %s?", QUEST_HINT = "Right-click a quest to abandon it.",
		DROP_HINT = "Drop an item from your bags here to give it to the bot (a trade opens).",
		GOLD = "Gold", SPEC = "Spec", XP = "XP", ILVL = "Item level %d", LEVEL = "Level %d %s",
		MODEL_HINT = "Drag to turn it.",
		TALENTS = "Talents", T_SPENT = "Talent points spent: %d", T_AUTOPICK = "Reset to the build",
		T_AUTOPICK_ASK = "%s takes again the talents of its specialization's build for its level?",
		T_NONE = "No talent learnt yet.", T_NO_CMD = "No answer: this server's CoA Bots has no talent list yet (2.1 or later, CoA classes).",
		T_HINT = "The talents and paid abilities this bot learnt, by tree. An alt's talents are yours to choose; a random bot keeps the community build of its spec (Reset to the build).",
		T_ABILITY = "ability", T_REQUIRES = "Requires: %s", T_CAN = "Can be learnt now.", T_CANNOT = "Not yet: level, a prerequisite talent or points missing. Queued after its prerequisite, Save takes it in turn.",
		T_CHOOSE = "Choose talents", T_SAVE = "Save (%d)", T_CANCEL = "Cancel", T_BACK = "Learnt talents",
		T_POINTS = "Spec: %d spent, %d left  -  Class: %d spent, %d left",
		T_LEFT = "Left after your choices: spec %d, class %d", T_CLASS = "class", T_SPEC = "spec",
		T_REQ = "level %d", T_COST = "cost %d",
		T_CHOOSE_HINT = "+ adds a rank, - takes it back: nothing changes until Save. A saved rank cannot be taken back (Reset to the build can).",
		T_NO_OPTIONS = "No talent to choose (CoA classes only, CoA Bots 2.1 or later).", T_SAVING = "Learning %d ranks...",
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
		FOR_GROUND = "préférée au sol", FOR_FLYING = "préférée en vol",
		GROUND = "sol", FLYING = "vol", BOTH = "sol et vol",
		MOUNT_HINT = "Cliquez une monture : votre bot la prend désormais. Une préférée au sol, une en vol ; une monture sol et vol compte pour les deux. Choix automatique : le bot choisit à nouveau.",
		NO_MOUNT_CMD = "Pas de réponse : le CoA Bots de ce serveur n'a pas encore la commande des montures (2.1 ou plus).",
		NO_MOUNTS = "Ce bot ne connaît aucune monture.",
		USAGE = "/sbl bot <nom>, ou ciblez un bot de votre groupe et tapez /sbl bot.",
		NOT_A_MEMBER = "%s n'est pas dans votre groupe.",
		STRATS = "Stratégies", COMBAT = "En combat", NONCOMBAT = "Hors combat", ADD = "Ajouter...",
		STRAT_HINT = "Cliquez une stratégie pour la retirer ; Ajouter... pour en donner une. Le serveur les remet à zéro à un changement de spé.",
		BANK = "Banque", BAGS_BTN = "Sacs", DEPOSIT = "Mettre à la banque", WITHDRAW = "Reprendre de la banque",
		NO_BANKER = "Pas de banquier à côté du bot : la banque ne s'ouvre que si le bot est devant un banquier.",
		ABANDON = "Abandonner cette quête", ABANDON_ASK = "%s abandonne %s ?", QUEST_HINT = "Clic droit sur une quête pour l'abandonner.",
		DROP_HINT = "Déposez ici un objet de vos sacs pour le donner au bot (un échange s'ouvre).",
		GOLD = "Or", SPEC = "Spé", XP = "XP", ILVL = "Niveau d'objet %d", LEVEL = "Niveau %d %s",
		MODEL_HINT = "Faites glisser pour le tourner.",
		TALENTS = "Talents", T_SPENT = "Points de talent dépensés : %d", T_AUTOPICK = "Remettre le build",
		T_AUTOPICK_ASK = "%s reprend les talents du build de sa spé pour son niveau ?",
		T_NONE = "Aucun talent appris pour l'instant.", T_NO_CMD = "Pas de réponse : le CoA Bots de ce serveur n'a pas encore la liste des talents (2.1 ou plus, classes CoA).",
		T_HINT = "Les talents et capacités achetées de ce bot, par arbre. Ceux d'un alt sont à vous de choisir ; un bot aléatoire garde le build de la communauté pour sa spé (Remettre le build).",
		T_ABILITY = "capacité", T_REQUIRES = "Prérequis : %s", T_CAN = "Peut être appris maintenant.", T_CANNOT = "Pas encore : il manque le niveau, un talent prérequis ou des points. Ajouté après son prérequis, Sauvegarder le prend à son tour.",
		T_CHOOSE = "Choisir les talents", T_SAVE = "Sauvegarder (%d)", T_CANCEL = "Annuler", T_BACK = "Talents appris",
		T_POINTS = "Spé : %d dépensés, %d restants  -  Classe : %d dépensés, %d restants",
		T_LEFT = "Restants après vos choix : spé %d, classe %d", T_CLASS = "classe", T_SPEC = "spé",
		T_REQ = "niveau %d", T_COST = "coût %d",
		T_CHOOSE_HINT = "+ ajoute un rang, - le retire : rien ne change avant Sauvegarder. Un rang sauvegardé ne se retire plus (Remettre le build, si).",
		T_NO_OPTIONS = "Aucun talent à choisir (classes CoA seulement, CoA Bots 2.1 ou plus).", T_SAVING = "Apprentissage de %d rangs...",
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
local QUIET, GIVE_UP, REPEAT_DELAY = 0.7, 6, 2.1
local BAG_COLS, BAG_ROWS, QUEST_ROWS, MOUNT_ROWS = 8, 6, 14, 11
-- Inventory slot ids of the 3.3.5 client, left column, right column, then weapons.
local GEAR_LEFT = { 1, 2, 3, 15, 5, 4, 19, 9 }
local GEAR_RIGHT = { 10, 6, 7, 8, 11, 12, 13, 14 }
local GEAR_BOTTOM = { 16, 17, 18 }

local COMBAT_STRATS = { "avoid aoe", "behind", "threat", "dps aoe", "focus", "passive", "aggressive", "wait for attack",
	"tank face", "mark rti", "pull back", "potions", "racials", "flee", "kite" }
local NONCOMBAT_STRATS = { "follow", "stay", "grind", "loot", "gather", "food", "quest", "accept all quests", "rpg",
	"travel", "mount", "buff", "maintenance", "ready check", "emote", "chat", "duel", "sit" }

local sheet, current, tab
local capture, hideFrom, lastAsked = nil, {}, {}
local bags, quests, stats, mounts, bank = {}, {}, {}, {}, {}
local talents, talentSpent, talentOffset = {}, nil, 0
-- Choosing talents: what the bot may take ("talents options"), the ranks the player adds before Save, and the
-- points each tree has left ("Talent points: N spent, M left", "Class points: N spent, M left").
local options, pending, points, choosing = {}, {}, nil, false
local saveQueue, saveNext = {}, 0
local strats = { co = {}, nc = {} }
local bagMode = "bags"
local queue = {}
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
	if capture then
		for _, q in ipairs(queue) do if q.kind == kind then return end end
		table.insert(queue, { kind = kind, command = command })
		return
	end
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

-- "Strategies: a, b, c" (Engine::ListStrategies).
local function ParseStrats(lines)
	local list = {}
	for _, line in ipairs(lines) do
		local body = line:match("^Strategies: ?(.*)$")
		if body then
			for name in body:gmatch("[^,]+") do table.insert(list, strtrim(name)) end
		end
	end
	table.sort(list)
	return list
end

-- The stats line, "12g 30s 5c, ...": the first line that starts with money. Another answer of the bot can come
-- in the same window ("Strategies: ..." once showed as its gold).
local function StatsLine(lines)
	for _, line in ipairs(lines) do
		if line:find("^%d+[gsc]") or line:find("^0,") then return line end
	end
end

local function GoldOf(lines)
	local line = StatsLine(lines)
	return line and line:match("^([^,]+)")
end

local function ParseTalents(lines)
	local list, spent = {}, nil
	for _, line in ipairs(lines) do
		local id = tonumber(line:match("^Talent: .-|Hspell:(%d+)|h"))
		if id then
			local rank, max = line:match("rank (%d+)/(%d+)")
			table.insert(list, { id = id, name = line:match("|h%[(.-)%]|h") or "?", rank = tonumber(rank) or 1,
				max = tonumber(max) or 1, tree = line:match("%(tree (.-)%)") or "",
				ability = line:find("%d ability") ~= nil })
		end
		spent = tonumber(line:match("^Talent points: (%d+) spent")) or spent
		local ss, sl = line:match("^Talent points: (%d+) spent, (%d+) left")
		if ss then points = points or {}; points.specSpent, points.specLeft = tonumber(ss), tonumber(sl) end
		local cs, cl = line:match("^Class points: (%d+) spent, (%d+) left")
		if cs then points = points or {}; points.classSpent, points.classLeft = tonumber(cs), tonumber(cl) end
	end
	table.sort(list, function(a, b)
		if a.tree ~= b.tree then return a.tree < b.tree end
		return a.name < b.name
	end)
	return list, spent
end

-- "Talent option: <link> entry 123 rank 0/3 cost 1 spec level 10 (can learn)", then "Talent options: N".
local function ParseOptions(lines)
	local list = {}
	for _, line in ipairs(lines) do
		local id = tonumber(line:match("^Talent option: .-|Hspell:(%d+)|h"))
		local entry, rank, max, cost, kind, level = line:match("entry (%d+) rank (%d+)/(%d+) cost (%d+) (%a+) level (%d+)")
		if id and entry then
			local requires = {}
			for req in line:gmatch("requires (%d+) rank %d+") do table.insert(requires, tonumber(req)) end
			table.insert(list, { id = id, name = line:match("|h%[(.-)%]|h") or "?", entry = tonumber(entry), requires = requires,
				rank = tonumber(rank), max = tonumber(max), cost = tonumber(cost), kind = kind, level = tonumber(level),
				canLearn = line:find("(can learn)", 1, true) ~= nil })
		end
	end
	table.sort(list, function(a, b)
		if a.kind ~= b.kind then return a.kind == "class" end
		if a.level ~= b.level then return a.level < b.level end
		return a.name < b.name
	end)
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
		-- Same page after a choice (the list comes back in the same order); back to the top for another bot.
		mountOffset = math.min(mountOffset, math.max(0, #mounts - MOUNT_ROWS))
	elseif done.kind == "bank" then
		bank = ParseBags(done.lines)
	elseif done.kind == "talents" then
		talents, talentSpent = ParseTalents(done.lines)
		talentOffset = 0
	elseif done.kind == "options" then
		options = ParseOptions(done.lines)
		talentOffset = 0
	elseif done.kind == "co" or done.kind == "nc" then
		strats[done.kind] = ParseStrats(done.lines)
	else
		stats = done.lines
		sheet.gold = GoldOf(done.lines) or sheet.gold
		local line = StatsLine(done.lines)
		if SquidBotsLite_NoteStats and line then SquidBotsLite_NoteStats(done.name, line) end
	end
	local banker = done.kind == "bank" and done.lines[1] and done.lines[1]:find("banker", 1, true)
	if banker then
		sheet.status:SetText(T("NO_BANKER"))
	elseif #done.lines == 0 then
		sheet.status:SetText(done.kind == "mounts" and T("NO_MOUNT_CMD") or (done.kind == "talents" or done.kind == "options") and T("T_NO_CMD") or T("NO_REPLY"))
	else
		sheet.status:SetText("")
	end
	Render()
	local nextOne = table.remove(queue, 1)
	if nextOne then Ask(nextOne.kind, nextOne.command) end
end

local watch = CreateFrame("Frame")
watch:RegisterEvent("CHAT_MSG_WHISPER")
watch:RegisterEvent("INSPECT_TALENT_READY")
watch:RegisterEvent("UNIT_INVENTORY_CHANGED")
watch:SetScript("OnEvent", function(_, event, message, sender)
	if event == "CHAT_MSG_WHISPER" then
		if capture and sender == capture.name then
			-- The inventory starts with its own title: earlier chatter of the bot is not part of it.
			if (capture.kind == "bags" and message == "=== Inventory ===") or (capture.kind == "bank" and message == "=== Bank ===") then
				capture.lines = {}
			else
				table.insert(capture.lines, message)
			end
			capture.last = GetTime()
			if (capture.kind == "mounts" and message:find("^Mounts: %d+")) or (capture.kind == "talents" and message:find("^Talents: %d+"))
				or (capture.kind == "options" and message:find("^Talent options: %d+")) then Finish()
			elseif (capture.kind == "co" or capture.kind == "nc") and message:find("^Strategies:") then Finish() end
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
local MENU_HIDE_DELAY = 1
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
			if tab == "bags" then Ask(bagMode, bagMode == "bank" and "bank" or "c")
			elseif tab == "mounts" then Ask("mounts", "mount ?")
			elseif tab == "talents" then Ask("talents", "talents ?"); if choosing then Ask("options", "talents options") end
			elseif tab == "strats" then Ask("co", "co ?"); Ask("nc", "nc ?")
			elseif tab == "gear" then Render() end
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

-- An item dropped on the bags goes to the bot by trade: the trade opens, then the item on the cursor is put
-- in its first slot (TRADE_SHOW). The bot takes what its master gives.
local pendingDrop
local function DropOnBags()
	if not CursorHasItem() or not current then return end
	local unit = UnitOf(current)
	if not unit or not CheckInteractDistance(unit, 2) then
		ClearCursor()
		Print(T("TRADE_RANGE"))
		return
	end
	pendingDrop = GetTime() + 5
	InitiateTrade(unit)
end

local tradeWatch = CreateFrame("Frame")
tradeWatch:RegisterEvent("TRADE_SHOW")
tradeWatch:SetScript("OnEvent", function()
	if pendingDrop and GetTime() < pendingDrop and CursorHasItem() then
		ClickTradeButton(1)
	end
	pendingDrop = nil
	-- A trade with one of the group's bots opens its sheet on the bags (/sbl sheettrade off to stop).
	local partner = UnitName("NPC")
	if partner and SquidBotsLiteDB.sheetOnTrade ~= false and SquidBotsLite_OpenSheet and UnitOf(partner)
		and (partner:find(" Bot$") or (SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[partner])) then
		tab = "bags"
		SquidBotsLite_OpenSheet(partner)
	end
end)

local function ItemMenu(item)
	local link = SendableLink(item)
	if bagMode == "bank" then
		EasyMenu({
			{ text = item.link, isTitle = true, notCheckable = true },
			{ text = T("WITHDRAW"), notCheckable = true, func = function() Whisper("bank -" .. link); AfterChange() end },
			{ text = T("LINK"), notCheckable = true, func = function() ChatEdit_InsertLink(link) end },
		}, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
		return
	end
	EasyMenu({
		{ text = item.link, isTitle = true, notCheckable = true },
		item.soulbound and { text = T("SOULBOUND"), notCheckable = true, disabled = true }
			or { text = T("GIVE"), notCheckable = true, func = function() Give(link); AfterChange() end },
		{ text = T("EQUIP"), notCheckable = true, func = function() Whisper("e " .. link); AfterChange() end },
		{ text = T("USE"), notCheckable = true, func = function() Whisper("u " .. link); AfterChange() end },
		{ text = T("SELL"), notCheckable = true, func = function() Sell(link); AfterChange() end },
		{ text = T("DEPOSIT"), notCheckable = true, func = function() Whisper("bank " .. link); AfterChange() end },
		{ text = T("LINK"), notCheckable = true, func = function() ChatEdit_InsertLink(link) end },
	}, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
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
	for i, slot in ipairs(GEAR_RIGHT) do Slot(slot, 400, -(i - 1) * 40) end
	for i, slot in ipairs(GEAR_BOTTOM) do Slot(slot, 162 + (i - 1) * 44, -330) end
	-- The bot itself, as on the game's character sheet; drag to turn it. Needs the bot in the group and seen.
	page.model = CreateFrame("PlayerModel", nil, page)
	-- Its frame starts right under the header line: room above a tall headdress or a helm's horns.
	page.model:SetPoint("TOPLEFT", 56, -6)
	page.model:SetPoint("BOTTOMRIGHT", page, "TOPRIGHT", -62, -272)
	page.model:EnableMouse(true)
	page.model.facing = 0
	page.model:SetScript("OnMouseDown", function(self) self.dragX = GetCursorPosition() end)
	page.model:SetScript("OnMouseUp", function(self) self.dragX = nil end)
	page.model:SetScript("OnUpdate", function(self)
		if not self.dragX then return end
		local x = GetCursorPosition()
		self.facing = self.facing + (x - self.dragX) * 0.02
		self.dragX = x
		self:SetFacing(self.facing)
	end)
	page.ilvl = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page.ilvl:SetPoint("TOP", 0, -276)
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.note:SetWidth(240)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOP", 0, -374)
	page.hint:SetWidth(320)
	page.best = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.best:SetWidth(140)
	page.best:SetHeight(22)
	page.best:SetPoint("TOP", 0, -296)
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
			if CursorHasItem() then DropOnBags() return end
			if not self.item then return end
			if IsShiftKeyDown() then ChatEdit_InsertLink(SendableLink(self.item)) else ItemMenu(self.item) end
		end)
		b:SetScript("OnReceiveDrag", DropOnBags)
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
	page.bank = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.bank:SetWidth(110)
	page.bank:SetHeight(22)
	page.bank:SetPoint("LEFT", page.grey, "RIGHT", 8, 0)
	page.bank:SetScript("OnClick", function()
		bagMode = bagMode == "bank" and "bags" or "bank"
		Ask(bagMode, bagMode == "bank" and "bank" or "c")
		Render()
	end)
	page:EnableMouse(true)
	page:SetScript("OnReceiveDrag", DropOnBags)
	page:SetScript("OnMouseUp", function() if CursorHasItem() then DropOnBags() end end)
end

StaticPopupDialogs.SQUIDBOTSLITE_ABANDON = {
	text = "%s", button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
	OnAccept = function(self)
		Whisper("drop " .. self.data)
		AfterChange()
		local name = current
		local again = CreateFrame("Frame")
		local wait = 0
		again:SetScript("OnUpdate", function(f, delta)
			wait = wait + delta
			if wait < REPEAT_DELAY then return end
			f:SetScript("OnUpdate", nil)
			if current == name and tab == "quests" then Ask("quests", "quests all") end
		end)
	end,
}

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
		row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		row:SetScript("OnClick", function(self, mouse)
			if not (self.quest and self.quest.link) then return end
			if IsShiftKeyDown() then ChatEdit_InsertLink(self.quest.text)
			elseif mouse == "RightButton" then
				local title = self.quest.text:match("|h%[(.-)%]|h")
				if title then
					-- "drop" matches the title in the bot's log: no quest link to be refused by the client.
					StaticPopupDialogs.SQUIDBOTSLITE_ABANDON.text = string.format(T("ABANDON_ASK"), current, title)
					local dialog = StaticPopup_Show("SQUIDBOTSLITE_ABANDON")
					if dialog then dialog.data = title end
				end
			end
		end)
		page.rows[i] = row
	end
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", 14, -(QUEST_ROWS * 20) - 4)
	page.hint:SetWidth(400)
	page.hint:SetJustifyH("LEFT")
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

local STRAT_ROWS = 13

local function StratMenu(kind)
	local have, items = {}, { { text = T(kind == "co" and "COMBAT" or "NONCOMBAT"), isTitle = true, notCheckable = true } }
	for _, name in ipairs(strats[kind]) do have[name] = true end
	for _, name in ipairs(kind == "co" and COMBAT_STRATS or NONCOMBAT_STRATS) do
		if not have[name] then
			table.insert(items, { text = name, notCheckable = true, func = function() Whisper(kind .. " +" .. name); AfterChange() end })
		end
	end
	EasyMenu(items, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
end

local function BuildStrats(page)
	page.cols = {}
	for c, kind in ipairs({ "co", "nc" }) do
		local col = { kind = kind, rows = {} }
		local x = 10 + (c - 1) * 220
		col.title = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		col.title:SetPoint("TOPLEFT", x, 0)
		for i = 1, STRAT_ROWS do
			local row = CreateFrame("Button", nil, page)
			row:SetWidth(200)
			row:SetHeight(18)
			row:SetPoint("TOPLEFT", x, -18 - (i - 1) * 19)
			row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			row.text:SetAllPoints()
			row.text:SetJustifyH("LEFT")
			row:SetScript("OnClick", function(self)
				if self.strat then Whisper(kind .. " -" .. self.strat); AfterChange() end
			end)
			col.rows[i] = row
		end
		col.add = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
		col.add:SetWidth(110)
		col.add:SetHeight(20)
		col.add:SetPoint("TOPLEFT", x, -18 - STRAT_ROWS * 19 - 4)
		col.add:SetScript("OnClick", function() StratMenu(kind) end)
		page.cols[c] = col
	end
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", 10, -18 - STRAT_ROWS * 19 - 30)
	page.hint:SetWidth(430)
	page.hint:SetJustifyH("LEFT")
end

local function RenderStrats(page)
	for _, col in ipairs(page.cols) do
		col.title:SetText(T(col.kind == "co" and "COMBAT" or "NONCOMBAT"))
		col.add:SetText(T("ADD"))
		local list = strats[col.kind]
		for i, row in ipairs(col.rows) do
			row.strat = list[i]
			row.text:SetText(list[i] and ("|cffff6060x|r  " .. list[i]) or "")
			if list[i] then row:Show() else row:Hide() end
		end
	end
	page.hint:SetText(T("STRAT_HINT"))
end

local TALENT_ROWS = 13
local RenderTalents

StaticPopupDialogs.SQUIDBOTSLITE_AUTOPICK = {
	text = "%s", button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
	OnAccept = function() Whisper("talents autopick"); AfterChange() end,
}

local function Pending(o) return pending[o.entry] or 0 end

local function PendingCost(kind)
	local total = 0
	for _, o in ipairs(options) do
		if o.kind == kind then total = total + Pending(o) * o.cost end
	end
	return total
end

local function OptionById(id)
	for _, o in ipairs(options) do if o.id == id then return o end end
end

-- The core asks only that the prerequisite entry be held at some rank. One the bot cannot take (not in its
-- options) is left to the server to judge.
local function MissingPrereq(o)
	for _, id in ipairs(o.requires or {}) do
		local req = OptionById(id)
		if req and req.rank + Pending(req) == 0 then return req end
	end
end

local function PendingCount()
	local n = 0
	for _, ranks in pairs(pending) do n = n + ranks end
	return n
end

-- A rank may be added when the bot's level allows it, the talent has a rank left and its tree has the points.
local function CanAdd(o)
	local info = SquidBotsLiteDB.altInfo and current and SquidBotsLiteDB.altInfo[current] or {}
	if info.level and info.level < o.level then return false end
	if o.rank + Pending(o) >= o.max then return false end
	if MissingPrereq(o) then return false end
	if points then
		local left = o.kind == "class" and points.classLeft or points.specLeft
		if left and PendingCost(o.kind) + o.cost > left then return false end
	end
	return true
end

-- Save: one "talents learn <entry>" a second per rank, in the order of the levels they need; the answers
-- ("Talent learned: ...", "Cannot learn ...: <reason>") go to the chat, then both lists are asked again.
-- A rank refused for a missing prerequisite ("Cannot learn X: requires Y") is tried again once the others are
-- learnt, as long as a pass learnt something: the prerequisite may have come later in the queue.
local saving, lastSent, retry, retryMsg, progress = false, nil, {}, {}, false

local function Save()
	saveQueue = {}
	-- The spell id of the talent's first rank, not its entry: the server reads a bare number as a spell id
	-- first (the core's link parser hands it back as is), so "learn <entry>" answered "Unknown talent".
	local placed, ordered = {}, {}
	local function Place(o)
		if placed[o.id] then return end
		placed[o.id] = true
		for _, id in ipairs(o.requires or {}) do
			local req = OptionById(id)
			if req then Place(req) end
		end
		table.insert(ordered, o)
	end
	for _, o in ipairs(options) do Place(o) end
	for _, o in ipairs(ordered) do
		for _ = 1, Pending(o) do table.insert(saveQueue, o.id) end
	end
	if #saveQueue == 0 then return end
	Print(string.format(T("T_SAVING"), #saveQueue))
	pending = {}
	saveNext, saving, retry, retryMsg, progress = 0, true, {}, {}, false
end

local saveWatch = CreateFrame("Frame")
saveWatch:RegisterEvent("CHAT_MSG_WHISPER")
saveWatch:SetScript("OnEvent", function(_, _, message, sender)
	if sender ~= current then return end
	if saving and lastSent and message:find("^Cannot learn ") and message:find(": requires ") then
		table.insert(retry, lastSent)
		retryMsg[#retry] = message
		return
	end
	if message:find("^Talent learned: ") then progress = true end
	if message:find("^Talent learned: ") or message:find("^Cannot learn ") or message:find("^Talents can only be chosen")
		or message:find("^Unknown talent: ") or message:find("^Talents set from the build") then
		Print(sender .. ": " .. message)
	end
end)
saveWatch:SetScript("OnUpdate", function()
	if not saving or GetTime() < saveNext then return end
	if #saveQueue > 0 then
		saveNext = GetTime() + 1.2
		lastSent = table.remove(saveQueue, 1)
		Whisper("talents learn " .. lastSent)
		return
	end
	-- The queue is empty and the last answer had time to come: another pass for the refused ranks, or the end.
	if #retry > 0 and progress then
		saveQueue, retry, retryMsg, progress = retry, {}, {}, false
		return
	end
	for _, message in ipairs(retryMsg) do Print(current .. ": " .. message) end
	saving, lastSent, retry, retryMsg = false, nil, {}, {}
	AfterChange()
end)

local function TalentRow(page, i)
	local row = CreateFrame("Button", nil, page)
	row:SetWidth(410)
	row:SetHeight(22)
	row:SetPoint("TOPLEFT", 10, -(i - 1) * 24)
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetWidth(20)
	row.icon:SetHeight(20)
	row.icon:SetPoint("LEFT", 2, 0)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.name:SetPoint("LEFT", 28, 0)
	row.name:SetWidth(180)
	row.name:SetJustifyH("LEFT")
	row.rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	row.rank:SetPoint("LEFT", 212, 0)
	row.tree = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.tree:SetPoint("LEFT", 258, 0)
	row.tree:SetWidth(110)
	row.tree:SetJustifyH("LEFT")
	row.minus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	row.minus:SetWidth(20)
	row.minus:SetHeight(18)
	row.minus:SetPoint("RIGHT", -24, 0)
	row.minus:SetText("-")
	row.plus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	row.plus:SetWidth(20)
	row.plus:SetHeight(18)
	row.plus:SetPoint("RIGHT", 0, 0)
	row.plus:SetText("+")
	row:SetScript("OnEnter", function(self)
		local id = self.talent and self.talent.id or self.option and self.option.id
		if id then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink("spell:" .. id)
			if self.option then
				for _, id in ipairs(self.option.requires or {}) do
					local req = OptionById(id)
					local held = req and req.rank + Pending(req) > 0
					GameTooltip:AddLine(string.format(T("T_REQUIRES"), req and req.name or GetSpellInfo(id) or id),
						held and 0.25 or 1, held and 1 or 0.3, held and 0.25 or 0.3)
				end
				if self.option.canLearn then GameTooltip:AddLine(T("T_CAN"), 0.25, 1, 0.25, true)
				elseif self.option.rank < self.option.max then GameTooltip:AddLine(T("T_CANNOT"), 1, 0.5, 0.25, true) end
			end
			GameTooltip:Show()
		end
	end)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)
	row:SetScript("OnClick", function(self)
		local id = self.talent and self.talent.id or self.option and self.option.id
		if id and IsShiftKeyDown() then ChatEdit_InsertLink(GetSpellLink(id) or "") end
	end)
	row:EnableMouseWheel(true)
	row:SetScript("OnMouseWheel", function(_, delta)
		local count = choosing and #options or #talents
		talentOffset = math.max(0, math.min(math.max(0, count - TALENT_ROWS), talentOffset - delta * 3))
		RenderTalents(page)
	end)
	row.plus:SetScript("OnClick", function()
		if row.option and CanAdd(row.option) then pending[row.option.entry] = Pending(row.option) + 1 end
		RenderTalents(page)
	end)
	row.minus:SetScript("OnClick", function()
		local o = row.option
		if o and Pending(o) > 0 then
			pending[o.entry] = Pending(o) - 1
			-- Taking back the last rank of a prerequisite takes back what was added on top of it.
			if o.rank + Pending(o) == 0 then
				local changed = true
				while changed do
					changed = false
					for _, other in ipairs(options) do
						if Pending(other) > 0 and MissingPrereq(other) then pending[other.entry], changed = nil, true end
					end
				end
			end
		end
		RenderTalents(page)
	end)
	return row
end

local function BuildTalents(page)
	page.rows = {}
	for i = 1, TALENT_ROWS do page.rows[i] = TalentRow(page, i) end
	page.up = CreateFrame("Button", nil, page, "UIPanelScrollUpButtonTemplate")
	page.up:SetPoint("TOPRIGHT", -6, 0)
	page.up:SetScript("OnClick", function() talentOffset = math.max(0, talentOffset - TALENT_ROWS); RenderTalents(page) end)
	page.down = CreateFrame("Button", nil, page, "UIPanelScrollDownButtonTemplate")
	page.down:SetPoint("TOPRIGHT", -6, -(TALENT_ROWS * 24) + 16)
	page.down:SetScript("OnClick", function()
		local count = choosing and #options or #talents
		if talentOffset + TALENT_ROWS < count then talentOffset = talentOffset + TALENT_ROWS end
		RenderTalents(page)
	end)
	page.spent = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	page.spent:SetPoint("TOPLEFT", 12, -(TALENT_ROWS * 24) - 4)
	page.spent:SetWidth(430)
	page.spent:SetJustifyH("LEFT")
	-- Learnt view: Choose talents, Reset to the build. Choosing view: Save (N), Cancel, Learnt talents.
	local function Button(width, x, onClick)
		local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
		b:SetWidth(width)
		b:SetHeight(22)
		b:SetPoint("TOPLEFT", x, -(TALENT_ROWS * 24) - 22)
		b:SetScript("OnClick", onClick)
		return b
	end
	page.choose = Button(140, 10, function()
		choosing, pending, talentOffset = true, {}, 0
		Ask("options", "talents options")
		RenderTalents(page)
	end)
	page.autopick = Button(140, 156, function()
		StaticPopupDialogs.SQUIDBOTSLITE_AUTOPICK.text = string.format(T("T_AUTOPICK_ASK"), current or "?")
		StaticPopup_Show("SQUIDBOTSLITE_AUTOPICK")
	end)
	page.save = Button(130, 10, function() Save(); RenderTalents(page) end)
	page.cancel = Button(90, 146, function() pending = {}; RenderTalents(page) end)
	page.back = Button(130, 242, function()
		choosing, pending, talentOffset = false, {}, 0
		Ask("talents", "talents ?")
		RenderTalents(page)
	end)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", 12, -(TALENT_ROWS * 24) - 50)
	page.hint:SetWidth(430)
	page.hint:SetJustifyH("LEFT")
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.note:SetWidth(360)
end

RenderTalents = function(page)
	local list = choosing and options or talents
	local quiet = capture == nil and (sheet.status:GetText() or "") == ""
	page.note:SetText(#list == 0 and quiet and T(choosing and "T_NO_OPTIONS" or "T_NONE") or "")
	if choosing and points then
		page.spent:SetText(string.format(T("T_LEFT"), (points.specLeft or 0) - PendingCost("spec"), (points.classLeft or 0) - PendingCost("class")))
	elseif points then
		page.spent:SetText(string.format(T("T_POINTS"), points.specSpent or 0, points.specLeft or 0, points.classSpent or 0, points.classLeft or 0))
	else
		page.spent:SetText(talentSpent and string.format(T("T_SPENT"), talentSpent) or "")
	end
	page.choose:SetText(T("T_CHOOSE"))
	page.autopick:SetText(T("T_AUTOPICK"))
	page.save:SetText(string.format(T("T_SAVE"), PendingCount()))
	page.cancel:SetText(T("T_CANCEL"))
	page.back:SetText(T("T_BACK"))
	local isAlt = current and SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[current]
	if choosing or not isAlt then page.choose:Hide() else page.choose:Show() end
	if choosing or isAlt then page.autopick:Hide() else page.autopick:Show() end
	for _, b in ipairs({ page.save, page.cancel, page.back }) do if choosing then b:Show() else b:Hide() end end
	if PendingCount() > 0 then page.save:Enable(); page.cancel:Enable() else page.save:Disable(); page.cancel:Disable() end
	page.hint:SetText(T(choosing and "T_CHOOSE_HINT" or "T_HINT"))
	for i, row in ipairs(page.rows) do
		local item = list[talentOffset + i]
		row.talent, row.option = nil, nil
		if item then
			row.icon:SetTexture(select(3, GetSpellInfo(item.id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			row.name:SetText(item.name)
			if choosing and not item.canLearn and item.rank < item.max then row.name:SetTextColor(0.55, 0.55, 0.55)
			else row.name:SetTextColor(1, 1, 1) end
			if choosing then
				row.option = item
				local add = Pending(item)
				local rank = item.rank .. (add > 0 and ("|cff40ff40+" .. add .. "|r") or "") .. "/" .. item.max
				row.rank:SetText((item.rank + add >= item.max and "|cff40ff40" or "|cffffd100") .. rank .. "|r")
				local info = SquidBotsLiteDB.altInfo and current and SquidBotsLiteDB.altInfo[current] or {}
				local req = string.format(T("T_REQ"), item.level)
				if info.level and info.level < item.level then req = "|cffff4040" .. req .. "|r" end
				row.tree:SetText(T(item.kind == "class" and "T_CLASS" or "T_SPEC") .. ", " .. string.format(T("T_COST"), item.cost) .. ", " .. req)
				row.plus:Show(); row.minus:Show()
				if CanAdd(item) then row.plus:Enable() else row.plus:Disable() end
				if add > 0 then row.minus:Enable() else row.minus:Disable() end
			else
				row.talent = item
				row.rank:SetText((item.rank >= item.max and "|cff40ff40" or "|cffffd100") .. item.rank .. "/" .. item.max .. "|r")
				row.tree:SetText(item.ability and (item.tree ~= "" and (item.tree .. ", " .. T("T_ABILITY")) or T("T_ABILITY")) or item.tree)
				row.plus:Hide(); row.minus:Hide()
			end
			row:Show()
		else
			row:Hide()
		end
	end
	if #list > TALENT_ROWS then page.up:Show(); page.down:Show() else page.up:Hide(); page.down:Hide() end
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
		row:EnableMouseWheel(true)
		row:SetScript("OnMouseWheel", function(_, delta)
			mountOffset = math.max(0, math.min(math.max(0, #mounts - MOUNT_ROWS), mountOffset - delta * 3))
			RenderMounts(page)
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
	page.hint:SetWidth(270)
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
	-- The server marks a favourite without saying for what. A ground-and-flying favourite next to a ground one
	-- is the flying favourite (and the other way round): the list says which, so the old one does not look stuck.
	local groundFav, flyingFav = false, false
	for _, m in ipairs(mounts) do
		if m.preferred and m.kind == "ground" then groundFav = true end
		if m.preferred and m.kind == "flying" then flyingFav = true end
	end
	local function FavouriteFor(m)
		if m.kind == "ground" then return T("FOR_GROUND") end
		if m.kind == "flying" then return T("FOR_FLYING") end
		if groundFav and not flyingFav then return T("FOR_FLYING") end
		if flyingFav and not groundFav then return T("FOR_GROUND") end
		return T("PREFERRED")
	end
	for i, row in ipairs(page.rows) do
		local m = mounts[mountOffset + i]
		row.mount = m
		if m then
			row.icon:SetTexture(select(3, GetSpellInfo(m.id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			row.name:SetText(m.name)
			row.kind:SetText((kinds[m.kind] or m.kind or "") .. (m.preferred and ("  |cffffd100" .. FavouriteFor(m) .. "|r") or ""))
			if m.preferred then row.check:Show() else row.check:Hide() end
			row:Show()
		else
			row:Hide()
		end
	end
	if #mounts > MOUNT_ROWS then page.up:Show(); page.down:Show() else page.up:Hide(); page.down:Hide() end
end

local TABS = { { "gear", "GEAR", BuildGear }, { "bags", "BAGS", BuildBags }, { "quests", "QUESTS", BuildQuests },
	{ "talents", "TALENTS", BuildTalents }, { "mounts", "MOUNTS", BuildMounts }, { "info", "INFO", BuildInfo } }
-- The Strategies tab (BuildStrats) is kept out for now: too easy to break a bot with it (decision 12/10).
-- Put { "strats", "STRATS", BuildStrats } back in TABS to show it.

-- Average item level of what the bot wears (shirt and tabard left out), from the client's item cache.
local function AverageItemLevel(unit)
	local total, count = 0, 0
	for slot = 1, 18 do
		if slot ~= 4 then
			local link = GetInventoryItemLink(unit, slot)
			local level = link and select(4, GetItemInfo(link))
			if level and level > 0 then total, count = total + level, count + 1 end
		end
	end
	if count > 0 then return math.floor(total / count + 0.5) end
end

local function RenderGear(page)
	local unit = current and UnitOf(current)
	local inRange = unit and CheckInteractDistance(unit, 1)
	page.note:SetText(not unit and T("NOT_IN_GROUP") or (not inRange and T("OUT_OF_RANGE")) or "")
	page.hint:SetText(T("GEAR_HINT") .. " " .. T("MODEL_HINT"))
	page.best:SetText(T("BEST_GEAR"))
	for slot, b in pairs(page.slots) do
		local texture = unit and GetInventoryItemTexture(unit, slot)
		b.icon:SetTexture(texture)
		if texture then b.icon:Show() else b.icon:Hide() end
	end
	-- The model is set once per bot (setting it again would turn it back to the front).
	if unit and UnitIsVisible(unit) then
		if page.model.name ~= current then
			page.model:SetUnit(unit)
			page.model.name, page.model.facing = current, 0
			page.model:SetFacing(0)
			-- A step further back and a little lower: a tall headdress or helm stays inside the frame.
			page.model:SetPosition(-0.6, 0, -0.16)
		end
		page.model:Show()
	else
		page.model:ClearModel()
		page.model.name = nil
		page.model:Hide()
	end
	local ilvl = unit and AverageItemLevel(unit)
	page.ilvl:SetText(ilvl and string.format(T("ILVL"), ilvl) or "")
end

local function RenderBags(page)
	local list = bagMode == "bank" and bank or bags
	page.note:SetText(#list == 0 and capture == nil and T("EMPTY_BAGS") or "")
	page.hint:SetText(T("ITEM_HINT") .. " " .. T("DROP_HINT"))
	page.trade:SetText(T("TRADE"))
	page.bank:SetText(bagMode == "bank" and T("BAGS_BTN") or T("BANK"))
	page.grey:SetText(T("SELL_GREY"))
	for i, b in ipairs(page.buttons) do
		local item = list[i]
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
	page.hint:SetText(T("QUEST_HINT"))
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
	local info = SquidBotsLiteDB.altInfo and current and SquidBotsLiteDB.altInfo[current] or {}
	local gold = sheet.gold or info.gold
	-- A wrong value saved before the fix ("Strategies: ...") is not shown.
	if gold and not gold:find("^%d+[gsc]") then gold = nil end
	sheet.goldText:SetText(gold and ("|cffffd100" .. T("GOLD") .. "|r " .. gold) or "")
	local line = ""
	if info.level then
		local class = info.class or ""
		local color = info.token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[info.token]
		if color then class = string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, class) end
		line = string.format(T("LEVEL"), info.level, class)
	end
	if info.spec then line = line .. "  |cffaaaaaa- " .. info.spec .. "|r" end
	sheet.specText:SetText(line)
	if info.xp then
		sheet.xp:SetValue(info.xp)
		sheet.xp.text:SetText(string.format("%s %d%%%s", T("XP"), info.xp, (info.rest or 0) > 0 and (" (+" .. info.rest .. "%)") or ""))
		sheet.xp:Show()
	else
		sheet.xp:Hide()
	end
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
	elseif tab == "talents" then RenderTalents(pages.talents)
	elseif tab == "strats" then RenderStrats(pages.strats)
	else RenderInfo(pages.info) end
end

local function Load()
	if tab == "gear" then
		local unit = current and UnitOf(current)
		if unit and CanInspect(unit) then NotifyInspect(unit) end
		Render()
	elseif tab == "bags" then
		Ask(bagMode, bagMode == "bank" and "bank" or "c")
	elseif tab == "quests" then
		Ask("quests", "quests all")
	elseif tab == "mounts" then
		Ask("mounts", "mount ?")
	elseif tab == "talents" then
		Ask("talents", "talents ?")
	elseif tab == "strats" then
		Ask("co", "co ?")
		Ask("nc", "nc ?")
	else
		Ask("stats", "stats")
	end
	Render()
end

local function Build()
	sheet = CreateFrame("Frame", "SquidBotsLiteSheet", UIParent)
	sheet:SetWidth(470)
	sheet:SetHeight(540)
	sheet:SetPoint("CENTER", 120, 0)
	sheet:SetBackdrop(BACKDROP)
	sheet:SetBackdropColor(0.04, 0.04, 0.05, 1)
	sheet:SetFrameStrata("DIALOG")
	sheet:SetMovable(true)
	sheet:SetToplevel(true)
	sheet:SetScript("OnMouseDown", function() CloseDropDownMenus() end)
	-- Smaller on screen than its layout: a sheet sits next to My alts without hiding the game.
	sheet:SetScale(0.95)
	sheet:EnableMouse(true)
	sheet:SetClampedToScreen(true)
	sheet:RegisterForDrag("LeftButton")
	sheet:SetScript("OnDragStart", sheet.StartMoving)
	sheet:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.moved = true
	end)
	table.insert(UISpecialFrames, "SquidBotsLiteSheet")
	sheet.title = sheet:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	sheet.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, sheet, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	sheet.tabs = {}
	for i, def in ipairs(TABS) do
		local b = CreateFrame("Button", nil, sheet, "UIPanelButtonTemplate")
		b:SetWidth(70)
		b:SetHeight(22)
		b:SetPoint("TOPLEFT", 16 + (i - 1) * 73, -36)
		b:SetScript("OnClick", function() tab = def[1]; Load() end)
		sheet.tabs[def[1]] = b
		local page = CreateFrame("Frame", nil, sheet)
		page:SetPoint("TOPLEFT", 8, -86)
		page:SetPoint("BOTTOMRIGHT", -8, 40)
		def[3](page)
		pages[def[1]] = page
	end
	sheet.refresh = CreateFrame("Button", nil, sheet, "UIPanelButtonTemplate")
	sheet.refresh:SetWidth(100)
	sheet.refresh:SetHeight(22)
	sheet.refresh:SetPoint("BOTTOMRIGHT", -16, 14)
	sheet.refresh:SetScript("OnClick", function() Load() end)
	sheet.goldText = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	sheet.goldText:SetPoint("TOPRIGHT", -20, -64)
	sheet.specText = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	sheet.specText:SetPoint("TOPLEFT", 20, -64)
	sheet.xp = CreateFrame("StatusBar", nil, sheet)
	sheet.xp:SetHeight(12)
	sheet.xp:SetPoint("BOTTOMLEFT", 20, 44)
	sheet.xp:SetPoint("BOTTOMRIGHT", -20, 44)
	sheet.xp:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	sheet.xp:SetStatusBarColor(0.58, 0.0, 0.55)
	sheet.xp:SetMinMaxValues(0, 100)
	local xpBg = sheet.xp:CreateTexture(nil, "BACKGROUND")
	xpBg:SetAllPoints()
	xpBg:SetTexture(0, 0, 0, 0.6)
	sheet.xp.text = sheet.xp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	sheet.xp.text:SetPoint("CENTER")
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
	if current ~= name then
		bags, quests, stats, mounts, bank, strats, queue = {}, {}, {}, {}, {}, { co = {}, nc = {} }, {}
		talents, talentSpent, talentOffset = {}, nil, 0
		options, pending, points, choosing, saveQueue = {}, {}, nil, false, {}
		bagMode = "bags"
		if sheet then sheet.gold = nil end
	end
	current = name
	tab = tab or "gear"
	local alts = _G.SquidBotsLiteAlts
	if not sheet.moved then
		sheet:ClearAllPoints()
		if alts and alts:IsShown() then
			sheet:SetPoint("TOPLEFT", alts, "TOPRIGHT", 4, 0)
		else
			sheet:SetPoint("CENTER", 120, 0)
		end
	end
	sheet:Show()
	sheet:Raise()
	if not UnitOf(name) and tab == "gear" then tab = "bags" end
	Load()
	if not sheet.gold then Ask("stats", "stats") end
	local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[name]
	if not (info and info.spec) and SquidBotsLite_AskSpecs then SquidBotsLite_AskSpecs(name) end
end

function SquidBotsLite_SheetDebug()
	SquidBotsLiteDB.sheetDebug = not SquidBotsLiteDB.sheetDebug
	Print("sheet debug " .. (SquidBotsLiteDB.sheetDebug and "on" or "off"))
end

function SquidBotsLite_SheetOnTrade(on)
	SquidBotsLiteDB.sheetOnTrade = on
end
