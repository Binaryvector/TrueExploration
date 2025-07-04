
TrueExplor = TrueExplor or {}
TrueExplor.lang = TrueExplor.lang or {}

local language = {
	empty = "Fully Hidden",
	filled = "Discover near POI",
	newMapTitle = "Start fully hidden?",
	newMapBody = "Do you want to start with a completely hidden map?\nOr should areas near completed point of interests (quests, wayshrines, etc.) be discovered?",
	debugCheckbox = "TrueExploration Debug Mode",
	init = "Initialization",
	initBody = "The 'True Exploration' Add-On cannot know which areas you explored before the Add-On was installed.\nYou have two options how to initialize the addon:\nA) Completely hide all maps until you explore them again.\nB) Let the Add-On guess which areas you explored already by using your completed point of interests (quests, skyshards, wayshrines, etc.)",
	guessExploration = "Guess exploration",
	clearTitle = "Confirm Reset",
	clearBody = "Do you want to reset exploration data for this map?\nThis can NOT be undone.",
	clearMap = "Reset map exploration",
	discoverMap = "Discover entire map",
	clearGuide = "There you also have the option to reset map exploration'. During this reset, you can select to completely hide the map, or to discover any area close to a completed point of interest (wayshrine, quest, city, etc.).",
	guide = "The Add-On cannot know which areas you explored before the Add-On was installed. You can manually uncover maps as follows:\n1) Open the map,\n2) Select 'Options' and switch to 'Filters',\n3) Scroll down to 'Discover entire map'.",
	noknowledge = "The Add-On cannot know which areas your explored before the Add-On was installed.",
	noknowledgeDesc = "When viewing a map for the first time, there are two options:\nA) 'Guess explored areas' = ON\nLet the Add-On guess which areas you explored already by using your completed quests, skyshards, wayshrines, etc.\nB) 'Guess explored areas' = OFF\nNo guessing. The Add-On completely hides all maps until you explore them again.",
	retroactive = "Guess explored areas",
	retroactiveDec = "The Add-On cannot know which areas your explored before the Add-On was installed. When viewing a map for the first time, there are two options:\n(*) 'Guess explored areas' = ON\nLet the Add-On guess which areas you explored already by using your completed quests, skyshards, wayshrines, etc.\n(*) 'Guess explored areas' = OFF\nNo guessing. The Add-On completely hides all maps until you explore them again.",
	--
	resetLabel = "This setting affects maps that are viewed for the first time. If you want to reset an already viewed map:\n1) Open the map you want to reset,\n2) Open the map's filter tab ('Options' => 'Filters'),\n3) Select 'Reset map exploration'.",
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
	discoveredDesc = "0 = map completely visible,\n255 = map completely hidden.",
	undiscovered = "Undiscovered Opacity",
	undiscoveredDesc = "0 = map completely visible,\n255 = map completely hidden.",
	
}

for type, string in pairs(language) do
	TrueExplor.lang[type] = string
end
