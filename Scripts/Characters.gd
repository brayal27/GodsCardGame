extends Node

const CHARACTERS = {
# =========================
# Facción nórdica
# =========================
"Thor": {
	"name": "Thor",
	"attack": 6,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Thor.png",
	"abilities": {
		"OFENSIVO": 1
	}
},

"Odin": {
	"name": "Odin",
	"attack": 4,
	"health": 5,
	"faction": "nordicos",
	"image": "res://Characters_image/Odin.png",
	"abilities": {
		"CENTRO": 2
	}
},

"Loki": {
	"name": "Loki",
	"attack": 3,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Loki.png",
	"abilities": {
		"DEBILITAR": 1
	}
},

"Freyja": {
	"name": "Freyja",
	"attack": 3,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Freyja.png",
	"abilities": {
		"APOYO": 1
	}
},

"Frigg": {
	"name": "Frigg",
	"attack": 2,
	"health": 5,
	"faction": "nordicos",
	"image": "res://Characters_image/Frigg.png",
	"abilities": {
		"DEFENSIVO": 2
	}
},

"Tyr": {
	"name": "Tyr",
	"attack": 5,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Tyr.png",
	"abilities": {
		"OFENSIVO": 1
	}
},

"Heimdall": {
	"name": "Heimdall",
	"attack": 4,
	"health": 5,
	"faction": "nordicos",
	"image": "res://Characters_image/Heimdall.png",
	"abilities": {
		"LATERAL": 1,
		"DEFENSIVO": 1
	}
},

"Balder": {
	"name": "Balder",
	"attack": 3,
	"health": 5,
	"faction": "nordicos",
	"image": "res://Characters_image/Balder.png",
	"abilities": {
		"APOYO": 1
	}
},

"Hodr": {
	"name": "Hödr",
	"attack": 4,
	"health": 2,
	"faction": "nordicos",
	"image": "res://Characters_image/Hodr.png",
	"abilities": {
		"AISLADO": 2
	}
},

"Vidar": {
	"name": "Vidar",
	"attack": 5,
	"health": 5,
	"faction": "nordicos",
	"image": "res://Characters_image/Vidar.png",
	"abilities": {
		"CENTRO": 1
	}
},

"Vali": {
	"name": "Vali",
	"attack": 4,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Vali.png",
	"abilities": {
		"OFENSIVO": 1
	}
},

"Bragi": {
	"name": "Bragi",
	"attack": 2,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Bragi.png",
	"abilities": {
		"APOYO": 2
	}
},

"Idunn": {
	"name": "Idunn",
	"attack": 1,
	"health": 5,
	"faction": "nordicos",
	"image": "res://Characters_image/Idunn.png",
	"abilities": {
		"APOYO": 1,
		"DEFENSIVO": 1
	}
},

"Njord": {
	"name": "Njord",
	"attack": 3,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Njord.png",
	"abilities": {
		"LATERAL": 2
	}
},

"Freyr": {
	"name": "Freyr",
	"attack": 4,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Freyr.png",
	"abilities": {
		"APOYO": 1
	}
},

"Skadi": {
	"name": "Skadi",
	"attack": 4,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Skadi.png",
	"abilities": {
		"AISLADO": 1,
		"LATERAL": 1
	}
},

"Sif": {
	"name": "Sif",
	"attack": 3,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Sif.png",
	"abilities": {
		"DEFENSIVO": 1,
		"APOYO": 1
	}
},

"Ullr": {
	"name": "Ullr",
	"attack": 3,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Ullr.png",
	"abilities": {
		"AISLADO": 2
	}
},

"Forseti": {
	"name": "Forseti",
	"attack": 2,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Forseti.png",
	"abilities": {
		"DEBILITAR": 1
	}
},

"Hel": {
	"name": "Hel",
	"attack": 5,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Hel.png",
	"abilities": {
		"AISLADO": 1
	}
},

"Fenrir": {
	"name": "Fenrir",
	"attack": 7,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Fenrir.png",
	"abilities": {
		"OFENSIVO": 1
	}
},

"Jormungan": {
	"name": "Jörmungan",
	"attack": 6,
	"health": 6,
	"faction": "nordicos",
	"image": "res://Characters_image/Jormungan.png",
	"abilities": {
		"CENTRO": 1
	}
},

"Sleipnir": {
	"name": "Sleipnir",
	"attack": 3,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Sleipnir.png",
	"abilities": {
		"LATERAL": 1
	}
},

"Mjolnir": {
	"name": "Mjolnir",
	"attack": 2,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Mjolnir.png",
	"abilities": {
		"APOYO": 2
	}
},

"Mimir": {
	"name": "Mimir",
	"attack": 1,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Mimir.png",
	"abilities": {
		"APOYO": 1,
		"CENTRO": 1
	}
},

"Ymir": {
	"name": "Ymir",
	"attack": 6,
	"health": 6,
	"faction": "nordicos",
	"image": "res://Characters_image/Ymir.png",
	"abilities": {
		"DEFENSIVO": 1
	}
},

"Surtr": {
	"name": "Surtr",
	"attack": 7,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Surtr.png",
	"abilities": {
		"OFENSIVO": 2
	}
},

"Angrboda": {
	"name": "Angrboda",
	"attack": 4,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Angrboda.png",
	"abilities": {
		"DEBILITAR": 1
	}
},

"Nidhogg": {
	"name": "Nidhogg",
	"attack": 5,
	"health": 4,
	"faction": "nordicos",
	"image": "res://Characters_image/Nidhogg.png",
	"abilities": {
		"ESQUINA": 2
	}
},

"Valkyrie": {
	"name": "Valkiria",
	"attack": 4,
	"health": 3,
	"faction": "nordicos",
	"image": "res://Characters_image/Valkyrie.png",
	"abilities": {
		"LATERAL": 1,
		"OFENSIVO": 1
	}
},

# =========================
# Facción griega
# =========================

"Zeus": {
	"name": "Zeus",
	"attack": 6,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Zeus.png",
	"abilities": {
		"OFENSIVO": 2
	}
},

"Poseidon": {
	"name": "Poseidón",
	"attack": 5,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Poseidon.png",
	"abilities": {
		"LATERAL": 2
	}
},

"Hades": {
	"name": "Hades",
	"attack": 5,
	"health": 6,
	"faction": "griegos",
	"image": "res://Characters_image/Hades.png",
	"abilities": {
		"DEFENSIVO": 2
	}
},

"Ares": {
	"name": "Ares",
	"attack": 7,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Ares.png",
	"abilities": {
		"OFENSIVO": 2
	}
},

"Athena": {
	"name": "Atenea",
	"attack": 4,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Athena.png",
	"abilities": {
		"CENTRO": 2
	}
},

"Apollo": {
	"name": "Apolo",
	"attack": 4,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Apollo.png",
	"abilities": {
		"APOYO": 1,
		"LATERAL": 1
	}
},

"Artemis": {
	"name": "Artemisa",
	"attack": 4,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Artemis.png",
	"abilities": {
		"AISLADO": 2
	}
},

"Hermes": {
	"name": "Hermes",
	"attack": 3,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Hermes.png",
	"abilities": {
		"LATERAL": 1,
		"OFENSIVO": 1
	}
},

"Hephaestus": {
	"name": "Hefesto",
	"attack": 3,
	"health": 6,
	"faction": "griegos",
	"image": "res://Characters_image/Hephaestus.png",
	"abilities": {
		"DEFENSIVO": 2
	}
},

"Aphrodite": {
	"name": "Afrodita",
	"attack": 2,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Aphrodite.png",
	"abilities": {
		"DEBILITAR": 1,
		"APOYO": 1
	}
},

"Dionysus": {
	"name": "Dionisio",
	"attack": 3,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Dionysus.png",
	"abilities": {
		"DEBILITAR": 2
	}
},

"Demeter": {
	"name": "Deméter",
	"attack": 2,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Demeter.png",
	"abilities": {
		"APOYO": 2
	}
},

"Hera": {
	"name": "Hera",
	"attack": 3,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Hera.png",
	"abilities": {
		"DEFENSIVO": 1,
		"CENTRO": 1
	}
},

"Hestia": {
	"name": "Hestia",
	"attack": 1,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Hestia.png",
	"abilities": {
		"APOYO": 1,
		"DEFENSIVO": 1
	}
},

"Persephone": {
	"name": "Perséfone",
	"attack": 3,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Persephone.png",
	"abilities": {
		"APOYO": 1,
		"DEBILITAR": 1
	}
},

"Heracles": {
	"name": "Heracles",
	"attack": 7,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Heracles.png",
	"abilities": {
		"OFENSIVO": 1
	}
},

"Achilles": {
	"name": "Aquiles",
	"attack": 6,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Achilles.png",
	"abilities": {
		"AISLADO": 1,
		"OFENSIVO": 1
	}
},

"Odysseus": {
	"name": "Odiseo",
	"attack": 4,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Odysseus.png",
	"abilities": {
		"CENTRO": 1,
		"DEBILITAR": 1
	}
},

"Theseus": {
	"name": "Teseo",
	"attack": 5,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Theseus.png",
	"abilities": {
		"LATERAL": 1
	}
},

"Perseus": {
	"name": "Perseo",
	"attack": 5,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Perseus.png",
	"abilities": {
		"ESQUINA": 2
	}
},

"Medusa": {
	"name": "Medusa",
	"attack": 4,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Medusa.png",
	"abilities": {
		"DEBILITAR": 2
	}
},

"Minotaur": {
	"name": "Minotauro",
	"attack": 6,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Minotaur.png",
	"abilities": {
		"CENTRO": 1
	}
},

"Pegasus": {
	"name": "Pegaso",
	"attack": 3,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Pegasus.png",
	"abilities": {
		"LATERAL": 2
	}
},

"Cerberus": {
	"name": "Cerbero",
	"attack": 5,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Cerberus.png",
	"abilities": {
		"DEFENSIVO": 1
	}
},

"Chimera": {
	"name": "Quimera",
	"attack": 6,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Chimera.png",
	"abilities": {
		"OFENSIVO": 1,
		"DEBILITAR": 1
	}
},

"Hydra": {
	"name": "Hidra",
	"attack": 4,
	"health": 6,
	"faction": "griegos",
	"image": "res://Characters_image/Hydra.png",
	"abilities": {
		"DEFENSIVO": 1,
		"APOYO": 1
	}
},

"Asclepius": {
	"name": "Asclepio",
	"attack": 1,
	"health": 4,
	"faction": "griegos",
	"image": "res://Characters_image/Asclepius.png",
	"abilities": {
		"APOYO": 2
	}
},

"Nyx": {
	"name": "Nyx",
	"attack": 4,
	"health": 5,
	"faction": "griegos",
	"image": "res://Characters_image/Nyx.png",
	"abilities": {
		"AISLADO": 1,
		"DEBILITAR": 1
	}
},

"Thanatos": {
	"name": "Tánatos",
	"attack": 6,
	"health": 3,
	"faction": "griegos",
	"image": "res://Characters_image/Thanatos.png",
	"abilities": {
		"AISLADO": 2
	}
},

"Chronos": {
	"name": "Cronos",
	"attack": 6,
	"health": 6,
	"faction": "griegos",
	"image": "res://Characters_image/Chronos.png",
	"abilities": {
		"CENTRO": 1
		}
	}
}
static func get_characters_by_faction(faction_name: String) -> Array:
	var result := []
	
	for character_key in CHARACTERS.keys():
		var character_data = CHARACTERS[character_key]
		
		if character_data.get("faction", "") == faction_name:
			result.append(character_key)
	
	return result


static func create_deck_from_faction(faction_name: String) -> Array:
	var deck := get_characters_by_faction(faction_name)
	deck.shuffle()
	return deck
