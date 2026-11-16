-- SquidBots Manager: a button on the minimap (GitHub #4), for players who do not use chat commands.
-- Left click: the bar and the addon's windows shown or hidden (as /sbl). Right click: a menu (the windows, the key
-- spells bar, the language, hide this button). Drag: around the minimap. /sbl minimap shows or hides the button.
-- Plain frames and the game's own art, no library. Kept account-wide in SquidBotsLiteDB.minimap { angle, hide }.

local M = {}
SquidBotsLite_Minimap = M

local STRINGS = {
	en = {
		TITLE = "SquidBots Manager",
		TIP_LEFT = "Left-click: show or hide the bar and the addon's windows.",
		TIP_RIGHT = "Right-click: menu.",
		TIP_DRAG = "Drag: move this button around the minimap.",
		BAR = "Show the bar", ALTS = "My alts", WORLD = "World", QUESTS = "Group quests", DASH = "Dashboard",
		MISSIONS = "Missions", KEYS = "Key spells bar", LANG = "Language: English / Français",
		HIDE = "Hide this button", HIDDEN = "minimap button hidden: /sbl minimap brings it back.",
		SHOWN = "minimap button shown.", CLOSE = "Close",
	},
	fr = {
		TITLE = "SquidBots Manager",
		TIP_LEFT = "Clic gauche : afficher ou cacher la barre et les fenêtres de l'addon.",
		TIP_RIGHT = "Clic droit : menu.",
		TIP_DRAG = "Glisser : déplacer ce bouton autour de la minicarte.",
		BAR = "Afficher la barre", ALTS = "Mes alts", WORLD = "Monde", QUESTS = "Quêtes de groupe", DASH = "Tableau de bord",
		MISSIONS = "Missions", KEYS = "Barre des sorts clés", LANG = "Langue : English / Français",
		HIDE = "Cacher ce bouton", HIDDEN = "bouton de minicarte caché : /sbl minimap le remet.",
		SHOWN = "bouton de minicarte affiché.", CLOSE = "Fermer",
	},
}

local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Manager|r: " .. text)
end

-- The addon's windows (not the bars that keep their own state: key spells, Main Tank, team).
M.WINDOWS = { "SquidBotsLiteAlts", "SquidBotsLiteSpecs", "SquidBotsLiteDungeonClear", "SquidBotsLiteWorld",
	"SquidBotsLiteGroupQuests", "SquidBotsLiteDashboard", "SquidBotsLiteMissions", "SquidBotsLiteSheet",
	"SquidBotsLiteBulk", "SquidBotsLiteAltLog", "SquidBotsLiteTeamSettings" }

function M.Settings()
	SquidBotsLiteDB.minimap = SquidBotsLiteDB.minimap or {}
	return SquidBotsLiteDB.minimap
end

local function Slash(command)
	if SlashCmdList and SlashCmdList.SQUIDBOTSLITE then SlashCmdList.SQUIDBOTSLITE(command) end
end

-- Shown: the bar and the windows hidden; hidden: the bar back (the windows open from it, or from the menu).
function M.Toggle()
	local bar = SquidBotsLiteBar
	if bar and bar:IsShown() then
		Slash("hide")
		for _, name in ipairs(M.WINDOWS) do
			local frame = _G[name]
			if frame and frame:IsShown() then frame:Hide() end
		end
	else
		Slash("show")
	end
end

-- Around a round minimap: the angle in degrees, 0 on the right, counter-clockwise.
M.RADIUS = 80
function M.Place()
	local b = M.button
	if not b then return end
	local angle = math.rad(M.Settings().angle or 200)
	b:ClearAllPoints()
	b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * M.RADIUS, math.sin(angle) * M.RADIUS)
end

function M.Drag()
	local mx, my = Minimap:GetCenter()
	local scale = Minimap:GetEffectiveScale()
	local px, py = GetCursorPosition()
	px, py = px / scale, py / scale
	M.Settings().angle = math.floor(math.deg(math.atan2(py - my, px - mx)) + 0.5) % 360
	M.Place()
end

function M.Menu()
	local db = SquidBotsLiteDB
	local bar = SquidBotsLiteBar
	local items = {
		{ text = T("TITLE"), isTitle = true, notCheckable = true },
		{ text = T("BAR"), checked = bar and bar:IsShown() and true or false, func = function() M.Toggle() end },
		{ text = T("KEYS"), checked = db.keyBarShown and true or false,
			func = function() if SquidBotsLite_ToggleKeySpells then SquidBotsLite_ToggleKeySpells() end end },
		{ text = T("ALTS"), notCheckable = true, func = function() Slash("alts") end },
		{ text = T("WORLD"), notCheckable = true, func = function() Slash("world") end },
		{ text = T("QUESTS"), notCheckable = true, func = function() Slash("quests") end },
		{ text = T("DASH"), notCheckable = true, func = function() Slash("dashboard") end },
		{ text = T("MISSIONS"), notCheckable = true, func = function() Slash("missions") end },
		{ text = T("LANG"), notCheckable = true, func = function() Slash("lang " .. ((db.lang == "fr") and "en" or "fr")) end },
		{ text = T("HIDE"), notCheckable = true, func = function() M.SetHidden(true) end },
		{ text = T("CLOSE"), notCheckable = true, func = function() end },
	}
	M.menu = M.menu or CreateFrame("Frame", "SquidBotsLiteMinimapMenu", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(items, M.menu, "cursor", 0, 0, "MENU")
end

function M.SetHidden(hidden)
	M.Settings().hide = hidden and true or nil
	if M.button then if hidden then M.button:Hide() else M.button:Show() end end
	Print(T(hidden and "HIDDEN" or "SHOWN"))
end

function M.Build()
	if M.button or not Minimap then return end
	local b = CreateFrame("Button", "SquidBotsLiteMinimapButton", Minimap)
	M.button = b
	b:SetWidth(31)
	b:SetHeight(31)
	b:SetFrameStrata("MEDIUM")
	b:SetFrameLevel(8)
	b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	local back = b:CreateTexture(nil, "BACKGROUND")
	back:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	back:SetWidth(20)
	back:SetHeight(20)
	back:SetPoint("TOPLEFT", 7, -5)
	local icon = b:CreateTexture(nil, "ARTWORK")
	icon:SetTexture("Interface\\Icons\\Spell_Frost_SummonWaterElemental")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetWidth(17)
	icon:SetHeight(17)
	icon:SetPoint("TOPLEFT", 7, -6)
	b.icon = icon
	local border = b:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetWidth(53)
	border:SetHeight(53)
	border:SetPoint("TOPLEFT")
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	b:RegisterForDrag("LeftButton")
	b:SetScript("OnClick", function(_, mouse)
		if mouse == "RightButton" then M.Menu() else M.Toggle() end
	end)
	b:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", M.Drag)
		GameTooltip:Hide()
	end)
	b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(T("TITLE"))
		GameTooltip:AddLine(T("TIP_LEFT"), 1, 1, 1, true)
		GameTooltip:AddLine(T("TIP_RIGHT"), 1, 1, 1, true)
		GameTooltip:AddLine(T("TIP_DRAG"), 0.6, 0.6, 0.6, true)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	M.Place()
	if M.Settings().hide then b:Hide() end
end

-- /sbl minimap: the button shown or hidden.
function SquidBotsLite_MinimapToggle()
	if not M.button then M.Build() end
	M.SetHidden(not M.Settings().hide)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
	SquidBotsLiteDB = SquidBotsLiteDB or {}
	M.Build()
end)
