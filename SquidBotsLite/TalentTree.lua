-- SquidBots Lite 3.0: the talent tree of a bot, on the sheet's Talents tab (a Tree / List switch).
-- The layout of the 21 CoA classes comes with the addon (TalentLayouts.lua, from CoA Spec); the bot sends its ranks
-- on the addon channel (SQBA), asked with "talents tree" (SquidBot):
--   TT n <treeId> <entryId> <spellId> <rank> <max> <learnable 1|0>   one per node it has data for
--   TT pts <treeId> <spent> <budget>                                  one per tree
--   TT -                                                              end
-- A click on a node learns one rank ("talents learn <entry>") for the player's alt; a random bot's sheet is read only.

local PREFIX, WAIT = "SQBA", 6
local STRINGS = {
	en = { TREE = "Tree", LIST = "List", PTS = "%d / %d points", NONE = "No tree yet: this realm's CoA Bots does not send it (3.0 or later); the talents are in the list.",
		NOCLASS = "No tree view for this bot's class (the 21 CoA classes only): its talents are in the list.", RANK = "Rank %d / %d", LEARN = "Click: learn one rank.", LOCKED = "Not available yet.",
		RO = "Read only: not one of your characters.", OTHER = "Another spec of the class: to look at only.",
		KNOWN = "Learned (a spec spell the level gives).", AT_LEVEL = "Unlocked at level %d.", SPEC_SPELL = "A spec spell the level gives." },
	fr = { TREE = "Arbre", LIST = "Liste", PTS = "%d / %d points", NONE = "Pas encore d'arbre : le CoA Bots de ce royaume ne l'envoie pas (3.0 ou plus) ; les talents sont dans la liste.",
		NOCLASS = "Pas de vue en arbre pour la classe de ce bot (les 21 classes CoA seulement) : ses talents sont dans la liste.", RANK = "Rang %d / %d", LEARN = "Clic : apprendre un rang.", LOCKED = "Pas encore disponible.",
		RO = "Lecture seule : ce n'est pas un de vos personnages.", OTHER = "Une autre spé de la classe : à regarder seulement.",
		KNOWN = "Appris (un sort de spé donné par le niveau).", AT_LEVEL = "Débloqué au niveau %d.", SPEC_SPELL = "Un sort de spé donné par le niveau." },
}

local TT = { mode = "tree", data = nil, pending = nil, tree = nil, askedAt = nil, name = nil, LINE = 2 }
SquidBotsLite_TalentTree = TT

local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or key
end

local function Split(text)
	local f = {}
	for part in (text .. "\t"):gmatch("([^\t]*)\t") do table.insert(f, part) end
	return f
end

-- entry -> class slug, built once from the layouts.
function TT.Index()
	if TT.byEntry then return end
	TT.byEntry, TT.treeOfEntry = {}, {}
	for slug, c in pairs(SquidBotsLite_TalentLayouts and SquidBotsLite_TalentLayouts.classes or {}) do
		for key, tree in pairs(c.trees) do
			for _, n in ipairs(tree.n) do TT.byEntry[n[1]], TT.treeOfEntry[n[1]] = slug, key end
		end
	end
end

function TT.ClassOf(entry)
	TT.Index()
	return TT.byEntry[entry]
end

-- The server names a spec tree by the core's SpecId (47 Valkyrie, 55 Soul), CoA Spec by its own (90, 80): the layout
-- tree is found by the entries the server sent for it (each entry is in one tree only).
function TT.LayoutKeyOf(entry)
	TT.Index()
	return TT.treeOfEntry[entry]
end

function TT.Reset()
	TT.data, TT.pending, TT.tree, TT.askedAt, TT.name = nil, nil, nil, nil, nil
end

function TT.State()
	if SquidBotsLite_SheetState then return SquidBotsLite_SheetState() end
end

function TT.Ask()
	local name = TT.State()
	if not name then return end
	if name ~= TT.name then TT.Reset() end
	TT.name, TT.askedAt = name, GetTime()
	if SquidBotsLite_QuietWhisper then SquidBotsLite_QuietWhisper("talents tree", name) end
end

-- The bot's lines: gathered until "-", then drawn.
function TT.OnAddon(prefix, message, channel, sender)
	if prefix ~= PREFIX or channel ~= "WHISPER" or not message or sender ~= TT.name then return end
	local f = Split(message)
	if f[1] ~= "TT" then return end
	TT.pending = TT.pending or { nodes = {}, pts = {}, trees = {} }
	local p = TT.pending
	if f[2] == "n" then
		local tree, entry = tonumber(f[3]), tonumber(f[4])
		if tree and entry then
			p.nodes[entry] = { tree = tree, spell = tonumber(f[5]) or 0, rank = tonumber(f[6]) or 0, max = tonumber(f[7]) or 1,
				learnable = f[8] == "1" }
			p.class = p.class or TT.ClassOf(entry)
			-- The server's tree id -> the layout's tree key; the tabs are layout keys.
			p.keyOf = p.keyOf or {}
			local key = TT.LayoutKeyOf(entry)
			if key and not p.keyOf[tree] then p.keyOf[tree] = key end
			if key and not p.trees[key] then p.trees[key] = true; table.insert(p.trees, key); p.sent = p.sent or {}; p.sent[key] = true end
		end
	elseif f[2] == "a" then
		local tree, entry = tonumber(f[3]), tonumber(f[4])
		if tree and entry then
			p.spells = p.spells or {}
			p.spells[entry] = { spell = tonumber(f[5]) or 0, known = f[6] == "1", level = tonumber(f[7]) or 0 }
			p.class = p.class or TT.ClassOf(entry)
			p.keyOf = p.keyOf or {}
			local key = TT.LayoutKeyOf(entry)
			if key and not p.keyOf[tree] then p.keyOf[tree] = key end
			if key and not p.trees[key] then p.trees[key] = true; table.insert(p.trees, key); p.sent = p.sent or {}; p.sent[key] = true end
		end
	elseif f[2] == "pts" then
		local tree = tonumber(f[3])
		if tree then p.ptsRaw = p.ptsRaw or {}; p.ptsRaw[tree] = { spent = tonumber(f[4]) or 0, budget = tonumber(f[5]) or 0 } end
	elseif f[2] == "-" then
		TT.data, TT.pending = p, nil
		-- The points by layout key; the other specs of the class after the bot's own (to look at: no ranks, read only).
		for tree, pts in pairs(p.ptsRaw or {}) do
			local key = p.keyOf and p.keyOf[tree]
			if key then p.pts[key] = pts end
		end
		local layout = TT.Layout()
		-- The class tree ("Class") first, then the bot's spec.
		if layout then
			table.sort(p.trees, function(a, b)
				local ta, tb = layout.trees[a], layout.trees[b]
				local ca = ta and ta.name == "Class" and 0 or (p.sent and p.sent[a]) and 1 or 2
				local cb = tb and tb.name == "Class" and 0 or (p.sent and p.sent[b]) and 1 or 2
				if ca ~= cb then return ca < cb end
				return a < b
			end)
		end
		if not TT.tree or not TT.HasTree(TT.tree) then TT.tree = p.trees[1] end
		TT.Redraw()
	end
end

function TT.Layout()
	local d = TT.data
	local slug = d and d.class
	return slug and SquidBotsLite_TalentLayouts and SquidBotsLite_TalentLayouts.classes[slug]
end

-- A tree of the layout by the server's id: the class tree comes as 0 (the core's SpecId of class entries, SquidBot).
function TT.LayoutTree(layout, id)
	if not layout then return end
	if layout.trees[id] then return layout.trees[id] end
	if id == 0 then
		for _, t in pairs(layout.trees) do if t.name == "Class" then return t end end
	end
end

function TT.HasTree(tree)
	for _, t in ipairs(TT.data and TT.data.trees or {}) do if t == tree then return true end end
	return false
end

-- ---------------------------------------------------------------------------
-- The view: tree buttons, the points, the grid (icons, rank badges, prerequisite lines).
-- ---------------------------------------------------------------------------
function TT.Build(page)
	TT.page = page
	page.treeSwitch = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	-- Right of the list's rows and left of its scroll arrow; above the tree view.
	page.treeSwitch:SetWidth(54)
	page.treeSwitch:SetHeight(20)
	page.treeSwitch:SetPoint("TOPRIGHT", -32, 0)
	page.treeSwitch:SetNormalFontObject(GameFontNormalSmall)
	page.treeSwitch:SetHighlightFontObject(GameFontHighlightSmall)
	page.treeSwitch:SetScript("OnEnter", function(self)
		if not TT.reason then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(T("TREE"), 1, 0.82, 0)
		GameTooltip:AddLine(T(TT.reason), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	page.treeSwitch:SetScript("OnLeave", function() GameTooltip:Hide() end)
	page.treeSwitch:SetMotionScriptsWhileDisabled(true)
	page.treeSwitch:SetScript("OnClick", function()
		TT.mode = TT.mode == "tree" and "list" or "tree"
		if TT.mode == "tree" and not TT.data then TT.Ask() end
		TT.Redraw()
	end)
	local v = CreateFrame("Frame", nil, page)
	TT.view = v
	v:SetAllPoints(page)
	v:SetFrameLevel(page:GetFrameLevel() + 20)
	v:EnableMouse(true)
	v.bg = v:CreateTexture(nil, "BACKGROUND")
	v.bg:SetAllPoints()
	v.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
	v.bg:SetVertexColor(0.04, 0.04, 0.06, 0.97)
	v.tabs = {}
	for i = 1, 5 do
		local b = CreateFrame("Button", nil, v, "UIPanelButtonTemplate")
		b:SetWidth(84)
		b:SetHeight(20)
		b:SetPoint("TOPLEFT", 6 + (i - 1) * 86, -2)
		b:SetNormalFontObject(GameFontNormalSmall)
		b:SetHighlightFontObject(GameFontHighlightSmall)
		b:SetScript("OnClick", function(self) TT.tree = self.tree; TT.Redraw() end)
		b:Hide()
		v.tabs[i] = b
	end
	v.pts = v:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	v.pts:SetPoint("BOTTOMRIGHT", -8, 6)
	v.note = v:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	v.note:SetPoint("CENTER", 0, 0)
	v.note:SetWidth(400)
	v.grid = CreateFrame("Frame", nil, v)
	v.grid:SetPoint("TOPLEFT", 6, -28)
	v.grid:SetPoint("BOTTOMRIGHT", -6, 20)
	v.nodes, v.lines = {}, {}
	v:Hide()
	page.treeSwitch:SetFrameLevel(v:GetFrameLevel() + 10)
end

-- A node button (made on first use, kept).
function TT.Node(i)
	local v = TT.view
	if v.nodes[i] then return v.nodes[i] end
	local b = CreateFrame("Button", nil, v.grid)
	b:SetWidth(30)
	b:SetHeight(30)
	b:SetFrameLevel(v.grid:GetFrameLevel() + 3)
	b.border = b:CreateTexture(nil, "BACKGROUND")
	b.border:SetTexture("Interface\\Buttons\\WHITE8X8")
	b.border:SetPoint("TOPLEFT", -2, 2)
	b.border:SetPoint("BOTTOMRIGHT", 2, -2)
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetAllPoints()
	b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	b.rank = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	b.rank:SetPoint("BOTTOMRIGHT", 4, -4)
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.spell and self.spell > 0 then GameTooltip:SetHyperlink("spell:" .. self.spell) else GameTooltip:SetText(self.label or "?", 1, 0.82, 0) end
		if self.ability then
			-- A spec spell given by the level: learned, or the level that brings it.
			if self.known then GameTooltip:AddLine(T("KNOWN"), 0.4, 0.8, 1)
			elseif (self.level or 0) > 0 then GameTooltip:AddLine(string.format(T("AT_LEVEL"), self.level), 0.6, 0.6, 0.6)
			else GameTooltip:AddLine(T("SPEC_SPELL"), 0.6, 0.6, 0.6) end
			GameTooltip:Show()
			return
		end
		GameTooltip:AddLine(string.format(T("RANK"), self.cur or 0, self.max or 1), 1, 1, 1)
		local _, ro = TT.State()
		if ro then GameTooltip:AddLine(T("RO"), 0.6, 0.6, 0.6, true)
		elseif self.learnable then GameTooltip:AddLine(T("LEARN"), 0.4, 1, 0.4)
		elseif (self.cur or 0) < (self.max or 1) then GameTooltip:AddLine(T("LOCKED"), 0.6, 0.6, 0.6) end
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	b:SetScript("OnClick", function(self)
		local name, ro = TT.State()
		if ro or self.ability or not self.learnable or not name or not SquidBotsLite_QuietWhisper then return end
		SquidBotsLite_QuietWhisper("talents learn " .. self.entry, name)
		-- The answer changes the ranks: asked again a moment later.
		local t, wait = 0, CreateFrame("Frame")
		wait:SetScript("OnUpdate", function(f, d) t = t + d; if t > 1.5 then f:SetScript("OnUpdate", nil); TT.Ask() end end)
	end)
	v.nodes[i] = b
	return b
end

function TT.Line(i)
	local v = TT.view
	if v.lines[i] then return v.lines[i] end
	local l = v.grid:CreateTexture(nil, "BORDER")
	l:SetTexture("Interface\\Buttons\\WHITE8X8")
	v.lines[i] = l
	return l
end

-- Draws the tree chosen: cells sized to fit the grid, a node per layout entry, an elbow line per link.
function TT.DrawTree()
	local v, layout, d = TT.view, TT.Layout(), TT.data
	local tree = layout and layout.trees[TT.tree]
	for _, b in ipairs(v.nodes) do b:Hide() end
	for _, l in ipairs(v.lines) do l:Hide() end
	if not tree then return end
	local gw, gh = v.grid:GetWidth(), v.grid:GetHeight()
	if not gw or gw <= 0 then gw, gh = 492, 380 end
	local cw, ch = gw / tree.w, gh / tree.h
	local pos = {}
	for i, n in ipairs(tree.n) do
		local entry, col, row, maxRank, kind = n[1], n[2], n[3], n[4], n[5]
		local x, y = (col + 0.5) * cw, (row + 0.5) * ch
		pos[entry] = { x = x, y = y }
		local b = TT.Node(i)
		local s = d.nodes[entry]
		local a = kind == 2 and d.spells and d.spells[entry]
		b.ability, b.known, b.level = kind == 2, a and a.known or false, a and a.level or 0
		b.entry, b.spell, b.label = entry, a and a.spell or s and s.spell or 0, layout.names[entry]
		b.cur, b.max, b.learnable = s and s.rank or 0, s and s.max or maxRank, (not b.ability) and s and s.learnable or false
		local _, _, icon = GetSpellInfo(b.spell or 0)
		b.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
		local full = b.cur >= b.max
		if b.ability then
			-- A spec spell: blue edge, lit once the bot has it; no rank, it is not bought with points.
			b.icon:SetDesaturated(not b.known)
			if b.known then b.border:SetVertexColor(0.35, 0.7, 1, 1) else b.border:SetVertexColor(0.2, 0.3, 0.45, 1) end
			b.rank:SetText("")
		else
		b.icon:SetDesaturated(b.cur == 0 and not b.learnable)
		-- Gold when full, green when it has ranks or can take one, dark otherwise.
		if full then b.border:SetVertexColor(1, 0.82, 0, 1)
		elseif b.cur > 0 or b.learnable then b.border:SetVertexColor(0.3, 0.9, 0.3, 1)
		else b.border:SetVertexColor(0.25, 0.25, 0.28, 1) end
		b.rank:SetText((b.max > 1 or b.cur > 0) and (b.cur .. "/" .. b.max) or "")
		end
		b.rank:SetTextColor(full and 1 or 0.4, full and 0.82 or 1, full and 0 or 0.4)
		b:ClearAllPoints()
		b:SetPoint("CENTER", v.grid, "TOPLEFT", x, -y)
		b:Show()
	end
	-- The links: down from the parent to the child's row, then across (an elbow), lit when the parent has a rank.
	local li = 0
	local function Seg(x1, y1, x2, y2, lit)
		li = li + 1
		local l = TT.Line(li)
		l:ClearAllPoints()
		local w = TT.LINE
		l:SetPoint("TOPLEFT", v.grid, "TOPLEFT", math.min(x1, x2) - w / 2, -(math.min(y1, y2) - w / 2))
		l:SetWidth(math.max(w, math.abs(x2 - x1) + w))
		l:SetHeight(math.max(w, math.abs(y2 - y1) + w))
		if lit then l:SetVertexColor(1, 0.82, 0, 0.8) else l:SetVertexColor(0.45, 0.45, 0.5, 0.6) end
		l:Show()
	end
	for _, e in ipairs(tree.e) do
		local a, b = pos[e[1]], pos[e[2]]
		if a and b then
			local s = d.nodes[e[1]]
			local lit = s and s.rank > 0
			if a.x == b.x or a.y == b.y then
				Seg(a.x, a.y, b.x, b.y, lit)
			else
				Seg(a.x, a.y, a.x, b.y, lit)
				Seg(a.x, b.y, b.x, b.y, lit)
			end
		end
	end
	local p = d.pts[TT.tree]
	v.pts:SetText(p and string.format(T("PTS"), p.spent, p.budget) or (d.sent and d.sent[TT.tree] and "" or T("OTHER")))
end

function TT.Redraw()
	local page, v = TT.page, TT.view
	if not page or not v then return end
	page.treeSwitch:SetText(T(TT.mode == "tree" and "LIST" or "TREE"))
	local d, layout = TT.data, TT.Layout()
	-- No tree for this bot (a classic class of a Warcraft Reborn realm, an older server, no answer): the list stays,
	-- the switch is greyed and says why in its tooltip; never an empty tree nor a wait without end.
	local reason = (d and not layout) and "NOCLASS" or (not d and TT.askedAt and GetTime() - TT.askedAt > WAIT) and "NONE" or nil
	TT.reason = reason
	if reason then page.treeSwitch:SetText(T("TREE")); page.treeSwitch:Disable() else page.treeSwitch:Enable() end
	if TT.mode ~= "tree" or not page:IsShown() or reason then v:Hide() return end
	v:Show()
	for _, b in ipairs(v.tabs) do b:Hide() end
	if not d then
		for _, b in ipairs(v.nodes) do b:Hide() end
		for _, l in ipairs(v.lines) do l:Hide() end
		v.pts:SetText("")
		v.note:SetText(TT.askedAt and GetTime() - TT.askedAt > WAIT and T("NONE") or "")
		return
	end
	if not layout then
		v.note:SetText(T("NOCLASS"))
		return
	end
	v.note:SetText("")
	for i, tree in ipairs(d.trees) do
		local b = v.tabs[i]
		if b then
			b.tree = tree
			local lt = layout.trees[tree]
			-- The spec's name, never a number; the specs the bot has not taken are dimmed (look only).
			local label = lt and lt.name or "?"
			if lt and lt.name ~= "Class" and not (d.sent and d.sent[tree]) then label = "|cff888888" .. label .. "|r" end
			b:SetText(label)
			if tree == TT.tree then b:LockHighlight() else b:UnlockHighlight() end
			b:Show()
		end
	end
	TT.DrawTree()
end

-- The sheet's Talents tab: drawn with the list (Manager.lua calls it); "no answer" shows after the wait.
function TT.Render(page)
	TT.page = page
	TT.Redraw()
end

-- A realm or class without the tree (Warcraft Reborn's classic classes) answers "talents tree" with "Unknown command.":
-- kept out of the chat, and the view falls back to the list at once.
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(_, _, message, name)
	if name == TT.name and TT.askedAt and GetTime() - TT.askedAt < 5 and message == "Unknown command." then
		if not TT.data then TT.data = { nodes = {}, pts = {}, trees = {} } end
		TT.Redraw()
		return true
	end
end)

local events = CreateFrame("Frame")
events:RegisterEvent("CHAT_MSG_ADDON")
events:SetScript("OnEvent", function(_, _, ...) TT.OnAddon(...) end)
events:SetScript("OnUpdate", function(self, delta)
	self.t = (self.t or 0) + delta
	if self.t < 1 then return end
	self.t = 0
	-- The "no answer" note once the wait is over.
	if TT.askedAt and not TT.data and TT.view and TT.view:IsShown() then TT.Redraw() end
end)
