if not TrueExplor then
	TrueExplor = {}
end
local TrueExplor = _G["TrueExplor"]

-- settings
TrueExplor.total_units = 48

local defaultSettings = {
	discoveredColor = { 1, 1, 1, 0 }, -- rgba format
	undiscoveredColor = { 1, 1, 1, 1 },
	dontHideMapTypes = {
		--MAPTYPE_SUBZONE, --cities but some dungeons as well
		[MAPTYPE_COSMIC] = true,
		[MAPTYPE_WORLD] = true,
	},
	radiusForMapSize = {
		[768] = 3, --dungeon
		[1280] = 2, --city
		[1536] = 1, --starter island, larger cities
		[2048] = 0, --zones
		[5120] = 0,--96, -- cyrodiil (more than 50 panels will result in too much lag)
	}
}

--internal stuff
TrueExplor.radius = 1
TrueExplor.dataVersion = 1
local UPDATE_DELAY_IN_MS = 1000 --num of milliseconds until addon tries to discover current position
-- to prevent the save file from bloating up, i save the discovered flag from multiple units as bits in a large integer.
TrueExplor.unitsPerNumber = 31 --number of units to be saved in one integer
-- eso can't save integers larger than 2^31 (or they'll become floats and i lose the lsb information)
TrueExplor.lastTime = 0

-- GetUniversallyNormalizedMapInfo


function TrueExplor:IsCurrentMapSkipped()
	return self.settings.dontHideMapTypes[GetMapType()]
end

function TrueExplor:RefreshRadius()
	local numTiles = GetMapNumTiles()
	-- might not be loaded yet!
	local tileSize = ZO_WorldMapContainer1:GetTextureFileDimensions()

	if tileSize ~= nil and numTiles ~= nil then
		local mapSize = tileSize * numTiles
		local smallestSize = math.huge
		local r
		for size, radius in pairs(self.settings.radiusForMapSize) do
			if size < smallestSize and size >= mapSize then
				smallestSize = size
				r = radius
			end
		end
		self.tileDisplay:SetRadius(r)
		return
	end
	self.tileDisplay:SetRadius(1)
end

function TrueExplor:Refresh()
	if not (ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded()) then
		self.needUpdate = true
			return
	end
	self:RefreshRadius()
	local mapId = GetCurrentMapId()
	local discoveryData = self:GetDiscoveryDataForMapId(mapId)
	assert(discoveryData)
	self.tileDisplay:SetDiscoveryData(discoveryData)
	self.tileDisplay:Refresh()
end

function TrueExplor:GetDiscoveryDataForMapId(mapId)
	local discoveryData = self.loadedData[mapId]
	if not discoveryData then
		local data = self.maps[mapId]
		if not data then
			data = self.maps[GetMapTileTexture()] or {}
			self.maps[GetMapTileTexture()] = nil
			self.maps[mapId] = data
		end
		discoveryData = self.discoveryData:Load(data)
		self.loadedData[mapId] = discoveryData
	end
	return discoveryData
end

function TrueExplor:DiscoverForMapId(tileX, tileY, mapId)
	local discoveryData = self:GetDiscoveryDataForMapId(mapId)
	discoveryData:Discover(tileX, tileY)
end

function TrueExplor:BuildHierarchy()
	local lastMapId = GetCurrentMapId()
	local newParentMapId
	
	while (MapZoomOut() == SET_MAP_RESULT_MAP_CHANGED) do
		newParentMapId = GetCurrentMapId()
		if lastMapId == newParentMapId then
			break
		end
		self.hierarchy[lastMapId] = newParentMapId
	end
	SetMapToPlayerLocation()
end

function TrueExplor:DiscoverCurrentLocation()
	local originalMapId = GetCurrentMapId()
	SetMapToPlayerLocation()
	
	self:BuildHierarchy()
	local mapId = GetCurrentMapId()
	local parentMapId = self.hierarchy[mapId]
	if not parentMapId then
		self:BuildHierarchy()
		parentMapId = self.hierarchy[mapId]
	end
	
	local x, y = GetMapPlayerPosition("player")
	local discoveredTileX = zo_floor(x * TrueExplor.total_units)
	local discoveredTileY = zo_floor(y * TrueExplor.total_units)
	
	local offsetX, offsetY, scaleX, scaleY = GetUniversallyNormalizedMapInfo(mapId)
	
	local globalX = x * scaleX + offsetX
	local globalY = y * scaleY + offsetY
	
	local tileX, tileY
	local wasAnyChanged, wasChanged
	--d(mapId)
	while mapId do
		--d("uncover " .. mapName)
		offsetX, offsetY, scaleX, scaleY = GetUniversallyNormalizedMapInfo(mapId)
		-- get local coords
		x = (globalX - offsetX) / scaleX
		y = (globalY - offsetY) / scaleY
		--d(x,y)
		-- get tile coords
		tileX = zo_floor(x * TrueExplor.total_units)
		tileY = zo_floor(y * TrueExplor.total_units)
		-- set to discovered
		wasChanged = self:DiscoverForMapId(tileX, tileY, mapId)
		if not wasChanged then
			break -- if nothing was discovered on small scale, we don't have to look at larger scale maps
		end
		wasAnyChanged = true
		-- get parent map and repeat
		mapId = self.hierarchy[mapId]
		--d(mapId == nil)
		--d(self.hierarchy[mapId])
	end
	
	if originalMapId ~= GetCurrentMapId() then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	elseif wasAnyChanged then
		if AUI_MapContainer or WORLD_MAP_FRAGMENT:IsShowing() then
			self.tileDisplay:OnDiscoveryStatusChanged(discoveredTileX, discoveredTileY)
		end
	end
end

function TrueExplor:Initialize()
	-- load save files
	self.save = ZO_SavedVars:New("TE_SavedVars", 1, "save", { maps = {} })
	self.maps = self.save.maps
	self.settings = ZO_SavedVars:New("TE_SavedVars", 1, "save", defaultSettings)
	
	self.hierarchy = {}
	self.loadedData = {}
	-- initialize options menu (see TrueExplorationOptions.lua)
	--TrueExplor.setupOptions()
	--self.settingsMenu:Initialize()
	self.tileDisplay:Initialize(ZO_WorldMapContainer, 0)--self.settings.radius)
	self.tileDisplay:SetColors(self.settings.discoveredColor, self.settings.undiscoveredColor)
	-- add debug chat commands
	SLASH_COMMANDS["/tedebug"] = TrueExplor.Debug
	SLASH_COMMANDS["/discover"] = TrueExplor.DiscoverAll
	SLASH_COMMANDS["/undiscover"] = TrueExplor.UndiscoverAll
	SLASH_COMMANDS["/clearmap"] = TrueExplor.ClearMap
	
	--if true then return end
	-- update the MapTile objects, when a new map is displayed
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:Refresh() end)
	
	-- there is a short blending animation, which resets the alpha values for the texture's vertices
	-- so let the worldmap appear instantly instead
	WORLD_MAP_FRAGMENT.Show = ZO_SimpleSceneFragment.Show
	WORLD_MAP_FRAGMENT.Hide = ZO_SimpleSceneFragment.Hide
	-- when the map is opened/closed, the tiles need to be refreshed
	local callback = function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			if AUI_MapContainer then
				self.tileDisplay:SetContainer(ZO_WorldMapContainer)
			end
			--TrueExplor.RefreshTiles()
		elseif newState == SCENE_HIDING then
			if AUI_MapContainer then
				self.tileDisplay:SetContainer(AUI_MapContainer)
			end
		end
	end
	local mapscene = SCENE_MANAGER:GetScene("worldMap")
	mapscene:RegisterCallback("StateChange", callback)
	mapscene = SCENE_MANAGER:GetScene("gamepad_worldMap")
	mapscene:RegisterCallback("StateChange", callback)
	----[[
	EVENT_MANAGER:RegisterForUpdate("TrueExploration", UPDATE_DELAY_IN_MS, function()
		if TrueExplor.needUpdate then
			if ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded() then
				TrueExplor.needUpdate = false
				TrueExplor:Refresh()
			else
				return
			end
		end
		
		if ZO_WorldMap_IsWorldMapShowing() then return end
		
		TrueExplor:DiscoverCurrentLocation()
	end)
	--]]--
	-- add zoom function for the tiles. when the map is zoomed into, the tiles need to scale as well
	local oldDimensions = ZO_WorldMapContainer.SetDimensions
	ZO_PreHook(ZO_WorldMapContainer, "SetDimensions", function(container, width, height, ...)
		if self.tileDisplay.container == container then
			self.tileDisplay:UpdateSize(width, height)
		end
	end)
	
end

EVENT_MANAGER:RegisterForEvent("TrueExploration", EVENT_ADD_ON_LOADED, function(_, addon)
	if addon ~= "TrueExploration" then
		return
	end
	TrueExplor:Initialize()
end)