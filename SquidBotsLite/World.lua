-- SquidBots Lite 3.0: the World panel (guild orders, artisans, world events) and the bots' soul.
-- Protocol: docs/WORLD-PROTOCOLE-3.0.md. Addon messages, prefix "SQBW", tab-separated:
--   guild, artisans, events: whispered to oneself, the server answers by addon whispers from oneself;
--   soul: "SOUL?" whispered to the bot, which answers.
-- Every list ends with "-". One request at a time; no answer within 6 s: the feature is off on this realm.

-- GAP: the server answers at most 1 request per second and per brick (more: no answer at all, not even "-").
local PREFIX, WAIT, ROWS, GAP = "SQBW", 6, 12, 1.1
local REQUESTS = { GORD = true, GLIST = true, WEV = true, ["WEV?"] = true, ALIST = true, ARCP = true, AQUOTE = true,
	AORDER = true, AMAIL = true, ["SOUL?"] = true }

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
		A_BACK = "< Artisans list", A_MAILS = "My CoD mails", A_QUOTE = "Quote", A_ORDER = "Order", A_NONE = "No artisan bot online.",
		A_PICK = "Click an artisan, then a recipe.", A_TITLE = "Online artisans of your faction (not only your guild): click one for its recipes.",
		C_ARTISAN = "Artisan", C_LEVEL = "Lvl", C_ZONE = "Zone", C_PROFS = "Professions", A_FILTER = "Profession: %s", A_ALL = "All", A_PRICE = "%s x%d: %s, cash on delivery.",
		M_pending = "in your mailbox", M_paid = "paid", M_returned = "returned",
		E_NONE = "No invasion or rush right now.", E_inv = "Invasion", E_rush = "Gold rush", E_IN = "in %s", E_LEFT = "%s left",
		E_FIRSTS = "Server firsts", F_level = "level %s", F_boss = "%s",
		R_quality = "quality too high", R_daily = "daily limit reached", R_noguild = "no guild", R_item = "unknown item",
		R_qty = "quantity not allowed", R_off = "off on this realm", R_nobot = "no guild bot online", R_cannot = "no such recipe",
		R_busy = "the artisan is busy", R_mats = "no materials", R_expired = "quote too old: ask again",
		R_faction = "other faction", R_price = "the price went up: ask a new quote", R_offline = "the bot is offline",
		R_notyours = "not your bot",
		ASK_ART = "Order %d x %s from %s for %s (cash on delivery)?",
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
		A_BACK = "< Liste des artisans", A_MAILS = "Mes courriers CR", A_QUOTE = "Devis", A_ORDER = "Commander", A_NONE = "Aucun bot artisan en ligne.",
		A_PICK = "Cliquez un artisan, puis une recette.", A_TITLE = "Artisans de votre faction en ligne (pas seulement votre guilde) : cliquez-en un pour ses recettes.",
		C_ARTISAN = "Artisan", C_LEVEL = "Niv.", C_ZONE = "Zone", C_PROFS = "Métiers", A_FILTER = "Métier : %s", A_ALL = "Tous", A_PRICE = "%s x%d : %s, contre remboursement.",
		M_pending = "dans votre boîte", M_paid = "payé", M_returned = "renvoyé",
		E_NONE = "Aucune invasion ni ruée en ce moment.", E_inv = "Invasion", E_rush = "Ruée vers l'or", E_IN = "dans %s", E_LEFT = "encore %s",
		E_FIRSTS = "Server first", F_level = "niveau %s", F_boss = "%s",
		R_quality = "qualité trop haute", R_daily = "limite du jour atteinte", R_noguild = "pas de guilde", R_item = "objet inconnu",
		R_qty = "quantité refusée", R_off = "coupé sur ce royaume", R_nobot = "aucun bot de guilde en ligne", R_cannot = "recette inconnue",
		R_busy = "l'artisan est occupé", R_mats = "pas de composants", R_expired = "devis trop vieux : redemandez",
		R_faction = "autre faction", R_price = "le prix a monté : redemandez un devis", R_offline = "le bot est hors ligne",
		R_notyours = "pas votre bot",
		ASK_ART = "Commander %d x %s à %s pour %s (contre remboursement) ?",
		ASK_GUILD = "Commander %d x %s à votre guilde ? Si un bot le fabrique ou l'achète à l'hôtel des ventes, il arrive contre remboursement (vous payez en le retirant du courrier).",
		YES = "Oui", NO = "Non",
		SOUL = "Âme", ARCH_lazy = "Paresseux", ARCH_quester = "Quêteur", ARCH_wanderer = "Vagabond", ARCH_trader = "Marchand",
		ARCH_pvp = "JcJ", TRAITS = "rythme %d, sociabilité %d, curiosité %d, avidité %d, agressivité %d",
	},
}

local W = {
	queue = {}, busy = nil, lines = {}, off = {}, at = {},
	guild = { orders = {}, gifts = {} }, art = { bots = {}, recipes = {}, mails = {}, bot = nil, quote = nil, mode = "bots" },
	events = { list = {}, firsts = {} }, soul = {}, soulAsked = {}, error = nil, tab = "guild", offset = 0,
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
	[186] = "Trade_Mining", [182] = "Trade_Herbalism", [393] = "INV_Misc_Pelt_Wolf_01", [356] = "Trade_Fishing" }

function W.SkillName(id)
	local names = SquidBotsLite_Alts and SquidBotsLite_Alts.SKILLS
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return names and ((names[lang] or names.en)[id] or names.en[id]) or ("#" .. tostring(id))
end

-- "164:300,197:275" -> { { id = 164, value = 300 }, ... }, best first.
function W.Skills(text)
	local list = {}
	for id, value in (text or ""):gmatch("(%d+):(%d+)") do table.insert(list, { id = tonumber(id), value = tonumber(value) }) end
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
	if kinds.AM or (q and q.request == "AMAIL") then W.art.mails = {} end
	for _, f in ipairs(lines) do W.Line(f) end
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
		if f[5] then
			table.insert(W.art.bots, { name = f[2], level = tonumber(f[3]), zone = f[4], skills = W.Skills(f[5]) })
		else
			table.insert(W.art.bots, { name = f[2], skills = W.Skills(f[3]) })
		end
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
		if f[3] == "mailed" then
			W.art.quote = nil
			W.Send("AMAIL", "art")
		else
			W.error = W.Reason(f[3])
			if f[3] == "price" or f[3] == "expired" then W.art.quote = nil end
		end
	elseif k == "AM" then
		table.insert(W.art.mails, { id = f[2], bot = f[3], item = tonumber(f[4]), qty = tonumber(f[5]) or 1,
			copper = tonumber(f[6]) or 0, at = tonumber(f[7]) or 0, state = f[8] })
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
local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }

function W.Build()
	local f = CreateFrame("Frame", "SquidBotsLiteWorld", UIParent)
	W.frame = f
	f:SetWidth(520)
	f:SetHeight(460)
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
	for i, key in ipairs({ "guild", "art", "events" }) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetWidth(110)
		b:SetHeight(22)
		b:SetPoint("TOPLEFT", 16 + (i - 1) * 114, -36)
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
	f.action:SetWidth(110)
	f.action:SetHeight(22)
	f.action:SetPoint("LEFT", f.qty, "RIGHT", 12, 0)
	f.action:SetScript("OnClick", function() W.Action() end)
	f.action2 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.action2:SetWidth(110)
	f.action2:SetHeight(22)
	f.action2:SetPoint("TOPRIGHT", -20, -36)
	f.action2:SetScript("OnClick", function() W.Action2() end)
	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("TOPLEFT", 20, -96)
	f.hint:SetWidth(480)
	f.hint:SetJustifyH("LEFT")
	f.rows = {}
	for i = 1, ROWS do
		local row = CreateFrame("Button", nil, f)
		row:SetWidth(470)
		row:SetHeight(22)
		row:SetPoint("TOPLEFT", 16, -122 - (i - 1) * 23)
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
		row.left:SetWidth(230)
		row.left:SetJustifyH("LEFT")
		row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.right:SetPoint("LEFT", 264, 0)
		row.right:SetWidth(200)
		row.right:SetHeight(22)
		row.right:SetJustifyH("LEFT")
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
	f.filter:SetWidth(170)
	f.filter:SetHeight(20)
	f.filter:SetPoint("TOPLEFT", 20, -66)
	f.filter:SetScript("OnClick", function() W.FilterMenu() end)
	f.menu = CreateFrame("Frame", "SquidBotsLiteWorldMenu", UIParent, "UIDropDownMenuTemplate")
	f.status = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.status:SetPoint("BOTTOMLEFT", 22, 20)
	f.status:SetWidth(470)
	f.status:SetJustifyH("LEFT")
	f:SetScript("OnUpdate", function(self, delta)
		self.t = (self.t or 0) + delta
		if self.t < 1 then return end
		self.t = 0
		if W.tab == "events" or next(W.waiting) then W.Refresh() end
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

-- Column x and width on a row (470 wide): artisan, level, zone, professions.
W.COLUMNS = { { 28, 118 }, { 148, 30 }, { 182, 104 }, { 290, 178 } }

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
	if W.tab == "guild" then W.Ask("GLIST", "guild")
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
		if W.frame then W.frame.item:SetText("") end
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

-- The rows of the tab: { icon, left, right, click, item }.
function W.Rows()
	local rows, now = {}, time()
	if W.tab == "guild" then
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
				if r.skill ~= lastSkill then
					lastSkill = r.skill
					table.insert(rows, { left = "|cffffd100" .. W.SkillsText({ { id = r.skill or 0, value = 0 } }):gsub(" 0$", "") .. "|r", right = "" })
				end
				local picked = W.art.pick == r
				table.insert(rows, { item = r.item, left = (picked and "> " or "") .. W.Colored(r.item, r.quality),
					right = "|cffaaaaaa" .. (r.rank and r.rank > 0 and (r.rank .. "  ") or "") .. (r.bot or "") .. "|r", click = function()
						W.art.pick, W.art.quote = r, nil
						W.Refresh()
					end })
			end
		else
			for _, m in ipairs(W.art.mails) do
				table.insert(rows, { item = m.item, left = W.Colored(m.item) .. (m.qty > 1 and (" x" .. m.qty) or ""),
					right = W.Money(m.copper) .. "  |cffaaaaaa" .. T("M_" .. (m.state or "pending")) .. "|r" })
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
		if b.key == W.tab then b:LockHighlight() else b:UnlockHighlight() end
	end
	local guild, art = W.tab == "guild", W.tab == "art"
	local recipes = art and W.art.mode == "recipes"
	if guild or recipes then f.item:Show(); f.qty:Show(); f.qtyLabel:Show(); f.action:Show() else f.item:Hide(); f.qty:Hide(); f.qtyLabel:Hide(); f.action:Hide() end
	if recipes then f.item:Hide() end
	f.qtyLabel:SetText(T("G_QTY"))
	f.itemHint:SetText((f.item:GetText() == "" and not f.item:HasFocus()) and T("G_ITEM") or "")
	if guild then
		f.action:SetText(T("G_ORDER"))
		if W.BoxItem() then f.action:Enable() else f.action:Disable() end
		f.hint:SetText(T("G_HINT"))
	elseif recipes then
		local q = W.art.quote
		f.action:SetText(T((q and q.ok) and "A_ORDER" or "A_QUOTE"))
		if W.art.pick then f.action:Enable() else f.action:Disable() end
		f.hint:SetText(q and q.ok and string.format(T("A_PRICE"), W.Colored(q.item), q.qty, W.Money(q.copper)) or T("A_PICK"))
	elseif art and W.art.mode == "bots" then
		f.hint:SetText(T("A_TITLE"))
	elseif art then
		f.hint:SetText(T("A_PICK"))
	else
		f.hint:SetText("")
	end
	if art then
		f.action2:Show()
		f.action2:SetText(T(W.art.mode == "bots" and "A_MAILS" or "A_BACK"))
	else
		f.action2:Hide()
	end
	local columns = art and W.art.mode == "bots"
	local heads = { "C_ARTISAN", "C_LEVEL", "C_ZONE", "C_PROFS" }
	for c, fs in ipairs(f.heads) do fs:SetText(columns and T(heads[c]) or "") end
	if columns then
		f.filter:Show()
		f.filter:SetText(string.format(T("A_FILTER"), W.art.skill and W.SkillName(W.art.skill) or T("A_ALL")))
		f.hint:ClearAllPoints()
		f.hint:SetPoint("TOPLEFT", 20, -92)
	else
		f.filter:Hide()
		f.hint:ClearAllPoints()
		f.hint:SetPoint("TOPLEFT", 20, -96)
	end
	local rows = W.Rows()
	W.count = #rows
	W.offset = math.max(0, math.min(W.offset, #rows - ROWS))
	for i, row in ipairs(f.rows) do
		local r = rows[W.offset + i]
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
			for c, fs in ipairs(row.cols) do fs:SetText(r.cols and r.cols[c] or "") end
			row:Show()
		else
			row:Hide()
		end
	end
	local feature = W.tab
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
