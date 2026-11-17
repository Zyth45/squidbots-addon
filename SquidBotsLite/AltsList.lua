-- SquidBots Manager: the alts list sorted and filtered, and the team editor (player requests after 3.1.4).
-- Sort: logged in first (as before), name, last played, team, level (SquidBotsLiteDB.altsSort).
-- Hide: an alt (right-click its card) or every known alt of a linked account (Accounts menu); kept in the addon only
-- (SquidBotsLiteDB.altsHidden, .accountsHidden), nothing is deleted on the server, "Show hidden alts" brings them back.
-- Last played: SquidBotsLiteDB.altInfo[name].seen, the last time the character was in the game (played, or logged in
-- as a bot), recorded from this version on.
-- Teams: a window to rename, duplicate and edit a team: click or drag an alt from one list to the other, drag a
-- member up or down for the login order.

local AL = {}
SquidBotsLite_AltsList = AL

local STRINGS = {
	en = {
		SORT = "Sort: %s", SORT_BY = "Sort the list by", S_online = "Logged in first", S_name = "Name", S_played = "Last played",
		S_team = "Team", S_level = "Level", SHOW_HIDDEN = "Show hidden alts (%d)", UNHIDE_ALL = "Unhide every alt",
		HIDE = "Hide from my alts list", UNHIDE = "Show in my alts list", HIDE_ACCOUNT = "Hide every alt of account %s",
		HIDDEN_TAG = "hidden", HIDDEN = "%s hidden from your alts list (Sort > Show hidden alts brings it back).",
		ACC_HIDE = "Hide its alts from my list (%d known)", ACC_SHOW = "Show its alts in my list",
		ACC_UNKNOWN = "Hide its alts: log them in once from here first",
		AGO_NOW = "now", AGO_MIN = "%d min ago", AGO_H = "%d h ago", AGO_D = "%d d ago", PLAYED = "Last played: %s",
		NO_TEAM = "no team", TEAMS_TIP = "Teams: %s",
		EDIT = "Edit...", DUPLICATE = "Duplicate", NEW = "New team...", E_TITLE = "Team", E_NAME = "Name:",
		E_MEMBERS = "In the team (%d)", E_ALTS = "Your alts", E_SAVE = "Save", E_CANCEL = "Cancel",
		E_HELP = "Click or drag an alt to move it. Drag a member up or down: the login order.",
		E_NONAME = "Give the team a name.", E_EXISTS = "A team is already called %s.", E_SAVED = "team %s saved (%d).",
		COPY = "%s (copy)",
		GROUP_LOGIN = "Log in my group's bots (%d)", GROUP_STARTED = "logging in %d bots of your group.",
	},
	fr = {
		SORT = "Tri : %s", SORT_BY = "Trier la liste par", S_online = "Connectés d'abord", S_name = "Nom", S_played = "Dernier joué",
		S_team = "Équipe", S_level = "Niveau", SHOW_HIDDEN = "Afficher les alts cachés (%d)", UNHIDE_ALL = "Ne plus cacher aucun alt",
		HIDE = "Cacher de ma liste d'alts", UNHIDE = "Afficher dans ma liste d'alts", HIDE_ACCOUNT = "Cacher tous les alts du compte %s",
		HIDDEN_TAG = "caché", HIDDEN = "%s caché de votre liste d'alts (Tri > Afficher les alts cachés le remet).",
		ACC_HIDE = "Cacher ses alts de ma liste (%d connus)", ACC_SHOW = "Afficher ses alts dans ma liste",
		ACC_UNKNOWN = "Cacher ses alts : connectez-les une fois d'ici d'abord",
		AGO_NOW = "maintenant", AGO_MIN = "il y a %d min", AGO_H = "il y a %d h", AGO_D = "il y a %d j", PLAYED = "Dernier joué : %s",
		NO_TEAM = "sans équipe", TEAMS_TIP = "Équipes : %s",
		EDIT = "Modifier...", DUPLICATE = "Dupliquer", NEW = "Nouvelle équipe...", E_TITLE = "Équipe", E_NAME = "Nom :",
		E_MEMBERS = "Dans l'équipe (%d)", E_ALTS = "Vos alts", E_SAVE = "Enregistrer", E_CANCEL = "Annuler",
		E_HELP = "Cliquez ou glissez un alt pour le changer de liste. Glissez un membre : l'ordre de connexion.",
		E_NONAME = "Donnez un nom à l'équipe.", E_EXISTS = "Une équipe s'appelle déjà %s.", E_SAVED = "équipe %s enregistrée (%d).",
		COPY = "%s (copie)",
		GROUP_LOGIN = "Connecter les bots de mon groupe (%d)", GROUP_STARTED = "connexion de %d bots de votre groupe.",
	},
}

function AL.T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end
local T = AL.T

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Manager|r: " .. text)
end

local function Info(name, create)
	local db = SquidBotsLiteDB
	if create then
		db.altInfo = db.altInfo or {}
		db.altInfo[name] = db.altInfo[name] or {}
	end
	return db.altInfo and db.altInfo[name]
end

-- Last played: now, for a character in the game (the one played, or an alt logged in as a bot).
function AL.Seen(name)
	if name then Info(name, true).seen = time() end
end

function AL.Ago(t)
	local s = math.max(0, time() - t)
	if s < 60 then return T("AGO_NOW") end
	if s < 3600 then return string.format(T("AGO_MIN"), math.floor(s / 60)) end
	if s < 86400 then return string.format(T("AGO_H"), math.floor(s / 3600)) end
	return string.format(T("AGO_D"), math.floor(s / 86400))
end

-- Hidden: "alt" (hidden by itself), "account" (its linked account hidden), or nil.
function AL.Hidden(name)
	local db = SquidBotsLiteDB
	if db.altsHidden and db.altsHidden[name] then return "alt" end
	local account = db.altAccount and db.altAccount[name]
	if account and db.accountsHidden and db.accountsHidden[account] then return "account" end
end

function AL.SetHidden(name, hidden)
	local db = SquidBotsLiteDB
	db.altsHidden = db.altsHidden or {}
	db.altsHidden[name] = hidden and true or nil
	-- Shown again by itself: its account's hiding no longer covers it either.
	if not hidden and AL.Hidden(name) == "account" then
		local account = db.altAccount[name]
		db.accountsHidden[account] = nil
	end
	if hidden then Print(string.format(T("HIDDEN"), name)) end
end

-- Linked accounts: which account an alt came from, known when "Log in all" of that account logged it in.
function AL.AccountLogin(account)
	AL.pendingAccount, AL.pendingUntil = account, GetTime() + 20
end

function AL.NoteAccount(name)
	if not (AL.pendingAccount and GetTime() < AL.pendingUntil) then return end
	SquidBotsLiteDB.altAccount = SquidBotsLiteDB.altAccount or {}
	SquidBotsLiteDB.altAccount[name] = AL.pendingAccount
end

function AL.AccountAlts(account)
	local names = {}
	for name, acc in pairs(SquidBotsLiteDB.altAccount or {}) do
		if acc == account then table.insert(names, name) end
	end
	return names
end

-- The Accounts menu's line for one linked account.
function AL.AccountItem(account, refresh)
	local db = SquidBotsLiteDB
	if db.accountsHidden and db.accountsHidden[account] then
		return { text = T("ACC_SHOW"), notCheckable = true, func = function()
			db.accountsHidden[account] = nil
			if refresh then refresh() end
		end }
	end
	local count = #AL.AccountAlts(account)
	if count == 0 then return { text = T("ACC_UNKNOWN"), notCheckable = true, disabled = true } end
	return { text = string.format(T("ACC_HIDE"), count), notCheckable = true, func = function()
		db.accountsHidden = db.accountsHidden or {}
		db.accountsHidden[account] = true
		if refresh then refresh() end
	end }
end

-- Every team an alt belongs to, A to Z; the first one is the one the Team sort uses.
function AL.TeamsOf(name)
	local list = {}
	for team, members in pairs(SquidBotsLiteDB.teams or {}) do
		for _, n in ipairs(members) do
			if n == name then table.insert(list, team) break end
		end
	end
	table.sort(list)
	return list
end

function AL.TeamOf(name)
	return AL.TeamsOf(name)[1]
end

-- On the card: three teams at most, then "..." (the tooltip names them all; a long line is cut by the game).
AL.CARD_TEAMS = 3
function AL.TeamsText(name)
	local list = AL.TeamsOf(name)
	if #list == 0 then return nil end
	local shown = {}
	for i = 1, math.min(#list, AL.CARD_TEAMS) do shown[i] = list[i] end
	return table.concat(shown, ", ") .. (#list > AL.CARD_TEAMS and ", ..." or "")
end

AL.SORTS = { "online", "name", "played", "team", "level" }

local function SortKey(alt, mode)
	local info = Info(alt.name) or {}
	if mode == "played" then return info.seen
	elseif mode == "level" then return info.level
	elseif mode == "team" then return AL.TeamOf(alt.name) end
end

-- The list shown: the roster without the hidden alts (unless asked), in the order chosen. The online alts are
-- "played" now.
function AL.View(roster)
	local db = SquidBotsLiteDB
	local mode = db.altsSort or "online"
	local list = {}
	for _, alt in ipairs(roster) do
		if alt.online then AL.Seen(alt.name) end
		if db.altsShowHidden or not AL.Hidden(alt.name) then table.insert(list, alt) end
	end
	table.sort(list, function(a, b)
		if mode == "online" then
			if a.online ~= b.online then return a.online end
		elseif mode ~= "name" then
			local ka, kb = SortKey(a, mode), SortKey(b, mode)
			if ka ~= kb then
				-- Unknown last; the newest played and the highest level first, the teams A to Z.
				if ka == nil or kb == nil then return kb == nil end
				if mode == "team" then return ka < kb end
				return ka > kb
			end
		end
		return a.name < b.name
	end)
	return list
end

function AL.HiddenCount(roster)
	local n = 0
	for _, alt in ipairs(roster) do if AL.Hidden(alt.name) then n = n + 1 end end
	return n
end

function AL.SortLabel()
	return string.format(T("SORT"), T("S_" .. (SquidBotsLiteDB.altsSort or "online")))
end

-- What the card says more under this sort: the team, or when last played; "(hidden)" on a hidden card shown.
function AL.NameSuffix(name)
	if AL.Hidden(name) then return " |cff808080(" .. T("HIDDEN_TAG") .. ")|r" end
	return ""
end

function AL.InfoSuffix(name)
	local mode = SquidBotsLiteDB.altsSort
	if mode == "team" then
		return "  |cff88ccff" .. (AL.TeamsText(name) or T("NO_TEAM")) .. "|r"
	elseif mode == "played" then
		local info = Info(name)
		if info and info.seen then return "  |cffaaaaaa" .. AL.Ago(info.seen) .. "|r" end
	end
	return ""
end

function AL.Tooltip(name)
	local info = Info(name)
	if info and info.seen then GameTooltip:AddLine(string.format(T("PLAYED"), AL.Ago(info.seen)), 0.7, 0.7, 0.7) end
	local teams = AL.TeamsOf(name)
	if #teams > 0 then GameTooltip:AddLine(string.format(T("TEAMS_TIP"), table.concat(teams, ", ")), 0.53, 0.8, 1, true) end
end

-- The Sort button's menu.
function AL.SortItems(roster, refresh)
	local db = SquidBotsLiteDB
	local items = { { text = T("SORT_BY"), isTitle = true, notCheckable = true } }
	for _, mode in ipairs(AL.SORTS) do
		table.insert(items, { text = T("S_" .. mode), checked = (db.altsSort or "online") == mode, func = function()
			db.altsSort = mode ~= "online" and mode or nil
			refresh()
		end })
	end
	table.insert(items, { text = string.format(T("SHOW_HIDDEN"), AL.HiddenCount(roster)), checked = db.altsShowHidden and true or false,
		keepShownOnClick = 1, func = function()
			db.altsShowHidden = not db.altsShowHidden or nil
			refresh()
		end })
	if next(db.altsHidden or {}) or next(db.accountsHidden or {}) then
		table.insert(items, { text = T("UNHIDE_ALL"), notCheckable = true, func = function()
			db.altsHidden, db.accountsHidden = nil, nil
			refresh()
		end })
	end
	return items
end

-- Right-click on an alt's card.
function AL.RowItems(alt, refresh)
	local db = SquidBotsLiteDB
	local items = { { text = alt.name, isTitle = true, notCheckable = true } }
	if AL.Hidden(alt.name) then
		table.insert(items, { text = T("UNHIDE"), notCheckable = true, func = function() AL.SetHidden(alt.name, false) refresh() end })
	else
		table.insert(items, { text = T("HIDE"), notCheckable = true, func = function() AL.SetHidden(alt.name, true) refresh() end })
		local account = db.altAccount and db.altAccount[alt.name]
		if account then
			table.insert(items, { text = string.format(T("HIDE_ACCOUNT"), account), notCheckable = true, func = function()
				db.accountsHidden = db.accountsHidden or {}
				db.accountsHidden[account] = true
				refresh()
			end })
		end
	end
	return items
end

-- Team editor ------------------------------------------------------------------------------------------------------

local E = { members = {}, rows = 13, rowH = 18 }
AL.editor = E

local function IsAlt(name)
	return SquidBotsLiteDB.alts and SquidBotsLiteDB.alts[name]
end

local function Copy(list)
	local out = {}
	for _, n in ipairs(list or {}) do if IsAlt(n) then table.insert(out, n) end end
	return out
end

function AL.FreeName(base)
	local teams, name, i = SquidBotsLiteDB.teams or {}, base, 2
	while teams[name] do
		name = base .. " " .. i
		i = i + 1
	end
	return name
end

-- The alts not in the team, by name (the hidden ones too: the list is the player's to choose from).
function E.Others()
	local inTeam, list = {}, {}
	for _, n in ipairs(E.members) do inTeam[n] = true end
	for name in pairs(SquidBotsLiteDB.alts or {}) do
		if not inTeam[name] then table.insert(list, name) end
	end
	table.sort(list)
	return list
end

-- Moves: to the team (at a place, or last), out of it.
function E.Add(name, at)
	for i, n in ipairs(E.members) do
		if n == name then table.remove(E.members, i) if at and at > i then at = at - 1 end break end
	end
	if at and at >= 1 and at <= #E.members + 1 then table.insert(E.members, at, name) else table.insert(E.members, name) end
	E.Refresh()
end

function E.Remove(name)
	for i, n in ipairs(E.members) do
		if n == name then table.remove(E.members, i) break end
	end
	E.Refresh()
end

-- Save: a new name must be free; a renamed team leaves its old name.
function E.Save()
	local name = strtrim(E.frame.name:GetText() or "")
	local teams = SquidBotsLiteDB.teams or {}
	if name == "" then E.frame.status:SetText(T("E_NONAME")) return false end
	if name ~= E.original and teams[name] then E.frame.status:SetText(string.format(T("E_EXISTS"), name)) return false end
	SquidBotsLiteDB.teams = teams
	teams[name] = Copy(E.members)
	if E.original and E.original ~= name then teams[E.original] = nil end
	Print(string.format(T("E_SAVED"), name, #teams[name]))
	E.frame:Hide()
	return true
end

local function ColumnRows(column)
	return column == E.frame.left and E.members or E.Others()
end

local function DisplayName(name)
	local ui = SquidBotsLite_UI
	local text = ui and ui.ClassName and ui.ClassName(name) or name
	local info = Info(name)
	if info and info.level then text = text .. " |cffaaaaaa" .. info.level .. "|r" end
	return text
end

function E.Refresh()
	local f = E.frame
	if not f then return end
	f.left.head:SetText(string.format(T("E_MEMBERS"), #E.members))
	for _, column in ipairs({ f.left, f.right }) do
		local list = ColumnRows(column)
		column.offset = math.max(0, math.min(column.offset or 0, #list - E.rows))
		for i, row in ipairs(column.rows) do
			local name = list[i + column.offset]
			row.who, row.index = name, i + column.offset
			if name then
				row.text:SetText((column == f.left and (row.index .. ". ") or "") .. DisplayName(name))
				row:Show()
			else
				row:Hide()
			end
		end
	end
end

-- Dragging: the name follows the cursor; dropped on the other list, it moves there; on the team's list, at that place.
function E.DropAt()
	local f = E.frame
	if MouseIsOver(f.left) then
		for _, row in ipairs(f.left.rows) do
			if row:IsShown() and MouseIsOver(row) then return "left", row.index end
		end
		return "left", nil
	elseif MouseIsOver(f.right) then
		return "right"
	end
end

function E.Drop(name, from)
	local target, at = E.DropAt()
	if target == "left" then E.Add(name, at)
	elseif target == "right" and from == "left" then E.Remove(name) end
end

local function Row(column, i)
	local row = CreateFrame("Button", nil, column)
	row:SetHeight(E.rowH)
	row:SetPoint("TOPLEFT", 4, -22 - (i - 1) * E.rowH)
	row:SetPoint("RIGHT", -4, 0)
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.text:SetPoint("LEFT", 4, 0)
	row.text:SetJustifyH("LEFT")
	row:RegisterForClicks("LeftButtonUp")
	row:RegisterForDrag("LeftButton")
	row:SetScript("OnClick", function(self)
		if not self.who then return end
		if column == E.frame.left then E.Remove(self.who) else E.Add(self.who) end
	end)
	row:SetScript("OnDragStart", function(self)
		if not self.who then return end
		E.dragging = { name = self.who, from = column == E.frame.left and "left" or "right" }
		E.frame.ghost.text:SetText(DisplayName(self.who))
		E.frame.ghost:Show()
	end)
	row:SetScript("OnDragStop", function()
		local drag = E.dragging
		E.dragging = nil
		E.frame.ghost:Hide()
		if drag then E.Drop(drag.name, drag.from) end
	end)
	row:EnableMouseWheel(true)
	row:SetScript("OnMouseWheel", function(_, delta) column:GetScript("OnMouseWheel")(column, delta) end)
	return row
end

local function Column(f, x)
	local column = CreateFrame("Frame", nil, f)
	column:SetWidth(200)
	column:SetHeight(22 + E.rows * E.rowH + 4)
	column:SetPoint("TOPLEFT", x, -72)
	column:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
	column:SetBackdropColor(0.08, 0.08, 0.1, 0.9)
	column:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
	column.head = column:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	column.head:SetPoint("TOPLEFT", 8, -7)
	column:EnableMouseWheel(true)
	column:SetScript("OnMouseWheel", function(self, delta)
		self.offset = (self.offset or 0) - delta * 3
		E.Refresh()
	end)
	column.rows = {}
	for i = 1, E.rows do column.rows[i] = Row(column, i) end
	return column
end

function E.Build()
	local f = CreateFrame("Frame", "SquidBotsLiteTeamEditor", UIParent)
	E.frame = f
	f:SetWidth(440)
	f:SetHeight(72 + 22 + E.rows * E.rowH + 4 + 64)
	f:SetPoint("CENTER")
	f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } })
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteTeamEditor")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -16)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	f.nameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.nameLabel:SetPoint("TOPLEFT", 20, -46)
	f.name = CreateFrame("EditBox", "SquidBotsLiteTeamEditorName", f, "InputBoxTemplate")
	f.name:SetWidth(180)
	f.name:SetHeight(20)
	f.name:SetAutoFocus(false)
	f.name:SetMaxLetters(24)
	f.name:SetPoint("LEFT", f.nameLabel, "RIGHT", 10, 0)
	f.name:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	f.name:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f.left = Column(f, 16)
	f.right = Column(f, 224)
	f.help = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.help:SetPoint("TOPLEFT", f.left, "BOTTOMLEFT", 2, -6)
	f.help:SetWidth(400)
	f.help:SetJustifyH("LEFT")
	f.status = f:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	f.status:SetPoint("BOTTOMLEFT", 20, 20)
	f.status:SetWidth(200)
	f.status:SetJustifyH("LEFT")
	f.save = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.save:SetWidth(96)
	f.save:SetHeight(22)
	f.save:SetPoint("BOTTOMRIGHT", -116, 16)
	f.save:SetScript("OnClick", function() E.Save() end)
	f.cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.cancel:SetWidth(96)
	f.cancel:SetHeight(22)
	f.cancel:SetPoint("BOTTOMRIGHT", -16, 16)
	f.cancel:SetScript("OnClick", function() f:Hide() end)
	-- The name being dragged, under the cursor.
	f.ghost = CreateFrame("Frame", nil, UIParent)
	f.ghost:SetFrameStrata("TOOLTIP")
	f.ghost:SetWidth(160)
	f.ghost:SetHeight(18)
	f.ghost.text = f.ghost:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.ghost.text:SetPoint("LEFT")
	f.ghost:SetScript("OnUpdate", function(self)
		local x, y = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / scale + 12, y / scale - 6)
	end)
	f.ghost:Hide()
	f:SetScript("OnHide", function() E.dragging = nil f.ghost:Hide() end)
	f:Hide()
end

-- Opens the editor on a team (nil: a new one); copy: a duplicate under a free name, the original kept.
function AL.EditTeam(name, copy)
	if not E.frame then E.Build() end
	local f = E.frame
	local members = name and (SquidBotsLiteDB.teams or {})[name]
	E.members = Copy(members)
	E.original = (name and not copy) and name or nil
	f.title:SetText(T("E_TITLE"))
	f.nameLabel:SetText(T("E_NAME"))
	f.right.head:SetText(T("E_ALTS"))
	f.help:SetText(T("E_HELP"))
	f.save:SetText(T("E_SAVE"))
	f.cancel:SetText(T("E_CANCEL"))
	f.status:SetText("")
	f.name:SetText(copy and AL.FreeName(string.format(T("COPY"), name)) or name or "")
	f.left.offset, f.right.offset = 0, 0
	E.Refresh()
	f:Show()
end

-- The Teams menu's lines for one team (a second-level menu: the game has no third level).
function AL.TeamItems(name)
	return {
		{ text = T("EDIT"), notCheckable = true, func = function() AL.EditTeam(name) end },
		{ text = T("DUPLICATE"), notCheckable = true, func = function() AL.EditTeam(name, true) end },
	}
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
	SquidBotsLiteDB = SquidBotsLiteDB or {}
	AL.Seen(UnitName("player"))
end)
