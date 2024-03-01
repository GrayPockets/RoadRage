--=================================================================================================================
--	Buildable Roads - UI Script
--  By Zegangani
--=================================================================================================================
print("Zegangani's Buildable Roads - UI Script loaded!");

--===========================================================================================
--	InsertUI
--===========================================================================================
function InsertUI()
	if not ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack") then return end

	pUnitPanelBaseContainer	= ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
	pUnitPanelBaseContainer:AddChildAtIndex(Controls.BuildableRoadButtonGrid, 1)

	RefreshBuildRoadButton();
end

--===========================================================================================
--	OnBuildRoadButtenClicked
--===========================================================================================
function OnBuildRoadButtenClicked(iPlayerID, iUnitID, pUnit, iPlotX, iPlotY, bIndustrialRoad)
	if pUnit~= nil then
		local tParams = {}
        tParams.playerID = iPlayerID;
        tParams.unitID = iUnitID;
        tParams.plotX = iPlotX;
		tParams.plotY = iPlotY;
		tParams.buildCharges = pUnit:GetBuildCharges()
		tParams.industrialRoad = bIndustrialRoad
        tParams.OnStart = "OnZegaBuildRoad";
    
		UI.RequestPlayerOperation(iPlayerID, PlayerOperations.EXECUTE_SCRIPT, tParams);
	end
end

--===========================================================================================
--	RefreshBuildRoadButton
--===========================================================================================
function RefreshBuildRoadButton(uTypeName, HasRoad, bHide)
	if uTypeName == "UNIT_BUILDER" or uTypeName == "UNIT_MILITARY_ENGINEER" or uTypeName == "UNIT_ROMAN_LEGION"
		or uTypeName == "UNIT_RURCOM_FARMER" or uTypeName == "UNIT_RURCOM_FISHER" or uTypeName == "UNIT_RURCOM_MINER" then -- City-Lights
		if HasRoad then
			Controls.BuildableRoadButtonGrid:SetHide(false);
		else
			Controls.BuildableRoadButtonGrid:SetHide(true);
		end
	elseif bHide==true then
		Controls.BuildableRoadButtonGrid:SetHide(true);
	else
		Controls.BuildableRoadButtonGrid:SetHide(true);
	end
end

--===========================================================================================
--	BuildableRoad_OnUnitMoved
--===========================================================================================
function BuildableRoad_OnUnitMoved(iPlayerID, iUnitID, iPlotX, iPlotY)
	local iLocationX = iPlotX
	local iLocationY = iPlotY
	if (iPlayerID == Game.GetLocalPlayer()) and (iLocationX==nil or iLocationY== nil) then
		local pPlayer = Players[iPlayerID]
		local pSelectedUnit : table = UI.GetHeadSelectedUnit();
		if(pSelectedUnit ~= nil and pSelectedUnit:GetID() == iUnitID)then
			iLocationX = pSelectedUnit:GetX()
			iLocationY = pSelectedUnit:GetY()
		end
	end
	
	BuildableRoad_OnUnitSelectionChanged(iPlayerID, iUnitID, iLocationX, iLocationY, nil, nil)
end

--===========================================================================================
--	BuildableRoad_OnUnitSelectionChanged
--===========================================================================================
function BuildableRoad_OnUnitSelectionChanged(iPlayerID, iUnitID, iLocationX, iLocationY, iLocationZ, isSelected)
	if (not Controls) or (not Controls.BuildableRoadButton) or (not pUnitPanelBaseContainer) then 
		return
	else
		Controls.BuildableRoadButtonGrid:SetHide(true)
	end
	
	Controls.BuildableRoadButtonGrid:SetHide(true)
	
	if isSelected == nil then
		local pUnitSelected = UI.GetHeadSelectedUnit();
		local bIsUnitSelected = pUnitSelected ~= nil
		
		if bIsUnitSelected and (iLocationX~= nil and iLocationY~=nil) then -- Correct Nil error
			local iSelectedPlayerID = pUnitSelected:GetOwner()
			local iSelectedUnitID = pUnitSelected:GetID()
			local iSelectedLocationX = pUnitSelected:GetX()
			local iSelectedLocationY = pUnitSelected:GetY()
			if ( iPlayerID == iSelectedPlayerID and iUnitID == iSelectedUnitID and  iLocationX == iSelectedLocationX and iLocationY == iSelectedLocationY ) then
				isSelected = true
			elseif ( iSelectedPlayerID == Game.GetLocalPlayer() ) then
				isSelected = bIsUnitSelected
				iPlayerID = iSelectedPlayerID
				iUnitID = iSelectedUnitID
				iLocationX = iSelectedLocationX
				iLocationY = iSelectedLocationY
			end
		else
			return
		end
	end
	
	if (isSelected) then
		if iPlayerID == Game.GetLocalPlayer() then 
			local pPlayer = Players[iPlayerID]
			local pUnit = pPlayer:GetUnits():FindID(iUnitID);
			local uTypeName =  GameInfo.Units[pUnit:GetUnitType()].UnitType;
			
			if pUnit ==nil then
				return
			end
			
			if uTypeName == "UNIT_BUILDER" or uTypeName == "UNIT_MILITARY_ENGINEER" or uTypeName == "UNIT_ROMAN_LEGION"
				or uTypeName == "UNIT_RURCOM_FARMER" or uTypeName == "UNIT_RURCOM_FISHER" or uTypeName == "UNIT_RURCOM_MINER" then -- City-Lights
				
				if pUnit:GetMovesRemaining() <= 0 then 
					return
				end
				
				local pPlot	:table = Map.GetPlot(iLocationX, iLocationY);
				
				if pPlot:IsWater() == true then 
					return
				end
				
				local iCurrentOriginalPlayerEra = pPlayer:GetEra()
				local sEraType = GameInfo.Eras[iCurrentOriginalPlayerEra].EraType
				local sRailRoadPrereqTech = GameInfo.Routes_XP2["ROUTE_RAILROAD"]
				local bHasRailRoadTech = false
				if sRailRoadPrereqTech then
					local bHasTech = pPlayer:GetTechs():HasTech(GameInfo.Technologies[sRailRoadPrereqTech.PrereqTech].Index);
					bHasRailRoadTech = bHasTech
					if (iCurrentOriginalPlayerEra > 5 or sEraType == "ERA_MODERN") and bHasTech == false then
						return
					end
				end
				
				if bHasRailRoadTech == false and iCurrentOriginalPlayerEra < 6 and sEraType ~= "ERA_MODERN" then
					return
				end
				
				local bIndustrialRoad = false
				if bHasRailRoadTech == true and sEraType == "ERA_INDUSTRIAL" then
					bIndustrialRoad = true
				end
				
				local iPlotOwnerID = pPlot:GetOwner();
				if iPlotOwnerID ~= nil then
					if iPlotOwnerID ~= -1 and iPlotOwnerID ~= iPlayerID then
						local pOtherPlayerConfig = PlayerConfigurations[iPlotOwnerID];
						local isMinorCiv = pOtherPlayerConfig:GetCivilizationLevelTypeID() == CivilizationLevelTypes.CIVILIZATION_LEVEL_CITY_STATE;
						if (isMinorCiv) then
							local pOtherPlayer = Players[iPlotOwnerID];
							local pOtherPlayerInfluence	= pOtherPlayer:GetInfluence();
							if pOtherPlayerInfluence then
								local iSuzerainID		= pOtherPlayerInfluence:GetSuzerain();
								if iSuzerainID == iPlayerID then
									Controls.BuildableRoadButtonGrid:SetHide(false)
								else
									return
								end
							else
								return
							end
						else
							return
						end
					elseif iPlotOwnerID == -1 then
						Controls.BuildableRoadButtonGrid:SetHide(false)
					end
				else
					return
				end
				
				Controls.BuildableRoadButtonGrid:SetHide(false)
				Controls.BuildableRoadButton:SetAlpha(0.75);
				Controls.BuildableRoadButtonGrid:SetDisabled(false)
				
				local pPlayerTreasury	= pPlayer:GetTreasury();
				-- local iGoldBalance = math.floor(pPlayerTreasury:GetGoldBalance()); -- Removed cost
				
				if bIndustrialRoad == true then
					Controls.BuildableRoadButton:SetToolTipString(Locale.Lookup("LOC_ZEGA_UPGRADE_ROAD_TO_INDUSTRIAL_ROAD"));
				else
					Controls.BuildableRoadButton:SetToolTipString(Locale.Lookup("LOC_ZEGA_UPGRADE_ROAD_TO_MODERN_ROAD"));
				end
				
				local HasRoad				= pPlot:IsRoute();
				local routeInfo = GameInfo.Routes[pPlot:GetRouteType()];
				
				if HasRoad then -- and iGoldBalance >= 20 then -- Removed cost
					if (bIndustrialRoad == false and routeInfo.RouteType ~= "ROUTE_MODERN_ROAD" and routeInfo.RouteType ~="ROUTE_RAILROAD")
						or (bIndustrialRoad == true and routeInfo.RouteType ~= "ROUTE_INDUSTRIAL_ROAD" and routeInfo.RouteType ~= "ROUTE_MODERN_ROAD" and routeInfo.RouteType ~= "ROUTE_RAILROAD") then
						Controls.BuildableRoadButton:SetAlpha(1.0);
						Controls.BuildableRoadButton:RegisterCallback( Mouse.eLClick, function() OnBuildRoadButtenClicked(iPlayerID, iUnitID, pUnit, iLocationX, iLocationY, bIndustrialRoad); end );
					else
						Controls.BuildableRoadButtonGrid:SetHide(true)
					end
				else -- elseif HasRoad == false and iGoldBalance >= 20 then -- Removed cost
					if bIndustrialRoad == true then
						Controls.BuildableRoadButton:SetToolTipString(Locale.Lookup("LOC_ZEGA_BUILD_INDUSTRIAL_ROAD"));
					else
						Controls.BuildableRoadButton:SetToolTipString(Locale.Lookup("LOC_ZEGA_BUILD_MODERN_ROAD"));
					end
					Controls.BuildableRoadButton:SetAlpha(1.0);
					Controls.BuildableRoadButton:RegisterCallback( Mouse.eLClick, function() OnBuildRoadButtenClicked(iPlayerID, iUnitID, pUnit, iLocationX, iLocationY, bIndustrialRoad); end );
				end
				--else -- Removed cost
				--	Controls.BuildableRoadButton:SetAlpha(0.75);
				--	Controls.BuildableRoadButton:SetDisabled(true)
				--	Controls.BuildableRoadButtonGrid:SetDisabled(true)
				--	Controls.BuildableRoadButton:SetToolTipString(Locale.Lookup("LOC_ZEGA_BUILDABLE_ROAD_INSUFFICIENT_GOLD"));
				--end
			end
		end
	end
end

--===========================================================================================
--	Initialize
--===========================================================================================
function Initialize()
	InsertUI()
	
	Events.UnitSelectionChanged.Add( BuildableRoad_OnUnitSelectionChanged );
	--Events.UnitMoved.Add (BuildableRoad_OnUnitMoved);
	Events.UnitMoveComplete.Add(BuildableRoad_OnUnitMoved)
	Events.UnitMovementPointsChanged.Add( BuildableRoad_OnUnitMoved );
end

Events.LoadGameViewStateDone.Add(Initialize)

--=================================================================================================================
--=================================================================================================================