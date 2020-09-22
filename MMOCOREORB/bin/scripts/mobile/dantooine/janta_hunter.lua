janta_hunter = Creature:new {
	objectName = "@mob/creature_names:janta_hunter",
	randomNameType = NAME_GENERIC,
	randomNameTag = true,
	socialGroup = "janta_tribe",
	faction = "janta_tribe",
	level = 50,
	chanceHit = 0.5,
	damageMin = 415,
	damageMax = 540,
	baseXp = 4916,
	baseHAM = 11000,
	baseHAMmax = 13000,
	armor = 1,
	resists = {5,5,-1,-1,5,60,-1,-1,-1},
	meatType = "",
	meatAmount = 0,
	hideType = "",
	hideAmount = 0,
	boneType = "",
	boneAmount = 0,
	milk = 0,
	tamingChance = 0,
	ferocity = 0,
	pvpBitmask = ATTACKABLE,
	creatureBitmask = PACK + HERD + KILLER,
	optionsBitmask = AIENABLED,
	diet = HERBIVORE,

	templates = {
		"object/mobile/dantari_male.iff",
		"object/mobile/dantari_female.iff"},
	lootGroups = {
		{
			groups = {
				{group = "armor_attachments", chance = 500000},
				{group = "clothing_attachments", chance = 500000},
				{group = "junk", chance = 500000},
				{group = "janta_common", chance = 10000000},
				{group = "loot_kit_parts", chance = 300000},
				{group = "wearables_all", chance = 1000000}
			}
		}
	},
	weapons = {"primitive_weapons"},
	conversationTemplate = "",
	attacks = merge(pikemanmaster,fencermaster,brawlermaster)
}

CreatureTemplates:addCreatureTemplate(janta_hunter, "janta_hunter")
