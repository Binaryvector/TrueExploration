
local FilterMenu = {}
TrueExplor = TrueExplor or {}
TrueExplor.filterMenu = FilterMenu

function FilterMenu:Initialize()
	local lang = TrueExplor.lang
	
	ESO_Dialogs["CLEAR_EXPLORATION"] =
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title =
		{
			text = lang.clearTitle,
		},
		mainText =
		{
			text = lang.clearBody,
		},
		buttons =
		{
			[1] =
			{
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					TrueExplore:ClearDataForCurrentMap()
				end,
			},
			[2] =
			{
				text = SI_DIALOG_CANCEL,
			},
		}
	}
	
	
	local consolePanels = {
		GAMEPAD_WORLD_MAP_FILTERS.pvePanel,
		GAMEPAD_WORLD_MAP_FILTERS.pvpPanel,
		GAMEPAD_WORLD_MAP_FILTERS.imperialPvPPanel}
	
	local function ToggleFunction(data)
		TrueExplor:SetCompletelyDiscoverForCurrentMap(data.currentValue)
	end
	
	local function ToggleDebugFunction(data)
		TrueExplor:SetDebugEnabled(data.currentValue)
	end
	
	local function ClearFunction(data)
		if not data.currentValue then return end
		ZO_Dialogs_ShowPlatformDialog("CLEAR_EXPLORATION", {})
	end
	
	local function NarrationText(entryData, entryControl)
		return ZO_FormatToggleNarrationText(entryData.text, entryData.currentValue)
	end
	
	for _, panel in pairs(consolePanels) do
		ZO_PreHook(panel, "PostBuildControls", function(panel)
			local text = TrueExplor.lang.discoverMap
			local checkBox = ZO_GamepadEntryData:New(text)
			local info = 
			{
				name = text,
				onSelect = ToggleFunction,
				showSelectButton = true,
				narrationText = NarrationText,
			}
			checkBox:SetDataSource(info)
			local mapId = GetCurrentMapId()
			local discoveryData = TrueExplor:GetDiscoveryDataForMapId(mapId)
			checkbox.currentValue = discoveryData:IsCompletelyDiscovered()
			panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxTemplate", checkBox)
			
			
			local text = TrueExplor.lang.clearMap
			local checkBox = ZO_GamepadEntryData:New(text)
			local info = 
			{
				name = text,
				onSelect = ClearFunction,
				showSelectButton = false, --true,
				narrationText = NarrationText,
			}
			checkBox:SetDataSource(info)
			checkbox.currentValue = false
			panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxTemplate", checkBox)
			
			local text = TrueExplor.lang.debugCheckbox
			local checkBox = ZO_GamepadEntryData:New(text)
			local info = 
			{
				name = text,
				onSelect = ToggleDebugFunction,
				showSelectButton = true,
				narrationText = NarrationText,
			}
			checkBox:SetDataSource(info)
			local mapId = GetCurrentMapId()
			checkbox.currentValue = TrueExplor:IsDebugEnabled()
			panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxTemplate", checkBox)
		end)
	end
	
end
