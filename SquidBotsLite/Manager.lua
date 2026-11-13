-- SquidBots Lite, bot sheet (beta): the gear, bags, quests and stats of one bot of the group, for players who
-- keep a long-term party of alts. Everything goes through chat commands a player can whisper to their own
-- bots ("c", "quests all", "stats", "e", "ue", "u", "s", "t", "mount", "bank", "drop", "co ?", "nc ?", "talents ?"); the gear is read
-- by the client's own inspect.

local STRINGS = {
	en = {
		TITLE = "Bot sheet", GEAR = "Gear", BAGS = "Bags", QUESTS = "Quests", INFO = "Info", REFRESH = "Refresh",
		BEST_GEAR = "Best gear", BEST_GEAR_ASK = "%s gets free gear for its level, replacing what it wears. Players who earn their gear may not want this. Sure?",
		BEST_GEAR_TIP = "Free gear for its level from the server, replacing what it wears (cannot be undone). A server can turn it off for alts (AiPlayerbot.AutoGearCommandAltBots = 0).",
		TRADE = "Open trade", FOLLOW = "Follow", STAY = "Stay", SUMMON = "Summon",
		LOGOUT = "Log out", WAIT = "Asking the bot...", WAIT_AGAIN = "Still waiting: asking the bot again...", NO_REPLY = "No answer: is it one of your bots?",
		NOT_IN_GROUP = "Invite it to your group to see its gear.", OUT_OF_RANGE = "Come closer to see its gear.",
		EMPTY_BAGS = "Nothing in the bags.", NO_QUESTS = "No quest.",
		GIVE = "Give it to me", SOULBOUND = "Soulbound: cannot be traded", TRADE_RANGE = "Trade: stand next to the bot (10 yards).", EQUIP = "Equip", USE = "Use", SELL = "Sell (bot next to a vendor)", SELL_GREY = "Sell junk",
		BULK_BTN = "Sell / destroy", BULK_JUNK = "Sell its junk (as before)", BULK_SELL = "Sell its %s items...", BULK_DESTROY = "Destroy its %s items...",
		Q_GREY = "grey", Q_WHITE = "white", BULK_T_SELL = "%s sells these %s items:", BULK_T_DESTROY = "%s destroys these %s items (every stack of each):",
		BULK_H_SELL = "Untick what it keeps. The bot must stand next to a vendor.", BULK_H_DESTROY = "Untick what it keeps. A destroyed item is gone for good.",
		BULK_GO_SELL = "Sell (%d)", BULK_GO_DESTROY = "Destroy (%d)", BULK_NONE = "No %s item in its bags.", BULK_MORE = "+%d more not shown (left alone).",
		BULK_ASKING = "Asking %s for its list...", BULK_SOLD = "%s sold %d items for %s.", BULK_DESTROYED = "%s destroyed %d items.",
		BULK_ERR = "%s: %s.", BULK_R_changed = "its bags changed, open the list again", BULK_R_novendor = "no vendor next to it",
		BULK_R_combat = "in combat", BULK_R_dead = "dead", BULK_R_quality = "quality too high", BULK_R_off = "off on this realm",
		BS_TITLE = "Its bags", BS_FREE = "%d free of %d", BS_EMPTY = "Empty bag slot", BS_PUT = "Put on as a bag", BS_PUT_HERE = "Put %s here",
		BS_NONE = "No bag in its bags to put here.", BS_DONE = "%s put on %s.", BS_ERR = "%s: %s.", BS_R_notfound = "that bag is not in its bags",
		BS_R_notbag = "not a bag", BS_R_nospace = "no room for what the old bag holds", BS_R_combat = "in combat", BS_R_dead = "dead",
		BS_R_off = "off on this realm", BS_HINT = "Click a bag slot to put one of its bags there.",
		BULK_TOOMANY = "Too many unticked items for one order: untick fewer, or sell those one by one.",
		BULK_H_SERVER = "The bot leaves out quest items, what it would wear, what it keeps and what has a use.",
		NO_VENDOR = "Nothing sold: the bot sells only standing right next to a vendor (Summon it there, or walk it there with Follow).", LINK = "Link in chat",
		UNEQUIP = "Unequip", ITEM_HINT = "Click an item for what to do with it. Shift-click: link it in chat.",
		GEAR_HINT = "Right-click a piece to take it off.",
		CMP_WORN = "Worn by %s", CMP_ILVL = "Item level %s compared with what %s wears (%d)", CMP_NONE = "%s: nothing known in that slot (Gear tab, in range).",
		CMP_LEVEL = "%s is level %d: this needs %d.", CMP_ASKING = "Asking %s...", CMP_V_equip = "Upgrade for %s: that slot is empty.",
		CMP_V_replace = "Upgrade for %s%s", CMP_V_bad = "Worse than what %s wears%s", CMP_V_cannot = "%s cannot use this.",
		CMP_SCORE = "Score: this one %s, worn %s", CMP_NOTFOUND = "%s: unknown item.", CMP_NOANSWER = "%s did not answer: compared from the group.", TRADE_HINT = "Give it to me opens a trade with the bot: accept it.",
		MOUNTS = "Mounts", AUTO_MOUNT = "Automatic choice", PREFERRED = "preferred",
		PETS = "Pets", PET_CAT_loot = "Loot", PET_CAT_quest = "Quests", PET_CAT_class = "Class trainer",
		PET_CAT_craft = "Professions", PETS_FAV = "Favourite", PETS_USE = "Use", PETS_DISMISS = "Dismiss",
		PETS_AUTO = "Uses them by itself", PETS_IS_FAV = "favourite", PETS_IS_OUT = "out", PETS_UNKNOWN = "not learned",
		PETS_HINT = "One favourite per use: the alt summons it by itself when needed (loot out of combat, class and profession books when it can learn something). Use calls it now.",
		PETS_NO_CMD = "No answer: this realm's CoA Bots has no pet command yet (3.0 or later).", PETS_ERR = "Refused: %s.", PETS_ERR_unknown = "this alt does not know that companion", PETS_ERR_dead = "the alt is dead",
		PETS_ERR_combat = "in combat", PETS_ERR_mounted = "mounted", PETS_ERR_raid = "no loot pet in a raid", PETS_ERR_cast = "the summon failed",
		FOR_GROUND = "favourite on the ground", FOR_FLYING = "favourite in the air",
		MOUNT_SEARCH = "Search a mount...", MOUNT_NONE = "No mount matches \"%s\".",
		GROUND = "ground", FLYING = "flying", BOTH = "ground and flying",
		MOUNT_ALL = "All", MOUNT_F_GROUND = "Ground", MOUNT_F_FLYING = "Flying", MOUNT_COUNT = "%d mounts",
		MOUNT_FAVS = "Favourites:  %s on the ground,  %s in the air", MOUNT_AUTO_WORD = "automatic",
		MOUNT_HINT = "Click a mount: your bot rides it from now on. One ground and one flying favourite; a ground-and-flying mount is both. Automatic choice: the bot picks again.",
		NO_MOUNT_CMD = "No answer: this server's CoA Bots has no mount command yet (2.1 or later).",
		NO_MOUNTS = "No mount known: give this alt a mount, it rides when you ride.",
		LOOT_PET = "Loot pet", BACK_MOUNTS = "Mounts", PET_AUTO = "Automatic choice", PET_OFF = "No pet",
		PET_SEARCH = "Search a companion...", PET_NONE = "No companion matches \"%s\".", PET_LOOTS = "loots by itself",
		PET_FAV = "favourite", NO_PETS = "No companion known: give this alt one (or Lootbot 3000).",
		NO_PET_CMD = "No answer: this realm's CoA Bots has no loot pet yet (2.9.5 or later).",
		PET_IS_OFF = "This alt summons no companion. Automatic choice turns it back on.",
		PET_HINT = "Click a companion: this alt summons it out of combat. Lootbot 3000 and the Kleptomanic Demon loot by themselves. The realm needs AiPlayerbot.AltLootCompanion = 1.",
		TIP_LOOT_PET = "The companion this alt summons out of combat, and that loots for it when it can.",
		PET_APP = "Loot-Transfigurator on: any companion loots. Shift-click one (your spellbook's companions, a link in the chat) into the box, or type its spell id, then Enter.",
		USAGE = "/sbl bot <name>, or target a bot of your group and type /sbl bot.",
		READ_ONLY = "read only", READ_ONLY_NO = "Read-only sheet: this bot is not one of your characters.",
		NOT_A_MEMBER = "%s is not in your group.",
		STRATS = "Strategies", COMBAT = "In combat", NONCOMBAT = "Out of combat", ADD = "Add...",
		STRAT_HINT = "Click a strategy to remove it; Add... to give one. The server resets them on a specialization switch.",
		BANK = "Bank", BAGS_BTN = "Bags", DEPOSIT = "Put in the bank", DESTROY = "Destroy", DESTROY_ASK = "%s destroys %s (every stack of it in its bags). Sure?", WITHDRAW = "Take from the bank",
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
		BEST_GEAR = "Meilleur équipement", BEST_GEAR_ASK = "%s reçoit un équipement gratuit de son niveau, à la place de ce qu'il porte. Les joueurs qui gagnent leur équipement n'en voudront peut-être pas. Sûr ?",
		BEST_GEAR_TIP = "Équipement gratuit de son niveau donné par le serveur, à la place de ce qu'il porte (impossible à annuler). Un serveur peut le désactiver pour les alts (AiPlayerbot.AutoGearCommandAltBots = 0).",
		TRADE = "Ouvrir l'échange", FOLLOW = "Suivre", STAY = "Rester", SUMMON = "Appeler",
		LOGOUT = "Déconnecter", WAIT = "Demande au bot...", WAIT_AGAIN = "Toujours en attente : je redemande au bot...", NO_REPLY = "Pas de réponse : est-ce bien un de vos bots ?",
		NOT_IN_GROUP = "Invitez-le dans votre groupe pour voir son équipement.", OUT_OF_RANGE = "Approchez-vous pour voir son équipement.",
		EMPTY_BAGS = "Rien dans les sacs.", NO_QUESTS = "Aucune quête.",
		GIVE = "Me le donner", SOULBOUND = "Lié : impossible à échanger", TRADE_RANGE = "Échange : placez-vous à côté du bot (10 mètres).", EQUIP = "Équiper", USE = "Utiliser", SELL = "Vendre (bot à côté d'un marchand)", SELL_GREY = "Vendre la camelote",
		BULK_BTN = "Vendre / détruire", BULK_JUNK = "Vendre sa camelote (comme avant)", BULK_SELL = "Vendre ses objets %s...", BULK_DESTROY = "Détruire ses objets %s...",
		Q_GREY = "gris", Q_WHITE = "blancs", BULK_T_SELL = "%s vend ces objets %s :", BULK_T_DESTROY = "%s détruit ces objets %s (toutes les piles de chacun) :",
		BULK_H_SELL = "Décochez ce qu'il garde. Le bot doit se tenir à côté d'un marchand.", BULK_H_DESTROY = "Décochez ce qu'il garde. Un objet détruit est perdu pour de bon.",
		BULK_GO_SELL = "Vendre (%d)", BULK_GO_DESTROY = "Détruire (%d)", BULK_NONE = "Aucun objet %s dans ses sacs.", BULK_MORE = "+%d autres non affichés (laissés tels quels).",
		BULK_ASKING = "Demande de sa liste à %s...", BULK_SOLD = "%s a vendu %d objets pour %s.", BULK_DESTROYED = "%s a détruit %d objets.",
		BULK_ERR = "%s : %s.", BULK_R_changed = "ses sacs ont changé, rouvrez la liste", BULK_R_novendor = "aucun marchand à côté de lui",
		BULK_R_combat = "en combat", BULK_R_dead = "mort", BULK_R_quality = "qualité trop haute", BULK_R_off = "coupé sur ce royaume",
		BS_TITLE = "Ses sacs", BS_FREE = "%d libres sur %d", BS_EMPTY = "Emplacement de sac vide", BS_PUT = "Mettre comme sac", BS_PUT_HERE = "Mettre %s ici",
		BS_NONE = "Aucun sac dans ses sacs à mettre ici.", BS_DONE = "%s a mis %s.", BS_ERR = "%s : %s.", BS_R_notfound = "ce sac n'est pas dans ses sacs",
		BS_R_notbag = "ce n'est pas un sac", BS_R_nospace = "pas de place pour ce que contient l'ancien sac", BS_R_combat = "en combat", BS_R_dead = "mort",
		BS_R_off = "coupé sur ce royaume", BS_HINT = "Cliquez sur un emplacement de sac pour y mettre un de ses sacs.",
		BULK_TOOMANY = "Trop d'objets décochés pour un seul ordre : décochez-en moins, ou vendez-les un par un.",
		BULK_H_SERVER = "Le bot laisse de côté les objets de quête, ce qu'il porterait, ce qu'il garde et ce qui s'utilise.",
		NO_VENDOR = "Rien vendu : le bot ne vend que collé à un marchand (appelez-le devant le marchand, ou amenez-le avec Suivre).", LINK = "Lien dans le chat",
		UNEQUIP = "Retirer", ITEM_HINT = "Cliquez un objet pour choisir quoi en faire. Maj-clic : lien dans le chat.",
		GEAR_HINT = "Clic droit sur une pièce pour la retirer.",
		CMP_WORN = "Porté par %s", CMP_ILVL = "Niveau d'objet %s par rapport à ce que porte %s (%d)", CMP_NONE = "%s : rien de connu à cet emplacement (onglet Équipement, à portée).",
		CMP_LEVEL = "%s est niveau %d : il faut le niveau %d.", CMP_ASKING = "Question à %s...", CMP_V_equip = "Mieux pour %s : cet emplacement est vide.",
		CMP_V_replace = "Mieux pour %s%s", CMP_V_bad = "Moins bien que ce que porte %s%s", CMP_V_cannot = "%s ne peut pas l'utiliser.",
		CMP_SCORE = "Score : celui-ci %s, porté %s", CMP_NOTFOUND = "%s : objet inconnu.", CMP_NOANSWER = "%s n'a pas répondu : comparé depuis le groupe.", TRADE_HINT = "Me le donner ouvre un échange avec le bot : acceptez-le.",
		MOUNTS = "Montures", AUTO_MOUNT = "Choix automatique", PREFERRED = "préférée",
		PETS = "Familiers", PET_CAT_loot = "Butin", PET_CAT_quest = "Quêtes", PET_CAT_class = "Maître de classe",
		PET_CAT_craft = "Métiers", PETS_FAV = "Favori", PETS_USE = "Sortir", PETS_DISMISS = "Renvoyer",
		PETS_AUTO = "Les utilise tout seul", PETS_IS_FAV = "favori", PETS_IS_OUT = "sorti", PETS_UNKNOWN = "pas appris",
		PETS_HINT = "Un favori par usage : l'alt le sort tout seul au besoin (butin hors combat, livres de classe et de métiers quand il peut apprendre). Sortir l'appelle maintenant.",
		PETS_NO_CMD = "Pas de réponse : le CoA Bots de ce royaume n'a pas encore la commande pet (3.0 ou plus).", PETS_ERR = "Refusé : %s.", PETS_ERR_unknown = "cet alt ne connaît pas cette mascotte", PETS_ERR_dead = "l'alt est mort",
		PETS_ERR_combat = "en combat", PETS_ERR_mounted = "sur sa monture", PETS_ERR_raid = "pas de familier de butin en raid", PETS_ERR_cast = "l'invocation a échoué",
		FOR_GROUND = "préférée au sol", FOR_FLYING = "préférée en vol",
		MOUNT_SEARCH = "Chercher une monture...", MOUNT_NONE = "Aucune monture ne correspond à « %s ».",
		GROUND = "sol", FLYING = "vol", BOTH = "sol et vol",
		MOUNT_ALL = "Toutes", MOUNT_F_GROUND = "Sol", MOUNT_F_FLYING = "Vol", MOUNT_COUNT = "%d montures",
		MOUNT_FAVS = "Préférées :  %s au sol,  %s en vol", MOUNT_AUTO_WORD = "automatique",
		MOUNT_HINT = "Cliquez une monture : votre bot la prend désormais. Une préférée au sol, une en vol ; une monture sol et vol compte pour les deux. Choix automatique : le bot choisit à nouveau.",
		NO_MOUNT_CMD = "Pas de réponse : le CoA Bots de ce serveur n'a pas encore la commande des montures (2.1 ou plus).",
		NO_MOUNTS = "Aucune monture connue : donnez une monture à cet alt, il monte quand vous montez.",
		LOOT_PET = "Familier de butin", BACK_MOUNTS = "Montures", PET_AUTO = "Choix automatique", PET_OFF = "Aucun familier",
		PET_SEARCH = "Chercher une mascotte...", PET_NONE = "Aucune mascotte ne correspond à « %s ».", PET_LOOTS = "ramasse seul",
		PET_FAV = "préférée", NO_PETS = "Aucune mascotte connue : donnez-en une à cet alt (ou Lootbot 3000).",
		NO_PET_CMD = "Pas de réponse : le CoA Bots de ce royaume n'a pas encore le familier de butin (2.9.5 ou plus).",
		PET_IS_OFF = "Cet alt n'invoque aucune mascotte. Choix automatique le remet.",
		PET_HINT = "Cliquez une mascotte : cet alt l'invoque hors combat. Lootbot 3000 et le Démon kleptomane ramassent seuls. Le royaume doit avoir AiPlayerbot.AltLootCompanion = 1.",
		TIP_LOOT_PET = "La mascotte que cet alt invoque hors combat, et qui ramasse pour lui quand elle sait le faire.",
		PET_APP = "Loot-Transfigurator actif : toute mascotte ramasse. Maj-clic sur une mascotte (mascottes du grimoire, lien du chat) dans la case, ou tapez son id de sort, puis Entrée.",
		USAGE = "/sbl bot <nom>, ou ciblez un bot de votre groupe et tapez /sbl bot.",
		READ_ONLY = "lecture seule", READ_ONLY_NO = "Fiche en lecture seule : ce bot n'est pas un de vos personnages.",
		NOT_A_MEMBER = "%s n'est pas dans votre groupe.",
		STRATS = "Stratégies", COMBAT = "En combat", NONCOMBAT = "Hors combat", ADD = "Ajouter...",
		STRAT_HINT = "Cliquez une stratégie pour la retirer ; Ajouter... pour en donner une. Le serveur les remet à zéro à un changement de spé.",
		BANK = "Banque", BAGS_BTN = "Sacs", DEPOSIT = "Mettre à la banque", DESTROY = "Détruire", DESTROY_ASK = "%s détruit %s (toutes les piles dans ses sacs). Sûr ?", WITHDRAW = "Reprendre de la banque",
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
local BAG_COLS, BAG_ROWS, QUEST_ROWS, MOUNT_ROWS = 8, 6, 14, 12
-- Inventory slot ids of the 3.3.5 client, left column, right column, then weapons.
local GEAR_LEFT = { 1, 2, 3, 15, 5, 4, 19, 9 }
local GEAR_RIGHT = { 10, 6, 7, 8, 11, 12, 13, 14 }
local GEAR_BOTTOM = { 16, 17, 18 }

local COMBAT_STRATS = { "avoid aoe", "behind", "threat", "dps aoe", "focus", "passive", "aggressive", "wait for attack",
	"tank face", "mark rti", "pull back", "potions", "racials", "flee", "kite" }
local NONCOMBAT_STRATS = { "follow", "stay", "grind", "loot", "gather", "food", "quest", "accept all quests", "rpg",
	"travel", "mount", "buff", "maintenance", "ready check", "emote", "chat", "duel", "sit" }

local sheet, current, tab
-- 3.0: a sheet opened read only (a random bot of the group, from its sheet icon): its own tabs only, and only the
-- questions below are whispered; any order is refused with a line in the chat.
local readOnly = { on = false, HIDDEN = { bags = true, mounts = true, pets = true },
	ASK = { ["stats"] = true, ["quests all"] = true, ["talents ?"] = true, ["talents tree"] = true, ["co ?"] = true, ["nc ?"] = true } }
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
-- 3.0: the Mounts tab's filter: "all", "ground" or "flying" (the loot pet moved to the Pets tab).
local mountKind = "all"

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Manager|r: " .. text)
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
	if readOnly.on and not readOnly.ASK[text] then
		Print(T("READ_ONLY_NO"))
		return
	end
	hideFrom[current] = GetTime() + QUIET + 1
	SquidBotsLite_QuietWhisper(text, current)
end

-- ---------------------------------------------------------------------------
-- Listings: "c", "quests all", "stats" come back as one whisper per line
-- ---------------------------------------------------------------------------
local Render
-- 3.1: whether an item is an upgrade for the sheet's alt, by its own answer (the compare block, further down).
local IconVerdict

-- A request too soon after the same one (the server would drop its lines) waits its turn instead of being lost.
local later = {}
local function Ask(kind, command)
	if not current then return end
	if capture then
		for _, q in ipairs(queue) do if q.kind == kind then return end end
		table.insert(queue, { kind = kind, command = command })
		return
	end
	local key = current .. ":" .. kind
	if lastAsked[key] and GetTime() - lastAsked[key] < REPEAT_DELAY then
		later[kind] = { name = current, command = command, at = lastAsked[key] + REPEAT_DELAY }
		sheet.status:SetText(T("WAIT"))
		return
	end
	lastAsked[key] = GetTime()
	capture = { name = current, kind = kind, command = command, lines = {}, started = GetTime(), last = GetTime() }
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
	-- Silent the first time (a bot just logged in, a busy server): asked once more before saying so.
	if #done.lines == 0 and not done.retried and done.name == current and done.command then
		capture = { name = done.name, kind = done.kind, command = done.command, lines = {}, started = GetTime(),
			last = GetTime(), retried = true }
		sheet.status:SetText(T("WAIT_AGAIN"))
		Whisper(done.command)
		return
	end
	hideFrom[done.name] = GetTime() + 1
	if done.name ~= current then
		-- Another bot's answer: the sheet's own questions (queued meanwhile) go on.
		sheet.status:SetText("")
		local nextOne = table.remove(queue, 1)
		if nextOne then Ask(nextOne.kind, nextOne.command) end
		return
	end
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
			elseif (capture.kind == "co" or capture.kind == "nc") and message:find("^Strategies:") then Finish()
			-- CoA Bots 2.9.4 ends the bags and the bank with "Items: N": no need to wait for the quiet.
			elseif (capture.kind == "bags" or capture.kind == "bank") and message:find("^Items: %d+") then Finish() end
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
	local now = GetTime()
	if capture then
		if (#capture.lines > 0 and now - capture.last > QUIET) or now - capture.started > GIVE_UP then
			Finish()
		end
	end
	for kind, q in pairs(later) do
		if q.name ~= current then
			later[kind] = nil
		elseif not capture and now >= q.at then
			later[kind] = nil
			Ask(kind, q.command)
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

-- "t [item]" opens a trade with the master first, and puts the item in only once the trade is open. On an item
-- already in the trade, "t" takes it back out: it is sent again only while the item is not on the bot's side.
local function InTrade(link)
	local id = link:match("item:(%d+)")
	for i = 1, 6 do
		local l = GetTradeTargetItemLink(i)
		if l and l:match("item:(%d+)") == id then return true end
	end
end
local giveAt
local function Give(link)
	local unit = UnitOf(current)
	if not unit or not CheckInteractDistance(unit, 2) then
		Print(T("TRADE_RANGE"))
		return
	end
	if TradeFrame:IsShown() then
		if not InTrade(link) then Whisper("t " .. link) end
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
		if not InTrade(link) then Whisper("t " .. link) end
	end
end)

-- An item sold, destroyed or moved leaves the list at once (2.9.4); a sale the bot does not make puts it back.
local function TakeOut(list, item)
	for i, other in ipairs(list) do
		if other == item then
			table.remove(list, i)
			if Render then Render() end
			return i
		end
	end
end

local sellCheck, AfterChange
-- One item: silence means no vendor. "gray" with nothing grey is silent too, so it is not checked.
local function Sell(text, unchecked, item)
	Whisper("s " .. text)
	if not unchecked then
		sellCheck = { name = current, at = GetTime() + 3, item = item, list = bags, index = item and TakeOut(bags, item) }
	end
end
local sellWatch = CreateFrame("Frame")
sellWatch:RegisterEvent("CHAT_MSG_WHISPER")
sellWatch:SetScript("OnEvent", function(_, _, message, sender)
	if not sellCheck or sender ~= sellCheck.name then return end
	-- Sold: the bags are asked again now. On its way to the vendor it targets: more time.
	if message:find("^Selling ") or message:find("^Sold ") then
		sellCheck = nil
		AfterChange()
	elseif message:find("^Going to ") then
		sellCheck.at = GetTime() + 20
	end
end)
sellWatch:SetScript("OnUpdate", function()
	if sellCheck and GetTime() >= sellCheck.at then
		local check = sellCheck
		sellCheck = nil
		-- Not sold: the item comes back, unless the list was asked again since (it is right then).
		if check.index and check.name == current and bags == check.list then
			table.insert(bags, math.min(check.index, #bags + 1), check.item)
			if Render then Render() end
		end
		Print(T("NO_VENDOR"))
	end
end)

function AfterChange()
	-- The bags changed: ask again once the server lets the same lines through, counted from the last listing
	-- (Ask queues it otherwise); a short moment first, for the bot to act on the order.
	local name = current
	local again = CreateFrame("Frame")
	local wait = 0
	again:SetScript("OnUpdate", function(self, delta)
		wait = wait + delta
		if wait < 0.4 then return end
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

-- From a menu or a click on the sheet no chat box is open, and ChatEdit_InsertLink drops the link: the chat opens with it.
local function InsertLink(link)
	if not link or link == "" then return end
	if not ChatEdit_InsertLink(link) then ChatFrame_OpenChat(link) end
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
		and ((SquidBotsLite_IsBot and SquidBotsLite_IsBot(partner)) or (SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[partner])) then
		tab = "bags"
		SquidBotsLite_OpenSheet(partner)
	end
end)

StaticPopupDialogs.SQUIDBOTSLITE_DESTROY = {
	text = "%s", button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
	OnAccept = function(self)
		Whisper("destroy " .. self.data)
		if self.item then TakeOut(bags, self.item) end
		AfterChange()
	end,
}
-- "autogear" makes new gear on the server: a click by mistake cannot be taken back, so it is asked first.
StaticPopupDialogs.SQUIDBOTSLITE_AUTOGEAR = {
	text = "%s", button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
	OnAccept = function()
		Whisper("autogear")
		AfterChange()
	end,
}
local function Destroy(item, link)
	StaticPopupDialogs.SQUIDBOTSLITE_DESTROY.text = string.format(T("DESTROY_ASK"), current, item.link)
	local dialog = StaticPopup_Show("SQUIDBOTSLITE_DESTROY")
	if dialog then dialog.data, dialog.item = link, item end
end

-- 3.1: sell or destroy an alt's grey or white items at once, from a list where each one can be unticked first.
-- The bot's own commands take several links in one whisper ("s <links>", "destroy <links>"): sent in short
-- batches, 1.1 s apart.
-- 3.1: the alt answers for itself (CoA Bots 3.1 with AiPlayerbot.CoaAltBags.Enable, HELLO's 6th field): its own
-- verdict on an item, and the bag lists it would sell or destroy. Only the account's alts; otherwise the addon alone
-- of the addon alone (the Gear tab's view, "s"/"destroy" with links).
local function AltBags(name)
	local A = SquidBotsLite_Alts
	return name and A and A.hello and A.hello.bags and A.IsAlt and A.IsAlt(name) and A.Send and true or false
end

local Bulk
do
	local QUALITY = { grey = "^|cff9d9d9d", white = "^|cffffffff" }
	local COLS, PER_COL = 3, 16
	local queue, nextAt = {}, 0
	local pump = CreateFrame("Frame")
	pump:SetScript("OnUpdate", function()
		if #queue == 0 or GetTime() < nextAt then return end
		-- To the bot the list was made for, even if another sheet opened meanwhile.
		local q, shown = table.remove(queue, 1), current
		current = q.name
		Whisper(q.text)
		current = shown
		nextAt = GetTime() + 1.1
	end)
	local function Batches(word, links)
		local line
		for _, link in ipairs(links) do
			if line and #line + 1 + #link > 250 then table.insert(queue, { name = current, text = line }); line = nil end
			line = line and (line .. " " .. link) or (word .. " " .. link)
		end
		if line then table.insert(queue, { name = current, text = line }) end
	end
	local f
	local function Count()
		local n = 0
		for _, row in ipairs(f.rows) do if row:IsShown() and row:GetChecked() then n = n + 1 end end
		f.go:SetText(string.format(T(f.action == "sell" and "BULK_GO_SELL" or "BULK_GO_DESTROY"), n))
		if n > 0 then f.go:Enable() else f.go:Disable() end
	end
	local function Build()
		f = CreateFrame("Frame", "SquidBotsLiteBulk", UIParent)
		f:SetWidth(COLS * 196 + 24)
		f:SetHeight(PER_COL * 20 + 110)
		f:SetPoint("CENTER")
		f:SetFrameStrata("DIALOG")
		f:SetBackdrop(BACKDROP)
		f:SetBackdropColor(0, 0, 0, 0.92)
		f:EnableMouse(true)
		table.insert(UISpecialFrames, "SquidBotsLiteBulk")
		f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		f.title:SetPoint("TOPLEFT", 16, -16)
		f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		f.hint:SetPoint("TOPLEFT", 16, -34)
		f.more = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		f.more:SetPoint("BOTTOMLEFT", 16, 44)
		f.rows = {}
		for i = 1, COLS * PER_COL do
			local row = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
			row:SetWidth(20)
			row:SetHeight(20)
			row:SetPoint("TOPLEFT", 12 + math.floor((i - 1) / PER_COL) * 196, -52 - ((i - 1) % PER_COL) * 20)
			row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			row.label:SetPoint("LEFT", row, "RIGHT", 2, 0)
			row.label:SetWidth(170)
			row.label:SetHeight(18)
			row.label:SetJustifyH("LEFT")
			row:SetScript("OnClick", Count)
			row:SetScript("OnEnter", function(self)
				if not self.item then return end
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(self.item.link:match("|H(item:[^|]+)|h"))
				GameTooltip:Show()
			end)
			row:SetScript("OnLeave", function() GameTooltip:Hide() end)
			f.rows[i] = row
		end
		f.go = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		f.go:SetWidth(120)
		f.go:SetHeight(22)
		f.go:SetPoint("BOTTOMRIGHT", -140, 16)
		f.go:SetScript("OnClick", function()
			if f.server then
				-- The token covers the whole preview: what is unticked or not shown is skipped.
				local skip = {}
				for i, item in ipairs(f.server.items) do
					local row = f.rows[i]
					if not (row and row:IsShown() and row:GetChecked()) then table.insert(skip, item.bag .. ":" .. item.slot) end
				end
				local q = f.server.quality
				local text = f.action .. " " .. q .. " " .. f.server.token .. (#skip > 0 and (" skip " .. table.concat(skip, ",")) or "")
				if #text > 250 then Print(T("BULK_TOOMANY")) return end
				SquidBotsLite_Alts.Send(f.server.name, text)
				f:Hide()
				return
			end
			local links = {}
			for _, row in ipairs(f.rows) do
				if row:IsShown() and row:GetChecked() and row.item then
					table.insert(links, SendableLink(row.item))
					TakeOut(bags, row.item)
				end
			end
			Batches(f.action == "sell" and "s" or "destroy", links)
			f:Hide()
			AfterChange()
		end)
		f.cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		f.cancel:SetWidth(120)
		f.cancel:SetHeight(22)
		f.cancel:SetPoint("BOTTOMRIGHT", -16, 16)
		f.cancel:SetText(CANCEL or "Cancel")
		f.cancel:SetScript("OnClick", function() f:Hide() end)
	end
	local function Fill(action, word, list, server, name)
		if not f then Build() end
		f.action, f.server = action, server
		f.title:SetText(string.format(T(action == "sell" and "BULK_T_SELL" or "BULK_T_DESTROY"), name or "?", word))
		f.hint:SetText(T(action == "sell" and "BULK_H_SELL" or "BULK_H_DESTROY") .. (server and (" " .. T("BULK_H_SERVER")) or ""))
		for i, row in ipairs(f.rows) do
			local item = list[i]
			row.item = item
			if item then
				row.label:SetText(item.link .. (item.count and item.count > 1 and (" x" .. item.count) or ""))
				row:SetChecked(true)
				row:Show()
			else
				row:Hide()
			end
		end
		f.more:SetText(#list > #f.rows and string.format(T("BULK_MORE"), #list - #f.rows) or "")
		Count()
		f:Show()
	end
	-- The alt's preview ("alt bags <q> [destroy]"): BAGS it ..., BAGS sum ... <token>, BAGS -.
	local preview
	local Q = { grey = 0, white = 1 }
	local function LinkOf(id, quality, name)
		local _, link = GetItemInfo(id)
		if link then return link end
		local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
		return (color and color.hex or "|cffffffff") .. "|Hitem:" .. id .. ":0:0:0:0:0:0:0:0|h[" .. (name ~= "" and name or ("#" .. id)) .. "]|h|r"
	end
	local function Bulk_OnLine(name, f)
		local kind = f[2]
		if kind == "it" and preview and preview.name == name then
			local id, quality = tonumber(f[5]) or 0, tonumber(f[7]) or 0
			table.insert(preview.items, { bag = f[3], slot = f[4], id = id, count = tonumber(f[6]) or 1, quality = quality,
				price = tonumber(f[8]) or 0, link = LinkOf(id, quality, f[9] or "") })
		elseif kind == "sum" and preview and preview.name == name then
			preview.token = f[5]
		elseif kind == "done" then
			if f[3] == "sell" then
				Print(string.format(T("BULK_SOLD"), name, tonumber(f[4]) or 0, GetCoinTextureString and GetCoinTextureString(tonumber(f[5]) or 0) or (f[5] or "0")))
			else
				Print(string.format(T("BULK_DESTROYED"), name, tonumber(f[4]) or 0))
			end
			if name == current then AfterChange() end
		elseif kind == "err" then
			if preview and preview.name == name then preview = nil end
			Print(string.format(T("BULK_ERR"), name, T("BULK_R_" .. (f[3] or "")) or f[3] or "?"))
		elseif kind == "-" and preview and preview.name == name then
			local p = preview
			preview = nil
			if not p.token then return end
			if #p.items == 0 then Print(string.format(T("BULK_NONE"), p.word)) return end
			Fill(p.action, p.word, p.items, p, name)
		end
	end
	-- action: "sell" or "destroy"; quality: "grey" or "white".
	Bulk = function(action, quality)
		local word = T(quality == "grey" and "Q_GREY" or "Q_WHITE")
		if AltBags(current) then
			preview = { name = current, action = action, quality = Q[quality], word = word, items = {} }
			Print(string.format(T("BULK_ASKING"), current))
			-- Alts.lua loads after this file: its handler table is there by now.
			SquidBotsLite_Alts.Handle.BAGS = Bulk_OnLine
			SquidBotsLite_Alts.Send(current, "bags " .. Q[quality] .. (action == "destroy" and " destroy" or ""))
			return
		end
		local list = {}
		for _, item in ipairs(bags) do
			if item.link and item.link:find(QUALITY[quality]) then table.insert(list, item) end
		end
		if #list == 0 then Print(string.format(T("BULK_NONE"), word)) return end
		Fill(action, word, list, nil, current)
	end
end

-- 3.1: an alt's four bags (CoA Bots 3.1, alt bags on): "bagslots" gives each one (BAGSLOT slot <1..4> <id|0>
-- <size> <free> <itemString|-> bagslots, then "BAGSLOT - bagslots"); "bagequip <itemString> [<1..4>]" puts one of
-- its bags on (BAGSLOT done <slot> <id> <req> or BAGSLOT err <reason> <req>, then "BAGSLOT - <req>").
local BagSlots = { by = {}, ASK_EVERY = 30 }
function BagSlots.Shown()
	return AltBags(current) and bagMode ~= "bank"
end
function BagSlots.Ask(force)
	if not AltBags(current) then return end
	local d = BagSlots.by[current]
	-- Asked again every ASK_EVERY seconds at most; an unanswered question (older server) after 10 s.
	if not force and d and GetTime() - d.at < (d.asking and 10 or BagSlots.ASK_EVERY) then return end
	BagSlots.by[current] = { at = GetTime(), asking = true, got = d and d.got or {} }
	SquidBotsLite_Alts.Handle.BAGSLOT = BagSlots.OnLine
	SquidBotsLite_Alts.Send(current, "bagslots")
end
function BagSlots.Equip(name, str, slot)
	BagSlots.pending = BagSlots.pending or {}
	BagSlots.pending[tonumber(str:match("item:(%d+)")) or 0] = { name = name, str = str }
	SquidBotsLite_Alts.Handle.BAGSLOT = BagSlots.OnLine
	SquidBotsLite_Alts.Send(name, "bagequip " .. str .. (slot and (" " .. slot) or ""))
end
function BagSlots.OnLine(name, f)
	if f[2] == "slot" then
		local d = BagSlots.by[name]
		local slot = tonumber(f[3] or "")
		if not d or not slot then return end
		d.new = d.new or {}
		d.new[slot] = { id = tonumber(f[4]) or 0, size = tonumber(f[5]) or 0, free = tonumber(f[6]) or 0, str = f[7] ~= "-" and f[7] or nil }
	elseif f[2] == "done" or f[2] == "err" then
		local req = tonumber(f[2] == "done" and f[5] or f[4] or "")
		local p = BagSlots.pending and BagSlots.pending[req or 0]
		if f[2] == "done" then
			local bag = p and (select(2, GetItemInfo(p.str)) or p.str) or ("item " .. (f[4] or "?"))
			Print(string.format(T("BS_DONE"), name, bag))
		else
			local why = T("BS_R_" .. (f[3] or "")) or f[3] or "?"
			Print(string.format(T("BS_ERR"), name, why))
		end
	elseif f[2] == "-" then
		if f[3] == "bagslots" then
			local d = BagSlots.by[name]
			if not d then return end
			d.got, d.new, d.asking, d.at = d.new or d.got, nil, false, GetTime()
		else
			local req = tonumber(f[3] or "")
			if BagSlots.pending and req then BagSlots.pending[req] = nil end
			-- After a change: its four bags and its bag list again.
			if name == current then
				BagSlots.Ask(true)
				Ask("bags", "c")
			end
		end
		if name == current and Render then Render() end
	end
end
-- A bag slot clicked: one of the alt's bags to put there.
function BagSlots.Menu(slot)
	local items = { { text = T("BS_TITLE"), isTitle = true, notCheckable = true } }
	for _, item in ipairs(bags) do
		local loc = select(9, GetItemInfo(item.link))
		if loc == "INVTYPE_BAG" then
			local str = item.link:match("|H(item:[^|]+)|h")
			table.insert(items, { text = string.format(T("BS_PUT_HERE"), item.link), notCheckable = true,
				func = function() BagSlots.Equip(current, str, slot) end })
		end
	end
	if #items == 1 then
		Print(T("BS_NONE"))
		return
	end
	EasyMenu(items, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
end

local function ItemMenu(item)
	local link = SendableLink(item)
	if bagMode == "bank" then
		EasyMenu({
			{ text = item.link, isTitle = true, notCheckable = true },
			{ text = T("WITHDRAW"), notCheckable = true, func = function() Whisper("bank -" .. link); TakeOut(bank, item); AfterChange() end },
			{ text = T("LINK"), notCheckable = true, func = function() InsertLink(link) end },
		}, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
		return
	end
	local menu = {
		{ text = item.link, isTitle = true, notCheckable = true },
		item.soulbound and { text = T("SOULBOUND"), notCheckable = true, disabled = true }
			or { text = T("GIVE"), notCheckable = true, func = function() Give(link); AfterChange() end },
		{ text = T("EQUIP"), notCheckable = true, func = function() Whisper("e " .. link); AfterChange() end },
		{ text = T("USE"), notCheckable = true, func = function() Whisper("u " .. link); AfterChange() end },
		{ text = T("SELL"), notCheckable = true, func = function() Sell(link, false, item) end },
		{ text = T("DEPOSIT"), notCheckable = true, func = function() Whisper("bank " .. link); TakeOut(bags, item); AfterChange() end },
		{ text = T("DESTROY"), notCheckable = true, func = function() Destroy(item, link) end },
		{ text = T("LINK"), notCheckable = true, func = function() InsertLink(link) end },
	}
	if AltBags(current) and select(9, GetItemInfo(item.link)) == "INVTYPE_BAG" then
		table.insert(menu, 5, { text = T("BS_PUT"), notCheckable = true,
			func = function() BagSlots.Equip(current, item.link:match("|H(item:[^|]+)|h"), nil) end })
	end
	EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
end

-- ---------------------------------------------------------------------------
-- The sheet
-- ---------------------------------------------------------------------------
local function ItemButton(parent, size)
	local b = CreateFrame("Button", nil, parent)
	b:SetWidth(size)
	b:SetHeight(size)
	-- One thin border, in the item's quality colour (the action bar's slot texture drew a frame in the frame).
	b.edge = b:CreateTexture(nil, "BACKGROUND")
	b.edge:SetTexture("Interface\\Buttons\\WHITE8X8")
	b.edge:SetAllPoints()
	b.edge:SetVertexColor(0, 0, 0, 0.9)
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetPoint("TOPLEFT", 1, -1)
	b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	b.count:SetPoint("BOTTOMRIGHT", -2, 2)
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return b
end

-- 3.1: a small green arrow in the corner of an item that is an upgrade for the sheet's alt.
local function UpMark(b, on)
	if not on then
		if b.sqbUp then b.sqbUp:Hide() end
		return
	end
	if not b.sqbUp then
		b.sqbUp = b:CreateTexture(nil, "OVERLAY")
		b.sqbUp:SetTexture("Interface\\Buttons\\UI-MicroStream-Green")
		-- The texture points down: turned upside down.
		b.sqbUp:SetTexCoord(0, 1, 1, 0)
		b.sqbUp:SetWidth(16)
		b.sqbUp:SetHeight(16)
		b.sqbUp:SetPoint("TOPLEFT", -2, 2)
	end
	b.sqbUp:Show()
end

-- Green and better get their colour on the border; white, grey and an empty slot stay black.
local function SetQuality(b, quality)
	local color = quality and quality >= 2 and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
	if color then b.edge:SetVertexColor(color.r, color.g, color.b, 1) else b.edge:SetVertexColor(0, 0, 0, 0.9) end
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
				InsertLink(link)
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
	page.best:SetScript("OnClick", function()
		StaticPopupDialogs.SQUIDBOTSLITE_AUTOGEAR.text = string.format(T("BEST_GEAR_ASK"), current or "?")
		StaticPopup_Show("SQUIDBOTSLITE_AUTOGEAR")
	end)
	page.best:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(T("BEST_GEAR"))
		GameTooltip:AddLine(T("BEST_GEAR_TIP"), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	page.best:SetScript("OnLeave", function() GameTooltip:Hide() end)
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
			if IsShiftKeyDown() then InsertLink(SendableLink(self.item)) else ItemMenu(self.item) end
		end)
		b:SetScript("OnReceiveDrag", DropOnBags)
		page.buttons[i] = b
	end
	-- 3.1: its four bags, in a column right of the grid.
	page.slotsTitle = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	page.slotsTitle:SetPoint("TOPLEFT", 14 + BAG_COLS * 46 + 14, 0)
	page.slots = {}
	for i = 1, 4 do
		local b = ItemButton(page, 36)
		b:SetPoint("TOPLEFT", 14 + BAG_COLS * 46 + 14, -16 - (i - 1) * 56)
		b.slot = i
		b.free = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		b.free:SetPoint("TOPLEFT", b, "BOTTOMLEFT", -4, -2)
		b:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if self.bag and self.bag.str then
				GameTooltip:SetHyperlink(self.bag.str)
				GameTooltip:AddLine(string.format(T("BS_FREE"), self.bag.free, self.bag.size), 0.6, 0.8, 1)
			else
				GameTooltip:SetText(T("BS_EMPTY"))
			end
			GameTooltip:AddLine(T("BS_HINT"), 0.6, 0.6, 0.6, true)
			GameTooltip:Show()
		end)
		b:SetScript("OnClick", function(self) BagSlots.Menu(self.slot) end)
		page.slots[i] = b
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
	page.grey:SetScript("OnClick", function()
		local grey, white = T("Q_GREY"), T("Q_WHITE")
		EasyMenu({
			{ text = T("BULK_JUNK"), notCheckable = true, func = function()
				Sell("junk", true)
				-- The grey items leave the list at once.
				for i = #bags, 1, -1 do
					if bags[i].link:find("^|cff9d9d9d") then table.remove(bags, i) end
				end
				if Render then Render() end
				AfterChange()
			end },
			{ text = string.format(T("BULK_SELL"), grey), notCheckable = true, func = function() Bulk("sell", "grey") end },
			{ text = string.format(T("BULK_SELL"), white), notCheckable = true, func = function() Bulk("sell", "white") end },
			{ text = string.format(T("BULK_DESTROY"), grey), notCheckable = true, func = function() Bulk("destroy", "grey") end },
			{ text = string.format(T("BULK_DESTROY"), white), notCheckable = true, func = function() Bulk("destroy", "white") end },
		}, menuFrame, "cursor", 0, 0, "MENU", MENU_HIDE_DELAY)
		if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
	end)
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
			if IsShiftKeyDown() then InsertLink(self.quest.text)
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
		if id and IsShiftKeyDown() then InsertLink(GetSpellLink(id) or "") end
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

-- The mounts shown: the kind chosen (a ground-and-flying mount is in both) and the search box (a part of the name,
-- any case). The favourites first, then by name.
local function ShownMounts(page)
	local search = page.search and strlower(strtrim(page.search:GetText() or "")) or ""
	local list = {}
	for _, m in ipairs(mounts) do
		local kindOk = mountKind == "all" or m.kind == mountKind or m.kind == "both"
		if kindOk and (search == "" or strlower(m.name or ""):find(search, 1, true)) then table.insert(list, m) end
	end
	table.sort(list, function(x, y)
		if (x.preferred and 1 or 0) ~= (y.preferred and 1 or 0) then return x.preferred == true end
		return (x.name or "") < (y.name or "")
	end)
	return list, search
end

local MOUNT_COLORS = { ground = { 0.85, 0.7, 0.45 }, flying = { 0.5, 0.8, 1 }, both = { 0.55, 0.9, 0.55 } }

local function BuildMounts(page)
	page.search = CreateFrame("EditBox", "SquidBotsLiteMountSearch", page, "InputBoxTemplate")
	page.search:SetWidth(190)
	page.search:SetHeight(20)
	page.search:SetPoint("TOPLEFT", 18, -2)
	page.search:SetAutoFocus(false)
	page.search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
	page.search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	page.search:SetScript("OnTextChanged", function() mountOffset = 0; RenderMounts(page) end)
	page.search:SetScript("OnEditFocusGained", function() page.typing = true; RenderMounts(page) end)
	page.search:SetScript("OnEditFocusLost", function() page.typing = nil; RenderMounts(page) end)
	page.searchHint = page.search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.searchHint:SetPoint("LEFT", 4, 0)
	-- The kind filter: All, Ground, Flying.
	page.kinds = {}
	for i, kind in ipairs({ "all", "ground", "flying" }) do
		local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
		b:SetWidth(62)
		b:SetHeight(20)
		b:SetPoint("LEFT", page.search, "RIGHT", 10 + (i - 1) * 64, 0)
		b:SetNormalFontObject(GameFontNormalSmall)
		b:SetHighlightFontObject(GameFontHighlightSmall)
		b:SetScript("OnClick", function() mountKind = kind; mountOffset = 0; RenderMounts(page) end)
		b.kind = kind
		page.kinds[i] = b
	end
	page.count = 0
	page.countText = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.countText:SetPoint("TOPRIGHT", -12, -6)
	page.favs = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.favs:SetPoint("TOPLEFT", 14, -28)
	page.favs:SetWidth(470)
	page.favs:SetJustifyH("LEFT")
	page.rows = {}
	for i = 1, MOUNT_ROWS do
		local row = CreateFrame("Button", nil, page)
		row:SetWidth(456)
		row:SetHeight(23)
		row:SetPoint("TOPLEFT", 10, -46 - (i - 1) * 24)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		-- Every other row a shade lighter: the eye follows the line to its kind.
		row.stripe = row:CreateTexture(nil, "BACKGROUND")
		row.stripe:SetAllPoints()
		row.stripe:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.stripe:SetVertexColor(1, 1, 1, i % 2 == 0 and 0.04 or 0)
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
		row.name:SetWidth(240)
		row.name:SetJustifyH("LEFT")
		row.kind = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.kind:SetPoint("LEFT", 276, 0)
		row.kind:SetWidth(156)
		row.kind:SetJustifyH("LEFT")
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
			mountOffset = math.max(0, math.min(math.max(0, (page.count or 0) - MOUNT_ROWS), mountOffset - delta * 3))
			RenderMounts(page)
		end)
		page.rows[i] = row
	end
	page.up = CreateFrame("Button", nil, page, "UIPanelScrollUpButtonTemplate")
	page.up:SetPoint("TOPLEFT", page.rows[1], "TOPRIGHT", 4, 0)
	page.up:SetScript("OnClick", function() mountOffset = math.max(0, mountOffset - MOUNT_ROWS); RenderMounts(page) end)
	page.down = CreateFrame("Button", nil, page, "UIPanelScrollDownButtonTemplate")
	page.down:SetPoint("BOTTOMLEFT", page.rows[MOUNT_ROWS], "BOTTOMRIGHT", 4, 0)
	page.down:SetScript("OnClick", function()
		if mountOffset + MOUNT_ROWS < (page.count or 0) then mountOffset = mountOffset + MOUNT_ROWS end
		RenderMounts(page)
	end)
	page.auto = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.auto:SetWidth(150)
	page.auto:SetHeight(22)
	page.auto:SetPoint("TOPLEFT", page.rows[MOUNT_ROWS], "BOTTOMLEFT", 0, -8)
	page.auto:SetScript("OnClick", function() Whisper("mount clear"); AfterChange() end)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", page.auto, "TOPRIGHT", 10, 2)
	page.hint:SetWidth(300)
	page.hint:SetJustifyH("LEFT")
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	page.note:SetPoint("TOP", 0, -120)
	page.note:SetWidth(340)
end

RenderMounts = function(page)
	local shown, search = ShownMounts(page)
	page.count = #shown
	mountOffset = math.max(0, math.min(mountOffset, #shown - MOUNT_ROWS))
	page.searchHint:SetText(search == "" and not page.typing and T("MOUNT_SEARCH") or "")
	if #mounts == 0 then
		page.note:SetText(capture == nil and sheet.status:GetText() == "" and T("NO_MOUNTS") or "")
	else
		page.note:SetText(#shown == 0 and string.format(T("MOUNT_NONE"), page.search:GetText()) or "")
	end
	local labels = { all = "MOUNT_ALL", ground = "MOUNT_F_GROUND", flying = "MOUNT_F_FLYING" }
	for _, b in ipairs(page.kinds) do
		b:SetText(T(labels[b.kind]))
		if b.kind == mountKind then b:LockHighlight() else b:UnlockHighlight() end
	end
	page.countText:SetText(#mounts > 0 and string.format(T("MOUNT_COUNT"), #shown) or "")
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
	-- The line at the top: which mount for the ground, which for the air (automatic: none chosen).
	local groundName, flyingName
	for _, m in ipairs(mounts) do
		if m.preferred then
			local role = FavouriteFor(m)
			if role == T("FOR_GROUND") then groundName = m.name
			elseif role == T("FOR_FLYING") then flyingName = m.name
			else groundName, flyingName = groundName or m.name, flyingName or m.name end
		end
	end
	local auto = "|cff808080" .. T("MOUNT_AUTO_WORD") .. "|r"
	page.favs:SetText(#mounts > 0 and string.format(T("MOUNT_FAVS"),
		groundName and ("|cffffd100" .. groundName .. "|r") or auto, flyingName and ("|cffffd100" .. flyingName .. "|r") or auto) or "")
	for i, row in ipairs(page.rows) do
		local m = shown[mountOffset + i]
		row.mount = m
		if m then
			row.icon:SetTexture(select(3, GetSpellInfo(m.id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			row.name:SetText(m.name)
			local color = MOUNT_COLORS[m.kind] or { 0.7, 0.7, 0.7 }
			row.kind:SetText(kinds[m.kind] or m.kind or "")
			row.kind:SetTextColor(color[1], color[2], color[3])
			if m.preferred then
				row.name:SetTextColor(1, 0.82, 0)
				row.kind:SetText((kinds[m.kind] or m.kind or "") .. "  |cffffd100" .. FavouriteFor(m) .. "|r")
				row.check:Show()
			else
				row.name:SetTextColor(1, 1, 1)
				row.check:Hide()
			end
			row:Show()
		else
			row:Hide()
		end
	end
	if #shown > MOUNT_ROWS then page.up:Show(); page.down:Show() else page.up:Hide(); page.down:Hide() end
end

local TABS = { { "gear", "GEAR", BuildGear, "Interface\\Icons\\INV_Chest_Chain_05" },
	{ "bags", "BAGS", BuildBags, "Interface\\Icons\\INV_Misc_Bag_08" },
	{ "quests", "QUESTS", BuildQuests, "Interface\\GossipFrame\\AvailableQuestIcon" },
	{ "talents", "TALENTS", BuildTalents, "Interface\\Icons\\INV_Misc_Book_11" },
	{ "mounts", "MOUNTS", BuildMounts, "Interface\\Icons\\Ability_Mount_RidingHorse" },
	{ "pets", "PETS", function(page) SquidBotsLite_Pets.Build(page) end, "Interface\\Icons\\INV_Misc_Book_09" },
	{ "info", "INFO", BuildInfo, "Interface\\Icons\\INV_Misc_Note_01" } }
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
		SetQuality(b, texture and GetInventoryItemQuality(unit, slot))
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
	page.grey:SetText(T("BULK_BTN"))
	local shown = BagSlots.Shown()
	if shown then BagSlots.Ask() end
	local d = shown and BagSlots.by[current]
	-- Nothing shown before the first answer (a server without the command never answers).
	shown = shown and d and d.got and next(d.got) ~= nil
	page.slotsTitle:SetText(shown and T("BS_TITLE") or "")
	for i, b in ipairs(page.slots) do
		local bag = d and d.got and d.got[i]
		b.bag = bag
		if shown then
			if bag and bag.id ~= 0 then
				b.icon:SetTexture((GetItemIcon and GetItemIcon(bag.id)) or select(10, GetItemInfo(bag.id)) or "Interface\\Icons\\INV_Misc_Bag_08")
				b.free:SetText(string.format("%d/%d", bag.free, bag.size))
				SetQuality(b, select(3, GetItemInfo(bag.id)))
			else
				b.icon:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag")
				b.free:SetText("")
				SetQuality(b, nil)
			end
			b:Show()
		else
			b.free:SetText("")
			b:Hide()
		end
	end
	for i, b in ipairs(page.buttons) do
		local item = list[i]
		b.item = item
		if item then
			b.icon:SetTexture((GetItemIcon and GetItemIcon(item.id)) or select(10, GetItemInfo(item.id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			b.icon:Show()
			SetQuality(b, select(3, GetItemInfo(item.id)))
			b.count:SetText(item.count > 1 and item.count or "")
			UpMark(b, bagMode ~= "bank" and IconVerdict and IconVerdict(item.link))
			b:Show()
		else
			UpMark(b, false)
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
	local text = table.concat(stats, "\n")
	local W = SquidBotsLite_World
	if W and current then
		local arch, traits = W.SoulText(current)
		if arch then
			text = text .. (text ~= "" and "\n\n" or "") .. "|cffffd100" .. W.T("SOUL") .. " : " .. arch .. "|r\n|cffaaaaaa" .. traits .. "|r"
		else
			W.Soul(current)
		end
	end
	page.text:SetText(text)
	for _, b in ipairs(page.buttons) do b:SetText(T(b.label)) end
end

Render = function()
	if not sheet or not sheet:IsShown() then return end
	sheet.title:SetText("SquidBots Manager - " .. T("TITLE") .. " : " .. (current or "?")
		.. (readOnly.on and ("  |cffaaaaaa(" .. T("READ_ONLY") .. ")|r") or ""))
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
	end
	sheet.xp.has = info.xp ~= nil
	sheet.xp:Update()
	sheet.refresh:SetText(T("REFRESH"))
	for _, def in ipairs(TABS) do
		local key = def[1]
		sheet.tabs[key]:SetText(T(def[2]))
		local text = sheet.tabs[key]:GetFontString()
		if text then
			text:ClearAllPoints()
			text:SetPoint("LEFT", sheet.tabs[key].tabIcon, "RIGHT", 4, 0)
		end
		if key == tab then sheet.tabs[key]:LockHighlight() else sheet.tabs[key]:UnlockHighlight() end
		if readOnly.on and readOnly.HIDDEN[key] then sheet.tabs[key]:Hide() else sheet.tabs[key]:Show() end
		if key == tab then pages[key]:Show() else pages[key]:Hide() end
	end
	if tab == "gear" then RenderGear(pages.gear)
	elseif tab == "bags" then RenderBags(pages.bags)
	elseif tab == "quests" then RenderQuests(pages.quests)
	elseif tab == "mounts" then RenderMounts(pages.mounts)
	elseif tab == "pets" then SquidBotsLite_Pets.Render(pages.pets)
	elseif tab == "talents" then
		RenderTalents(pages.talents)
		if SquidBotsLite_TalentTree then SquidBotsLite_TalentTree.Render(pages.talents) end
	elseif tab == "strats" then RenderStrats(pages.strats)
	else RenderInfo(pages.info) end
	if SquidBotsLite_MarkContainers then SquidBotsLite_MarkContainers() end
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
	elseif tab == "pets" then
		SquidBotsLite_Pets.Ask()
	elseif tab == "talents" then
		Ask("talents", "talents ?")
		if SquidBotsLite_TalentTree then SquidBotsLite_TalentTree.Ask() end
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
	-- 3.1: the arrows on the player's own bags go with the sheet.
	sheet:SetScript("OnHide", function() if SquidBotsLite_MarkContainers then SquidBotsLite_MarkContainers() end end)
	-- 3.0: 520 wide (was 470): seven tabs.
	sheet:SetWidth(520)
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
		b:SetPoint("TOPLEFT", 12 + (i - 1) * 72, -36)
		b:SetScript("OnClick", function() tab = def[1]; sheet.xp:Update(); Load() end)
		-- A small icon before the name, the name a size smaller to make room.
		b:SetNormalFontObject(GameFontNormalSmall)
		b:SetHighlightFontObject(GameFontHighlightSmall)
		b:SetPushedTextOffset(0, 0)
		b.tabIcon = b:CreateTexture(nil, "OVERLAY")
		b.tabIcon:SetWidth(14)
		b.tabIcon:SetHeight(14)
		b.tabIcon:SetPoint("LEFT", 6, 0)
		b.tabIcon:SetTexture(def[4])
		if def[4]:find("Icons") then b.tabIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
		sheet.tabs[def[1]] = b
		local page = CreateFrame("Frame", nil, sheet)
		page:SetPoint("TOPLEFT", 8, -86)
		page:SetPoint("BOTTOMRIGHT", -8, 40)
		def[3](page)
		-- 3.0: the Talents tab's tree view (TalentTree.lua).
		if def[1] == "talents" and SquidBotsLite_TalentTree then SquidBotsLite_TalentTree.Build(page) end
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
	sheet.xp:SetHeight(10)
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
	-- The Pets tab has its buttons ("Dismiss", "Uses them by itself") where the bar sits: no bar on that tab.
	sheet.xp.Update = function(self)
		if self.has and tab ~= "pets" then self:Show() else self:Hide() end
	end
	sheet.status = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	sheet.status:SetPoint("BOTTOMLEFT", 18, 20)
	-- The flat buttons of the other panels (SquidBotsLite.lua).
	if SquidBotsLite_UI then SquidBotsLite_UI.FlattenAll(sheet) end
	sheet:Hide()
end

-- ---------------------------------------------------------------------------
-- 3.0: the Pets tab. The alt's companions by use (loot, quests, class trainer, professions), one favourite per use
-- that it summons by itself. Protocol: docs/PETS-PROTOCOLE-3.0.md ("pet list|set|use|dismiss|auto", "PET ..." lines).
-- ---------------------------------------------------------------------------
SquidBotsLite_Pets = {
	CATEGORIES = { "loot", "quest", "class", "craft" },
	-- What the tab shows before (or without) an answer; the server's lines replace it.
	KNOWN = {
		{ id = 9930889, entry = 44022, cat = "loot", name = "Lootbot 3000" },
		{ id = 83086, entry = 79026, cat = "loot", name = "Kleptomanic Demon" },
		{ id = 83050, entry = 79025, cat = "quest", name = "Wondrous Wisdomball" },
		{ id = 979602, entry = 75115, cat = "class", name = "Book of Ascension" },
		{ id = 499992, entry = 499992, cat = "class", name = "Book of Ascension" },
		{ id = 499908, entry = 75137, cat = "class", name = "Bloody Book of Ascension" },
		{ id = 105307, entry = 108587, cat = "class", name = "Book of Conquest" },
		{ id = 750750, entry = 57500, cat = "craft", name = "Book of Artisans" },
	},
	-- 8 rows: the server sends both Books of Ascension (979602 and 499992).
	ROWS = 8, WAIT = 6.5,
	list = nil, pending = nil, fav = {}, out = 0, auto = true, askedAt = nil, answered = false,
}
local PT = SquidBotsLite_Pets

function PT.Reset()
	PT.list, PT.pending, PT.fav, PT.out, PT.auto, PT.askedAt, PT.answered = nil, nil, {}, 0, true, nil, false
	PT.err, PT.errPending, PT.favPending = nil, nil, nil
end

function PT.Send(command)
	if not current then return end
	if SquidBotsLite_Alts and SquidBotsLite_Alts.Handle then SquidBotsLite_Alts.Handle.PET = PT.OnLine end
	PT.askedAt = GetTime()
	Whisper(command)
	local name, wait, t = current, CreateFrame("Frame"), 0
	wait:SetScript("OnUpdate", function(self, delta)
		t = t + delta
		if t < PT.WAIT then return end
		self:SetScript("OnUpdate", nil)
		if current == name and sheet and sheet:IsShown() and tab == "pets" then PT.Render(pages.pets) end
	end)
end

function PT.Ask() PT.Send("pet list") end

function PT.OnLine(name, f)
	if name ~= current then return end
	if f[2] == "pet" then
		local id = tonumber(f[3] or "")
		if id then
			PT.pending = PT.pending or {}
			table.insert(PT.pending, { id = id, entry = tonumber(f[4] or ""), cat = f[5], known = f[6] == "1",
				name = (f[7] and f[7] ~= "") and f[7] or GetSpellInfo(id) or ("#" .. id) })
		end
	elseif f[2] == "fav" and f[3] then
		PT.favPending = PT.favPending or {}
		PT.favPending[f[3]] = tonumber(f[4] or "") or 0
	elseif f[2] == "out" then
		PT.out = tonumber(f[3] or "") or 0
	elseif f[2] == "auto" then
		PT.auto = f[3] ~= "0"
	elseif f[2] == "err" then
		-- A refused use / dismiss / set (in combat, in a raid...): shown until the next answer.
		PT.errPending = f[3] or "?"
	elseif f[2] == "-" then
		PT.list, PT.pending = PT.pending or PT.list or {}, nil
		PT.fav, PT.favPending = PT.favPending or PT.fav, nil
		PT.err, PT.errPending = PT.errPending, nil
		PT.answered = true
		if sheet and sheet:IsShown() and tab == "pets" then PT.Render(pages.pets) end
	end
end

-- The rows: the server's list, in use order, else the companions the tab knows (greyed until an answer).
function PT.Shown()
	local order = {}
	for i, cat in ipairs(PT.CATEGORIES) do order[cat] = i end
	local list = {}
	for _, p in ipairs(PT.list or PT.KNOWN) do table.insert(list, p) end
	table.sort(list, function(a, b)
		local ca, cb = order[a.cat] or 9, order[b.cat] or 9
		if ca ~= cb then return ca < cb end
		if (a.known and 1 or 0) ~= (b.known and 1 or 0) then return a.known == true end
		return a.name < b.name
	end)
	return list
end

function PT.Build(page)
	page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	page.hint:SetPoint("TOPLEFT", 10, -2)
	page.hint:SetWidth(430)
	page.hint:SetJustifyH("LEFT")
	page.rows = {}
	for i = 1, PT.ROWS do
		local row = CreateFrame("Frame", nil, page)
		row:SetWidth(440)
		row:SetHeight(36)
		row:SetPoint("TOPLEFT", 6, -34 - (i - 1) * 38)
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(30)
		row.icon:SetHeight(30)
		row.icon:SetPoint("LEFT", 2, 0)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -1)
		row.name:SetWidth(220)
		row.name:SetJustifyH("LEFT")
		row.kind = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.kind:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 1)
		row.kind:SetWidth(220)
		row.kind:SetJustifyH("LEFT")
		row.use = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.use:SetWidth(70)
		row.use:SetHeight(22)
		row.use:SetPoint("RIGHT", -2, 0)
		row.use:SetScript("OnClick", function(self) if self.pet then PT.Send("pet use " .. self.pet.id) end end)
		row.fav = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.fav:SetWidth(80)
		row.fav:SetHeight(22)
		row.fav:SetPoint("RIGHT", row.use, "LEFT", -4, 0)
		row.fav:SetScript("OnClick", function(self)
			local p = self.pet
			if not p then return end
			-- A second click on the favourite: none (the alt takes the first it knows).
			PT.Send("pet set " .. p.cat .. " " .. ((PT.fav[p.cat] == p.id) and 0 or p.id))
		end)
		page.rows[i] = row
	end
	page.dismiss = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.dismiss:SetWidth(100)
	page.dismiss:SetHeight(22)
	page.dismiss:SetPoint("BOTTOMLEFT", 10, 2)
	page.dismiss:SetScript("OnClick", function() PT.Send("pet dismiss") end)
	page.auto = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
	page.auto:SetWidth(24)
	page.auto:SetHeight(24)
	page.auto:SetPoint("LEFT", page.dismiss, "RIGHT", 16, 0)
	page.auto:SetScript("OnClick", function(self) PT.Send("pet auto " .. (self:GetChecked() and "on" or "off")) end)
	page.autoText = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.autoText:SetPoint("LEFT", page.auto, "RIGHT", 2, 0)
	page.note = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	page.note:SetPoint("BOTTOMLEFT", page.dismiss, "TOPLEFT", 0, 6)
	page.note:SetWidth(430)
	page.note:SetJustifyH("LEFT")
end

function PT.Render(page)
	if not page or not page.rows then return end
	page.hint:SetText(T("PETS_HINT"))
	local answered = PT.answered
	local list = PT.Shown()
	for i, row in ipairs(page.rows) do
		local p = list[i]
		if p then
			local _, _, icon = GetSpellInfo(p.id)
			row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
			row.icon:SetDesaturated(not (answered and p.known))
			row.name:SetText(p.name)
			local words = { T("PET_CAT_" .. p.cat) or p.cat }
			if answered and not p.known then table.insert(words, "|cff808080" .. T("PETS_UNKNOWN") .. "|r") end
			if PT.fav[p.cat] == p.id then table.insert(words, "|cffffd100" .. T("PETS_IS_FAV") .. "|r") end
			if PT.out == p.id then table.insert(words, "|cff40ff40" .. T("PETS_IS_OUT") .. "|r") end
			row.kind:SetText(table.concat(words, "  ·  "))
			row.fav.pet, row.use.pet = p, p
			row.fav:SetText(T("PETS_FAV"))
			row.use:SetText(T("PETS_USE"))
			if answered and p.known then row.fav:Enable(); row.use:Enable() else row.fav:Disable(); row.use:Disable() end
			row:Show()
		else
			row:Hide()
		end
	end
	page.dismiss:SetText(T("PETS_DISMISS"))
	if answered and PT.out ~= 0 then page.dismiss:Enable() else page.dismiss:Disable() end
	page.auto:SetChecked(PT.auto)
	if answered then page.auto:Enable() else page.auto:Disable() end
	page.autoText:SetText(T("PETS_AUTO"))
	local silent = not answered and PT.askedAt and GetTime() - PT.askedAt > PT.WAIT - 0.5
	page.note:SetText(silent and T("PETS_NO_CMD") or PT.err and ("|cffff6060" .. string.format(T("PETS_ERR"), T("PETS_ERR_" .. PT.err) or PT.err) .. "|r") or "")
end

-- tabKey: the tab to open on (else the last one); ro: read only (a bot that is not the player's).
function SquidBotsLite_OpenSheet(name, tabKey, ro)
	readOnly.on = ro and true or false
	if tabKey then tab = tabKey end
	if readOnly.on and readOnly.HIDDEN[tab or ""] then tab = "gear" end
	if not name or name == "" then
		name = UnitName("target")
		if not name or not UnitOf(name) then Print(T("USAGE")) return end
	end
	if not sheet then Build() end
	if current ~= name then
		bags, quests, stats, mounts, bank, strats, queue = {}, {}, {}, {}, {}, { co = {}, nc = {} }, {}
		if pages.mounts and pages.mounts.search then pages.mounts.search:SetText(""); pages.mounts.search:ClearFocus() end
		SquidBotsLite_Pets.Reset()
		if SquidBotsLite_TalentTree then SquidBotsLite_TalentTree.Reset() end
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
	if not UnitOf(name) and tab == "gear" and not readOnly.on then tab = "bags" end
	Load()
	if not sheet.gold then Ask("stats", "stats") end
	local info = SquidBotsLiteDB.altInfo and SquidBotsLiteDB.altInfo[name]
	if not (info and info.spec) and SquidBotsLite_AskSpecs then SquidBotsLite_AskSpecs(name) end
end

-- 3.1: an item's tooltip, while a bot's sheet is open, also shows what the bot wears in that slot (a tooltip
-- beside it, like the game's own compare) and the item level difference. The bot must be in the group: its gear
-- is read like the Gear tab's.
do
	local SLOTS = { INVTYPE_HEAD = { 1 }, INVTYPE_NECK = { 2 }, INVTYPE_SHOULDER = { 3 }, INVTYPE_BODY = { 4 },
		INVTYPE_CHEST = { 5 }, INVTYPE_ROBE = { 5 }, INVTYPE_WAIST = { 6 }, INVTYPE_LEGS = { 7 }, INVTYPE_FEET = { 8 },
		INVTYPE_WRIST = { 9 }, INVTYPE_HAND = { 10 }, INVTYPE_FINGER = { 11, 12 }, INVTYPE_TRINKET = { 13, 14 },
		INVTYPE_CLOAK = { 15 }, INVTYPE_WEAPON = { 16, 17 }, INVTYPE_SHIELD = { 17 }, INVTYPE_2HWEAPON = { 16 },
		INVTYPE_WEAPONMAINHAND = { 16 }, INVTYPE_WEAPONOFFHAND = { 17 }, INVTYPE_HOLDABLE = { 17 },
		INVTYPE_RANGED = { 18 }, INVTYPE_THROWN = { 18 }, INVTYPE_RANGEDRIGHT = { 18 }, INVTYPE_RELIC = { 18 },
		INVTYPE_TABARD = { 19 } }
	local tips = {}
	local function HideTips() for _, t in ipairs(tips) do t:Hide() end end
	-- Beside the outermost tooltip already shown, on the side with room (bags sit at the screen's right).
	local function Place(t, owner)
		local shown = { owner }
		local others = { ShoppingTooltip1 or false, ShoppingTooltip2 or false, tips[1] or false, tips[2] or false }
		for _, o in ipairs(others) do
			if o and o ~= t and o:IsShown() and o:GetLeft() then table.insert(shown, o) end
		end
		local left, right = owner, owner
		for _, o in ipairs(shown) do
			if (o:GetLeft() or 0) < (left:GetLeft() or 0) then left = o end
			if (o:GetRight() or 0) > (right:GetRight() or 0) then right = o end
		end
		t:ClearAllPoints()
		-- Like the game's own comparison: beside the tooltips, on the side away from the bot's sheet, if it fits.
		local roomRight = (right:GetRight() or 0) + (t:GetWidth() or 0) <= (UIParent:GetRight() or 0)
		local roomLeft = (left:GetLeft() or 0) - (t:GetWidth() or 0) >= 0
		local away = "right"
		local sx, ox = sheet and sheet:IsShown() and sheet:GetCenter(), owner:GetCenter()
		if sx and ox and sx > ox then away = "left" end
		if (away == "right" and roomRight) or (away == "left" and not roomLeft and roomRight) then
			t:SetPoint("TOPLEFT", right, "TOPRIGHT", 0, -10)
		else
			t:SetPoint("TOPRIGHT", left, "TOPLEFT", 0, -10)
		end
	end
	-- The alt's answer to "alt cmp <itemString>": CMP item <id> ..., CMP worn (one per slot), or CMP err; then CMP -.
	-- An answer goes to the question about its item id, never simply to the oldest one: a single lost or doubled
	-- answer then shifted every later one onto the wrong item (gloves shown with a robe, "Asking..." for ever).
	-- Only the hovered item's slots are kept. No answer within WAIT seconds: the addon's own comparison, and a late
	-- answer still shows if the tooltip is on that item. Kept a minute per alt and item.
	local WAIT, RETRY = 2, 5
	local cache, waiting, receiving = {}, {}, {}
	local function Worn(tooltip, n, str, name)
		if not tips[n] then
			tips[n] = CreateFrame("GameTooltip", "SquidBotsLiteCompare" .. n, UIParent, "GameTooltipTemplate")
			tips[n]:SetFrameStrata("TOOLTIP")
		end
		local t = tips[n]
		t:SetOwner(tooltip, "ANCHOR_NONE")
		t:SetHyperlink(str)
		t:AddLine(string.format(T("CMP_WORN"), name), 0.4, 0.8, 1)
		t:Show()
		Place(t, tooltip)
	end
	-- The item the tooltip shows now, if it is for this alt's sheet: its item string.
	local function Shown(name)
		if name ~= current or not GameTooltip:IsShown() then return end
		local _, link = GameTooltip:GetItem()
		return link and (link:match("|H(item:[^|]+)|h") or link)
	end
	local function Redraw(name, key)
		local str = Shown(name)
		if not str or name .. "|" .. str ~= key then return end
		local owner = GameTooltip:GetOwner()
		local enter = owner and owner.GetScript and owner:GetScript("OnEnter")
		if enter then enter(owner) end
	end
	-- A question past WAIT: the tooltip again, now with the addon's own comparison.
	local timer = CreateFrame("Frame")
	timer:Hide()
	local OnCmp
	-- One question to the alt (none if the same one is already open).
	local function Question(name, key, str, slots)
		local queue = waiting[name] or {}
		waiting[name] = queue
		for i = #queue, 1, -1 do
			if queue[i].key == key then
				if GetTime() - queue[i].sent > RETRY then table.remove(queue, i) else return queue[i] end
			end
		end
		local w = { key = key, id = tonumber(str:match("item:(%d+)")), slots = slots, sent = GetTime(), worn = {} }
		table.insert(queue, w)
		SquidBotsLite_Alts.Handle.CMP = OnCmp
		SquidBotsLite_Alts.Send(name, "cmp " .. str)
		timer:Show()
		return w
	end
	-- 3.1: the icons' questions wait here and go ICON_FLIGHT at a time per alt (the server keeps 16 per bot).
	local ICON_FLIGHT = 4
	local wants = {}
	local function InFlight(name)
		local n = 0
		for _, w in ipairs(waiting[name] or {}) do if not w.late then n = n + 1 end end
		return n
	end
	timer:SetScript("OnUpdate", function(self)
		local now, open = GetTime(), false
		for name, queue in pairs(waiting) do
			for _, w in ipairs(queue) do
				if not w.late then
					if now - w.sent >= WAIT then
						w.late = true
						Redraw(name, w.key)
					else
						open = true
					end
				end
			end
		end
		for name, list in pairs(wants) do
			while #list > 0 and InFlight(name) < ICON_FLIGHT do
				local q = table.remove(list, 1)
				Question(name, q.key, q.str, q.slots)
			end
			if #list > 0 then open = true else wants[name] = nil end
		end
		if not open then self:Hide() end
	end)
	IconVerdict = function(link)
		if not (current and link and AltBags(current)) then return false end
		local _, _, _, _, _, _, _, _, loc = GetItemInfo(link)
		local slots = loc and SLOTS[loc]
		if not slots then return false end
		local str = link:match("|H(item:[^|]+)|h") or link
		local key = current .. "|" .. str
		local c = cache[key]
		-- A stale answer still shows while it is asked again; nothing is guessed without an answer.
		local stale = not c or GetTime() - c.at > (c.busy and RETRY or 60)
		if stale then
			local list = wants[current] or {}
			wants[current] = list
			local queued = false
			for _, q in ipairs(list) do if q.key == key then queued = true end end
			for _, w in ipairs(waiting[current] or {}) do if w.key == key and not w.late then queued = true end end
			if not queued then table.insert(list, { key = key, str = str, slots = slots }) end
			timer:Show()
		end
		return c and not c.busy and not c.err and (c.usage == "equip" or c.usage == "replace") or false
	end
	-- true: the tooltip has the alt's answer, or "Asking" for WAIT seconds at most; false: no answer in time.
	local function Asked(tooltip, link, slots)
		local str = link:match("|H(item:[^|]+)|h") or link
		local key = current .. "|" .. str
		local c = cache[key]
		if c and c.busy and GetTime() - c.at <= RETRY then return false end
		if not c or GetTime() - c.at > (c.busy and RETRY or 60) then
			local w = Question(current, key, str, slots)
			if GetTime() - w.sent >= WAIT then return false end
			tooltip:AddLine(string.format(T("CMP_ASKING"), current), 0.6, 0.6, 0.6)
			tooltip:Show()
			return true
		end
		if c.err then
			if c.err ~= "notgear" then tooltip:AddLine(string.format(T("CMP_NOTFOUND"), current), 0.6, 0.6, 0.6) end
			tooltip:Show()
			return true
		end
		-- One plain line: the verdict, and how much better or worse than the weaker worn piece in %.
		local base
		for _, w in ipairs(c.worn) do
			if w.id ~= 0 and w.score and w.score > 0 and (not base or w.score < base) then base = w.score end
		end
		local pct = ""
		if base and c.score and c.score > 0 then
			local d = math.floor((c.score - base) / base * 100 + 0.5)
			pct = string.format(" (%s%d%%)", d > 0 and "+" or "", d)
		end
		local v = c.usage and c.usage ~= "other" and T("CMP_V_" .. c.usage)
		if v then
			local good, cannot = c.usage == "equip" or c.usage == "replace", c.usage == "cannot"
			local r, g, b = 1, 0.35, 0.35
			if good then r, g, b = 0.25, 1, 0.25 elseif cannot then r, g, b = 0.6, 0.6, 0.6 end
			tooltip:AddLine(string.format(v, current, pct), r, g, b)
		end
		local n = 0
		for _, w in ipairs(c.worn) do
			if w.str and w.str ~= "-" and w.id ~= 0 then
				n = n + 1
				Worn(tooltip, n, w.str, current)
				-- The raw scores only while Shift is held.
				if IsShiftKeyDown() and c.score then
					tooltip:AddLine(string.format(T("CMP_SCORE"), string.format("%.1f", c.score), string.format("%.1f", w.score or 0)), 0.6, 0.6, 0.6)
				end
			end
		end
		tooltip:Show()
		return true
	end

	local function ById(queue, id)
		if not id then return end
		for _, w in ipairs(queue) do
			if w.id == id then return w end
		end
	end
	-- 3.1 servers end every worn, err and "-" line with the asked item id; older ones do not.
	OnCmp = function(name, f)
		local queue = waiting[name]
		if not queue then return end
		if f[2] == "item" then
			local w = ById(queue, tonumber(f[3] or ""))
			receiving[name] = w
			if w then w.usage, w.score, w.worn, w.err = f[6], tonumber(f[7] or ""), {}, nil end
		elseif f[2] == "worn" then
			local w, slot = ById(queue, tonumber(f[7] or "")) or receiving[name], tonumber(f[3] or "")
			if not w or not slot then return end
			for _, s in ipairs(w.slots or {}) do
				if s == slot then
					table.insert(w.worn, { slot = slot, id = tonumber(f[4]) or 0, score = tonumber(f[5] or ""), str = f[6] })
					break
				end
			end
		elseif f[2] == "err" then
			local w = ById(queue, tonumber(f[4] or ""))
			if w then
				w.err, receiving[name] = f[3] or "?", w
			elseif not f[4] and queue[1] then
				-- An older server's error names no item: kept only when one question is open, else left out
				-- (the questions still open get their own answers, or the addon's own comparison after WAIT).
				if #queue == 1 then
					queue[1].err, receiving[name] = f[3] or "?", queue[1]
				else
					receiving[name] = nil
				end
			end
		elseif f[2] == "-" then
			local w = ById(queue, tonumber(f[3] or "")) or receiving[name]
			receiving[name] = nil
			if not w then return end
			for i, x in ipairs(queue) do
				if x == w then table.remove(queue, i) break end
			end
			if w.err == "busy" then
				-- Too many questions at once: the addon's own comparison for a few seconds, then asked again.
				cache[w.key] = { at = GetTime(), busy = true }
			else
				cache[w.key] = { at = GetTime(), usage = w.usage, score = w.score, worn = w.worn, err = w.err }
			end
			-- The item still under the mouse: its tooltip again, now with the answer.
			Redraw(name, w.key)
			if name == current then SquidBotsLite_IconsChanged() end
		end
	end

	local function OnItem(tooltip)
		HideTips()
		if not (sheet and sheet:IsShown() and current) then return end
		local _, link = tooltip:GetItem()
		if not link then return end
		local _, _, _, ilvl, need, _, _, _, loc = GetItemInfo(link)
		local slots = loc and SLOTS[loc]
		local late = false
		if slots and AltBags(current) then
			if Asked(tooltip, link, slots) then return end
			late = true
			tooltip:AddLine(string.format(T("CMP_NOANSWER"), current), 0.6, 0.6, 0.6)
		end
		local unit = UnitOf(current)
		if not slots or not unit then
			if late then tooltip:Show() end
			return
		end
		local level = UnitLevel(unit) or 0
		if need and level > 0 and need > level then
			tooltip:AddLine(string.format(T("CMP_LEVEL"), current, level, need), 1, 0.3, 0.3)
		end
		local n, known = 0, false
		for _, slot in ipairs(slots) do
			local worn = GetInventoryItemLink(unit, slot)
			if worn then
				known = true
				-- Hovering the bot's own piece (Gear tab): nothing to compare with.
				if worn == link then HideTips(); tooltip:Show(); return end
				n = n + 1
				if not tips[n] then
					tips[n] = CreateFrame("GameTooltip", "SquidBotsLiteCompare" .. n, UIParent, "GameTooltipTemplate")
					tips[n]:SetFrameStrata("TOOLTIP")
				end
				local t = tips[n]
				t:SetOwner(tooltip, "ANCHOR_NONE")
				t:SetHyperlink(worn)
				t:AddLine(string.format(T("CMP_WORN"), current), 0.4, 0.8, 1)
				t:Show()
				Place(t, tooltip)
				local wl = select(4, GetItemInfo(worn))
				if ilvl and wl then
					local d = ilvl - wl
					local diff = d > 0 and ("|cff40ff40+" .. d .. "|r") or d < 0 and ("|cffff6060" .. d .. "|r") or "="
					tooltip:AddLine(string.format(T("CMP_ILVL"), diff, current, wl), 0.4, 0.8, 1)
				end
			end
		end
		if not known then tooltip:AddLine(string.format(T("CMP_NONE"), current), 0.6, 0.6, 0.6) end
		tooltip:Show()
	end
	-- 3.1: the player's own bags (the game's bag frames) show the arrow too, while an alt's sheet is open.
	local function MarkContainer(frame)
		if not (frame and frame.GetID and frame:GetName()) then return end
		local bag = frame:GetID()
		local on = sheet and sheet:IsShown() and current
		for i = 1, frame.size or 0 do
			local b = _G[frame:GetName() .. "Item" .. i]
			if b then UpMark(b, on and IconVerdict(GetContainerItemLink(bag, b:GetID())) or false) end
		end
	end
	if ContainerFrame_Update then hooksecurefunc("ContainerFrame_Update", MarkContainer) end
	function SquidBotsLite_MarkContainers()
		for i = 1, NUM_CONTAINER_FRAMES or 0 do
			local frame = _G["ContainerFrame" .. i]
			if frame and frame:IsShown() then MarkContainer(frame) end
		end
	end
	function SquidBotsLite_IconsChanged()
		if sheet and sheet:IsShown() and tab == "bags" then Render() else SquidBotsLite_MarkContainers() end
	end
	GameTooltip:HookScript("OnTooltipSetItem", OnItem)
	GameTooltip:HookScript("OnHide", HideTips)
	GameTooltip:HookScript("OnTooltipCleared", HideTips)
end

-- The sheet's bot, and whether its sheet is read only (TalentTree.lua).
function SquidBotsLite_SheetState()
	return current, readOnly.on
end

function SquidBotsLite_SheetDebug()
	SquidBotsLiteDB.sheetDebug = not SquidBotsLiteDB.sheetDebug
	Print("sheet debug " .. (SquidBotsLiteDB.sheetDebug and "on" or "off"))
end

function SquidBotsLite_SheetOnTrade(on)
	SquidBotsLiteDB.sheetOnTrade = on
end
