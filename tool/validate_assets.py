import json, sys

LIGHT = {"direct_sun","bright_indirect","partial_shade","shade","artificial_light"}
SOIL = {"universal","drainage","cactus_succulent","peat","sandy","loamy",
        "perlite_mix","orchid_bark","acidic","humus","leaf_soil"}
CAUSE = {"overwatering","underwatering","poor_drainage","low_light","low_humidity",
         "pests","fungus","cold_draft","overfertilizing"}
SYMPTOM = {"yellow_leaves","brown_tips","brown_spots","white_coating","wilting",
           "leaf_drop","soft_stem","root_discoloration","bad_smell","webbing",
           "sticky_leaves","stunted_growth","curling_leaves"}
SEVERITY = {"low","medium","high"}

errors = []
plants = json.load(open("assets/plants_catalog.json", encoding="utf-8"))
diseases = json.load(open("assets/diseases_catalog.json", encoding="utf-8"))

ids = [p["id"] for p in plants]
if len(ids) != len(set(ids)):
    errors.append("plants: повторяются id")

for p in plants:
    i = p["id"]
    if not set(p["light"]) <= LIGHT or not p["light"]:
        errors.append(f"{i}: неверные теги света {p['light']}")
    if not set(p["soil"]) <= SOIL or not p["soil"]:
        errors.append(f"{i}: неверные теги почвы {p['soil']}")
    if not 20 <= p["wateringMl"] <= 2000:
        errors.append(f"{i}: wateringMl вне диапазона")
    if not 1 <= p["wateringIntervalDays"] <= 60:
        errors.append(f"{i}: wateringIntervalDays вне диапазона")
    if not 20 <= p["humidityPercent"] <= 90:
        errors.append(f"{i}: humidityPercent вне диапазона")
    if p["temperatureMinC"] >= p["temperatureMaxC"]:
        errors.append(f"{i}: min температура не меньше max")

dids = [d["id"] for d in diseases]
if len(dids) != len(set(dids)):
    errors.append("diseases: повторяются id")

for d in diseases:
    i = d["id"]
    if not set(d["cause"]) <= CAUSE or not d["cause"]:
        errors.append(f"{i}: неверные причины {d['cause']}")
    if not set(d["symptoms"]) <= SYMPTOM or not d["symptoms"]:
        errors.append(f"{i}: неверные симптомы {d['symptoms']}")
    if d["severity"] not in SEVERITY:
        errors.append(f"{i}: неверная severity")
    bad = set(d["affectedPlantIds"]) - set(ids)
    if bad:
        errors.append(f"{i}: несуществующие растения {sorted(bad)}")

print("\n".join(errors) if errors else "OK")
sys.exit(1 if errors else 0)