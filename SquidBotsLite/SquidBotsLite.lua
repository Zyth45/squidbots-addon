-- SquidBots Lite: the minimal take. No window: a thin bar of orders (a Release button joins it while
-- a bot lies dead) and "Bots" to recruit, the bots' roles and alerts drawn on the game's own party
-- frames, and the offers bots whisper as small toasts above the bar, each with an Invite button.

SquidBotsLiteDB = SquidBotsLiteDB or {}

local STRINGS = {
	en = {
		FOLLOW = "Follow", STAY = "Stay", ATTACK = "Target", PASSIVE = "Passive", ACTIVE = "Active", DUNGEON = "Dungeon", RECRUIT = "Bots",
		TIP_FOLLOW = "Bots follow you.", TIP_STAY = "Bots stay where they are.", TIP_ATTACK = "Bots attack your target.",
		TIP_ACTIVE = "Bots fight normally. Click to make them passive: no fights, and the tank stops pulling on its own.",
		TIP_PASSIVE = "Bots are passive: no fights, no auto pull. Click, or give any order, to wake them.",
		TOGGLE_PASSIVE = "Passive / Active",
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
		RAID_10 = "Raid of 10 bots", RAID_25 = "Raid of 25 bots", REGEAR = "Regear level 60+ bots (GM)",
		ALTS = "My alts", ALTS_REFRESH = "Refresh", ALTS_ADD = "Log in", ALTS_REMOVE = "Log out", ALTS_SUMMON = "Summon",
		ALTS_WAIT = "Asking the server...", ALTS_EMPTY = "No other character on this account.",
		ALTS_NO_REPLY = "No answer from the server: does it run the bot module?", ALTS_MORE = "%d more not shown.",
		ALTS_HELP = "Your other characters, played as bots: a logged-in alt joins your group. They keep their look (wardrobe, mounts) if the server has CoA.CollectionsForBots = 1.",
		INVITE = "Invite", ASKED = "Asked in %s: %s", NO_CHANNEL = "Join the Zone or Newcomers channel first (or /sbl channel <name>).",
		NOT_IN_GROUP = "You are not in a group with bots.",
		LOW_MANA = "Low mana", PULLING = "Pulling", REZ = "Rez",
		M_FOLLOW = "Follow me", M_STAY = "Stay here", M_ATTACK = "Attack my target", M_SUMMON = "Come to me",
		M_AUTOPULL_ON = "Auto pull on", M_AUTOPULL_OFF = "Auto pull off", M_KICK = "Remove from group",
		M_STATS = "Stats (bags, money, xp)", M_GEAR = "Best gear", M_HEAL_ME = "Heal only me", M_HEAL_ALL = "Heal the whole group",
		SUMMON = "Regroup", TIP_SUMMON = "Bots teleport next to you. Handy when one is stuck.",
		RELEASE = "Release", TIP_RELEASE = "Shown when a bot is dead: dead bots release their spirit and run back to their body.",
		ROLE_ORDERS = "Orders by role", R_TANK_ATTACK = "Tank: attack my target", R_DPS_ATTACK = "Damage: attack my target",
		R_HEAL_FOLLOW = "Healers: follow me", R_HEAL_STAY = "Healers: stay here", R_MELEE_FLEE = "Melee: back to me, hold fire",
		FORMATION = "Formation", F_NEAR = "Close (default)", F_LINE = "Line", F_CIRCLE = "Circle", F_SHIELD = "Shield around me",
		F_ARROW = "Arrow", F_QUEUE = "Single file",
		ROLES_ON = "Automatic roles on: a bot of unknown role is asked \"co ?\" once, answer hidden.",
		ROLES_OFF = "Automatic roles off.",
		SPECS = "Specializations", SPEC_MENU = "Specialization", SPEC_OPEN = "All the group's specializations...",
		MY_ROLE = "My role:", ROLE_TANK = "Tank", ROLE_HEAL = "Healer", ROLE_DPS = "Damage", SUPPORT = "support",
		SPEC_PICK = "Spec", SPECS_REFRESH = "Refresh", BALANCE = "Balance the group",
		TIP_BALANCE = "One tank and one healer, your own role counted, everyone else damage. A bot that already plays the role it gets keeps its specialization.",
		SPECS_WAIT = "asking...", SPEC_UNKNOWN = "?", SPECS_NONE = "No bot in your group.", SPECS_NO_REPLY = "no answer",
		SPECS_HELP = "Click a role to switch a bot to it (the specialization it last played in that role), or Spec to choose one. Rotation and position follow. An alt keeps your choice, with the talents you gave it for that specialization.",
		TIP_BOT_ICON = "Click: orders and specialization.", SPEC_ALT_NOTE = "Your alt keeps it, with the talents you gave it.",
		SPEC_NOW = "%s is now %s (%s).", SPEC_NO_ROLE = "%s has no specialization for the %s role.",
		BALANCE_DONE = "Group: %s.", BALANCE_MISSING = "No bot in the group can play %s.",
		BALANCE_WAIT = "Asking the bots for their specializations...", BALANCE_RAID = "In a raid, the raid command already sets the roles: pick specializations bot by bot.",
		SPECS_NOT_BOT = "not a bot", SPEC_ASK = "Ask the bot", TIP_ROLE = "Switch to %s.", TIP_NO_ROLE = "No specialization of this role.",
		HELP = "SquidBots Lite: /sbl (show/hide), /sbl lang fr|en, /sbl channel <name>, /sbl alts, /sbl spec, /sbl roles on|off, /sbl gm (GM only), /sbl reset. Key bindings: Esc > Key Bindings > SquidBots Lite.",
		LANG_SET = "SquidBots Lite language: English.", CHANNEL_SET = "SquidBots Lite asks in: %s",
	},
	fr = {
		FOLLOW = "Suivre", STAY = "Rester", ATTACK = "Cible", PASSIVE = "Passif", ACTIVE = "Actif", DUNGEON = "Donjon", RECRUIT = "Bots",
		TIP_FOLLOW = "Les bots vous suivent.", TIP_STAY = "Les bots restent sur place.", TIP_ATTACK = "Les bots attaquent votre cible.",
		TIP_ACTIVE = "Les bots combattent normalement. Cliquez pour les rendre passifs : plus de combat, et le tank arrête de tirer seul.",
		TIP_PASSIVE = "Les bots sont passifs : pas de combat, pas de pull auto. Cliquez, ou donnez n'importe quel ordre, pour les réveiller.",
		TOGGLE_PASSIVE = "Passif / Actif",
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
		RAID_10 = "Raid de 10 bots", RAID_25 = "Raid de 25 bots", REGEAR = "Rééquiper les bots 60+ (MJ)",
		ALTS = "Mes alts", ALTS_REFRESH = "Actualiser", ALTS_ADD = "Connecter", ALTS_REMOVE = "Déconnecter", ALTS_SUMMON = "Appeler",
		ALTS_WAIT = "Demande au serveur...", ALTS_EMPTY = "Aucun autre personnage sur ce compte.",
		ALTS_NO_REPLY = "Pas de réponse du serveur : a-t-il le module des bots ?", ALTS_MORE = "%d de plus, non affichés.",
		ALTS_HELP = "Vos autres personnages, joués en bots : un alt connecté rejoint votre groupe. Ils gardent leur apparence (garde-robe, montures) si le serveur a CoA.CollectionsForBots = 1.",
		INVITE = "Inviter", ASKED = "Demandé dans %s : %s", NO_CHANNEL = "Rejoignez le channel Zone ou Newcomers (ou /sbl channel <nom>).",
		NOT_IN_GROUP = "Vous n'êtes pas en groupe avec des bots.",
		LOW_MANA = "Mana bas", PULLING = "Pull", REZ = "Rez",
		M_FOLLOW = "Me suivre", M_STAY = "Rester ici", M_ATTACK = "Attaquer ma cible", M_SUMMON = "Venir à moi",
		M_AUTOPULL_ON = "Auto pull activé", M_AUTOPULL_OFF = "Auto pull désactivé", M_KICK = "Retirer du groupe",
		M_STATS = "Stats (sacs, argent, xp)", M_GEAR = "Meilleur équipement", M_HEAL_ME = "Ne soigner que moi", M_HEAL_ALL = "Soigner tout le groupe",
		SUMMON = "Rappel", TIP_SUMMON = "Les bots se téléportent près de vous. Pratique quand l'un d'eux est coincé.",
		RELEASE = "Libérer", TIP_RELEASE = "Visible quand un bot est mort : les bots morts libèrent leur esprit et rejoignent leur corps.",
		ROLE_ORDERS = "Ordres par rôle", R_TANK_ATTACK = "Tank : attaquer ma cible", R_DPS_ATTACK = "DPS : attaquer ma cible",
		R_HEAL_FOLLOW = "Soigneurs : me suivre", R_HEAL_STAY = "Soigneurs : rester ici", R_MELEE_FLEE = "Corps à corps : revenir sans attaquer",
		FORMATION = "Formation", F_NEAR = "Proche (par défaut)", F_LINE = "Ligne", F_CIRCLE = "Cercle", F_SHIELD = "Bouclier autour de moi",
		F_ARROW = "Flèche", F_QUEUE = "File indienne",
		ROLES_ON = "Rôles automatiques activés : un bot au rôle inconnu reçoit « co ? » une fois, réponse masquée.",
		ROLES_OFF = "Rôles automatiques désactivés.",
		SPECS = "Spécialisations", SPEC_MENU = "Spécialisation", SPEC_OPEN = "Toutes les spécialisations du groupe...",
		MY_ROLE = "Mon rôle :", ROLE_TANK = "Tank", ROLE_HEAL = "Soigneur", ROLE_DPS = "DPS", SUPPORT = "soutien",
		SPEC_PICK = "Spé", SPECS_REFRESH = "Actualiser", BALANCE = "Équilibrer le groupe",
		TIP_BALANCE = "Un tank et un soigneur, votre propre rôle compris, tous les autres en DPS. Un bot qui joue déjà le rôle qu'il reçoit garde sa spécialisation.",
		SPECS_WAIT = "demande...", SPEC_UNKNOWN = "?", SPECS_NONE = "Aucun bot dans votre groupe.", SPECS_NO_REPLY = "pas de réponse",
		SPECS_HELP = "Cliquez sur un rôle pour y passer un bot (la spécialisation qu'il a jouée en dernier dans ce rôle), ou sur Spé pour en choisir une. Rotation et placement suivent. Un alt garde votre choix, avec les talents que vous lui avez mis dans cette spécialisation.",
		TIP_BOT_ICON = "Clic : ordres et spécialisation.", SPEC_ALT_NOTE = "Votre alt la garde, avec les talents que vous lui avez mis.",
		SPEC_NOW = "%s joue maintenant %s (%s).", SPEC_NO_ROLE = "%s n'a aucune spécialisation de %s.",
		BALANCE_DONE = "Groupe : %s.", BALANCE_MISSING = "Aucun bot du groupe ne peut jouer %s.",
		BALANCE_WAIT = "Demande de leurs spécialisations aux bots...", BALANCE_RAID = "En raid, la commande de raid répartit déjà les rôles : choisissez les spécialisations bot par bot.",
		SPECS_NOT_BOT = "pas un bot", SPEC_ASK = "Demander au bot", TIP_ROLE = "Passer en %s.", TIP_NO_ROLE = "Aucune spécialisation de ce rôle.",
		HELP = "SquidBots Lite : /sbl (afficher/cacher), /sbl lang fr|en, /sbl channel <nom>, /sbl alts, /sbl spec, /sbl roles on|off, /sbl gm (MJ), /sbl reset. Raccourcis : Échap > Raccourcis > SquidBots Lite.",
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
local OFFER_SECONDS = 120
local MAX_TOASTS = 5
-- Captions in a smaller font than the game's small text, and buttons spaced by the widest caption of the
-- current language (measured in game): English "Dungeon" needs more room than French "Donjon".
local CAPTION_SIZE, CAPTION_GAP, MIN_STEP, FALLBACK_STEP = 8, 4, 38, 52
local BAR_ORDER = { "follow", "stay", "attack", "passive", "dungeon", "summon", "recruit", "release" }
-- A member of unknown role is asked "co ?" this long after it shows up (a lfg recruit announces
-- its role on its own first), and the "Strategies: ..." answer is hidden for PROBE_WINDOW seconds.
local PROBE_DELAY, PROBE_WINDOW = 3, 10
local FORMATIONS = { { "near", "F_NEAR" }, { "line", "F_LINE" }, { "circle", "F_CIRCLE" }, { "shield", "F_SHIELD" },
	{ "arrow", "F_ARROW" }, { "queue", "F_QUEUE" } }
-- The Passive button shows the bots' current state: a charge arrow while they fight, Zzz while passive.
local ICON_ACTIVE, ICON_PASSIVE = "Interface\\Icons\\Ability_Warrior_Charge", "Interface\\Icons\\Spell_Nature_Sleep"
-- The panels: a dark plain background under the dialog border, since the dialog background let the floating
-- names of the world show through. The role buttons use square icons, like the bar.
local PANEL_BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
local ROLE_BUTTON_ICONS = { tank = "Interface\\Icons\\Ability_Defend", heal = "Interface\\Icons\\Spell_Holy_FlashHeal",
	dps = "Interface\\Icons\\Ability_MeleeDamage" }
local BINDINGS = { { "follow", "FOLLOW" }, { "stay", "STAY" }, { "attack", "M_ATTACK" }, { "passive", "TOGGLE_PASSIVE" },
	{ "dungeon", "DUNGEON" }, { "summon", "SUMMON" }, { "release", "RELEASE" } }

local roleByName, badges, toasts = {}, {}, {}
local firstSeen, probedAt = {}, {}
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
	-- Names shown in the game's Key Bindings window (the bindings themselves are in Bindings.xml).
	BINDING_HEADER_SQUIDBOTSLITE = "SquidBots Lite"
	for _, binding in ipairs(BINDINGS) do
		_G["BINDING_NAME_SQUIDBOTSLITE_" .. string.upper(binding[1])] = L[binding[2]]
	end
	BINDING_NAME_SQUIDBOTSLITE_SPECS = L.SPECS
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

local ShowAlts, ShowSpecs
local function RecruitMenu()
	local items = {
		{ text = L.RECRUIT, isTitle = true, notCheckable = true },
		{ text = L.ASK_TANK, notCheckable = true, func = function() Ask("tank") end },
		{ text = L.ASK_HEAL, notCheckable = true, func = function() Ask("heal") end },
		{ text = L.ASK_DPS, notCheckable = true, func = function() Ask("dps") end },
		{ text = L.ASK_ALL, notCheckable = true, func = function() Ask("tank heal dps") end },
		-- The server answers with a system message: raid built, or how long to wait (players: 30 min).
		{ text = L.RAID_10, notCheckable = true, func = function() SendChatMessage(".playerbots coa raid 10", "SAY") end },
		{ text = L.RAID_25, notCheckable = true, func = function() SendChatMessage(".playerbots coa raid 25", "SAY") end },
		{ text = L.ALTS, notCheckable = true, func = function() ShowAlts() end },
		{ text = L.SPECS, notCheckable = true, func = function() ShowSpecs() end },
		{ text = L.GEAR, notCheckable = true, func = function() SendGroup("autogear") end },
		{ text = L.REPAIR, notCheckable = true, func = function() SendGroup("repair") end },
	}
	if SquidBotsLiteDB.gm then
		table.insert(items, { text = L.REGEAR, notCheckable = true, func = function() SendChatMessage(".playerbots coa regear", "SAY") end })
	end
	return items
end

-- Set by the bar and by the menus alike, so the lit button always matches the last order sent.
local Highlight
local function SetOrder(order)
	state.order = order
	Highlight()
end

-- "co +passive" only holds the combat engine, while the tank's auto pull runs out of combat: a passive
-- tank would still pull, then stand there. So passive also stops its auto pull, and waking restores it
-- (it is on by default for a CoA tank).
local function SetPassive(on)
	if on then
		return SendGroup("co +passive", "@tank nc -coa auto pull")
	end
	return SendGroup("co -passive", "@tank nc +coa auto pull")
end

-- For every group order: follow, stay and tank attack already end "passive" on the bots, and "attack"
-- is ignored by a passive bot. So any order wakes the bots first, and the Passive button follows.
local function SendOrder(...)
	if state.passive then
		if not SetPassive(false) then return false end
		state.passive = false
		Highlight()
	end
	return SendGroup(...)
end

local function ProfileMenu()
	local roleOrders = {
		{ text = L.R_TANK_ATTACK, notCheckable = true, func = function() SendOrder("@tank attack") end },
		{ text = L.R_DPS_ATTACK, notCheckable = true, func = function() SendOrder("@dps attack") end },
		{ text = L.R_HEAL_FOLLOW, notCheckable = true, func = function() SendOrder("@heal follow") end },
		{ text = L.R_HEAL_STAY, notCheckable = true, func = function() SendOrder("@heal stay") end },
		{ text = L.R_MELEE_FLEE, notCheckable = true, func = function() SendGroup("@melee flee") end },
	}
	local formations = {}
	for _, f in ipairs(FORMATIONS) do
		table.insert(formations, { text = L[f[2]], notCheckable = true, func = function() SendGroup("formation " .. f[1]) end })
	end
	return {
		{ text = L.PROFILES, isTitle = true, notCheckable = true },
		{ text = L.P_FARM, notCheckable = true, func = function() SendGroup("nc +grind,+loot,+food") end },
		{ text = L.P_STRICT, notCheckable = true, func = function()
			if SendOrder("nc +follow,-grind,-rpg,-move random", "follow") then SetOrder("follow") end
		end },
		{ text = L.P_DUNGEON, notCheckable = true, func = function()
			if SendOrder("co -wait for attack,+avoid aoe", "follow") then SetOrder("dungeon") end
		end },
		{ text = L.P_LEAVE_DUNGEON, notCheckable = true, func = function()
			if SendGroup("co -wait for attack,-avoid aoe,-mark rti") and state.order == "dungeon" then SetOrder("follow") end
		end },
		{ text = L.ROLE_ORDERS, hasArrow = true, notCheckable = true, menuList = roleOrders },
		{ text = L.FORMATION, hasArrow = true, notCheckable = true, menuList = formations },
		{ text = L.GEAR, notCheckable = true, func = function() SendGroup("autogear") end },
		{ text = L.REPAIR, notCheckable = true, func = function() SendGroup("repair") end },
	}
end

-- ---------------------------------------------------------------------------
-- Specializations: a bot's specialization (its role, rotation, talents and position follow), one by one or
-- the whole group balanced in a click
-- ---------------------------------------------------------------------------
-- "talents spec list" answers one line per specialization of the bot's class, "> " before the active one:
-- "> Houndmaster - damage, ranged", "  Black Knight - tank, close", ", support" after a damage dealer that
-- carries the group. "talents spec <name>" answers "Now Houndmaster - damage, ranged, running ...". Both work
-- on a player's own bots (alts, recruits, class bots) without any GM right, and an alt keeps the choice: the
-- server never overrides it. The lists come from the bots, so every class and the specs of a later release
-- show up without a table here.
-- Only members known to be bots are asked anything: one that answered like a bot ("co ?", a lfg offer, a
-- "joins as" line, a list) or carries the "Bot" surname. A WotLK class (an alt of an old class) has no CoA
-- specialization and is left alone. Nothing is switched blind: a role waits for the bot's list.
local SPEC_WAIT, SPEC_HIDE, SPEC_REASK, REAPPLY_AFTER = 5, 8, 30, 1.5   -- seconds
local ROLE_WORDS = { tank = "tank", healer = "heal", damage = "dps" }
local ROLE_KEYS = { tank = "ROLE_TANK", heal = "ROLE_HEAL", dps = "ROLE_DPS" }
local ROLES = { "tank", "heal", "dps" }
local WOTLK_TOKENS = { WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true, PRIEST = true, DEATHKNIGHT = true,
	SHAMAN = true, MAGE = true, WARLOCK = true, DRUID = true }
-- Set aside by the server (CoaExcludedSpecializations): nothing in the core lets Bloodmage Eternal tank.
local EXCLUDED_SPECS = { Eternal = true }
-- Orders the addon sends to one bot after a switch (the server resets its strategies), kept out of the chat.
local REAPPLY_ORDERS = { ["co +passive"] = true, ["nc -coa auto pull"] = true, ["co -wait for attack,+avoid aoe"] = true, stay = true }
local SPEC_ROWS = 4
local knownBot = {}
local specsByName, specAskedAt, specHideUntil, pendingRole, reapplyAt, specAskedOnce, specSilent = {}, {}, {}, {}, {}, {}, {}
local specsFrame, specRows = nil, {}
local balancePending

-- A party member's unit id, or nil.
local function UnitOf(name)
	for i = 1, 4 do
		if UnitName("party" .. i) == name then return "party" .. i end
	end
end

local function IsCoaBot(name)
	local unit = UnitOf(name)
	if unit then
		local _, token = UnitClass(unit)
		if token and WOTLK_TOKENS[token] then return false end
	end
	return knownBot[name] or name:find(" Bot$") ~= nil
end

-- True when the question went out: a member not known as a bot yet is asked once it is (TickSpecs).
local function AskSpecs(name)
	if not IsCoaBot(name) then return false end
	specAskedAt[name] = GetTime()
	specAskedOnce[name] = GetTime()
	specSilent[name] = nil
	specHideUntil[name] = GetTime() + SPEC_HIDE
	Whisper(name, "talents spec list")
	return true
end

local function SpecOf(name, specName)
	local info = specsByName[name]
	if not info or not specName then return end
	for _, spec in ipairs(info.list) do
		if spec.name == specName then return spec end
	end
end

local function CurrentRole(name)
	local info = specsByName[name]
	local spec = info and SpecOf(name, info.current)
	return spec and spec.role or roleByName[name]
end

-- The specializations of a role a bot can play, the ones set aside by the server left out.
local function SpecsForRole(name, role)
	local found = {}
	local info = specsByName[name]
	if info then
		for _, spec in ipairs(info.list) do
			if spec.role == role and not EXCLUDED_SPECS[spec.name] then table.insert(found, spec) end
		end
	end
	return found
end

-- The specialization a bot last played in each role, kept between sessions: switching a tank back to damage
-- gives it its own damage specialization again, not the first of the list.
local function Remember(name, specName, role)
	SquidBotsLiteDB.lastSpec = SquidBotsLiteDB.lastSpec or {}
	SquidBotsLiteDB.lastSpec[name] = SquidBotsLiteDB.lastSpec[name] or {}
	SquidBotsLiteDB.lastSpec[name][role] = specName
end

-- The switch shows at once: the server drops an answer identical to one it sent less than 2 s before, so a
-- quick Tank > Damage > Tank would never hear the last "Now ...".
local function PickSpec(name, specName)
	local spec = SpecOf(name, specName)
	if not spec then return end
	specsByName[name].current = specName
	roleByName[name] = spec.role
	Remember(name, specName, spec.role)
	specHideUntil[name] = GetTime() + SPEC_HIDE
	reapplyAt[name] = GetTime() + REAPPLY_AFTER
	Whisper(name, "talents spec " .. specName)
end

-- A role: nothing if the bot already plays it, else the specialization it last played in that role, else
-- its first one. Without its list yet, the bot is asked and the role waits for the answer.
local function PickRole(name, role)
	if not specsByName[name] then
		pendingRole[name] = role
		AskSpecs(name)
		return
	end
	if CurrentRole(name) == role then return end
	local specs = SpecsForRole(name, role)
	local last = SquidBotsLiteDB.lastSpec and SquidBotsLiteDB.lastSpec[name] and SquidBotsLiteDB.lastSpec[name][role]
	for _, spec in ipairs(specs) do
		if spec.name == last then
			PickSpec(name, last)
			return
		end
	end
	if specs[1] then
		PickSpec(name, specs[1].name)
	else
		Print(string.format(L.SPEC_NO_ROLE, name, L[ROLE_KEYS[role]]))
	end
end

-- The server resets a bot's strategies on a switch: the bar's state is given back to that bot.
local function Reapply(name)
	specHideUntil[name] = GetTime() + SPEC_HIDE
	if state.passive then
		Whisper(name, "co +passive")
		if CurrentRole(name) == "tank" then Whisper(name, "nc -coa auto pull") end
	end
	if state.order == "dungeon" then
		Whisper(name, "co -wait for attack,+avoid aoe")
	elseif state.order == "stay" then
		Whisper(name, "stay")
	end
end

local function PartyNames()
	local names = {}
	for i = 1, 4 do
		local name = UnitName("party" .. i)
		if name and name ~= UNKNOWNOBJECT then table.insert(names, name) end
	end
	return names
end

-- One tank and one healer (the player's own role and the known role of members without a list counted),
-- everyone else damage. A role goes first to a bot that already plays it, then to the bot with the fewest
-- other key roles to offer, so that the only bot able to heal is not made the tank. Members without a list
-- (humans, silent bots) are never switched. In a raid the server's raid command sets the roles.
local function BalanceGroup()
	if GetNumRaidMembers() > 0 then
		Print(L.BALANCE_RAID)
		return
	end
	local members = PartyNames()
	if #members == 0 then
		Print(L.SPECS_NONE)
		return
	end
	if not balancePending then
		local asked = false
		for _, name in ipairs(members) do
			if not specsByName[name] and IsCoaBot(name) then
				asked = true
				AskSpecs(name)
			end
		end
		if asked then
			balancePending = GetTime()
			Print(L.BALANCE_WAIT)
			return
		end
	end
	balancePending = nil
	local bots, filled = {}, { [SquidBotsLiteDB.myRole or "dps"] = true }
	for _, name in ipairs(members) do
		if specsByName[name] then
			table.insert(bots, name)
		elseif roleByName[name] then
			filled[roleByName[name]] = true
		end
	end
	local assigned = {}
	for _, role in ipairs({ "tank", "heal" }) do
		if not filled[role] then
			local best, bestScore
			for _, name in ipairs(bots) do
				if not assigned[name] and #SpecsForRole(name, role) > 0 then
					local current = CurrentRole(name)
					local score = current == role and -10 or 0
					for _, other in ipairs({ "tank", "heal" }) do
						if other ~= role then
							if #SpecsForRole(name, other) > 0 then score = score + 1 end
							if current == other then score = score + 5 end
						end
					end
					if not bestScore or score < bestScore then best, bestScore = name, score end
				end
			end
			if best then
				assigned[best] = role
			else
				Print(string.format(L.BALANCE_MISSING, L[ROLE_KEYS[role]]))
			end
		end
	end
	local parts = {}
	for _, name in ipairs(bots) do
		local role = assigned[name] or "dps"
		PickRole(name, role)
		table.insert(parts, name .. " " .. L[ROLE_KEYS[role]])
	end
	if #parts > 0 then Print(string.format(L.BALANCE_DONE, table.concat(parts, ", "))) end
end

-- The parsed list of a "talents spec list" answer, or nil when the message is not one: every line must read
-- "[>] Name - role, position[, support]".
local function ParseSpecList(message)
	local list, current = {}, nil
	for line in (message .. "\n"):gmatch("([^\n]*)\n") do
		if strtrim(line) ~= "" then
			local mark, name, roleWord, rest = line:match("^%s*(>?)%s*(.-)%s+%-%s+(%a+),%s*%a+(.*)$")
			if not name or not ROLE_WORDS[roleWord] or name == "" then return end
			table.insert(list, { name = name, role = ROLE_WORDS[roleWord], support = rest:find("support", 1, true) ~= nil })
			if mark == ">" then current = name end
		end
	end
	if #list > 0 then return list, current end
end

local function ParseNow(message)
	local picked, word = message:match("^Now (.-) %- (%a+),")
	if picked and ROLE_WORDS[word] then return picked, ROLE_WORDS[word] end
end

-- An answer of a bot about its specializations: true when it was one.
local function OnSpecReply(message, sender)
	local picked, role = ParseNow(message)
	if picked then
		knownBot[sender] = true
		local info = specsByName[sender]
		if info then info.current = picked end
		roleByName[sender] = role
		Remember(sender, picked, role)
		Print(string.format(L.SPEC_NOW, sender, picked, L[ROLE_KEYS[role]]))
		return true
	end
	if not specAskedAt[sender] then return false end
	local list, current = ParseSpecList(message)
	if not list then return false end
	knownBot[sender] = true
	specAskedAt[sender] = nil
	specsByName[sender] = { list = list, current = current }
	local active = SpecOf(sender, current)
	if active then
		roleByName[sender] = active.role
		Remember(sender, active.name, active.role)
	end
	if pendingRole[sender] then
		local wanted = pendingRole[sender]
		pendingRole[sender] = nil
		PickRole(sender, wanted)
	end
	return true
end

-- Only the addon's own questions and orders, and the exact answers, stay out of the chat, for a few seconds
-- after it asked; an error ("I have no specialization called ...", "I cannot switch to ...") still shows.
local function HideSpecChat(_, event, message, name)
	local untilTime = specHideUntil[name]
	if not untilTime or GetTime() > untilTime then return end
	if event == "CHAT_MSG_WHISPER_INFORM" then
		return message:find("^talents spec ") ~= nil or REAPPLY_ORDERS[message] ~= nil
	end
	return ParseNow(message) ~= nil or ParseSpecList(message) ~= nil
end
-- A bot answers on the channel of the last order it got within a second, so the group channels too.
for _, e in ipairs({ "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER" }) do
	ChatFrame_AddMessageEventFilter(e, HideSpecChat)
end

local function SpecMenu(name)
	local items = { { text = L.SPEC_MENU, isTitle = true, notCheckable = true } }
	local info = specsByName[name]
	if info then
		for _, role in ipairs(ROLES) do
			table.insert(items, { text = L[ROLE_KEYS[role]], disabled = #SpecsForRole(name, role) == 0,
				checked = CurrentRole(name) == role, func = function() PickRole(name, role) end })
		end
		table.insert(items, { text = name, isTitle = true, notCheckable = true })
		if SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[name] then
			table.insert(items, { text = "|cffaaaaaa" .. L.SPEC_ALT_NOTE .. "|r", notCheckable = true, disabled = true })
		end
		for _, spec in ipairs(info.list) do
			local label = spec.name .. " |cffaaaaaa(" .. L[ROLE_KEYS[spec.role]] .. (spec.support and ", " .. L.SUPPORT or "") .. ")|r"
			table.insert(items, { text = label, checked = spec.name == info.current, disabled = EXCLUDED_SPECS[spec.name],
				func = function() PickSpec(name, spec.name) end })
		end
	elseif IsCoaBot(name) then
		table.insert(items, { text = specAskedAt[name] and L.SPECS_WAIT or L.SPEC_ASK, notCheckable = true,
			disabled = specAskedAt[name] ~= nil, func = function() AskSpecs(name) end })
	else
		table.insert(items, { text = L.SPECS_NOT_BOT, notCheckable = true, disabled = true })
	end
	table.insert(items, { text = L.SPEC_OPEN, notCheckable = true, func = function() ShowSpecs() end })
	return items
end

local function RefreshSpecs()
	if not specsFrame or not specsFrame:IsShown() then return end
	local members = PartyNames()
	for i, row in ipairs(specRows) do
		local name = members[i]
		row.botName = name
		if name then
			local info = specsByName[name]
			local spec = info and SpecOf(name, info.current)
			row.name:SetText(name)
			SetRoleIcon(row.role, CurrentRole(name))
			if spec then
				row.spec:SetText(spec.name)
			elseif specAskedAt[name] then
				row.spec:SetText(L.SPECS_WAIT)
			elseif not IsCoaBot(name) then
				row.spec:SetText(L.SPECS_NOT_BOT)
			else
				row.spec:SetText((not info and specSilent[name]) and L.SPECS_NO_REPLY or L.SPEC_UNKNOWN)
			end
			for _, role in ipairs(ROLES) do
				local button = row[role]
				button.can = info ~= nil and #SpecsForRole(name, role) > 0
				button.icon:SetDesaturated(not button.can)
				button:SetAlpha(button.can and 1 or 0.35)
				if button.can and CurrentRole(name) == role then button.ring:Show() else button.ring:Hide() end
			end
			row:Show()
		else
			row:Hide()
		end
	end
	for role, button in pairs(specsFrame.myRole) do
		local mine = (SquidBotsLiteDB.myRole or "dps") == role
		button:SetAlpha(mine and 1 or 0.6)
		if mine then button.ring:Show() else button.ring:Hide() end
	end
	-- As tall as the rows shown: no empty space under one or two bots.
	local shown = math.max(1, math.min(#members, SPEC_ROWS))
	if specsFrame.rowsShown ~= shown then
		specsFrame.rowsShown = shown
		specsFrame:SetHeight(176 + shown * 26)
		specsFrame.balance:ClearAllPoints()
		specsFrame.balance:SetPoint("TOPLEFT", 16, -74 - shown * 26)
	end
	specsFrame.status:SetText(#members == 0 and L.SPECS_NONE or (balancePending and L.SPECS_WAIT) or "")
end

local function SpecsTexts()
	if not specsFrame then return end
	specsFrame.title:SetText("SquidBots Lite - " .. L.SPECS)
	specsFrame.myRoleLabel:SetText(L.MY_ROLE)
	specsFrame.balance:SetText(L.BALANCE)
	specsFrame.refresh:SetText(L.SPECS_REFRESH)
	specsFrame.help:SetText(L.SPECS_HELP)
	for _, row in ipairs(specRows) do
		row.pick:SetText(L.SPEC_PICK)
	end
end

-- A small square button showing a role icon, with a tooltip.
local function RoleButton(parent, role, size, tipFunc, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(size)
	button:SetHeight(size)
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetAllPoints()
	button.icon:SetTexture(ROLE_BUTTON_ICONS[role])
	button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.ring = button:CreateTexture(nil, "OVERLAY")
	button.ring:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	button.ring:SetBlendMode("ADD")
	button.ring:SetWidth(size * 1.8)
	button.ring:SetHeight(size * 1.8)
	button.ring:SetPoint("CENTER")
	button.ring:SetVertexColor(1, 0.82, 0)
	button.ring:Hide()
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(tipFunc(self))
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return button
end

local function BuildSpecs()
	specsFrame = CreateFrame("Frame", "SquidBotsLiteSpecs", UIParent)
	specsFrame:SetWidth(400)
	specsFrame:SetHeight(176 + SPEC_ROWS * 26)
	specsFrame:SetPoint("CENTER")
	specsFrame:SetBackdrop(PANEL_BACKDROP)
	specsFrame:SetBackdropColor(0.04, 0.04, 0.05, 1)
	specsFrame:SetFrameStrata("DIALOG")
	specsFrame:SetMovable(true)
	specsFrame:EnableMouse(true)
	specsFrame:SetClampedToScreen(true)
	specsFrame:RegisterForDrag("LeftButton")
	specsFrame:SetScript("OnDragStart", specsFrame.StartMoving)
	specsFrame:SetScript("OnDragStop", specsFrame.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteSpecs")
	specsFrame.title = specsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	specsFrame.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, specsFrame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	-- The player's own role, counted by "Balance the group".
	specsFrame.myRoleLabel = specsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	specsFrame.myRoleLabel:SetPoint("TOPLEFT", 18, -40)
	specsFrame.myRole = {}
	for i, role in ipairs(ROLES) do
		local button = RoleButton(specsFrame, role, 20, function() return L[ROLE_KEYS[role]] end, function()
			SquidBotsLiteDB.myRole = role
			RefreshSpecs()
		end)
		button:SetPoint("TOPLEFT", 100 + (i - 1) * 24, -36)
		specsFrame.myRole[role] = button
	end
	for i = 1, SPEC_ROWS do
		local row = CreateFrame("Frame", nil, specsFrame)
		row:SetWidth(368)
		row:SetHeight(24)
		row:SetPoint("TOPLEFT", 16, -66 - (i - 1) * 26)
		row.role = row:CreateTexture(nil, "ARTWORK")
		row.role:SetWidth(16)
		row.role:SetHeight(16)
		row.role:SetPoint("LEFT", 2, 0)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.name:SetPoint("LEFT", 24, 0)
		row.name:SetWidth(110)
		row.name:SetJustifyH("LEFT")
		row.spec = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		row.spec:SetPoint("LEFT", 136, 0)
		row.spec:SetWidth(100)
		row.spec:SetJustifyH("LEFT")
		for j, role in ipairs(ROLES) do
			local button = RoleButton(row, role, 18, function(self)
				return self.can and string.format(L.TIP_ROLE, L[ROLE_KEYS[role]]) or L.TIP_NO_ROLE
			end, function(self)
				local name = self:GetParent().botName
				if name and self.can then PickRole(name, role) end
			end)
			button:SetPoint("LEFT", 240 + (j - 1) * 22, 0)
			row[role] = button
		end
		row.pick = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.pick:SetWidth(54)
		row.pick:SetHeight(18)
		row.pick:SetPoint("LEFT", 310, 0)
		row.pick:SetScript("OnClick", function(self)
			local name = self:GetParent().botName
			if name then ShowMenu(SpecMenu(name)) end
		end)
		row:Hide()
		specRows[i] = row
	end
	specsFrame.balance = CreateFrame("Button", nil, specsFrame, "UIPanelButtonTemplate")
	specsFrame.balance:SetWidth(150)
	specsFrame.balance:SetHeight(22)
	specsFrame.balance:SetPoint("TOPLEFT", 16, -74 - SPEC_ROWS * 26)
	specsFrame.balance:SetScript("OnClick", function()
		if not balancePending then BalanceGroup() end
	end)
	specsFrame.balance:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(L.BALANCE)
		GameTooltip:AddLine(L.TIP_BALANCE, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	specsFrame.balance:SetScript("OnLeave", function() GameTooltip:Hide() end)
	specsFrame.refresh = CreateFrame("Button", nil, specsFrame, "UIPanelButtonTemplate")
	specsFrame.refresh:SetWidth(90)
	specsFrame.refresh:SetHeight(22)
	specsFrame.refresh:SetPoint("LEFT", specsFrame.balance, "RIGHT", 8, 0)
	specsFrame.refresh:SetScript("OnClick", function()
		for _, name in ipairs(PartyNames()) do AskSpecs(name) end
	end)
	specsFrame.status = specsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	specsFrame.status:SetPoint("LEFT", specsFrame.refresh, "RIGHT", 8, 0)
	specsFrame.status:SetWidth(110)
	specsFrame.status:SetJustifyH("LEFT")
	specsFrame.help = specsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	specsFrame.help:SetPoint("BOTTOMLEFT", 16, 18)
	specsFrame.help:SetWidth(368)
	specsFrame.help:SetJustifyH("LEFT")
	specsFrame:Hide()
	SpecsTexts()
end

ShowSpecs = function()
	specsFrame:Show()
	for _, name in ipairs(PartyNames()) do AskSpecs(name) end
	RefreshSpecs()
end

-- Called with the other refreshes: a silent bot is marked, a bot that joins while the panel is open is asked,
-- a pending "Balance the group" goes on once every bot answered (or after SPEC_WAIT), and a switched bot gets
-- the bar's state back.
local function TickSpecs()
	local now = GetTime()
	for name, at in pairs(specAskedAt) do
		if now - at > SPEC_WAIT then
			specAskedAt[name] = nil
			pendingRole[name] = nil
			specSilent[name] = true
		end
	end
	for name, at in pairs(reapplyAt) do
		if now >= at then
			reapplyAt[name] = nil
			Reapply(name)
		end
	end
	if specsFrame and specsFrame:IsShown() then
		for _, name in ipairs(PartyNames()) do
			local info = specsByName[name]
			if not info and not specAskedAt[name] and (not specAskedOnce[name] or now - specAskedOnce[name] > SPEC_REASK) then
				AskSpecs(name)
			end
		end
	end
	if balancePending then
		local waiting = false
		for _, name in ipairs(PartyNames()) do
			if specAskedAt[name] then waiting = true end
		end
		if not waiting or now - balancePending > SPEC_WAIT then BalanceGroup() end
	end
	RefreshSpecs()
end

local function BotMenu(name)
	local items = {
		{ text = name, isTitle = true, notCheckable = true },
		{ text = L.M_FOLLOW, notCheckable = true, func = function() Whisper(name, "follow") end },
		{ text = L.M_STAY, notCheckable = true, func = function() Whisper(name, "stay") end },
		{ text = L.M_ATTACK, notCheckable = true, func = function() Whisper(name, "attack") end },
		{ text = L.M_SUMMON, notCheckable = true, func = function() Whisper(name, "summon") end },
		{ text = L.SPEC_MENU, hasArrow = true, notCheckable = true, menuList = SpecMenu(name) },
	}
	if roleByName[name] == "tank" then
		table.insert(items, { text = L.M_AUTOPULL_ON, notCheckable = true, func = function() Whisper(name, "nc +coa auto pull") end })
		table.insert(items, { text = L.M_AUTOPULL_OFF, notCheckable = true, func = function() Whisper(name, "nc -coa auto pull") end })
	elseif roleByName[name] == "heal" then
		-- "focus heal" makes the healer heal ONLY the listed players: meant for a duo, undone by "clear".
		local me = UnitName("player")
		table.insert(items, { text = L.M_HEAL_ME, notCheckable = true, func = function() Whisper(name, "focus heal +" .. me) end })
		table.insert(items, { text = L.M_HEAL_ALL, notCheckable = true, func = function() Whisper(name, "focus heal clear") end })
	end
	table.insert(items, { text = L.M_STATS, notCheckable = true, func = function() Whisper(name, "stats") end })
	table.insert(items, { text = L.M_GEAR, notCheckable = true, func = function() Whisper(name, "autogear") end })
	table.insert(items, { text = L.M_KICK, notCheckable = true, func = function() UninviteUnit(name) end })
	return items
end

-- ---------------------------------------------------------------------------
-- The bar
-- ---------------------------------------------------------------------------
Highlight = function()
	for key, button in pairs(buttons) do
		local active = key == state.order or (key == "passive" and state.passive)
		button.ring:SetVertexColor(active and 1 or 0.35, active and 0.82 or 0.35, active and 0 or 0.35)
	end
	local passive = buttons.passive
	if passive then
		passive.icon:SetTexture(state.passive and ICON_PASSIVE or ICON_ACTIVE)
		passive.label = state.passive and "PASSIVE" or "ACTIVE"
		passive.tip = state.passive and "TIP_PASSIVE" or "TIP_ACTIVE"
		passive.caption:SetText(L[passive.label])
	end
end

local function BarButton(key, icon, label, tip, onClick)
	local button = CreateFrame("Button", nil, bar)
	button:SetWidth(34)
	button:SetHeight(34)
	local texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture(icon)
	button.icon = texture
	texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.ring = button:CreateTexture(nil, "OVERLAY")
	button.ring:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	button.ring:SetBlendMode("ADD")
	button.ring:SetWidth(62)
	button.ring:SetHeight(62)
	button.ring:SetPoint("CENTER")
	button.ring:SetAlpha(0.8)
	button.caption = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	local font, _, flags = button.caption:GetFont()
	button.caption:SetFont(font, CAPTION_SIZE, flags)
	button.caption:SetPoint("TOP", button, "BOTTOM", 0, -1)
	button.label, button.tip, button.onClick = label, tip, onClick
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

-- Spaces the buttons evenly by the widest caption, "Active" and "Passive" both counted so that the bar
-- does not move when the Passive button flips.
local function LayoutBar()
	local measure = buttons.follow.caption
	local shown = measure:GetText()
	local texts = { L.ACTIVE, L.PASSIVE }
	for _, button in pairs(buttons) do
		table.insert(texts, L[button.label])
	end
	local widest = 0
	for _, text in ipairs(texts) do
		measure:SetText(text)
		widest = math.max(widest, measure:GetStringWidth() or 0)
	end
	measure:SetText(shown)
	local step = widest > 0 and math.max(MIN_STEP, math.ceil(widest) + CAPTION_GAP) or FALLBACK_STEP
	for i, key in ipairs(BAR_ORDER) do
		buttons[key]:ClearAllPoints()
		buttons[key]:SetPoint("TOPLEFT", 3 + (i - 1) * step, 0)
	end
	bar:SetWidth(#BAR_ORDER * step)
end

local function RefreshTexts()
	for _, button in pairs(buttons) do
		button.caption:SetText(L[button.label])
	end
	if buttons.follow then LayoutBar() end
	for _, toast in ipairs(toastFrames) do
		toast.invite:SetText(L.INVITE)
	end
end

-- Party members lying dead, spirit not yet released (a ghost is already on its way back).
local function DeadMembers()
	local dead = {}
	for i = 1, 4 do
		local unit = "party" .. i
		if UnitExists(unit) and UnitIsDead(unit) and not UnitIsGhost(unit) then
			-- The name only: UnitName also returns the realm, "" for a member out of range or on a flight
			-- path, and table.insert took it for a position (jealous-sound/azerothcore-wotlk-coa#5441).
			local name = UnitName(unit)
			table.insert(dead, name)
		end
	end
	return dead
end

local function BuildBar()
	bar = CreateFrame("Frame", "SquidBotsLiteBar", UIParent)
	bar:SetWidth(#BAR_ORDER * FALLBACK_STEP)
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
			if SendOrder("follow") then SetOrder("follow") end
		end },
		{ "stay", "Interface\\Icons\\Spell_Nature_TimeStop", "STAY", "TIP_STAY", function()
			if SendOrder("stay") then SetOrder("stay") end
		end },
		{ "attack", "Interface\\Icons\\Ability_DualWield", "ATTACK", "TIP_ATTACK", function()
			if SendOrder("attack") then SetOrder("attack") end
		end },
		{ "passive", ICON_ACTIVE, "ACTIVE", "TIP_ACTIVE", function()
			if SetPassive(not state.passive) then state.passive = not state.passive; Highlight() end
		end },
		{ "dungeon", "Interface\\Icons\\Achievement_Dungeon_ClassicDungeonMaster", "DUNGEON", "TIP_DUNGEON", function()
			if SendOrder("co -wait for attack,+avoid aoe", "follow") then SetOrder("dungeon") end
		end },
		{ "summon", "Interface\\Icons\\Spell_Arcane_PortalDalaran", "SUMMON", "TIP_SUMMON", function()
			SendGroup("summon")
		end },
		{ "recruit", "Interface\\Icons\\Spell_Frost_SummonWaterElemental", "RECRUIT", "TIP_RECRUIT", function()
			ShowMenu(RecruitMenu())
		end },
		-- Whispered to the dead only: "release" tells a living bot to stop following and wait.
		{ "release", "Interface\\Icons\\Spell_Holy_Resurrection", "RELEASE", "TIP_RELEASE", function()
			for _, name in ipairs(DeadMembers()) do Whisper(name, "release") end
		end },
	}
	for _, def in ipairs(defs) do
		BarButton(def[1], def[2], def[3], def[4], def[5])
	end
	buttons.release:Hide()
	RefreshTexts()
	Highlight()
	if SquidBotsLiteDB.hidden then
		bar:Hide()
	end
end

local function RefreshRelease()
	-- No SetShown on the 3.3.5 client.
	if #DeadMembers() > 0 then buttons.release:Show() else buttons.release:Hide() end
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
			-- Nothing told that the icon opens the bot's menu.
			overlay:SetScript("OnEnter", function(self)
				local name = UnitName(self.unit)
				if not name then return end
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(name)
				local info = specsByName[name]
				local role = CurrentRole(name)
				if info and info.current then
					GameTooltip:AddLine(info.current .. (role and (" - " .. L[ROLE_KEYS[role]]) or ""), 1, 1, 1)
				elseif role then
					GameTooltip:AddLine(L[ROLE_KEYS[role]], 1, 1, 1)
				end
				GameTooltip:AddLine(L.TIP_BOT_ICON, 0.6, 0.6, 0.6)
				GameTooltip:Show()
			end)
			overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
			-- Who plays what at a glance: the specialization name, small, right of the health bar.
			overlay.spec = overlay:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			local healthBar = _G["PartyMemberFrame" .. i .. "HealthBar"]
			overlay.spec:SetPoint("LEFT", healthBar or frame, "RIGHT", 12, 0)
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
			local info = specsByName[name]
			overlay.spec:SetText(info and info.current or "")
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
-- My alts: the player's other characters, logged in as bots
-- ---------------------------------------------------------------------------
local ALT_ROWS = 12
local ROSTER_WAIT, AFTER_TOGGLE = 5, 3   -- seconds: answer to "bot list", new list after a log in / out
local WOTLK_CLASSES = { Druid = true, Hunter = true, Mage = true, Paladin = true, Priest = true, Rogue = true,
	Shaman = true, Warlock = true, Warrior = true, DeathKnight = true }
local altsFrame, altRows, roster = nil, {}, {}
local rosterAskedAt, refreshAt, hideRosterUntil

local function BotCommand(text)
	SendChatMessage(".playerbots bot " .. text, "SAY")
end

local function AskRoster()
	rosterAskedAt, refreshAt = GetTime(), nil
	altsFrame.status:SetText(L.ALTS_WAIT)
	BotCommand("list")
end

-- "Bot roster: +Aria Dawn , -Brom Warrior": + logged in as a bot, - offline. The server names the class only
-- for the WotLK classes (blank for a CoA class), and a CoA name may hold a space. The random bots of the
-- group come last with a +, so a + counts only for a name once seen offline (an alt) or out of the group.
local function ParseRoster(text)
	local list, inParty = {}, {}
	for i = 1, 4 do
		local name = UnitName("party" .. i)
		if name then inParty[name] = true end
	end
	SquidBotsLiteDB.alts = SquidBotsLiteDB.alts or {}
	for entry in (text .. ","):gmatch("([^,]+),") do
		local sign, rest = strtrim(entry):match("^([%+%-])(.*)$")
		if sign then
			rest = strtrim(rest)
			local head, last = rest:match("^(.-)%s+(%S+)$")
			local name = (last and WOTLK_CLASSES[last]) and head or rest
			if name ~= "" then
				if sign == "-" then SquidBotsLiteDB.alts[name] = true end
				if sign == "-" or SquidBotsLiteDB.alts[name] or not inParty[name] then
					table.insert(list, { name = name, online = sign == "+" })
				end
			end
		end
	end
	return list
end

local function RefreshAlts()
	if not altsFrame then return end
	for i, row in ipairs(altRows) do
		local alt = roster[i]
		row.alt = alt
		if alt then
			row.name:SetText(alt.name)
			row.dot:SetVertexColor(alt.online and 0.2 or 0.45, alt.online and 1 or 0.45, alt.online and 0.2 or 0.45)
			row.toggle:SetText(alt.online and L.ALTS_REMOVE or L.ALTS_ADD)
			row.toggle:Enable()
			if alt.online then row.summon:Show() else row.summon:Hide() end
			row:Show()
		else
			row:Hide()
		end
	end
	if #roster == 0 then
		altsFrame.status:SetText(L.ALTS_EMPTY)
	elseif #roster > ALT_ROWS then
		altsFrame.status:SetText(string.format(L.ALTS_MORE, #roster - ALT_ROWS))
	else
		altsFrame.status:SetText("")
	end
end

local function AltsTexts()
	if not altsFrame then return end
	altsFrame.title:SetText("SquidBots Lite - " .. L.ALTS)
	altsFrame.refresh:SetText(L.ALTS_REFRESH)
	altsFrame.help:SetText(L.ALTS_HELP)
	for _, row in ipairs(altRows) do
		row.summon:SetText(L.ALTS_SUMMON)
	end
end

local function BuildAlts()
	altsFrame = CreateFrame("Frame", "SquidBotsLiteAlts", UIParent)
	altsFrame:SetWidth(300)
	altsFrame:SetHeight(120 + ALT_ROWS * 22)
	altsFrame:SetPoint("CENTER")
	altsFrame:SetBackdrop(PANEL_BACKDROP)
	altsFrame:SetBackdropColor(0.04, 0.04, 0.05, 1)
	altsFrame:SetFrameStrata("DIALOG")
	altsFrame:SetMovable(true)
	altsFrame:EnableMouse(true)
	altsFrame:SetClampedToScreen(true)
	altsFrame:RegisterForDrag("LeftButton")
	altsFrame:SetScript("OnDragStart", altsFrame.StartMoving)
	altsFrame:SetScript("OnDragStop", altsFrame.StopMovingOrSizing)
	-- Escape closes it, as any game window.
	table.insert(UISpecialFrames, "SquidBotsLiteAlts")
	altsFrame.title = altsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	altsFrame.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, altsFrame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	altsFrame.refresh = CreateFrame("Button", nil, altsFrame, "UIPanelButtonTemplate")
	altsFrame.refresh:SetWidth(90)
	altsFrame.refresh:SetHeight(20)
	altsFrame.refresh:SetPoint("TOPLEFT", 16, -36)
	altsFrame.refresh:SetScript("OnClick", function() AskRoster() end)
	altsFrame.status = altsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	altsFrame.status:SetPoint("LEFT", altsFrame.refresh, "RIGHT", 8, 0)
	altsFrame.status:SetWidth(170)
	altsFrame.status:SetJustifyH("LEFT")
	for i = 1, ALT_ROWS do
		local row = CreateFrame("Frame", nil, altsFrame)
		row:SetWidth(268)
		row:SetHeight(20)
		row:SetPoint("TOPLEFT", 16, -62 - (i - 1) * 22)
		row.dot = row:CreateTexture(nil, "ARTWORK")
		row.dot:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.dot:SetWidth(8)
		row.dot:SetHeight(8)
		row.dot:SetPoint("LEFT", 2, 0)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.name:SetPoint("LEFT", 16, 0)
		row.name:SetWidth(110)
		row.name:SetJustifyH("LEFT")
		row.toggle = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.toggle:SetWidth(76)
		row.toggle:SetHeight(18)
		row.toggle:SetPoint("LEFT", 128, 0)
		row.toggle:SetScript("OnClick", function(self)
			local alt = self:GetParent().alt
			if not alt then return end
			BotCommand((alt.online and "remove " or "add ") .. alt.name)
			self:Disable()
			refreshAt = GetTime() + AFTER_TOGGLE
		end)
		-- An alt logs in where it logged out: Summon brings it over.
		row.summon = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.summon:SetWidth(60)
		row.summon:SetHeight(18)
		row.summon:SetPoint("LEFT", row.toggle, "RIGHT", 4, 0)
		row.summon:SetScript("OnClick", function(self)
			local alt = self:GetParent().alt
			if alt then Whisper(alt.name, "summon") end
		end)
		row:Hide()
		altRows[i] = row
	end
	altsFrame.help = altsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	altsFrame.help:SetPoint("BOTTOMLEFT", 16, 14)
	altsFrame.help:SetWidth(268)
	altsFrame.help:SetJustifyH("LEFT")
	altsFrame:Hide()
	AltsTexts()
end

ShowAlts = function()
	altsFrame:Show()
	AskRoster()
end

-- Called with the other refreshes: a new list after a log in / out, a word if the server stays silent.
local function TickAlts()
	if not altsFrame:IsShown() then return end
	local now = GetTime()
	if refreshAt and now >= refreshAt then
		AskRoster()
	elseif rosterAskedAt and now - rosterAskedAt > ROSTER_WAIT then
		rosterAskedAt = nil
		altsFrame.status:SetText(L.ALTS_NO_REPLY)
	end
end

-- Only the roster the panel asked for is read, and kept out of the chat; a "bot list" typed by hand shows.
local function OnSystem(message)
	local text = message:match("^Bot roster: ?(.*)$")
	if text and rosterAskedAt then
		-- The chat frames may see this message after this handler: they still hide it for a second.
		rosterAskedAt, hideRosterUntil = nil, GetTime() + 1
		roster = ParseRoster(text)
		RefreshAlts()
		return true
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
	if (rosterAskedAt or (hideRosterUntil and GetTime() < hideRosterUntil)) and message:find("^Bot roster:") then
		return true
	end
end)

-- ---------------------------------------------------------------------------
-- Chat
-- ---------------------------------------------------------------------------
-- A party member of unknown role (invited by hand, not through lfg bot) is whispered "co ?" once: a bot
-- answers with its combat strategies, "coa tank" or "coa heal" giving its role. Question and answer are
-- kept out of the chat. A human player gets that one whisper too; /sbl roles off stops it.
local function ProbeRoles()
	if SquidBotsLiteDB.autoRoles == false then return end
	local now = GetTime()
	for i = 1, 4 do
		local unit = "party" .. i
		local name = UnitName(unit)
		if name and name ~= UNKNOWNOBJECT and not roleByName[name] and not probedAt[name] and UnitIsConnected(unit) then
			firstSeen[name] = firstSeen[name] or now
			if now - firstSeen[name] >= PROBE_DELAY then
				probedAt[name] = now
				Whisper(name, "co ?")
			end
		end
	end
end

local function InProbeWindow(name)
	return probedAt[name] and GetTime() - probedAt[name] < PROBE_WINDOW
end

local function OnStrategies(message, sender)
	local list = {}
	for strategy in message:sub(13):gmatch("[^,]+") do
		list[strtrim(strategy)] = true
	end
	roleByName[sender] = (list["coa tank"] or list["tank"] or list["bear"]) and "tank"
		or (list["coa heal"] or list["heal"] or list["holy heal"]) and "heal" or "dps"
	knownBot[sender] = true
end

local function HideProbe(_, _, message, name)
	if InProbeWindow(name) and (message == "co ?" or message:find("^Strategies: ")) then
		return true
	end
end
-- A bot answers on the channel of the last order it got within a second, so party too.
for _, e in ipairs({ "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER" }) do
	ChatFrame_AddMessageEventFilter(e, HideProbe)
end

local function OnWhisper(message, sender)
	if OnSpecReply(message, sender) then return end
	if InProbeWindow(sender) and message:find("^Strategies: ") then
		OnStrategies(message, sender)
		return
	end
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
	knownBot[sender] = true
	for i = #toasts, 1, -1 do
		if toasts[i].name == sender then table.remove(toasts, i) end
	end
	table.insert(toasts, { name = sender, level = level, class = class, role = role, expires = GetTime() + OFFER_SECONDS })
	while #toasts > MAX_TOASTS do table.remove(toasts, 1) end
	if not bar:IsShown() then bar:Show(); SquidBotsLiteDB.hidden = false end
	RefreshToasts()
end

local function OnGroupChat(message, sender)
	if OnSpecReply(message, sender) then return end
	if InProbeWindow(sender) and message:find("^Strategies: ") then
		OnStrategies(message, sender)
		return
	end
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
		BuildAlts()
		BuildSpecs()
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
			RefreshRelease()
			ProbeRoles()
			TickAlts()
			TickSpecs()
		end)
	elseif event == "CHAT_MSG_WHISPER" then
		OnWhisper(arg1, arg2)
	elseif event == "CHAT_MSG_SYSTEM" then
		if OnSystem(arg1) then return end
		-- "Kegarink Bot joins as tank": a bot name can hold a space since CoA Bots 1.5 (CoaBotSurname).
		local name, role = arg1:match("^(.-) joins as (%a+)")
		if name and ROLE_COORDS[role] then
			roleByName[name] = role
			knownBot[name] = true
		end
	elseif arg1 and arg2 then
		OnGroupChat(arg1, arg2)
	end
end)

-- Called by Bindings.xml: a key does what a left click on that bar button does, bar shown or not.
function SquidBotsLite_Specs()
	ShowSpecs()
end

function SquidBotsLite_Order(key)
	local button = buttons[key]
	if button then button.onClick(button, "LeftButton") end
end

SLASH_SQUIDBOTSLITE1 = "/sbl"
SLASH_SQUIDBOTSLITE2 = "/squidlite"
SlashCmdList["SQUIDBOTSLITE"] = function(message)
	local command, rest = string.match(message or "", "^(%S*)%s*(.-)$")
	command = string.lower(command or "")
	if command == "lang" then
		SetLanguage(string.lower(rest))
		RefreshTexts()
		AltsTexts()
		RefreshAlts()
		SpecsTexts()
		Print(L.LANG_SET)
	elseif command == "channel" then
		SquidBotsLiteDB.channel = rest
		Print(string.format(L.CHANNEL_SET, rest ~= "" and rest or table.concat(CHANNELS, ", ")))
	elseif command == "alts" then
		ShowAlts()
	elseif command == "spec" or command == "specs" then
		ShowSpecs()
	elseif command == "roles" then
		SquidBotsLiteDB.autoRoles = string.lower(rest) ~= "off"
		Print(SquidBotsLiteDB.autoRoles and L.ROLES_ON or L.ROLES_OFF)
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
