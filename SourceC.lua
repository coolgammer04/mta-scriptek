--***********************************************************************************************************************************************************************************
--***********************************************************************************************************************************************************************************
--*********************************************************************************[Panel Készítés]**********************************************************************************
--***********************************************************************************************************************************************************************************
local Kepernyo = {guiGetScreenSize()}
local Meretek = {1080, 600}
local Menusor = {
	{"Info"},{"Frakció"},{"Vagyon"},{"Prémium Panel"},{"Beállítások"},{"Adminok"},
}

local getJobName = {
	[0] = "Nincs Munkád",
	[1] = "Autószállító",
	[2] = "Pizzafutár",
	[3] = "Árufeltöltő",
	[4] = "Buszsofőr",
	[5] = "Csomagszállító",
	[6] = "Favágó",
}

local Adatok = {}
local panelX, panelY = Kepernyo[1]/2-Meretek[1]/2, Kepernyo[2]/2-Meretek[2]/2
local show = false
local alpha = 0
local alphaText = 0
local alphaPercent = 0.7
local KepAlpha = 0 

local klikkTimer = false
local klikkTimerRun
local Menupontfont = dxCreateFont("files/myriadproregular.ttf",12)
local Elsolepes = 0
local JelenOldal = 0
local Tick = getTickCount()
local progress = "Linear"
local PanelY1 = Kepernyo[2]/2-50/2
local panelY2 = Kepernyo[2]/2-50/2

local Szerverszin = "#7cc576"
local optionsTable = {{"Látótávolság", 0},{"Jármű shader", 0},{"Szebb víz shader",0},{"Kontraszt shader",0},{"Kidolgozodttság shader",0},{"Szebb égbolt shader",0},{"Lencsefolt shader",0},{"Motionblur",0},{"Harc stílus",0},{"Séta stílus",0}}
local optionsCreateColor = ""
local optionsCreateText = "" 
local maxDistance = 0

local groupManaging = {}
local groups = {}

local playerGroups = {}
local playerRanksInGroups = {}

local groupMembers = {}
local groupVehicles = {}
local meInGroup = {}

local admins = {}

local walks = {118, 119, 120, 121, 122, 123, 124, 125, 126, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137}
local fights = {4, 5, 6, 7, 15, 16}

function fetchGroups()
	local groupCount = getElementData(localPlayer, "groupCount")
	if tonumber(groupCount) and groupCount >= 1 then
		playerGroups = {}
		for i=0, groupCount-1 do
			local groupID = getElementData(localPlayer, "group_" .. i)
			if groupID then
				for k,v in pairs(groups) do
					if groupID == v["groupID"] then
						table.insert(playerGroups, groupID)
					end
				end
			end
		end
	end

	if #playerGroups >= 1 then
		triggerServerEvent("requestGroupData", localPlayer, playerGroups)
	end

	local groupsKeyed = {}

	for k, v in pairs(playerGroups) do
		groupsKeyed[v] = true
		groupVehicles[v] = {}
	end
	
	for k, v in ipairs(getElementsByType("vehicle")) do
		local group = getElementData(v, "veh:faction")

		if groupVehicles[group] then
			table.insert(groupVehicles[group], v)
		end
	end
end

local leaderText = {"#acd373igen"}
leaderText[0] = "#d9534fnem"

local rankCount = {}

addEvent("sendGroupMembers", true )
addEventHandler("sendGroupMembers", getRootElement(),
	function (members, playerID, groupID)
		local me = getElementData(localPlayer, "char:id")

		for k, v in pairs(members) do
			for k2, v2 in pairs(v) do
				if v2["id"] == me then
					meInGroup[k] = v2
				end
			end
		end

		local onlinePlayers = {}

		for k, v in pairs(getElementsByType("player")) do
			local id = getElementData(v, "char:id")
			onlinePlayers[id] = v
		end

		for k, v in pairs(members) do
			rankCount[k] = {}

			for k2, v2 in pairs(v) do
				local id = v2["id"]

				if onlinePlayers[id] then
					members[k][k2]["online"] = onlinePlayers[id]
				else
					members[k][k2]["online"] = false
				end

				local rank = v2["rank"]
				
				local current = rankCount[k][rank] or 0

				rankCount[k][rank] = current + 1

				if k == groupID and id == playerID then
					selectedMember = k2
				end
			end
		end

		groupMembers = members
	end)

addEvent("sendGroups", true )
addEventHandler("sendGroups", getRootElement(),
	function (datas)
		groups = datas

		if JelenOldal == 2 then
			fetchGroups()
		end
	end)

addEvent("renameGroupRank", true )
addEventHandler("renameGroupRank", getRootElement(),
	function (name, rankName, groupId)
		if not groups[groupId][name] then return end
		
		groups[groupId][name] = rankName or ""

		if JelenOldal == 2 then
			fetchGroups()
		end
	end)
	
function isPlayerInFaction(groupID)
	fetchGroups()
	triggerServerEvent("requestGroups", localPlayer)
	
	if getElementData(localPlayer, "loggedin") then
		if meInGroup[groupID] then
			return true
		else
			return false
		end
	else
		return false
	end
end

function getPlayerRankInFaction(groupID)
	if isPlayerInFaction(groupID) then
		return meInGroup[groupID]["rank"]
	else
		return false
	end
end

function isPlayerLeaderInFaction(groupID)
	if isPlayerInFaction(groupID) then
		if meInGroup[groupID]["isLeader"] == 1 then
			return true
		else
			return false
		end
	else
		return false
	end	
end

function getFactionName(groupID)
	if groups[groupID] then
		return groups[groupID]["name"]
	else
		return ""
	end
end

function getFactionBalance(groupID)
	if groups[groupID] then
		return groups[groupID]["balance"]
	else
		return 0
	end
end

function getPlayerPayment()
	triggerServerEvent("getPlayerPayment", localPlayer, localPlayer)
end
	
local admindutyText = {"#acd737Igen"}
admindutyText[0] = "#cc0000Nem"

local leaderText = {"#acd737Igen"}
leaderText[0] = "#cc0000Nem"

local onlineText = {"#acd373Online"}
onlineText[0] = "#cc0000Offline"
	
function dashboardFelrajzol ()
	if not show then return end
		if alpha < 255*alphaPercent then
			alpha = alpha + ((255*alphaPercent)/100)*(alphaPercent*2)
			alphaText = alphaText + ((255*alphaPercent)/100)*(alphaPercent*2)
		else
			alpha = 255*alphaPercent
			alphaText = 255
		end
		KepAlpha = KepAlpha + 2.5 
		if KepAlpha >= 255 then 
			KepAlpha = 0
		end
		PanelY1 = Kepernyo[2]/2-50/2
		panelY2 = Kepernyo[2]/2-50/2
	if Elsolepes == 1 then 
		Time = (getTickCount() - Tick) / 1300
		Size1 = interpolateBetween(PanelY1,0,0,Kepernyo[2]/2-Meretek[2]/2,0,0,Time,progress)	
		
		Time2 = (getTickCount() - Tick) / 1300
		Size2 = interpolateBetween(panelY2,0,0,Kepernyo[2]/2-Meretek[2]/2+Meretek[2]+5,0,0,Time2,progress)		
		
		Time3 = (getTickCount() - Tick) / 1300
		Size3 = interpolateBetween(0,0,0,Meretek[2],0,0,Time2,progress)
		
		dxDrawRectangle(panelX, Size1, Meretek[1],Size3, tocolor(0, 0, 0, alpha)) ---<[ Az egész Háttere ]>---

		PanelY1 = Size1
		panelY2 = Size2
	end
	
	dxDrawRectangle(panelX, PanelY1-55, Meretek[1], 50, tocolor(0, 0, 0, alpha)) ---<[ Felsőcsík ]>---
	dxDrawRectangle(panelX, panelY2, Meretek[1], 50, tocolor(0, 0, 0, alpha)) ---<[ Alsócsík ]>---
		
	for index, value in ipairs (Menusor) do 
		roundedRectangle(panelX-150+index*155, PanelY1-55+5, 150, 40, tocolor(0, 0, 0, alpha))
		if(isCursorOnBox(panelX-150+index*155, PanelY1-55+5, 150, 40)) then	
			roundedRectangle(panelX-147.5+index*155, PanelY1-55+7.5, 145, 35, tocolor(135, 211, 124, alpha))
		end
		dxDrawText(value[1], panelX-80+index*(155), PanelY1-45, panelX-80+index*(155), panelX-80+index*(155), tocolor(255,255,255,alphaText), 1.0, Menupontfont, "center", "top", false, false, false,true) ---<[ Menüpontok Kiírás ]>---
	end

	dxDrawImage(panelX, panelY2, 200, 50, "files/logo.png", 0, 0, 0, tocolor(255, 255, 255, KepAlpha)) ---<[ LOGO ]>---
	dxDrawImage(panelX+Meretek[1]-106, PanelY1-48, 32, 32, "files/clock.png", 0, 0, 0, tocolor(255, 255, 255, 170)) ---<[ Óra ]>---
		
	local Time = getRealTime()
	local hour = Time.hour
	local minutes = Time.minute
	if minutes < 10 then 
		minutes = "0"..minutes
	end		
	if hour < 10 then 
		hour = "0"..hour
	end
	date = string.format("%04d.%02d.%02d", Time.year + 1900, Time.month + 1, Time.monthday )
	dxDrawText("   "..hour.." : "..minutes.."\n"..date, panelX+Meretek[1]-70, PanelY1-45, 32, 32, tocolor(215,215,215,alphaText), 1.0, "default-bold", "left", "top", false, false, false,true) ---<[ Óra Kiírás ]>---
	
	if Size3 == Meretek[2] then
		if (JelenOldal == 1 ) then -- INFO 
			for index, value in ipairs  (Adatok) do 
				dxDrawRectangle(panelX+145, PanelY1+10+index*27, 285, 27, tocolor(0, 0, 0, alpha)) ---<[ Háttér ]>---
				dxDrawText(value[1], panelX+150, PanelY1+15+index*27, 32, 32, tocolor(215,215,215,alphaText), 1.0, "default-bold", "left", "top", false, false, false,true) ---<[ Karakter Info Kiírás ]>---
			end
			dxDrawImage(panelX+10, PanelY1+30, 128, 256, "files/Skinek/"..getElementModel(localPlayer)..".jpg", 0, 0, 0, tocolor(255, 255, 255, 255)) ---<[ Skin kép ]>---
			dxDrawImage(panelX+4, PanelY1+23, 256, 512, "files/Skinek/frame.png", 0, 0, 0, tocolor(0, 0, 0, 255)) ---<[ Skin kép ]>---
			dxDrawRectangle(panelX+Meretek[1]/2-100, PanelY1+5, 5, Size3-10, tocolor(0, 0, 0, alpha)) ---<[ Elválasztó ]>---
			dxDrawRectangle(panelX+10, PanelY1+160+256, 400, 150, tocolor(0, 0, 0, alpha)) ---<[ Desc Háttere ]>---
			dxDrawText("Karakter Leírás", panelX+10, PanelY1+165+256, panelX+10 + 400 , panelX+10, tocolor(135, 211, 124,alphaText), 1.0, Menupontfont, "center", "top", false, false, false,true) ---<[ Desc Kiírás ]>---		
			dxDrawText(getLocalPlayer():getData("char:leiras"), panelX+10, PanelY1+185+256, panelX+10 + 400 , panelX+10, tocolor(255, 255, 255,alphaText), 1.0, Menupontfont, "center", "top", false, false, false,true) ---<[ Desc Kiírás ]>---
		elseif (JelenOldal == 2 ) then -- Frakció
			if #playerGroups > 0 then
				dxDrawRectangle(panelX+21, PanelY1+21, 198, 32*#playerGroups+4, tocolor(0,0,0,alpha))
				
				--- groups
				for key = 1, #playerGroups do
					dxDrawRectangle(panelX+25, PanelY1+25+(key-1)*32, 190, 28, tocolor(255,255,255,20))
					
					if selectedGroup == key then
						dxDrawRectangle(panelX+25, PanelY1+25+(key-1)*32, 190, 28, tocolor(124,197,118,180))
					end
					
					local groupId = playerGroups[key]
					
					if tonumber(groupId) then
						dxDrawText(groups[groupId]["name"], panelX+25, PanelY1+25+(key-1)*32, panelX+25+190, PanelY1+25+(key-1)*32+30, tocolor(255,255,255), 1, "default-bold", "center", "center")
					end
				end
				
				groupId = playerGroups[selectedGroup]
				
				if tonumber(groupId) and meInGroup[groupId] then
					local rank = meInGroup[groupId]["rank"]
					
					--- ranks
					groupStartX, groupStartY = panelX+230-2, PanelY1+25-2
					
					dxDrawRectangle(groupStartX, groupStartY, 240, 22*15+2, tocolor(0,0,0,alpha))
					for key = 0, 14 do -- 15 rang
						groupStartForY = groupStartY+2+key*22
						
						dxDrawRectangle(groupStartX+2, groupStartForY, 240-4, 20, tocolor(255,255,255,20))
						if key+1 == selectedGroupRank then
							dxDrawRectangle(groupStartX+2, groupStartForY, 240-4, 20, tocolor(124,197,118,180))
						end
						
						dxDrawText((groups[groupId]["rank_"..key+1])..Szerverszin.." (Fizetés: "..(groups[groupId]["rank_"..(key+1).."_pay"]).."$)", groupStartX+8, groupStartForY, groupStartX+240, groupStartForY+20, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
					end
					
					if meInGroup[groupId]["isLeader"] == 1 and groups[groupId]["type"] ~= (5 or 6) then
						groupStartX = panelX+25
						groupStartY = groupStartY+15*22+10
						dxDrawRectangle(groupStartX, groupStartY, 444, 2*22+2, tocolor(0,0,0,alpha))
						for key = 0, 1 do
							groupStartForY = groupStartY+2+key*22
							
							dxDrawRectangle(groupStartX+2, groupStartForY, 444-4, 20, tocolor(255,255,255,20))
						end
						dxDrawText(Szerverszin.."Frakció neve: #ffffff"..groups[groupId]["name"], groupStartX+4, groupStartY+2, groupStartX+440, groupStartY+22, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
						
						local balance = groups[groupId]["balance"].."$"
						if balance == (0).."$" then
							balance = "A frakció számlán nincs pénz"
						end
						dxDrawText(Szerverszin.."Frakció banki egyenlege: #ffffff"..balance, groupStartX+4, groupStartY+2+22, groupStartX+440, groupStartY+44, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
						
						dxDrawRectangleButton(groupStartX+2, groupStartY+48, 440, 20, tocolor(124,197,118,180), "Befizetés a számlára")
						pBalanceX, pBalanceY = groupStartX+2, groupStartY+48
						dxDrawRectangleButton(groupStartX+2, groupStartY+70, 440, 20, tocolor(0,113,210,180), "Kivétel a számláról")
						mBalanceX, mBalanceY = groupStartX+2, groupStartY+70
						
						if balanceGui then
							local text = guiGetText(balanceGui)
							if text == "" or text == " " then text = 0 end
							dxDrawText(guiGetText(balanceGui).."$", pBalanceX+4, pBalanceY+44, pBalanceX+444, pBalanceY+64, tocolor(255,255,255), 1, "default-bold", "left", "center")
							roundedRectangle(pBalanceX, pBalanceY+44, 440, 20, tocolor(0,0,0,alpha), tocolor(255,255,255,20))
						
							dxDrawRectangleButton(pBalanceX, pBalanceY+66, 440, 20, tocolor(124,197,118,180), "Elfogad")
							dxDrawRectangleButton(pBalanceX, pBalanceY+88, 440, 20, tocolor(243,85,85,180), "Mégse")
						end
						
						groupStartX = panelX+230-2
						groupStartY = groupStartY-15*22-10
					end
					
					--- members
					groupStartX = groupStartX+250
					
					dxDrawRectangle(groupStartX, groupStartY, 340, 22*15+2, tocolor(0,0,0,alpha))
					
					for key = 0, 14 do
						groupStartForY = groupStartY+2+key*22					
						dxDrawRectangle(groupStartX+2, groupStartForY, 340-4, 20, tocolor(255,255,255,20))
					end
					
					latestRowG = currentRowG+maxRowG-1
					if meInGroup[groupId] then
						for key, value in ipairs(groupMembers[groupId]) do
							if key >= currentRowG and key <= latestRowG then
								key = key-currentRowG+1
								groupStartForY = groupStartY+2+(key-1)*22
								if key == selectedMember-currentRowG+1 then
									dxDrawRectangle(groupStartX+2, groupStartForY, 340-4, 20, tocolor(124,197,118,180))						
								end
								dxDrawText(value["characterName"]:gsub("_", " ")..Szerverszin.." ("..groups[groupId]["rank_"..value["rank"]]..")", groupStartX+4, groupStartForY, groupStartX+340, groupStartForY+20, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
								dxDrawText(onlineText[onlineByName(value["characterName"]:gsub("_", " "))], groupStartX, groupStartForY, groupStartX+336, groupStartForY+20, tocolor(255,255,255), 1, "default-bold", "right", "center", false, false, false, true)
							end
						end
					end
					
					groupStartY = groupStartY+15*22+10
					groupVehicleX, groupVehicleY = groupStartX, groupStartY
					dxDrawRectangle(groupStartX, groupStartY, 340, 22*10+2, tocolor(0,0,0,alpha))
					for key = 0, 9 do
						groupStartForY = groupStartY+2+key*22
						dxDrawRectangle(groupStartX+2, groupStartForY, 340-4, 20, tocolor(255,255,255,20))
					end
					
					latestRowVehG = currentRowVehG+maxRowVehG-1
					for key, value in ipairs(groupVehicles[groupId]) do
						if key >= currentRowVehG and key <= latestRowVehG then
							key = key-currentRowVehG+1
							groupStartForY = groupStartY+2+(key-1)*22
							dxDrawText(exports["exg_carshop"]:getVehicleRealName(getElementModel(value))..Szerverszin.." (ID: "..value:getData("veh:id")..")", groupStartX+4, groupStartForY, groupStartX+340, groupStartForY+20, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
							dxDrawText("Állapot: #acd373"..math.floor(getElementHealth(value)/10).."%", groupStartX, groupStartForY, groupStartX+340-4, groupStartForY+20, tocolor(255,255,255), 1, "default-bold", "right", "center", false, false, false, true)
						end
					end
					
					groupStartY = groupStartY-15*22-4
					
					if not select then
						selectedMember = selectedMember-maxRowG+latestRowG
						select = true
					end
					
					--- information
					groupStartX = groupStartX+350
					
					dxDrawRectangle(groupStartX, groupStartY, 220, 90, tocolor(0,0,0,alpha))
					for key = 0, 3 do
						groupStartForY = groupStartY+2+key*22
						dxDrawRectangle(groupStartX+2, groupStartForY, 220-4, 20, tocolor(255,255,255,20))
					end
					
					dxDrawText(Szerverszin.."Név: #ffffff"..groupMembers[groupId][selectedMember]["characterName"]:gsub("_", " "), groupStartX+4, groupStartY+2, groupStartX+220, groupStartY+22, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
					dxDrawText(Szerverszin.."Rang: #ffffff"..groups[groupId]["rank_"..groupMembers[groupId][selectedMember]["rank"]], groupStartX+4, groupStartY+2+22, groupStartX+220, groupStartY+22+22, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
					dxDrawText(Szerverszin.."Fizetés: #ffffff"..groups[groupId]["rank_"..groupMembers[groupId][selectedMember]["rank"].."_pay"].."$", groupStartX+4, groupStartY+2+44, groupStartX+220, groupStartY+22+44, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
					dxDrawText(Szerverszin.."Leader: #ffffff"..leaderText[groupMembers[groupId][selectedMember]["isLeader"]], groupStartX+4, groupStartY+2+66, groupStartX+220, groupStartY+22+66, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
					
					--- leader
					if meInGroup[groupId]["isLeader"] == 1 then
						--- member
						dxDrawRectangle(groupStartX+4, groupStartY+88+5, 220-8, 20, tocolor(124,197,118,200))
						dxDrawText("Előléptetés", groupStartX, groupStartY+93, groupStartX+220, groupStartY+113, tocolor(255,255,255), 1, "default-bold", "center", "center")
						rankupX, rankupY = groupStartX+4, groupStartY+88+5
						
						dxDrawRectangle(groupStartX+4, groupStartY+110+5, 220-8, 20, tocolor(0,113,210,200))
						dxDrawText("Lefokozás", groupStartX, groupStartY+96+22, groupStartX+220, groupStartY+113+20, tocolor(255,255,255), 1, "default-bold", "center", "center")
						rankdownX, rankdownY = groupStartX+4, groupStartY+96+22
						
						dxDrawRectangle(groupStartX+4, groupStartY+132+5, 220-8, 20, tocolor(197,124,118,200))
						dxDrawText("Kirúgás", groupStartX, groupStartY+99+42, groupStartX+220, groupStartY+113+40, tocolor(255,255,255), 1, "default-bold", "center", "center")
						removeX, removeY = groupStartX+4, groupStartY+99+42
					
						--- rank
						groupStartY = groupStartY+165
						dxDrawRectangle(groupStartX, groupStartY, 220, 46, tocolor(0,0,0,alpha))
						for key = 0, 1 do
							groupStartForY = groupStartY+2+key*22
							dxDrawRectangle(groupStartX+2, groupStartForY, 220-4, 20, tocolor(255,255,255,20))
						end
						dxDrawText(Szerverszin.."Név: #ffffff"..groups[groupId]["rank_"..selectedGroupRank], groupStartX+4, groupStartY+3, groupStartX+240, groupStartY+3+20, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
						dxDrawText(Szerverszin.."Fizetés: #ffffff"..groups[groupId]["rank_"..selectedGroupRank.."_pay"].."$", groupStartX+4, groupStartY+3+22, groupStartX+240, groupStartY+3+20+22, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
						
						groupStartY = groupStartY+46
						
						dxDrawRectangle(groupStartX+4, groupStartY+2, 212, 20, tocolor(124,197,118,180))
						dxDrawText("Rang szerkesztése", groupStartX, groupStartY+2, groupStartX+220, groupStartY+22, tocolor(255,255,255), 1, "default-bold", "center", "center")
						groupStartEditX, groupStartEditY = groupStartX+2, groupStartY+2
						
						if editRangGui then
							roundedRectangle(groupStartX, groupStartY+26, 220, 22, tocolor(0,0,0,alpha), tocolor(255,255,255,20), true)
							roundedRectangle(groupStartX, groupStartY+50, 220, 22, tocolor(0,0,0,alpha), tocolor(255,255,255,20), true)
							
							dxDrawText(guiGetText(editRangGui),groupStartX+4, groupStartY+26, groupStartX+246, groupStartY+48, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, true)
							if guiGetText(editRangGui) == "" then
								dxDrawText("Rang neve", groupStartX+4, groupStartY+26, groupStartX+246, groupStartY+48, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, true)
							end
							
							dxDrawText(guiGetText(editPayGui),groupStartX+4, groupStartY+26+24, groupStartX+246, groupStartY+48+24, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, true)
							if guiGetText(editPayGui) == "" then
								dxDrawText("Rang fizetése", groupStartX+4, groupStartY+26+24, groupStartX+246, groupStartY+48+24, tocolor(255,255,255), 1, "default-bold", "left", "center", false, false, true)
							end
							
							dxDrawRectangleButton(groupStartX+4, groupStartY+78, 212, 20, tocolor(124,197,118,180), "Elfogad")
							dxDrawRectangleButton(groupStartX+4, groupStartY+100, 212, 20, tocolor(243,85,85,180), "Elutasít")
							
							acceptX, acceptY, declineX, declineY = groupStartX+4, groupStartY+78, groupStartX+4, groupStartY+100
						else
							dxDrawRectangleButton(groupStartX+4, groupStartY+25, 212, 20, tocolor(124,197,118,180), "Tag felvétele")
							inviteX, inviteY = groupStartX+4, groupStartY+25+22
							
							if inviteGui then
								roundedRectangle(inviteX-4, inviteY, 220, 22, tocolor(0,0,0,alpha), tocolor(255,255,255,20), true)
								
								dxDrawText(guiGetText(inviteGui), inviteX, inviteY, inviteX+212, inviteY+22, tocolor(255,255,255), 1, "default-bold", "left", "center")
								if guiGetText(inviteGui) == "" then
									dxDrawText("Játékos neve", inviteX, inviteY, inviteX+212, inviteY+22, tocolor(255,255,255), 1, "default-bold", "left", "center")
								end
								
								dxDrawRectangleButton(inviteX, inviteY+24, 212, 20, tocolor(124,197,118,180), "Felvétel")
								dxDrawRectangleButton(inviteX, inviteY+46, 212, 20, tocolor(243,85,85,180), "Mégse")
								
								acceptX, acceptY, declineX, declineY = inviteX, inviteY+24, inviteX, inviteY+45
							end
						end
					end
				end
			else
				dxDrawText("Nem vagy frakcióban", 0, 0, Kepernyo[1], Kepernyo[2], tocolor(255,255,255), 2.40, "default-bold", "center", "center")
			end
		elseif (JelenOldal == 3 ) then -- Vagyon
			dxDrawText("Banki egyenleg: #7cc576"..penz_darabolas(localPlayer:getData("char:bankmoney")).." #ffffff$ - Prémium egyenleg: #2AABFD"..penz_darabolas(localPlayer:getData("char:pp")).." #ffffffPP", Kepernyo[1], PanelY1+10, 0, 0, tocolor(255,255,255), 1, Menupontfont, "center", "top", false, false, false, true)
		
			--- Vehicles
			dxDrawText("Járművek", panelX+120, PanelY1+60-20, panelX+120+320, 0, tocolor(255,255,255), 1, Menupontfont, "center")
			dxDrawRectangle(panelX+120, PanelY1+60, 320, 453, tocolor(0,0,0,alpha))
			
			dxDrawRectangle(panelX+120, PanelY1+35, 70, 20, tocolor(124, 197, 118, 100))
			dxDrawText("+slot", panelX+120, PanelY1+35, panelX+190, PanelY1+55, tocolor(255,255,255,180), 1, "default-bold", "center", "center")
			
			dxDrawText("Slot: #7cc576"..#myVehicles.."#ffffff/#7cc576"..localPlayer:getData("char:vehSlot"), panelX+120, PanelY1+60-20, panelX+120+320, 0, tocolor(255,255,255), 1, Menupontfont, "right", "top", false, false, false, true)
			
			latestRowV = currentRowV+maxRowV-1
			for index, value in ipairs(myVehicles) do
				if index >= currentRowV and index <= latestRowV then
					index = index-currentRowV+1
				
					vehicleX, vehicleY = panelX+120+4, PanelY1+60+4+((index-1)*25)
					dxDrawRectangle(vehicleX, vehicleY, 312, 20, tocolor(124, 197, 118, 100))
					dxDrawText(exports.exg_carshop:getVehicleRealName(getElementModel(value)), vehicleX+6, vehicleY, vehicleX+312, vehicleY+20, tocolor(255,255,255), 1, "default-bold", "left", "center")
					vehicleHealth = "#ffffffÁllapot: #2AABFD"..math.floor(getElementHealth(value)/10+0.5).."%"
					vehicleID = "#ffffffID: #7cc576"..value:getData("veh:id")
					vehicleText = vehicleHealth.." | "..vehicleID
					dxDrawText(vehicleText, vehicleX, vehicleY, vehicleX+306, vehicleY+20, tocolor(255,255,255), 1, "default-bold", "right", "center", false, false, false, true)
				end
			end
			
			for index = 0, 17 do
				vehicleX, vehicleY = panelX+120+4, PanelY1+60+4+index*25
				
				if not myVehicles[index+1] then
					dxDrawRectangle(vehicleX, vehicleY, 312, 20, tocolor(108, 122, 137, 20))
				end
			end
			
			--- Interiors
			dxDrawText("Ingatlanok", panelX+Meretek[1]/2+105, PanelY1+60-20, panelX+Meretek[1]/2+430, PanelY1+60+450, tocolor(255,255,255,255), 1, Menupontfont, "center")
			dxDrawRectangle(panelX+Meretek[1]/2+105, PanelY1+60, 320, 453, tocolor(0,0,0,alpha))
			
			dxDrawRectangle(panelX+Meretek[1]/2+105, PanelY1+35, 70, 20, tocolor(124, 197, 118, 100))
			dxDrawText("+slot", panelX+Meretek[1]/2+105, PanelY1+35, panelX+Meretek[1]/2+180, PanelY1+55, tocolor(255,255,255,180), 1, "default-bold", "center", "center")
		
			dxDrawText("Slot: #7cc576"..#myInteriors.."#ffffff/#7cc576"..localPlayer:getData("char:houseSlot"), panelX+Meretek[1]/2+105, PanelY1+60-20, panelX+Meretek[1]/2+105+320, 0, tocolor(255,255,255), 1, Menupontfont, "right", "top", false, false, false, true)
		
			latestRowI = currentRowI+maxRowI-1
			for index, value in ipairs(myInteriors) do
				if index >= currentRowI and index <= latestRowI then
					index = index-currentRowI+1
				
					interiorX, interiorY = panelX+Meretek[1]/2+109, PanelY1+60+4+((index-1)*25)
					dxDrawRectangle(interiorX, interiorY, 312, 20, tocolor(124, 197, 118, 100))
					dxDrawText(value:getData("name") or "Ingatlan", interiorX+6, interiorY, interiorX+312, interiorY+20, tocolor(255,255,255), 1, "default-bold", "left", "center")
					if value:getData("locked") == 1 then
						interiorStatus = "#ffffffStátusz: #cc0000zárva"
					else
						interiorStatus = "#ffffffStátusz: #7cc576nyitva"
					end
					interiorID = "#ffffffID: #7cc576"..value:getData("id")
					interiorText = interiorStatus.." | "..interiorID
					dxDrawText(interiorText, interiorX, interiorY, interiorX+306, interiorY+20, tocolor(255,255,255), 1, "default-bold", "right", "center", false, false, false, true)
				end
			end
			
			for index = 0, 17 do
				interiorX, interiorY = panelX+Meretek[1]/2+109, PanelY1+60+4+index*25
				
				if not myInteriors[index+1] then
					dxDrawRectangle(interiorX, interiorY, 312, 20, tocolor(108, 122, 137, 20))
				end
			end
		elseif (JelenOldal == 4 ) then  -- PP
			--dxDrawText("Hamarosan elérhető", 0, 0, Kepernyo[1], Kepernyo[2], tocolor(255,255,255), 2.40, "default-bold", "center", "center")
			dxDrawRectangle(panelX, PanelY1,Meretek[1], 40, tocolor(0, 0, 0, 200))
			dxDrawText("PrémiumPont", panelX+Meretek[1]/2, PanelY1+40/2, panelX+Meretek[1]/2, PanelY1+40/2, tocolor(255,255,255,255), 1.6, "default-bold", "center", "center")
			dxDrawRectangle(panelX, PanelY1+40,Meretek[1], 3, tocolor(124, 197, 118, 200))
			dxDrawRectangle(panelX+5, PanelY1+80, Meretek[1]-10, Meretek[2]-85, tocolor(0, 0, 0,200))
			dxDrawText("A PremiumPanelt az #7cc576'F6'#ffffff-gomb lenyomásával tudod megnyitni, járművet PrémiumPontért a kereskedésben vásárolhatsz. \nTöbb féle módon vásárolhatsz PremiumPontot, SMS-ért, PayPalon és Banki átutalással. \n\nHa SMS-ért szeretnél PremiumPontot vásárolni látogass el az #7cc576'ucp.externalgaming.hu'#ffffff-oldalra \nmajd jelentkezz be a szerveren a szerveren megadott adatokkal, és válaszd ki a #19B5FE'Támogatás'#ffffff-menüpontot!\n\n#D24D57Fontos hogy ne tartózkodjon a szerveren amikor az SMS-t küldöd különben nem íródik jóvá a PremiumPont.\nElgépelt SMS-ekért nem vállalunk felelőséget!#ffffff\n\nAmennyiben PayPal-on vagy Banki átutalásal szeretnél PremiumPontot vagy esetleg mást #F7CA18(Ház,Kocsi,Pénz,ETC)#ffffff-vásárolni \nlátogass fel TeamSpeak szerverünkre #F7CA18(ts.externalgaming.hu)#ffffff-és menj be #87D37C'djalmasi' #ffffffvagy #87D37C'bob' #ffffffvárójába.'", (panelX+5)+(Meretek[1]-10)/2, PanelY1+85, (panelX+5)+(Meretek[1]-10)/2, 0, tocolor(255,255,255,255), 1.2, "default-bold", "center", "top", false, false, false, true)
			dxDrawImage(panelX+270, PanelY1+340, 620, 220, "files/pp.png")--SMS Aggregátor: #2574A9'fortumo.com' #ffffff- Weboldalunk: #2574A9'externalgaming.hu
			dxDrawText("SMS Aggregátor: #2574A9'fortumo.com' #ffffff- Weboldalunk: #2574A9'externalgaming.hu", (panelX+5)+(Meretek[1]-10)/2, PanelY1+Meretek[2]-25, (panelX+5)+(Meretek[1]-10)/2, 0, tocolor(255,255,255,255), 1.2, "default-bold", "center", "top", false, false, false, true)
		elseif (JelenOldal == 5 ) then  -- beállítások
			dxDrawRectangle(panelX, PanelY1,Meretek[1], 40, tocolor(0, 0, 0, 200))
			dxDrawText("Beállítások", panelX+Meretek[1]/2, PanelY1+40/2, panelX+Meretek[1]/2, PanelY1+40/2, tocolor(255,255,255,255), 1.6, "default-bold", "center", "center")
			dxDrawRectangle(panelX, PanelY1+40,Meretek[1], 3, tocolor(124, 197, 118, 200))
			for i , v in ipairs (optionsTable) do 
				dxDrawRectangle(panelX+10, PanelY1-50+70+i*(50),350, 40, tocolor(0, 0, 0, 200))
				if v[2] == 0 then 
					optionsCreateColor = tocolor(210, 77, 87, 200)
					optionsCreateText = "Kikapcsolva"	
				else
					optionsCreateColor = tocolor(124, 197, 118, 200)
					optionsCreateText = "Bekapcsolva"
				end
				if v[1] ~= "Látótávolság" and v[1] ~= "Séta stílus" and v[1] ~= "Harc stílus"  then 
					dxDrawRectangle(panelX+355-150, PanelY1-50+75+i*(50),150, 30, optionsCreateColor)
					if isCursorOnBox(panelX+355-150, PanelY1-50+75+i*(50),150, 30) then 
						dxDrawText(optionsCreateText, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, tocolor(0,0,0,255), 1.0, "default-bold", "center", "center")
					else
						dxDrawText(optionsCreateText, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, tocolor(255,255,255,255), 1.0, "default-bold", "center", "center")
					end
				elseif v[1] == "Látótávolság" then 
					dxDrawRectangle(panelX+355-150, PanelY1-50+75+i*(50),150, 30, tocolor(0, 0, 0, 200))
					local maxDistanceText = ""
					if maxDistance <= 0 then 
						maxDistanceText = "Alapértelmezett"
					else
						maxDistanceText = maxDistance
					end
					if maxDistance > 4000 then 
						maxDistance = 0
					end
					dxDrawText(maxDistanceText, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, tocolor(255,255,255,255), 1.0, "default-bold", "center", "center")
				elseif v[1] == "Séta stílus" then
					dxDrawRectangle(panelX+205, PanelY1+25+i*50, 150, 30, tocolor(0, 0, 0, 200))
					local walkText = ""
					walkStyle = getPedWalkingStyle(localPlayer)
					if walkStyle == walks[1] then
						walkText = "Alapértelmezett"
					else
						for key, value in ipairs(walks) do
							if walks[key] == walkStyle then
								walkText = "Séta stílus " .. key
							end
						end
					end
					dxDrawText(walkText, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, tocolor(255,255,255,255), 1, "default-bold", "center", "center")
				elseif v[1] == "Harc stílus" then
					dxDrawRectangle(panelX+205, PanelY1+25+i*50, 150, 30, tocolor(0, 0, 0, 200))
					local fightText = ""
					fightStyle = localPlayer:getData("fightStyle")
					if fightStyle == fights[1] then
						fightText = "Alapértelmezett"
					else
						for key, value in ipairs(fights) do
							if fights[key] == fightStyle then
								fightText = "Harc stílus " .. key
							end
						end
					end
					dxDrawText(fightText, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, panelX+355-150+150/2, PanelY1-50+75+i*(50)+30/2, tocolor(255,255,255,255), 1, "default-bold", "center", "center")			
				end
				dxDrawText(v[1], panelX+20, PanelY1-50+70+i*(50)+ 40/2, 0, PanelY1-50+70+i*(50)+ 40/2, tocolor(255,255,255,255), 1.2, "default-bold", "left", "center")
			end
		
		
		elseif (JelenOldal == 6) then  -- Adminok
			dxDrawText(Szerverszin.."Online#ffffff Adminisztrátorok / Adminsegédek", Kepernyo[1], PanelY1+20, 0, 0, tocolor(255,255,255), 1.3, "default-bold", "center", "top", false, false, false, true)
			
			dxDrawText("Az adminrangok menüpontok között\na "..Szerverszin.."PageUP #ffffffés "..Szerverszin.."PageDOWN #ffffff\ngombokkal tudsz navigálni", panelX+357+395, PanelY1+140, panelX+357+395+300, PanelY1+140+360, tocolor(255,255,255), 1, "default-bold", "center", "center", false, false, false, true)
		
			dxDrawRectangle(panelX+17, PanelY1+140, 340, 359, tocolor(0,0,0,alpha))
			dxDrawRectangle(panelX+357+40, PanelY1+140, 340, 359, tocolor(0,0,0,alpha))

			for key = 0, 7 do
				startKeyY = PanelY1+145
				dxDrawRectangle(panelX+22, startKeyY+key*44, 330, 40, tocolor(255,255,255,20))
				
				if key == selectedRank then
					dxDrawRectangle(panelX+22, startKeyY+key*44, 330, 40, tocolor(124, 197, 118, 180))
				end
				
				if key == 0 then
					dxDrawText("Adminsegéd", panelX+22, startKeyY+key*44, panelX+352, startKeyY+key*44+40, tocolor(255,255,255), 1.3, "default-bold", "center", "center", false, false, false, true)
				elseif key < 6 then
					dxDrawText("Admin "..key, panelX+22, startKeyY+key*44, panelX+352, startKeyY+key*44+40, tocolor(255,255,255), 1.3, "default-bold", "center", "center", false, false, false, true)			
				else
					if key == 6 then
						dxDrawText("Főadmin", panelX+22, startKeyY+key*44, panelX+352, startKeyY+key*44+40, tocolor(255,255,255), 1.3, "default-bold", "center", "center", false, false, false, true)			
					else
						dxDrawText("Szuperadmin", panelX+22, startKeyY+key*44, panelX+352, startKeyY+key*44+40, tocolor(255,255,255), 1.3, "default-bold", "center", "center", false, false, false, true)								
					end
				end
			end
			
			forRank = selectedRank
			if forRank == 0 then
				forRank = "as"
			end
			
			for key, value in ipairs(gotAdmins[forRank]) do
				if #gotAdmins[forRank] > 0 then
					startDrawY = PanelY1+141.5+(key-1)*21
					startDrawX = panelX+399
					dxDrawRectangle(startDrawX, startDrawY, 336, 20, tocolor(255,255,255,20))
					
					textLeft = value:getData("char:anick") .. " ID: " .. Szerverszin .. value:getData("playerid")
					textRight = "Adminszolgálat: " .. admindutyText[value:getData("char:adminduty")]
					
					if forRank == "as" then
						textLeft = value:getData("char:name") .. " ID: " .. Szerverszin .. value:getData("playerid")
						textRight = "Adminsegéd"
						if value:getData("acc:aseged") == 1 then
							textRight = "Ideiglenes adminsegéd"
						end
					end
					
					dxDrawText(textLeft, startDrawX+6, startDrawY, startDrawX+336, startDrawY+20, tocolor(255,255,255,255), 1, "default-bold", "left", "center", false, false, false, true)
					dxDrawText(textRight, startDrawX, startDrawY, startDrawX+330, startDrawY+20, tocolor(255,255,255,255), 1, "default-bold", "right", "center", false, false, false, true)
				end
			end
			
			if #gotAdmins[forRank] < 1 then
				dxDrawText("Nincs elérhető", panelX+357+40, PanelY1+140, panelX+357+40+340, PanelY1+140+359, tocolor(144,0,0,200), 1.4, "default-bold", "center", "center")
			end
			
			for key = 1, 17 do
				if #gotAdmins[forRank] > 0 then
					if not gotAdmins[forRank][key] then
						startDrawY = PanelY1+141.5+(key-1)*21
						startDrawX = panelX+399
						dxDrawRectangle(startDrawX, startDrawY, 336, 20, tocolor(255,255,255,20))
					end
				end
			end
			
			dxDrawText(">", panelX+367-3, startKeyY+3, panelX+387, startKeyY+360, tocolor(0, 0, 0, 200), 3, "default-bold", "center", "center")
			dxDrawText(">", panelX+367-3, startKeyY-3, panelX+387, startKeyY+360, tocolor(0, 0, 0, 200), 3, "default-bold", "center", "center")
			dxDrawText(">", panelX+367+3, startKeyY-3, panelX+387, startKeyY+360, tocolor(0, 0, 0, 200), 3, "default-bold", "center", "center")
			dxDrawText(">", panelX+367+3, startKeyY+3, panelX+387, startKeyY+360, tocolor(0, 0, 0, 200), 3, "default-bold", "center", "center")
			dxDrawText(">", panelX+367, startKeyY, panelX+387, startKeyY+360, tocolor(124, 197, 118, 200), 3, "default-bold", "center", "center")
		end
	end
end
addEventHandler("onClientRender", root ,dashboardFelrajzol)

function onlineByName(name)
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "loggedin") then
			if getElementData(player, "char:name"):gsub("_", " ") == tostring(name) then
				return 1
			end
		else
			return 0
		end
	end

	return 0
end

local openedTime = 0
function MutatDashboard()
	if localPlayer:getData("loggedin") then
		if confirmVehSlot or confirmIntSlot then return end
		if editRangGui then return end
		
		if getTickCount()-openedTime <= 5000 and not show then
			infobox("Csak 5 másodpercenként nyithatod meg a dashboardot.", 2)
			return
		else
			openedTime = getTickCount()
		end

		setElementData(localPlayer, "toggle-->All", show)

		if show then
			show = false
			showChat(true)
			alpha = 0
			alphaText = 0
			KepAlpha = 0
			JelenOldal = 0
			
			setTimer(function()
				toggleControl("change_camera",true)
			end, 500, 1)
			
		else			
			show = true
			showChat(false)
			Elsolepes = 0
			LoadingDashboard()
			
			confirmVehSlot = false
			confirmIntSlot = false
			
			getVehicles()
				maxRowV = 18
				currentRowV = 1
				latestRowV = 1
			
			getInteriors()
				maxRowI = 18
				currentRowI = 1
				latestRowI = 1			
			
			getAdmins()
				selectedRank = 0
				
			fetchGroups()
				triggerServerEvent("requestGroups", localPlayer)
				selectedGroup = 1
				selectedMember = 1
				selectedGroupRank = 1
				maxRowG = 15
				currentRowG = 1
				latestRowG = 1
				maxRowVehG = 10
				currentRowVehG = 1
				latestRowVehG = 1
				toggleControl("change_camera",false)
		end
	end
end
bindKey("Home","down",MutatDashboard)
addCommandHandler("dash", MutatDashboard)

local Admin
function LoadingDashboard()
	if not getElementData(localPlayer,"loggedin") then return end
	local Alevel = tonumber(getLocalPlayer():getData("acc:admin"))
	if (Alevel > 0) then 
		Admin = "Igen"
	else
		Admin = "Nem"
	end
	Adatok = {
		{"Neved: ".. Szerverszin .. string.gsub(getPlayerName(localPlayer),"_"," ")},
		{"Pénzed: ".. Szerverszin .. penz_darabolas(tonumber(getLocalPlayer():getData("char:money"))).. "$"},
		{"Banki egyenleged: ".. Szerverszin .. penz_darabolas(tonumber(getLocalPlayer():getData("char:bankmoney"))).. "$"},
		{"Játszott percek: ".. Szerverszin .. tonumber(getLocalPlayer():getData("char:playedTime"))},
		{"#ffffffÓra: ".. Szerverszin .. tonumber(math.floor(getLocalPlayer():getData("char:playedTime")/60))},
		{"Prémium Pont: ".. Szerverszin .. tonumber(getLocalPlayer():getData("char:pp"))},
		{"Regisztráció dátuma: ".. Szerverszin .. getLocalPlayer():getData("acc:regdate")},
		{"Utolsó bejelentkezés napja: ".. Szerverszin .. getLocalPlayer():getData("acc:lastlogin") or "n/a"},
		{"Account ID: ".. Szerverszin .. tonumber(getLocalPlayer():getData("acc:id"))},
		{"Admin: ".. Szerverszin .." ( "..Admin.. " ) " .. getColor(localPlayer)},
		{"Skin ID: ".. Szerverszin .. tonumber(getLocalPlayer():getData("char:skin"))},
		{"Munkád: ".. Szerverszin .. getJobName[tonumber(getLocalPlayer():getData("char:job"))]},
		{"Admin nick: ".. Szerverszin .. getLocalPlayer():getData("char:anick")},
	}
	
end

function getColor(playerSource)
	if (playerSource:getData("char:adminduty") == 1) then
		if (tonumber(playerSource:getData("acc:admin")) == 10) then
			return "#F62459 ( Tulajdonos ) "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 9) then
			return "#663399 ( Rendszergazda ) "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 8) then
			return "#19B5FE < Fejlesztő /> "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 7) then
			return "#F7CA18 [Szuper Admin] "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 6) then
			return "#1BA39C [FőAdmin] "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 5) then
			return "#F9BF3B [Admin ~ 5] "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 4) then
			return "#F9BF3B [Admin ~ 4] "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 3) then
			return "#F9BF3B [Admin ~ 3] "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 2) then
			return "#F9BF3B [Admin ~ 2] "		
		elseif (tonumber(playerSource:getData("acc:admin")) == 1) then
			return "#F9BF3B [Admin ~ 1] "		
		elseif (tonumber(playerSource:getData("acc:aseged")) == 2) then
			return "#BF55EC [Admin Segéd] "		
		elseif (tonumber(playerSource:getData("acc:aseged")) == 1) then
			return "#BF55EC [I.D.G Admin Segéd] "
		end
	else
		return "#ffffff"
	end
end

function getVehicles()
	myVehicles = {}
	
    for _, value in ipairs(getElementsByType("vehicle")) do
        if value:getData("veh:owner") == localPlayer:getData("char:id") then
			table.insert(myVehicles, value)
        end
    end
end

function getInteriors()
	myInteriors = {}
	
	for _, value in ipairs(getElementsByType("marker")) do
		if value:getData("typePick") and value:getData("typePick") == "outside" then
			if value:getData("owner") == localPlayer:getData("char:id") then
				table.insert(myInteriors, value)
			end
		end
	end
end

function getAdmins()
	gotAdmins = {}

	gotAdmins["as"] = {}

	for i=1, 7 do
		gotAdmins[i] = {}
	end

	for k, v in ipairs(getElementsByType("player")) do
		local level = getElementData(v, "acc:admin")

		if tonumber(level) and level > 0 and level <= 7 then
			table.insert(gotAdmins[level], v)
		else
			local level2 = getElementData(v, "acc:aseged")

			if tonumber(level2) and level2 > 0 then
				table.insert(gotAdmins["as"], v)
			end
		end
	end
end

function penz_darabolas(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

LoadingDashboard()

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end
		
		if (not bgColor) then
			bgColor = borderColor;
		end
		
		--> Background
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		
		--> Border
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end

--***********************************************************************************************************************************************************************************
--************************************************************************************[Clickelés]************************************************************************************
--***********************************************************************************************************************************************************************************

function menuClick(gomb,stat,x,y)
	if not show then return end
	if confirmVehSlot or confirmIntSlot then return end
	
	if gomb == "left" and stat == "down" then
		for i ,v in ipairs (Menusor) do 
			if (dobozbaVan(panelX-150+i*155, PanelY1-55+5, 150, 40, x, y)) then 
				if editRangGui then return end
				
				JelenOldal = i
				if JelenOldal == 2 then
					--outputChatBox("AHA")
					fetchGroups()
					triggerServerEvent("requestGroups", localPlayer,localPlayer)
				end
				if Elsolepes == 0 then 
					Elsolepes = 1
					Tick = getTickCount()
					progress = "Linear"
				end
				--else
				--	Elsolepes = 0
				--	Elsolepes = 1
				--	Tick = getTickCount()
				--	progress = "Linear"
				--end
			end
		end
		if Size3 ~= Meretek[2] then return end -- hibák miatt -> néhány változónak nincs értéke amíg nem nyílik szét és elsőre hibát dob vissza
		if JelenOldal == 5 then 
			for i , v in ipairs (optionsTable) do 
				if v[1] ~= "Látótávolság" and v[1] ~= "Séta stílus" and v[1] ~= "Harc stílus"  then 
					if dobozbaVan(panelX+355-150, PanelY1-50+75+i*(50),150, 30, x, y) then
						if editRangGui then return end
						
						if v[2] > 0 then
							v[2] = 0
						else
							v[2] = 1
						end
					end
				elseif v[1] == "Látótávolság" then 
					if dobozbaVan(panelX+355-150, PanelY1-50+75+i*(50),150, 30, x, y) then
						if editRangGui then return end
						
						if maxDistance >= 0 and  maxDistance < 3900 then 
							maxDistance = maxDistance + 150
							setFarClipDistance(maxDistance)
						elseif maxDistance == 3900 then 
							maxDistance = maxDistance + 100
							setFarClipDistance(maxDistance)
						elseif maxDistance == 0 then 
							resetFarClipDistance()
						elseif maxDistance >= 4000 then 
							maxDistance = 0 
						end
					end
				elseif v[1] == "Séta stílus" then
					if dobozbaVan(panelX+205, PanelY1+25+i*50, 150, 30, x, y) then
						if editRangGui then return end
						
						if getPedWalkingStyle(localPlayer) == walks[#walks] then
							setPedWalkingStyle(localPlayer, walks[1])
							triggerServerEvent("setPedNextWalkStyle", localPlayer, walks[1])
						else
							local currentWalk = getPedWalkingStyle(localPlayer)
							for key, value in ipairs(walks) do
								if walks[key] == currentWalk then
									setPedWalkingStyle(localPlayer, walks[key+1])
									triggerServerEvent("setPedNextWalkStyle", localPlayer, walks[key+1])
									break
								end
							end
						end
					end
				elseif v[1] == "Harc stílus" then
					if dobozbaVan(panelX+205, PanelY1+25+i*50, 150, 30, x, y) then
						if editRangGui then return end
						
						if localPlayer:getData("fightStyle") == fights[#fights] then
							nextStyle = fights[1]
						else
							for key, value in ipairs(fights) do
								if fights[key] == localPlayer:getData("fightStyle") then
									nextStyle = fights[key+1]
									break
								end
							end
						end
						localPlayer:setData("fightStyle", nextStyle)
						triggerServerEvent("setPedNextFightStyle", localPlayer, nextStyle)
					end
				end
				shaderFrissites()
			end
		elseif JelenOldal == 2 then
			--select member
			for key = 0, 14 do
				groupStartX, groupStartY = panelX+230+250, PanelY1+25-2
				groupStartForY = groupStartY+2+key*22
				if dobozbaVan(groupStartX, groupStartForY, 340, 20, x, y) and groupMembers[groupId][key+1-maxRowG+latestRowG] then
					if editRangGui then return end
					
					select = false
					selectedMember = key+1
				end
			end
				
			--select rank
			for key = 0, 14 do
				groupStartX, groupStartY = panelX+230-2, PanelY1+25-2
				groupStartForY = groupStartY+2+key*22
				if dobozbaVan(groupStartX, groupStartForY, 240, 20, x, y) then
					if editRangGui then return end
					
					selectedGroupRank = key+1
				end
			end
				
			if meInGroup[groupId]["isLeader"] == 1 then
				--edit selected rank
				if not editRangGui and not inviteGui and dobozbaVan(groupStartEditX, groupStartEditY, 212, 22, x, y) then
					editRangGui = guiCreateEdit(groupStartEditX, groupStartEditY+24, 212, 22, "", false)
					guiSetAlpha(editRangGui, 0)
					guiEditSetMaxLength(editRangGui, 32)
					
					editPayGui = guiCreateEdit(groupStartEditX, groupStartEditY+48, 212, 22, "", false)
					guiSetAlpha(editPayGui, 0)
					guiEditSetMaxLength(editPayGui, 32)
				end
				
				if editRangGui then
					if dobozbaVan(acceptX, acceptY, 212, 20, x, y) then --- accept the edit
						if groups[groupId]["type"] == (5 or 6) then
							guiSetText(editPayGui, 0)
						end
						if tostring(guiGetText(editRangGui)) and tonumber(guiGetText(editPayGui)) then
							if guiGetText(editRangGui) ~= "" and guiGetText(editRangGui) ~= " " then
								if tonumber(guiGetText(editPayGui)) >= 0 or tonumber(guiGetText(editPayGui)) <= 1000 then
									groups[groupId]["rank_"..selectedGroupRank] = guiGetText(editRangGui)
									groups[groupId]["rank_"..selectedGroupRank.."_pay"] = guiGetText(editPayGui)
									
									infobox("Sikeresen megváltoztattad a rang beállításait")
									
									triggerServerEvent("renameRank", localPlayer, selectedGroupRank, guiGetText(editRangGui), groupId)
									triggerServerEvent("setRankPayment", localPlayer, selectedGroupRank, tonumber(guiGetText(editPayGui)), groupId)
									fetchGroups()
									
									destroyElement(editRangGui)
									destroyElement(editPayGui)							
									editRangGui = false
									editPayGui = false
								end
							end
						end
					elseif dobozbaVan(declineX, declineY, 212, 20, x, y) then --- decline the edit
						destroyElement(editRangGui)
						destroyElement(editPayGui)							
						editRangGui = false
						editPayGui = false					
					end
				end
				
				--change member datas
				if not editRangGui and not inviteGui then
					if dobozbaVan(rankupX, rankupY, 212, 20, x, y) then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]
						
						triggerServerEvent("modifyRankForPlayer", localPlayer, member["id"], member["rank"], groupId, "up", member["online"], playerGroups)
						infobox("Sikeresen előléptetted "..member["characterName"].." játékost")
					end
					
					if dobozbaVan(rankdownX, rankdownY, 212, 20, x, y) then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]
						
						triggerServerEvent("modifyRankForPlayer", localPlayer, member["id"], member["rank"], groupId, "down", member["online"], playerGroups)					
						infobox("Sikeresen lefokoztad "..member["characterName"].." játékost")
					end
					
					if dobozbaVan(removeX, removeY, 212, 20, x, y) then
						local thisMembers = groupMembers[groupId]
						local member = thisMembers[selectedMember]
						
						triggerServerEvent("deletePlayerFromGroup", localPlayer, member["id"], groupId, member["online"], playerGroups)
						infobox("Sikeresen kirúgtad "..member["characterName"].." játékost")
						
						table.remove(meInGroup, groupId)
						
						--fetchGroups()
						--triggerServerEvent("requestGroups", localPlayer)
					end
				end
				
				--invite player to group
				if not inviteGui and not editRangGui then
					if dobozbaVan(inviteX, inviteY-22, 212, 20, x, y) then
						inviteGui = guiCreateEdit(inviteX, inviteY, 220, 22, "", false)
						guiSetAlpha(inviteGui, 0)
						guiEditSetMaxLength(inviteGui, 32)
					end
				end
				
				if inviteGui then
					if dobozbaVan(acceptX, acceptY, 212, 20, x, y) then
						local name = guiGetText(inviteGui)
						local found = false
						local multipleFound = false
						
						for _, value in ipairs(getElementsByType("player")) do
							if value:getData("loggedin") then
								if string.find(value:getData("char:name"), name) then
									if not found then
										found = value
									else
										infobox("Több találat", 2)
										found = false
										multipleFound = true
										break
									end
								end
							end
						end
						
						if found and not multipleFound and isElement(found) then
							local thisMembers = groupMembers[groupId]
							
							local already = false
							for _, value in ipairs(thisMembers) do
								if found:getData("char:name") == value["characterName"]:gsub("_", " ") then
									already = true
								end
							end

							if already then
								infobox(found:getData("char:name").." már tagja a frakciónak", 2)
							else
								infobox("Sikeresen felvetted "..found:getData("char:name").." játékost")
								triggerServerEvent("invitePlayer", localPlayer, getElementData(found, "char:id"), groupId, found, playerGroups)
							end
						elseif not found and not multipleFound then
							infobox("Nincs találat", 2)
						end
					end
					if dobozbaVan(declineX, declineY, 212, 20, x, y) then
						destroyElement(inviteGui)
						inviteGui = false
					end
				end
				
				--- set the group balance
				if not balanceGui then
					if groups[groupId]["type"] ~= (5 or 6) then
						if dobozbaVan(pBalanceX, pBalanceY, 440, 20, x, y) then
							balanceGui = guiCreateEdit(pBalanceX, pBalanceY+44, 440, 20, "", false)
							guiSetAlpha(balanceGui, 0)
							guiEditSetMaxLength(balanceGui, 30)
							balanceGuiType = "plus"
						end
						
						if dobozbaVan(mBalanceX, mBalanceY, 440, 20, x, y) then
							balanceGui = guiCreateEdit(pBalanceX, pBalanceY+44, 440, 20, "", false)
							guiSetAlpha(balanceGui, 0)
							guiEditSetMaxLength(balanceGui, 30)
							balanceGuiType = "minus"					
						end
					end
				end
				
				if balanceGui then
					if balanceGuiType == "plus" then
						if dobozbaVan(pBalanceX, pBalanceY+66, 440, 20, x, y) then
							local money = guiGetText(balanceGui)
							if not tonumber(money) then
								infobox("Hibás összeg (nem szám)", 2)
								return
							end
							
							if tonumber(money) < 1 then
								infobox("Minimum 1 dollárt kell befizetned", 2)
								return
							end
							
							local money = tonumber(money)
							local current = groups[groupId]["balance"]
							local after = current+money
							
							if localPlayer:getData("char:money") >= money then
								triggerServerEvent("setGroupBalance", localPlayer, groupId, after)
								groups[groupId]["balance"] = after
								fetchGroups()
								
								localPlayer:setData("char:money", localPlayer:getData("char:money")-money)
								
								infobox("Sikeresen befizettél a frakció számlára "..money.." dollárt")
								
								destroyElement(balanceGui)
								balanceGui = false
							else
								infobox("Nincs elég pénzed", 2)
							end
						end
					elseif balanceGuiType == "minus" then
						if dobozbaVan(pBalanceX, pBalanceY+66, 440, 20, x, y) then
							local money = guiGetText(balanceGui)
							if not tonumber(money) then
								infobox("Hibás összeg (nem szám)", 2)
								return
							end
							
							if tonumber(money) < 1 then
								infobox("Minimum 1 dollárt kell kifizetned", 2)
								return
							end
							
							local money = tonumber(money)
							local current = groups[groupId]["balance"]
							local after = current-money
							
							if groups[groupId]["balance"] >= money then
								triggerServerEvent("setGroupBalance", localPlayer, groupId, after)
								groups[groupId]["balance"] = after
								fetchGroups()
								
								localPlayer:setData("char:money", localPlayer:getData("char:money")+money)
								
								infobox("Sikeresen kivettél a frakció számláról "..money.." dollárt")
								
								destroyElement(balanceGui)
								balanceGui = false
							else
								infobox("Nincs ennyi pénz a frakció számlán", 2)
							end
						end						
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick",getRootElement(),menuClick)

function infobox(text, type)
	if not tonumber(type) then type = 4 end
	exports["mta_notifications"]:createNotification(text, type)
end

addEventHandler("onClientClick", root, function(key, state, cx, cy)
	if show and JelenOldal == 3 then
		---Buy vehicle slot
		if key == "left" and state == "down" and cx >= panelX+120 and cx <= panelX+190 and cy >= PanelY1+35 and cy <= PanelY1+55 and not (confirmVehSlot or confirmIntSlot)  then
			addEventHandler("onClientRender", root, confirmSlotFunction)
			confirmVehSlot = true
		end
		if key == "left" and state == "down" and cx >= Kepernyo[1]/2-70 and cx <= Kepernyo[1]/2-70+65 and cy >= Kepernyo[2]/2-12 and cy <= Kepernyo[2]/2+12 and confirmVehSlot then
			if localPlayer:getData("char:pp") >= 100 then
				localPlayer:setData("char:pp", localPlayer:getData("char:pp")-100)
				localPlayer:setData("char:vehSlot", localPlayer:getData("char:vehSlot")+1)
				triggerServerEvent("updateVehicleSlots", localPlayer, localPlayer:getData("char:vehSlot"))
				
				confirmVehSlot = false
				removeEventHandler("onClientRender", root, confirmSlotFunction)
				
				outputChatBox("[ExternalGaming]: #ffffffSikeresen vettél egy jármű slotot #2AABFD100 #ffffffprémium pontért", 124, 197, 118, true)
			else
				outputChatBox("[ExternalGaming]: #ffffffNincs elég prémium pontod #2AABFD(100)", 124, 197, 118, true)
			end
		end
		if key == "left" and state == "down" and cx >= Kepernyo[1]/2-5 and cx <= Kepernyo[1]/2+70 and cy >= Kepernyo[2]/2-12 and cy <= Kepernyo[2]/2+12 and confirmVehSlot then
			confirmVehSlot = false
			removeEventHandler("onClientRender", root, confirmSlotFunction)			
		end
		
		---Buy interior slot
		if key == "left" and state == "down" and cx >= panelX+Meretek[1]/2+105 and cx <= panelX+Meretek[1]/2+175 and cy >= PanelY1+35 and cy <= PanelY1+55 and not (confirmVehSlot or confirmIntSlot)  then
			addEventHandler("onClientRender", root, confirmSlotFunction)
			confirmIntSlot = true
		end
		if key == "left" and state == "down" and cx >= Kepernyo[1]/2-70 and cx <= Kepernyo[1]/2-70+65 and cy >= Kepernyo[2]/2-12 and cy <= Kepernyo[2]/2+12 and confirmIntSlot then
			if localPlayer:getData("char:pp") >= 100 then
				localPlayer:setData("char:pp", localPlayer:getData("char:pp")-100)
				triggerServerEvent("savePP", localPlayer, localPlayer, getElementData(localPlayer, "char:pp"), getElementData(localPlayer, "char:id"))
				localPlayer:setData("char:houseSlot", localPlayer:getData("char:houseSlot")+1)
				triggerServerEvent("updateInteriorSlots", localPlayer, localPlayer:getData("char:houseSlot"))
				
				confirmIntSlot = false
				removeEventHandler("onClientRender", root, confirmSlotFunction)
				
				outputChatBox("[ExternalGaming]: #ffffffSikeresen vettél egy ingatlan slotot #2AABFD100 #ffffffprémium pontért", 124, 197, 118, true)
			else
				outputChatBox("[ExternalGaming]: #ffffffNincs elég prémium pontod #2AABFD(100)", 124, 197, 118, true)
			end
		end
		if key == "left" and state == "down" and cx >= Kepernyo[1]/2-5 and cx <= Kepernyo[1]/2+70 and cy >= Kepernyo[2]/2-12 and cy <= Kepernyo[2]/2+12 and confirmIntSlot then
			confirmIntSlot = false
			removeEventHandler("onClientRender", root, confirmSlotFunction)			
		end
	end
end)

bindKey("mouse_wheel_down", "down", function()
	if show and JelenOldal == 3 then
		if isCursorOnBox(panelX+120, PanelY1+60, 320, 453) then
			if currentRowV < #myVehicles-(maxRowV-1) then
				currentRowV = currentRowV+1
			end
		end
	end
end)

bindKey("mouse_wheel_up", "down", function()
	if show and JelenOldal == 3 then
		if isCursorOnBox(panelX+120, PanelY1+60, 320, 453) then
			if currentRowV > 1 then
				currentRowV = currentRowV-1
			end
		end
	end
end)

bindKey("mouse_wheel_down", "down", function()
	if show and JelenOldal == 3 then
		if isCursorOnBox(panelX+Meretek[1]/2+105, PanelY1+60, 320, 453) then
			if currentRowI < #myInteriors-(maxRowI-1) then
				currentRowI = currentRowI+1
			end
		end
	elseif show and JelenOldal == 2 then
		if currentRowG < #groupMembers[groupId]-(maxRowG-1) then
			groupStartX, groupStartY = panelX+230+250, PanelY1+25-2
			if isCursorOnBox(groupStartX, groupStartY, 340, 2+15*22) then
				currentRowG = currentRowG+1
			end
		end
		
		if currentRowVehG < #groupVehicles[groupId]-(maxRowVehG-1) then
			groupStartX, groupStartY = groupVehicleX, groupVehicleY
			if isCursorOnBox(groupStartX, groupStartY, 340, 2+10*22) then
				currentRowVehG = currentRowVehG+1
			end
		end
	end
end)

bindKey("mouse_wheel_up", "down", function()
	if show and JelenOldal == 3 then
		if isCursorOnBox(panelX+Meretek[1]/2+105, PanelY1+60, 320, 453) then
			if currentRowI > 1 then
				currentRowI = currentRowI-1
			end
		end
	elseif show and JelenOldal == 2 then
		if currentRowG > 1 then
			groupStartX, groupStartY = panelX+230+250, PanelY1+25-2
			if isCursorOnBox(groupStartX, groupStartY, 340, 2+15*22) then
				currentRowG = currentRowG-1
			end
		end
		
		if currentRowVehG > 1 then
			groupStartX, groupStartY = groupVehicleX, groupVehicleY
			if isCursorOnBox(groupStartX, groupStartY, 340, 2+10*22) then
				currentRowVehG = currentRowVehG-1
			end
		end
	end
end)

bindKey("pgdn", "down", function()
	if show and JelenOldal == 6 then
		if selectedRank < 7 then
			selectedRank = selectedRank+1
		end
	elseif show and JelenOldal == 2 then
		if selectedGroup < #playerGroups then
			selectedGroup = selectedGroup+1
			selectedMember = 1
		end
	end
end)

bindKey("pgup",  "down", function()
	if show and JelenOldal == 6 then
		if selectedRank > 0 then
			selectedRank = selectedRank-1
		end
	elseif show and JelenOldal == 2 then
		if selectedGroup > 1 then
			selectedGroup = selectedGroup-1
			selectedMember = 1
		end
	end
end)

--[[bindKey("arrow_d", "down", function()
	if show and JelenOldal == 2 then
		if selectedGroupRank < 15 then
			selectedGroupRank = selectedGroupRank+1
		end
	end
end)

bindKey("arrow_u", "down", function()
	if show and JelenOldal == 2 then
		if selectedGroupRank > 1 then
			selectedGroupRank = selectedGroupRank-1
		end
	end
end)]] --- click

function confirmSlotFunction()
	roundedRectangle(Kepernyo[1]/2-80, Kepernyo[2]/2-45, 160, 65, tocolor(0, 0, 0, 140))
	
	dxDrawText("Slot ára: #2AABFD100 PP", Kepernyo[1], Kepernyo[2]/2-40, 0, 0, tocolor(255,255,255), 1, "clear", "center", "top", false, false, false, true)
	
	dxDrawRectangleButton(Kepernyo[1]/2-70, Kepernyo[2]/2-12, 65, 24, tocolor(124, 197, 118, 180), "Elfogad")
	dxDrawRectangleButton(Kepernyo[1]/2+5, Kepernyo[2]/2-12, 65, 24, tocolor(243, 85, 85, 180), "Elutasít")
end

function dxDrawRectangleButton(startX, startY, endX, endY, rgbColor, text)
	dxDrawRectangle(startX, startY, endX, endY, rgbColor, true)
	dxDrawText(text, startX, startY, startX+endX, startY+endY, tocolor(255,255,255), 1, "default-bold", "center", "center", false, false, true)
end

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end	
end

triggerServerEvent("setPedNextFightStyle", localPlayer, 4)
localPlayer:setData("fightStyle", 4)

setPedWalkingStyle(localPlayer, 118)
setTimer(function()
	setControlState("walk", true)
end, 500, 0)

showPlayerHudComponent("all", false)
showPlayerHudComponent("crosshair", true)

------------------------------------------------------------
-----------------------Shader Control-----------------------
------------------------------------------------------------

function shaderFajlEllenorzes()
	local file = xmlLoadFile ( "xml/settings.xml" )
	lencsefolt = ""
	egbolt = ""
	hdrertek = ""
	kontrasztertek = ""
	vizertek = ""
	jarmuertek = ""
	motionblur = ""
	if file then
		local data = xmlFindChild ( file, "konfiguracio", 0 )
		if data then
			local attrs = xmlNodeGetAttributes ( data )
			if attrs then
				lencsefolt = attrs.lencsefolt or ""
				egbolt = attrs.egbolt or ""
				hdrertek = attrs.hdrbe or ""
				kontrasztertek = attrs.kontraszt or ""
				vizertek = attrs.viz or ""
				jarmuertek = attrs.jarmuvek or ""
				motionblur = attrs.motionblur or ""
			end
			optionsTable[2][2] = ertekToBin(jarmuertek)
			
			optionsTable[3][2], optionsTable[4][2] = ertekToBin(vizertek) , ertekToBin(kontrasztertek)
			
			optionsTable[5][2], optionsTable[6][2] = ertekToBin(hdrertek) , ertekToBin(egbolt)
			
			optionsTable[7][2], optionsTable[8][2] = ertekToBin(lencsefolt), ertekToBin(motionblur)
					
		end
	else
		local RootNode = xmlCreateFile("xml/settings.xml","SocialGaming")
		local Newcode = xmlCreateChild(RootNode, "konfiguracio")
		xmlNodeSetAttribute(Newcode, "lencsefolt", "false")
		xmlNodeSetAttribute(Newcode, "egbolt", "false")
		xmlNodeSetAttribute(Newcode, "hdrbe", "false")
		xmlNodeSetAttribute(Newcode, "kontraszt", "false")
		xmlNodeSetAttribute(Newcode, "viz", "false")
		xmlNodeSetAttribute(Newcode, "jarmuvek", "false")
		xmlNodeSetAttribute(Newcode, "motionblur", "false")
		
		optionsTable[2][2] = 0
		optionsTable[3][2], optionsTable[4][2] = 0,0
		optionsTable[5][2], optionsTable[6][2] = 0,0
		optionsTable[7][2], optionsTable[8][2] = 0, 0
					
		xmlSaveFile(RootNode)
	end
end

function ertekToBin(ertek)
	if ertek == "true" then
		return 1
	else
		return 0
	end
end	

addEventHandler( "onClientResourceStart", getRootElement( ),
    function ( startedRes )
		--fetchGroups()
		--triggerServerEvent("requestGroups", localPlayer)
		
		shaderFajlEllenorzes()
	
		
		if optionsTable[3][2] > 0 then
			if not WaterShader then
				startWaterRefract()
			end		
		end				
		
		if optionsTable[4][2] > 0 then
			if not kontrasztShader then
				enableContrast(true)
			end		
		end		
		
		if optionsTable[5][2] > 0 then
			if not hdrShader then
				enableDetail()
			end	
		end	
		
		if optionsTable[6][2] > 0 then
			if not egboltShader then
				startShaderResource()
			end	
		end	
		
		if optionsTable[7][2] > 0 then
			if not lencsefoltShader then
				controlLencseFolt(true)
			end		
		end			
		if optionsTable[8][2] > 0 then
			if not lencsefoltShader then
				enableRadialBlur()
			end		
		end	
				
	end
);

function shaderFrissites()		
	-- Lencsefolt
	if optionsTable[7][2] > 0 then
		if not lencsefoltShader then
			lencsefoltShader = true
			controlLencseFolt(true)
		end
		xml_lencse = "true"
	else
		if lencsefoltShader then
			controlLencseFolt(false)
			lencsefoltShader = nil
		end
		xml_lencse = "false"
	end			
	-- Egbolt
	if optionsTable[6][2] > 0 then
		if not egboltShader then
			egboltShader = true
			startShaderResource()
		end
		xml_egbolt = "true"
	else
		if egboltShader then
			stopShaderResource()
			egboltShader = nil
		end
		xml_egbolt = "false"
	end		
	-- Kidolgozodttság
	if optionsTable[5][2] > 0 then
		if not hdrShader then
			hdrShader = true
			enableDetail()
		end
		xml_hdr = "true"
	else
		if hdrShader then
			disableDetail()
			hdrShader = nil
		end
		xml_hdr = "false"
	end	
	-- Kontraszt
	if optionsTable[4][2] > 0 then
		if not kontrasztShader then
			kontrasztShader = true
			enableContrast(true)
		end
		xml_kontraszt = "true"
	else
		if kontrasztShader then
			disableContrast()
			kontrasztShader = nil
		end
		xml_kontraszt = "false"
	end
	-- VizShader
	if optionsTable[3][2] > 0 then
		if not WaterShader then
			WaterShader = true
			startWaterRefract()
		end
		xml_watershader = "true"
	else
		if WaterShader then
			executeCommandHandler("waterrefrectstopfunction")
			WaterShader = nil
		end
		xml_watershader = "false"
	end
	-- Kocsi
	if optionsTable[2][2] > 0 then
		if not JarmuShader then
			JarmuShader = true
			startCarPaintReflect()
		end
		xml_jarmuertek = "true"
	else
		if JarmuShader then
			stopCarPaintReflect()
			JarmuShader = nil
		end
		xml_jarmuertek = "false"
	end	
	-- motionblur
	if optionsTable[8][2] > 0 then
		if not motiobblurShader then
			motiobblurShader = true
			enableRadialBlur()
		end
		xml_motiobblur = "true"
	else
		if motiobblurShader then
			disableRadialBlur()
			motiobblurShader = nil
		end
		xml_motiobblur = "false"
	end
	
	local RootNode = xmlCreateFile("xml/settings.xml","External_Gaming")
	local NewNode = xmlCreateChild(RootNode, "konfiguracio")
	xmlNodeSetAttribute(NewNode, "lencsefolt", xml_lencse)
	xmlNodeSetAttribute(NewNode, "egbolt", xml_egbolt)
	xmlNodeSetAttribute(NewNode, "hdrbe", xml_hdr)
	xmlNodeSetAttribute(NewNode, "kontraszt", xml_kontraszt)
	xmlNodeSetAttribute(NewNode, "viz", xml_watershader)
	xmlNodeSetAttribute(NewNode, "jarmuvek", xml_jarmuertek)
	xmlNodeSetAttribute(NewNode, "maxlatotavolas", xml_latotav)
	xmlNodeSetAttribute(NewNode, "motionblur", xml_motiobblur)
	xmlSaveFile(RootNode)
end
----------------------------------------------------------------

--- duty skin állítás
local showFactions = false
local showSkins = false

addCommandHandler("dutyskin", function()
	if localPlayer:getData("loggedin") and not showSkins and getElementInterior(localPlayer) == 15 then 
		if #playerGroups < 1 then return end
		
		showFactions = not showFactions
		if showFactions then
			fetchGroups()
			triggerServerEvent("requestGroups", localPlayer)
		end
	end
end)

function renderFactionList()
	if showFactions then
		dxDrawRectangle(Kepernyo[1]/2-100, Kepernyo[2]/2-150, 200, #playerGroups*22+18, tocolor(0,0,0,220))
		
		for key = 1, #playerGroups do
			local groupId = playerGroups[key]
			local forX, forY = Kepernyo[1]/2-90, Kepernyo[2]/2-140+(key-1)*22
			
			if isCursorOnBox(forX, forY, 180, 20) then
				dxDrawRectangle(forX, forY, 180, 20, tocolor(124,197,118,170))
			end
		
			dxDrawRectangleButton(forX, forY, 180, 20, tocolor(255,255,255,20), groups[groupId]["name"])
		end
	end
end
addEventHandler("onClientRender", root, renderFactionList)

addEventHandler("onClientClick", root, function(button, state)
	if localPlayer:getData("loggedin") and showFactions then
		if button == "left" and state == "down" then
			for key = 1, #playerGroups do
				local forX, forY = Kepernyo[1]/2-90, Kepernyo[2]/2-140+(key-1)*22
				
				if isCursorOnBox(forX, forY, 180, 20) then
					groupIdForSkins = playerGroups[key]
					showFactions = false
					showSkins = true
					
					updateDutySkin()
				end
			end			
		end
	end
end)

local dutySkins = {
  --[id] = {skinid1, skinid2, stb..}
	[7] = {265, 266, 267, 280, 281}, --- pd
	[8] = {272, 274, 275, 276},	--- mentő
	[9] = {282, 283, 287, 288}, --- sherrif
	[10] = {285}, --- swat
	[11] = {50, 57, 58}, --- mechanic
	[12] = {163, 164, 165, 166}, --- fbi
	[13] = {225, 7}, --- taxi
	[28] = {89, 54, 199, 87, 88}, --- taxi
	[15] = {173, 174, 175, 176, 177, 308}, --- olasz gecik
	[16] = {124, 125, 126, 127, 128}, --- piru
	[26] = {108, 109, 114, 115, 116}, --- crip
	[18] = {117, 118, 120, 121, 122}, --- torosyan g.
	[19] = {105, 106, 107}, --- dean niggerek
	[29] = {217, 227, 228, 295, 294, 290}, --- los pollos
	[31] = {102, 103, 104, 105, 106}, --- orosz
	[22] = {69, 70, 71, 72, 73}, --- green side
	[24] = {231, 232, 235, 229}, --- paskals (háromszög) mc
	[14] = {123, 132, 154, 186, 187} ,--- paskals (háromszög) mc
}

function updateDutySkin()
	if not dutyPed or not isElement(dutyPed) then
		setCameraMatrix(212.9947052002, -107.92009735107, 1006.0772705078, 213.97711181641, -107.91326141357, 1005.890625)
		
		dutyPed = createPed(dutySkins[groupIdForSkins][1], 214.80674743652, -107.90746307373, 1005.1328125)
		setElementInterior(dutyPed, 15)
		setElementDimension(dutyPed, 77)
		setElementRotation(dutyPed, 0, 0, 90)
		
		selectedSkin = 1
	end
end

bindKey("arrow_l", "down", function()
	if isElement(dutyPed) then
		if selectedSkin > 1 then
			selectedSkin = selectedSkin-1
			setElementModel(dutyPed, dutySkins[groupIdForSkins][selectedSkin])
		end
	end
end)

bindKey("arrow_r", "down", function()
	if isElement(dutyPed) then
		if selectedSkin < #dutySkins[groupIdForSkins] then
			selectedSkin = selectedSkin+1
			setElementModel(dutyPed, dutySkins[groupIdForSkins][selectedSkin])
		end
	end
end)

bindKey("backspace", "down", function()
	if isElement(dutyPed) then
		setCameraTarget(localPlayer)
		destroyElement(dutyPed)
		dutyPed = false
		showSkins = false
	end
end)

function setSelectedDutyskin()
	if isElement(dutyPed) then
		setCameraTarget(localPlayer)
		destroyElement(dutyPed)
		dutyPed = false
		showSkins = false
		
		triggerServerEvent("updateDutySkin", localPlayer, groupIdForSkins, dutySkins[groupIdForSkins][selectedSkin])
		infobox("Sikeresen megváltoztattad a dutyskined", 1)
	end
end

bindKey("enter", "down", setSelectedDutyskin)
setTimer(function()
	if not bindKey("enter", "down", setSelectedDutyskin) then
		bindKey("enter", "down", setSelectedDutyskin)
	end
end, 1000, 0)

addEvent("onSetNextFightStyle", true)
addEventHandler("onSetNextFightStyle", getRootElement(),
    function(style)
        setPedNextFightStyle(style) -- This is where the client function is called
    end
)
