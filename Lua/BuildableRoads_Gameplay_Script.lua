--=================================================================================================================
--	Buildable Roads - Gameplay Script
--  By Zegangani
--=================================================================================================================
print("Zegangani's Buildable Roads - Gameplay Script!");

--===========================================================================================
--	OnBuildRoad
--===========================================================================================
function OnBuildRoad(playerID : number, params : table)
	local unitID = params.unitID
	local plotX = params.plotX
	local plotY = params.plotY
	local bIndustrialRoad = params.industrialRoad
	local iBuildCharges = params.buildCharges
	
	if playerID == nil then return end
	
	local pPlot	:table = Map.GetPlot(plotX, plotY);
	local pUnit = UnitManager.GetUnit(playerID, unitID);
	
	RouteBuilder.SetRouteType(pPlot, RouteTypes.NONE);
	
	if bIndustrialRoad == false then
		local routeInfo = GameInfo.Routes["ROUTE_MODERN_ROAD"];
		if (routeInfo ~= nil and routeInfo.MovementCost ~= nil and routeInfo.Name ~= nil) then
			RouteBuilder.SetRouteType(pPlot, routeInfo.Index);
		end
	else
		local routeInfo = GameInfo.Routes["ROUTE_INDUSTRIAL_ROAD"];
		if (routeInfo ~= nil and routeInfo.MovementCost ~= nil and routeInfo.Name ~= nil) then
			RouteBuilder.SetRouteType(pPlot, routeInfo.Index);
		end
	end
	
	--local pPlayer = Players[playerID] -- Removed cost
	--pPlayer:GetTreasury():ChangeGoldBalance(-20); -- Removed cost
	
	UnitManager.FinishMoves(pUnit);
end

GameEvents.OnZegaBuildRoad.Add(OnBuildRoad);

--=================================================================================================================
--=================================================================================================================