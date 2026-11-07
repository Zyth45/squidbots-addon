-- SquidBots Lite, the Main Tank bar (CoA Bots 2.9.4). In a raid the player tanks the boss and leads one or two
-- off-tank bots: take my target (the server marks it), taunt, swap, hold a place, clear, and a tank / damage
-- switch per bot. Opened from the Dungeon clear panel (Main Tank) or a key binding.
-- Contract with the module (ETUDE-MAIN-TANK-2.9.4, frozen with the Builder): addon messages "SQBA" whispered to
-- the bot, any bot of the group whose master is the player; tab-separated replies, the target name last:
--   addon -> bot: tank main on|off (the player's flag: any bot, one answers), tank target (the player's target),
--                 tank taunt, tank swap, tank hold (where the player stands), tank clear, tank spec tank|dps
--                 (out of combat), tank status all (one bot answers for every bot of the group that can tank)
--   bot -> addon: TK <action> <ok|no_target|out_of_range|cooldown|dead|not_tank|not_in_group|busy> <icon> <target|->
--                 TS <bot> <tank|dps|heal> <can tank 0|1> <icon> <target|->
-- Icons are the client's: 1 star ... 8 skull, 0 none. A marked target that dies: "TK target dead", the bot
-- assists the player again. A realm without the module never answers: the bar greys out and says so.

local PREFIX, ROWS, ICON, ROW_H, WIDTH = "SQBA", 2, 18, 24, 312
local STATUS_WAIT, TAUNT_CD, REFRESH_EVERY, FLASH, STATUS_TRIES, FORGET_AFTER = 6, 8, 20, 1.2, 3, 60

local STRINGS = {
	en = {
		LEAVE = "Leave Tank", TIP_LEAVE = "Main tank off: the bar closes and the Dungeon clear panel comes back.",
		INFO_NEXT = "Next boss:", INFO_BOSSES = "Bosses", INFO_NONE = "none",
		TITLE = "Main Tank", YOU = "You (MT)", FREE = "free", AS_DPS = "damage", AS_HEAL = "healer",
		MAIN = "Main tank", TIP_MAIN = "You tank the boss; your off-tanks take what you mark for them. Lit: on.",
		REFRESH = "Refresh", TIP_REFRESH = "Asks the bots which of them can tank, and what each one holds.",
		CLEAR_ALL = "Clear all", TIP_CLEAR_ALL = "Every off-tank forgets its target and its icon, and assists you again.",
		TARGET = "Off-tank on my target", TIP_TARGET = "%s takes your target; the server marks it with an icon.",
		TAUNT = "Taunt", TIP_TAUNT = "%s taunts its marked target now.",
		SWAP = "Swap", TIP_SWAP = "Tank swap: %s taunts your target off you, or gives its own back.",
		HOLD = "Placement", TIP_HOLD = "%s comes where you stand and tanks there, away from the raid's cleaves.",
		CLEAR = "Clear", TIP_CLEAR = "%s forgets its target and its icon, and assists you again.",
		SPEC = "Tank / damage", TIP_SPEC = "Switches %s between its tank and damage specs, out of combat. Now: %s.",
		ROLE_tank = "tank", ROLE_dps = "damage", ROLE_heal = "healer",
		ASKING = "Asking the bots...", NO_BOT = "No bot of your group can tank.",
		NO_ANSWER = "No answer from the bots yet: asked again in a moment.",
		NO_SERVER = "The realm does not answer the Main Tank bar (it needs CoA Bots 2.9.4).",
		NO_GROUP = "Join a group with bots first.",
		NO_KNOWN_BOT = "No bot of the group known yet: give the group an order (follow), or wait for one to answer.",
		MT_OFF_FOR_DC = "Main tank off: Dungeon Clear leads.",
		NEED_TARGET = "Target the monster first.", IN_COMBAT = "Out of combat only.", NO_OFFTANK = "No off-tank %d in the bar.",
		LAST = "Last order: %s", FAIL = "%s, %s: %s.",
		R_no_target = "no target", R_out_of_range = "out of range", R_cooldown = "on cooldown", R_dead = "target dead",
		R_not_tank = "cannot tank", R_not_in_group = "not in your group", R_busy = "busy (in a fight, dead, controlled or in a vehicle)",
		B_HEADER = "SquidBots Lite: Main Tank", B_MAIN = "Main tank on / off", B_BAR = "Main Tank bar (Main tank on / off)",
		B_TARGET = "Off-tank %d: on my target", B_TAUNT = "Off-tank %d: taunt", B_SWAP = "Off-tank %d: swap",
		B_HOLD = "Off-tank %d: placement",
	},
	fr = {
		LEAVE = "Quitter tank", TIP_LEAVE = "Main tank inactif : la barre se ferme et le panneau Dungeon clear revient.",
		INFO_NEXT = "Prochain boss :", INFO_BOSSES = "Boss", INFO_NONE = "aucun",
		TITLE = "Main Tank", YOU = "Vous (MT)", FREE = "libre", AS_DPS = "DPS", AS_HEAL = "soigneur",
		MAIN = "Main tank", TIP_MAIN = "Vous tankez le boss ; vos off-tanks prennent ce que vous leur marquez. Allumé : actif.",
		REFRESH = "Actualiser", TIP_REFRESH = "Demande aux bots lesquels peuvent tanker, et ce que chacun tient.",
		CLEAR_ALL = "Tout effacer", TIP_CLEAR_ALL = "Chaque off-tank oublie sa cible et son icône, et vous assiste de nouveau.",
		TARGET = "Off-tank sur ma cible", TIP_TARGET = "%s prend votre cible ; le serveur la marque d'une icône.",
		TAUNT = "Taunt", TIP_TAUNT = "%s provoque tout de suite sa cible marquée.",
		SWAP = "Swap", TIP_SWAP = "Échange de tank : %s vous prend votre cible, ou vous rend la sienne.",
		HOLD = "Placement", TIP_HOLD = "%s vient là où vous êtes et y tanke, à l'écart des cleaves du raid.",
		CLEAR = "Effacer", TIP_CLEAR = "%s oublie sa cible et son icône, et vous assiste de nouveau.",
		SPEC = "Tank / DPS", TIP_SPEC = "Fait passer %s de sa spé tank à sa spé DPS, ou l'inverse, hors combat. Maintenant : %s.",
		ROLE_tank = "tank", ROLE_dps = "DPS", ROLE_heal = "soigneur",
		ASKING = "Je demande aux bots...", NO_BOT = "Aucun bot du groupe ne peut tanker.",
		NO_ANSWER = "Pas encore de réponse des bots : nouvelle demande dans un instant.",
		NO_SERVER = "Le royaume ne répond pas à la barre Main Tank (il faut CoA Bots 2.9.4).",
		NO_GROUP = "Rejoignez d'abord un groupe avec des bots.",
		NO_KNOWN_BOT = "Aucun bot du groupe connu pour l'instant : donnez un ordre au groupe (suivre), ou attendez qu'un bot réponde.",
		MT_OFF_FOR_DC = "Main tank éteint : Dungeon Clear mène.",
		NEED_TARGET = "Ciblez d'abord le monstre.", IN_COMBAT = "Hors combat seulement.", NO_OFFTANK = "Pas d'off-tank %d dans la barre.",
		LAST = "Dernier ordre : %s", FAIL = "%s, %s : %s.",
		R_no_target = "pas de cible", R_out_of_range = "hors de portée", R_cooldown = "en recharge", R_dead = "cible morte",
		R_not_tank = "ne peut pas tanker", R_not_in_group = "pas dans votre groupe", R_busy = "occupé (en combat, mort, contrôlé ou en véhicule)",
		B_HEADER = "SquidBots Lite : Main Tank", B_MAIN = "Main tank actif / inactif", B_BAR = "Barre Main Tank (Main tank actif / inactif)",
		B_TARGET = "Off-tank %d : sur ma cible", B_TAUNT = "Off-tank %d : taunt", B_SWAP = "Off-tank %d : swap",
		B_HOLD = "Off-tank %d : placement",
	},
}

local function T(key)
	local lang = SquidBotsLiteDB and SquidBotsLiteDB.lang
	return (STRINGS[lang] or STRINGS.en)[key] or STRINGS.en[key] or key
end

local function Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSquidBots Lite|r: " .. text)
end

local ICONS = {
	main = "Interface\\Icons\\Ability_Warrior_DefensiveStance", refresh = "Interface\\Icons\\INV_Misc_PocketWatch_01",
	clear = "Interface\\Buttons\\UI-GroupLoot-Pass-Up", target = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
	taunt = "Interface\\Icons\\Spell_Nature_Reincarnation", swap = "Interface\\Icons\\Ability_Hunter_Misdirection",
	hold = "Interface\\Icons\\Ability_Hunter_Pathfinding", tank = "Interface\\Icons\\Ability_Defend",
	dps = "Interface\\Icons\\Ability_MeleeDamage",
}

-- One table for the state: info[bot] = { role, can, icon, target, hold, at, error }; rows[i].bot = its off-tank.
local mt = { info = {}, rows = {}, main = false, supported = nil, askedAt = 0, waitUntil = nil, askAt = nil, nextRefresh = 0 }
local UI

local function RaidIcon(index, size)
	index = tonumber(index) or 0
	if index < 1 or index > 8 then return "" end
	return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. index .. ":" .. (size or 14) .. "|t "
end

local function GroupUnits()
	local units = {}
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do table.insert(units, "raid" .. i) end
	else
		for i = 1, GetNumPartyMembers() do table.insert(units, "party" .. i) end
	end
	return units
end

local function UnitOf(name)
	for _, unit in ipairs(GroupUnits()) do
		if UnitName(unit) == name then return unit end
	end
end

-- In the player's zone (the raid panel says where each member is; a party member: taken as here). A bot left in
-- a city cannot off-tank in Molten Core, and it may answer "tank status" with the bots of its own map only.
local function SameZone(unit)
	local index = unit and unit:match("^raid(%d+)$")
	if not index then return true end
	local zone = select(7, GetRaidRosterInfo(tonumber(index)))
	return not zone or zone == "" or zone == GetRealZoneText()
end

-- The bot's name in its class colour, from the group.
local function ClassName(name)
	local unit = UnitOf(name)
	local token = unit and select(2, UnitClass(unit))
	local color = token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
	if not color then return name end
	return string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, name)
end

function mt.Send(name, text)
	SendAddonMessage(PREFIX, text, "WHISPER", name)
end

-- A player without an alt logged in never says HELLO (Alts.lua says it to an alt): said here to a known bot
-- of the group, so the module answers TK / TS as addon messages and not as whispers. At most every 30 s.
function mt.Hello()
	local alts = SquidBotsLite_OnlineAlts and SquidBotsLite_OnlineAlts() or {}
	if #alts > 0 or (mt.helloAt and GetTime() - mt.helloAt < 30) then return end
	local me = UnitName("player")
	for _, unit in ipairs(GroupUnits()) do
		local name = UnitName(unit)
		if name and name ~= me and UnitIsConnected(unit) and (mt.info[name] or (SquidBotsLite_IsBot and SquidBotsLite_IsBot(name))) then
			mt.helloAt = GetTime()
			mt.Send(name, "HELLO	1")
			return
		end
	end
end

-- "tank status all" goes to one bot, and only to a bot: one that answered the bar before, an alt, a bot known
-- to the addon (it answered, joined as a role, a "Bot" surname). Never to a member who may be a player.
-- "retry": the bot asked before did not answer (dead, far, lagging in a big fight): another one is asked, the
-- living ones first, a bot that answered the bar before first among them.
function mt.AskStatus(retry)
	mt.askAt = nil
	if not retry then mt.tried, mt.tries = {}, 0 end
	mt.tried = mt.tried or {}
	local me, to, best, members = UnitName("player"), nil, -1, 0
	for _, unit in ipairs(GroupUnits()) do
		local name = UnitName(unit)
		if name and name ~= me and name ~= UNKNOWNOBJECT and UnitIsConnected(unit) then
			members = members + 1
			local known = mt.info[name] and true or false
			if not mt.tried[name] and (known or (SquidBotsLite_IsBot and SquidBotsLite_IsBot(name))) then
				local score = (SameZone(unit) and 4 or 0) + (UnitIsDeadOrGhost(unit) and 0 or 2) + (known and 1 or 0)
				if score > best then to, best = name, score end
			end
		end
	end
	mt.askedAt = GetTime()
	mt.nextRefresh = mt.askedAt + REFRESH_EVERY
	if retry and not to then
		-- Every bot asked once: the list stays as it was, asked again at the next refresh.
		mt.noAnswer, mt.waitUntil = true, nil
		mt.Refresh()
		return
	end
	mt.noBot = members > 0 and not to
	if not to then
		mt.info, mt.waitUntil = {}, nil
		mt.Refresh()
		return
	end
	mt.tried[to] = true
	mt.tries = (mt.tries or 0) + 1
	mt.Hello()
	mt.Send(to, "tank status all")
	mt.waitUntil = mt.askedAt + STATUS_WAIT
	mt.Refresh()
end

-- The rows: the bots that are tanks, or damage dealers able to tank (a healer is never offered: one click would
-- leave the raid without its heals), tanks first, then by name; two at most.
-- A tank the raid shows: the raid panel's Main Tank flag (".playerbots coa raid" sets it on its tanks) or the
-- Dungeon Finder role, what the raid frames draw as the tank icon.
local function RaidTank(unit)
	if not unit then return false end
	local index = unit:match("^raid(%d+)$")
	if index then
		local role = select(10, GetRaidRosterInfo(tonumber(index)))
		if role == "MAINTANK" then return true end
	end
	if UnitGroupRolesAssigned then
		local tank = UnitGroupRolesAssigned(unit)
		if tank == true or tank == "TANK" then return true end
	end
	return false
end

-- The off-tanks, at most two: the bots the realm says tank first (it refuses tank orders to the others), then
-- the damage bots that could. Within each, the raid's tanks first: the flag may be old (a tank turned damage
-- since the raid was built), so it only breaks ties. Healers never.
function mt.Candidates()
	local list, rank = {}, {}
	for name, info in pairs(mt.info) do
		local unit = UnitOf(name)
		-- Only a bot that is here: online and in the player's zone (one left in a city cannot off-tank).
		if unit and UnitIsConnected(unit) and SameZone(unit) and (info.role == "tank" or (info.role == "dps" and info.can)) then
			table.insert(list, name)
			-- A bot switched from the bar stays on it: a tank turned damage does not give its row to another.
			rank[name] = (SameZone(unit) and 8 or 0) + (info.keep and 4 or 0) + (info.role == "tank" and 2 or 0)
				+ (RaidTank(unit) and 1 or 0)
		end
	end
	table.sort(list, function(a, b)
		if rank[a] ~= rank[b] then return rank[a] > rank[b] end
		return a < b
	end)
	while #list > ROWS do table.remove(list) end
	return list
end

function mt.Fail(name, action, result)
	local key = name .. "|" .. action .. "|" .. result
	if mt.lastFail == key and GetTime() - (mt.lastFailAt or 0) < 1 then return end
	mt.lastFail, mt.lastFailAt = key, GetTime()
	local info = mt.info[name]
	if info then info.error = T("R_" .. result) end
	local text = string.format(T("FAIL"), ClassName(name), T(string.upper(action)), T("R_" .. result))
	if UIErrorsFrame then UIErrorsFrame:AddMessage(text, 1, 0.4, 0.3) end
	for _, row in ipairs(mt.rows) do
		if row.bot == name then row.flashUntil = GetTime() + FLASH end
	end
end

function mt.StartTauntCooldown(name)
	for _, row in ipairs(mt.rows) do
		if row.bot == name and CooldownFrame_SetTimer then CooldownFrame_SetTimer(row.taunt.cd, GetTime(), TAUNT_CD, 1) end
	end
end

-- The replies: TS fills the rows, TK updates the bot's line (or blinks it red with the reason).
function mt.OnAddon(sender, message)
	-- The last answers, for "/sbl mt".
	mt.log = mt.log or {}
	table.insert(mt.log, string.format("%d %s: %s", GetTime(), sender, (message:gsub("	", " | "))))
	if #mt.log > 12 then table.remove(mt.log, 1) end
	local f = {}
	for field in (message .. "\t"):gmatch("([^\t]*)\t") do table.insert(f, field) end
	if f[1] == "TS" and f[2] == "-" then
		-- 2.9.5: "TS	-" ends an answer (a realm that sends it): the answer is whole, so the bots it did not list
		-- leave the off-tanks now, and an answer with no tank in it reads "no bot can tank", not "no answer".
		mt.supported, mt.noAnswer, mt.waitUntil, mt.endLine = true, nil, nil, true
		for name, info in pairs(mt.info) do
			if not (info.at and info.at >= (mt.askedAt or 0)) and not info.keep then mt.info[name] = nil end
		end
		if mt.pending then mt.pendingAt = GetTime() end
		mt.Refresh()
	elseif f[1] == "TS" and f[2] and f[2] ~= "" then
		mt.supported, mt.noAnswer = true, nil
		local info = mt.info[f[2]] or {}
		info.role, info.can, info.at = f[3], f[4] == "1" or info.keep or false, GetTime()
		info.icon, info.target = tonumber(f[5]) or 0, (f[6] and f[6] ~= "-" and f[6] ~= "") and f[6] or nil
		mt.info[f[2]] = info
		-- A key pressed before the bar knew its off-tanks: done once the answers are in.
		if mt.pending then mt.pendingAt = GetTime() + 0.3 end
		mt.Refresh()
	elseif f[1] == "TK" then
		mt.supported = true
		local action, result = f[2] or "", f[3] or ""
		-- "tank swap back" answers with the action "swap back": a swap that gives the target back.
		local back = action == "swap back"
		if back then action = "swap" end
		local icon, target = tonumber(f[4]) or 0, (f[5] and f[5] ~= "-" and f[5] ~= "") and f[5] or nil
		if action == "main" then
			-- "TK main ok 0 on|off": the state of the flag in the last field.
			if result == "ok" then
				if target == "on" or target == "off" then mt.main = target == "on" else mt.main = mt.wantMain and true or false end
				if mt.main and not (mt.frame and mt.frame:IsShown()) then
					-- On while the bar is closed (a reload, a late answer): the bar closed means off.
					mt.SetMain(false, true)
				elseif mt.main and SquidBotsLite_DcStopForTank then
					-- Main tank and a running clear never go together: the server's "on" stops the clear.
					SquidBotsLite_DcStopForTank()
				end
			else
				mt.Fail(sender, action, result)
			end
		else
			-- A bot not known from "tank status" (an answer that comes by itself, like the realm's "clear" when a
			-- pinned target dies) gets no role here: only "tank status" makes it an off-tank of the bar.
			local info = mt.info[sender] or { at = GetTime() }
			mt.info[sender] = info
			-- The realm only takes a target, a taunt, a swap or a placement from a tank: an "ok" to one of them
			-- makes the bot an off-tank even when "tank status" did not list it (an answer lost in a big fight).
			if result == "ok" and not info.role and (action == "target" or action == "taunt" or action == "swap" or action == "hold") then
				info.role, info.can = "tank", true
			end
			if result == "ok" then
				-- An answer from the bot itself: it is here, as fresh as a "tank status" line.
				info.error, info.at = nil, GetTime()
				if action == "spec" then
					info.role = target or info.role
					if info.role ~= "tank" then info.icon, info.target, info.hold = 0, nil, false end
					-- It has a tank spec (it just switched from or to it): it keeps its row, as damage with its Tank
					-- button, whatever the next "tank status" says; that one is asked a moment later.
					info.can, info.keep = true, true
					mt.askAt = GetTime() + 2
				elseif action == "clear" then
					info.icon, info.target, info.hold = 0, nil, false
				elseif action == "hold" then
					info.hold = true
				elseif action == "taunt" then
					-- A taunt does not move the pin: the line keeps its icon and its target.
					mt.StartTauntCooldown(sender)
				elseif action == "swap" and (back or info.swapBack) then
					-- "tank swap back": the target is the player's again.
					info.icon, info.target = 0, nil
				else
					if icon > 0 or target then info.icon, info.target = icon, target end
				end
				if action == "swap" then info.swapBack = nil end
			elseif result == "dead" then
				-- Its marked target died: it assists the player again.
				info.icon, info.target = 0, nil
			else
				if action == "taunt" and result == "cooldown" then mt.StartTauntCooldown(sender) end
				mt.Fail(sender, action, result)
			end
		end
		mt.Refresh()
	end
end

-- An order from a row (or a key binding: the row's index).
function mt.Order(index, action)
	if mt.supported == false then
		Print(T("NO_SERVER"))
		return
	end
	local name = mt.Candidates()[index]
	if not name then
		Print(string.format(T("NO_OFFTANK"), index))
		return
	end
	local info = mt.info[name] or {}
	if action == "spec" then
		if UnitAffectingCombat("player") then
			if UIErrorsFrame then UIErrorsFrame:AddMessage(T("IN_COMBAT"), 1, 0.4, 0.3) end
			return
		end
		mt.Send(name, "tank spec " .. (info.role == "tank" and "dps" or "tank"))
		return
	end
	if info.role and info.role ~= "tank" then
		if UIErrorsFrame then UIErrorsFrame:AddMessage(string.format(T("FAIL"), ClassName(name), T(string.upper(action)), T("R_not_tank")), 1, 0.4, 0.3) end
		return
	end
	if (action == "target" or action == "swap") and not UnitExists("target") then
		if UIErrorsFrame then UIErrorsFrame:AddMessage(T("NEED_TARGET"), 1, 0.4, 0.3) end
		return
	end
	info.last = T(string.upper(action))
	-- Swap on the target the bot already holds: it gives it back to the player.
	if action == "swap" and info.target and UnitName("target") == info.target then
		info.swapBack = true
		mt.Send(name, "tank swap back")
		return
	end
	info.swapBack = nil
	mt.Send(name, "tank " .. action)
end

-- Main tank on or off. "quiet": no line in the chat when it cannot be sent (the bar opening by itself).
-- on true / false: Main tank on / off; on nil: only asks the server's state ("tank main" changes nothing).
function mt.SetMain(on, quiet)
	if mt.supported == false then
		if not quiet then Print(T("NO_SERVER")) end
		return
	end
	local to = mt.Candidates()[1]
	if not to then
		for _, unit in ipairs(GroupUnits()) do
			local name = UnitName(unit)
			if name and name ~= UnitName("player") and SquidBotsLite_IsBot and SquidBotsLite_IsBot(name) then to = name break end
		end
	end
	if not to then
		if not quiet then Print(T("NO_BOT")) end
		return false
	end
	if on == nil then
		mt.Send(to, "tank main")
		return true
	end
	mt.wantMain = on and true or false
	-- A running clear moves the group and overrides the tank orders: stopped first, you lead.
	if on and SquidBotsLite_DcStopForTank then SquidBotsLite_DcStopForTank() end
	mt.Send(to, "tank main " .. (on and "on" or "off"))
	return true
end

-- Dungeon clear starts (SquidBotsLite.lua): the bar closes (Main tank off), and says so.
function SquidBotsLite_MainTankOffForDc()
	local was = (mt.frame and mt.frame:IsShown()) or mt.main
	-- Sent even when the addon believes it off: after a reload the server may still have it on.
	if mt.frame and mt.frame:IsShown() then mt.frame:Hide() else mt.SetMain(false, true) end
	mt.main = false
	if was then Print(T("MT_OFF_FOR_DC")) end
end

function mt.ClearAll()
	for _, name in ipairs(mt.Candidates()) do mt.Send(name, "tank clear") end
end

-- ---------------------------------------------------------------------------
-- The bar
-- ---------------------------------------------------------------------------
local function Lit(button, on)
	if on then
		button.border:SetVertexColor(1, 0.82, 0, 1)
		button:LockHighlight()
	else
		button.border:SetVertexColor(0, 0, 0, 0.9)
		button:UnlockHighlight()
	end
end

function mt.BotButton(row, key, x)
	local button = UI.IconButton(row, ICON, ICONS[key], function()
		local name = row.bot and ClassName(row.bot) or "?"
		local key2 = key == "spec" and "SPEC" or string.upper(key)
		local info = row.bot and mt.info[row.bot]
		if key == "spec" then return T(key2), string.format(T("TIP_SPEC"), name, T("ROLE_" .. (info and info.role or "tank"))) end
		local line = string.format(T("TIP_" .. key2), name)
		if info and info.error then line = line .. "\n|cffff6655" .. string.format(T("LAST"), info.error) .. "|r" end
		return T(key2), line
	end, function() mt.Order(row.index, key) end)
	button:SetPoint("LEFT", x, 0)
	return button
end

function mt.Build()
	UI = UI or SquidBotsLite_UI
	local f = CreateFrame("Frame", "SquidBotsLiteMainTank", UIParent)
	f:SetWidth(WIDTH)
	f:SetBackdrop(UI.CARD)
	f:SetBackdropColor(0.04, 0.04, 0.05, 0.92)
	f:SetBackdropBorderColor(1, 0.82, 0, 0.35)
	f:SetFrameStrata("MEDIUM")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relative, x, y = self:GetPoint()
		SquidBotsLiteDB.mainTankBar = { point, relative, x, y }
	end)
	local saved = SquidBotsLiteDB.mainTankBar
	if saved then f:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4]) else f:SetPoint("TOP", 0, -230) end
	-- Head: Leave Tank and the title on the left; Clear all, Refresh and close on the right. The bar is Main tank:
	-- open, it is on; closed (Leave Tank, its X, its key, a clear that starts), off.
	f.leave = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	f.leave:SetWidth(96)
	f.leave:SetHeight(18)
	f.leave:SetPoint("TOPLEFT", 8, -5)
	f.leave:SetScript("OnClick", function() SquidBotsLite_LeaveMainTank() end)
	f.leave:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(T("LEAVE"), 1, 0.82, 0)
		GameTooltip:AddLine(T("TIP_LEAVE"), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	f.leave:SetScript("OnLeave", function() GameTooltip:Hide() end)
	if UI.Flatten then UI.Flatten(f.leave) end
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("LEFT", f.leave, "RIGHT", 8, 0)
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetWidth(22)
	close:SetHeight(22)
	close:SetPoint("TOPRIGHT", 0, 0)
	f.refresh = UI.IconButton(f, ICON, ICONS.refresh, function() return T("REFRESH"), T("TIP_REFRESH") end, function() mt.AskStatus() end)
	f.refresh:SetPoint("TOPRIGHT", -26, -5)
	f.clearAll = UI.IconButton(f, ICON, ICONS.clear, function() return T("CLEAR_ALL"), T("TIP_CLEAR_ALL") end, function() mt.ClearAll() end)
	f.clearAll:SetPoint("RIGHT", f.refresh, "LEFT", -4, 0)
	UI.Rule(f, -28)
	-- What a main tank needs of the clear: the next boss, the bosses killed (the Dungeon clear panel's data).
	f.info = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.info:SetPoint("TOPLEFT", 12, -33)
	f.info:SetWidth(WIDTH - 24)
	f.info:SetJustifyH("LEFT")
	-- The player's line: "You (MT)" and what they target.
	f.me = CreateFrame("Frame", nil, f)
	f.me:SetWidth(WIDTH - 16)
	f.me:SetHeight(ROW_H)
	f.me:SetPoint("TOPLEFT", 8, -32)
	f.me.name = f.me:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.me.name:SetPoint("LEFT", 4, 0)
	f.me.status = f.me:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.me.status:SetPoint("LEFT", 82, 0)
	f.me.status:SetWidth(WIDTH - 106)
	f.me.status:SetJustifyH("LEFT")
	-- A line per off-tank: its name, six buttons, what it holds.
	for i = 1, ROWS do
		local row = CreateFrame("Frame", nil, f)
		row.index = i
		row:SetWidth(WIDTH - 16)
		row:SetHeight(ROW_H)
		row:SetPoint("TOPLEFT", 8, -32 - i * ROW_H)
		row.bg = row:CreateTexture(nil, "BACKGROUND")
		row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.bg:SetAllPoints()
		row.bg:SetVertexColor(1, 1, 1, 0.03)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.name:SetPoint("LEFT", 4, 0)
		row.name:SetWidth(74)
		row.name:SetJustifyH("LEFT")
		local x = 80
		for _, key in ipairs({ "target", "taunt", "swap", "hold", "clear", "spec" }) do
			row[key] = mt.BotButton(row, key, x)
			x = x + ICON + 3 + (key == "clear" and 4 or 0)
		end
		row.taunt.cd = CreateFrame("Cooldown", nil, row.taunt)
		row.taunt.cd:SetAllPoints()
		row.status = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.status:SetPoint("LEFT", x + 2, 0)
		row.status:SetWidth(WIDTH - 16 - x - 6)
		row.status:SetJustifyH("LEFT")
		mt.rows[i] = row
	end
	f.note = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.note:SetWidth(WIDTH - 24)
	f.note:SetJustifyH("LEFT")
	-- Not in UISpecialFrames: Escape, and fear, stun or charm (UIParent closes those windows) would close it, and
	-- closing the bar turns Main tank off. Its X and its key close it.
	f:Hide()
	f:SetScript("OnHide", function()
		mt.pending, mt.pendingAt = nil, nil
		if mt.supported ~= false then mt.ClearAll() end
		mt.SetMain(false, true)
		if SquidBotsLite_RefreshBar then SquidBotsLite_RefreshBar() end
	end)
	f:SetScript("OnShow", function() if SquidBotsLite_RefreshBar then SquidBotsLite_RefreshBar() end end)
	mt.frame = f
end

function mt.Refresh()
	local f = mt.frame
	if not f or not f:IsShown() then return end
	f.title:SetText(T("TITLE"))
	f.leave:SetText(T("LEAVE"))
	local unsupported = mt.supported == false
	-- The player's line.
	f.me.name:SetText(T("YOU"))
	local target = UnitExists("target") and UnitName("target")
	f.me.status:SetText(target and (RaidIcon(GetRaidTargetIndex("target")) .. target) or "")
	-- The off-tanks.
	local bots = mt.Candidates()
	local inCombat = UnitAffectingCombat("player")
	for i, row in ipairs(mt.rows) do
		local name = bots[i]
		row.bot = name
		if name then
			local info = mt.info[name]
			local tank = info.role == "tank"
			row.name:SetText(ClassName(name))
			for _, key in ipairs({ "target", "taunt", "swap", "hold", "clear" }) do
				UI.SetIcon(row[key], ICONS[key], tank and not unsupported)
			end
			UI.SetIcon(row.spec, tank and ICONS.tank or ICONS.dps, not inCombat and not unsupported)
			Lit(row.hold, tank and info.hold)
			Lit(row.target, tank and info.target ~= nil)
			if not tank then
				row.status:SetText("|cff999999" .. T("AS_DPS") .. "|r")
			elseif info.target then
				row.status:SetText(RaidIcon(info.icon) .. info.target)
			else
				row.status:SetText("|cff999999" .. T("FREE") .. "|r")
			end
			row:Show()
		else
			row:Hide()
		end
	end
	-- Under the rows: why the bar is empty or grey.
	local note
	if unsupported then
		note = T("NO_SERVER")
	elseif #GroupUnits() == 0 then
		note = T("NO_GROUP")
	elseif mt.waitUntil and #bots == 0 then
		note = T("ASKING")
	elseif mt.noBot then
		note = T("NO_KNOWN_BOT")
	elseif #bots == 0 and mt.noAnswer then
		note = T("NO_ANSWER")
	elseif #bots == 0 then
		note = T("NO_BOT")
	end
	UI.SetIcon(f.clearAll, ICONS.clear, not unsupported)
	-- The clear's line, when there is one: the rows go down by its height.
	local top = 32
	local nextBoss, dead, total = nil, 0, 0
	if SquidBotsLite_DcInfo then nextBoss, dead, total = SquidBotsLite_DcInfo() end
	if nextBoss or (total and total > 0) then
		local text = "|cffffd100" .. T("INFO_NEXT") .. "|r " .. (nextBoss or T("INFO_NONE"))
		if total > 0 then text = text .. "  |cffaaaaaa·|r  |cffffd100" .. T("INFO_BOSSES") .. "|r " .. dead .. "/" .. total end
		f.info:SetText(text)
		f.info:Show()
		top = 48
	else
		f.info:SetText("")
		f.info:Hide()
	end
	f.me:SetPoint("TOPLEFT", 8, -top)
	for i, row in ipairs(mt.rows) do row:SetPoint("TOPLEFT", 8, -top - i * ROW_H) end
	local height = top + (1 + #bots) * ROW_H + 8
	if note then
		f.note:ClearAllPoints()
		f.note:SetPoint("TOPLEFT", 12, -top - (1 + #bots) * ROW_H - 2)
		f.note:SetText(note)
		height = height + f.note:GetStringHeight() + 4
	else
		f.note:SetText("")
	end
	f:SetHeight(height)
end

function SquidBotsLite_ToggleMainTank()
	if not SquidBotsLiteDB then return end
	if not mt.frame then mt.Build() end
	if mt.frame:IsShown() then
		mt.frame:Hide()
		return
	end
	mt.frame:Show()
	-- Asked again each time it opens: an earlier "no answer" may have been a realm restarted since.
	if mt.supported == false then mt.supported = nil end
	mt.AskStatus()
	if SquidBotsLite_DcAsk then SquidBotsLite_DcAsk() end
	-- Opening the bar turns Main tank on (and stops a running clear); closing it turns it off. Off-tanks not
	-- known yet: sent once the answers are in.
	if mt.waitUntil then
		mt.pending = { action = "mainon", index = 1 }
	else
		mt.RunKey("mainon", 1)
	end
end

-- A pinned target died: its line is free at once (the realm's "TK target dead" or the next status may come later,
-- or not at all when another bot killed it). The same name; and when the dead one still carries a raid icon, the
-- line's icon, so that one of two Lava Annihilators dying does not free the other's line (a mark may already be
-- gone at death: no icon on the dead one, the name decides).
function mt.PinnedDied(name, flags)
	if not name then return end
	local marks = flags and (flags % 0x10000000 - flags % 0x00100000) or 0
	local changed = false
	for _, info in pairs(mt.info) do
		if info.target == name then
			local icon = info.icon or 0
			local bit = icon > 0 and 0x00100000 * 2 ^ (icon - 1) or 0
			if icon == 0 or marks == 0 or (flags % (bit * 2) >= bit) then
				info.icon, info.target = 0, nil
				changed = true
			end
		end
	end
	if changed then mt.Refresh() end
end

-- "/sbl mt": what the bar knows of each bot, to understand a row that is missing.
function SquidBotsLite_MainTankDebug()
	local now = GetTime()
	Print(string.format("Main Tank: zone %s, asked %ds ago, waiting %s, no answer %s, rows: %s", GetRealZoneText() or "?",
		now - (mt.askedAt or 0), tostring(mt.waitUntil ~= nil), tostring(mt.noAnswer), table.concat(mt.Candidates(), ", ")))
	for name, info in pairs(mt.info) do
		local unit = UnitOf(name)
		Print(string.format("  [%s] role %s, can %s, keep %s, seen %ds ago, unit %s, online %s, same zone %s, target %s",
			name, tostring(info.role), tostring(info.can), tostring(info.keep), now - (info.at or 0), tostring(unit),
			tostring(unit and UnitIsConnected(unit) and true or false), tostring(unit and SameZone(unit)), tostring(info.target)))
	end
	for _, line in ipairs(mt.log or {}) do Print("  " .. line) end
end

-- The clear's data changed (SquidBotsLite.lua): its line on the bar follows.
function SquidBotsLite_MainTankRefresh()
	mt.Refresh()
end

-- The Dungeon clear panel's Main Tank button: the bar opens (Main tank on), never closes.
function SquidBotsLite_OpenMainTank()
	if not (mt.frame and mt.frame:IsShown()) then SquidBotsLite_ToggleMainTank() end
end

function SquidBotsLite_MainTankShown()
	return mt.frame and mt.frame:IsShown() and true or false
end

-- Leave Tank (the bar's button, or the Main Tank button clicked again): Main tank off, the bar closes, the
-- Dungeon clear panel comes back.
function SquidBotsLite_LeaveMainTank()
	if mt.frame then mt.frame:Hide() end
	if SquidBotsLite_ShowDcPanel then SquidBotsLite_ShowDcPanel() end
end

-- Key bindings (Bindings.xml): SquidBotsLite_MainTank("target", 1) and so on.
-- They work with the bar closed or never opened: off-tanks not known yet (or not for a while) are asked first,
-- and the key's order follows the answers.
function SquidBotsLite_MainTank(action, index)
	if not SquidBotsLiteDB then return end
	if not mt.frame then mt.Build() end
	if mt.supported == false then mt.supported = nil end
	if not next(mt.info) or GetTime() - mt.askedAt > REFRESH_EVERY then
		mt.pending = { action = action, index = index or 1 }
		mt.AskStatus()
		if mt.waitUntil then return end
		mt.pending = nil
	end
	mt.RunKey(action, index or 1)
end

function mt.RunKey(action, index)
	if action == "mainon" then mt.SetMain(true, true)
	else mt.Order(index, action) end
end

local function BindingNames()
	BINDING_HEADER_SQUIDBOTSLITE_MT = T("B_HEADER")
	BINDING_NAME_SQUIDBOTSLITE_MT_BAR = T("B_BAR")
	for i = 1, ROWS do
		for _, key in ipairs({ "TARGET", "TAUNT", "SWAP", "HOLD" }) do
			_G["BINDING_NAME_SQUIDBOTSLITE_MT_" .. key .. i] = string.format(T("B_" .. key), i)
		end
	end
end
BindingNames()

local frame = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "CHAT_MSG_ADDON", "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE",
	"PLAYER_TARGET_CHANGED", "RAID_TARGET_UPDATE", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
	"COMBAT_LOG_EVENT_UNFILTERED" }) do
	frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4, ...)
	if event == "PLAYER_LOGIN" then
		BindingNames()
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- After a login or a reload the bar is closed, so Main tank is off: the server's flag may still be on. Its
		-- state is asked ("tank main"), and an "on" is turned off (OnAddon).
		mt.syncAt = GetTime() + 3
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == PREFIX and arg3 == "WHISPER" and arg4 and arg2 and (arg2:find("^TK\t") or arg2:find("^TS\t")) then
			mt.OnAddon(arg4, arg2)
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		-- 3.3.5: timestamp, event, source GUID, name, flags, dest GUID, name, flags.
		if arg2 == "UNIT_DIED" then mt.PinnedDied(select(7, arg1, arg2, arg3, arg4, ...), select(8, arg1, arg2, arg3, arg4, ...)) end
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		-- Who can tank may have changed: asked again a moment later, once the roster settles.
		if mt.frame and mt.frame:IsShown() then mt.askAt = GetTime() + 2 end
		if mt.syncPending then mt.syncAt = GetTime() + 2 end
		mt.Hello()
	else
		mt.Refresh()
	end
end)

local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
	elapsed = elapsed + delta
	if elapsed < 0.1 then return end
	elapsed = 0
	if mt.syncAt and GetTime() >= mt.syncAt then
		mt.syncAt = nil
		if mt.frame and mt.frame:IsShown() then
			mt.syncPending = nil
		else
			-- No bot known yet: tried again when the group changes.
			mt.syncPending = not mt.SetMain(nil, true) or nil
		end
	end
	if not mt.frame then return end
	local now = GetTime()
	local shown = mt.frame:IsShown()
	if mt.askAt and now >= mt.askAt then mt.AskStatus() end
	-- No TS since the question: a realm without the module (or without a bot that can answer).
	if mt.waitUntil and now >= mt.waitUntil then
		mt.waitUntil = nil
		local answered = false
		for _, info in pairs(mt.info) do
			if info.at and info.at >= mt.askedAt then answered = true end
		end
		if answered then
			-- Answers from different bots may each list part of the raid (a bot on another map lists its own
			-- map): a bot leaves the list only when no answer has listed it for a minute, never on one answer.
			for name, info in pairs(mt.info) do
				if not (info.at and info.at >= mt.askedAt - FORGET_AFTER) and not info.keep then mt.info[name] = nil end
			end
		else
			-- No answer: the list stays, another bot is asked (a fresh raid: the first one may be mid-teleport).
			mt.noAnswer = true
			if (mt.tries or 0) < STATUS_TRIES then mt.AskStatus(true) end
			if not mt.waitUntil and mt.supported ~= true then
				-- Every try silent, on a realm that never answered: said once a session, and not final (the
				-- refresh keeps asking; any TK or TS turns the bar on again).
				mt.supported = false
				if not mt.toldNoServer then
					mt.toldNoServer = true
					Print(T("NO_SERVER"))
				end
			end
		end
		-- A key pressed meanwhile: run once the answers are in (or no other bot is left to ask).
		if mt.pending and not mt.waitUntil then mt.pendingAt = now end
		mt.Refresh()
	end
	if mt.pending and mt.pendingAt and now >= mt.pendingAt then
		local key = mt.pending
		mt.pending, mt.pendingAt = nil, nil
		mt.RunKey(key.action, key.index)
	end
	if not shown then return end
	if not mt.waitUntil and not mt.askAt and now >= mt.nextRefresh and mt.supported ~= nil then mt.AskStatus() end
	-- A failed order blinks its line red for a moment.
	for _, row in ipairs(mt.rows) do
		if row.flashUntil then
			local left = row.flashUntil - now
			if left <= 0 then
				row.flashUntil = nil
				row.bg:SetVertexColor(1, 1, 1, 0.03)
			else
				local pulse = 0.25 + 0.2 * math.sin(now * 12)
				row.bg:SetVertexColor(1, 0.2, 0.15, pulse * left / FLASH)
			end
		end
	end
end)
