-- SquidBots Manager 3.2: "What is this bot doing?" on the target frame, for debugging (module 32fd04de).
-- The button says ".squidbots why" (the realm takes the line as a command, nothing is said aloud). The realm answers with
-- system lines "[SquidBots why] ..."; they are gathered in a small window whose text can be copied (Ctrl+C) and pasted
-- to us. Open to every account on CoA Bots 3.2 (a realm may keep it to GMs: its refusal is one of those lines); no
-- answer at all, or the line echoed as chat, means an older realm, said in the window in plain words.

local W = { lines = {}, WAIT = 3, PREFIX = "[SquidBots why] " }
SquidBotsLite_Why = W

local STRINGS = {
	en = {
		BUTTON_TIP = "What is this bot doing?", BUTTON_TIP2 = "Asks the server (.squidbots why). Needs CoA Bots 3.2.",
		TITLE = "What is this bot doing?", ASKING = "Asking the server about %s...",
		COPY = "Ctrl+C copies the text; paste it to us when you report a bot.",
		REFUSED = "No answer from the server (CoA Bots 3.2 needed).",
		REFUSED_SAID = "Refused: the server took .squidbots why as plain chat (CoA Bots 3.2 needed).",
		CLOSE = "Close", SELECT = "Select all",
	},
	fr = {
		BUTTON_TIP = "Que fait ce bot ?", BUTTON_TIP2 = "Demande au serveur (.squidbots why). Il faut CoA Bots 3.2.",
		TITLE = "Que fait ce bot ?", ASKING = "Question au serveur sur %s...",
		COPY = "Ctrl+C copie le texte ; collez-le-nous quand vous signalez un bot.",
		REFUSED = "Pas de réponse du serveur (il faut CoA Bots 3.2).",
		REFUSED_SAID = "Refusé : le serveur a pris .squidbots why pour du texte (il faut CoA Bots 3.2).",
		CLOSE = "Fermer", SELECT = "Tout sélectionner",
	},
}

local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

-- The window: a title, the answer in a read-only edit box (so it can be selected and copied), a hint, Close.
function W.Window()
	if W.frame then return W.frame end
	local f = CreateFrame("Frame", "SquidBotsLiteWhyFrame", UIParent)
	f:SetWidth(520)
	f:SetHeight(200)
	f:SetPoint("CENTER", 0, 120)
	f:SetFrameStrata("DIALOG")
	f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SquidBotsLiteWhyFrame")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOPLEFT", 12, -10)
	local scroll = CreateFrame("ScrollFrame", "SquidBotsLiteWhyScroll", f, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 12, -30)
	scroll:SetPoint("BOTTOMRIGHT", -32, 40)
	local box = CreateFrame("EditBox", nil, scroll)
	box:SetMultiLine(true)
	box:SetAutoFocus(false)
	box:SetFontObject(ChatFontNormal)
	box:SetWidth(470)
	box:SetScript("OnEscapePressed", function() f:Hide() end)
	-- Read-only: any typing puts the answer back.
	box:SetScript("OnTextChanged", function(self, user) if user then self:SetText(W.text or "") self:HighlightText() end end)
	scroll:SetScrollChild(box)
	f.box = box
	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("BOTTOMLEFT", 12, 16)
	f.hint:SetText(T("COPY"))
	local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	close:SetWidth(80)
	close:SetHeight(22)
	close:SetPoint("BOTTOMRIGHT", -10, 10)
	close:SetText(T("CLOSE"))
	close:SetScript("OnClick", function() f:Hide() end)
	local all = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	all:SetWidth(110)
	all:SetHeight(22)
	all:SetPoint("RIGHT", close, "LEFT", -6, 0)
	all:SetText(T("SELECT"))
	all:SetScript("OnClick", function() box:SetFocus() box:HighlightText() end)
	W.frame = f
	return f
end

function W.Show(text)
	W.text = text
	local f = W.Window()
	f.title:SetText(T("TITLE"))
	f.hint:SetText(T("COPY"))
	f.box:SetText(text)
	f:Show()
	f.box:SetFocus()
	f.box:HighlightText()
end

-- Ask about the target: the window opens at once, filled as the lines come; no line within WAIT seconds = refused.
function W.Ask()
	local name = UnitName("target")
	if not name then return end
	W.lines, W.waiting, W.deadline, W.name = {}, true, GetTime() + W.WAIT, name
	W.Show(T("ASKING"):format(name))
	W.watch:Show()
	SendChatMessage(".squidbots why", "SAY")
end

function W.Refused(text)
	W.waiting = false
	W.watch:Hide()
	W.Show(text)
end

-- A system line from the realm: one of ours goes to the window (and stays in the chat as well).
function W.OnSystem(message)
	if type(message) ~= "string" or message:sub(1, #W.PREFIX) ~= W.PREFIX then return end
	if not W.waiting and #W.lines == 0 then return end
	if W.waiting then W.waiting = false W.watch:Hide() end
	table.insert(W.lines, message)
	W.Show(table.concat(W.lines, "\n"))
end

-- An older realm: the command is unknown to it and said aloud; the echo is the refusal.
function W.OnSay(message, sender)
	if W.waiting and sender == UnitName("player") and type(message) == "string" and message:find("^%.squidbots why") then
		W.Refused(T("REFUSED_SAID"))
	end
end

W.watch = CreateFrame("Frame")
W.watch:Hide()
W.watch:SetScript("OnUpdate", function()
	if W.waiting and GetTime() >= W.deadline then W.Refused(T("REFUSED")) end
end)

-- The button: a small question mark on the target's portrait, for a player target other than yourself.
function W.Update()
	local b = W.button
	if not b then return end
	if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then b:Show() else b:Hide() end
end

function W.Build()
	if W.button or not TargetFrame then return end
	local b = CreateFrame("Button", "SquidBotsLiteWhyButton", TargetFrame)
	b:SetWidth(20)
	b:SetHeight(20)
	b:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", -30, -6)
	b:SetFrameLevel(TargetFrame:GetFrameLevel() + 5)
	b:SetNormalTexture("Interface\\GossipFrame\\ActiveQuestIcon")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:SetScript("OnClick", W.Ask)
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(T("BUTTON_TIP"))
		GameTooltip:AddLine(T("BUTTON_TIP2"), 0.8, 0.8, 0.8, true)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	W.button = b
	W.Update()
end

local events = CreateFrame("Frame")
for _, e in ipairs({ "PLAYER_LOGIN", "PLAYER_TARGET_CHANGED", "CHAT_MSG_SYSTEM", "CHAT_MSG_SAY" }) do events:RegisterEvent(e) end
events:SetScript("OnEvent", function(_, event, message, sender)
	if event == "PLAYER_LOGIN" then W.Build()
	elseif event == "PLAYER_TARGET_CHANGED" then W.Update()
	elseif event == "CHAT_MSG_SYSTEM" then W.OnSystem(message)
	else W.OnSay(message, sender) end
end)
