
TrueExplor = TrueExplor or {}
TrueExplor.lang = TrueExplor.lang or {}

local language = {
	debugCheckbox = "TrueExploration Debug Mode",
	clearTitle = "Confirm Deletion",
	clearBody = "Do you want to delete exploration data for this map?\nDeletion can NOT be reverted.",
	clearMap = "Delete map exploration"
	discoverMap = "Discover entire map",
	retroactive = "Guess explored areas",
	retroactiveDec = "The Add-On cannot know which areas your explored before the Add-On was installed.\n- If this setting is enabled, the Add-On will uncover areas near completed quests, skyshards, wayshrines, etc.\n- If this setting is disabled, all maps will start as completely undiscovered (hidden).",
	chatCommands = "Chat Commands (while map is open)",
	chatCommandsDesc = "/discover, /undiscover, /clearmap, /tedebug [0,1]",
	radiusSetting = "Radius Settings",
	dungeonRadius = "Dungeon Radius",
	dungeonRadiusDesc = "Number of tiles that can be discovered at once on a dungeon or delve map (map size <= 768)",
	townRadius = "Town Radius",
	townRadiusDesc = "Number of tiles that can be discovered at once on a town map (map size <= 1280)",
	islandRadius = "Island Radius",
	islandRadiusDesc = "Number of tiles that can be discovered at once on an island map (or large city) (map size <= 1536)",
	zoneRadius = "Zone Radius",
	zoneRadiusDesc = "Number of tiles that can be discovered at once on a zone map (map size <= 2048)",
	cyrodiilRadius = "Cyrodiil Radius",
	cyrodiilRadiusDesc = "Number of tiles that can be discovered at once on the Cyrodiil map (map size = 5120)",
	mapTypes = "Map Types",
		
	zone = "Enable Addon on zone maps",
	zoneDesc = "If NOT checked, zone maps will always be discovered.",
	subzone = "Enable Addon on subzone maps",
	subzoneDesc = "If NOT checked, subzone maps (dungeons, towns) will always be discovered.",
	graphicSettings = "Graphical Settings",
	discovered = "Discovered Opacity",
	discoveredDesc = "0 ~ map completely visible, 255 ~ map completely hidden.",
	undiscovered = "Undiscovered Opacity",
	undiscoveredDesc = "0 ~ map completely visible, 255 ~ map completely hidden.",
	
}

for type, string in pairs(language) do
	TrueExplor.lang[type] = string
end
