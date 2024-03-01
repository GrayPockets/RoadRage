-- Update civilian descriptions

INSERT OR REPLACE INTO "LocalizedText"
	(	"Language",	"Tag",											"Text"																																																																																											)
VALUES
	(	'en_US',	'LOC_UNIT_BUILDER_DESCRIPTION',					'May create tile improvements, remove features like Woods or Rainforest, or Harvest some resources. Builders can be used 3 times. This can be increased through policies or wonders like the Pyramids.[NEWLINE][NEWLINE]Can build and remove roads without using charges.'																										),
	(	'en_US',	'LOC_UNIT_MILITARY_ENGINEER_ALT_DESCRIPTION',	'Medieval era support unit. Requires an Armory to produce. Can construct Roads, Railroads, Forts, Airstrips, Missile Silos, and Mountain Tunnel improvements. One of their build charges can also be used to complete 20% of a Canal, Dam or Aqueduct district or a Flood Barrier building.[NEWLINE][NEWLINE]Can build and remove roads and railroads without using charges.'	),
	(	'en_US',	'LOC_UNIT_ROMAN_LEGION_DESCRIPTION',			'Roman unique Classical era melee unit that replaces the Swordsman. Can build a Roman Fort.[NEWLINE][NEWLINE]Can build and remove roads without using charges.'																																																					);

-- Replace "Buildable Roads" text

DELETE FROM "LocalizedText"
WHERE "Tag" = 'LOC_ZEGA_BUILDABLE_ROAD_INSUFFICIENT_GOLD';

INSERT OR REPLACE INTO "LocalizedText"
	(	"Language",	"Tag",										"Text"											)
VALUES
	(	'en_US',	'LOC_ZEGA_UPGRADE_ROAD_TO_INDUSTRIAL_ROAD',	'Upgrade this tile''s Road to Industrial Road.'	),
	(	'en_US',	'LOC_ZEGA_BUILD_INDUSTRIAL_ROAD',			'Build an Industrial Road on this Tile.'		),
	(	'en_US',	'LOC_ZEGA_UPGRADE_ROAD_TO_MODERN_ROAD',		'Upgrade this tile''s Road to Modern Road.'		),
	(	'en_US',	'LOC_ZEGA_BUILD_MODERN_ROAD',				'Build a Modern Road on this Tile.'				);
