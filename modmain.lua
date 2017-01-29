PrefabFiles = {
	"guude",
	"guude_none",
	"guudebee",
	"conifer"
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/guude.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/guude.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/guude.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/guude.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/guude_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/guude_silho.xml" ),

    Asset( "IMAGE", "bigportraits/guude.tex" ),
    Asset( "ATLAS", "bigportraits/guude.xml" ),
	
	Asset( "IMAGE", "images/map_icons/guude.tex" ),
	Asset( "ATLAS", "images/map_icons/guude.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_guude.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_guude.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_guude.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_guude.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_guude.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_guude.xml" ),
	
	Asset( "IMAGE", "images/names_guude.tex" ),
    Asset( "ATLAS", "images/names_guude.xml" ),
	
    Asset( "IMAGE", "bigportraits/guude_none.tex" ),
    Asset( "ATLAS", "bigportraits/guude_none.xml" ),

}

GLOBAL.GuudeMod = modname

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.guude = "The Reluctant Leader"
STRINGS.CHARACTER_NAMES.guude = "Guude"
STRINGS.CHARACTER_DESCRIPTIONS.guude = "*Overdosed on the Insect Swarm plasmid\n*Has a loyal companion\n*Is very nervous"
STRINGS.CHARACTER_QUOTES.guude = "\"I like things hard\""

-- Custom speech strings
STRINGS.CHARACTERS.GUUDE = require "speech_guude"

-- The character's name as appears in-game 
STRINGS.NAMES.GUUDE = "Guude"

STRINGS.NAMES.CONIFER = "Conifer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CONIFER = "It's Guude's Cat, Conifer!"
STRINGS.CHARACTERS.GUUDE.DESCRIBE.CONIFER = "He's a Maine Catcoon"

AddMinimapAtlas("images/map_icons/guude.xml")

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("guude", "MALE")

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_B, function()
	local player=GLOBAL.ThePlayer
	if player and player.prefab=="guude"
    and not GLOBAL.IsPaused() and not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL) and not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
    and not player.HUD:IsChatInputScreenOpen() and not player.HUD:IsConsoleScreenOpen()then
		SendModRPCToServer(MOD_RPC[modname]["Beeeees"])
	end
end)

AddModRPCHandler(modname, "Beeeees", function(player)
	
	local target = GLOBAL.FindEntity(player, 35,
        function(guy)
            return player.components.combat:CanTarget(guy)
        end,
        { "_combat", "_health" },
        { "character", "INLIMBO", "glommer", "companion", "shadow" },
        { "monster", "animal", "hostile" })
		
	local bees = 0;
	local spawner = player.components.childspawner
	
	if not player:HasTag("playerghost") then
		player.components.talker:Say("Beeeeeeees!!!", 2.5, true)
	else
		player.components.talker:Say("Why can't bees be bats?", 2.5, true)
	end
	
	while spawner:CanSpawn() and player.components.sanity.current >= 2 and bees < 5 do
		bees = bees + 1
		if not player:HasTag("playerghost") then
			spawner:SpawnChild(target, "guudebee")
		else
			local child = spawner:SpawnChild(target, "bat")
			child.components.homeseeker:SetHome(nil)
		end
		player.components.sanity:DoDelta(-2)
	end
	--player.components.childspawner:ReleaseAllChildren(target,"guudebee")
	player.components.childspawner:StopSpawning()
end)

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_R, function()
	local player=GLOBAL.ThePlayer
	if player and player.prefab=="guude"
    and not GLOBAL.IsPaused() and not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL) and not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
    and not player.HUD:IsChatInputScreenOpen() and not player.HUD:IsConsoleScreenOpen()then
		SendModRPCToServer(MOD_RPC[modname]["fullheal"])
	end
end)

AddModRPCHandler(modname, "fullheal", function(player)
	player.components.talker:Say("Resetting Stats", 2.5, true)
	player.components.sanity:DoDelta(10000)
	player.components.health:DoDelta(10000)
	player.components.hunger:DoDelta(10000)
	
	player.components.childspawner:StopSpawning()
end)

AddClassPostConstruct("widgets/statusdisplays", function(self)

	local player = self.owner
	if player.prefab=="guude" then
	
		local beeCounter = require "widgets/beecounter"
		player.beeCounter = beeCounter(player)
		
		player.beeCounter:Update("")
		
		if not player.components.childspawner then
			-- Update bee counter for cave enabled servers
			self.netBeeTotal = GLOBAL.net_ushortint(player.GUID, "beeTotal", "guude_bee_update")
			self.netBeeTotal:set(0)			
			
			player:ListenForEvent("guude_bee_update", function(inst)
				inst.beeCounter:Update("Bees: "..self.netBeeTotal:value())
			end)
		else
			-- Update bee counter for non-cave servers
			player:DoPeriodicTask(0, function(inst)
				inst.beeCounter:Update("Bees: "..player.components.childspawner.childreninside)
			end)
		end
	end
end)
