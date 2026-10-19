#!/usr/bin/env bash
# Tests automatiques du site Orbitask.
# En local : bash tests/verifier.sh    |   Sur GitHub : lance par GitHub Actions
cd "$(dirname "$0")/.." || exit 1
erreurs=0
echec() { echo "  ECHEC : $1"; erreurs=$((erreurs + 1)); }

echo "1. Chaque page a un titre"
for f in *.html; do
  grep -q "<title>.*</title>" "$f" || echec "$f n'a pas de <title>"
done

echo "2. Tous les liens internes menent a une page qui existe"
for f in *.html; do
  for cible in $(grep -o 'href="[^"#:]*\.html"' "$f" | sed 's/href="//; s/"$//'); do
    [ -f "$cible" ] || echec "$f contient un lien vers $cible, qui n'existe pas"
  done
done

echo "3. Tous les prix sont au format 0,00 €"
for f in *.html; do
  while IFS= read -r ligne; do
    echo "$ligne" | grep -qE 'class="prix">[0-9]+,[0-9]{2} €<' || echec "$f : prix invalide -> $(echo "$ligne" | sed 's/^ *//')"
  done < <(grep 'class="prix"' "$f")
done

echo "4. Aucun TODO oublie"
if grep -q "TODO" *.html; then echec "il reste un TODO dans : $(grep -l TODO *.html | tr '\n' ' ')"; fi

echo "5. Le pied de page affiche la version"
for f in *.html; do
  grep -q 'class="version"' "$f" || echec "$f n'affiche pas la version en production"
done

echo
if [ "$erreurs" -eq 0 ]; then echo "OK : tous les tests passent."; exit 0
else echo "$erreurs test(s) en echec."; exit 1; fi
