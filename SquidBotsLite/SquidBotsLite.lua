-- SquidBots Lite: the minimal take. No window: a thin bar of orders (a Release button joins it while
-- a bot lies dead) and "Bots" to recruit, the bots' roles and alerts drawn on the game's own party
-- frames, and the offers bots whisper as small toasts above the bar, each with an Invite button.

SquidBotsLiteDB = SquidBotsLiteDB or {}

local STRINGS = {
	en = {
		FOLLOW = "Follow", STAY = "Stay", ATTACK = "Target", PASSIVE = "Passive", ACTIVE = "Active", DUNGEON = "Dungeon", ALTS_BAR = "Alts", RECRUIT = "Bots",
		TIP_FOLLOW = "Bots follow you.", TIP_STAY = "Bots stay where they are.", TIP_ATTACK = "Bots attack your target.",
		TIP_ACTIVE = "Bots fight normally. Click to make them passive: no fights, and the tank stops pulling on its own.",
		TIP_PASSIVE = "Bots are passive: no fights, no auto pull. Click, or give any order, to wake them.",
		TOGGLE_PASSIVE = "Passive / Active",
		PULL_ON = "Auto pull", PULL_OFF = "No pull", TOGGLE_PULL = "Tank auto pull on / off",
		RAIDFRAMES_ON = "Role icons and bot menus on the raid-style frames: on.",
		RAIDFRAMES_OFF = "Role icons and bot menus on the raid-style frames: off.",
		TIP_PULL_ON = "The tank pulls on its own. Click so it waits: it only fights what you or the group attack.",
		TIP_PULL_OFF = "The tank does not pull on its own: you choose the fights. Click to let it pull again.",
		TIP_DUNGEON = "Dungeon mode: bots stick to you, avoid ground effects, engage with you.",
		TIP_RECRUIT = "Ask for a tank, a healer or damage. Offers pop up above this bar.",
		TIP_ALTS = "Your other characters: log them in as bots, summon them, open their sheet (gear, bags, quests, mounts).",
		TIP_MOVE = "Shift-drag to move the bar, Ctrl + mouse wheel to resize it.",
		TIP_PROFILES = "Right click: profiles (farm, strict follow, dungeon).",
		PROFILES = "Profiles", P_FARM = "Farm (hunt, loot, eat)", P_STRICT = "Strict follow",
		P_DUNGEON = "Dungeon mode", P_LEAVE_DUNGEON = "Leave dungeon mode",
		ASK_TANK = "Ask for a tank", ASK_HEAL = "Ask for a healer", ASK_DPS = "Ask for damage", ASK_ALL = "Ask for all three",
		GM_ON = "GM mode on: bots are called with .playerbots coa.",
		GM_OFF = "GM mode off: bots are called with lfg bot, like any player.",
		GEAR = "Best gear for the group", REPAIR = "Repair the group",
		RAID_10 = "Raid of 10 bots", RAID_25 = "Raid of 25 bots", REGEAR = "Regear level 60+ bots (GM)",
		TRAIN = "Learn from my target (trainer)", M_TRAIN = "Learn from my target (trainer)",
		M_GATHER_ALL = "Gather everything (grey too)", M_GATHER_SKILLUP = "Gather only what gives skill",
		GATHER = "Gathering (whole group)",
		NO_TRAINER = "Target a trainer first (class or profession): the bots learn all it teaches them.",
		ALTS = "My alts", ALTS_REFRESH = "Refresh", ALTS_ADD = "Log in", ALTS_REMOVE = "Log out", ALTS_SUMMON = "Summon", ALTS_SHEET = "Sheet",
		ALTS_LEVEL = "Level %d %s", ALTS_UNKNOWN = "Level ?", ALTS_NO_SPEC = "no spec",
		TIP_SHEET = "Bot sheet: the gear, bags, quests and mounts of this alt.",
		TEAMS = "Teams", T_LOGIN = "Log in (%d)", T_LOGOUT = "Log out", T_DELETE = "Delete", T_SAVE_GROUP = "Save my group as a team...",
		T_SAVE_ONLINE = "Save the logged-in alts as a team...", T_NAME = "Name of the team:", T_NONE = "No team yet.",
		T_SAVED = "Team %s saved: %d characters.", T_STARTED = "Team %s: logging in %d characters, one a second.",
		T_EMPTY = "Nobody to save: invite or log in your alts first.",
		ACCOUNTS = "Accounts", A_SHOW = "Show my linked accounts", A_LINK = "Link an account...", A_KEY = "Set this account's key...",
		A_LOGIN_ALL = "Log in all its characters", A_UNLINK = "Unlink", A_NAME = "Account name to link:",
		A_KEYFOR = "Security key of %s (set on that account with Set this account's key):", A_MYKEY = "Key for this account (letters and digits):",
		A_BAD = "Letters, digits and _ only.", A_NONE = "No linked account known yet: Show my linked accounts.",
		A_HOWTO = "To play the characters of another account: log on that account once and set its key, then link it from here with that key.",
		ALTS_WAIT = "Asking the server...", ALTS_EMPTY = "No other character on this account.",
		ALTS_NO_REPLY = "No answer from the server: does it run the bot module?", ALTS_MORE = "%d more not shown.",
		ALTS_HELP = "Log an alt in: it joins your group as your bot. Hover a name for more.",
		ALTS_LOOK = "Keeps its look (wardrobe, mounts) if the server has CoA.CollectionsForBots = 1.",
		ALTS_TIP_CLICK = "Click: open its bot sheet.", ALTS_GOLD = "Gold: %s", ALTS_XP = "XP: %d%% (rested %d%%)",
		INVITE = "Invite", ASKED = "Asked in %s: %s", NO_CHANNEL = "Join the Zone or Newcomers channel first (or /sbl channel <name>).",
		NOT_IN_GROUP = "You are not in a group with bots.",
		LOW_MANA = "Low mana", PULLING = "Pulling", REZ = "Rez",
		M_FOLLOW = "Follow me", M_STAY = "Stay here", M_ATTACK = "Attack my target", M_SUMMON = "Come to me",
		M_AUTOPULL_ON = "Auto pull on", M_AUTOPULL_OFF = "Auto pull off", M_KICK = "Remove from group",
		M_TAKE_LEAD = "Give me the lead", M_MAKE_LEADER = "Make it the leader",
		M_MARK_ON = "Mark its target (skull)", M_MARK_OFF = "Stop marking",
		ALTS_LINKED = "linked account", ALTS_FROM_LINKED = "From a linked account: logged in with it, it stays listed here.",
		M_SHEET = "Bot sheet (gear, bags, quests)", M_STATS = "Stats (bags, money, xp)", M_GEAR = "Best gear", M_HEAL_ME = "Heal only me", M_HEAL_ALL = "Heal the whole group",
		SUMMON = "Regroup", TIP_SUMMON = "Bots teleport next to you. Handy when one is stuck.",
		RELEASE = "Release", TIP_RELEASE = "Shown when a bot is dead: dead bots release their spirit and run back to their body.",
		ROLE_ORDERS = "Orders by role", R_TANK_ATTACK = "Tank: attack my target", R_DPS_ATTACK = "Damage: attack my target",
		R_HEAL_FOLLOW = "Healers: follow me", R_HEAL_STAY = "Healers: stay here", R_MELEE_FLEE = "Melee: back to me, hold fire",
		FORMATION = "Formation", F_NEAR = "Close (default)", F_LINE = "Line", F_CIRCLE = "Circle", F_SHIELD = "Shield around me",
		F_ARROW = "Arrow", F_QUEUE = "Single file",
		ROLES_ON = "Automatic roles on: a bot of unknown role is asked \"co ?\" once, answer hidden.",
		OUTDATED = "SquidBots Lite %s is older than CoA Bots %s on this server. New version: https://github.com/Zyth45/squidbots-addon/releases/latest",
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
		HELP = "SquidBots Lite: /sbl (show/hide), /sbl show, /sbl hide, /sbl scale 0.5-2, /sbl lang fr|en, /sbl channel <name>, /sbl alts, /sbl spec, /sbl roles on|off, /sbl gm (GM only), /sbl reset. Key bindings: Esc > Key Bindings > SquidBots Lite.",
		SCALE_SET = "SquidBots Lite bar size: %s (this character).", SCALE_BAD = "Bar size: a number from 0.5 to 2, for example /sbl scale 1.2",
		LANG_SET = "SquidBots Lite language: English.", CHANNEL_SET = "SquidBots Lite asks in: %s",
	},
	fr = {
		FOLLOW = "Suivre", STAY = "Rester", ATTACK = "Cible", PASSIVE = "Passif", ACTIVE = "Actif", DUNGEON = "Donjon", ALTS_BAR = "Alts", RECRUIT = "Bots",
		TIP_FOLLOW = "Les bots vous suivent.", TIP_STAY = "Les bots restent sur place.", TIP_ATTACK = "Les bots attaquent votre cible.",
		TIP_ACTIVE = "Les bots combattent normalement. Cliquez pour les rendre passifs : plus de combat, et le tank arrête de tirer seul.",
		TIP_PASSIVE = "Les bots sont passifs : pas de combat, pas de pull auto. Cliquez, ou donnez n'importe quel ordre, pour les réveiller.",
		TOGGLE_PASSIVE = "Passif / Actif",
		PULL_ON = "Pull auto", PULL_OFF = "Pas de pull", TOGGLE_PULL = "Pull auto du tank oui / non",
		RAIDFRAMES_ON = "Icônes de rôle et menus des bots sur les cadres de style raid : activés.",
		RAIDFRAMES_OFF = "Icônes de rôle et menus des bots sur les cadres de style raid : désactivés.",
		TIP_PULL_ON = "Le tank tire tout seul. Cliquez pour qu'il attende : il ne se bat que contre ce que vous ou le groupe attaquez.",
		TIP_PULL_OFF = "Le tank ne tire pas tout seul : vous choisissez les combats. Cliquez pour qu'il tire de nouveau.",
		TIP_DUNGEON = "Mode donjon : les bots restent avec vous, évitent les zones au sol, engagent avec vous.",
		TIP_RECRUIT = "Demandez un tank, un soigneur ou des DPS. Les offres s'affichent au-dessus de la barre.",
		TIP_ALTS = "Vos autres personnages : connectez-les en bots, appelez-les, ouvrez leur fiche (équipement, sacs, quêtes, montures).",
		TIP_MOVE = "Maj + glisser pour déplacer la barre, Ctrl + molette pour la redimensionner.",
		TIP_PROFILES = "Clic droit : les profils (farm, suivi strict, donjon).",
		PROFILES = "Profils", P_FARM = "Farm (chasse, butin, repas)", P_STRICT = "Suivi strict",
		P_DUNGEON = "Mode donjon", P_LEAVE_DUNGEON = "Quitter le mode donjon",
		ASK_TANK = "Demander un tank", ASK_HEAL = "Demander un soigneur", ASK_DPS = "Demander des DPS", ASK_ALL = "Demander les trois",
		GM_ON = "Mode GM activé : les bots sont appelés avec .playerbots coa.",
		GM_OFF = "Mode GM désactivé : les bots sont appelés avec lfg bot, comme tout le monde.",
		GEAR = "Meilleur équipement du groupe", REPAIR = "Réparer le groupe",
		RAID_10 = "Raid de 10 bots", RAID_25 = "Raid de 25 bots", REGEAR = "Rééquiper les bots 60+ (MJ)",
		TRAIN = "Apprendre de ma cible (entraîneur)", M_TRAIN = "Apprendre de ma cible (entraîneur)",
		M_GATHER_ALL = "Tout récolter (gris compris)", M_GATHER_SKILLUP = "Récolter seulement ce qui fait monter",
		GATHER = "Récolte (tout le groupe)",
		NO_TRAINER = "Ciblez d'abord un entraîneur (de classe ou de métier) : les bots apprennent tout ce qu'il leur enseigne.",
		ALTS = "Mes alts", ALTS_REFRESH = "Actualiser", ALTS_ADD = "Connecter", ALTS_REMOVE = "Déconnecter", ALTS_SUMMON = "Appeler", ALTS_SHEET = "Fiche",
		ALTS_LEVEL = "Niveau %d %s", ALTS_UNKNOWN = "Niveau ?", ALTS_NO_SPEC = "sans spé",
		TIP_SHEET = "Fiche du bot : l'équipement, les sacs, les quêtes et les montures de cet alt.",
		TEAMS = "Équipes", T_LOGIN = "Connecter (%d)", T_LOGOUT = "Déconnecter", T_DELETE = "Supprimer", T_SAVE_GROUP = "Enregistrer mon groupe comme équipe...",
		T_SAVE_ONLINE = "Enregistrer les alts connectés comme équipe...", T_NAME = "Nom de l'équipe :", T_NONE = "Aucune équipe pour l'instant.",
		T_SAVED = "Équipe %s enregistrée : %d personnages.", T_STARTED = "Équipe %s : connexion de %d personnages, un par seconde.",
		T_EMPTY = "Personne à enregistrer : invitez ou connectez d'abord vos alts.",
		ACCOUNTS = "Comptes", A_SHOW = "Voir mes comptes liés", A_LINK = "Lier un compte...", A_KEY = "Définir la clé de ce compte...",
		A_LOGIN_ALL = "Connecter tous ses personnages", A_UNLINK = "Délier", A_NAME = "Nom du compte à lier :",
		A_KEYFOR = "Clé de sécurité de %s (définie sur ce compte avec Définir la clé de ce compte) :", A_MYKEY = "Clé de ce compte (lettres et chiffres) :",
		A_BAD = "Lettres, chiffres et _ seulement.", A_NONE = "Aucun compte lié connu : Voir mes comptes liés.",
		A_HOWTO = "Pour jouer les personnages d'un autre compte : connectez-vous une fois sur ce compte et définissez sa clé, puis liez-le d'ici avec cette clé.",
		ALTS_WAIT = "Demande au serveur...", ALTS_EMPTY = "Aucun autre personnage sur ce compte.",
		ALTS_NO_REPLY = "Pas de réponse du serveur : a-t-il le module des bots ?", ALTS_MORE = "%d de plus, non affichés.",
		ALTS_HELP = "Connectez un alt : il rejoint votre groupe comme bot. Survolez un nom pour en savoir plus.",
		ALTS_LOOK = "Garde son apparence (garde-robe, montures) si le serveur a CoA.CollectionsForBots = 1.",
		ALTS_TIP_CLICK = "Clic : ouvrir sa fiche.", ALTS_GOLD = "Or : %s", ALTS_XP = "XP : %d%% (reposé %d%%)",
		INVITE = "Inviter", ASKED = "Demandé dans %s : %s", NO_CHANNEL = "Rejoignez le channel Zone ou Newcomers (ou /sbl channel <nom>).",
		NOT_IN_GROUP = "Vous n'êtes pas en groupe avec des bots.",
		LOW_MANA = "Mana bas", PULLING = "Pull", REZ = "Rez",
		M_FOLLOW = "Me suivre", M_STAY = "Rester ici", M_ATTACK = "Attaquer ma cible", M_SUMMON = "Venir à moi",
		M_AUTOPULL_ON = "Auto pull activé", M_AUTOPULL_OFF = "Auto pull désactivé", M_KICK = "Retirer du groupe",
		M_TAKE_LEAD = "Me rendre le lead", M_MAKE_LEADER = "Le nommer chef",
		M_MARK_ON = "Marquer sa cible (tête de mort)", M_MARK_OFF = "Arrêter de marquer",
		ALTS_LINKED = "compte lié", ALTS_FROM_LINKED = "D'un compte lié : connecté une fois d'ici, il reste dans la liste.",
		M_SHEET = "Fiche du bot (équipement, sacs, quêtes)", M_STATS = "Stats (sacs, argent, xp)", M_GEAR = "Meilleur équipement", M_HEAL_ME = "Ne soigner que moi", M_HEAL_ALL = "Soigner tout le groupe",
		SUMMON = "Rappel", TIP_SUMMON = "Les bots se téléportent près de vous. Pratique quand l'un d'eux est coincé.",
		RELEASE = "Libérer", TIP_RELEASE = "Visible quand un bot est mort : les bots morts libèrent leur esprit et rejoignent leur corps.",
		ROLE_ORDERS = "Ordres par rôle", R_TANK_ATTACK = "Tank : attaquer ma cible", R_DPS_ATTACK = "DPS : attaquer ma cible",
		R_HEAL_FOLLOW = "Soigneurs : me suivre", R_HEAL_STAY = "Soigneurs : rester ici", R_MELEE_FLEE = "Corps à corps : revenir sans attaquer",
		FORMATION = "Formation", F_NEAR = "Proche (par défaut)", F_LINE = "Ligne", F_CIRCLE = "Cercle", F_SHIELD = "Bouclier autour de moi",
		F_ARROW = "Flèche", F_QUEUE = "File indienne",
		ROLES_ON = "Rôles automatiques activés : un bot au rôle inconnu reçoit « co ? » une fois, réponse masquée.",
		OUTDATED = "SquidBots Lite %s est plus ancien que CoA Bots %s sur ce serveur. Nouvelle version : https://github.com/Zyth45/squidbots-addon/releases/latest",
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
		HELP = "SquidBots Lite : /sbl (afficher/cacher), /sbl show, /sbl hide, /sbl scale 0.5-2, /sbl lang fr|en, /sbl channel <nom>, /sbl alts, /sbl spec, /sbl roles on|off, /sbl gm (MJ), /sbl reset. Raccourcis : Échap > Raccourcis > SquidBots Lite.",
		SCALE_SET = "Taille de la barre SquidBots Lite : %s (ce personnage).", SCALE_BAD = "Taille de la barre : un nombre de 0,5 à 2, par exemple /sbl scale 1.2",
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
-- Ascension's texture is 256 x 256 with 66-pixel icons (leader, heal / tank, dps / a black disc below the tank),
-- not Blizzard's 64 x 64 one with 19-pixel icons.
local ROLE_COORDS = {
	tank = { 1 / 256, 66 / 256, 69 / 256, 130 / 256 },
	heal = { 68 / 256, 132 / 256, 1 / 256, 66 / 256 },
	dps = { 68 / 256, 132 / 256, 68 / 256, 133 / 256 },
}
local CHANNELS = { "Zone", "Newcomers", "World" }
local OFFER_SECONDS = 120
-- "Ask for all three" brings 7 offers by default (2 tanks, 2 healers, 3 damage: CoaLfg*Offers on the server).
local MAX_TOASTS = 8
-- Captions in a smaller font than the game's small text, and buttons spaced by the widest caption of the
-- current language (measured in game): English "Dungeon" needs more room than French "Donjon".
local CAPTION_SIZE, CAPTION_GAP, MIN_STEP, FALLBACK_STEP = 8, 3, 37, 52
local BAR_ORDER = { "follow", "stay", "attack", "passive", "pull", "dungeon", "summon", "alts", "recruit", "release" }
-- A member of unknown role is asked "co ?" this long after it shows up (a lfg recruit announces
-- its role on its own first), and the "Strategies: ..." answer is hidden for PROBE_WINDOW seconds.
local PROBE_DELAY, PROBE_WINDOW = 3, 10
local FORMATIONS = { { "near", "F_NEAR" }, { "line", "F_LINE" }, { "circle", "F_CIRCLE" }, { "shield", "F_SHIELD" },
	{ "arrow", "F_ARROW" }, { "queue", "F_QUEUE" } }
-- The Passive button shows the bots' current state: a charge arrow while they fight, Zzz while passive.
local ICON_ACTIVE, ICON_PASSIVE = "Interface\\Icons\\Ability_Warrior_Charge", "Interface\\Icons\\Spell_Nature_Sleep"
-- The tank's auto pull (on by default for a CoA tank): an arrow while it pulls, a shield while it waits.
local ICON_PULL_ON, ICON_PULL_OFF = "Interface\\Icons\\Ability_Marksmanship", "Interface\\Icons\\INV_Shield_06"
-- The panels: a dark plain background under the dialog border, since the dialog background let the floating
-- names of the world show through. The role buttons use square icons, like the bar.
local PANEL_BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
local ROLE_BUTTON_ICONS = { tank = "Interface\\Icons\\Ability_Defend", heal = "Interface\\Icons\\Spell_Holy_FlashHeal",
	dps = "Interface\\Icons\\Ability_MeleeDamage" }
local BINDINGS = { { "follow", "FOLLOW" }, { "stay", "STAY" }, { "attack", "M_ATTACK" }, { "passive", "TOGGLE_PASSIVE" }, { "pull", "TOGGLE_PULL" },
	{ "dungeon", "DUNGEON" }, { "summon", "SUMMON" }, { "alts", "ALTS" }, { "release", "RELEASE" } }

local roleByName, badges, toasts = {}, {}, {}
local firstSeen, probedAt = {}, {}
local state = { order = "follow", passive = false, autoPull = true }
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

-- A menu closes on its own once the mouse has left it this many seconds (the game keeps it open otherwise).
local MENU_HIDE_DELAY = 1
local menuFrame = CreateFrame("Frame", "SquidBotsLiteMenu", UIParent, "UIDropDownMenuTemplate")
-- The game closes a menu only on a click in the world, not over an addon window, and its own hide delay does
-- not apply to these menus: a menu of the addon closes a second after the mouse left it, or on a click on our panels.
local menuWatch = CreateFrame("Frame")
menuWatch:Hide()
menuWatch:SetScript("OnUpdate", function(self)
	local list1, list2 = _G.DropDownList1, _G.DropDownList2
	if not list1 or not list1:IsShown() then self:Hide() return end
	if MouseIsOver(list1) or (list2 and list2:IsShown() and MouseIsOver(list2)) then
		self.left = nil
	else
		self.left = self.left or GetTime()
		if GetTime() - self.left > MENU_HIDE_DELAY then
			CloseDropDownMenus()
			self:Hide()
		end
	end
end)

function SquidBotsLite_WatchMenu()
	menuWatch.left = nil
	menuWatch:Show()
end

local function ShowMenu(items)
	-- A second click on the button that opened it closes it.
	if _G.DropDownList1 and DropDownList1:IsShown() and UIDROPDOWNMENU_OPEN_MENU == menuFrame then
		CloseDropDownMenus()
		return
	end
	EasyMenu(items, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	SquidBotsLite_WatchMenu()
end

-- "trainer learn": the bot learns all that the player's target teaches it (class spells, a profession and its ranks).
local function TargetIsNpc()
	if UnitExists("target") and not UnitIsPlayer("target") then return true end
	Print(L.NO_TRAINER)
	return false
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
		{ text = L.TRAIN, notCheckable = true, func = function() if TargetIsNpc() then SendGroup("trainer learn") end end },
		{ text = L.GATHER, hasArrow = true, notCheckable = true, menuList = {
			{ text = L.M_GATHER_SKILLUP, notCheckable = true, func = function() SendGroup("nc -gather all") end },
			{ text = L.M_GATHER_ALL, notCheckable = true, func = function() SendGroup("nc +gather all") end },
		} },
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
	return SendGroup("co -passive", state.autoPull and "@tank nc +coa auto pull" or "@tank nc -coa auto pull")
end

-- The Auto pull button: passive bots keep it off until they wake, then the choice applies.
local function SetAutoPull(on)
	if not state.passive and not SendGroup(on and "@tank nc +coa auto pull" or "@tank nc -coa auto pull") then return false end
	state.autoPull = on
	Highlight()
	return true
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

-- The group's leader: in a raid the roster says it (rank 2), in a party UnitIsPartyLeader.
local function IsGroupLeader(name)
	local raid = GetNumRaidMembers()
	if raid > 0 then
		for i = 1, raid do
			local member, rank = GetRaidRosterInfo(i)
			if member == name then return rank == 2 end
		end
		return false
	end
	if name == UnitName("player") then return IsPartyLeader() == 1 or IsPartyLeader() == true end
	local unit = UnitOf(name)
	return unit and UnitIsPartyLeader(unit) and true or false
end

local function IsCoaBot(name)
	local unit = UnitOf(name)
	if unit then
		local _, token = UnitClass(unit)
		if token and WOTLK_TOKENS[token] then return false end
	end
	-- An alt of this account (seen offline in My alts, or logged in by the player) is a bot of theirs too.
	return knownBot[name] or name:find(" Bot$") ~= nil or (SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[name]) == true
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
	SquidBotsLiteDB.altInfo = SquidBotsLiteDB.altInfo or {}
	SquidBotsLiteDB.altInfo[name] = SquidBotsLiteDB.altInfo[name] or {}
	SquidBotsLiteDB.altInfo[name].spec, SquidBotsLiteDB.altInfo[name].role = specName, role
	SquidBotsLiteDB.altInfo[name].noSpec = nil
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
	elseif not state.autoPull and CurrentRole(name) == "tank" then
		Whisper(name, "nc -coa auto pull")
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
	-- A character rushed with .level has specializations to pick, none active: My alts says so.
	SquidBotsLiteDB.altInfo = SquidBotsLiteDB.altInfo or {}
	SquidBotsLiteDB.altInfo[sender] = SquidBotsLiteDB.altInfo[sender] or {}
	SquidBotsLiteDB.altInfo[sender].noSpec = current == nil or nil
	if current == nil then SquidBotsLiteDB.altInfo[sender].spec = nil end
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
		-- No role icon in front of the name: the active role button already shows it, gold-ringed.
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.name:SetPoint("LEFT", 4, 0)
		row.name:SetWidth(128)
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
		{ text = L.M_TRAIN, notCheckable = true, func = function() if TargetIsNpc() then Whisper(name, "trainer learn") end end },
		-- CoA Bots 2.2 skips what is grey for the bot's gathering skill; "gather all" gathers it anyway.
		{ text = L.M_GATHER_ALL, notCheckable = true, func = function() Whisper(name, "nc +gather all") end },
		{ text = L.M_GATHER_SKILLUP, notCheckable = true, func = function() Whisper(name, "nc -gather all") end },
	}
	-- "give leader": a bot that leads the group (the player's old main, played as a bot now) hands the lead back.
	if IsGroupLeader(name) then
		table.insert(items, { text = L.M_TAKE_LEAD, notCheckable = true, func = function() Whisper(name, "give leader") end })
	elseif IsGroupLeader(UnitName("player")) then
		table.insert(items, { text = L.M_MAKE_LEADER, notCheckable = true, func = function() PromoteToLeader(name) end })
	end
	if roleByName[name] == "tank" then
		table.insert(items, { text = L.M_AUTOPULL_ON, notCheckable = true, func = function() Whisper(name, "nc +coa auto pull") end })
		table.insert(items, { text = L.M_AUTOPULL_OFF, notCheckable = true, func = function() Whisper(name, "nc -coa auto pull") end })
		-- "mark rti" puts the "rti" icon (skull) on the target it fights.
		table.insert(items, { text = L.M_MARK_ON, notCheckable = true, func = function()
			Whisper(name, "rti skull")
			Whisper(name, "co +mark rti")
		end })
		table.insert(items, { text = L.M_MARK_OFF, notCheckable = true, func = function() Whisper(name, "co -mark rti") end })
	elseif roleByName[name] == "heal" then
		-- "focus heal" makes the healer heal ONLY the listed players: meant for a duo, undone by "clear".
		local me = UnitName("player")
		table.insert(items, { text = L.M_HEAL_ME, notCheckable = true, func = function() Whisper(name, "focus heal +" .. me) end })
		table.insert(items, { text = L.M_HEAL_ALL, notCheckable = true, func = function() Whisper(name, "focus heal clear") end })
	end
	-- Bot sheet: Manager.lua (beta).
	if SquidBotsLite_OpenSheet then
		table.insert(items, { text = L.M_SHEET, notCheckable = true, func = function() SquidBotsLite_OpenSheet(name) end })
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
		local active = key == state.order or (key == "passive" and state.passive) or (key == "pull" and not state.autoPull)
		button.ring:SetVertexColor(active and 1 or 0.35, active and 0.82 or 0.35, active and 0 or 0.35)
	end
	local passive = buttons.passive
	if passive then
		passive.icon:SetTexture(state.passive and ICON_PASSIVE or ICON_ACTIVE)
		passive.label = state.passive and "PASSIVE" or "ACTIVE"
		passive.tip = state.passive and "TIP_PASSIVE" or "TIP_ACTIVE"
		passive.caption:SetText(L[passive.label])
	end
	local pull = buttons.pull
	if pull then
		pull.icon:SetTexture(state.autoPull and ICON_PULL_ON or ICON_PULL_OFF)
		pull.label = state.autoPull and "PULL_ON" or "PULL_OFF"
		pull.tip = state.autoPull and "TIP_PULL_ON" or "TIP_PULL_OFF"
		pull.caption:SetText(L[pull.label])
	end
end

-- Size and place of the bar, and whether it shows, are kept per character (SquidBotsLiteCharDB): a healer
-- and a tank of the same account rarely want the bar at the same spot.
local SCALE_MIN, SCALE_MAX = 0.5, 2

local function PlaceBar()
	local p = SquidBotsLiteCharDB.point
	bar:ClearAllPoints()
	if p then
		bar:SetPoint(p[1], UIParent, p[2], p[3], p[4])
	else
		bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
	end
end

local function SetBarScale(scale, quiet)
	scale = math.floor(math.max(SCALE_MIN, math.min(SCALE_MAX, scale)) * 100 + 0.5) / 100
	SquidBotsLiteCharDB.scale = scale
	if bar then bar:SetScale(scale) end
	if not quiet then Print(string.format(L.SCALE_SET, scale)) end
end

local function SetBarShown(shown)
	SquidBotsLiteCharDB.hidden = not shown
	if shown then bar:Show() else bar:Hide() end
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
		SquidBotsLiteCharDB.point = { point, relativePoint, x, y }
	end)
	-- Ctrl + mouse wheel over the bar: bigger or smaller, by steps of 0.05.
	button:EnableMouseWheel(true)
	button:SetScript("OnMouseWheel", function(_, delta)
		if IsControlKeyDown() then SetBarScale((SquidBotsLiteCharDB.scale or 1) + 0.05 * delta, true) end
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
-- Spaces the buttons evenly, as close as two neighbouring captions allow: the step is the widest pair of
-- neighbours (half of each caption either side of its icon), not the widest caption twice. "Active" and
-- "Passive" are both counted, so the bar does not move when the button flips.
local function LayoutBar()
	local measure = buttons.follow.caption
	local shown = measure:GetText()
	local function Width(text)
		measure:SetText(text)
		return measure:GetStringWidth() or 0
	end
	local widths = {}
	for i, key in ipairs(BAR_ORDER) do
		local button = buttons[key]
		widths[i] = key == "passive" and math.max(Width(L.ACTIVE), Width(L.PASSIVE))
			or key == "pull" and math.max(Width(L.PULL_ON), Width(L.PULL_OFF)) or Width(L[button.label])
	end
	measure:SetText(shown)
	local step = 0
	for i = 1, #widths - 1 do
		step = math.max(step, (widths[i] + widths[i + 1]) / 2)
	end
	step = step > 0 and math.max(MIN_STEP, math.ceil(step) + CAPTION_GAP) or FALLBACK_STEP
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
	bar:SetScale(SquidBotsLiteCharDB.scale or 1)
	PlaceBar()
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
		{ "pull", ICON_PULL_ON, "PULL_ON", "TIP_PULL_ON", function()
			SetAutoPull(not state.autoPull)
		end },
		{ "dungeon", "Interface\\Icons\\Achievement_Dungeon_ClassicDungeonMaster", "DUNGEON", "TIP_DUNGEON", function()
			if SendOrder("co -wait for attack,+avoid aoe", "follow") then SetOrder("dungeon") end
		end },
		{ "summon", "Interface\\Icons\\Spell_Arcane_PortalDalaran", "SUMMON", "TIP_SUMMON", function()
			SendGroup("summon")
		end },
		-- Alts: the My alts panel, where each logged-in alt also opens its bot sheet.
		{ "alts", "Interface\\Icons\\INV_Misc_Head_Human_01", "ALTS_BAR", "TIP_ALTS", function()
			ShowAlts()
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
	if SquidBotsLiteCharDB.hidden then
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
local function OverlayClick(self)
	local name = self.unit and UnitName(self.unit)
	if name then ShowMenu(BotMenu(name)) end
end

-- Nothing told that the icon opens the bot's menu.
local function OverlayTooltip(self)
	local name = self.unit and UnitName(self.unit)
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
end

local function BuildOverlays()
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame" .. i]
		if frame then
			local overlay = CreateFrame("Button", nil, frame)
			overlay:SetWidth(18)
			overlay:SetHeight(18)
			overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
			overlay:SetFrameLevel(frame:GetFrameLevel() + 5)
			-- The party frame's own role icon peeked out under ours (#5439): ours shows the role, the native one is hidden.
			local nativeRole = _G["PartyMemberFrame" .. i .. "RoleIcon"]
			if nativeRole then nativeRole:SetAlpha(0) end
			overlay.icon = overlay:CreateTexture(nil, "OVERLAY")
			overlay.icon:SetAllPoints()
			overlay.badge = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			overlay.badge:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 46, 10)
			overlay.unit = "party" .. i
			overlay:SetScript("OnClick", OverlayClick)
			overlay:SetScript("OnEnter", OverlayTooltip)
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

-- Raid-style frames (Ascension_CompactRaidFrames, "Use raid-style party frames"): the same role icon and
-- bot menu, and the alert text inside the frame. Their frames are made on demand and change units, so
-- they are looked for every few seconds and the unit is read from the frame at each refresh. Our icons
-- belong to UIParent and are only anchored to those secure frames, which keeps them out of combat locks.
-- Looking through every frame costs: every 10 seconds in a group, and half a second after the group changes.
local compactOverlays, compactScanAt, compactGroupSize = {}, 0, -1
local COMPACT_SCAN, COMPACT_RESCAN = 10, 0.5

local function CompactUnit(frame)
	local unit = frame.displayedUnit or frame.unit
	if type(unit) ~= "string" and frame.GetAttribute then unit = frame:GetAttribute("unit") end
	return type(unit) == "string" and unit or nil
end

local function IsCompactFrame(frame)
	-- A CompactUnitFrame: a unit and a "healthBar" (the old party and target frames have "healthbar"). Ascension's
	-- CompactRaidFrameN have no "name" field.
	return frame.healthBar and CompactUnit(frame)
end

local function CompactOverlay(frame)
	local overlay = CreateFrame("Button", nil, UIParent)
	overlay:SetWidth(14)
	overlay:SetHeight(14)
	overlay:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
	overlay.icon = overlay:CreateTexture(nil, "OVERLAY")
	overlay.icon:SetAllPoints()
	overlay.badge = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	overlay.badge:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, 3)
	overlay.badge:SetPoint("RIGHT", frame, "RIGHT", -3, 0)
	overlay.badge:SetJustifyH("LEFT")
	overlay:SetScript("OnClick", OverlayClick)
	overlay:SetScript("OnEnter", OverlayTooltip)
	overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
	overlay.frame = frame
	compactOverlays[frame] = overlay
	return overlay
end

local function ScanCompactFrames()
	local frame = EnumerateFrames()
	while frame do
		if not compactOverlays[frame] and IsCompactFrame(frame) then CompactOverlay(frame) end
		frame = EnumerateFrames(frame)
	end
end

local function RefreshCompactOverlays()
	if SquidBotsLiteDB.raidFrames == false then
		for _, overlay in pairs(compactOverlays) do overlay:Hide() end
		return
	end
	local now = GetTime()
	local size = GetNumRaidMembers() + GetNumPartyMembers()
	if size ~= compactGroupSize then
		compactGroupSize = size
		compactScanAt = math.min(compactScanAt, now + COMPACT_RESCAN)
	end
	if size > 0 and now >= compactScanAt then
		compactScanAt = now + COMPACT_SCAN
		if _G.CompactUnitMixin or IsAddOnLoaded("Ascension_CompactRaidFrames") or IsAddOnLoaded("CompactRaidFrame")
			or _G.CompactRaidFrameContainer then
			ScanCompactFrames()
		end
	end
	for frame, overlay in pairs(compactOverlays) do
		local unit = frame:IsVisible() and CompactUnit(frame)
		local name = unit and not UnitIsUnit(unit, "player") and UnitName(unit)
		if name then
			overlay.unit = unit
			overlay:SetFrameStrata(frame:GetFrameStrata())
			overlay:SetFrameLevel(frame:GetFrameLevel() + 10)
			if frame.roleIcon then frame.roleIcon:SetAlpha(0) end
			SetRoleIcon(overlay.icon, roleByName[name] or "none")
			if not roleByName[name] then
				overlay.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				overlay.icon:SetTexCoord(0, 1, 0, 1)
				overlay.icon:Show()
			end
			local badge = badges[name]
			if badge and badge.untilTime > now then
				overlay.badge:SetText(badge.text)
				overlay.badge:SetTextColor(badge.r, badge.g, badge.b)
			else
				overlay.badge:SetText("")
			end
			overlay:Show()
		else
			overlay.unit = nil
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
local ALT_ROWS = 10
local ALT_ROW_H = 36
-- "Bot list" names the alts only; their level and class are noted whenever they are seen (played, or in the
-- group) and kept account-wide in SquidBotsLiteDB.altInfo.
local SHEET_ICON = "Interface\\Icons\\Achievement_Character_Human_Male"
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
	local list, inParty, seen = {}, {}, {}
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
				if sign == "-" then
					SquidBotsLiteDB.alts[name] = true
					-- Seen offline in "bot list": a character of this account, not of a linked one.
					if SquidBotsLiteDB.linkedAlts then SquidBotsLiteDB.linkedAlts[name] = nil end
				end
				if sign == "-" or SquidBotsLiteDB.alts[name] or not inParty[name] then
					table.insert(list, { name = name, online = sign == "+", linked = SquidBotsLiteDB.linkedAlts and SquidBotsLiteDB.linkedAlts[name] })
					seen[name] = true
				end
			end
		end
	end
	-- "bot list" names only this account's characters: those of a linked account logged in from here are kept
	-- (SquidBotsLiteDB.linkedAlts), offline when the server does not list them.
	for name in pairs(SquidBotsLiteDB.linkedAlts or {}) do
		if not seen[name] then table.insert(list, { name = name, online = false, linked = true }) end
	end
	table.sort(list, function(a, b)
		if a.online ~= b.online then return a.online end
		return a.name < b.name
	end)
	return list
end

local function NoteAlt(unit)
	local name = UnitName(unit)
	if not name or name == UNKNOWNOBJECT then return end
	local level = UnitLevel(unit)
	if not level or level <= 0 then return end
	local class, token = UnitClass(unit)
	SquidBotsLiteDB.altInfo = SquidBotsLiteDB.altInfo or {}
	local info = SquidBotsLiteDB.altInfo[name] or {}
	if info.level ~= level then info.xp, info.rest = nil, nil end
	info.level, info.class, info.token = level, class, token
	if unit == "player" then
		local max = UnitXPMax("player")
		if max and max > 0 and level < (MAX_PLAYER_LEVEL or 60) then
			info.xp = math.floor(100 * UnitXP("player") / max)
			info.rest = math.floor(100 * (GetXPExhaustion() or 0) / max)
		else
			info.xp = nil
		end
	end
	SquidBotsLiteDB.altInfo[name] = info
end

-- "12g 3s 4c, ..., |cff00ff0045|cffffd333/|cff00ff0012%|cffffffff XP" (StatsAction): xp and rested, in %.
function SquidBotsLite_NoteStats(name, message)
	local plain = (message or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	SquidBotsLiteDB.altInfo = SquidBotsLiteDB.altInfo or {}
	local info = SquidBotsLiteDB.altInfo[name] or {}
	if not plain:find("^%d+[gsc]") then return end
	local xp, rest = plain:match("(%d+)/(%d+)%% XP")
	info.xp, info.rest = tonumber(xp), tonumber(rest)
	if plain:find("^%d+[gsc]") then info.gold = plain:match("^([^,]+)") end
	SquidBotsLiteDB.altInfo[name] = info
end

local function NoteGroup()
	NoteAlt("player")
	for i = 1, 4 do NoteAlt("party" .. i) end
	-- Five alts or more make a raid: party1-4 then hold only the player's own subgroup.
	for i = 1, GetNumRaidMembers() do NoteAlt("raid" .. i) end
end

local function AltLine(name)
	local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[name]
	if not info or not info.level then return "|cff808080" .. L.ALTS_UNKNOWN .. "|r" end
	local color = info.token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[info.token]
	local class = info.class or ""
	if color then class = string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, class) end
	local line = string.format(L.ALTS_LEVEL, info.level, class)
	if info.spec then line = line .. " |cffaaaaaa- " .. info.spec .. "|r"
	elseif info.noSpec and (info.level or 0) >= 10 then line = line .. " |cffff9933- " .. L.ALTS_NO_SPEC .. "|r" end
	return line
end

local function ShowXP(bar, name)
	local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[name]
	if info and info.xp then
		bar:SetValue(info.xp)
		bar.rest:SetWidth(math.max(1, bar:GetWidth() * math.min(100 - info.xp, info.rest or 0) / 100))
		if (info.rest or 0) > 0 then bar.rest:Show() else bar.rest:Hide() end
		bar:Show()
	else
		bar:Hide()
	end
end

-- The online alts are asked "stats" now and then (at most once a minute each), for their xp: answer hidden.
local altStatsAt, altSpecAsked = {}, {}
local function AskAltStats()
	local now = GetTime()
	for _, alt in ipairs(roster) do
		if alt.online and (not altStatsAt[alt.name] or now - altStatsAt[alt.name] > 60) then
			altStatsAt[alt.name] = now
			Whisper(alt.name, "stats")
		end
		-- Its specialization too, once a session, if it is in the group (the panel of specializations asks the same).
		local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[alt.name]
		if alt.online and not (info and info.spec) and not altSpecAsked[alt.name] then
			altSpecAsked[alt.name] = true
			AskSpecs(alt.name)
		end
	end
end

local function InStatsWindow(name)
	return altStatsAt[name] and GetTime() - altStatsAt[name] < 5
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(_, _, message, name)
	if InStatsWindow(name) and (message:find(" XP", 1, true) or message:find("^%d+[gsc]")) then return true end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_, _, message, name)
	if InStatsWindow(name) and message == "stats" then return true end
end)

local function RefreshAlts()
	if not altsFrame then return end
	NoteGroup()
	-- 25 alts for a raid: the list scrolls (wheel or bar), ALT_ROWS at a time.
	altsFrame:SetHeight(138 + math.max(3, math.min(#roster, ALT_ROWS)) * ALT_ROW_H)
	FauxScrollFrame_Update(altsFrame.scroll, #roster, ALT_ROWS, ALT_ROW_H)
	local offset = FauxScrollFrame_GetOffset(altsFrame.scroll)
	for i, row in ipairs(altRows) do
		local alt = roster[i + offset]
		row.alt = alt
		if alt then
			row.name:SetText(alt.linked and (alt.name .. " |cff8888aa(" .. L.ALTS_LINKED .. ")|r") or alt.name)
			row.info:SetText(AltLine(alt.name))
			ShowXP(row.xp, alt.name)
			row.dot:SetVertexColor(alt.online and 0.2 or 0.45, alt.online and 1 or 0.45, alt.online and 0.2 or 0.45)
			row.toggle:SetText(alt.online and L.ALTS_REMOVE or L.ALTS_ADD)
			row.toggle:Enable()
			if alt.online then row.summon:Show() else row.summon:Hide() end
			if alt.online and SquidBotsLite_OpenSheet then row.sheet:Show() else row.sheet:Hide() end
			row:Show()
		else
			row:Hide()
		end
	end
	if #roster == 0 then
		altsFrame.status:SetText(L.ALTS_EMPTY)
	else
		altsFrame.status:SetText("")
	end
end

local function AltsTexts()
	if not altsFrame then return end
	altsFrame.title:SetText("SquidBots Lite - " .. L.ALTS)
	altsFrame.refresh:SetText(L.ALTS_REFRESH)
	altsFrame.teams:SetText(L.TEAMS)
	altsFrame.accounts:SetText(L.ACCOUNTS)
	altsFrame.help:SetText(L.ALTS_HELP)
	for _, row in ipairs(altRows) do
		row.summon:SetText(L.ALTS_SUMMON)
		row.sheet:SetText("   " .. L.ALTS_SHEET)
	end
end

-- Teams: named lists of characters kept account-wide (SquidBotsLiteDB.teams), logged in one a second with the same
-- ".playerbots bot add" a player types; a sixth member turns the party into a raid on the server's side.
local loginQueue, loginNext = {}, 0

local function QueueBots(command, names)
	for _, name in ipairs(names) do table.insert(loginQueue, command .. " " .. name) end
end

local function TeamNames(name)
	local names = {}
	for _, n in ipairs((SquidBotsLiteDB.teams or {})[name] or {}) do table.insert(names, n) end
	return names
end

local function GroupNames()
	local names, me = {}, UnitName("player")
	local raid = GetNumRaidMembers()
	for i = 1, (raid > 0 and raid or 4) do
		local n = UnitName((raid > 0 and "raid" or "party") .. i)
		if n and n ~= me and n ~= UNKNOWNOBJECT then table.insert(names, n) end
	end
	return names
end

local function OnlineAltNames()
	local names = {}
	for _, alt in ipairs(roster) do if alt.online then table.insert(names, alt.name) end end
	return names
end

local pendingTeam
StaticPopupDialogs.SQUIDBOTSLITE_TEAM = {
	text = "%s", button1 = OKAY, button2 = CANCEL, hasEditBox = 1, maxLetters = 24, timeout = 0, whileDead = 1,
	hideOnEscape = 1,
	OnAccept = function(self)
		local box = _G[self:GetName() .. "EditBox"]
		local name = strtrim(box:GetText() or "")
		if name == "" or not pendingTeam then return end
		SquidBotsLiteDB.teams = SquidBotsLiteDB.teams or {}
		SquidBotsLiteDB.teams[name] = pendingTeam
		Print(string.format(L.T_SAVED, name, #pendingTeam))
		pendingTeam = nil
	end,
	EditBoxOnEnterPressed = function(self)
		StaticPopupDialogs.SQUIDBOTSLITE_TEAM.OnAccept(self:GetParent())
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

local function SaveTeam(names)
	if #names == 0 then Print(L.T_EMPTY) return end
	pendingTeam = names
	StaticPopupDialogs.SQUIDBOTSLITE_TEAM.text = L.T_NAME
	StaticPopup_Show("SQUIDBOTSLITE_TEAM")
end

local function TeamsMenu()
	local items = { { text = L.TEAMS, isTitle = true, notCheckable = true } }
	local names = {}
	for name in pairs(SquidBotsLiteDB.teams or {}) do table.insert(names, name) end
	table.sort(names)
	if #names == 0 then table.insert(items, { text = L.T_NONE, notCheckable = true, disabled = true }) end
	for _, name in ipairs(names) do
		local members = TeamNames(name)
		table.insert(items, { text = name, hasArrow = true, notCheckable = true, menuList = {
			{ text = table.concat(members, ", "), notCheckable = true, disabled = true },
			{ text = string.format(L.T_LOGIN, #members), notCheckable = true, func = function()
				QueueBots("add", members)
				Print(string.format(L.T_STARTED, name, #members))
			end },
			{ text = L.T_LOGOUT, notCheckable = true, func = function() QueueBots("remove", members) end },
			{ text = L.T_DELETE, notCheckable = true, func = function() SquidBotsLiteDB.teams[name] = nil end },
		} })
	end
	table.insert(items, { text = L.T_SAVE_GROUP, notCheckable = true, func = function() SaveTeam(GroupNames()) end })
	table.insert(items, { text = L.T_SAVE_ONLINE, notCheckable = true, func = function() SaveTeam(OnlineAltNames()) end })
	ShowMenu(items)
end

-- Linked accounts: ".playerbots account setKey / link / linkedAccounts / unlink" and ".playerbots bot addaccount".
-- The server puts the account name straight into its SQL: the addon sends only letters, digits and _.
local function SafeName(text)
	text = strtrim(text or "")
	if text == "" or text:find("[^%w_]") then Print(L.A_BAD) return end
	return text
end

local function AccountCommand(text)
	SendChatMessage(".playerbots account " .. text, "SAY")
end

local linkStep = {}
StaticPopupDialogs.SQUIDBOTSLITE_ACCOUNT = {
	text = "%s", button1 = OKAY, button2 = CANCEL, hasEditBox = 1, maxLetters = 32, timeout = 0, whileDead = 1,
	hideOnEscape = 1,
	OnAccept = function(self)
		local value = SafeName(_G[self:GetName() .. "EditBox"]:GetText())
		if not value then return end
		if linkStep.kind == "key" then
			AccountCommand("setKey " .. value)
		elseif linkStep.kind == "name" then
			linkStep = { kind = "keyfor", account = value }
			local nextAsk = function()
				StaticPopupDialogs.SQUIDBOTSLITE_ACCOUNT.text = string.format(L.A_KEYFOR, value)
				StaticPopup_Show("SQUIDBOTSLITE_ACCOUNT")
			end
			-- The same dialog cannot show again while it is closing: the next frame asks for the key.
			local f = CreateFrame("Frame")
			f:SetScript("OnUpdate", function(frame) frame:SetScript("OnUpdate", nil); nextAsk() end)
			return
		elseif linkStep.kind == "keyfor" then
			AccountCommand("link " .. linkStep.account .. " " .. value)
			SquidBotsLiteDB.linked = SquidBotsLiteDB.linked or {}
			SquidBotsLiteDB.linked[linkStep.account] = true
		end
		linkStep = {}
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		StaticPopupDialogs.SQUIDBOTSLITE_ACCOUNT.OnAccept(parent)
		parent:Hide()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

local function AskAccount(kind, text)
	linkStep = { kind = kind }
	StaticPopupDialogs.SQUIDBOTSLITE_ACCOUNT.text = text
	StaticPopup_Show("SQUIDBOTSLITE_ACCOUNT")
end

local function AccountsMenu()
	local items = { { text = L.ACCOUNTS, isTitle = true, notCheckable = true } }
	local names = {}
	for name in pairs(SquidBotsLiteDB.linked or {}) do table.insert(names, name) end
	table.sort(names)
	if #names == 0 then table.insert(items, { text = L.A_NONE, notCheckable = true, disabled = true }) end
	for _, name in ipairs(names) do
		table.insert(items, { text = name, hasArrow = true, notCheckable = true, menuList = {
			{ text = L.A_LOGIN_ALL, notCheckable = true, func = function()
				BotCommand("addaccount " .. name)
				refreshAt = GetTime() + AFTER_TOGGLE + 2
			end },
			{ text = L.A_UNLINK, notCheckable = true, func = function()
				AccountCommand("unlink " .. name)
				SquidBotsLiteDB.linked[name] = nil
			end },
		} })
	end
	table.insert(items, { text = L.A_SHOW, notCheckable = true, func = function() AccountCommand("linkedAccounts") end })
	table.insert(items, { text = L.A_LINK, notCheckable = true, func = function() AskAccount("name", L.A_NAME) end })
	table.insert(items, { text = L.A_KEY, notCheckable = true, func = function() AskAccount("key", L.A_MYKEY) end })
	table.insert(items, { text = L.A_HOWTO, notCheckable = true, disabled = true })
	ShowMenu(items)
end

local function TickLogins()
	if #loginQueue == 0 or GetTime() < loginNext then return end
	loginNext = GetTime() + 1
	BotCommand(table.remove(loginQueue, 1))
	if #loginQueue == 0 and altsFrame and altsFrame:IsShown() then refreshAt = GetTime() + AFTER_TOGGLE end
end

local function BuildAlts()
	altsFrame = CreateFrame("Frame", "SquidBotsLiteAlts", UIParent)
	altsFrame:SetWidth(452)
	altsFrame:SetHeight(138 + ALT_ROWS * ALT_ROW_H)
	altsFrame:SetPoint("CENTER")
	altsFrame:SetBackdrop(PANEL_BACKDROP)
	altsFrame:SetBackdropColor(0.04, 0.04, 0.05, 1)
	altsFrame:SetFrameStrata("DIALOG")
	altsFrame:SetMovable(true)
	altsFrame:SetToplevel(true)
	altsFrame:SetScript("OnMouseDown", function() CloseDropDownMenus() end)
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
	altsFrame.teams = CreateFrame("Button", nil, altsFrame, "UIPanelButtonTemplate")
	altsFrame.teams:SetWidth(90)
	altsFrame.teams:SetHeight(20)
	altsFrame.teams:SetPoint("LEFT", altsFrame.refresh, "RIGHT", 6, 0)
	altsFrame.teams:SetScript("OnClick", TeamsMenu)
	altsFrame.accounts = CreateFrame("Button", nil, altsFrame, "UIPanelButtonTemplate")
	altsFrame.accounts:SetWidth(90)
	altsFrame.accounts:SetHeight(20)
	altsFrame.accounts:SetPoint("LEFT", altsFrame.teams, "RIGHT", 6, 0)
	altsFrame.accounts:SetScript("OnClick", AccountsMenu)
	altsFrame.status = altsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	altsFrame.status:SetPoint("TOPLEFT", 18, -62)
	altsFrame.status:SetWidth(390)
	altsFrame.status:SetJustifyH("LEFT")
	altsFrame.status:SetJustifyH("LEFT")
	for i = 1, ALT_ROWS do
		local row = CreateFrame("Frame", nil, altsFrame)
		row:SetWidth(398)
		row:SetHeight(ALT_ROW_H - 2)
		row:SetPoint("TOPLEFT", 16, -80 - (i - 1) * ALT_ROW_H)
		row.dot = row:CreateTexture(nil, "ARTWORK")
		row.dot:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.dot:SetWidth(8)
		row.dot:SetHeight(8)
		row.dot:SetPoint("LEFT", 2, 0)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.name:SetPoint("TOPLEFT", 16, -3)
		row.name:SetWidth(166)
		row.name:SetJustifyH("LEFT")
		row.info = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.info:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
		row.info:SetWidth(168)
		row.info:SetHeight(12)
		row.info:SetJustifyH("LEFT")
		row.xp = CreateFrame("StatusBar", nil, row)
		row.xp:SetWidth(150)
		row.xp:SetHeight(4)
		row.xp:SetPoint("TOPLEFT", row.info, "BOTTOMLEFT", 0, -2)
		row.xp:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		row.xp:SetStatusBarColor(0.58, 0.0, 0.55)
		row.xp:SetMinMaxValues(0, 100)
		row.xp.bg = row.xp:CreateTexture(nil, "BACKGROUND")
		row.xp.bg:SetAllPoints()
		row.xp.bg:SetTexture(0, 0, 0, 0.6)
		-- Rested xp, in blue right after the xp gained, as on the game's own bar.
		row.xp.rest = row.xp:CreateTexture(nil, "ARTWORK")
		row.xp.rest:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
		row.xp.rest:SetVertexColor(0.0, 0.39, 0.88, 0.6)
		row.xp.rest:SetHeight(4)
		row.xp.rest:SetPoint("LEFT", row.xp:GetStatusBarTexture(), "RIGHT", 0, 0)
		row.xp:Hide()
		row.toggle = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.toggle:SetWidth(76)
		row.toggle:SetHeight(18)
		row.toggle:SetPoint("LEFT", 186, 0)
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
		row.sheet = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.sheet:SetWidth(76)
		row.sheet:SetHeight(18)
		row.sheet:SetPoint("LEFT", row.summon, "RIGHT", 4, 0)
		row.sheet.icon = row.sheet:CreateTexture(nil, "OVERLAY")
		row.sheet.icon:SetWidth(14)
		row.sheet.icon:SetHeight(14)
		row.sheet.icon:SetPoint("LEFT", 6, 0)
		row.sheet.icon:SetTexture(SHEET_ICON)
		row.sheet.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		-- A gold glow that breathes until the player has opened a sheet once: the feature is new.
		row.sheet.glow = row.sheet:CreateTexture(nil, "BACKGROUND")
		row.sheet.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
		row.sheet.glow:SetTexCoord(0, 0.75, 0, 0.609375)
		row.sheet.glow:SetBlendMode("ADD")
		row.sheet.glow:SetPoint("TOPLEFT", -10, 8)
		row.sheet.glow:SetPoint("BOTTOMRIGHT", 10, -8)
		row.sheet:SetScript("OnUpdate", function(self)
			if SquidBotsLiteDB.sheetOpened then self.glow:Hide() return end
			self.glow:SetAlpha(0.35 + 0.35 * math.sin(GetTime() * 4))
		end)
		row.sheet:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L.ALTS_SHEET)
			GameTooltip:AddLine(L.TIP_SHEET, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		row.sheet:SetScript("OnLeave", function() GameTooltip:Hide() end)
		row.sheet:SetScript("OnClick", function(self)
			local alt = self:GetParent().alt
			if alt and SquidBotsLite_OpenSheet then
				SquidBotsLiteDB.sheetOpened = true
				SquidBotsLite_OpenSheet(alt.name)
			end
		end)
		-- A logged-in alt's name opens its bot sheet (Manager.lua, beta).
		row:EnableMouse(true)
		row:SetScript("OnEnter", function(self)
			local alt = self.alt
			if not alt then return end
			local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[alt.name] or {}
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(alt.name)
			GameTooltip:AddLine(AltLine(alt.name), 1, 1, 1)
			if info.xp then GameTooltip:AddLine(string.format(L.ALTS_XP, info.xp, info.rest or 0), 0.8, 0.5, 1) end
			if info.gold then GameTooltip:AddLine(string.format(L.ALTS_GOLD, info.gold), 1, 0.82, 0) end
			if alt.linked then GameTooltip:AddLine(L.ALTS_FROM_LINKED, 0.55, 0.55, 0.85, true) end
			GameTooltip:AddLine(L.ALTS_LOOK, 0.6, 0.6, 0.6, true)
			if alt.online and SquidBotsLite_OpenSheet then GameTooltip:AddLine(L.ALTS_TIP_CLICK, 0.4, 0.8, 1) end
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		row:SetScript("OnMouseUp", function(self)
			if self.alt and self.alt.online and SquidBotsLite_OpenSheet then
				SquidBotsLiteDB.sheetOpened = true
				SquidBotsLite_OpenSheet(self.alt.name)
			end
		end)
		row:Hide()
		altRows[i] = row
	end
	altsFrame.scroll = CreateFrame("ScrollFrame", "SquidBotsLiteAltsScroll", altsFrame, "FauxScrollFrameTemplate")
	altsFrame.scroll:SetPoint("TOPLEFT", 16, -80)
	altsFrame.scroll:SetPoint("BOTTOMRIGHT", -32, 60)
	altsFrame.scroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ALT_ROW_H, RefreshAlts)
	end)
	-- Under the rows, so that their buttons still take the clicks; the rows pass the wheel on to it.
	altsFrame.scroll:SetFrameLevel(altsFrame:GetFrameLevel())
	for _, row in ipairs(altRows) do
		row:EnableMouseWheel(true)
		row:SetScript("OnMouseWheel", function(_, delta)
			local bar = _G.SquidBotsLiteAltsScrollScrollBar
			bar:SetValue(bar:GetValue() - delta * ALT_ROW_H)
		end)
	end
	altsFrame.help = altsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	altsFrame.help:SetPoint("BOTTOMLEFT", 16, 14)
	altsFrame.help:SetWidth(398)
	altsFrame.help:SetJustifyH("LEFT")
	altsFrame:Hide()
	AltsTexts()
end

ShowAlts = function()
	altsFrame:Show()
	AskRoster()
end

-- Called with the other refreshes: a new list after a log in / out, a word if the server stays silent.
local readingLinks

local function TickAlts()
	TickLogins()
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
	-- "add: Name - ok" / "addaccount: Name - ok": a character logged in by the player is one of their alts, also
	-- those of a linked account, which "bot list" alone never shows offline.
	local added = message:match("^add%a*: (.-) %- ok$")
	if added then
		SquidBotsLiteDB.alts = SquidBotsLiteDB.alts or {}
		SquidBotsLiteDB.alts[added] = true
		-- Not in the last roster as one of this account's: a character of a linked account.
		local own = false
		for _, alt in ipairs(roster) do if alt.name == added and not alt.linked then own = true end end
		if not own then
			SquidBotsLiteDB.linkedAlts = SquidBotsLiteDB.linkedAlts or {}
			SquidBotsLiteDB.linkedAlts[added] = true
		end
	end
	-- "Linked accounts:" then "- name" lines, or "No linked accounts."
	if message == "No linked accounts." then SquidBotsLiteDB.linked = {} end
	if message == "Linked accounts:" then SquidBotsLiteDB.linked, readingLinks = {}, GetTime() + 2 end
	local linked = readingLinks and GetTime() < readingLinks and message:match("^%- (%S+)$")
	if linked and linked ~= "Unknown" then SquidBotsLiteDB.linked[linked] = true end
	local text = message:match("^Bot roster: ?(.*)$")
	if text and rosterAskedAt then
		-- The chat frames may see this message after this handler: they still hide it for a second.
		rosterAskedAt, hideRosterUntil = nil, GetTime() + 1
		roster = ParseRoster(text)
		RefreshAlts()
		AskAltStats()
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
-- kept out of the chat. Only members known as bots are asked (a bot answer, the "Bot" surname, an alt of
-- this account): a real player of the group would see the whisper (PTR report). /sbl roles off stops it.
local function LooksLikeBot(name)
	return knownBot[name] or name:find(" Bot$") ~= nil or (SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[name])
end

local function ProbeRoles()
	if SquidBotsLiteDB.autoRoles == false then return end
	local now = GetTime()
	for i = 1, 4 do
		local unit = "party" .. i
		local name = UnitName(unit)
		if name and name ~= UNKNOWNOBJECT and not roleByName[name] and not probedAt[name] and UnitIsConnected(unit)
			and LooksLikeBot(name) then
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
	local was = roleByName[sender]
	roleByName[sender] = (list["coa tank"] or list["tank"] or list["bear"]) and "tank"
		or (list["coa heal"] or list["heal"] or list["holy heal"]) and "heal" or "dps"
	knownBot[sender] = true
	if roleByName[sender] == "tank" and was ~= "tank" and (state.passive or not state.autoPull) then
		Whisper(sender, "nc -coa auto pull")
	end
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
	if InStatsWindow(sender) and (message:find(" XP", 1, true) or message:find("^%d+[gsc]")) then
		SquidBotsLite_NoteStats(sender, message)
		RefreshAlts()
		return
	end
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
	-- Too many offers: drop the oldest of the role with the most offers (damage first), so a tank and a healer stay.
	while #toasts > MAX_TOASTS do
		local count = { tank = 0, heal = 0, dps = 0 }
		for _, offer in ipairs(toasts) do count[offer.role] = (count[offer.role] or 0) + 1 end
		local drop = "dps"
		if count.heal > count[drop] then drop = "heal" end
		if count.tank > count[drop] then drop = "tank" end
		for i, offer in ipairs(toasts) do
			if offer.role == drop then table.remove(toasts, i) break end
		end
	end
	if not bar:IsShown() then SetBarShown(true) end
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
-- At login the server says "CoA Bots v1.9.1 (mod-playerbots) ..." (Playerbots.cpp). The addon carries the
-- same number since 1.8: a server ahead of it means a newer addon is out. Said once; an addon-only update
-- (a server still on the older number) cannot be seen this way.
local function VersionParts(text)
	local parts = {}
	for n in (text or ""):gmatch("%d+") do table.insert(parts, tonumber(n)) end
	return parts
end

local function IsOlder(mine, theirs)
	local a, b = VersionParts(mine), VersionParts(theirs)
	for i = 1, math.max(#a, #b) do
		local x, y = a[i] or 0, b[i] or 0
		if x ~= y then return x < y end
	end
	return false
end

local versionWatch = CreateFrame("Frame")
versionWatch:RegisterEvent("CHAT_MSG_SYSTEM")
versionWatch:SetScript("OnEvent", function(self, _, message)
	local plain = (message or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	local server = plain:match("^CoA Bots v(%d[%d%.]*)")
	if not server then return end
	self:UnregisterEvent("CHAT_MSG_SYSTEM")
	server = server:gsub("%.$", "")
	local mine = GetAddOnMetadata("SquidBotsLite", "Version") or "0"
	if L and IsOlder(mine:match("^[%d%.]+") or mine, server) then
		Print(string.format(L.OUTDATED, mine, server))
	end
end)

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "ADDON_LOADED" and arg1 == "SquidBotsLite" then
		SquidBotsLiteDB = SquidBotsLiteDB or {}
		if not SquidBotsLiteCharDB then
			-- First load on this character since 2.0: start from the account-wide place and state of 1.9.
			SquidBotsLiteCharDB = { point = SquidBotsLiteDB.point, hidden = SquidBotsLiteDB.hidden, scale = 1 }
		end
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
			RefreshCompactOverlays()
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

-- The bot sheet (Manager.lua) asks a bot its specialization the same way.
function SquidBotsLite_AskSpecs(name)
	return AskSpecs(name)
end

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
	elseif command == "raidframes" then
		SquidBotsLiteDB.raidFrames = string.lower(rest) ~= "off"
		Print(SquidBotsLiteDB.raidFrames and L.RAIDFRAMES_ON or L.RAIDFRAMES_OFF)
	elseif command == "sheettrade" and SquidBotsLite_SheetOnTrade then
		SquidBotsLite_SheetOnTrade(string.lower(rest) ~= "off")
	elseif command == "sheetdebug" and SquidBotsLite_SheetDebug then
		SquidBotsLite_SheetDebug()
	elseif command == "bot" and SquidBotsLite_OpenSheet then
		SquidBotsLite_OpenSheet(rest)
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
		SquidBotsLiteCharDB.point = nil
		PlaceBar()
		SetBarShown(true)
	elseif command == "show" then
		SetBarShown(true)
	elseif command == "hide" then
		SetBarShown(false)
	elseif command == "scale" or command == "size" then
		local scale = tonumber((string.gsub(rest or "", ",", "."))) -- "1,2" as French players write it
		if rest == "" then
			Print(string.format(L.SCALE_SET, SquidBotsLiteCharDB.scale or 1))
		elseif scale and scale >= SCALE_MIN and scale <= SCALE_MAX then
			SetBarScale(scale)
		else
			Print(L.SCALE_BAD)
		end
	elseif command == "help" or command == "?" then
		Print(L.HELP)
	else
		SetBarShown(not bar:IsShown())
	end
end
