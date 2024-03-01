--=================================================================================================================
--=================================================================================================================
--	Removable Roads UI Script
--  By Zegangani, with special Thanks to Technoluddute, whose "What Did I Promise?" Mod was a helpful
--  in making this mod
--=================================================================================================================
--=================================================================================================================
print("Zegangani's Removable Roads - UI Script loaded!");

--===========================================================================================
--	InsertUI
--===========================================================================================
function InsertUI()
	
	if not ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack") then return end

	pUnitPanelBaseContainer	= ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
	pUnitPanelBaseContainer:AddChildAtIndex(Controls.RemovableRoadsButtonGrid, 1)

	RefreshRemoveRoadButton();
	
end

--===========================================================================================
--	OnRemoveRoadButtenClicked
--===========================================================================================
function OnRemoveRoadButtenClicked(iPlayerID, iUnitID, pUnit, iPlotX, iPlotY)
	if pUnit~= nil then
		local tParams = {}
        tParams.playerID = iPlayerID;
        tParams.unitID = iUnitID;
        tParams.plotX = iPlotX;
		tParams.plotY = iPlotY;
        tParams.OnStart = "OnZegaRemoveRoad";
    
		UI.RequestPlayerOperation(iPlayerID, PlayerOperations.EXECUTE_SCRIPT, tParams);
		
		RefreshRemoveRoadButton(false, false, true);
	end
end

--===========================================================================================
--	RefreshRemoveRoadButton
--===========================================================================================
function RefreshRemoveRoadButton(uTypeName, HasRoad, bHide)
	if uTypeName == "UNIT_BUILDER" or uTypeName == "UNIT_MILITARY_ENGINEER" or uTypeName == "UNIT_ROMAN_LEGION"
		or uTypeName == "UNIT_RURCOM_FARMER" or uTypeName == "UNIT_RURCOM_FISHER" or uTypeName == "UNIT_RURCOM_MINER" then -- City-Lights
		if HasRoad then
			Controls.RemovableRoadsButtonGrid:SetHide(false);
		else
			Controls.RemovableRoadsButtonGrid:SetHide(true);
		end
	elseif bHide==true then
		Controls.RemovableRoadsButtonGrid:SetHide(true);
	else
		Controls.RemovableRoadsButtonGrid:SetHide(true);
	end
end

--===========================================================================================
--	RefreshRemoveRoadButton
--===========================================================================================
function RemovableRoads_OnUnitMoved(iPlayerID, iUnitID, iPlotX, iPlotY)
	local iLocationX = iPlotX
	local iLocationY = iPlotY
	local bIsSelected = nil
	if (iPlayerID == Game.GetLocalPlayer()) then
		if (iLocationX==nil or iLocationY== nil) then
			local pSelectedUnit : table = UI.GetHeadSelectedUnit();
			if (pSelectedUnit ~= nil and pSelectedUnit:GetID() == iUnitID) then
				iLocationX = pSelectedUnit:GetX()
				iLocationY = pSelectedUnit:GetY()
				bIsSelected = true
			end
		else
			local pSelectedUnit : table = UI.GetHeadSelectedUnit();
			if (pSelectedUnit ~= nil and pSelectedUnit:GetID() == iUnitID) then
				bIsSelected = true
			end
		end
	end
	
	RemovableRoads_OnUnitSelectionChanged(iPlayerID, iUnitID, iLocationX, iLocationY, nil, bIsSelected)
end

--===========================================================================================
--	RemovableRoads_OnUnitSelectionChanged
--===========================================================================================
function RemovableRoads_OnUnitSelectionChanged(iPlayer, iUnitId, iLocationX, iLocationY, iLocationZ, isSelected)
	if (not Controls) or (not Controls.RemovableRoadsButton) or (not pUnitPanelBaseContainer) then 
		Controls.RemovableRoadsButtonGrid:SetHide(true)
		return
	else
		Controls.RemovableRoadsButtonGrid:SetHide(true)
	end

	if (isSelected) then
		if iPlayer == Game.GetLocalPlayer() then 
			local pPlayer = Players[iPlayer]
			local pUnit = pPlayer:GetUnits():FindID(iUnitId);
			local uTypeName =  GameInfo.Units[pUnit:GetUnitType()].UnitType;
			
			if pUnit == nil then
				return
			end
			
			if pUnit:GetMovesRemaining() <= 0 then 
				return
			end
			
			if uTypeName == "UNIT_BUILDER" or uTypeName == "UNIT_MILITARY_ENGINEER" or uTypeName == "UNIT_ROMAN_LEGION"
				or uTypeName == "UNIT_RURCOM_FARMER" or uTypeName == "UNIT_RURCOM_FISHER" or uTypeName == "UNIT_RURCOM_MINER" then -- City-Lights
				Controls.RemovableRoadsButtonGrid:SetHide(false)
				Controls.RemovableRoadsButton:RegisterCallback( Mouse.eLClick, function() OnRemoveRoadButtenClicked(iPlayer, iUnitId, pUnit, iLocationX, iLocationY); end );
				
				local pPlot	:table = Map.GetPlot(iLocationX, iLocationY);
				local HasRoad				= pPlot:IsRoute();
				RefreshRemoveRoadButton(uTypeName, HasRoad)
			end
		end
	end
end

--===========================================================================================
--	Initialize
--===========================================================================================
function Initialize()
	InsertUI()
	
	Events.UnitSelectionChanged.Add( RemovableRoads_OnUnitSelectionChanged );
	--Events.UnitMoved.Add (BuildableModernRoad_OnUnitMoved);
	Events.UnitMoveComplete.Add(RemovableRoads_OnUnitMoved)
	Events.UnitMovementPointsChanged.Add( RemovableRoads_OnUnitMoved );
end

Events.LoadGameViewStateDone.Add(Initialize)
--=================================================================================================================
--=================================================================================================================