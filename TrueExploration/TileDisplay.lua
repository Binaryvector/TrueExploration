
local TileDisplay = {}
TrueExplor = TrueExplor or {}
TrueExplor.tileDisplay = TileDisplay

function TileDisplay:Initialize(container, radius)
	self.parent = container:CreateControl(nil, CT_CONTROL)
	local composite = self.parent:CreateControl(nil, CT_TEXTURECOMPOSITE)
	composite:SetDrawLevel(2)
	composite:SetPixelRoundingEnabled(false)
	composite:SetTexture("EsoUI/Art/WorldMap/worldmap_map_background_512tile.dds")
	for y = 0, TrueExplor.total_units - 1 do
		for x = 0, TrueExplor.total_units - 1 do
			composite:AddSurface(
				x / TrueExplor.total_units,
				(x+1) / TrueExplor.total_units,
				y / TrueExplor.total_units,
				(y+1) / TrueExplor.total_units)
		end
	end
	self.composite = composite
	self.container = container
	self.hideAllControl = CreateControlFromVirtual(nil, container, "TE_MapTile")
	self.hideAllControl:SetHidden(true)
	self.controls = {}
	self.lastUnused = 0
	self.unusedControls = {}
	self.radius = radius
	
	self:SetContainer(container)
end

function TileDisplay:GetControl(x, y)
	local unit = x + y * TrueExplor.total_units
	local control = self.controls[unit]
	if control then return control end
	
	if self.lastUnused > 0 then
		control = self.unusedControls[self.lastUnused]
		self.lastUnused = self.lastUnused - 1
	else
		control = CreateControlFromVirtual(nil, self.parent, "TE_MapTile")
		control:SetPixelRoundingEnabled(false)
	end
	control:SetTextureCoords(
		x / TrueExplor.total_units,
		(x+1) / TrueExplor.total_units,
		y / TrueExplor.total_units,
		(y+1) / TrueExplor.total_units)
	local container = self.container
	local width, height = self.hideAllControl:GetDimensions()
	local controlWidth = width / TrueExplor.total_units
	local controlHeight = height / TrueExplor.total_units
	control:SetAnchor(TOPLEFT, container, TOPLEFT, (x-0.5) * controlWidth, (y-0.5) * controlHeight)
	control:SetDimensions(controlWidth, controlHeight)
	control:SetHidden(false)
	self.controls[unit] = control
	return control
end

function TileDisplay:SetDiscoveryData(discoveryData)
	self.discoveryData = discoveryData
	--self:Refresh()
end

function TileDisplay:SetRadius(radius)
	self.radius = radius
	--self:Refresh()
end

function TileDisplay:SetContainer(container, width, height)
	self.parent:SetParent(container)
	self.composite:SetAnchor(CENTER, container, TOPLEFT, 0, 0)
	self.hideAllControl:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
	self.container = container
	self:UpdateSize()
end

function TileDisplay:UpdateSize(width, height)
	local container = self.container
	if not (width and height) then
		width, height = container:GetDimensions()
	end
	self.hideAllControl:SetDimensions(width, height)
	local controlWidth = width / TrueExplor.total_units
	local controlHeight = height / TrueExplor.total_units
	local x, y
	for index, control in pairs(self.controls) do
		x = index % TrueExplor.total_units
		y = zo_floor(index / TrueExplor.total_units)
		control:SetAnchor(TOPLEFT, container, TOPLEFT, (x-0.5) * controlWidth, (y-0.5) * controlHeight)
		control:SetDimensions(controlWidth, controlHeight)
	end
	local index
	local composite = self.composite
	for y = 0, TrueExplor.total_units - 1 do
		for x = 0, TrueExplor.total_units - 1 do
			index = x + y * TrueExplor.total_units
			composite:SetInsets(index + 1,
				x * controlWidth, x * controlWidth, y * controlHeight, y * controlHeight)
		end
	end
	composite:SetDimensions(controlWidth, controlHeight)
end

function TileDisplay:RemoveAllControls()
	local lastUnused = self.lastUnused
	for _, control in pairs(self.controls) do
		control:SetHidden(true)
		lastUnused = lastUnused + 1
		self.unusedControls[lastUnused] = control
	end
	self.lastUnused = lastUnused
	ZO_ClearTable(self.controls)
end

function TileDisplay:OnDiscoveryStatusChanged(unitX, unitY)
	local discoveryData = self.discoveryData
	if discoveryData:IsCompletelyDiscovered() then
		return
	end
	local index, anyDiscovered, allDiscovered, control
	local composite = self.composite
	local topRow = {}
	local currentRow = {}
	local radius = self.radius
	local discoveredColor = self.discoveredColor
	local undiscoveredColor = self.undiscoveredColor
	
	local startX = zo_max(0, unitX - self.radius)
	local endX = zo_min(TrueExplor.total_units-1, unitX + self.radius + 1)
	
	if unitY - self.radius - 1 >= 0 then
		local y = unitY - self.radius - 1
		for x = startX - 1, endX do
			index = x + y * TrueExplor.total_units
			topRow[x] = discoveryData:IsAnyDiscoveredInRadius(x, y, radius)
		end
	end
	
	for y = zo_max(0, unitY - self.radius), zo_min(TrueExplor.total_units-1, unitY + self.radius + 1) do
		
		currentRow[startX - 1] = discoveryData:IsAnyDiscoveredInRadius(startX - 1, y, radius)
		for x = startX, endX do
			index = x + y * TrueExplor.total_units
			currentRow[x] = discoveryData:IsAnyDiscoveredInRadius(x, y, radius)
			anyDiscovered = currentRow[x] or currentRow[x-1] or topRow[x] or topRow[x-1]
			allDiscovered = currentRow[x] and currentRow[x-1] and topRow[x] and topRow[x-1]
			if anyDiscovered and not allDiscovered then
				composite:SetSurfaceHidden(index + 1, true)
				control = self:GetControl(x, y)
				self:RefreshControlForDiscoveryStatus(control, currentRow[x], currentRow[x-1], topRow[x], topRow[x-1])
			else
				composite:SetSurfaceHidden(index + 1, false)
				composite:SetColor(index + 1, unpack((allDiscovered and discoveredColor) or undiscoveredColor))
			end
		end
		topRow, currentRow = currentRow, topRow
	end
end

function TileDisplay:Refresh()
	self:RemoveAllControls()
	if self.discoveryData:IsCompletelyDiscovered() then 
		self:HideTiles()
		return
	end
	self.parent:SetHidden(false)
	local discoveredColor = self.discoveredColor
	local undiscoveredColor = self.undiscoveredColor
	local discoveryData = self.discoveryData
	local index, anyDiscovered, allDiscovered, control
	local composite = self.composite
	local topRow = {}
	local currentRow = {}
	local radius = self.radius
	for y = 0, TrueExplor.total_units - 1 do
		for x = 0, TrueExplor.total_units - 1 do
			index = x + y * TrueExplor.total_units
			currentRow[x] = discoveryData:IsAnyDiscoveredInRadius(x, y, radius)
			anyDiscovered = currentRow[x] or currentRow[x-1] or topRow[x] or topRow[x-1]
			allDiscovered = currentRow[x] and currentRow[x-1] and topRow[x] and topRow[x-1]
			if anyDiscovered and not allDiscovered then
				composite:SetSurfaceHidden(index + 1, true)
				control = self:GetControl(x, y)
				self:RefreshControlForDiscoveryStatus(control, currentRow[x], currentRow[x-1], topRow[x], topRow[x-1])
			else
				composite:SetSurfaceHidden(index + 1, false)
				composite:SetColor(index + 1, unpack((allDiscovered and discoveredColor) or undiscoveredColor))
			end
		end
		topRow, currentRow = currentRow, topRow
	end
end

function TileDisplay:RefreshControlForDiscoveryStatus(control, center, left, top, topleft)
	local discoveredColor = self.discoveredColor
	local hiddenColor = self.undiscoveredColor
	
	control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT, --1, 0, 0, 1)
		unpack(center and discoveredColor or hiddenColor))
	-- color of the tile's neigbors for gradient effect
	control:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT,
		unpack(left and discoveredColor or hiddenColor))
	control:SetVertexColors(VERTEX_POINTS_TOPRIGHT,
		unpack(top and discoveredColor or hiddenColor))
	control:SetVertexColors(VERTEX_POINTS_TOPLEFT,
		unpack(topleft and discoveredColor or hiddenColor))
end

function TileDisplay:SetColors(discoveredColor, undiscoveredColor)
	self.discoveredColor = discoveredColor
	self.undiscoveredColor = undiscoveredColor
	--self.hiddenColor:SetColor(unpack(undiscoveredColor))
	--self:Refresh()
end

-- set all tiles as hidden (so the entire map becomes visible)
function TileDisplay:HideTiles()
	self.parent:SetHidden(true)
	self.hideAllControl:SetHidden(true)
end
