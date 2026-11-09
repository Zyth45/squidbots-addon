-- SquidBots Lite 3.0: the World panel (guild orders, artisans, world events) and the bots' soul.
-- Protocol: docs/WORLD-PROTOCOLE-3.0.md. Addon messages, prefix "SQBW", tab-separated:
--   guild, artisans, events: whispered to oneself, the server answers by addon whispers from oneself;
--   soul: "SOUL?" whispered to the bot, which answers.
-- Every list ends with "-". One request at a time; no answer within 6 s: the feature is off on this realm.

-- GAP: the server answers at most 1 request per second and per brick (more: no answer at all, not even "-").
local PREFIX, WAIT, ROWS, GAP = "SQBW", 6, 12, 1.1
local REQUESTS = { GORD = true, GLIST = true, WEV = true, ["WEV?"] = true, ALIST = true, ARCP = true, AQUOTE = true,
	AORDER = true, AMAIL = true, ["SOUL?"] = true, GOFF = true, GACC = true, GREF = true, GCAT = true, GACT = true,
	["GACT?"] = true }

local STRINGS = {
	en = {
		TITLE = "SquidBots Lite - World", GUILD = "Guild", ARTISANS = "Artisans", EVENTS = "Events",
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
		Q_TITLE = "Quote from %s", Q_COD = "cash on delivery, paid when you take it from the mail",
		M_preparing = "Preparing", M_sent = "Sent", M_awaiting = "Awaiting pickup", M_paid = "Received",
		M_returned = "Returned", M_cancelled = "Cancelled", M_pending = "Awaiting pickup",
		M_ETA = "arrives in ~%s", M_HERE = "in your mailbox", M_TITLE = "Your artisan orders (last 7 days), newest first.",
		M_CHAT = "Your order %s (%s): %s.", M_CHAT_ETA = "Your order %s (%s) is on its way, arriving in ~%s.",
		E_NONE = "No invasion or rush right now.", E_inv = "Invasion", E_rush = "Gold rush", E_IN = "in %s", E_LEFT = "%s left",
		E_FIRSTS = "Server firsts", F_level = "level %s", F_boss = "%s",
		R_quality = "quality too high", R_daily = "daily limit reached", R_noguild = "no guild", R_item = "unknown item",
		R_qty = "quantity not allowed", R_off = "off on this realm", R_nobot = "no guild bot online", R_cannot = "no such recipe",
		R_busy = "the artisan is busy", R_mats = "no materials", R_expired = "quote too old: ask again",
		R_faction = "other faction", R_price = "the price went up: ask a new quote", R_offline = "the bot is offline",
		R_notyours = "not your bot",
		ASK_ART = "Order %d x %s from %s for %s (cash on delivery)?",
		V_gifts = "Gifts", V_cat = "Catalogue", V_act = "Activities", V_orders = "My orders",
		GF_HINT = "Gear your guild's members offer you. Accept: it comes by mail. Decline: that item is not offered again for 30 days.",
		GF_NONE = "No gift offered right now.", GF_LINE = "%s offers it (%s), %s", GF_EXPIRES = "ends in %s",
		GF_ACCEPT = "Accept", GF_DECLINE = "Decline", GF_EMPTY = "empty slot", GF_CHAT = "%s offers you %s (%s): open World > Guild > Gifts to accept.",
		GC_HINT = "What your guild's online bots have in stock or can craft. Search by English name; click an item to order it.",
		GC_SEARCH = "Search (English name)...", GC_NONE = "Nothing found.", GC_STOCK = "in stock: %s x%d", GC_CRAFT = "crafted by %s",
		GC_REQ = "level %d", GC_PAGE = "Page %d / %d", GC_SLOT = "Slot: %s", GC_USABLE = "Usable now", C_OTHER = "Other",
		GA_HINT = "Your guild's bots with you: rally them where you are, make a dungeon party, or a guild raid.",
		GA_gather = "Rally the guild", GA_party5 = "Dungeon party (5)", GA_raid10 = "Guild raid (10)", GA_raid15 = "Guild raid (15)",
		GA_raid25 = "Guild raid (25)", GS_ready = "ready", GS_busy = "under way", GS_cooldown = "again in %s", GS_nobots = "not enough bots",
		GA_BOTS = "%d bots available", GA_START = "Start", ASK_ACT = "Start: %s?",
		R_ingroup = "leave your group first", R_level = "level too low", R_offer = "this offer is gone",
		ASK_GUILD = "Order %d x %s from your guild? If a bot crafts it or buys it at the auction house, it comes cash on delivery (you pay when you take it from the mail).",
		YES = "Yes", NO = "No",
		SOUL = "Soul", ARCH_lazy = "Lazy", ARCH_quester = "Quester", ARCH_wanderer = "Wanderer", ARCH_trader = "Trader",
		ARCH_pvp = "PvP", TRAITS = "pace %d, sociability %d, curiosity %d, greed %d, aggression %d",
	},
	fr = {
		TITLE = "SquidBots Lite - Monde", GUILD = "Guilde", ARTISANS = "Artisans", EVENTS = "Événements",
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
		Q_TITLE = "Devis de %s", Q_COD = "contre remboursement, payé en le retirant du courrier",
		M_preparing = "En préparation", M_sent = "Envoyé", M_awaiting = "En attente de réception", M_paid = "Reçu (payé)",
		M_returned = "Renvoyé", M_cancelled = "Annulé", M_pending = "En attente de réception",
		M_ETA = "arrivée dans ~%s", M_HERE = "dans votre boîte aux lettres", M_TITLE = "Vos commandes aux artisans (7 derniers jours), les plus récentes d'abord.",
		M_CHAT = "Votre commande %s (%s) : %s.", M_CHAT_ETA = "Votre commande %s (%s) est en route, arrivée dans ~%s.",
		E_NONE = "Aucune invasion ni ruée en ce moment.", E_inv = "Invasion", E_rush = "Ruée vers l'or", E_IN = "dans %s", E_LEFT = "encore %s",
		E_FIRSTS = "Server first", F_level = "niveau %s", F_boss = "%s",
		R_quality = "qualité trop haute", R_daily = "limite du jour atteinte", R_noguild = "pas de guilde", R_item = "objet inconnu",
		R_qty = "quantité refusée", R_off = "coupé sur ce royaume", R_nobot = "aucun bot de guilde en ligne", R_cannot = "recette inconnue",
		R_busy = "l'artisan est occupé", R_mats = "pas de composants", R_expired = "devis trop vieux : redemandez",
		R_faction = "autre faction", R_price = "le prix a monté : redemandez un devis", R_offline = "le bot est hors ligne",
		R_notyours = "pas votre bot",
		ASK_ART = "Commander %d x %s à %s pour %s (contre remboursement) ?",
		V_gifts = "Dons", V_cat = "Catalogue", V_act = "Activités", V_orders = "Mes commandes",
		GF_HINT = "L'équipement que les membres de votre guilde vous offrent. Accepter : il arrive par courrier. Refuser : cet objet ne vous est plus proposé pendant 30 jours.",
		GF_NONE = "Aucun don proposé en ce moment.", GF_LINE = "offert par %s (%s), %s", GF_EXPIRES = "fin dans %s",
		GF_ACCEPT = "Accepter", GF_DECLINE = "Refuser", GF_EMPTY = "emplacement vide", GF_CHAT = "%s vous offre %s (%s) : Monde > Guilde > Dons pour l'accepter.",
		GC_HINT = "Ce que les bots de votre guilde en ligne ont en stock ou savent fabriquer. Cherchez par nom anglais ; cliquez un objet pour le commander.",
		GC_SEARCH = "Chercher (nom anglais)...", GC_NONE = "Rien trouvé.", GC_STOCK = "en stock : %s x%d", GC_CRAFT = "fabriqué par %s",
		GC_REQ = "niveau %d", GC_PAGE = "Page %d / %d", GC_SLOT = "Emplacement : %s", GC_USABLE = "Utilisable", C_OTHER = "Autre",
		GA_HINT = "Les bots de votre guilde avec vous : rassemblez-les où vous êtes, formez un groupe de donjon ou un raid de guilde.",
		GA_gather = "Rassembler la guilde", GA_party5 = "Groupe de donjon (5)", GA_raid10 = "Raid de guilde (10)", GA_raid15 = "Raid de guilde (15)",
		GA_raid25 = "Raid de guilde (25)", GS_ready = "prêt", GS_busy = "en cours", GS_cooldown = "à nouveau dans %s", GS_nobots = "pas assez de bots",
		GA_BOTS = "%d bots disponibles", GA_START = "Lancer", ASK_ACT = "Lancer : %s ?",
		R_ingroup = "quittez d'abord votre groupe", R_level = "niveau trop bas", R_offer = "ce don n'est plus proposé",
		ASK_GUILD = "Commander %d x %s à votre guilde ? Si un bot le fabrique ou l'achète à l'hôtel des ventes, il arrive contre remboursement (vous payez en le retirant du courrier).",
		YES = "Oui", NO = "Non",
		SOUL = "Âme", ARCH_lazy = "Paresseux", ARCH_quester = "Quêteur", ARCH_wanderer = "Vagabond", ARCH_trader = "Marchand",
		ARCH_pvp = "JcJ", TRAITS = "rythme %d, sociabilité %d, curiosité %d, avidité %d, agressivité %d",
	},
}

local W = {
	queue = {}, busy = nil, lines = {}, off = {}, at = {},
	guild = { orders = {}, gifts = {}, mode = "gifts", offers = {}, acts = {},
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
	if q and q.request == "WEV?" then W.events.list = {} end
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
	elseif k == "AQ" then
		W.art.quote = { bot = f[2], item = tonumber(f[3]), qty = tonumber(f[4]) or 1, copper = tonumber(f[5]) or 0,
			ok = f[6] == "ok", reason = f[6], id = f[7] }
		if not W.art.quote.ok then W.error = W.Reason(f[6]) end
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
				DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. string.format(T("GF_CHAT"), o.bot or "?",
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
	if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text) end
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
	v_orders = "Interface\\Icons\\INV_Letter_15" }
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
	f.item:SetScript("OnTextChanged", function() W.Refresh() end)
	f.itemHint = f.item:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.itemHint:SetPoint("LEFT", 4, 0)
	f.qty = CreateFrame("EditBox", "SquidBotsLiteWorldQty", f, "InputBoxTemplate")
	f.qty:SetWidth(36)
	f.qty:SetHeight(20)
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
	for i = 1, ROWS do
		local row = CreateFrame("Button", nil, f)
		row:SetWidth(630)
		row:SetHeight(22)
		row:SetPoint("TOPLEFT", 16, -146 - (i - 1) * 23)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row.stripe = row:CreateTexture(nil, "BACKGROUND")
		row.stripe:SetAllPoints()
		row.stripe:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.stripe:SetVertexColor(1, 1, 1, i % 2 == 0 and 0.04 or 0)
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(20)
		row.icon:SetHeight(20)
		row.icon:SetPoint("LEFT", 2, 0)
		row.left = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.left:SetPoint("LEFT", 28, 0)
		row.left:SetWidth(290)
		row.left:SetJustifyH("LEFT")
		row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.right:SetPoint("LEFT", 330, 0)
		row.right:SetWidth(296)
		row.right:SetHeight(22)
		row.right:SetJustifyH("LEFT")
		-- Accept / Decline (gifts), Start (activities).
		for j = 1, 2 do
			local b = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			b:SetWidth(80)
			b:SetHeight(20)
			if j == 1 then b:SetPoint("RIGHT", -88, 0) else b:SetPoint("RIGHT", -4, 0) end
			b:SetNormalFontObject(GameFontNormalSmall)
			b:SetHighlightFontObject(GameFontHighlightSmall)
			b:SetDisabledFontObject(GameFontDisableSmall)
			b:SetScript("OnClick", function(self) if self.run then self.run() end end)
			b:Hide()
			row["b" .. j] = b
		end
		-- The artisans' columns: name, level, zone, professions.
		row.cols = {}
		for c, def in ipairs(W.COLUMNS) do
			local fs = row:CreateFontString(nil, "OVERLAY", c == 1 and "GameFontHighlight" or "GameFontHighlightSmall")
			fs:SetPoint("LEFT", def[1], 0)
			fs:SetWidth(def[2])
			fs:SetHeight(20)
			fs:SetJustifyH(c == 2 and "CENTER" or "LEFT")
			row.cols[c] = fs
		end
		row:SetScript("OnClick", function(self) if self.click then self.click() end end)
		row:SetScript("OnEnter", function(self)
			if self.item then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink("item:" .. self.item)
				GameTooltip:Show()
			end
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		row:EnableMouseWheel(true)
		row:SetScript("OnMouseWheel", function(_, delta)
			W.offset = math.max(0, math.min(math.max(0, (W.count or 0) - ROWS), W.offset - delta * 3))
			W.Refresh()
		end)
		f.rows[i] = row
	end
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
	-- The Guild tab's views: Gifts, Catalogue, Activities, My orders.
	f.views = {}
	for i, key in ipairs({ "gifts", "cat", "act", "orders" }) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetWidth(W.BUTTON_W)
		b:SetHeight(W.BUTTON_H)
		b:SetPoint("TOPLEFT", 18 + (i - 1) * (W.BUTTON_W + 6), -68)
		W.StyleButton(b, W.ICONS["v_" .. key])
		b:SetScript("OnClick", function() W.guild.mode = key; W.offset = 0; W.error = nil; W.Load() end)
		b.key = key
		f.views[i] = b
	end
	-- The catalogue's line: search, slot, usable now, pages.
	f.search = CreateFrame("EditBox", "SquidBotsLiteWorldSearch", f, "InputBoxTemplate")
	f.search:SetWidth(200)
	f.search:SetHeight(20)
	f.search:SetPoint("TOPLEFT", 24, -98)
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
	f.prev:SetPoint("TOPRIGHT", -84, -98)
	f.prev:SetScript("OnClick", function() W.CatPage(W.guild.cat.page - 1) end)
	f.next = CreateFrame("Button", nil, f, "UIPanelScrollDownButtonTemplate")
	f.next:SetPoint("TOPRIGHT", -20, -98)
	f.next:SetScript("OnClick", function() W.CatPage(W.guild.cat.page + 1) end)
	f.pageText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.pageText:SetPoint("RIGHT", f.next, "LEFT", -6, 0)
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
	if link and box and box:IsVisible() and box:HasFocus() then
		box:SetText(link)
		return true
	end
	return insertLink(link, ...)
end

-- Column x and width on a row (630 wide): artisan, level, zone, professions.
W.COLUMNS = { { 28, 130 }, { 160, 34 }, { 200, 136 }, { 342, 286 } }

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
		if mode == "gifts" then W.Ask("GOFF", "gifts")
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
	local text = W.frame and W.frame.item:GetText() or ""
	return tonumber(text:match("|Hitem:(%d+)") or text:match("^%s*(%d+)%s*$"))
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
				if W.frame then W.frame.qty:SetText("1") end
			end)
		elseif W.art.pick then
			W.Send("AQUOTE\t" .. W.art.pick.bot .. "\t" .. W.art.pick.item .. "\t" .. W.Qty(5), "art")
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
	elseif W.tab == "guild" and W.guild.mode == "cat" then
		local c, level = W.guild.cat, UnitLevel and UnitLevel("player") or 80
		for _, x in ipairs(c.list) do
			if (not c.slot or W.SlotName(x.slot) == c.slot) and (not c.usable or x.req <= level) then
				local source = x.source == "stock" and string.format(T("GC_STOCK"), x.bot or "?", x.qty)
					or string.format(T("GC_CRAFT"), x.bot or "?")
				local req = x.req > 0 and ("  " .. (x.req > level and "|cffff6060" or "|cffaaaaaa") .. string.format(T("GC_REQ"), x.req) .. "|r") or ""
				table.insert(rows, { item = x.item, left = W.Colored(x.item, x.quality) .. "  |cffaaaaaa" .. W.SlotName(x.slot) .. "|r",
					right = "|cffaaaaaa" .. source .. "|r" .. req .. (x.price > 0 and ("\n" .. W.Money(x.price)) or ""),
					click = function()
						W.Confirm(string.format(T("ASK_GUILD"), 1, W.Colored(x.item, x.quality)), function()
							W.Send("GORD\t" .. x.item .. "\t1", "guild")
						end)
					end })
			end
		end
		if #rows == 0 then table.insert(rows, { left = "|cffaaaaaa" .. T("GC_NONE") .. "|r", right = "" }) end
	elseif W.tab == "guild" and W.guild.mode == "act" then
		for _, kind in ipairs(W.ACTS) do
			local a = W.guild.acts[kind]
			local state = ""
			if a then
				state = a.state == "cooldown" and string.format(T("GS_cooldown"), W.Duration(a.untilAt - now)) or T("GS_" .. (a.state or ""))
				local color = a.state == "ready" and "|cff40ff40" or a.state == "busy" and "|cffffd100" or "|cffff6060"
				state = color .. state .. "|r  |cffaaaaaa" .. string.format(T("GA_BOTS"), a.bots) .. "|r"
			end
			table.insert(rows, { left = T("GA_" .. kind), right = state,
				b1 = { text = T("GA_START"), enabled = a and a.state == "ready", click = function()
					W.Confirm(string.format(T("ASK_ACT"), T("GA_" .. kind)), function() W.Send("GACT\t" .. kind, "act") end)
				end } })
		end
	elseif W.tab == "guild" then
		-- Two parts, each with its title: my orders (and how each went), the gifts the guild sent me.
		table.insert(rows, { left = "|cffffd100" .. T("G_ORDERS") .. "|r", right = "" })
		for _, o in ipairs(W.guild.orders) do
			local state = T("S_" .. (o.state or "open"))
			if o.reason then state = state .. " : " .. W.Reason(o.reason) end
			if o.cod > 0 then state = state .. "  " .. W.Money(o.cod) end
			local color = (o.state == "refused" or o.state == "none") and "|cffff6060" or (o.state == "open") and "|cffaaaaaa" or "|cff40ff40"
			local by = o.bot and string.format(T("G_BY"), o.bot, W.Ago(o.at)) or W.Ago(o.at)
			table.insert(rows, { item = o.item, left = W.Colored(o.item) .. (o.qty > 1 and (" x" .. o.qty) or ""),
				right = color .. state .. "|r\n|cffaaaaaa" .. by .. "|r" })
		end
		if #W.guild.orders == 0 then table.insert(rows, { left = "|cffaaaaaa" .. T("G_NONE") .. "|r", right = "" }) end
		table.insert(rows, { left = "|cffffd100" .. T("G_GIFTS") .. "|r", right = "" })
		for _, g in ipairs(W.guild.gifts) do
			table.insert(rows, { item = g.item, left = W.Colored(g.item),
				right = "|cffaaaaaa" .. string.format(T("G_GIFT_LINE"), g.bot or "?", W.Ago(g.at)) .. "|r" })
		end
		if #W.guild.gifts == 0 then table.insert(rows, { left = "|cffaaaaaa" .. T("G_NO_GIFT") .. "|r", right = "" }) end
	elseif W.tab == "art" then
		if W.art.mode == "bots" then
			for _, b in ipairs(W.art.bots) do
				local keep = not W.art.skill
				for _, sk in ipairs(b.skills) do if sk.id == W.art.skill then keep = true end end
				if keep then
				table.insert(rows, { cols = { b.name, b.level and tostring(b.level) or "", b.zone or "",
					W.SkillsText(b.skills, W.art.skill) }, click = function()
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
				if r.skill ~= lastSkill and CRAFTS[r.skill or 0] then
					lastSkill = r.skill
					table.insert(rows, { left = "|cffffd100" .. W.SkillsText({ { id = r.skill or 0, value = 0 } }):gsub(" 0$", "") .. "|r", right = "" })
				end
				local picked = W.art.pick == r
				table.insert(rows, { item = r.item, left = (picked and "> " or "") .. W.Colored(r.item, r.quality),
					right = "|cffaaaaaa" .. (r.rank and r.rank > 0 and (r.rank .. "  ") or "") .. (r.bot or "") .. "|r", click = function()
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
			table.insert(rows, { left = "|cffffd100" .. T("E_FIRSTS") .. "|r", right = "" })
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
	for _, b in ipairs(f.views) do
		if guild then
			b:Show()
			b:SetText(T("V_" .. b.key))
			W.PlaceText(b)
			if b.key == W.guild.mode then b:LockHighlight() else b:UnlockHighlight() end
		else
			b:Hide()
		end
	end
	-- The order line: under the views on the Guild tab, under the tabs on the Artisans tab.
	f.item:ClearAllPoints()
	f.item:SetPoint("TOPLEFT", 24, guild and -98 or -70)
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
	if recipes then f.item:Hide() end
	f.qtyLabel:SetText(T("G_QTY"))
	W.PlaceText(f.action)
	f.itemHint:SetText((f.item:GetText() == "" and not f.item:HasFocus()) and T("G_ITEM") or "")
	if guild and not orders then
		f.hint:SetText(T(W.guild.mode == "gifts" and "GF_HINT" or cat and "GC_HINT" or "GA_HINT"))
	elseif guild then
		f.action:SetText(T("G_ORDER"))
		W.PlaceText(f.action)
		if W.BoxItem() then f.action:Enable() else f.action:Disable() end
		f.hint:SetText(T("G_HINT"))
	elseif recipes then
		local q = W.art.quote
		f.action:SetText(T((q and q.ok) and "A_ORDER" or "A_QUOTE"))
		W.PlaceText(f.action)
		if W.art.pick then f.action:Enable() else f.action:Disable() end
		f.hint:SetText(T("A_PICK"))
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
	local heads = { "C_ARTISAN", "C_LEVEL", "C_ZONE", "C_PROFS" }
	for c, fs in ipairs(f.heads) do fs:SetText(columns and T(heads[c]) or "") end
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
		shown = ROWS - 3
		local card = f.card
		card.icon:SetTexture(GetItemIcon and GetItemIcon(q.item) or select(10, GetItemInfo(q.item)) or "Interface\\Icons\\INV_Misc_QuestionMark")
		card.title:SetText(string.format(T("Q_TITLE"), q.bot or "?"))
		card.item:SetText(W.Colored(q.item) .. "  |cffffffffx" .. q.qty .. "|r")
		card.price:SetText(W.MoneyBig(q.copper))
		card.cod:SetText(T("Q_COD"))
		card.order:SetText(T("A_ORDER"))
		W.PlaceText(card.order)
		card:Show()
	elseif f.card then
		f.card:Hide()
	end
	local rows = W.Rows()
	W.count = #rows
	W.offset = math.max(0, math.min(W.offset, #rows - shown))
	for i, row in ipairs(f.rows) do
		local r = i <= shown and rows[W.offset + i]
		if r then
			row.item, row.click = r.item, r.click
			if r.item then
				row.icon:SetTexture(GetItemIcon and GetItemIcon(r.item) or select(10, GetItemInfo(r.item)) or "Interface\\Icons\\INV_Misc_QuestionMark")
				row.icon:Show()
			else
				row.icon:Hide()
			end
			row.left:SetText(r.cols and "" or r.left)
			row.right:SetText(r.cols and "" or r.right)
			row.right:SetWidth(r.b2 and 130 or r.b1 and 214 or 296)
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
			for c, fs in ipairs(row.cols) do fs:SetText(r.cols and r.cols[c] or "") end
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
events:SetScript("OnEvent", function(_, _, ...) W.OnAddon(...) end)
events:SetScript("OnUpdate", function(self, delta)
	self.t = (self.t or 0) + delta
	if self.t < 0.25 then return end
	self.t = 0
	W.Tick()
end)
