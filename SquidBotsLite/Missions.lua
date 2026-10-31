-- SquidBots Lite, missions: send a logged-in alt gathering on its own (mining or herbalism) while you play,
-- follow it, call it back; what it gathers comes by mail. Everything goes through what a player can whisper to
-- their own alt: "mission gather [minutes] [mining|herbalism]", "mission status", "mission stop" (CoA Bots 2.8.2).
-- An alt in High Risk refuses "Mission refused: I am in High Risk (add "risk" to accept)."; "mission gather <minutes>
-- [skill] risk" sends it anyway, after a red warning here (CoA Bots 2.8.3). MISSION;... gains an 8th field, risk 0|1.
-- "mission status" answers "MISSION;<TRAVEL|WORK|DELIVER>;<zone>;<minutes left>;<items>;<mining|herbalism>;<deaths>"
-- or "MISSION;NONE"; those lines and the polls stay out of the chat.
-- Watching an alt out (the camera on it, same continent): "mission watch" / "mission unwatch"; it answers
-- "Watch on: <zone>.", "Watch off: <reason>." or "Watch refused: <reason>.".
-- An order: "mission order <item id> [count] [minutes]" gathers that ore or herb up to the count, the rest on the way;
-- it answers "Mission started: order of <n> <name> (<skill>) in <zone>, ..." or "Order refused: <reason>.".
-- CoA Bots 2.8.4: skinning, fishing and cloth too (the 6th field of MISSION;...), 4 alts at a time, and
-- "mission can" answers "MISSIONCAN;<level>;<suggested>;<activity>:<skill>:<ok|nopick|noknife|nopole>,..." (the
-- activities the alt can be sent to, cloth always): the card shows only those, the suggested one chosen first.

local STRINGS = {
	en = {
		TITLE = "Missions", REFRESH = "Refresh", SEND = "Send", RECALL = "Recall", NONE = "Free",
		HINT = "Send a logged-in alt gathering on its own while you play: it leaves the group, gathers, and mails you what it found. You stay logged in (on any character).",
		NO_ALTS = "No alt logged in: log one in from My alts, then Refresh.",
		COUNT = "On a mission: %d / 4", WAIT = "Asking your alts...",
		AUTO = "Its gathering skill", MINING = "Mining", HERBALISM = "Herbalism", MIN = "%d min",
		TRAVEL = "On the way to %s", WORK = "Gathering in %s", DELIVER = "Mailing the loot",
		LEFT = "%d min left", ITEMS = "%d items", DEATHS = "%d deaths", DEATH = "1 death",
		SKILL_mining = "mining", SKILL_herbalism = "herbalism",
		RECALL_ASK = "Call %s back now? What it gathered so far comes by mail.",
		MAIL = "Mail from %s has arrived: %d items (at a mailbox).", DONE = "%s: mission over. %s",
		TIP_SEND = "Choose the activity and how long, then Send: 4 alts at a time.",
		TIP_RECALL = "Ends the mission now: the loot comes by mail, the alt waits for you or comes back.",
		RESUMED = "%s went back to its mission, so it stays out of your group: Recall it from Missions to have it back.",
		BACK_AT = "back ~%s", RATE = "~%d/h", AGAIN = "Same again: %s, %d min",
		BAR_OUT = "%d on a mission · %d min", BAR_BACK = "%s is back: loot by mail", TIP_BADGE = "Click: the Missions panel.",
		WATCH = "Watch", TIP_WATCH = "The camera follows it while it works (same continent only). Back to me, or Escape, to return.",
		WATCH_BAR = "Watching %s", WATCH_BACK = "Back to me", WATCH_WAIT = "Asking %s for its view...",
		WATCH_REFUSED = "%s: no view (%s)", WATCH_OFF = "View of %s closed: %s", TIP_WATCH_BACK = "Your own camera again.",
		ORDER = "Order", TIP_ORDER = "Ask it for a given material: it gathers that up to the count, the rest on the way, and mails it all. Search by name, or drop an item from your bags on this button.",
		ORDER_COUNT = "%d of them", ORDER_DEFAULT = "%d of them (default)", ORDER_DROP = "Or drop a material from your bags here.",
		ORDER_LINE = "Order: %d %s", ORDER_REFUSED = "%s: order refused (%s)",
		OUT = "On a mission", HELP = "The loot comes by mail. Hover here for more, or an icon to see what it does.",
		BADGE_FREE = "Free", BADGE_OUT = "On a mission", BADGE_DONE = "Done", BADGE_WAIT = "...",
		READY = "Ready to go", READY_SKILL = "Ready to go: %s", DONE_LINE = "Back: %d items mailed to you", DONE_NOTHING = "Back: nothing gathered",
		TIP_FULL = "Four alts are already out: recall one or wait for it.", TIP_REFRESH = "Ask your alts where they are now.",
		RISK = "High Risk", RISK_ASK = "%s is in High Risk.\n\n|cffff3333Your alt can lose its loot if it dies.|r\n\nSend it gathering anyway (%s, %d min)?",
		RISK_SEND = "Send in High Risk", RISK_LINE = "In High Risk: you will be asked to confirm.",
		RECALL_ALL_ASK = "Call back the %d alts on a mission now? What they gathered so far comes by mail.",
		SKINNING = "Skinning", FISHING = "Fishing", CLOTH = "Cloth",
		SKILL_skinning = "skinning", SKILL_fishing = "fishing", SKILL_cloth = "cloth",
		TIP_mining = "Mines the ore of its skill.", TIP_herbalism = "Picks the herbs of its skill.",
		TIP_skinning = "Kills beasts of its level and skins them.", TIP_fishing = "Fishes by a water of its skill.",
		TIP_cloth = "Kills humanoids of its level for their cloth: no profession needed.",
		TIP_AUTO = "The server picks its best gathering skill.", SUGGESTED = "Suggested for its level and skills.",
		WHY_nopick = "No mining pick in its bags.", WHY_noknife = "No skinning knife in its bags.", WHY_nopole = "No fishing pole in its bags.",
		SEND_BTN = "Send", TIP_SEND_BTN = "Sends it now: %s, %d min. The loot comes by mail.", TIP_MINUTES = "How long it stays out.",
		ORDER_TITLE = "Order: %s", SEARCH = "Search: copper, peace, wool...", ORDER_SUGGEST = "Suggested for it",
		ORDER_NONE = "Nothing found.", ORDER_QTY = "How many:", WHY_SKILL = "needs %s %d", WHY_NOSKILL = "does not know %s",
		WHY_LEVEL = "levels %d-%d", TIP_ORDER_ROW = "Click: order it.",
	},
	fr = {
		TITLE = "Missions", REFRESH = "Actualiser", SEND = "Envoyer", RECALL = "Rappeler", NONE = "Libre",
		HINT = "Envoyez un alt connecté récolter seul pendant que vous jouez : il quitte le groupe, récolte, et vous envoie sa récolte par courrier. Vous restez connecté (sur n'importe quel personnage).",
		NO_ALTS = "Aucun alt connecté : connectez-en un depuis Mes alts, puis Actualiser.",
		COUNT = "En mission : %d / 4", WAIT = "Je demande à vos alts...",
		AUTO = "Son métier de récolte", MINING = "Minage", HERBALISM = "Herboristerie", MIN = "%d min",
		TRAVEL = "En route vers %s", WORK = "Récolte à %s", DELIVER = "Envoi du butin",
		LEFT = "%d min restantes", ITEMS = "%d objets", DEATHS = "%d morts", DEATH = "1 mort",
		SKILL_mining = "minage", SKILL_herbalism = "herboristerie",
		RECALL_ASK = "Rappeler %s maintenant ? Ce qu'il a déjà récolté arrive par courrier.",
		MAIL = "Le courrier de %s est arrivé : %d objets (à une boîte aux lettres).", DONE = "%s : mission terminée. %s",
		TIP_SEND = "Choisissez l'activité et la durée, puis Envoyer : 4 alts à la fois.",
		TIP_RECALL = "Arrête la mission tout de suite : le butin arrive par courrier, l'alt vous attend ou revient.",
		RESUMED = "%s a repris sa mission, il reste donc hors de votre groupe : rappelez-le depuis Missions pour le récupérer.",
		BACK_AT = "retour ~%s", RATE = "~%d/h", AGAIN = "Pareil : %s, %d min",
		BAR_OUT = "%d en mission · %d min", BAR_BACK = "%s est revenu : butin par courrier", TIP_BADGE = "Clic : le panneau Missions.",
		WATCH = "Regarder", TIP_WATCH = "La caméra le suit pendant qu'il travaille (même continent seulement). Revenir à moi, ou Échap, pour revenir.",
		WATCH_BAR = "Vue de %s", WATCH_BACK = "Revenir à moi", WATCH_WAIT = "Je demande sa vue à %s...",
		WATCH_REFUSED = "%s : pas de vue (%s)", WATCH_OFF = "Vue de %s fermée : %s", TIP_WATCH_BACK = "Votre caméra à nouveau.",
		ORDER = "Commander", TIP_ORDER = "Demandez-lui un matériau précis : il en récolte jusqu'au nombre voulu, le reste en route, et vous envoie tout par courrier. Cherchez par nom, ou déposez un objet de vos sacs sur ce bouton.",
		ORDER_COUNT = "%d", ORDER_DEFAULT = "%d (par défaut)", ORDER_DROP = "Ou déposez un matériau de vos sacs ici.",
		ORDER_LINE = "Commande : %d %s", ORDER_REFUSED = "%s : commande refusée (%s)",
		OUT = "En mission", HELP = "Le butin arrive par courrier. Survolez ici pour en savoir plus, ou une icône pour son rôle.",
		BADGE_FREE = "Libre", BADGE_OUT = "En mission", BADGE_DONE = "Terminé", BADGE_WAIT = "...",
		READY = "Prêt à partir", READY_SKILL = "Prêt à partir : %s", DONE_LINE = "De retour : %d objets envoyés par courrier", DONE_NOTHING = "De retour : rien récolté",
		TIP_FULL = "Quatre alts sont déjà partis : rappelez-en un ou attendez son retour.", TIP_REFRESH = "Redemander à vos alts où ils en sont.",
		RISK = "High Risk", RISK_ASK = "%s est en High Risk.\n\n|cffff3333Votre alt peut perdre son butin s'il meurt.|r\n\nL'envoyer récolter quand même (%s, %d min) ?",
		RISK_SEND = "Envoyer en High Risk", RISK_LINE = "En High Risk : une confirmation vous sera demandée.",
		RECALL_ALL_ASK = "Rappeler maintenant les %d alts en mission ? Ce qu'ils ont déjà récolté arrive par courrier.",
		SKINNING = "Dépeçage", FISHING = "Pêche", CLOTH = "Tissu",
		SKILL_skinning = "dépeçage", SKILL_fishing = "pêche", SKILL_cloth = "tissu",
		TIP_mining = "Extrait le minerai de son niveau de métier.", TIP_herbalism = "Cueille les herbes de son niveau de métier.",
		TIP_skinning = "Tue des bêtes de son niveau et les dépèce.", TIP_fishing = "Pêche dans une eau de son niveau de métier.",
		TIP_cloth = "Tue des humanoïdes de son niveau pour leur tissu : aucun métier requis.",
		TIP_AUTO = "Le serveur choisit son meilleur métier de récolte.", SUGGESTED = "Conseillé pour son niveau et ses métiers.",
		WHY_nopick = "Pas de pioche dans ses sacs.", WHY_noknife = "Pas de couteau à dépecer dans ses sacs.", WHY_nopole = "Pas de canne à pêche dans ses sacs.",
		SEND_BTN = "Envoyer", TIP_SEND_BTN = "L'envoie maintenant : %s, %d min. Le butin arrive par courrier.", TIP_MINUTES = "Combien de temps il reste parti.",
		ORDER_TITLE = "Commande : %s", SEARCH = "Chercher : cuivre, paix, laine...", ORDER_SUGGEST = "Suggestions pour lui",
		ORDER_NONE = "Rien trouvé.", ORDER_QTY = "Combien :", WHY_SKILL = "demande %s %d", WHY_NOSKILL = "ne connaît pas %s",
		WHY_LEVEL = "niveaux %d-%d", TIP_ORDER_ROW = "Clic : le commander.",
	},
}
local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or key
end

local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
local ROWS, ROW_H, ROWS_TOP = 6, 80, 74
-- One poll a minute while an alt is out (or the panel is open); one whisper a second, so as not to flood.
local POLL_EVERY, POLL_GAP, OFFLINE_WAIT = 60, 1, 3
local DURATIONS = { 30, 60, 120 }
-- Alts out at the same time: AiPlayerbot.Missions.MaxPerPlayer (4 from CoA Bots 2.8.4, a group of 5).
local MAX_OUT = 4
local ORDER_COUNTS, ORDER_DEFAULT = { 10, 20, 40 }, 20
-- The activities a card can show, in this order (MISSIONCAN lists those of the alt).
local ACTIVITIES = { "mining", "herbalism", "skinning", "fishing", "cloth" }
local ACTIVITY_NAME = { mining = "MINING", herbalism = "HERBALISM", skinning = "SKINNING", fishing = "FISHING", cloth = "CLOTH" }
-- The classic materials to order: id, activity, from (the skill it needs; cloth: the humanoids' levels from-to),
-- English name (searched too, and shown until the client knows the item).
local MATERIALS = {
	{ 2770, "mining", 1, "Copper Ore" }, { 2835, "mining", 1, "Rough Stone" }, { 2771, "mining", 65, "Tin Ore" },
	{ 2836, "mining", 65, "Coarse Stone" }, { 2775, "mining", 75, "Silver Ore" }, { 2772, "mining", 125, "Iron Ore" },
	{ 2838, "mining", 125, "Heavy Stone" }, { 2776, "mining", 155, "Gold Ore" }, { 3858, "mining", 175, "Mithril Ore" },
	{ 7912, "mining", 175, "Solid Stone" }, { 7911, "mining", 230, "Truesilver Ore" }, { 10620, "mining", 245, "Thorium Ore" },
	{ 12365, "mining", 245, "Dense Stone" },
	{ 2447, "herbalism", 1, "Peacebloom" }, { 765, "herbalism", 1, "Silverleaf" }, { 2449, "herbalism", 15, "Earthroot" },
	{ 785, "herbalism", 50, "Mageroyal" }, { 2450, "herbalism", 70, "Briarthorn" }, { 2453, "herbalism", 100, "Bruiseweed" },
	{ 3355, "herbalism", 115, "Wild Steelbloom" }, { 3356, "herbalism", 125, "Kingsblood" }, { 3357, "herbalism", 150, "Liferoot" },
	{ 3818, "herbalism", 160, "Fadeleaf" }, { 3821, "herbalism", 170, "Goldthorn" }, { 3358, "herbalism", 185, "Khadgar's Whisker" },
	{ 8838, "herbalism", 230, "Sungrass" }, { 13464, "herbalism", 260, "Golden Sansam" }, { 13463, "herbalism", 270, "Dreamfoil" },
	{ 13465, "herbalism", 280, "Mountain Silversage" }, { 13466, "herbalism", 285, "Plaguebloom" }, { 13468, "herbalism", 300, "Black Lotus" },
	{ 2934, "skinning", 1, "Ruined Leather Scraps" }, { 2318, "skinning", 1, "Light Leather" }, { 783, "skinning", 1, "Light Hide" },
	{ 2319, "skinning", 100, "Medium Leather" }, { 4232, "skinning", 100, "Medium Hide" }, { 4234, "skinning", 150, "Heavy Leather" },
	{ 4235, "skinning", 150, "Heavy Hide" }, { 4304, "skinning", 200, "Thick Leather" }, { 8169, "skinning", 200, "Thick Hide" },
	{ 8170, "skinning", 250, "Rugged Leather" }, { 8171, "skinning", 250, "Rugged Hide" },
	{ 6291, "fishing", 1, "Raw Brilliant Smallfish" }, { 6303, "fishing", 1, "Raw Slitherskin Mackerel" },
	{ 6289, "fishing", 1, "Raw Longjaw Mud Snapper" }, { 6522, "fishing", 50, "Deviate Fish" },
	{ 6308, "fishing", 75, "Raw Bristle Whisker Catfish" }, { 6358, "fishing", 75, "Oily Blackmouth" },
	{ 6359, "fishing", 100, "Firefin Snapper" }, { 8365, "fishing", 175, "Raw Mithril Head Trout" },
	{ 4603, "fishing", 225, "Raw Spotted Yellowtail" }, { 13422, "fishing", 275, "Stonescale Eel" },
	{ 13889, "fishing", 275, "Raw Whitescale Salmon" },
	{ 2589, "cloth", 5, "Linen Cloth", 20 }, { 2592, "cloth", 15, "Wool Cloth", 30 }, { 4306, "cloth", 25, "Silk Cloth", 40 },
	{ 4338, "cloth", 35, "Mageweave Cloth", 50 }, { 14047, "cloth", 45, "Runecloth", 60 }, { 14256, "cloth", 55, "Felcloth", 60 },
}
local KNOWN_SKILL = { mining = true, herbalism = true, skinning = true, fishing = true, cloth = true }

-- done: the alts back from a mission this session, with how many items they mailed.
-- risk: the alts seen in High Risk (its aura in the group, the 8th field of MISSION;..., or a refusal); tried: the
-- last mission asked of each, offered again in High Risk after a refusal.
local M = { alts = {}, status = {}, queue = {}, nextSend = 0, nextPoll = 0, polled = {}, mail = {}, done = {}, risk = {}, tried = {},
	can = {} }
-- Read by Dashboard.lua: the missions of each alt, Go and Recall; M.watcher() true keeps the polls going.
SquidBotsLite_Missions = M
M.MAX_OUT = MAX_OUT
-- CoA's High Risk ruleset aura (mod-playerbots CoaMissionAction.cpp, MISSION_HIGH_RISK_AURA).
local HIGH_RISK_AURA = 1004019

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text)
end

local function Whisper(name, text)
	M.polled[name] = GetTime()
	SquidBotsLite_QuietWhisper(text, name)
end

-- The online alts, from the My alts roster (".playerbots bot list").
function M.Refresh()
	M.alts = SquidBotsLite_OnlineAlts and SquidBotsLite_OnlineAlts() or {}
	table.sort(M.alts)
end

function M.Poll()
	M.Refresh()
	M.queue = {}
	local queued = {}
	for _, name in ipairs(M.alts) do
		table.insert(M.queue, { name, "mission status" })
		queued[name] = true
		-- What it can be sent to: once, then again every 5 minutes (a new skill, a pick bought).
		local can = M.can[name]
		if not can or GetTime() - can.at > 300 then table.insert(M.queue, { name, "mission can" }) end
	end
	for name in pairs(SquidBotsLiteDB.missionOut or {}) do
		if not queued[name] then table.insert(M.queue, { name, "mission status" }) end
	end
	M.nextPoll = GetTime() + POLL_EVERY
end

-- "MISSIONCAN;32;skinning;fishing:80:nopole,skinning:150:ok,cloth:32:ok"
function M.OnCan(name, message)
	local level, suggested, list = message:match("^MISSIONCAN;(%d+);(%a*);(.*)$")
	if not level then return end
	local can = { level = tonumber(level), suggested = suggested, list = {}, by = {}, at = GetTime() }
	for activity, skill, state in list:gmatch("(%a+):(%d+):(%a+)") do
		if KNOWN_SKILL[activity] then
			local entry = { activity = activity, skill = tonumber(skill), state = state }
			table.insert(can.list, entry)
			can.by[activity] = entry
		end
	end
	M.can[name] = can
	M.RefreshPanel()
end

-- The activity chosen on its card: the player's last choice if it still can, else the suggested one.
function M.Pick(name)
	local can = M.can[name]
	local picked = SquidBotsLiteDB.missionPick and SquidBotsLiteDB.missionPick[name]
	if not can then return picked end
	local entry = picked and can.by[picked]
	if entry and entry.state == "ok" then return picked end
	return can.suggested ~= "" and can.suggested or nil
end

function M.Minutes(name)
	return SquidBotsLiteDB.missionMinutes and SquidBotsLiteDB.missionMinutes[name] or 60
end

function M.ActivityName(skill)
	return skill and T(ACTIVITY_NAME[skill] or "AUTO") or T("AUTO")
end

function M.OnMission(name)
	local s = M.status[name]
	return s and s.state ~= "NONE"
end

function M.Count()
	local n = 0
	for name in pairs(M.status) do if M.OnMission(name) then n = n + 1 end end
	return n
end

-- In the group, its aura tells; else what the alt said last.
function M.InHighRisk(name)
	local units = {}
	for i = 1, 4 do table.insert(units, "party" .. i) end
	for i = 1, GetNumRaidMembers() do table.insert(units, "raid" .. i) end
	for _, unit in ipairs(units) do
		if UnitName(unit) == name then
			for _, filter in ipairs({ "HELPFUL", "HARMFUL" }) do
				for i = 1, 40 do
					local aura, _, _, _, _, _, _, _, _, _, spell = UnitAura(unit, i, filter)
					if not aura then break end
					if spell == HIGH_RISK_AURA then return true end
				end
			end
			return M.risk[name] or false
		end
	end
	return M.risk[name] or false
end

-- "MISSION;WORK;Elwynn Forest;42;17;mining;0;1" (8th field from 2.8.3: risk 0|1) or "MISSION;NONE".
function M.OnStatus(name, message)
	local parts = {}
	for field in (message .. ";"):gmatch("([^;]*);") do table.insert(parts, field) end
	SquidBotsLiteDB.missionOut = SquidBotsLiteDB.missionOut or {}
	SquidBotsLiteDB.missionOut[name] = parts[2] ~= "NONE" or nil
	if parts[2] == "NONE" then
		M.status[name] = { state = "NONE" }
	else
		M.status[name] = { state = parts[2], zone = parts[3] or "?", minutes = tonumber(parts[4] or "") or 0,
			items = tonumber(parts[5] or "") or 0, skill = parts[6], deaths = tonumber(parts[7] or "") or 0 }
		if parts[8] == "1" then M.risk[name] = true end
		if KNOWN_SKILL[parts[6]] then
			SquidBotsLiteDB.missionSkill = SquidBotsLiteDB.missionSkill or {}
			SquidBotsLiteDB.missionSkill[name] = parts[6]
		end
	end
	M.RefreshPanel()
end

-- The alt's own lines: started (ask its state), done (mail coming), refused or resumed (shown as they are).
function M.OnLine(name, message)
	if message:find("^Mission started: ") or message:find("^Mission resumed: ") then
		local skill = message:match("^Mission %a+: (%a+) in ") or message:match("%((%a+)%) in ")
		local count, item = message:match("^Mission %a+: order of (%d+) (.-) %(")
		SquidBotsLiteDB.missionOrder = SquidBotsLiteDB.missionOrder or {}
		if count then
			SquidBotsLiteDB.missionOrder[name] = { count = tonumber(count), item = item }
		elseif message:find("^Mission started: ") then
			SquidBotsLiteDB.missionOrder[name] = nil
		end
		if KNOWN_SKILL[skill] then
			SquidBotsLiteDB.missionSkill = SquidBotsLiteDB.missionSkill or {}
			SquidBotsLiteDB.missionSkill[name] = skill
		end
		M.done[name] = nil
		SquidBotsLiteDB.missionOut = SquidBotsLiteDB.missionOut or {}
		SquidBotsLiteDB.missionOut[name] = true
		table.insert(M.queue, { name, "mission status" })
		-- Logged in again with a mission going on: it goes back to work, out of the group; say why.
		if message:find("^Mission resumed: ") then
			Print(string.format(T("RESUMED"), name))
			if UIErrorsFrame then UIErrorsFrame:AddMessage(string.format(T("RESUMED"), name), 1, 0.82, 0) end
		end
	elseif message:find("^Mission done: ") then
		M.status[name] = { state = "NONE" }
		if M.watching == name then M.Unwatch(true) end
		local count = tonumber(message:match("(%d+) items sent to you by mail") or "")
		M.done[name] = count or 0
		if SquidBotsLiteDB.missionOut then SquidBotsLiteDB.missionOut[name] = nil end
		if SquidBotsLiteDB.missionOrder then SquidBotsLiteDB.missionOrder[name] = nil end
		M.back, M.backUntil = name, GetTime() + 120
		if count and count > 0 then M.mail[name] = count end
		local rest = message:match("^Mission done: (.*)$") or ""
		if UIErrorsFrame then UIErrorsFrame:AddMessage(string.format(T("DONE"), name, rest), 1, 0.82, 0) end
		M.RefreshPanel()
	elseif message:find("^Mission refused: I am in High Risk") then
		-- Asked without "risk": the same mission again, once the player has read the warning.
		M.risk[name] = true
		local tried = M.tried[name]
		if tried then M.ConfirmRisk(name, tried.minutes, tried.skill) end
	end
end

function M.WatchBar()
	if M.bar then return M.bar end
	local f = CreateFrame("Frame", "SquidBotsLiteWatch", UIParent)
	f:SetHeight(34)
	f:SetPoint("TOP", 0, -110)
	f:SetFrameStrata("DIALOG")
	f:SetBackdrop(SquidBotsLite_UI.CARD)
	f:SetBackdropColor(0.05, 0.05, 0.06, 0.9)
	f:SetBackdropBorderColor(1, 0.82, 0, 0.6)
	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetWidth(20)
	f.icon:SetHeight(20)
	f.icon:SetPoint("LEFT", 8, 0)
	f.icon:SetTexture("Interface\\Icons\\Ability_EyeOfTheOwl")
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.text:SetPoint("LEFT", f.icon, "RIGHT", 8, 0)
	f.back = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.back:SetWidth(110)
	f.back:SetHeight(22)
	f.back:SetPoint("RIGHT", -6, 0)
	f.back:SetScript("OnClick", function() M.Unwatch() end)
	f.back:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(T("TIP_WATCH_BACK"), 1, 1, 1)
		GameTooltip:Show()
	end)
	f.back:SetScript("OnLeave", function() GameTooltip:Hide() end)
	if SquidBotsLite_UI.Flatten then SquidBotsLite_UI.Flatten(f.back) end
	-- Escape closes it too, and closing it ends the view.
	table.insert(UISpecialFrames, "SquidBotsLiteWatch")
	f:SetScript("OnHide", function() if M.watching then M.Unwatch() end end)
	f:Hide()
	M.bar = f
	return f
end

function M.ShowWatchBar(text)
	local f = M.WatchBar()
	f.text:SetText(text)
	f.back:SetText(T("WATCH_BACK"))
	f:SetWidth(f.text:GetStringWidth() + 160)
	f:Show()
end

function M.Watch(name)
	if M.watching and M.watching ~= name then Whisper(M.watching, "mission unwatch") end
	M.watching = name
	Whisper(name, "mission watch")
	M.ShowWatchBar(string.format(T("WATCH_WAIT"), SquidBotsLite_UI.ClassName(name)))
	M.RefreshPanel()
end

-- From here (button, Escape), or because the alt ended it (refused, mission over, other continent).
function M.Unwatch(silent)
	local name = M.watching
	M.watching = nil
	if name and not silent then Whisper(name, "mission unwatch") end
	if M.bar and M.bar:IsShown() then M.bar:Hide() end
	M.RefreshPanel()
end

function M.OnWatch(name, message)
	if name ~= M.watching then return end
	if message:find("^Watch on: ") then
		local s = M.status[name]
		M.ShowWatchBar(string.format(T("WATCH_BAR"), SquidBotsLite_UI.ClassName(name)) .. ((s and s.zone) and ("  |cffaaaaaa" .. s.zone .. "|r") or ""))
	else
		local reason = (message:match("^Watch %a+: (.-)%.?$") or ""):gsub("%.$", "")
		local key = message:find("^Watch refused: ") and "WATCH_REFUSED" or "WATCH_OFF"
		Print(string.format(T(key), name, reason))
		M.Unwatch(true)
	end
end

function M.Send(name, minutes, skill, risk)
	M.done[name] = nil
	M.tried[name] = { minutes = minutes, skill = skill }
	local text = "mission gather " .. minutes .. (skill and (" " .. skill) or "") .. (risk and " risk" or "")
	SquidBotsLiteDB.missionTotal = SquidBotsLiteDB.missionTotal or {}
	SquidBotsLiteDB.missionTotal[name] = minutes
	SquidBotsLiteDB.missionLast = SquidBotsLiteDB.missionLast or {}
	SquidBotsLiteDB.missionLast[name] = { minutes = minutes, skill = skill }
	Whisper(name, text)
end

function M.Order(name, item, count)
	M.done[name] = nil
	-- Its length is the server's default: the bar takes it from the first status.
	if SquidBotsLiteDB.missionTotal then SquidBotsLiteDB.missionTotal[name] = nil end
	Whisper(name, "mission order " .. item .. " " .. (count or ORDER_DEFAULT))
	if M.orderFrame then M.orderFrame:Hide() end
end

-- An item dropped on the button or the order window (or clicked with it on the cursor): ordered by its id.
function M.OrderCursor(name)
	local kind, id = GetCursorInfo()
	if not name or kind ~= "item" or not id then return false end
	ClearCursor()
	M.Order(name, id, M.orderFrame and M.orderFrame:IsShown() and M.OrderCount() or nil)
	return true
end

function M.Recall(name)
	StaticPopupDialogs.SQUIDBOTSLITE_MISSION_RECALL = {
		text = T("RECALL_ASK"), button1 = YES, button2 = NO, timeout = 0, whileDead = true, hideOnEscape = true,
		OnAccept = function(_, data) Whisper(data, "mission stop") end,
	}
	local dialog = StaticPopup_Show("SQUIDBOTSLITE_MISSION_RECALL", name)
	if dialog then dialog.data = name end
end

-- High Risk: a red warning first; Accept sends "mission gather <minutes> [skill] risk".
function M.ConfirmRisk(name, minutes, skill)
	StaticPopupDialogs.SQUIDBOTSLITE_MISSION_RISK = {
		text = "%s", button1 = T("RISK_SEND"), button2 = CANCEL, timeout = 0, whileDead = true, hideOnEscape = true,
		showAlert = true,
		OnAccept = function(_, data) M.Send(data.name, data.minutes, data.skill, true) end,
	}
	local what = M.ActivityName(skill)
	local dialog = StaticPopup_Show("SQUIDBOTSLITE_MISSION_RISK", string.format(T("RISK_ASK"), name, what, minutes))
	if dialog then dialog.data = { name = name, minutes = minutes, skill = skill } end
end

-- Sent as it is, or through the warning when the alt is in High Risk.
function M.Go(name, minutes, skill)
	if M.InHighRisk(name) then M.ConfirmRisk(name, minutes, skill) else M.Send(name, minutes, skill) end
end

-- Team bar and key binding: every alt out, after one question.
function SquidBotsLite_RecallAll()
	local out = {}
	for name in pairs(M.status) do if M.OnMission(name) then table.insert(out, name) end end
	if #out == 0 then return end
	StaticPopupDialogs.SQUIDBOTSLITE_MISSION_RECALL_ALL = {
		text = T("RECALL_ALL_ASK"), button1 = YES, button2 = NO, timeout = 0, whileDead = true, hideOnEscape = true,
		OnAccept = function(_, data) for _, name in ipairs(data) do Whisper(name, "mission stop") end end,
	}
	local dialog = StaticPopup_Show("SQUIDBOTSLITE_MISSION_RECALL_ALL", #out)
	if dialog then dialog.data = out end
end

-- ---------------------------------------------------------------------------
-- The panel: a card per logged-in alt, with its state, a bar of the time spent, the loot and the deaths
-- ---------------------------------------------------------------------------
local UI = SquidBotsLite_UI
local PHASE_ICON = { TRAVEL = "Interface\\Icons\\Ability_Mount_RidingHorse", DELIVER = "Interface\\Icons\\INV_Letter_15" }
local PHASE_COLOR = { TRAVEL = { 0.3, 0.6, 1 }, WORK = { 0.3, 0.85, 0.3 }, DELIVER = { 1, 0.82, 0 } }
local BADGE_COLOR = { FREE = { 0.3, 0.85, 0.3 }, OUT = { 1, 0.82, 0 }, DONE = { 0.4, 0.7, 1 }, WAIT = { 0.6, 0.6, 0.6 } }
local SEND_ICON, RECALL_ICON = "Interface\\Icons\\Ability_Hunter_Pathfinding", "Interface\\Icons\\INV_Misc_Rune_01"

local function Icon(parent, size, layer)
	local texture = parent:CreateTexture(nil, layer or "ARTWORK")
	texture:SetWidth(size)
	texture:SetHeight(size)
	texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	return texture
end

local function Rule(f, point, y)
	local rule = f:CreateTexture(nil, "ARTWORK")
	rule:SetTexture("Interface\\Buttons\\WHITE8X8")
	rule:SetVertexColor(1, 0.82, 0, 0.18)
	rule:SetHeight(1)
	rule:SetPoint(point .. "LEFT", 16, y)
	rule:SetPoint(point .. "RIGHT", -16, y)
end

-- ---------------------------------------------------------------------------
-- Order: a small window, a search field over the classic materials, at most 6 suggestions for the activity
-- chosen and the alt's level, a quantity, and an item of the bags dropped on it
-- ---------------------------------------------------------------------------
local ORDER_ROWS, ORDER_ROW_H = 8, 22
local FOLD = { ["à"] = "a", ["â"] = "a", ["ä"] = "a", ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e", ["î"] = "i",
	["ï"] = "i", ["ô"] = "o", ["ö"] = "o", ["ù"] = "u", ["û"] = "u", ["ü"] = "u", ["ç"] = "c", ["À"] = "a", ["Â"] = "a",
	["É"] = "e", ["È"] = "e", ["Ê"] = "e", ["Î"] = "i", ["Ô"] = "o", ["Û"] = "u", ["Ç"] = "c", ["œ"] = "oe", ["Œ"] = "oe" }

-- Lower case, without accents, so that "peche" finds "Pêche".
local function Fold(text)
	-- Accents first: lower() may change the bytes of a UTF-8 letter.
	text = (text or ""):gsub("[\195\197][\128-\191]", function(c) return FOLD[c] or c end)
	return text:lower()
end

local function MaterialName(def)
	return (GetItemInfo(def[1])) or def[4]
end

-- Why this alt cannot gather it, or nil when it can.
local function Unreachable(name, def)
	local can = M.can[name]
	if not can then return nil end
	local activity = def[2]
	if activity == "cloth" then
		local level = can.level or 0
		if level < def[3] then return string.format(T("WHY_LEVEL"), def[3], def[5] or def[3]) end
		return nil
	end
	local entry = can.by[activity]
	if not entry then return string.format(T("WHY_NOSKILL"), T(ACTIVITY_NAME[activity])) end
	if entry.state ~= "ok" then return T("WHY_" .. entry.state) end
	if entry.skill < def[3] then return string.format(T("WHY_SKILL"), T(ACTIVITY_NAME[activity]), def[3]) end
	return nil
end

-- The list shown: what the search finds (all activities), else the 6 best of the activity chosen it can gather.
function M.OrderList(name, search)
	local list = {}
	local wanted = Fold(search)
	if wanted ~= "" then
		for _, def in ipairs(MATERIALS) do
			if Fold(MaterialName(def)):find(wanted, 1, true) or Fold(def[4]):find(wanted, 1, true) then table.insert(list, def) end
		end
		return list
	end
	local activity = M.Pick(name) or SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name] or "cloth"
	local can = M.can[name]
	for i = #MATERIALS, 1, -1 do
		local def = MATERIALS[i]
		if def[2] == activity and not Unreachable(name, def) then
			-- Cloth: the cloth of humanoids around its level, not those far below it.
			if activity ~= "cloth" or not can or (def[5] or 60) + 8 >= (can.level or 0) then table.insert(list, def) end
		end
		if #list >= 6 then break end
	end
	return list
end

function M.BuildOrder()
	local f = CreateFrame("Frame", "SquidBotsLiteOrder", UIParent)
	f:SetWidth(280)
	f:SetHeight(84 + ORDER_ROWS * ORDER_ROW_H + 40)
	f:SetBackdrop(BACKDROP)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.97)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteOrder")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	f.search = CreateFrame("EditBox", "SquidBotsLiteOrderSearch", f, "InputBoxTemplate")
	f.search:SetWidth(232)
	f.search:SetHeight(20)
	f.search:SetPoint("TOPLEFT", 24, -38)
	f.search:SetAutoFocus(false)
	f.search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f.search:SetScript("OnTextChanged", function() M.RefreshOrder() end)
	f.search:SetScript("OnEditFocusGained", function() f.typing = true; M.RefreshOrder() end)
	f.search:SetScript("OnEditFocusLost", function() f.typing = nil; M.RefreshOrder() end)
	f.hint = f.search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("LEFT", 4, 0)
	f.caption = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.caption:SetPoint("TOPLEFT", 20, -64)
	f.scroll = CreateFrame("ScrollFrame", "SquidBotsLiteOrderScroll", f, "FauxScrollFrameTemplate")
	f.scroll:SetPoint("TOPLEFT", 16, -78)
	f.scroll:SetWidth(232)
	f.scroll:SetHeight(ORDER_ROWS * ORDER_ROW_H)
	f.scroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ORDER_ROW_H, M.RefreshOrder)
	end)
	f.rows = {}
	for i = 1, ORDER_ROWS do
		local row = CreateFrame("Button", nil, f)
		row:SetWidth(232)
		row:SetHeight(ORDER_ROW_H - 2)
		row:SetPoint("TOPLEFT", 18, -78 - (i - 1) * ORDER_ROW_H)
		row:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
		row:GetHighlightTexture():SetVertexColor(1, 0.82, 0, 0.12)
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(18)
		row.icon:SetHeight(18)
		row.icon:SetPoint("LEFT", 2, 0)
		row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
		row.text:SetWidth(200)
		row.text:SetJustifyH("LEFT")
		row:SetScript("OnClick", function(self)
			if self.def and not self.why then M.Order(f.alt, self.def[1], M.OrderCount()) end
		end)
		row:SetScript("OnEnter", function(self)
			if not self.def then return end
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink("item:" .. self.def[1])
			GameTooltip:AddLine(self.why and ("|cffff6666" .. self.why .. "|r") or T("TIP_ORDER_ROW"), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f.rows[i] = row
	end
	-- How many: 10 / 20 / 40, or typed.
	f.qtyLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.qtyLabel:SetPoint("BOTTOMLEFT", 20, 46)
	f.qtyLabel:SetText(T("ORDER_QTY"))
	f.counts = {}
	for i, count in ipairs(ORDER_COUNTS) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetWidth(34)
		b:SetHeight(18)
		b:SetText(count)
		b:SetPoint("LEFT", f.qtyLabel, "RIGHT", 6 + (i - 1) * 38, 0)
		b:SetScript("OnClick", function()
			f.count = count
			f.qty:SetText("")
			M.RefreshOrder()
		end)
		f.counts[i] = b
	end
	f.qty = CreateFrame("EditBox", "SquidBotsLiteOrderQty", f, "InputBoxTemplate")
	f.qty:SetWidth(40)
	f.qty:SetHeight(18)
	f.qty:SetPoint("LEFT", f.counts[#f.counts], "RIGHT", 12, 0)
	f.qty:SetAutoFocus(false)
	f.qty:SetNumeric(true)
	f.qty:SetMaxLetters(4)
	f.qty:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f.qty:SetScript("OnTextChanged", function() M.RefreshOrder() end)
	f.drop = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.drop:SetPoint("BOTTOMLEFT", 20, 20)
	f.drop:SetWidth(240)
	f.drop:SetJustifyH("LEFT")
	-- An item of the bags dropped anywhere on the window.
	f:SetScript("OnReceiveDrag", function() M.OrderCursor(f.alt) end)
	f:SetScript("OnMouseUp", function() M.OrderCursor(f.alt) end)
	-- Names the client did not know yet come with the item's data.
	f:SetScript("OnUpdate", function(self, delta)
		self.wait = (self.wait or 0) + delta
		if self.missing and self.wait > 1 then
			self.wait = 0
			M.RefreshOrder()
		end
	end)
	if UI.FlattenAll then UI.FlattenAll(f) end
	f:Hide()
	M.orderFrame = f
end

function M.OrderCount()
	local f = M.orderFrame
	local typed = f and tonumber(f.qty:GetText() or "")
	if typed and typed > 0 then return math.min(typed, 1000) end
	return f and f.count or ORDER_DEFAULT
end

function M.RefreshOrder()
	local f = M.orderFrame
	if not f or not f:IsShown() or not f.alt then return end
	local name = f.alt
	f.title:SetText(string.format(T("ORDER_TITLE"), UI.ClassName(name)))
	local search = f.search:GetText() or ""
	f.hint:SetText(search == "" and not f.typing and T("SEARCH") or "")
	f.caption:SetText(search == "" and T("ORDER_SUGGEST") or "")
	f.drop:SetText(T("ORDER_DROP"))
	local typed = tonumber(f.qty:GetText() or "")
	for i, b in ipairs(f.counts) do
		if not typed and ORDER_COUNTS[i] == (f.count or ORDER_DEFAULT) then b:LockHighlight() else b:UnlockHighlight() end
	end
	local list = M.OrderList(name, search)
	FauxScrollFrame_Update(f.scroll, #list, ORDER_ROWS, ORDER_ROW_H)
	local offset = FauxScrollFrame_GetOffset(f.scroll)
	f.missing = false
	for i, row in ipairs(f.rows) do
		local def = list[offset + i]
		row.def = def
		if def then
			local known = GetItemInfo(def[1])
			if not known then
				f.missing = true
				-- Asks the server for it: the name comes a moment later.
				M.cacheTip = M.cacheTip or CreateFrame("GameTooltip", "SquidBotsLiteOrderCache", UIParent, "GameTooltipTemplate")
				M.cacheTip:SetOwner(UIParent, "ANCHOR_NONE")
				M.cacheTip:SetHyperlink("item:" .. def[1])
			end
			row.why = Unreachable(name, def)
			row.icon:SetTexture((GetItemIcon and GetItemIcon(def[1])) or UI.LOOT_ICON[def[2]] or UI.UNKNOWN)
			row.icon:SetDesaturated(row.why ~= nil)
			local label = MaterialName(def)
			if row.why then
				row.text:SetText("|cff808080" .. label .. "  (" .. row.why .. ")|r")
			else
				row.text:SetText(label)
			end
			row:Show()
		else
			row:Hide()
		end
	end
	if #list == 0 then
		f.rows[1].def = nil
		f.rows[1].why = nil
		f.rows[1].icon:SetTexture(nil)
		f.rows[1].text:SetText("|cff808080" .. T("ORDER_NONE") .. "|r")
		f.rows[1]:Show()
	end
end

function M.OrderWindow(name)
	if not M.orderFrame then M.BuildOrder() end
	local f = M.orderFrame
	f.alt = name
	f.count = f.count or ORDER_DEFAULT
	f.search:SetText("")
	f.qty:SetText("")
	f:ClearAllPoints()
	if M.panel and M.panel:IsShown() then f:SetPoint("TOPLEFT", M.panel, "TOPRIGHT", 4, 0) else f:SetPoint("CENTER") end
	f:Show()
	f:Raise()
	if not M.can[name] then Whisper(name, "mission can") end
	M.RefreshOrder()
end

function M.BuildRow(f, i)
	local row = CreateFrame("Frame", nil, f)
	row:SetWidth(408)
	row:SetHeight(ROW_H - 8)
	row:SetPoint("TOPLEFT", 16, -ROWS_TOP - (i - 1) * ROW_H)
	UI.Card(row)
	-- Its portrait or class icon, its gathering skill in the corner.
	row.icon = Icon(row, 38)
	row.icon:SetPoint("LEFT", 8, 0)
	row.skill = Icon(row, 16, "OVERLAY")
	row.skill:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 4, -4)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetPoint("TOPLEFT", 56, -8)
	row.name:SetJustifyH("LEFT")
	-- The state, as a small coloured pill after the name: free, on a mission, done.
	row.badge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.badge:SetPoint("LEFT", row.name, "RIGHT", 12, 0)
	row.pill = row:CreateTexture(nil, "BORDER")
	row.pill:SetTexture("Interface\\Buttons\\WHITE8X8")
	row.pill:SetPoint("TOPLEFT", row.badge, "TOPLEFT", -5, 2)
	row.pill:SetPoint("BOTTOMRIGHT", row.badge, "BOTTOMRIGHT", 5, -2)
	-- The phase: its icon and where.
	row.phase = Icon(row, 14)
	row.phase:SetPoint("TOPLEFT", 56, -27)
	row.line = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.line:SetPoint("LEFT", row.phase, "RIGHT", 5, 0)
	row.line:SetWidth(270)
	row.line:SetJustifyH("LEFT")
	row.line:SetTextColor(0.75, 0.75, 0.75)
	-- The time spent out of the mission's, the minutes left written on it.
	row.bar = CreateFrame("StatusBar", nil, row)
	row.bar:SetWidth(210)
	row.bar:SetHeight(10)
	row.bar:SetPoint("TOPLEFT", 56, -46)
	row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	row.bar:SetMinMaxValues(0, 1)
	row.bar.bg = row.bar:CreateTexture(nil, "BACKGROUND")
	row.bar.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
	row.bar.bg:SetVertexColor(0, 0, 0, 0.7)
	row.bar.bg:SetPoint("TOPLEFT", -1, 1)
	row.bar.bg:SetPoint("BOTTOMRIGHT", 1, -1)
	row.bar.text = row.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.bar.text:SetPoint("CENTER", 0, 1)
	row.bar.text:SetFont(row.bar.text:GetFont(), 9, "OUTLINE")
	-- What it gathered (ore or herb), and its deaths in red with a skull, only once it died.
	row.loot = Icon(row, 14)
	row.loot:SetPoint("LEFT", row.bar, "RIGHT", 10, 0)
	row.items = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.items:SetPoint("LEFT", row.loot, "RIGHT", 3, 0)
	row.rate = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.rate:SetPoint("LEFT", row.items, "RIGHT", 4, 0)
	row.skull = row:CreateTexture(nil, "ARTWORK")
	row.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
	row.skull:SetWidth(14)
	row.skull:SetHeight(14)
	row.skull:SetPoint("LEFT", row.rate, "RIGHT", 8, 0)
	row.deaths = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.deaths:SetPoint("LEFT", row.skull, "RIGHT", 2, 0)
	row.deaths:SetTextColor(1, 0.35, 0.35)
	-- Recall, while it is out.
	row.action = UI.IconButton(row, 32, RECALL_ICON, function() return T("RECALL"), T("TIP_RECALL") end, function(self)
		local name = self:GetParent().alt
		if name and M.OnMission(name) then M.Recall(name) end
	end)
	row.action:SetPoint("RIGHT", -12, 0)
	-- At home: the activities it can be sent to (small icons, the chosen one framed in gold), the length, Send.
	row.acts = {}
	for a = 1, #ACTIVITIES do
		local b = CreateFrame("Button", nil, row)
		b:SetWidth(18)
		b:SetHeight(18)
		b.frame = b:CreateTexture(nil, "BACKGROUND")
		b.frame:SetTexture("Interface\\Buttons\\WHITE8X8")
		b.frame:SetPoint("TOPLEFT", -2, 2)
		b.frame:SetPoint("BOTTOMRIGHT", 2, -2)
		b.icon = b:CreateTexture(nil, "ARTWORK")
		b.icon:SetAllPoints()
		b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		b:SetScript("OnClick", function(self)
			local name = row.alt
			if not name or self.why then return end
			SquidBotsLiteDB.missionPick = SquidBotsLiteDB.missionPick or {}
			SquidBotsLiteDB.missionPick[name] = self.activity
			M.RefreshPanel()
		end)
		b:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(M.ActivityName(self.activity), 1, 0.82, 0)
			GameTooltip:AddLine(T(self.activity and ("TIP_" .. self.activity) or "TIP_AUTO"), 1, 1, 1, true)
			if self.why then GameTooltip:AddLine(self.why, 1, 0.4, 0.4, true)
			elseif self.suggested then GameTooltip:AddLine(T("SUGGESTED"), 0.4, 1, 0.4, true) end
			GameTooltip:Show()
		end)
		b:SetScript("OnLeave", function() GameTooltip:Hide() end)
		b:SetPoint("TOPLEFT", 66 + (a - 1) * 24, -50)
		row.acts[a] = b
	end
	row.lengths = {}
	for d, minutes in ipairs(DURATIONS) do
		local b = CreateFrame("Button", nil, row)
		b:SetWidth(28)
		b:SetHeight(16)
		b.bg = b:CreateTexture(nil, "BACKGROUND")
		b.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
		b.bg:SetAllPoints()
		b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		b.text:SetPoint("CENTER", 0, 0)
		b.text:SetText(minutes)
		b:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
		b:GetHighlightTexture():SetVertexColor(1, 0.82, 0, 0.15)
		b:SetScript("OnClick", function()
			local name = row.alt
			if not name then return end
			SquidBotsLiteDB.missionMinutes = SquidBotsLiteDB.missionMinutes or {}
			SquidBotsLiteDB.missionMinutes[name] = minutes
			M.RefreshPanel()
		end)
		b:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(string.format(T("MIN"), minutes), 1, 0.82, 0)
			GameTooltip:AddLine(T("TIP_MINUTES"), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		b:SetScript("OnLeave", function() GameTooltip:Hide() end)
		b:SetPoint("TOPLEFT", 66 + #ACTIVITIES * 24 + 10 + (d - 1) * 30, -51)
		row.lengths[d] = b
	end
	row.send = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	row.send:SetWidth(76)
	row.send:SetHeight(24)
	row.send:SetPoint("RIGHT", -10, 0)
	row.send:SetScript("OnClick", function()
		local name = row.alt
		if name and not M.OnMission(name) and M.Count() < MAX_OUT then M.Go(name, M.Minutes(name), M.Pick(name)) end
	end)
	row.send:SetScript("OnEnter", function(self)
		local name = row.alt
		if not name then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(T("SEND"), 1, 0.82, 0)
		if M.Count() >= MAX_OUT then
			GameTooltip:AddLine(T("TIP_FULL"), 1, 0.4, 0.4, true)
		else
			GameTooltip:AddLine(string.format(T("TIP_SEND_BTN"), M.ActivityName(M.Pick(name)), M.Minutes(name)), 1, 1, 1, true)
		end
		GameTooltip:Show()
	end)
	row.send:SetScript("OnLeave", function() GameTooltip:Hide() end)
	if UI.Flatten then UI.Flatten(row.send) end
	row.watch = UI.IconButton(row, 24, "Interface\\Icons\\Ability_EyeOfTheOwl", function() return T("WATCH"), T("TIP_WATCH") end,
		function(self)
			local name = self:GetParent().alt
			if not name then return end
			if M.watching == name then M.Unwatch() else M.Watch(name) end
		end)
	row.watch:SetPoint("RIGHT", row.action, "LEFT", -8, 0)
	row.watch:Hide()
	row.order = UI.IconButton(row, 24, "Interface\\Icons\\INV_Scroll_03", function() return T("ORDER"), T("TIP_ORDER") end,
		function(self)
			local name = self:GetParent().alt
			if not name or M.OrderCursor(name) then return end
			M.OrderWindow(name)
		end)
	row.order:SetScript("OnReceiveDrag", function(self)
		local name = self:GetParent().alt
		if name then M.OrderCursor(name) end
	end)
	row.order:SetPoint("RIGHT", row.send, "LEFT", -8, 0)
	row.order:Hide()
	return row
end

function M.Build()
	local f = CreateFrame("Frame", "SquidBotsLiteMissions", UIParent)
	f:SetWidth(440)
	f:SetPoint("CENTER", -200, 40)
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
	table.insert(UISpecialFrames, "SquidBotsLiteMissions")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	-- How many alts are out: one slot each, lit gold when taken.
	f.count = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.count:SetPoint("TOPLEFT", 20, -44)
	f.slots = {}
	for i = 1, MAX_OUT do
		local slot = f:CreateTexture(nil, "ARTWORK")
		slot:SetTexture("Interface\\Buttons\\WHITE8X8")
		slot:SetWidth(10)
		slot:SetHeight(10)
		slot:SetPoint("LEFT", f.count, "RIGHT", 8 + (i - 1) * 14, 0)
		f.slots[i] = slot
	end
	f.refresh = UI.IconButton(f, 22, "Interface\\Buttons\\UI-RefreshButton", function() return T("REFRESH"), T("TIP_REFRESH") end, function()
		if SquidBotsLite_AskRoster then SquidBotsLite_AskRoster() end
		-- A click asks again what each alt can do (a skill just learned, a pick just bought), not after 5 minutes.
		M.can = {}
		M.Poll()
		M.RefreshPanel()
	end)
	f.refresh.icon:SetTexCoord(0, 1, 0, 1)
	f.refresh:SetPoint("TOPRIGHT", -18, -38)
	Rule(f, "TOP", -66)
	f.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.empty:SetPoint("TOPLEFT", 20, -ROWS_TOP - 8)
	f.empty:SetWidth(400)
	f.empty:SetJustifyH("LEFT")
	f.rows = {}
	for i = 1, ROWS do f.rows[i] = M.BuildRow(f, i) end
	Rule(f, "BOTTOM", 34)
	f.help = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.help:SetPoint("BOTTOMLEFT", 18, 16)
	f.help:SetWidth(404)
	f.help:SetJustifyH("LEFT")
	-- The whole story in the tooltip of the help line's area.
	f.helpArea = CreateFrame("Frame", nil, f)
	f.helpArea:SetPoint("BOTTOMLEFT", 16, 8)
	f.helpArea:SetPoint("BOTTOMRIGHT", -16, 8)
	f.helpArea:SetHeight(24)
	f.helpArea:EnableMouse(true)
	f.helpArea:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(T("TITLE"), 1, 0.82, 0)
		GameTooltip:AddLine(T("HINT"), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	f.helpArea:SetScript("OnLeave", function() GameTooltip:Hide() end)
	if UI.FlattenAll then UI.FlattenAll(f) end
	f:Hide()
	M.panel = f
end

local function Badge(row, key, color)
	row.badge:SetText(T(key))
	row.badge:SetTextColor(color[1], color[2], color[3])
	row.pill:SetVertexColor(color[1], color[2], color[3], 0.18)
end

-- The mission's length: the one chosen from here, else the minutes left first seen, rounded up to half hours.
local function Total(name, left)
	SquidBotsLiteDB.missionTotal = SquidBotsLiteDB.missionTotal or {}
	local total = SquidBotsLiteDB.missionTotal[name]
	if not total or left > total then
		total = math.min(120, math.max(30, math.ceil(left / 30) * 30))
		SquidBotsLiteDB.missionTotal[name] = total
	end
	return total
end

function M.ShowOut(row, name, s)
	local skill = s.skill or (SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name])
	local color = PHASE_COLOR[s.state] or PHASE_COLOR.DELIVER
	Badge(row, "BADGE_OUT", BADGE_COLOR.OUT)
	row.phase:SetTexture(s.state == "WORK" and (UI.SKILL_ICON[skill] or UI.UNKNOWN) or PHASE_ICON[s.state] or PHASE_ICON.DELIVER)
	if s.state == "TRAVEL" then
		row.line:SetText(string.format(T("TRAVEL"), "|cffffffff" .. s.zone .. "|r"))
	elseif s.state == "WORK" then
		row.line:SetText(string.format(T("WORK"), "|cffffffff" .. s.zone .. "|r"))
	else
		row.line:SetText(T("DELIVER"))
	end
	local total = Total(name, s.minutes)
	row.bar:SetValue((total - s.minutes) / total)
	row.bar:SetStatusBarColor(color[1], color[2], color[3])
	row.bar.text:SetText(string.format(T("LEFT"), s.minutes) .. "  ·  " .. string.format(T("BACK_AT"), date("%H:%M", time() + s.minutes * 60)))
	-- Items an hour, once it has worked a little.
	local spent = total - s.minutes
	row.rate:SetText(spent >= 5 and s.items > 0 and string.format(T("RATE"), math.floor(s.items * 60 / spent + 0.5)) or "")
	row.rate:Show()
	row.bar:Show()
	row.loot:SetTexture(UI.LOOT_ICON[skill] or UI.UNKNOWN)
	row.items:SetText(s.items)
	row.loot:Show()
	row.items:Show()
	if s.deaths > 0 then
		row.deaths:SetText(s.deaths)
		row.skull:Show()
		row.deaths:Show()
	else
		row.skull:Hide()
		row.deaths:Hide()
	end
	local order = SquidBotsLiteDB.missionOrder and SquidBotsLiteDB.missionOrder[name]
	if order and s.state ~= "DELIVER" then
		row.line:SetText(row.line:GetText() .. "  |cffff9933" .. string.format(T("ORDER_LINE"), order.count, order.item) .. "|r")
	end
	UI.SetIcon(row.action, RECALL_ICON, true)
	row.action:Show()
	row.send:Hide()
	for _, b in ipairs(row.acts) do b:Hide() end
	for _, b in ipairs(row.lengths) do b:Hide() end
	row.order:Hide()
	row.watch:Show()
	row.watch.icon:SetVertexColor(1, 1, M.watching == name and 0.4 or 1)
end

function M.ShowIdle(row, name, s)
	local skill = M.Pick(name) or (SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name])
	row.bar:Hide()
	row.loot:Hide()
	row.items:Hide()
	row.rate:Hide()
	row.skull:Hide()
	row.deaths:Hide()
	local done = M.done[name]
	if done then
		Badge(row, "BADGE_DONE", BADGE_COLOR.DONE)
		row.phase:SetTexture(PHASE_ICON.DELIVER)
		row.line:SetText(done > 0 and string.format(T("DONE_LINE"), done) or T("DONE_NOTHING"))
	elseif s then
		Badge(row, "BADGE_FREE", BADGE_COLOR.FREE)
		row.phase:SetTexture(UI.SKILL_ICON[skill] or SEND_ICON)
		row.line:SetText(skill and string.format(T("READY_SKILL"), T("SKILL_" .. skill)) or T("READY"))
	else
		Badge(row, "BADGE_WAIT", BADGE_COLOR.WAIT)
		row.phase:SetTexture(SEND_ICON)
		row.line:SetText("|cff9d9d9d" .. T("WAIT") .. "|r")
	end
	row.action:Hide()
	row.watch:Hide()
	local free = M.Count() < MAX_OUT
	if s and free then row.order:Show() else row.order:Hide() end
	row.send:SetText(T("SEND_BTN"))
	if free and s then row.send:Enable() else row.send:Disable() end
	row.send:Show()
	M.ShowActivities(row, name)
end

-- The activities of its card: what MISSIONCAN listed (cloth always), the impossible ones greyed with why; before
-- the answer (or with an older server), one icon: its gathering skill, chosen by the server.
function M.ShowActivities(row, name)
	local can = M.can[name]
	local picked = M.Pick(name)
	local shown = {}
	if can then
		for _, activity in ipairs(ACTIVITIES) do
			local entry = can.by[activity]
			if entry then table.insert(shown, entry) end
		end
	else
		table.insert(shown, { activity = nil, state = "ok" })
	end
	for a, b in ipairs(row.acts) do
		local entry = shown[a]
		if entry then
			b.activity = entry.activity
			b.why = entry.state ~= "ok" and T("WHY_" .. entry.state) or nil
			b.suggested = can and entry.activity == can.suggested
			b.icon:SetTexture(entry.activity and UI.SKILL_ICON[entry.activity] or SEND_ICON)
			b.icon:SetDesaturated(b.why ~= nil)
			b.icon:SetAlpha(b.why and 0.6 or 1)
			if entry.activity == picked then b.frame:SetVertexColor(1, 0.82, 0, 1) else b.frame:SetVertexColor(0, 0, 0, 0.9) end
			b:Show()
		else
			b.activity = nil
			b:Hide()
		end
	end
	local minutes = M.Minutes(name)
	for d, b in ipairs(row.lengths) do
		local on = DURATIONS[d] == minutes
		b.bg:SetVertexColor(on and 1 or 1, on and 0.82 or 1, on and 0 or 1, on and 0.35 or 0.08)
		b.text:SetTextColor(on and 1 or 0.8, on and 0.82 or 0.8, on and 0 or 0.8)
		b:Show()
	end
end

function M.RefreshPanel()
	M.RefreshBadge()
	local f = M.panel
	if not f or not f:IsShown() then return end
	f.title:SetText("SquidBots Lite - " .. T("TITLE"))
	f.help:SetText(T("HELP"))
	local out = M.Count()
	f.count:SetText(T("OUT"))
	for i, slot in ipairs(f.slots) do
		if i <= out then slot:SetVertexColor(1, 0.82, 0, 1) else slot:SetVertexColor(1, 1, 1, 0.12) end
	end
	local alts = M.alts
	f:SetHeight(ROWS_TOP + math.max(1, math.min(#alts, ROWS)) * ROW_H + 44)
	f.empty:SetText(#alts == 0 and T("NO_ALTS") or "")
	for i, row in ipairs(f.rows) do
		local name = alts[i]
		if name then
			row.alt = name
			local s = M.status[name]
			local skill = SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name]
			row.name:SetText(UI.ClassName(name))
			UI.ClassIcon(row.icon, name)
			if skill and UI.SKILL_ICON[skill] then
				row.skill:SetTexture(UI.SKILL_ICON[skill])
				row.skill:Show()
			else
				row.skill:Hide()
			end
			if s and s.state ~= "NONE" then M.ShowOut(row, name, s) else M.ShowIdle(row, name, s) end
			row:Show()
		else
			row.alt = nil
			row:Hide()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Over the bar, on the right: how many alts are out and the soonest back; a click opens the panel
-- ---------------------------------------------------------------------------
function M.BuildBadge(bar)
	local b = CreateFrame("Button", nil, bar)
	b:SetHeight(20)
	b:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 4)
	-- No frame: an icon and an orange word, outlined to read on any ground.
	b.icon = Icon(b, 16)
	b.icon:SetPoint("LEFT", 4, 0)
	b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	-- A second icon when both skills are out.
	b.icon2 = Icon(b, 16)
	b.icon2:SetPoint("LEFT", b.icon, "RIGHT", 2, 0)
	b.text:SetPoint("LEFT", b.icon2, "RIGHT", 4, 0)
	b.text:SetFont(b.text:GetFont(), 10, "OUTLINE")
	b.glow = b:CreateTexture(nil, "HIGHLIGHT")
	b.glow:SetTexture("Interface\\Buttons\\WHITE8X8")
	b.glow:SetAllPoints()
	b.glow:SetBlendMode("ADD")
	b.glow:SetVertexColor(1, 0.6, 0.1, 0.08)
	b:SetScript("OnClick", function() if not (M.panel and M.panel:IsShown()) then SquidBotsLite_ShowMissions() end end)
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(T("TITLE"), 1, 0.82, 0)
		for name, st in pairs(M.status) do
			if M.OnMission(name) then
				local where = st.state == "DELIVER" and T("DELIVER") or st.zone
				GameTooltip:AddDoubleLine(UI.ClassName(name) .. "  |cffaaaaaa" .. where .. "|r",
					string.format(T("LEFT"), st.minutes) .. ", " .. string.format(T("ITEMS"), st.items), 1, 1, 1, 1, 1, 1)
			end
		end
		GameTooltip:AddLine(T("TIP_BADGE"), 0.4, 0.8, 1)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	b:Hide()
	M.badge = b
end

function M.RefreshBadge()
	local bar = _G.SquidBotsLiteBar
	if not bar then return end
	if not M.badge then M.BuildBadge(bar) end
	local b, out, soonest, skills = M.badge, 0, nil, {}
	for name, st in pairs(M.status) do
		if M.OnMission(name) then
			out = out + 1
			if not soonest or st.minutes < soonest then soonest = st.minutes end
			skills[st.skill or "mining"] = true
		end
	end
	local back = M.back and GetTime() < (M.backUntil or 0)
	if out > 0 then
		local first, second
		for _, activity in ipairs(ACTIVITIES) do
			if skills[activity] then
				if not first then first = activity elseif not second then second = activity end
			end
		end
		local both = second ~= nil
		b.icon:SetTexture(UI.SKILL_ICON[first or "mining"])
		b.icon2:SetTexture(UI.SKILL_ICON[second or first or "mining"])
		b.icon2:SetWidth(both and 16 or 0.1)
		b.icon2:SetAlpha(both and 1 or 0)
		b.text:SetText(string.format(T("BAR_OUT"), out, soonest))
		b.text:SetTextColor(1, 0.6, 0.1)
	elseif back then
		b.icon:SetTexture("Interface\\Icons\\INV_Letter_15")
		b.icon2:SetWidth(0.1)
		b.icon2:SetAlpha(0)
		b.text:SetText(string.format(T("BAR_BACK"), M.back))
		b.text:SetTextColor(0.4, 0.75, 1)
	else
		b:Hide()
		return
	end
	b:SetWidth(b.text:GetStringWidth() + 26 + b.icon2:GetWidth())
	-- Its right edge on the last button's, not on the bar's (a little wider).
	b:ClearAllPoints()
	b:SetPoint("BOTTOMRIGHT", bar.last or bar, "TOPRIGHT", 0, 4)
	b:Show()
end

-- For My alts: a gold word on the alts out on a mission.
function SquidBotsLite_MissionOf(name)
	return M.OnMission(name) and M.status[name] or nil
end

-- Next to My alts, never over it: on its left (the bot sheet opens on its right), else under it. Once the player
-- has moved the panel, it stays where they put it.
function M.Place()
	local f, alts = M.panel, _G.SquidBotsLiteAlts
	if f.moved then return end
	f:ClearAllPoints()
	if not (alts and alts:IsShown() and alts:GetLeft()) then
		f:SetPoint("CENTER", -200, 40)
		return
	end
	local scale = alts:GetEffectiveScale() / f:GetEffectiveScale()
	if alts:GetLeft() * scale >= f:GetWidth() + 8 then
		f:SetPoint("TOPRIGHT", alts, "TOPLEFT", -4, 0)
	else
		f:SetPoint("TOPLEFT", alts, "BOTTOMLEFT", 0, -4)
	end
end

function SquidBotsLite_ShowMissions()
	if not M.panel then M.Build() end
	if M.panel:IsShown() then M.panel:Hide() return end
	M.Place()
	M.panel:Show()
	M.panel:Raise()
	if SquidBotsLite_AskRoster then SquidBotsLite_AskRoster() end
	M.Poll()
	M.RefreshPanel()
end

-- The My alts roster came back: the panel shows the alts logged in now.
function SquidBotsLite_MissionsRoster()
	if M.panel and M.panel:IsShown() then
		M.Refresh()
		M.RefreshPanel()
	end
end

-- ---------------------------------------------------------------------------
-- Events, polls, and what stays out of the chat
-- ---------------------------------------------------------------------------
local function IsAlt(name)
	return name and SquidBotsLiteDB and SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[name]
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(_, _, message, name)
	if (message:find("^MISSION;") or message:find("^MISSIONCAN;") or message:find("^Watch on: ")) and IsAlt(name) then return true end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_, _, message, name)
	if (message == "mission status" or message == "mission can" or message == "mission watch" or message == "mission unwatch")
		and IsAlt(name) then return true end
end)
-- A poll to an alt that logged out meanwhile: "No player named 'X' is currently playing."
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
	local name = message:match("^No player named '(.-)' is currently playing%.$")
	if name and M.polled[name] and GetTime() - M.polled[name] < OFFLINE_WAIT then return true end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:RegisterEvent("UPDATE_PENDING_MAIL")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, message, name)
	if event == "CHAT_MSG_WHISPER" then
		if not IsAlt(name) then return end
		if message:find("^MISSIONCAN;") then
			M.OnCan(name, message)
		elseif message:find("^MISSION;") then
			M.OnStatus(name, message)
		elseif message:find("^Mission ") then
			M.OnLine(name, message)
		elseif message:find("^Watch ") then
			M.OnWatch(name, message)
		elseif message:find("^Order refused: ") then
			local reason = (message:match("^Order refused: (.-)%.?$") or "")
			if UIErrorsFrame then UIErrorsFrame:AddMessage(string.format(T("ORDER_REFUSED"), name, reason), 1, 0.4, 0.3) end
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local gone = message:match("^No player named '(.-)' is currently playing%.$")
		if gone and M.status[gone] then
			M.status[gone] = nil
			M.RefreshPanel()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		if next(SquidBotsLiteDB.missionOut or {}) and not M.asked then
			M.asked = true
			M.loginPoll, M.nextPoll = true, GetTime() + 5
		end
	elseif event == "UPDATE_PENDING_MAIL" and HasNewMail() then
		for alt, count in pairs(M.mail) do
			Print(string.format(T("MAIL"), alt, count))
			if UIErrorsFrame then UIErrorsFrame:AddMessage(string.format(T("MAIL"), alt, count), 0.4, 0.8, 1) end
			PlaySound("TellMessage")
		end
		M.mail = {}
	end
end)

local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
	elapsed = elapsed + delta
	if elapsed < 0.5 then return end
	elapsed = 0
	local now = GetTime()
	-- Polls go out one a second.
	if #M.queue > 0 and now >= M.nextSend then
		local poll = table.remove(M.queue, 1)
		Whisper(poll[1], poll[2])
		M.nextSend = now + POLL_GAP
	end
	-- Every minute, while an alt is out or the panel is open.
	if now >= M.nextPoll and (M.Count() > 0 or M.loginPoll or (M.panel and M.panel:IsShown()) or (M.watcher and M.watcher())) then
		M.loginPoll = nil
		M.Poll()
	end
	-- The "back" word goes after two minutes.
	if M.back and now >= (M.backUntil or 0) then
		M.back = nil
		M.RefreshBadge()
	end
end)
