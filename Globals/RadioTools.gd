extends Node

var ones_map: Dictionary = {
	1: "ein",
	2: "zwei",
	3: "drei",
	4: "vier",
	5: "fünf",
	6: "sechs",
	7: "sieben",
	8: "acht",
	9: "neun"
}

var tens_map: Dictionary = {
	1: "zehn",
	2: "zwanzig",
	3: "dreißig",
	4: "vierzig",
	5: "fünfzig",
	6: "sechzig",
	7: "siebzig",
	8: "achtzig",
	9: "neunzig"
}

var special_cases: Dictionary = {
	1: "eins",
	10: "zehn",
	11: "elf",
	12: "zwölf",
	13: "dreizehn",
	14: "vierzehn",
	15: "fünfzehn",
	16: "sechzehn",
	17: "siebzehn",
	18: "achtzehn",
	19: "neunzehn",
	100: "einhundert",
	200: "zweihundert"
}

# {health} = health of the monster as formatted string
var health_radio_transmissions: Array = [
	"Basis an Funker, ein Tiefsee-Monster wurde entdeckt. Scans zeigen {health} Lebenspunkte.",
	"Funker, ein Tiefsee-Kreatur mit {health} Lebenspunkten nähert sich.",
	"Unsere Sensoren erfassen ein Tiefsee-Ungeheuer mit {health} Lebenspunkten.",
	"Funker, das Tiefsee-Monster weist {health} Lebenspunkte auf.",
	"Basis meldet: Lebensform aus der Tiefsee mit {health} Lebenspunkten gesichtet.",
	"Funker, aktuelle Gesundheit des Tiefsee-Gegners: {health} Lebenspunkte.",
	"Scan bestätigt: Tiefsee-Kreatur hat {health} Lebenspunkte.",
	"Tiefsee-Monster mit {health} Lebenspunkten lokalisiert."
]

# {mode} = Breadth-First Search or Depth-First Search
var tree_traversal_radio_transmissions: Array = [
	"Basis an Funker, untersuchen Sie das Schiffswrack mit {mode}.",
	"Vorsicht, wir scannen das Gebiet mit {mode}.",
	"Basis meldet: Analyse des Wracks erfolgt via {mode}.",
	"Funker, starten Sie die Untersuchung des Schiffswracks durch {mode}.",
	"Erkundung des Wracks wird mit {mode} durchgeführt.",
	"Basis bestätigt: Wir verwenden {mode} zur Erkundung.",
	"Beginnen Sie mit {mode} im Schiffswrack, Funker.",
	"Das Wrack wird jetzt mit {mode} systematisch durchsucht.",
]

var traversal_mode_strings: Dictionary = {
	0: "Breitensuche",
	1: "Tiefensuche"
}

func translate_to_string(value: int) -> String:
	var ones: int = value % 10

	@warning_ignore("integer_division")
	var tens: int = floor(value / 10) % 10
	
	@warning_ignore("integer_division")
	var hundreds: int = floor(value / 100)

	var remainder: int = value % 100
	var result: String = ""

	if remainder > 0:
		if remainder in special_cases:
			result = special_cases[remainder]
		elif remainder < 20:
			result = ones_map.get(remainder, "")
		elif ones == 0:
			result = tens_map.get(tens, "")
		else:
			result = ones_map[ones] + "und" + tens_map.get(tens, "")

	if hundreds > 0:
		if hundreds == 1:
			result = "einhundert" + result
		else:
			result = ones_map[hundreds] + "hundert" + result

	return result

func get_health_radio_transmission(health: int) -> String:
	var transmission: String = health_radio_transmissions.pick_random()
	transmission = transmission.format({"health": self.translate_to_string(health)})
	return transmission

func get_tree_traversal_radio_transmission(mode: int) -> String:
	var mode_string: String = traversal_mode_strings.get(mode)
	var transmission: String = tree_traversal_radio_transmissions.pick_random()
	transmission = transmission.format({"mode": mode_string})
	return transmission
