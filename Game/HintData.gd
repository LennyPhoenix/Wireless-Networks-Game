class_name HintData
extends Resource

enum HintTier {
	TIER1 = 1,
	TIER2,
	TIER3,
	TIER4,
	TIER5,
}

export var description := ""
export(HintTier) var tier
