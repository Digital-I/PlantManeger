import json
import sys

PLANTS_FILE = "../assets/plants_catalog.json"
DISEASES_FILE = "../assets/diseases_catalog.json"

with open(PLANTS_FILE, encoding="utf-8") as f:
    plant_ids = {p["id"] for p in json.load(f)}

with open(DISEASES_FILE, encoding="utf-8") as f:
    diseases = json.load(f)

problems = 0
used = set()

for d in diseases:
    for pid in d["affectedPlantIds"]:
        used.add(pid)
        if pid not in plant_ids:
            problems += 1
            print(f"Болезнь '{d['id']}': неизвестный id растения '{pid}'")

# Справочно: растения, на которые не ссылается ни одна болезнь
unused = sorted(plant_ids - used)
if unused:
    print(f"\nРастения без болезней в каталоге: {', '.join(unused)}")

if problems:
    print(f"\nНайдено проблемных id: {problems}")
    sys.exit(1)

print("\nВсе id растений в каталоге болезней корректны")