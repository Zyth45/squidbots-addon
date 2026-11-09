-- SquidBots Lite 3.0: the World panel (guild orders, artisans, world events) and the bots' soul.
-- Protocol: docs/WORLD-PROTOCOLE-3.0.md. Addon messages, prefix "SQBW", tab-separated:
--   guild, artisans, events: whispered to oneself, the server answers by addon whispers from oneself;
--   soul: "SOUL?" whispered to the bot, which answers.
-- Every list ends with "-". One request at a time; no answer within 6 s: the feature is off on this realm.

-- GAP: the server answers at most 1 request per second and per brick (more: no answer at all, not even "-").
-- ROWS: the cards a page shows (3.0: cards in the style of My alts, 36 high).
local PREFIX, WAIT, ROWS, GAP = "SQBW", 6, 8, 1.1
local REQUESTS = { GORD = true, GLIST = true, WEV = true, ["WEV?"] = true, ALIST = true, ARCP = true, AQUOTE = true,
	AORDER = true, AMAIL = true, ["SOUL?"] = true, GOFF = true, GACC = true, GREF = true, GCAT = true, GACT = true,
	["GACT?"] = true }

local STRINGS = {
	en = {
		TITLE = "SquidBots Manager - World", GUILD = "Guild", ARTISANS = "Artisans", EVENTS = "Events",
		TIP_WORLD = "Guild orders, bot artisans and the world's events (invasions, rushes, server firsts).",
		OFF = "Not on this realm (CoA Bots 3.0 with this feature and its .Addon option on).", WAITING = "Asking the server...",
		G_ITEM = "Item: shift-click it here, or its id", G_QTY = "Qty", G_ORDER = "Order",
		G_HINT = "Your guild's members sometimes send you gear that improves you. You can also order an item from them: they send it if they have it, craft it or buy it at the auction house.",
		G_GIFT = "gift", G_NONE = "No order in the last 7 days.", G_NO_GIFT = "No gift in the last 30 days.",
		G_ORDERS = "My orders to the guild", G_GIFTS = "Gifts from my guild",
		G_GIFT_LINE = "given by %s, %s", G_BY = "%s, %s", AGO = "%s ago",
		S_open = "waiting", S_shared = "sent from its bags (free)", S_crafted = "crafted (cash on delivery)",
		S_bought = "bought at the AH (cash on delivery)", S_none = "nobody could", S_refused = "refused",
		A_BACK = "< Artisans list", A_MAILS = "My orders", A_QUOTE = "Quote", A_ORDER = "Order", A_NONE = "No artisan bot online.",
		A_PICK = "Click an artisan, then a recipe.", A_TITLE = "Online artisans of your faction (not only your guild): click one for its recipes.",
		C_ARTISAN = "Artisan", C_LEVEL = "Lvl", C_ZONE = "Zone", C_PROFS = "Professions", A_FILTER = "Profession: %s", A_ALL = "All", A_PRICE = "%s x%d: %s, cash on delivery.",
		TIP_RECIPES = "Its recipes: pick one, then Quote.", A_RANK = "%s %d needed", A_MAX = "max %d", TIP_QUOTE = "Quote: the price of this item, no order yet.",
		Q_TITLE = "Quote from %s", Q_COD = "cash on delivery, paid when you take it from the mail",
		M_preparing = "Preparing", M_sent = "Sent", M_awaiting = "Awaiting pickup", M_paid = "Received",
		M_returned = "Returned", M_cancelled = "Cancelled", M_pending = "Awaiting pickup",
		M_ETA = "arrives in ~%s", M_HERE = "in your mailbox", M_TITLE = "Your artisan orders (last 7 days), newest first.",
		M_CHAT = "Your order %s (%s): %s.", M_CHAT_ETA = "Your order %s (%s) is on its way, arriving in ~%s.",
		E_NONE = "No invasion or rush right now.", E_inv = "Invasion", E_rush = "Gold rush", E_craid = "Capital raid", E_IN = "in %s", E_LEFT = "%s left",
		E_FIRSTS = "Server firsts", GM_TITLE = "GM", GM_INV = "Invasions", GM_RUSH = "Gold rush", GM_LIST = "List",
		GM_NEXT = "Next", GM_START = "Start", GM_STOP = "Stop", GM_STATUS = "Status", GM_scourge = "Scourge", GM_legion = "Legion",
		GM_aq = "Ahn'Qiraj", GM_HINT = "The server's answer shows here.", GM_CRAID = "Capital raid", GM_SW = "Stormwind",
		GM_ORG = "Orgrimmar", F_level = "level %s", F_boss = "%s",
		R_quality = "quality too high", R_daily = "daily limit reached", R_noguild = "no guild", R_item = "unknown item",
		R_qty = "quantity not allowed", R_off = "off on this realm", R_nobot = "no guild bot online", R_cannot = "no such recipe",
		R_busy = "the artisan is busy", R_mats = "no materials", R_expired = "quote too old: ask again",
		R_faction = "other faction", R_price = "the price went up: ask a new quote", R_offline = "the bot is offline",
		R_notyours = "not your bot",
		ASK_ART = "Order %d x %s from %s for %s (cash on delivery)?",
		V_gifts = "Gifts", V_cat = "Catalogue", V_act = "Activities", V_orders = "Ask the guild",
		G_DROP = "Drop an item here (shift-click or drag it)", G_ID = "or its id", G_ASK_LINE = "A member sends it if they have it, crafts it or buys it at the auction house.",
		G_BANNER = "%d of %d members online", G_FREE = "%d bots free", G_RUNNING = "Under way: %s", G_NO_GUILD = "You are in no guild.",
		G_NEXT = "Next activity in %s", G_CLEAR = "Clear", G_CLEAR_TIP = "Hide the requests shown now (new ones still come).",
		G_RECEIVED = "Received", G_THANKS = "Thank them", G_THANKED = "thanked", THANKS_MSG = "Thanks for the %s!",
		TIP_V_gifts = "Gear your guild offers you: accept or decline, and the gifts you received.",
		TIP_V_cat = "What your guild's bots have in stock or can craft: search, then order.",
		TIP_V_act = "Your guild's bots with you: rally, dungeon party, guild raid.",
		TIP_V_orders = "Ask your guild for one item, and how your requests went.",
		GF_HINT = "Gear your guild's members offer you. Accept: it comes by mail. Decline: that item is not offered again for 30 days.",
		GF_NONE = "No gift offered right now.", GF_LINE = "%s offers it (%s), %s", GF_EXPIRES = "ends in %s",
		GF_ACCEPT = "Accept", GF_DECLINE = "Decline", GF_EMPTY = "empty slot", GF_CHAT = "%s offers you %s (%s): open World > Guild > Gifts to accept.",
		GC_HINT = "What your guild's online bots have in stock or can craft. Search by English name; click an item to order it.",
		GC_SEARCH = "Search (English name)...", GC_NONE = "Nothing found.", GC_STOCK = "in stock: %s x%d", GC_CRAFT = "crafted by %s",
		GC_REQ = "level %d", GC_PAGE = "Page %d / %d", GC_SLOT = "Slot: %s", GC_USABLE = "Usable now", C_OTHER = "Other",
		GA_HINT = "Your guild's bots with you: rally them where you are, make a dungeon party, or a guild raid.",
		GA_gather = "Rally the guild", GA_party5 = "Dungeon party (5)", GA_raid10 = "Guild raid (10)", GA_raid15 = "Guild raid (15)",
		GA_raid25 = "Guild raid (25)", GS_ready = "ready", GS_busy = "under way", GS_cooldown = "again in %s", GS_nobots = "not enough bots",
		GA_BOTS = "%d bots available", GA_START = "Start", ASK_ACT = "Start: %s?", GS_blocked = "wait: %s under way",
		GA_TIP = "Bots available: your guild's bots online right now and free (not in a group, not busy elsewhere). Players and offline members are not counted.",
		GS_LEFT = "under way, %s left", GA_CANCEL = "Cancel", ASK_CANCEL = "Cancel: %s? Its bots go back to their lives.",
		R_none = "nothing to cancel",
		R_ingroup = "leave your group first", R_level = "level too low", R_offer = "this offer is gone",
		ASK_GUILD = "Order %d x %s from your guild? If a bot crafts it or buys it at the auction house, it comes cash on delivery (you pay when you take it from the mail).",
		YES = "Yes", NO = "No",
		SOUL = "Soul", ARCH_lazy = "Lazy", ARCH_quester = "Quester", ARCH_wanderer = "Wanderer", ARCH_trader = "Trader",
		ARCH_pvp = "PvP", TRAITS = "pace %d, sociability %d, curiosity %d, greed %d, aggression %d",
	},
	fr = {
		TITLE = "SquidBots Manager - Monde", GUILD = "Guilde", ARTISANS = "Artisans", EVENTS = "Événements",
		TIP_WORLD = "Commandes de guilde, bots artisans et événements du monde (invasions, ruées, server first).",
		OFF = "Pas sur ce royaume (CoA Bots 3.0 avec cette brique et son option .Addon activées).", WAITING = "Question au serveur...",
		G_ITEM = "Objet : Maj-clic ici, ou son id", G_QTY = "Qté", G_ORDER = "Commander",
		G_HINT = "Les membres de votre guilde vous envoient parfois de l'équipement qui vous améliore. Vous pouvez aussi leur commander un objet : ils vous l'envoient s'ils l'ont, le fabriquent ou l'achètent à l'hôtel des ventes.",
		G_GIFT = "don", G_NONE = "Aucune commande ces 7 derniers jours.", G_NO_GIFT = "Aucun cadeau ces 30 derniers jours.",
		G_ORDERS = "Mes commandes à la guilde", G_GIFTS = "Cadeaux reçus de ma guilde",
		G_GIFT_LINE = "offert par %s, %s", G_BY = "%s, %s", AGO = "il y a %s",
		S_open = "en attente", S_shared = "envoyé de ses sacs (gratuit)", S_crafted = "fabriqué (contre remboursement)",
		S_bought = "acheté à l'HV (contre remboursement)", S_none = "personne n'a pu", S_refused = "refusé",
		A_BACK = "< Liste des artisans", A_MAILS = "Mes commandes", A_QUOTE = "Devis", A_ORDER = "Commander", A_NONE = "Aucun bot artisan en ligne.",
		A_PICK = "Cliquez un artisan, puis une recette.", A_TITLE = "Artisans de votre faction en ligne (pas seulement votre guilde) : cliquez-en un pour ses recettes.",
		C_ARTISAN = "Artisan", C_LEVEL = "Niv.", C_ZONE = "Zone", C_PROFS = "Métiers", A_FILTER = "Métier : %s", A_ALL = "Tous", A_PRICE = "%s x%d : %s, contre remboursement.",
		TIP_RECIPES = "Ses recettes : choisissez-en une, puis Devis.", A_RANK = "%s %d requis", A_MAX = "max %d", TIP_QUOTE = "Devis : le prix de cet objet, sans commande.",
		Q_TITLE = "Devis de %s", Q_COD = "contre remboursement, payé en le retirant du courrier",
		M_preparing = "En préparation", M_sent = "Envoyé", M_awaiting = "En attente de réception", M_paid = "Reçu (payé)",
		M_returned = "Renvoyé", M_cancelled = "Annulé", M_pending = "En attente de réception",
		M_ETA = "arrivée dans ~%s", M_HERE = "dans votre boîte aux lettres", M_TITLE = "Vos commandes aux artisans (7 derniers jours), les plus récentes d'abord.",
		M_CHAT = "Votre commande %s (%s) : %s.", M_CHAT_ETA = "Votre commande %s (%s) est en route, arrivée dans ~%s.",
		E_NONE = "Aucune invasion ni ruée en ce moment.", E_inv = "Invasion", E_rush = "Ruée vers l'or", E_craid = "Raid sur une capitale", E_IN = "dans %s", E_LEFT = "encore %s",
		E_FIRSTS = "Server first", GM_TITLE = "MJ", GM_INV = "Invasions", GM_RUSH = "Ruée vers l'or", GM_LIST = "Liste",
		GM_NEXT = "Suivante", GM_START = "Lancer", GM_STOP = "Arrêter", GM_STATUS = "État", GM_scourge = "Fléau", GM_legion = "Légion",
		GM_aq = "Ahn'Qiraj", GM_HINT = "La réponse du serveur s'affiche ici.", GM_CRAID = "Raid capitale", GM_SW = "Hurlevent",
		GM_ORG = "Orgrimmar", F_level = "niveau %s", F_boss = "%s",
		R_quality = "qualité trop haute", R_daily = "limite du jour atteinte", R_noguild = "pas de guilde", R_item = "objet inconnu",
		R_qty = "quantité refusée", R_off = "coupé sur ce royaume", R_nobot = "aucun bot de guilde en ligne", R_cannot = "recette inconnue",
		R_busy = "l'artisan est occupé", R_mats = "pas de composants", R_expired = "devis trop vieux : redemandez",
		R_faction = "autre faction", R_price = "le prix a monté : redemandez un devis", R_offline = "le bot est hors ligne",
		R_notyours = "pas votre bot",
		ASK_ART = "Commander %d x %s à %s pour %s (contre remboursement) ?",
		V_gifts = "Dons", V_cat = "Catalogue", V_act = "Activités", V_orders = "Demander",
		G_DROP = "Déposez un objet ici (Maj-clic ou glisser)", G_ID = "ou son id", G_ASK_LINE = "Un membre l'envoie s'il l'a, le fabrique ou l'achète à l'hôtel des ventes.",
		G_BANNER = "%d membres en ligne sur %d", G_FREE = "%d bots libres", G_RUNNING = "En cours : %s", G_NO_GUILD = "Vous n'êtes dans aucune guilde.",
		G_NEXT = "Prochaine activité dans %s", G_CLEAR = "Effacer", G_CLEAR_TIP = "Masquer les demandes affichées (les nouvelles s'affichent toujours).",
		G_RECEIVED = "Reçus", G_THANKS = "Remercier", G_THANKED = "remercié", THANKS_MSG = "Merci pour %s !",
		TIP_V_gifts = "L'équipement que votre guilde vous offre : acceptez ou refusez, et les dons déjà reçus.",
		TIP_V_cat = "Ce que les bots de votre guilde ont en stock ou savent fabriquer : cherchez, puis commandez.",
		TIP_V_act = "Les bots de votre guilde avec vous : rassemblement, groupe de donjon, raid de guilde.",
		TIP_V_orders = "Demandez un objet à votre guilde, et suivez vos demandes.",
		GF_HINT = "L'équipement que les membres de votre guilde vous offrent. Accepter : il arrive par courrier. Refuser : cet objet ne vous est plus proposé pendant 30 jours.",
		GF_NONE = "Aucun don proposé en ce moment.", GF_LINE = "offert par %s (%s), %s", GF_EXPIRES = "fin dans %s",
		GF_ACCEPT = "Accepter", GF_DECLINE = "Refuser", GF_EMPTY = "emplacement vide", GF_CHAT = "%s vous offre %s (%s) : Monde > Guilde > Dons pour l'accepter.",
		GC_HINT = "Ce que les bots de votre guilde en ligne ont en stock ou savent fabriquer. Cherchez par nom anglais ; cliquez un objet pour le commander.",
		GC_SEARCH = "Chercher (nom anglais)...", GC_NONE = "Rien trouvé.", GC_STOCK = "en stock : %s x%d", GC_CRAFT = "fabriqué par %s",
		GC_REQ = "niveau %d", GC_PAGE = "Page %d / %d", GC_SLOT = "Emplacement : %s", GC_USABLE = "Utilisable", C_OTHER = "Autre",
		GA_HINT = "Les bots de votre guilde avec vous : rassemblez-les où vous êtes, formez un groupe de donjon ou un raid de guilde.",
		GA_gather = "Rassembler la guilde", GA_party5 = "Groupe de donjon (5)", GA_raid10 = "Raid de guilde (10)", GA_raid15 = "Raid de guilde (15)",
		GA_raid25 = "Raid de guilde (25)", GS_ready = "prêt", GS_busy = "en cours", GS_cooldown = "à nouveau dans %s", GS_nobots = "pas assez de bots",
		GA_BOTS = "%d bots disponibles", GA_START = "Lancer", ASK_ACT = "Lancer : %s ?", GS_blocked = "attendre : %s en cours",
		GA_TIP = "Bots disponibles : les bots de votre guilde en ligne en ce moment et libres (pas en groupe, pas occupés ailleurs). Les joueurs et les membres hors ligne ne comptent pas.",
		GS_LEFT = "en cours, encore %s", GA_CANCEL = "Annuler", ASK_CANCEL = "Annuler : %s ? Ses bots retournent à leurs occupations.",
		R_none = "rien à annuler",
		R_ingroup = "quittez d'abord votre groupe", R_level = "niveau trop bas", R_offer = "ce don n'est plus proposé",
		ASK_GUILD = "Commander %d x %s à votre guilde ? Si un bot le fabrique ou l'achète à l'hôtel des ventes, il arrive contre remboursement (vous payez en le retirant du courrier).",
		YES = "Oui", NO = "Non",
		SOUL = "Âme", ARCH_lazy = "Paresseux", ARCH_quester = "Quêteur", ARCH_wanderer = "Vagabond", ARCH_trader = "Marchand",
		ARCH_pvp = "JcJ", TRAITS = "rythme %d, sociabilité %d, curiosité %d, avidité %d, agressivité %d",
	},
}

local W = {
	queue = {}, busy = nil, lines = {}, off = {}, at = {},
	guild = { orders = {}, gifts = {}, mode = "orders", thanked = {}, offers = {}, acts = {},
		cat = { list = {}, total = 0, page = 1, search = "", slot = nil, usable = false } }, art = { bots = {}, recipes = {}, mails = {}, bot = nil, quote = nil, mode = "bots" },
	events = { list = {}, firsts = {} }, soul = {}, soulAsked = {}, error = nil, tab = "art", offset = 0,
}
SquidBotsLite_World = W

local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end
W.T = T

local SKILL_ICON = { [171] = "Trade_Alchemy", [164] = "Trade_BlackSmithing", [333] = "Trade_Engraving",
	[202] = "Trade_Engineering", [773] = "INV_Inscription_Tradeskill01", [755] = "INV_Misc_Gem_01",
	[165] = "Trade_LeatherWorking", [197] = "Trade_Tailoring", [185] = "INV_Misc_Food_15", [129] = "Spell_Holy_SealOfSacrifice",
	[186] = "Trade_Mining", [182] = "Trade_Herbalism", [393] = "INV_Misc_Pelt_Wolf_01", [356] = "Trade_Fishing",
	[806] = "INV_Ammo_Arrow_02", [757] = "INV_Staff_08", [505] = "INV_Misc_Herb_07" }
-- CoA's own professions (Economie, 09/11), not in the client's 3.3.5 names.
local COA_SKILLS = { en = { [806] = "Fletching", [757] = "Woodworking", [505] = "Bushcraft" },
	fr = { [806] = "Empennage", [757] = "Menuiserie", [505] = "Bushcraft" } }
-- The crafting professions the Artisans tab shows; any other skill (riding, gathering, racial, weapon, language, or
-- one the addon cannot name) is left out, from an older server's ALIST too.
local CRAFTS = { [171] = true, [164] = true, [185] = true, [333] = true, [202] = true, [129] = true, [773] = true,
	[755] = true, [165] = true, [197] = true, [806] = true, [757] = true, [505] = true }

function W.SkillName(id)
	local names = SquidBotsLite_Alts and SquidBotsLite_Alts.SKILLS
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	local coa = (COA_SKILLS[lang] or COA_SKILLS.en)[id]
	if coa then return coa end
	return names and ((names[lang] or names.en)[id] or names.en[id]) or ("#" .. tostring(id))
end

-- "164:300,197:275" -> { { id = 164, value = 300 }, ... }, best first.
function W.Skills(text)
	local list = {}
	for id, value in (text or ""):gmatch("(%d+):(%d+)") do
		id = tonumber(id)
		if CRAFTS[id] then table.insert(list, { id = id, value = tonumber(value) }) end
	end
	table.sort(list, function(a, b) return a.value > b.value end)
	return list
end

-- "|T..:12|t Forge 300, |T..:12|t Couture 275"
function W.SkillsText(list, onlyId)
	local parts = {}
	for _, sk in ipairs(list) do
		local icon = SKILL_ICON[sk.id] and ("|TInterface\\Icons\\" .. SKILL_ICON[sk.id] .. ":12:12:0:0|t ") or ""
		local text = icon .. W.SkillName(sk.id) .. " " .. sk.value
		if sk.id == onlyId then text = "|cffffd100" .. text .. "|r" end
		table.insert(parts, text)
	end
	return table.concat(parts, "  ")
end

-- The inventory types of GC lines, named with the client's own words.
local INVTYPES = { [1] = "INVTYPE_HEAD", [2] = "INVTYPE_NECK", [3] = "INVTYPE_SHOULDER", [4] = "INVTYPE_BODY",
	[5] = "INVTYPE_CHEST", [6] = "INVTYPE_WAIST", [7] = "INVTYPE_LEGS", [8] = "INVTYPE_FEET", [9] = "INVTYPE_WRIST",
	[10] = "INVTYPE_HAND", [11] = "INVTYPE_FINGER", [12] = "INVTYPE_TRINKET", [13] = "INVTYPE_WEAPON", [14] = "INVTYPE_SHIELD",
	[15] = "INVTYPE_RANGED", [16] = "INVTYPE_CLOAK", [17] = "INVTYPE_2HWEAPON", [18] = "INVTYPE_BAG", [19] = "INVTYPE_TABARD",
	[20] = "INVTYPE_CHEST", [21] = "INVTYPE_WEAPONMAINHAND", [22] = "INVTYPE_WEAPONOFFHAND", [23] = "INVTYPE_HOLDABLE",
	[25] = "INVTYPE_THROWN", [26] = "INVTYPE_RANGEDRIGHT", [28] = "INVTYPE_RELIC" }
function W.SlotName(t)
	local key = INVTYPES[t or 0]
	return key and (_G[key] or key) or T("C_OTHER")
end

local function Split(text)
	local f = {}
	for part in (text .. "\t"):gmatch("([^\t]*)\t") do table.insert(f, part) end
	return f
end

-- "12g 5s 3c" from copper.
function W.Money(copper)
	copper = tonumber(copper) or 0
	local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
	local parts = {}
	if g > 0 then table.insert(parts, g .. "|cffffd100g|r") end
	if s > 0 then table.insert(parts, s .. "|cffc7c7cfs|r") end
	if c > 0 or #parts == 0 then table.insert(parts, c .. "|cffeda55fc|r") end
	return table.concat(parts, " ")
end

-- The price in big: gold, silver and copper with their coins.
function W.MoneyBig(copper)
	copper = tonumber(copper) or 0
	local g, sv, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
	local coin = "|TInterface\\MoneyFrame\\UI-%sIcon:16:16:2:0|t"
	local parts = {}
	if g > 0 then table.insert(parts, g .. string.format(coin, "Gold")) end
	if sv > 0 then table.insert(parts, sv .. string.format(coin, "Silver")) end
	if c > 0 or #parts == 0 then table.insert(parts, c .. string.format(coin, "Copper")) end
	return table.concat(parts, "  ")
end

function W.Duration(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	if seconds >= 3600 then return string.format("%dh%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60) end
	if seconds >= 60 then return string.format("%d min", math.ceil(seconds / 60)) end
	return seconds .. " s"
end

-- "2 h", "15 min" ago, from a server time.
function W.Ago(at)
	local d = math.max(0, time() - (at or 0))
	local text = d >= 86400 and (math.floor(d / 86400) .. " j") or d >= 3600 and (math.floor(d / 3600) .. " h")
		or (math.max(1, math.floor(d / 60)) .. " min")
	if d >= 86400 and not (SquidBotsLiteDB and SquidBotsLiteDB.lang == "fr") then text = math.floor(d / 86400) .. " d" end
	return string.format(T("AGO"), text)
end

-- "ilvl +5" stays, "empty" in words.
function W.GiftReason(reason)
	if reason == "empty" then return T("GF_EMPTY") end
	return reason or ""
end

function W.Reason(word) return T("R_" .. (word or "")) ~= "R_" .. (word or "") and T("R_" .. word) or (word or "?") end

-- The client knows only the items in its cache: an unknown one is asked to the server through a hidden tooltip, and
-- the panel draws again once a second while some are on their way. The server's English name (ARCP) meanwhile.
W.names, W.waiting = {}, {}
function W.ItemName(id)
	local name, _, quality = GetItemInfo(id or 0)
	if name then W.waiting[id] = nil return name, quality or 1 end
	if id and not W.waiting[id] then
		W.waiting[id] = true
		if not W.scan then
			W.scan = CreateFrame("GameTooltip", "SquidBotsLiteWorldScan", UIParent, "GameTooltipTemplate")
		end
		W.scan:SetOwner(UIParent, "ANCHOR_NONE")
		W.scan:SetHyperlink("item:" .. id)
		W.scan:Hide()
	end
	return W.names[id] or ("item:" .. tostring(id)), 1
end

function W.Colored(id, qualityHint)
	local name, quality = W.ItemName(id)
	local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[qualityHint or quality]
	return color and (color.hex .. name .. "|r") or name
end

-- ---------------------------------------------------------------------------
-- Transport: one request at a time, the server's lines gathered until "-".
-- ---------------------------------------------------------------------------
-- feature: the word that tells which tab the request is for ("guild", "art", "events").
function W.Send(request, feature, target)
	for _, q in ipairs(W.queue) do if q.request == request and q.target == target then return end end
	table.insert(W.queue, { request = request, feature = feature, target = target })
	W.Next()
end

function W.Next()
	if W.busy or #W.queue == 0 then return end
	if W.lastSent and GetTime() - W.lastSent < GAP then return end
	local q = table.remove(W.queue, 1)
	W.lastSent = GetTime()
	W.busy = q
	q.sentAt = GetTime()
	W.lines = {}
	W.error = nil
	SendAddonMessage(PREFIX, q.request, "WHISPER", q.target or UnitName("player"))
end

-- Lines that come with a request, or alone (a pushed event, "WE ... -").
function W.OnAddon(prefix, message, channel, sender)
	if prefix ~= PREFIX or channel ~= "WHISPER" or not message then return end
	local f = Split(message)
	-- Our own request, back as a plain echo: no brick took it (off on this realm); the 6 s rule says so.
	if REQUESTS[f[1]] then return end
	if f[1] == "SOUL" then
		-- From the bot itself, or from the server through oneself (both forms, SquidBot 2fd474bd).
		if f[2] and f[2] ~= "" and (sender == f[2] or sender == UnitName("player")) then
			W.soul[f[2]] = { arch = f[3], pace = tonumber(f[4]) or 0, soc = tonumber(f[5]) or 0, cur = tonumber(f[6]) or 0,
				greed = tonumber(f[7]) or 0, aggr = tonumber(f[8]) or 0 }
		end
		return
	end
	if sender ~= UnitName("player") and not (W.busy and W.busy.target == sender) then return end
	if f[1] == "-" then
		W.Finish()
	else
		table.insert(W.lines, f)
	end
end

function W.Finish()
	local q, lines = W.busy, W.lines
	W.lines = {}
	local kinds = {}
	for _, f in ipairs(lines) do kinds[f[1]] = true end
	if q then W.off[q.feature] = nil end
	if kinds.GO or kinds.GG or (q and q.request == "GLIST") then W.guild.orders, W.guild.gifts = {}, {} end
	if kinds.WF or (q and q.request == "WEV?") then W.events.firsts = {} end
	if q and q.request == "WEV?" then W.events.list, W.events.gm = {}, false end
	if kinds.AB or (q and q.request == "ALIST") then W.art.bots = {} end
	if kinds.AR then W.art.recipes = {} end
	if q and q.request == "AMAIL" then W.art.mails, W.art.bulk = {}, true end
	if q and (q.request == "GOFF" or q.request:find("^GACC") or q.request:find("^GREF")) then W.guild.offers, W.guild.bulk = {}, true end
	if q and q.request:find("^GCAT") then W.guild.cat.list = {} end
	for _, f in ipairs(lines) do W.Line(f) end
	W.art.bulk, W.guild.bulk = nil, nil
	if q and q.request:find("^GORD") and not W.error then W.Send("GLIST", "guild") end
	W.busy = nil
	W.Refresh()
	W.Next()
end

function W.Line(f)
	local k = f[1]
	if k == "ERR" then
		W.error = W.Reason(f[3])
	elseif k == "GO" then
		table.insert(W.guild.orders, { id = f[2], item = tonumber(f[3]), qty = tonumber(f[4]) or 1, state = f[5],
			bot = f[6] ~= "-" and f[6] or nil, at = tonumber(f[7]) or 0, cod = tonumber(f[8]) or 0, reason = f[9] ~= "-" and f[9] or nil })
	elseif k == "GG" then
		table.insert(W.guild.gifts, { item = tonumber(f[2]), bot = f[3], at = tonumber(f[4]) or 0 })
	elseif k == "AB" then
		local bot = f[5] and { name = f[2], level = tonumber(f[3]), zone = f[4], skills = W.Skills(f[5]) }
			or { name = f[2], skills = W.Skills(f[3]) }
		if #bot.skills > 0 then table.insert(W.art.bots, bot) end
	elseif k == "AR" then
		local item = tonumber(f[3])
		if item and f[8] and f[8] ~= "" then W.names[item] = f[8] end
		table.insert(W.art.recipes, { bot = f[2], item = item, spell = tonumber(f[4]), skill = tonumber(f[5]),
			quality = tonumber(f[6]), rank = tonumber(f[7] or "") })
	elseif k == "ARR" then
		local item = tonumber(f[3])
		if item then
			local list = {}
			for id, count in (f[4] or ""):gmatch("(%d+):(%d+)") do table.insert(list, { item = tonumber(id), count = tonumber(count) }) end
			W.art.reagents = W.art.reagents or {}
			W.art.reagents[item] = list
		end
	elseif k == "AQ" then
		W.art.quote = { bot = f[2], item = tonumber(f[3]), qty = tonumber(f[4]) or 1, copper = tonumber(f[5]) or 0,
			ok = f[6] == "ok", reason = f[6], id = f[7] }
		if not W.art.quote.ok then W.error = W.Reason(f[6]) end
		if W.art.quote.ok and W.art.asked and W.art.quote.qty < W.art.asked then
			W.art.maxQty = W.art.quote.qty
			W.art.quote.capped = true
		end
	elseif k == "AO" then
		-- 3.0 (fb83b3fd): "preparing", then the order's AM line; "mailed" from an older server.
		if f[3] == "preparing" or f[3] == "mailed" then
			W.art.quote = nil
			if f[3] == "mailed" then W.Send("AMAIL", "art") end
		else
			W.error = W.Reason(f[3])
			if f[3] == "price" or f[3] == "expired" then W.art.quote = nil end
		end
	elseif k == "AM" then
		local m = { id = f[2], bot = f[3], item = tonumber(f[4]), qty = tonumber(f[5]) or 1,
			copper = tonumber(f[6]) or 0, at = tonumber(f[7]) or 0, state = f[8] == "pending" and "awaiting" or f[8],
			eta = tonumber(f[9] or "") or 0 }
		if W.art.bulk then
			table.insert(W.art.mails, m)
		else
			W.UpdateOrder(m)
		end
	elseif k == "GF" then
		local o = { id = f[2], item = tonumber(f[3]), bot = f[4], at = tonumber(f[5]) or 0, expires = tonumber(f[6]) or 0,
			reason = f[7] }
		if W.guild.bulk then
			table.insert(W.guild.offers, o)
		else
			-- A new offer, pushed: on top, and said in the chat.
			for i = #W.guild.offers, 1, -1 do if W.guild.offers[i].id == o.id then table.remove(W.guild.offers, i) end end
			table.insert(W.guild.offers, 1, o)
			if DEFAULT_CHAT_FRAME then
				DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Manager|r: " .. string.format(T("GF_CHAT"), o.bot or "?",
					W.Colored(o.item), W.GiftReason(o.reason)))
			end
		end
	elseif k == "GC" then
		local item = tonumber(f[2])
		if item and f[12] and f[12] ~= "" then W.names[item] = f[12] end
		table.insert(W.guild.cat.list, { item = item, source = f[3], bot = f[4], qty = tonumber(f[5]) or 0,
			price = tonumber(f[6]) or 0, quality = tonumber(f[7]), ilvl = tonumber(f[8]) or 0, req = tonumber(f[9]) or 0,
			slot = tonumber(f[10]) or 0, skill = tonumber(f[11]) or 0 })
	elseif k == "GCN" then
		W.guild.cat.total, W.guild.cat.page = tonumber(f[2]) or 0, tonumber(f[3]) or 1
	elseif k == "GA" then
		W.guild.acts[f[2] or "?"] = { state = f[3], bots = tonumber(f[4]) or 0, untilAt = tonumber(f[5]) or 0 }
	elseif k == "WE" then
		local id = f[3]
		for i = #W.events.list, 1, -1 do if W.events.list[i].id == id then table.remove(W.events.list, i) end end
		if f[4] ~= "end" then
			table.insert(W.events.list, { kind = f[2], id = id, state = f[4], zone = f[5], place = f[6],
				at = tonumber(f[7]) or 0, name = f[8] })
		end
	elseif k == "WGM" then
		W.events.gm = f[2] == "1"
	elseif k == "WF" then
		table.insert(W.events.firsts, { kind = f[2], entry = f[3], team = f[4], who = f[5], guild = f[6] ~= "-" and f[6] or nil,
			at = tonumber(f[7]) or 0 })
	end
end

-- A pushed order line: replaces its order (newest first), and a line in the chat when its state changed.
function W.UpdateOrder(m)
	local old
	for i, x in ipairs(W.art.mails) do
		if x.id == m.id then old = x; table.remove(W.art.mails, i) break end
	end
	table.insert(W.art.mails, 1, m)
	if old and old.state == m.state then return end
	local what = W.Colored(m.item) .. (m.qty > 1 and (" x" .. m.qty) or "")
	local text
	if m.state == "sent" and m.eta > time() then
		text = string.format(T("M_CHAT_ETA"), what, m.bot or "?", W.Duration(m.eta - time()))
	else
		text = string.format(T("M_CHAT"), what, m.bot or "?", T("M_" .. (m.state or "")))
	end
	if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Manager|r: " .. text) end
end

function W.GM(command)
	W.gmOut, W.gmUntil = {}, GetTime() + 3
	SendChatMessage(".coaworld " .. command, "SAY")
	W.Refresh()
end

function W.OnSystem(message)
	if not W.gmUntil or GetTime() > W.gmUntil or not message then return end
	W.gmOut = W.gmOut or {}
	table.insert(W.gmOut, message)
	while #W.gmOut > 4 do table.remove(W.gmOut, 1) end
	W.Refresh()
end

-- The 6 s rule, and the countdowns.
function W.Tick()
	W.Next()
	if W.busy and GetTime() - W.busy.sentAt > WAIT then
		local q = W.busy
		W.busy, W.lines = nil, {}
		if q.feature then W.off[q.feature] = true end
		W.Refresh()
		W.Next()
	end
end

-- ---------------------------------------------------------------------------
-- Soul: asked once per bot and session, to the bot itself.
-- ---------------------------------------------------------------------------
function W.Soul(name)
	if not name then return end
	if W.soul[name] then return W.soul[name] end
	if not W.soulAsked[name] then
		W.soulAsked[name] = true
		SendAddonMessage(PREFIX, "SOUL?", "WHISPER", name)
	end
end

-- "Quester: pace 40, sociability 70, ..." or nil.
function W.SoulText(name)
	local s = W.soul[name]
	if not s then return end
	return (T("ARCH_" .. (s.arch or "")) ~= "ARCH_" .. (s.arch or "") and T("ARCH_" .. s.arch) or (s.arch or "?")),
		string.format(T("TRAITS"), s.pace, s.soc, s.cur, s.greed, s.aggr)
end

-- ---------------------------------------------------------------------------
-- The panel
-- ---------------------------------------------------------------------------
-- The bot sheet's button style: a small icon left of the name, the name a size smaller (Manager.lua's tabs).
W.ICONS = { art = "Interface\\Icons\\Trade_BlackSmithing", guild = "Interface\\Icons\\INV_Shirt_GuildTabard_01",
	events = "Interface\\Icons\\Ability_DualWield", mails = "Interface\\Icons\\INV_Letter_15",
	back = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", order = "Interface\\Icons\\INV_Misc_Coin_02",
	filter = "Interface\\Icons\\INV_Misc_Spyglass_02", v_gifts = "Interface\\Icons\\INV_Holiday_Christmas_Present_01",
	v_cat = "Interface\\Icons\\INV_Misc_Book_09", v_act = "Interface\\Icons\\Ability_Warrior_BattleShout",
	v_orders = "Interface\\Icons\\INV_Letter_15", start = "Interface\\Icons\\Ability_Warrior_BattleShout",
	cancel = "Interface\\Icons\\Spell_ChargeNegative", thanks = "Interface\\Icons\\INV_ValentinesCard02" }
-- Three tabs (18 + 3 x 116) and the right button (124) fit the 520 px panel with room between.
W.BUTTON_W, W.BUTTON_H = 110, 24

function W.StyleButton(b, icon)
	b:SetNormalFontObject(GameFontNormalSmall)
	b:SetHighlightFontObject(GameFontHighlightSmall)
	b:SetDisabledFontObject(GameFontDisableSmall)
	b:SetPushedTextOffset(0, 0)
	b.tabIcon = b:CreateTexture(nil, "OVERLAY")
	b.tabIcon:SetWidth(16)
	b.tabIcon:SetHeight(16)
	b.tabIcon:SetPoint("LEFT", 7, 0)
	W.SetIcon(b, icon)
end

function W.SmallBox(parent, name, width)
	local box = CreateFrame("EditBox", name, parent)
	box:SetWidth(width or 32)
	box:SetHeight(20)
	box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
	box:SetBackdropColor(0.04, 0.04, 0.05, 0.95)
	box:SetBackdropBorderColor(1, 0.82, 0, 0.6)
	box:SetFontObject(GameFontHighlightSmall)
	box:SetTextInsets(4, 4, 0, 0)
	box:SetJustifyH("CENTER")
	box:SetAutoFocus(false)
	box:SetNumeric(true)
	box:SetMaxLetters(2)
	box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	box:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(1, 0.82, 0, 1) end)
	box.Clamp = function(self)
		local n = tonumber(self:GetText() or "")
		if n and self.max and n > self.max then self:SetText(tostring(self.max)) end
	end
	box:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(1, 0.82, 0, 0.6) end)
	return box
end

function W.SetIcon(b, icon)
	b.tabIcon:SetTexture(icon)
	if icon and icon:find("Icons") then b.tabIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) else b.tabIcon:SetTexCoord(0, 1, 0, 1) end
end

-- After SetText: the name right of the icon.
function W.PlaceText(b)
	local text = b:GetFontString()
	if text then
		text:ClearAllPoints()
		text:SetPoint("LEFT", b.tabIcon, "RIGHT", 5, 0)
		text:SetPoint("RIGHT", -6, 0)
		text:SetJustifyH("LEFT")
	end
end

local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }

function W.Build()
	local f = CreateFrame("Frame", "SquidBotsLiteWorld", UIParent)
	W.frame = f
	-- 680 wide (3.0, the user's test): the artisans' professions fit in full.
	f:SetWidth(680)
	f:SetHeight(500)
	f:SetPoint("CENTER", 0, 40)
	f:SetBackdrop(BACKDROP)
	f:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
	f:SetFrameStrata("DIALOG")
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:Hide()
	table.insert(UISpecialFrames, "SquidBotsLiteWorld")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	f.tabs = {}
	for i, key in ipairs({ "art", "guild", "events" }) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetWidth(W.BUTTON_W)
		b:SetHeight(W.BUTTON_H)
		b:SetPoint("TOPLEFT", 18 + (i - 1) * (W.BUTTON_W + 6), -38)
		W.StyleButton(b, W.ICONS[key])
		b:SetScript("OnClick", function() W.tab = key; W.offset = 0; W.Load() end)
		b.key = key
		f.tabs[i] = b
	end
	-- The guild's order line: item box (link or id), quantity, Order.
	f.item = CreateFrame("EditBox", "SquidBotsLiteWorldItem", f, "InputBoxTemplate")
	f.item:SetWidth(230)
	f.item:SetHeight(20)
	f.item:SetPoint("TOPLEFT", 24, -70)
	f.item:SetAutoFocus(false)
	f.item:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f.item:SetScript("OnEnterPressed", function() W.Order() end)
	f.item:SetScript("OnTextChanged", function(self) if self:GetText() ~= "" then W.askItem = nil end; W.Refresh() end)
	f.itemHint = f.item:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.itemHint:SetPoint("LEFT", 4, 0)
	f.qty = W.SmallBox(f, "SquidBotsLiteWorldQty", 32)
	f.qty:SetPoint("LEFT", f.item, "RIGHT", 40, 0)
	f.qty:SetAutoFocus(false)
	f.qty:SetNumeric(true)
	f.qty:SetText("1")
	f.qty:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f.qtyLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.qtyLabel:SetPoint("RIGHT", f.qty, "LEFT", -8, 0)
	f.action = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.action:SetWidth(W.BUTTON_W)
	f.action:SetHeight(W.BUTTON_H)
	W.StyleButton(f.action, W.ICONS.order)
	f.action:SetPoint("LEFT", f.qty, "RIGHT", 12, 0)
	f.action:SetScript("OnClick", function() W.Action() end)
	f.action2 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.action2:SetWidth(W.BUTTON_W + 14)
	f.action2:SetHeight(W.BUTTON_H)
	f.action2:SetPoint("TOPRIGHT", -18, -38)
	W.StyleButton(f.action2, W.ICONS.mails)
	f.action2:SetScript("OnClick", function() W.Action2() end)
	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("TOPLEFT", 20, -96)
	f.hint:SetWidth(640)
	f.hint:SetJustifyH("LEFT")
	f.rows = {}
	local UI = SquidBotsLite_UI
	for i = 1, ROWS do
		local row = CreateFrame("Button", nil, f)
		row:SetWidth(W.CARD_W)
		row:SetHeight(36)
		row:SetPoint("TOPLEFT", 16, -146 - (i - 1) * 39)
		-- The card of My alts: a dark plate, its edge lights up under the mouse (a section title has none).
		row:SetBackdrop(UI and UI.CARD or { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(28)
		row.icon:SetHeight(28)
		row.icon:SetPoint("LEFT", 5, 0)
		row.left = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.left:SetWidth(280)
		row.left:SetJustifyH("LEFT")
		row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		row.sub:SetPoint("TOPLEFT", row.left, "BOTTOMLEFT", 0, -2)
		row.sub:SetWidth(280)
		row.sub:SetJustifyH("LEFT")
		row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.right:SetPoint("LEFT", 330, 0)
		row.right:SetWidth(250)
		row.right:SetHeight(30)
		row.right:SetJustifyH("LEFT")
		-- Accept / Decline (gifts), Start / Cancel (activities).
		for j = 1, 2 do
			local b = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			b:SetWidth(80)
			b:SetHeight(20)
			b:SetNormalFontObject(GameFontNormalSmall)
			b:SetHighlightFontObject(GameFontHighlightSmall)
			b:SetDisabledFontObject(GameFontDisableSmall)
			b:SetScript("OnClick", function(self) if self.run then self.run() end end)
			b:Hide()
			row["b" .. j] = b
		end
		-- The artisans' professions: an icon and its rank each, the name in the tooltip.
		row.skills = {}
		for j = 1, 6 do
			local sk = CreateFrame("Frame", nil, row)
			sk:SetWidth(52)
			sk:SetHeight(20)
			sk:SetPoint("LEFT", 300 + (j - 1) * 54, 0)
			sk.icon = sk:CreateTexture(nil, "ARTWORK")
			sk.icon:SetWidth(18)
			sk.icon:SetHeight(18)
			sk.icon:SetPoint("LEFT", 0, 0)
			sk.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			sk.text = sk:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			sk.text:SetPoint("LEFT", sk.icon, "RIGHT", 3, 0)
			sk:EnableMouse(true)
			sk:SetScript("OnEnter", function(self)
				if self.reagent then
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					GameTooltip:SetHyperlink("item:" .. self.reagent.item)
					GameTooltip:AddLine(self.reagent.count .. " x " .. W.ItemName(self.reagent.item), 1, 1, 1)
					GameTooltip:Show()
					return
				end
				if not self.skill then return end
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:SetText(W.SkillName(self.skill.id), 1, 0.82, 0)
				GameTooltip:AddLine(tostring(self.skill.value), 1, 1, 1)
				GameTooltip:Show()
			end)
			sk:SetScript("OnLeave", function() GameTooltip:Hide() end)
			sk:Hide()
			row.skills[j] = sk
		end
		-- The card's icon button, at its right (My alts' style): an artisan's recipes, a recipe's quote.
		if UI and UI.IconButton then
			row.go = UI.IconButton(row, 24, W.ICONS.order, function(self) return self.tipTitle, self.tipLine end,
				function(self) if self.run then self.run() end end)
			row.go:SetPoint("RIGHT", -8, 0)
			row.go:Hide()
		end
		row.qty = W.SmallBox(row, nil, 32)
		row.qty:SetPoint("RIGHT", -42, 0)
		row.qty:SetScript("OnTextChanged", function(self)
			self:Clamp()
			if self.key then W.cardQty[self.key] = self:GetText() end
		end)
		row.qty:Hide()
		row:SetScript("OnClick", function(self) if self.click then self.click() end end)
		row:SetScript("OnEnter", function(self)
			if not self.header then self:SetBackdropBorderColor(1, 0.82, 0, 0.55) end
			if self.item then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink("item:" .. self.item)
				GameTooltip:Show()
			elseif self.tip then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(self.tip, 1, 1, 1, 1, true)
				GameTooltip:Show()
			end
		end)
		row:SetScript("OnLeave", function(self)
			if not self.header then self:SetBackdropBorderColor(1, 1, 1, 0.08) end
			GameTooltip:Hide()
		end)
		row:EnableMouseWheel(true)
		row:SetScript("OnMouseWheel", function(_, delta) W.Scroll(-delta) end)
		f.rows[i] = row
	end
	-- The scroll bar: a thin dark track and a gold thumb right of the cards; the wheel works on the cards too.
	f.bar = CreateFrame("Slider", "SquidBotsLiteWorldScroll", f)
	f.bar:SetWidth(8)
	f.bar:SetOrientation("VERTICAL")
	f.bar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
	f.bar:SetBackdropColor(0.04, 0.04, 0.05, 0.9)
	f.bar:SetBackdropBorderColor(1, 1, 1, 0.08)
	local thumb = f.bar:CreateTexture(nil, "OVERLAY")
	thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
	thumb:SetVertexColor(1, 0.82, 0, 0.7)
	thumb:SetWidth(8)
	thumb:SetHeight(28)
	f.bar:SetThumbTexture(thumb)
	f.bar:SetPoint("TOPLEFT", f.rows[1], "TOPRIGHT", 8, 0)
	f.bar:SetPoint("BOTTOMLEFT", f.rows[ROWS], "BOTTOMRIGHT", 8, 0)
	f.bar:SetScript("OnValueChanged", function(self, value)
		value = math.floor((value or 0) + 0.5)
		if value ~= W.offset then W.offset = value; W.Refresh() end
	end)
	f.bar:SetValueStep(1)
	f.bar:SetMinMaxValues(0, 0)
	f.bar:SetValue(0)
	f.bar:EnableMouseWheel(true)
	f.bar:SetScript("OnMouseWheel", function(_, delta) W.Scroll(-delta) end)
	f.heads = {}
	for c, def in ipairs(W.COLUMNS) do
		local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		fs:SetPoint("BOTTOMLEFT", f.rows[1], "TOPLEFT", def[1], 2)
		fs:SetWidth(def[2])
		fs:SetJustifyH(c == 2 and "CENTER" or "LEFT")
		f.heads[c] = fs
	end
	f.filter = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.filter:SetWidth(190)
	f.filter:SetHeight(W.BUTTON_H)
	f.filter:SetPoint("TOPLEFT", 18, -68)
	W.StyleButton(f.filter, W.ICONS.filter)
	f.filter:SetScript("OnClick", function() W.FilterMenu() end)
	f.menu = CreateFrame("Frame", "SquidBotsLiteWorldMenu", UIParent, "UIDropDownMenuTemplate")
	-- The Guild tab: a banner (the guild, its members online, free bots, the activity under way with Cancel) holding the
	-- four views as smaller buttons, apart from the main tabs.
	local banner = CreateFrame("Frame", nil, f)
	f.banner = banner
	banner:SetWidth(646)
	banner:SetHeight(64)
	banner:SetPoint("TOPLEFT", 16, -68)
	banner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
	banner:SetBackdropColor(0.16, 0.12, 0.03, 0.9)
	banner:SetBackdropBorderColor(1, 0.82, 0, 0.35)
	banner.icon = banner:CreateTexture(nil, "ARTWORK")
	banner.icon:SetWidth(20)
	banner.icon:SetHeight(20)
	banner.icon:SetPoint("TOPLEFT", 10, -8)
	banner.icon:SetTexture(W.ICONS.guild)
	banner.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	banner.name = banner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	banner.name:SetPoint("LEFT", banner.icon, "RIGHT", 6, 0)
	banner.info = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	banner.info:SetPoint("LEFT", banner.name, "RIGHT", 12, 0)
	banner.act = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	banner.act:SetPoint("TOPRIGHT", -38, -12)
	local UIs = SquidBotsLite_UI
	if UIs and UIs.IconButton then
		banner.cancel = UIs.IconButton(banner, 20, W.ICONS.cancel, function() return T("GA_CANCEL"), W.guild.runningName end, function()
			if not W.guild.running then return end
			W.Confirm(string.format(T("ASK_CANCEL"), T("GA_" .. W.guild.running)), function() W.Send("GACT\tcancel", "act") end)
		end)
		banner.cancel:SetPoint("TOPRIGHT", -10, -8)
		banner.cancel:Hide()
	end
	f.views = {}
	for i, key in ipairs({ "orders", "cat", "act", "gifts" }) do
		local b = CreateFrame("Button", nil, banner, "UIPanelButtonTemplate")
		b:SetWidth(104)
		b:SetHeight(18)
		b:SetPoint("BOTTOMLEFT", 10 + (i - 1) * 110, 8)
		W.StyleButton(b, W.ICONS["v_" .. key])
		b.tabIcon:SetWidth(12)
		b.tabIcon:SetHeight(12)
		-- The view shown: a gold bar under its button.
		b.mark = b:CreateTexture(nil, "OVERLAY")
		b.mark:SetTexture("Interface\\Buttons\\WHITE8X8")
		b.mark:SetVertexColor(1, 0.82, 0, 0.9)
		b.mark:SetHeight(2)
		b.mark:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 4, -1)
		b.mark:SetPoint("TOPRIGHT", b, "BOTTOMRIGHT", -4, -1)
		b:SetScript("OnClick", function() W.guild.mode = key; W.offset = 0; W.error = nil; W.Load() end)
		b:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
			GameTooltip:SetText(T("V_" .. key), 1, 0.82, 0)
			GameTooltip:AddLine(T("TIP_V_" .. key), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		b:SetScript("OnLeave", function() GameTooltip:Hide() end)
		b.key = key
		f.views[i] = b
	end
	-- Ask the guild: a box to drop the item on (shift-click or drag), its icon and name once known.
	local drop = CreateFrame("Button", nil, f)
	f.drop = drop
	drop:SetWidth(330)
	drop:SetHeight(44)
	drop:SetPoint("TOPLEFT", 16, -140)
	drop:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
	drop:SetBackdropColor(0.09, 0.09, 0.11, 0.95)
	drop:SetBackdropBorderColor(1, 0.82, 0, 0.5)
	drop.icon = drop:CreateTexture(nil, "ARTWORK")
	drop.icon:SetWidth(36)
	drop.icon:SetHeight(36)
	drop.icon:SetPoint("LEFT", 4, 0)
	drop.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	drop.text = drop:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	drop.text:SetPoint("LEFT", drop.icon, "RIGHT", 8, 0)
	drop.text:SetWidth(270)
	drop.text:SetJustifyH("LEFT")
	local function take()
		local kind, id = GetCursorInfo()
		if kind == "item" and id then
			W.askItem = id
			ClearCursor()
			if W.frame then W.frame.item:SetText("") end
			W.Refresh()
		end
	end
	drop:SetScript("OnReceiveDrag", take)
	drop:SetScript("OnClick", take)
	drop:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(1, 0.82, 0, 1)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		if W.askItem then GameTooltip:SetHyperlink("item:" .. W.askItem) else GameTooltip:SetText(T("G_HINT"), 1, 1, 1, 1, true) end
		GameTooltip:Show()
	end)
	drop:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(1, 0.82, 0, 0.5); GameTooltip:Hide() end)
	f.askLine = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.askLine:SetPoint("TOPLEFT", drop, "BOTTOMLEFT", 2, -4)
	f.askLine:SetWidth(640)
	f.askLine:SetJustifyH("LEFT")
	-- The catalogue's line: search, slot, usable now, pages.
	f.search = CreateFrame("EditBox", "SquidBotsLiteWorldSearch", f, "InputBoxTemplate")
	f.search:SetWidth(200)
	f.search:SetHeight(20)
	f.search:SetPoint("TOPLEFT", 24, -142)
	f.search:SetAutoFocus(false)
	f.search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f.search:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		W.guild.cat.search = strtrim(self:GetText() or "")
		W.offset = 0
		W.CatPage(1)
	end)
	f.search:SetScript("OnEditFocusGained", function() W.Refresh() end)
	f.search:SetScript("OnEditFocusLost", function() W.Refresh() end)
	f.searchHint = f.search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.searchHint:SetPoint("LEFT", 4, 0)
	f.slotBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.slotBtn:SetWidth(170)
	f.slotBtn:SetHeight(W.BUTTON_H)
	f.slotBtn:SetPoint("LEFT", f.search, "RIGHT", 12, 0)
	W.StyleButton(f.slotBtn, W.ICONS.filter)
	f.slotBtn:SetScript("OnClick", function() W.SlotMenu() end)
	f.usable = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
	f.usable:SetWidth(22)
	f.usable:SetHeight(22)
	f.usable:SetPoint("LEFT", f.slotBtn, "RIGHT", 8, 0)
	f.usable:SetScript("OnClick", function(self) W.guild.cat.usable = self:GetChecked() and true or false; W.offset = 0; W.Refresh() end)
	f.usableText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.usableText:SetPoint("LEFT", f.usable, "RIGHT", 2, 0)
	f.prev = CreateFrame("Button", nil, f, "UIPanelScrollUpButtonTemplate")
	f.prev:SetPoint("TOPRIGHT", -150, -142)
	f.prev:SetScript("OnClick", function() W.CatPage(W.guild.cat.page - 1) end)
	f.next = CreateFrame("Button", nil, f, "UIPanelScrollDownButtonTemplate")
	f.next:SetPoint("TOPRIGHT", -20, -142)
	f.next:SetScript("OnClick", function() W.CatPage(W.guild.cat.page + 1) end)
	f.pageText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.pageText:SetPoint("LEFT", f.prev, "RIGHT", 6, 0)
	f.pageText:SetPoint("RIGHT", f.next, "LEFT", -6, 0)
	f.pageText:SetJustifyH("CENTER")
	-- The quote, in big (3.0, the user's test): item, quantity, price, artisan, and Order.
	local card = CreateFrame("Frame", nil, f)
	f.card = card
	card:SetWidth(634)
	card:SetHeight(74)
	card:SetPoint("BOTTOMLEFT", 14, 40)
	card:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, edgeSize = 14, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
	card:SetBackdropColor(0.12, 0.1, 0.02, 0.95)
	card:SetBackdropBorderColor(1, 0.82, 0, 0.9)
	card.icon = card:CreateTexture(nil, "ARTWORK")
	card.icon:SetWidth(44)
	card.icon:SetHeight(44)
	card.icon:SetPoint("LEFT", 12, 0)
	card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	card.title:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 10, 2)
	card.item = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	card.item:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -3)
	card.item:SetWidth(250)
	card.item:SetJustifyH("LEFT")
	card.price = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	card.price:SetPoint("TOPLEFT", card.item, "BOTTOMLEFT", 0, -4)
	card.cod = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	card.cod:SetPoint("BOTTOMRIGHT", -12, 8)
	card.order = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
	card.order:SetWidth(W.BUTTON_W)
	card.order:SetHeight(26)
	W.StyleButton(card.order, W.ICONS.order)
	card.order:SetPoint("TOPRIGHT", -12, -12)
	card.order:SetScript("OnClick", function() W.Action() end)
	card:Hide()
	local gm = CreateFrame("Frame", nil, f)
	f.gm = gm
	gm:SetWidth(646)
	gm:SetHeight(100)
	gm:SetPoint("BOTTOMLEFT", 16, 40)
	gm:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
	gm:SetBackdropColor(0.15, 0.04, 0.04, 0.9)
	gm:SetBackdropBorderColor(1, 0.3, 0.3, 0.5)
	gm.title = gm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	gm.title:SetPoint("TOPLEFT", 8, -6)
	gm.labels, gm.buttons = {}, {}
	local function Button(x, y, key, command)
		local b = CreateFrame("Button", nil, gm, "UIPanelButtonTemplate")
		b:SetWidth(58)
		b:SetHeight(18)
		b:SetPoint("TOPLEFT", x, y)
		b:SetNormalFontObject(GameFontNormalSmall)
		b:SetHighlightFontObject(GameFontHighlightSmall)
		b:SetScript("OnClick", function() W.GM(command) end)
		b.key = key
		table.insert(gm.buttons, b)
	end
	local function Label(x, y, key)
		local l = gm:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		l:SetPoint("TOPLEFT", x, y)
		l.key = key
		table.insert(gm.labels, l)
	end
	-- Invasions: List, Next; then Start / Stop for each of the three.
	Label(50, -9, "GM_INV")
	Button(130, -6, "GM_LIST", "invasion list")
	Button(190, -6, "GM_NEXT", "invasion next")
	for i, key in ipairs({ "scourge", "legion", "aq" }) do
		local x = 260 + (i - 1) * 128
		Label(x, -30, "GM_" .. key)
		Button(x, -42, "GM_START", "invasion start " .. key)
		Button(x + 60, -42, "GM_STOP", "invasion stop " .. key)
	end
	-- Capital raid: List, Start on Stormwind or Orgrimmar, Stop.
	Label(262, -9, "GM_CRAID")
	Button(352, -6, "GM_LIST", "capitalraid list")
	Button(412, -6, "GM_SW", "capitalraid start stormwind")
	Button(472, -6, "GM_ORG", "capitalraid start orgrimmar")
	Button(532, -6, "GM_STOP", "capitalraid stop")
	-- Gold rush: Start (in the open world), Stop, Status.
	Label(8, -30, "GM_RUSH")
	Button(8, -42, "GM_START", "rush start")
	Button(68, -42, "GM_STOP", "rush stop")
	Button(128, -42, "GM_STATUS", "rush status")
	gm.out = gm:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	gm.out:SetPoint("TOPLEFT", 8, -66)
	gm.out:SetWidth(630)
	gm.out:SetHeight(30)
	gm.out:SetJustifyH("LEFT")
	gm.out:SetJustifyV("TOP")
	gm:Hide()
	f.status = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.status:SetPoint("BOTTOMLEFT", 22, 20)
	f.status:SetWidth(630)
	f.status:SetJustifyH("LEFT")
	f:SetScript("OnUpdate", function(self, delta)
		self.t = (self.t or 0) + delta
		if self.t < 1 then return end
		self.t = 0
		local moving = false
		for _, m in ipairs(W.art.mails) do if m.state == "preparing" or m.state == "sent" then moving = true end end
		if W.tab == "events" or next(W.waiting) or (W.tab == "art" and moving) or (W.tab == "guild" and W.guild.mode ~= "orders") then W.Refresh() end
	end)
end

-- Shift-click an item into the box while it has the focus (the client fills only a chat box otherwise).
local insertLink = ChatEdit_InsertLink
ChatEdit_InsertLink = function(link, ...)
	local box = W.frame and W.frame.item
	local id = link and tonumber(link:match("|Hitem:(%d+)"))
	if id and W.frame and W.frame:IsShown() and W.tab == "guild" and W.guild.mode == "orders" then
		W.askItem = id
		box:SetText("")
		box:ClearFocus()
		W.Refresh()
		return true
	end
	if link and box and box:IsVisible() and box:HasFocus() then
		box:SetText(link)
		return true
	end
	return insertLink(link, ...)
end

-- The cards' width (the scroll bar right of them), and a few old column headers kept empty.
W.CARD_W = 612
W.COLUMNS = { { 28, 130 }, { 160, 34 }, { 200, 136 }, { 342, 240 } }

-- One step of the list (the wheel, the bar's arrows).
function W.Scroll(delta)
	W.offset = math.max(0, math.min(math.max(0, (W.count or 0) - (W.shown or ROWS)), W.offset + (delta or 0)))
	W.Refresh()
end

-- The professions the artisans have, to filter on.
function W.FilterMenu()
	local seen, ids = {}, {}
	for _, b in ipairs(W.art.bots) do
		for _, sk in ipairs(b.skills) do if not seen[sk.id] then seen[sk.id] = true; table.insert(ids, sk.id) end end
	end
	table.sort(ids, function(a, b) return W.SkillName(a) < W.SkillName(b) end)
	local items = { { text = T("A_ALL"), checked = W.art.skill == nil, func = function() W.art.skill = nil; W.offset = 0; W.Refresh() end } }
	for _, id in ipairs(ids) do
		table.insert(items, { text = W.SkillName(id), icon = SKILL_ICON[id] and ("Interface\\Icons\\" .. SKILL_ICON[id]) or nil,
			checked = W.art.skill == id, func = function() W.art.skill = id; W.offset = 0; W.Refresh() end })
	end
	EasyMenu(items, W.frame.menu, "cursor", 0, 0, "MENU")
end

function W.Toggle()
	if not W.frame then W.Build() end
	if W.frame:IsShown() then W.frame:Hide() else W.frame:Show(); W.Load() end
end

-- Each tab asks its list when opened, at most every 10 s (the server caches 10 s anyway).
function W.Ask(request, feature)
	local key = request
	if W.at[key] and GetTime() - W.at[key] < 10 then return end
	W.at[key] = GetTime()
	W.Send(request, feature)
end

function W.Load()
	W.error = nil
	if W.tab == "guild" then
		local mode = W.guild.mode
		if GuildRoster then GuildRoster() end
		if mode ~= "act" then W.Ask("GACT?", "act") end
		if mode == "gifts" then W.Ask("GOFF", "gifts"); W.Ask("GLIST", "guild")
		elseif mode == "cat" then W.Ask("GCAT\t" .. W.guild.cat.search .. "\t" .. W.guild.cat.page, "cat")
		elseif mode == "act" then W.Ask("GACT?", "act")
		else W.Ask("GLIST", "guild") end
	elseif W.tab == "art" then
		if W.art.mode == "mails" then W.Ask("AMAIL", "art")
		elseif W.art.mode == "recipes" and W.art.bot then W.Ask("ARCP\t" .. W.art.bot, "art")
		else W.art.mode = "bots"; W.Ask("ALIST", "art") end
	else W.Ask("WEV?", "events") end
	W.Refresh()
end

-- The item of the box: a link's id, or a number.
function W.BoxItem()
	if W.askItem and W.tab == "guild" then return W.askItem end
	local text = W.frame and W.frame.item:GetText() or ""
	return tonumber(text:match("|Hitem:(%d+)") or text:match("^%s*(%d+)%s*$"))
end

W.cardQty = {}
function W.CardQty(key, max)
	local n = tonumber(W.cardQty[key] or "") or 1
	return math.max(1, math.min(max, n))
end

function W.Qty(max)
	local n = tonumber(W.frame.qty:GetText() or "") or 1
	return math.max(1, math.min(max, n))
end

-- A yes / no popup before an order goes out (3.0, the user's test): text, then what Yes does.
function W.Confirm(text, onYes)
	StaticPopupDialogs.SQUIDBOTSLITE_WORLD_ORDER = {
		text = text, button1 = T("YES"), button2 = T("NO"), OnAccept = onYes,
		timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true,
	}
	StaticPopup_Show("SQUIDBOTSLITE_WORLD_ORDER")
end

-- The guild order: its price is only known once a bot answers (free from a bag, or cash on delivery), so the
-- popup says it may cost.
function W.Order()
	local item = W.BoxItem()
	if not item then return end
	local qty = W.Qty(20)
	W.frame.item:ClearFocus()
	W.Confirm(string.format(T("ASK_GUILD"), qty, W.Colored(item)), function()
		W.Send("GORD\t" .. item .. "\t" .. qty, "guild")
		W.askItem = nil
		if W.frame then W.frame.item:SetText(""); W.frame.qty:SetText("1") end
	end)
end

-- The tab's button: Order (guild), Quote / Order (artisans).
function W.Action()
	if W.tab == "guild" then W.Order()
	elseif W.tab == "art" then
		local q = W.art.quote
		if q and q.ok then
			-- The price of the last quote; the server checks it again (more than 10 % up: "price", a new quote).
			W.Confirm(string.format(T("ASK_ART"), q.qty, W.Colored(q.item), q.bot or "?", W.Money(q.copper)), function()
				W.Send("AORDER\t" .. q.id, "art")
				W.cardQty["r" .. tostring(q.item)] = nil
				if W.frame then W.frame.qty:SetText("1") end
			end)
		elseif W.art.pick then
			W.art.asked = W.CardQty("r" .. W.art.pick.item, W.art.maxQty or 20)
			W.Send("AQUOTE\t" .. W.art.pick.bot .. "\t" .. W.art.pick.item .. "\t" .. W.art.asked, "art")
		end
	end
end

-- The top-right button of the Artisans tab: back to the artisans, or the CoD mails.
function W.Action2()
	if W.tab ~= "art" then return end
	if W.art.mode == "bots" then W.art.mode = "mails" else W.art.mode = "bots" end
	W.art.pick, W.art.quote, W.offset = nil, nil, 0
	W.at.ALIST, W.at.AMAIL = nil, nil
	W.Load()
end

function W.Feature()
	if W.tab ~= "guild" then return W.tab end
	return ({ gifts = "gifts", cat = "cat", act = "act" })[W.guild.mode] or "guild"
end

W.ACTS = { "gather", "party5", "raid10", "raid15", "raid25" }

-- The catalogue: a page asked to the server (its search), the slot and level filtered here.
function W.CatPage(page)
	local c = W.guild.cat
	c.page = math.max(1, page or 1)
	W.at["GCAT\t" .. c.search .. "\t" .. c.page] = nil
	W.Ask("GCAT\t" .. c.search .. "\t" .. c.page, "cat")
end

function W.SlotMenu()
	local seen, slots = {}, {}
	for _, x in ipairs(W.guild.cat.list) do
		local name = W.SlotName(x.slot)
		if not seen[name] then seen[name] = true; table.insert(slots, { name = name, slot = x.slot }) end
	end
	table.sort(slots, function(a, b) return a.name < b.name end)
	local items = { { text = T("A_ALL"), checked = W.guild.cat.slot == nil, func = function() W.guild.cat.slot = nil; W.offset = 0; W.Refresh() end } }
	for _, x in ipairs(slots) do
		table.insert(items, { text = x.name, checked = W.guild.cat.slot == x.name,
			func = function() W.guild.cat.slot = x.name; W.offset = 0; W.Refresh() end })
	end
	EasyMenu(items, W.frame.menu, "cursor", 0, 0, "MENU")
end

-- A recipe's second line: the level its item asks, else the skill rank it needs (above 1), else nothing.
function W.RecipeSub(r)
	local _, _, _, _, reqLevel = GetItemInfo(r.item or 0)
	if reqLevel and reqLevel > 1 then return string.format(T("GC_REQ"), reqLevel) end
	if r.rank and r.rank > 1 then return string.format(T("A_RANK"), W.SkillName(r.skill or 0), r.rank) end
	return ""
end

-- The rows of the tab: { icon, left, right, click, item, b1 = { text, enabled, click }, b2 }.
function W.Rows()
	local rows, now = {}, time()
	if W.tab == "guild" and W.guild.mode == "gifts" then
		for _, o in ipairs(W.guild.offers) do
			local by = string.format(T("GF_LINE"), o.bot or "?", W.GiftReason(o.reason), W.Ago(o.at))
			if o.expires > now then by = by .. "  |cffffd100" .. string.format(T("GF_EXPIRES"), W.Duration(o.expires - now)) .. "|r" end
			table.insert(rows, { item = o.item, left = W.Colored(o.item), right = "|cffaaaaaa" .. by .. "|r",
				b1 = { text = T("GF_ACCEPT"), click = function() W.Send("GACC\t" .. o.id, "gifts") end },
				b2 = { text = T("GF_DECLINE"), click = function() W.Send("GREF\t" .. o.id, "gifts") end } })
		end
		if #W.guild.offers == 0 then table.insert(rows, { left = "|cffaaaaaa" .. T("GF_NONE") .. "|r", right = "" }) end
		if #W.guild.gifts > 0 then table.insert(rows, { header = true, left = "|cffffd100" .. T("G_RECEIVED") .. "|r", right = "" }) end
		for _, g in ipairs(W.guild.gifts) do
			local key = (g.bot or "?") .. ":" .. tostring(g.item) .. ":" .. tostring(g.at)
			local thanked = W.guild.thanked[key]
			table.insert(rows, { item = g.item, left = W.Colored(g.item),
				sub = string.format(T("G_GIFT_LINE"), g.bot or "?", W.Ago(g.at)),
				right = thanked and ("|cff40ff40" .. T("G_THANKED") .. "|r") or "",
				go = not thanked and g.bot and { icon = W.ICONS.thanks, title = T("G_THANKS"), line = g.bot, click = function()
					-- A thank-you whispered to the bot that gave it (a bot of the guild, named by the server).
					SendChatMessage(string.format(T("THANKS_MSG"), W.ItemName(g.item)), "WHISPER", nil, g.bot)
					W.guild.thanked[key] = true
					W.Refresh()
				end } or nil })
		end
	elseif W.tab == "guild" and W.guild.mode == "cat" then
		local c, level = W.guild.cat, UnitLevel and UnitLevel("player") or 80
		for _, x in ipairs(c.list) do
			if (not c.slot or W.SlotName(x.slot) == c.slot) and (not c.usable or x.req <= level) then
				local source = x.source == "stock" and string.format(T("GC_STOCK"), x.bot or "?", x.qty)
					or string.format(T("GC_CRAFT"), x.bot or "?")
				local req = x.req > 0 and ("  " .. (x.req > level and "|cffff6060" or "|cffaaaaaa") .. string.format(T("GC_REQ"), x.req) .. "|r") or ""
				local key = "c" .. x.item
				local function order()
					local qty = W.CardQty(key, 20)
					W.Confirm(string.format(T("ASK_GUILD"), qty, W.Colored(x.item, x.quality)), function()
						W.Send("GORD\t" .. x.item .. "\t" .. qty, "guild")
						W.cardQty[key] = nil
						W.Refresh()
					end)
				end
				table.insert(rows, { item = x.item, left = W.Colored(x.item, x.quality), sub = W.SlotName(x.slot) .. req,
					right = "|cffaaaaaa" .. source .. "|r" .. (x.price > 0 and ("\n" .. W.Money(x.price)) or ""),
					qtyKey = key, go = { icon = W.ICONS.order, title = T("G_ORDER"), line = W.ItemName(x.item), click = order }, click = order })
			end
		end
		if #rows == 0 then table.insert(rows, { left = "|cffaaaaaa" .. T("GC_NONE") .. "|r", right = "" }) end
	elseif W.tab == "guild" and W.guild.mode == "act" then
		local running
		for _, kind in ipairs(W.ACTS) do
			local a = W.guild.acts[kind]
			if a and a.state == "busy" and a.untilAt > 0 then running = kind end
		end
		for _, kind in ipairs(W.ACTS) do
			local a = W.guild.acts[kind]
			local state = ""
			if a then
				if a.state == "cooldown" then
					state = ""
				elseif a.state == "busy" and kind == running then
					state = string.format(T("GS_LEFT"), W.Duration(a.untilAt - now))
				elseif a.state == "busy" and running then
					state = string.format(T("GS_blocked"), T("GA_" .. running))
				else
					state = T("GS_" .. (a.state or ""))
				end
				local color = a.state == "ready" and "|cff40ff40" or (a.state == "busy" and kind == running) and "|cffffd100"
					or a.state == "busy" and "|cffaaaaaa" or "|cffff6060"
				state = state ~= "" and (color .. state .. "|r") or ""
			end
			local ready = a and a.state == "ready"
			table.insert(rows, { left = T("GA_" .. kind), right = state, tip = T("GA_TIP"),
				iconPath = W.ICONS[kind == "gather" and "start" or kind == "party5" and "v_act" or "guild"],
				-- The running one (a rally): Cancel instead of Start (Monde 8ebe01b3, "GACT cancel"); Start only when ready.
				go = kind == running and { icon = W.ICONS.cancel, title = T("GA_CANCEL"), line = T("GA_" .. kind), click = function()
					W.Confirm(string.format(T("ASK_CANCEL"), T("GA_" .. kind)), function() W.Send("GACT\tcancel", "act") end)
				end } or { icon = W.ICONS.start, title = T("GA_START"), line = T("GA_" .. kind), disabled = not ready, click = function()
					W.Confirm(string.format(T("ASK_ACT"), T("GA_" .. kind)), function() W.Send("GACT\t" .. kind, "act") end)
				end } })
		end
	elseif W.tab == "guild" then
		-- Two parts, each with its title: my orders (and how each went), the gifts the guild sent me.
		local cleared = SquidBotsLiteDB and SquidBotsLiteDB.guildClearedAt or 0
		local recent = {}
		for _, o in ipairs(W.guild.orders) do
			if o.at > now - 86400 and o.at > cleared and #recent < 5 then table.insert(recent, o) end
		end
		table.insert(rows, { header = true, left = "|cffffd100" .. T("G_ORDERS") .. "|r", right = "",
			go = #recent > 0 and { icon = W.ICONS.cancel, title = T("G_CLEAR"), line = T("G_CLEAR_TIP"), click = function()
				SquidBotsLiteDB.guildClearedAt = time()
				W.Refresh()
			end } or nil })
		for _, o in ipairs(recent) do
			local state = T("S_" .. (o.state or "open"))
			if o.reason then state = state .. " : " .. W.Reason(o.reason) end
			if o.cod > 0 then state = state .. "  " .. W.Money(o.cod) end
			local color = (o.state == "refused" or o.state == "none") and "|cffff6060" or (o.state == "open") and "|cffaaaaaa" or "|cff40ff40"
			local by = o.bot and string.format(T("G_BY"), o.bot, W.Ago(o.at)) or W.Ago(o.at)
			-- The item and who / when on the left, the status alone in its column.
			table.insert(rows, { item = o.item, left = W.Colored(o.item) .. (o.qty > 1 and (" x" .. o.qty) or ""), sub = by,
				right = color .. state .. "|r" })
		end
		if #recent == 0 then table.insert(rows, { left = "|cffaaaaaa" .. T("G_NONE") .. "|r", right = "" }) end
	elseif W.tab == "art" then
		if W.art.mode == "bots" then
			for _, b in ipairs(W.art.bots) do
				local keep = not W.art.skill
				for _, sk in ipairs(b.skills) do if sk.id == W.art.skill then keep = true end end
				if keep then
				local where = {}
				if b.level then table.insert(where, string.format(T("GC_REQ"), b.level)) end
				if b.zone and b.zone ~= "" then table.insert(where, b.zone) end
				local function open()
					W.art.bot, W.art.mode, W.art.pick, W.art.quote, W.offset = b.name, "recipes", nil, nil, 0
					W.at["ARCP\t" .. b.name] = nil
					W.Load()
				end
				local mainSkill = b.skills[1] and b.skills[1].id
				table.insert(rows, { left = b.name, sub = table.concat(where, "  ·  "), skills = b.skills,
					iconPath = mainSkill and SKILL_ICON[mainSkill] and ("Interface\\Icons\\" .. SKILL_ICON[mainSkill]) or nil,
					go = { icon = W.ICONS.v_cat, title = T("A_QUOTE"), line = T("TIP_RECIPES"), click = open }, click = function()
					W.art.bot, W.art.mode, W.art.pick, W.art.quote, W.offset = b.name, "recipes", nil, nil, 0
					W.at["ARCP\t" .. b.name] = nil
					W.Load()
				end })
				end
			end
		elseif W.art.mode == "recipes" then
			local list = {}
			for _, r in ipairs(W.art.recipes) do table.insert(list, r) end
			table.sort(list, function(a, b)
				if a.skill ~= b.skill then return W.SkillName(a.skill or 0) < W.SkillName(b.skill or 0) end
				local ra, rb = a.rank or 0, b.rank or 0
				if ra ~= rb then return ra < rb end
				if (a.quality or 0) ~= (b.quality or 0) then return (a.quality or 0) < (b.quality or 0) end
				return (W.ItemName(a.item)) < (W.ItemName(b.item))
			end)
			local lastSkill
			for _, r in ipairs(list) do
				if r.skill ~= lastSkill and not W.SkillName(r.skill or 0):find("^#") then
					lastSkill = r.skill
					table.insert(rows, { header = true, left = "|cffffd100" .. W.SkillsText({ { id = r.skill or 0, value = 0 } }):gsub(" 0$", "") .. "|r", right = "" })
				end
				local picked = W.art.pick == r
				local function quote()
					W.art.pick, W.art.quote = r, nil
					W.art.asked = W.CardQty("r" .. r.item, W.art.maxQty or 20)
					W.Send("AQUOTE\t" .. r.bot .. "\t" .. r.item .. "\t" .. W.art.asked, "art")
				end
				table.insert(rows, { item = r.item, left = (picked and "> " or "") .. W.Colored(r.item, r.quality),
					sub = W.RecipeSub(r), right = "", reagents = W.art.reagents and W.art.reagents[r.item],
					qtyKey = "r" .. r.item, qtyMax = W.art.maxQty or 20, go = { icon = W.ICONS.order, title = T("A_QUOTE"), line = T("TIP_QUOTE"), click = quote }, click = function()
						-- The quantity box is shared with the guild order: back to 1 for each recipe (a 5 typed there made 5 crafts).
						W.art.pick, W.art.quote = r, nil
						if W.frame then W.frame.qty:SetText("1") end
						W.Refresh()
					end })
			end
		else
			local colors = { preparing = "|cffffd100", sent = "|cff66ccff", awaiting = "|cff40ff40", paid = "|cffaaaaaa",
				returned = "|cffff6060", cancelled = "|cffff6060" }
			for _, m in ipairs(W.art.mails) do
				local when = ""
				if (m.state == "sent" or m.state == "preparing") and m.eta > now then
					when = "  " .. string.format(T("M_ETA"), W.Duration(m.eta - now))
				elseif m.state == "awaiting" then
					when = "  " .. T("M_HERE")
				end
				table.insert(rows, { item = m.item, left = W.Colored(m.item) .. (m.qty > 1 and (" x" .. m.qty) or "")
					.. "  |cffaaaaaa" .. (m.bot or "") .. "|r",
					right = (colors[m.state] or "|cffffffff") .. T("M_" .. (m.state or "")) .. "|r" .. when .. "\n" .. W.Money(m.copper) })
			end
		end
	else
		for _, e in ipairs(W.events.list) do
			local left = e.at - now
			local when = e.state == "warn" and string.format(T("E_IN"), W.Duration(left)) or string.format(T("E_LEFT"), W.Duration(left))
			table.insert(rows, { left = "|cffff8000" .. T("E_" .. e.kind) .. "|r " .. (e.name or ""),
				right = (e.place or "") .. ", " .. (e.zone or "") .. "  |cffffd100" .. when .. "|r" })
		end
		if #W.events.firsts > 0 then
			table.insert(rows, { header = true, left = "|cffffd100" .. T("E_FIRSTS") .. "|r", right = "" })
			for _, x in ipairs(W.events.firsts) do
				local what = x.kind == "level" and string.format(T("F_level"), x.entry) or string.format(T("F_boss"), x.entry)
				table.insert(rows, { left = (x.who or "?") .. (x.guild and (" <" .. x.guild .. ">") or ""),
					right = what .. "  |cffaaaaaa" .. (x.team == "H" and "Horde" or "Alliance") .. "|r" })
			end
		end
	end
	return rows
end

function W.Refresh()
	local f = W.frame
	if not f or not f:IsShown() then return end
	f.title:SetText(T("TITLE"))
	local labels = { guild = "GUILD", art = "ARTISANS", events = "EVENTS" }
	for _, b in ipairs(f.tabs) do
		b:SetText(T(labels[b.key]))
		W.PlaceText(b)
		if b.key == W.tab then b:LockHighlight() else b:UnlockHighlight() end
	end
	local guild, art = W.tab == "guild", W.tab == "art"
	local recipes = art and W.art.mode == "recipes"
	local orders, cat = guild and W.guild.mode == "orders", guild and W.guild.mode == "cat"
	-- The banner: the guild, who is online, the free bots, the activity under way.
	if guild then
		f.banner:Show()
		local gname = GetGuildInfo and GetGuildInfo("player")
		f.banner.name:SetText(gname or T("G_NO_GUILD"))
		local total, online = GetNumGuildMembers and GetNumGuildMembers(true) or 0, 0
		for i = 1, total do
			local _, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
			if isOnline then online = online + 1 end
		end
		local free, running
		for _, kind in ipairs(W.ACTS) do
			local a = W.guild.acts[kind]
			if a then free = a.bots end
			if a and a.state == "busy" and a.untilAt > 0 then running = kind end
		end
		W.guild.running = running
		W.guild.runningName = running and T("GA_" .. running) or nil
		local info = gname and string.format(T("G_BANNER"), online, total) or ""
		if free then info = info .. "  ·  " .. string.format(T("G_FREE"), free) end
		f.banner.info:SetText("|cffaaaaaa" .. info .. "|r")
		local wait
		for _, kind in ipairs(W.ACTS) do
			local a = W.guild.acts[kind]
			if a and a.state == "cooldown" and a.untilAt > time() then wait = math.max(wait or 0, a.untilAt - time()) end
		end
		f.banner.act:SetText(running and ("|cffffd100" .. string.format(T("G_RUNNING"), T("GA_" .. running)) .. "|r")
			or wait and ("|cffaaaaaa" .. string.format(T("G_NEXT"), W.Duration(wait)) .. "|r") or "")
		if f.banner.cancel then if running then f.banner.cancel:Show() else f.banner.cancel:Hide() end end
	else
		f.banner:Hide()
	end
	for _, b in ipairs(f.views) do
		if guild then
			b:Show()
			b:SetText(T("V_" .. b.key))
			W.PlaceText(b)
			if b.key == W.guild.mode then b:LockHighlight(); b.mark:Show() else b:UnlockHighlight(); b.mark:Hide() end
		else
			b:Hide()
		end
	end
	-- The order line: under the views on the Guild tab, under the tabs on the Artisans tab.
	f.item:ClearAllPoints()
	if guild then
		f.item:SetWidth(70)
		f.item:SetPoint("LEFT", f.drop, "RIGHT", 18, 0)
	else
		f.item:SetWidth(230)
		f.item:SetPoint("TOPLEFT", 24, -70)
	end
	if orders then
		f.drop:Show()
		local id = W.askItem
		if id then
			f.drop.icon:SetTexture(GetItemIcon and GetItemIcon(id) or select(10, GetItemInfo(id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
			f.drop.text:SetText(W.Colored(id))
		else
			f.drop.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
			f.drop.text:SetText("|cffaaaaaa" .. T("G_DROP") .. "|r")
		end
		f.askLine:SetText(T("G_ASK_LINE"))
	else
		f.drop:Hide()
		f.askLine:SetText("")
	end
	local catControls = { f.search, f.slotBtn, f.usable, f.usableText, f.prev, f.next, f.pageText }
	for _, c in ipairs(catControls) do if cat then c:Show() else c:Hide() end end
	if cat then
		local c = W.guild.cat
		f.searchHint:SetText((f.search:GetText() == "" and not f.search:HasFocus()) and T("GC_SEARCH") or "")
		f.slotBtn:SetText(string.format(T("GC_SLOT"), c.slot or T("A_ALL")))
		W.PlaceText(f.slotBtn)
		f.usable:SetChecked(c.usable)
		f.usableText:SetText(T("GC_USABLE"))
		local pages = math.max(1, math.ceil((c.total or 0) / 30))
		f.pageText:SetText(string.format(T("GC_PAGE"), c.page, pages))
		if c.page > 1 then f.prev:Enable() else f.prev:Disable() end
		if c.page < pages then f.next:Enable() else f.next:Disable() end
	end
	if orders or recipes then f.item:Show(); f.qty:Show(); f.qtyLabel:Show(); f.action:Show() else f.item:Hide(); f.qty:Hide(); f.qtyLabel:Hide(); f.action:Hide() end
	if recipes then f.qty:Hide(); f.qtyLabel:Hide(); f.action:Hide() end
	if recipes then f.item:Hide() end
	f.qtyLabel:SetText(T("G_QTY"))
	W.PlaceText(f.action)
	f.itemHint:SetText((f.item:GetText() == "" and not f.item:HasFocus()) and T(guild and "G_ID" or "G_ITEM") or "")
	if guild and not orders then
		-- The views' help is in their buttons' tooltips: the list starts right under the banner.
		f.hint:SetText("")
	elseif guild then
		f.action:SetText(T("G_ORDER"))
		W.PlaceText(f.action)
		if W.BoxItem() then f.action:Enable() else f.action:Disable() end
		f.hint:SetText("")
	elseif recipes then
		local q = W.art.quote
		f.action:SetText(T((q and q.ok) and "A_ORDER" or "A_QUOTE"))
		W.PlaceText(f.action)
		if W.art.pick then f.action:Enable() else f.action:Disable() end
		local who = W.art.bot or "?"
		for _, b in ipairs(W.art.bots) do
			if b.name == W.art.bot then
				local parts = { "|cffffd100" .. b.name .. "|r" }
				if b.level then table.insert(parts, string.format(T("GC_REQ"), b.level)) end
				if b.zone and b.zone ~= "" then table.insert(parts, b.zone) end
				table.insert(parts, W.SkillsText(b.skills))
				who = table.concat(parts, "  ·  ")
			end
		end
		f.hint:SetText(who)
	elseif art and W.art.mode == "bots" then
		f.hint:SetText(T("A_TITLE"))
	elseif art and W.art.mode == "mails" then
		f.hint:SetText(T("M_TITLE"))
	elseif art then
		f.hint:SetText(T("A_PICK"))
	else
		f.hint:SetText("")
	end
	if art then
		f.action2:Show()
		f.action2:SetText(T(W.art.mode == "bots" and "A_MAILS" or "A_BACK"))
		W.SetIcon(f.action2, W.ICONS[W.art.mode == "bots" and "mails" or "back"])
		W.PlaceText(f.action2)
	else
		f.action2:Hide()
	end
	local columns = art and W.art.mode == "bots"
	for _, fs in ipairs(f.heads) do fs:SetText("") end
	-- Recipes: the quantity and Quote / Order at the bottom right, under the list.
	f.action:ClearAllPoints()
	f.qty:ClearAllPoints()
	if cat then
		f.action:SetPoint("BOTTOMRIGHT", -22, 14)
		f.qty:SetPoint("BOTTOMRIGHT", -24, 16)
	elseif recipes then
		f.action:SetPoint("BOTTOMRIGHT", -22, 14)
		f.qty:SetPoint("RIGHT", f.action, "LEFT", -14, 0)
	else
		f.qty:SetPoint("LEFT", f.item, "RIGHT", 40, 0)
		f.action:SetPoint("LEFT", f.qty, "RIGHT", 12, 0)
	end
	if columns then
		f.filter:Show()
		f.filter:SetText(string.format(T("A_FILTER"), W.art.skill and W.SkillName(W.art.skill) or T("A_ALL")))
		W.PlaceText(f.filter)
		f.hint:ClearAllPoints()
		f.hint:SetPoint("TOPLEFT", 20, -98)
	else
		f.filter:Hide()
		f.hint:ClearAllPoints()
		f.hint:SetPoint("TOPLEFT", 20, guild and ((cat or orders) and -122 or -100) or -96)
	end
	local q = recipes and W.art.quote
	local shown = ROWS
	if q and q.ok then
		shown = ROWS - 2
		local card = f.card
		card.icon:SetTexture(GetItemIcon and GetItemIcon(q.item) or select(10, GetItemInfo(q.item)) or "Interface\\Icons\\INV_Misc_QuestionMark")
		card.title:SetText(string.format(T("Q_TITLE"), q.bot or "?"))
		card.item:SetText(W.Colored(q.item) .. "  |cffffffffx" .. q.qty .. "|r"
			.. (q.capped and ("  |cffff9933" .. string.format(T("A_MAX"), q.qty) .. "|r") or ""))
		card.price:SetText(W.MoneyBig(q.copper))
		card.cod:SetText(T("Q_COD"))
		card.order:SetText(T("A_ORDER"))
		W.PlaceText(card.order)
		card:Show()
	elseif f.card then
		f.card:Hide()
	end
	local top = recipes and -108 or -146
	-- Events, for a GM: the GM section at the bottom, fewer cards above it.
	local gmShown = W.tab == "events" and W.events.gm
	if gmShown then
		f.gm:Show()
		f.gm.title:SetText(T("GM_TITLE"))
		for _, l in ipairs(f.gm.labels) do l:SetText(T(l.key)) end
		for _, b in ipairs(f.gm.buttons) do b:SetText(T(b.key)) end
		f.gm.out:SetText(W.gmOut and #W.gmOut > 0 and table.concat(W.gmOut, "  |  ") or ("|cffaaaaaa" .. T("GM_HINT") .. "|r"))
		shown = math.min(shown, ROWS - 3)
	else
		f.gm:Hide()
	end
	if guild then top = orders and -206 or cat and -172 or -142 end
	shown = math.min(shown, math.floor((470 + top) / 39))
	for i, row in ipairs(f.rows) do
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", 16, top - (i - 1) * 39)
	end
	f.bar:ClearAllPoints()
	f.bar:SetPoint("TOPLEFT", f.rows[1], "TOPRIGHT", 8, 0)
	f.bar:SetPoint("BOTTOMLEFT", f.rows[math.max(1, shown)], "BOTTOMRIGHT", 8, 0)
	local rows = W.Rows()
	W.count, W.shown = #rows, shown
	W.offset = math.max(0, math.min(W.offset, #rows - shown))
	local maxOffset = math.max(0, #rows - shown)
	f.bar:SetMinMaxValues(0, maxOffset)
	f.bar:SetValue(W.offset)
	if maxOffset > 0 then f.bar:Show() else f.bar:Hide() end
	for i, row in ipairs(f.rows) do
		local r = i <= shown and rows[W.offset + i]
		if r then
			row.item, row.click, row.tip, row.header = r.item, r.click, r.tip, r.header
			if r.header then
				row:SetBackdropColor(0, 0, 0, 0)
				row:SetBackdropBorderColor(0, 0, 0, 0)
			else
				row:SetBackdropColor(0.09, 0.09, 0.11, 0.95)
				row:SetBackdropBorderColor(1, 1, 1, 0.08)
			end
			if r.item then
				row.icon:SetTexture(GetItemIcon and GetItemIcon(r.item) or select(10, GetItemInfo(r.item)) or "Interface\\Icons\\INV_Misc_QuestionMark")
				row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				row.icon:Show()
			elseif r.iconPath then
				row.icon:SetTexture(r.iconPath)
				row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				row.icon:Show()
			else
				row.icon:Hide()
			end
			-- The title, its second line under it (or alone, in the middle).
			local x = (r.item or r.iconPath) and 40 or 10
			row.left:ClearAllPoints()
			if r.sub and r.sub ~= "" then row.left:SetPoint("TOPLEFT", x, -4) else row.left:SetPoint("LEFT", x, 0) end
			row.left:SetText(r.left or "")
			row.sub:SetText(r.sub or "")
			row.right:SetText(r.right or "")
			row.right:SetWidth(r.b2 and 130 or r.b1 and 200 or 240)
			for j, sk in ipairs(row.skills) do
				local one = r.skills and r.skills[j]
				local reagent = r.reagents and j <= 4 and r.reagents[j]
				sk.reagent = nil
				if reagent then
					sk.skill, sk.reagent = nil, reagent
					W.ItemName(reagent.item)
					sk.icon:SetTexture(GetItemIcon and GetItemIcon(reagent.item) or select(10, GetItemInfo(reagent.item)) or "Interface\\Icons\\INV_Misc_QuestionMark")
					sk.text:SetText(reagent.count)
					sk:Show()
				elseif r.reagents and j == 5 and #r.reagents > 4 then
					sk.skill = nil
					sk.icon:SetTexture(nil)
					sk.text:SetText("+" .. (#r.reagents - 4))
					sk:Show()
				elseif one then
					sk.skill = one
					sk.icon:SetTexture(SKILL_ICON[one.id] and ("Interface\\Icons\\" .. SKILL_ICON[one.id]) or "Interface\\Icons\\INV_Misc_QuestionMark")
					sk.text:SetText(((W.art.skill == one.id) and "|cffffd100" or "") .. one.value)
					sk:Show()
				else
					sk.skill = nil
					sk:Hide()
				end
			end
			if r.qtyKey then
				row.qty.key = nil
				row.qty:SetText(tostring(W.cardQty[r.qtyKey] or "1"))
				row.qty.key = r.qtyKey
				row.qty.max = r.qtyMax or 20
				row.qty:Clamp()
				row.qty:Show()
			else
				row.qty.key = nil
				row.qty:Hide()
			end
			if row.go then
				if r.go then
					row.go.run, row.go.tipTitle, row.go.tipLine = (not r.go.disabled) and r.go.click or nil, r.go.title, r.go.line
					row.go.icon:SetTexture(r.go.icon)
					row.go.icon:SetDesaturated(r.go.disabled and true or false)
					row.go.icon:SetAlpha(r.go.disabled and 0.5 or 1)
					row.go:Show()
				else
					row.go:Hide()
				end
			end
			row.b1:ClearAllPoints()
			row.b1:SetPoint("RIGHT", r.b2 and -96 or -10, 0)
			row.b2:ClearAllPoints()
			row.b2:SetPoint("RIGHT", -10, 0)
			for j = 1, 2 do
				local b, def = row["b" .. j], r["b" .. j]
				if def then
					b:SetText(def.text)
					b.run = def.click
					if def.enabled == false then b:Disable() else b:Enable() end
					b:Show()
				else
					b:Hide()
				end
			end
			row:Show()
		else
			row:Hide()
		end
	end
	local feature = W.Feature()
	local status = ""
	if W.off[feature] then status = "|cffff6060" .. T("OFF") .. "|r"
	elseif W.error then status = "|cffff6060" .. W.error .. "|r"
	elseif W.busy and W.busy.feature == feature then status = "|cffaaaaaa" .. T("WAITING") .. "|r"
	elseif #rows == 0 then
		status = guild and "" or ("|cffaaaaaa" .. T(art and (W.art.mode == "bots" and "A_NONE" or "") or "E_NONE") .. "|r")
	end
	f.status:SetText(status)
end

local events = CreateFrame("Frame")
events:RegisterEvent("CHAT_MSG_ADDON")
events:RegisterEvent("CHAT_MSG_SYSTEM")
events:SetScript("OnEvent", function(_, event, ...)
	if event == "CHAT_MSG_SYSTEM" then W.OnSystem(...) else W.OnAddon(...) end
end)
events:SetScript("OnUpdate", function(self, delta)
	self.t = (self.t or 0) + delta
	if self.t < 0.25 then return end
	self.t = 0
	W.Tick()
end)
