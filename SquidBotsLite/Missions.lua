-- SquidBots Lite, missions: send a logged-in alt gathering on its own (mining or herbalism) while you play,
-- follow it, call it back; what it gathers comes by mail. Everything goes through what a player can whisper to
-- their own alt: "mission gather [minutes] [mining|herbalism]", "mission status", "mission stop" (CoA Bots 2.8.2).
-- "mission status" answers "MISSION;<TRAVEL|WORK|DELIVER>;<zone>;<minutes left>;<items>;<mining|herbalism>;<deaths>"
-- or "MISSION;NONE"; those lines and the polls stay out of the chat.

local STRINGS = {
	en = {
		TITLE = "Missions", REFRESH = "Refresh", SEND = "Send", RECALL = "Recall", NONE = "Free",
		HINT = "Send a logged-in alt gathering on its own while you play: it leaves the group, gathers, and mails you what it found. You stay logged in (on any character).",
		NO_ALTS = "No alt logged in: log one in from My alts, then Refresh.",
		COUNT = "On a mission: %d / 3", WAIT = "Asking your alts...",
		AUTO = "Its gathering skill", MINING = "Mining", HERBALISM = "Herbalism", MIN = "%d min",
		TRAVEL = "On the way to %s", WORK = "Gathering in %s", DELIVER = "Mailing the loot",
		LEFT = "%d min left", ITEMS = "%d items", DEATHS = "%d deaths", DEATH = "1 death",
		SKILL_mining = "mining", SKILL_herbalism = "herbalism",
		RECALL_ASK = "Call %s back now? What it gathered so far comes by mail.",
		MAIL = "Mail from %s has arrived: %d items (at a mailbox).", DONE = "%s: mission over. %s",
		TIP_SEND = "Choose the skill and how long: up to 120 min, 3 alts at a time.",
		TIP_RECALL = "Ends the mission now: the loot comes by mail, the alt waits for you or comes back.",
	},
	fr = {
		TITLE = "Missions", REFRESH = "Actualiser", SEND = "Envoyer", RECALL = "Rappeler", NONE = "Libre",
		HINT = "Envoyez un alt connecté récolter seul pendant que vous jouez : il quitte le groupe, récolte, et vous envoie sa récolte par courrier. Vous restez connecté (sur n'importe quel personnage).",
		NO_ALTS = "Aucun alt connecté : connectez-en un depuis Mes alts, puis Actualiser.",
		COUNT = "En mission : %d / 3", WAIT = "Je demande à vos alts...",
		AUTO = "Son métier de récolte", MINING = "Minage", HERBALISM = "Herboristerie", MIN = "%d min",
		TRAVEL = "En route vers %s", WORK = "Récolte à %s", DELIVER = "Envoi du butin",
		LEFT = "%d min restantes", ITEMS = "%d objets", DEATHS = "%d morts", DEATH = "1 mort",
		SKILL_mining = "minage", SKILL_herbalism = "herboristerie",
		RECALL_ASK = "Rappeler %s maintenant ? Ce qu'il a déjà récolté arrive par courrier.",
		MAIL = "Le courrier de %s est arrivé : %d objets (à une boîte aux lettres).", DONE = "%s : mission terminée. %s",
		TIP_SEND = "Choisissez le métier et la durée : jusqu'à 120 min, 3 alts à la fois.",
		TIP_RECALL = "Arrête la mission tout de suite : le butin arrive par courrier, l'alt vous attend ou revient.",
	},
}
local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or key
end

local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } }
local ROWS, ROW_H, ROWS_TOP = 10, 34, 96
-- One poll a minute while an alt is out (or the panel is open); one whisper a second, so as not to flood.
local POLL_EVERY, POLL_GAP, OFFLINE_WAIT = 60, 1, 3
local DURATIONS = { 30, 60, 90, 120 }

local M = { alts = {}, status = {}, queue = {}, nextSend = 0, nextPoll = 0, polled = {}, mail = {} }

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text)
end

local function Whisper(name, text)
	M.polled[name] = GetTime()
	SendChatMessage(text, "WHISPER", nil, name)
end

-- The online alts, from the My alts roster (".playerbots bot list").
function M.Refresh()
	M.alts = SquidBotsLite_OnlineAlts and SquidBotsLite_OnlineAlts() or {}
	table.sort(M.alts)
end

function M.Poll()
	M.Refresh()
	M.queue = {}
	for _, name in ipairs(M.alts) do table.insert(M.queue, name) end
	M.nextPoll = GetTime() + POLL_EVERY
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

-- "MISSION;WORK;Elwynn Forest;42;17;mining;0" or "MISSION;NONE".
function M.OnStatus(name, message)
	local parts = {}
	for field in (message .. ";"):gmatch("([^;]*);") do table.insert(parts, field) end
	if parts[2] == "NONE" then
		M.status[name] = { state = "NONE" }
	else
		M.status[name] = { state = parts[2], zone = parts[3] or "?", minutes = tonumber(parts[4] or "") or 0,
			items = tonumber(parts[5] or "") or 0, skill = parts[6], deaths = tonumber(parts[7] or "") or 0 }
		if parts[6] == "mining" or parts[6] == "herbalism" then
			SquidBotsLiteDB.missionSkill = SquidBotsLiteDB.missionSkill or {}
			SquidBotsLiteDB.missionSkill[name] = parts[6]
		end
	end
	M.RefreshPanel()
end

-- The alt's own lines: started (ask its state), done (mail coming), refused or resumed (shown as they are).
function M.OnLine(name, message)
	if message:find("^Mission started: ") or message:find("^Mission resumed: ") then
		local skill = message:match("^Mission %a+: (%a+) in ")
		if skill == "mining" or skill == "herbalism" then
			SquidBotsLiteDB.missionSkill = SquidBotsLiteDB.missionSkill or {}
			SquidBotsLiteDB.missionSkill[name] = skill
		end
		table.insert(M.queue, name)
	elseif message:find("^Mission done: ") then
		M.status[name] = { state = "NONE" }
		local count = tonumber(message:match("(%d+) items sent to you by mail") or "")
		if count and count > 0 then M.mail[name] = count end
		local rest = message:match("^Mission done: (.*)$") or ""
		if UIErrorsFrame then UIErrorsFrame:AddMessage(string.format(T("DONE"), name, rest), 1, 0.82, 0) end
		M.RefreshPanel()
	end
end

function M.Send(name, minutes, skill)
	local text = "mission gather " .. minutes .. (skill and (" " .. skill) or "")
	Whisper(name, text)
end

function M.Recall(name)
	StaticPopupDialogs.SQUIDBOTSLITE_MISSION_RECALL = {
		text = T("RECALL_ASK"), button1 = YES, button2 = NO, timeout = 0, whileDead = true, hideOnEscape = true,
		OnAccept = function(_, data) Whisper(data, "mission stop") end,
	}
	local dialog = StaticPopup_Show("SQUIDBOTSLITE_MISSION_RECALL", name)
	if dialog then dialog.data = name end
end

function M.SendMenu(name)
	local function Durations(skill)
		local list = {}
		for _, minutes in ipairs(DURATIONS) do
			table.insert(list, { text = string.format(T("MIN"), minutes), notCheckable = true,
				func = function() CloseDropDownMenus(); M.Send(name, minutes, skill) end })
		end
		return list
	end
	local known = SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name]
	local items = {
		{ text = name, isTitle = true, notCheckable = true },
		{ text = T("AUTO") .. (known and (" (" .. T("SKILL_" .. known) .. ")") or ""), hasArrow = true, notCheckable = true, menuList = Durations(nil) },
		{ text = T("MINING"), hasArrow = true, notCheckable = true, menuList = Durations("mining") },
		{ text = T("HERBALISM"), hasArrow = true, notCheckable = true, menuList = Durations("herbalism") },
	}
	M.menu = M.menu or CreateFrame("Frame", "SquidBotsLiteMissionMenu", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(items, M.menu, "cursor", 0, 0, "MENU")
	if SquidBotsLite_WatchMenu then SquidBotsLite_WatchMenu() end
end

-- ---------------------------------------------------------------------------
-- The panel
-- ---------------------------------------------------------------------------
local function Button(parent, width, onClick, tip)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetWidth(width)
	button:SetHeight(20)
	button:SetScript("OnClick", onClick)
	if tip then
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(self:GetText() or "", 1, 0.82, 0)
			GameTooltip:AddLine(T(tip), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end
	return button
end

function M.Build()
	local f = CreateFrame("Frame", "SquidBotsLiteMissions", UIParent)
	f:SetWidth(400)
	f:SetPoint("CENTER", -200, 40)
	f:SetBackdrop(BACKDROP)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.96)
	f:SetFrameStrata("DIALOG")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteMissions")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -14)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.hint:SetPoint("TOPLEFT", 18, -36)
	f.hint:SetWidth(364)
	f.hint:SetJustifyH("LEFT")
	f.count = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.count:SetPoint("TOPLEFT", 18, -76)
	f.refresh = Button(f, 90, function()
		if SquidBotsLite_AskRoster then SquidBotsLite_AskRoster() end
		M.Poll()
		M.RefreshPanel()
	end)
	f.refresh:SetHeight(18)
	f.refresh:SetPoint("TOPRIGHT", -16, -72)
	f.empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.empty:SetPoint("TOPLEFT", 20, -ROWS_TOP - 6)
	f.empty:SetWidth(360)
	f.empty:SetJustifyH("LEFT")
	f.rows = {}
	for i = 1, ROWS do
		local row = CreateFrame("Frame", nil, f)
		row:SetWidth(368)
		row:SetHeight(ROW_H)
		row:SetPoint("TOPLEFT", 16, -ROWS_TOP - (i - 1) * ROW_H)
		row.bg = row:CreateTexture(nil, "BACKGROUND")
		row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.bg:SetAllPoints()
		row.dot = row:CreateTexture(nil, "ARTWORK")
		row.dot:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.dot:SetWidth(8)
		row.dot:SetHeight(8)
		row.dot:SetPoint("LEFT", 6, 0)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.name:SetPoint("TOPLEFT", 20, -3)
		row.name:SetWidth(250)
		row.name:SetJustifyH("LEFT")
		row.info = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.info:SetPoint("TOPLEFT", 20, -18)
		row.info:SetWidth(262)
		row.info:SetJustifyH("LEFT")
		row.action = Button(row, 78, function(self)
			local name = self:GetParent().alt
			if not name then return end
			if M.OnMission(name) then M.Recall(name) else M.SendMenu(name) end
		end)
		row.action:SetPoint("RIGHT", -4, 0)
		row.action:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(self:GetText() or "", 1, 0.82, 0)
			GameTooltip:AddLine(T(self.tip or "TIP_SEND"), 1, 1, 1, true)
			GameTooltip:Show()
		end)
		row.action:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f.rows[i] = row
	end
	f:Hide()
	M.panel = f
end

local function Line(s)
	local parts = {}
	if s.state == "TRAVEL" then
		table.insert(parts, string.format(T("TRAVEL"), s.zone))
	elseif s.state == "WORK" then
		table.insert(parts, string.format(T("WORK"), s.zone))
	else
		table.insert(parts, T("DELIVER"))
	end
	table.insert(parts, string.format(T("LEFT"), s.minutes))
	table.insert(parts, string.format(T("ITEMS"), s.items))
	if s.deaths == 1 then
		table.insert(parts, "|cffff5555" .. T("DEATH") .. "|r")
	elseif s.deaths > 1 then
		table.insert(parts, "|cffff5555" .. string.format(T("DEATHS"), s.deaths) .. "|r")
	end
	return table.concat(parts, "  ·  ")
end

function M.RefreshPanel()
	local f = M.panel
	if not f or not f:IsShown() then return end
	f.title:SetText(T("TITLE"))
	f.hint:SetText(T("HINT"))
	f.refresh:SetText(T("REFRESH"))
	f.count:SetText(string.format(T("COUNT"), M.Count()))
	local alts = M.alts
	f:SetHeight(ROWS_TOP + math.max(1, math.min(#alts, ROWS)) * ROW_H + 24)
	f.empty:SetText(#alts == 0 and T("NO_ALTS") or "")
	for i, row in ipairs(f.rows) do
		local name = alts[i]
		if name then
			row.alt = name
			local s = M.status[name]
			local skill = SquidBotsLiteDB.missionSkill and SquidBotsLiteDB.missionSkill[name]
			row.name:SetText(name .. (skill and (" |cffaaaaaa(" .. T("SKILL_" .. skill) .. ")|r") or ""))
			row.bg:SetVertexColor(1, 1, 1, i % 2 == 0 and 0.04 or 0)
			if s and s.state ~= "NONE" then
				row.dot:SetVertexColor(1, 0.82, 0)
				row.info:SetText(Line(s))
				row.action:SetText(T("RECALL"))
				row.action.tip = "TIP_RECALL"
			else
				row.dot:SetVertexColor(s and 0.35 or 0.5, s and 1 or 0.5, s and 0.35 or 0.5)
				row.info:SetText(s and T("NONE") or T("WAIT"))
				row.action:SetText(T("SEND"))
				row.action.tip = "TIP_SEND"
			end
			row:Show()
		else
			row.alt = nil
			row:Hide()
		end
	end
end

function SquidBotsLite_ShowMissions()
	if not M.panel then M.Build() end
	if M.panel:IsShown() then M.panel:Hide() return end
	M.panel:Show()
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
	if message:find("^MISSION;") and IsAlt(name) then return true end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_, _, message, name)
	if message == "mission status" and IsAlt(name) then return true end
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
frame:SetScript("OnEvent", function(_, event, message, name)
	if event == "CHAT_MSG_WHISPER" then
		if not IsAlt(name) then return end
		if message:find("^MISSION;") then
			M.OnStatus(name, message)
		elseif message:find("^Mission ") then
			M.OnLine(name, message)
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		local gone = message:match("^No player named '(.-)' is currently playing%.$")
		if gone and M.status[gone] then
			M.status[gone] = nil
			M.RefreshPanel()
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
		Whisper(table.remove(M.queue, 1), "mission status")
		M.nextSend = now + POLL_GAP
	end
	-- Every minute, while an alt is out or the panel is open.
	if now >= M.nextPoll and (M.Count() > 0 or (M.panel and M.panel:IsShown())) then
		M.Poll()
	end
end)
