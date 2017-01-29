local assets =
{
	Asset( "ANIM", "anim/guude.zip" ),
	Asset( "ANIM", "anim/ghost_guude_build.zip" ),
}

local skins =
{
	normal_skin = "guude",
	ghost_skin = "ghost_guude_build",
}

local base_prefab = "guude"

local tags = {"GUUDE", "CHARACTER"}

return CreatePrefabSkin("guude_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	tags = tags,
	
	skip_item_gen = true,
	skip_giftable_gen = true,
})