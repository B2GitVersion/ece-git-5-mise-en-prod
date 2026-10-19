# Orbitask : de la pull request à la production

**ECE Bachelor 2 · Git et GitHub · Activité de 2 h, en équipe de 3 ou 4**

Orbitask (entreprise fictive) édite un logiciel SaaS de planning pour les équipes techniques. Vous êtes son **équipe web**. Aujourd'hui, le site vitrine est mis en ligne à la main par un développeur qui copie les fichiers sur le serveur. Résultat : des erreurs en production, et personne ne sait quelle version est en ligne.

**Votre mission :** mettre en place une chaîne de mise en production automatisée, puis livrer la **v1.0.0** du site. Elle devra survivre à un incident en production.

À la fin de la séance, votre équipe doit avoir :

- un site en ligne qui affiche **la version en production** dans son pied de page ;
- des **tests automatiques** qui bloquent toute pull request qui casse le site ;
- une branche `main` **protégée** : personne ne pousse dessus sans review ;
- au moins **3 releases** publiées (`v1.0.0`, puis au moins deux autres) ;
- un **post-mortem** de l'incident.

> Les rappels sur commit, push, pull, PR, issue, organisation et code review sont dans la **fiche récap** distribuée en début de séance.

---

## Les rôles

| Rôle | Qui | Responsabilités |
|---|---|---|
| **Tech Lead** | 1 personne (change à chaque phase si vous voulez) | Crée les issues, configure le dépôt, publie les releases |
| **Développeurs** | Tout le monde, Tech Lead compris | Traitent un ticket chacun, relisent les PR des autres |

Règle d'or : **on ne relit jamais sa propre PR**, et on ne fusionne pas une PR qui n'a pas été approuvée.

---

## Phase 0 · Mise en place (15 min)

1. **Le Tech Lead crée une organisation GitHub** : avatar en haut à droite, **Your organizations**, puis **New organization**, plan **Free**. Nom : `orbitask-<nom-de-l-equipe>`. Il invite les autres membres (onglet **People**, puis **Invite member**, rôle **Owner** pour simplifier).
2. **Créer le dépôt depuis le modèle** : ouvrez le dépôt modèle donné par l'enseignant, cliquez sur **Use this template**, puis **Create a new repository**. Owner : votre organisation. Nom : `site-orbitask`. Visibilité : **Public**.
3. **Activer GitHub Pages** : dans le dépôt, **Settings**, puis **Pages**. Dans **Source**, choisissez **GitHub Actions**.
4. **Autoriser les déploiements depuis les versions** : **Settings**, puis **Environments**, puis **github-pages**. Dans **Deployment branches and tags**, cliquez sur **Add deployment branch or tag rule**, choisissez **Tag**, tapez `v*` et validez.
5. Chacun clone le dépôt (bouton vert **Code**) et vérifie que les tests passent en local :

```bash
bash tests/verifier.sh
```

**Question 0** : ouvrez `tests/verifier.sh`. Quelles sont les 5 règles qu'un site Orbitask doit respecter ?

---

## Phase 1 · Ticket ORB-1 : l'intégration continue (20 min)

**Objectif :** les tests doivent se lancer **tout seuls** à chaque pull request.

Le Tech Lead crée l'issue **ORB-1 · Lancer les tests automatiquement sur chaque PR** et se l'assigne.

1. Sur GitHub : **Add file**, puis **Create new file**. Nom : `.github/workflows/ci.yml`.
2. Collez ce contenu :

```yaml
# Nom du workflow, tel qu'il apparaitra dans l'onglet Actions
name: Verification

# QUAND le lancer : a chaque pull request, et a chaque push sur main
on:
  pull_request:
  push:
    branches: [main]

jobs:
  verifier:                      # nom du "check" qui apparaitra sur les PR
    runs-on: ubuntu-latest       # une machine Linux toute neuve, fournie par GitHub
    steps:
      - name: Recuperer le code du depot
        uses: actions/checkout@v5

      - name: Lancer les tests du site
        run: bash tests/verifier.sh
```

3. **Commit changes**, choisissez **Create a new branch** (nom : `ci/tests-automatiques`), puis **Propose changes** et ouvrez la PR avec `Fixes #1` dans la description.
4. Regardez la PR : un check **Verification / verifier** démarre. Ouvrez l'onglet **Actions** et suivez son exécution.
5. Un autre membre relit et approuve, puis on fusionne.

**Protéger `main`** (Tech Lead) : **Settings**, puis **Rules**, puis **Rulesets**, puis **New ruleset** et **New branch ruleset**.

- Nom : `protection-main`. **Enforcement status** : **Active**.
- **Target branches** : **Add target**, puis **Include default branch**.
- Cochez **Require a pull request before merging**, avec **Required approvals** = `1`.
- Cochez **Require status checks to pass**, puis **Add checks** et choisissez `verifier`.
- Cochez **Block force pushes**. Enregistrez.

**Test :** essayez de modifier directement `README.md` sur `main` depuis GitHub. Que se passe-t-il ?

**Questions 1**

1. Sur quelle machine les tests tournent-ils ? Qui la fournit ?
2. Pourquoi a-t-on dû fusionner ORB-1 **avant** de pouvoir choisir le check `verifier` dans la règle ?
3. En entreprise, pourquoi interdire le push direct sur `main`, même au Tech Lead ?

---

## Phase 2 · Le sprint (30 min)

Le Product Owner vous transmet 4 tickets. Le Tech Lead crée une issue par ticket et en assigne un à chaque développeur (à 3, le Tech Lead prend aussi un ticket).

| Ticket | Demande du Product Owner |
|---|---|
| **ORB-2** | Créer une page **Statut** (`statut.html`) qui indique « Tous les services sont opérationnels », et l'ajouter au menu de **toutes** les pages. |
| **ORB-3** | Ajouter sur la page Tarifs une offre **Équipe annuelle** à **80 €** par utilisateur et par an. |
| **ORB-4** | Sur la page Support, ajouter une section **Astreinte** : « Les clients Entreprise peuvent joindre l'astreinte 24 h/24 au 01 23 45 67 89. » |
| **ORB-5** | Sur la page Produit, ajouter une 4e fonctionnalité **Rapports** et un bouton **Essayer gratuitement** qui mène vers la page Tarifs. |

Pour chaque ticket, suivez le cycle complet :

1. `git pull` sur `main`, puis une branche `feature/orb-<numéro>`.
2. Faites la modification, puis lancez `bash tests/verifier.sh` en local.
3. Commit, push, PR avec `Fixes #<numéro>`.
4. **Attendez le check vert.** S'il est rouge, cliquez sur **Details** pour lire l'erreur, corrigez, et poussez à nouveau sur la même branche.
5. Un coéquipier fait la **code review** : il lit l'onglet **Files changed** et laisse au moins un commentaire, puis il approuve ou demande des changements.
6. Fusion, puis vérifiez que l'issue s'est fermée toute seule.

Vous allez sûrement rencontrer des **conflits** : plusieurs tickets modifient les mêmes fichiers. Quand GitHub affiche **This branch has conflicts**, cliquez sur **Resolve conflicts**, gardez les deux modifications, puis **Mark as resolved** et **Commit merge**.

**Questions 2**

1. Quels tickets ont fait échouer le check au premier essai ? Quelle règle avait été oubliée ?
2. Le check était vert : est-ce que ça garantit que la PR est bonne ? Que vérifie la review que les tests ne vérifient pas ?

---

## Phase 3 · Ticket ORB-6 : la mise en production automatique (20 min)

**Objectif :** publier une version déclenche automatiquement sa mise en ligne.

### Le versionnage sémantique

Une version s'écrit **MAJEUR.MINEUR.CORRECTIF**, par exemple `v2.4.1`.

| On incrémente... | Quand | Exemple |
|---|---|---|
| **CORRECTIF** | On corrige un bug, sans rien ajouter | `v1.0.0` devient `v1.0.1` |
| **MINEUR** | On ajoute une fonctionnalité, sans rien casser | `v1.0.1` devient `v1.1.0` |
| **MAJEUR** | On casse quelque chose pour les utilisateurs existants | `v1.1.0` devient `v2.0.0` |

**Question 3a** : en partant de `v1.4.2`, quelle version donner à chacun de ces changements ?

1. Correction d'une faute d'orthographe sur la page Tarifs
2. Ajout d'une page Blog
3. Suppression de l'offre Starter gratuite (les clients Starter doivent payer)
4. Correction d'un lien cassé et ajout d'une FAQ, dans la même version

### Le workflow de déploiement

Ticket **ORB-6 · Déployer automatiquement chaque release**. Créez `.github/workflows/deploy.yml` sur une branche, via une PR comme pour ORB-1 :

```yaml
name: Mise en production

# QUAND : a chaque release publiee (ou a la main, depuis l'onglet Actions)
on:
  release:
    types: [published]
  workflow_dispatch:

# Droits donnes au workflow : lire le code, publier sur GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Jamais deux mises en production en meme temps
concurrency:
  group: production
  cancel-in-progress: false

jobs:
  deployer:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deploiement.outputs.page_url }}
    steps:
      - name: Recuperer le code de la version
        uses: actions/checkout@v5

      - name: Derniere verification avant la prod
        run: bash tests/verifier.sh

      - name: Preparer le site et y ecrire le numero de version
        run: |
          mkdir _site
          cp *.html *.css _site/
          sed -i "s/__VERSION__/${{ github.ref_name }}/g" _site/*.html

      - uses: actions/configure-pages@v5

      - name: Empaqueter le site
        uses: actions/upload-pages-artifact@v4
        with:
          path: _site

      - name: Mettre en ligne
        id: deploiement
        uses: actions/deploy-pages@v4
```

Une fois la PR fusionnée, **le Tech Lead publie la première version** : **Releases** (colonne de droite), puis **Draft a new release**.

- **Choose a tag** : tapez `v1.0.0` puis **Create new tag**. Cible : `main`.
- Titre : `v1.0.0 · Première version`.
- Cliquez sur **Generate release notes** : GitHub liste les PR fusionnées depuis la version précédente.
- **Publish release**.

Ouvrez l'onglet **Actions** : la mise en production démarre. À la fin, cliquez sur le lien du job **deployer** : votre site est en ligne, avec **v1.0.0** dans le pied de page.

**Questions 3b**

1. Dans `deploy.yml`, à quoi sert `${{ github.ref_name }}` ? Que s'afficherait-il si on lançait le déploiement à la main depuis `main` ?
2. Pourquoi relancer les tests juste avant la mise en production, alors qu'ils ont déjà tourné sur la PR ?
3. Pourquoi a-t-on dû autoriser les tags `v*` dans l'environnement `github-pages` en phase 0 ?

---

## Phase 4 · L'incident (20 min)

Le service marketing envoie le ticket **ORB-7** : « Mettre les prix en blanc, c'est plus moderne. »

1. Un développeur traite ORB-7 : dans `style.css`, il change la couleur de `.prix` en `#ffffff`. PR, review, fusion.
2. Le Tech Lead publie la release **v1.1.0**.
3. Ouvrez le site en production, page Tarifs. **Les prix ont disparu** (blanc sur fond blanc). Un client appelle le support.

**Gérez l'incident comme en entreprise :**

1. **Créez une issue** `INCIDENT · Prix invisibles sur la page Tarifs`, avec le label `bug`.
2. **Corrigez en urgence (hotfix)** : ouvrez la PR fusionnée d'ORB-7 et cliquez sur **Revert** en bas de la page. GitHub crée une nouvelle PR qui annule exactement ce changement. Review express, fusion.
3. **Publiez le correctif** : quel numéro de version ? Publiez-la, et vérifiez que les prix sont revenus en production.
4. **Rédigez le post-mortem** en commentaire de l'issue d'incident, en 5 lignes :
   - **Ce qui s'est passé**
   - **Impact** (qui a été touché, pendant combien de temps)
   - **Cause**
   - **Correction**
   - **Ce qu'on change pour que ça n'arrive plus**

**Questions 4**

1. Les tests étaient verts et la PR avait été relue. Pourquoi le bug est-il passé quand même ?
2. Pourquoi faire un **revert** plutôt que supprimer le commit de l'historique ?
3. Le site affiche quelle version maintenant ? En quoi est-ce utile au support client ?

---

## Bonus

- **Badge de statut** : ajoutez en haut du `README.md` le badge du workflow (onglet **Actions**, workflow **Verification**, menu **...**, puis **Create status badge**).
- **Un test qui aurait détecté l'incident** : ajoutez une 6e règle dans `tests/verifier.sh` qui échoue si `.prix` est en blanc dans `style.css`. Livrez-la dans une version.
- **Une version majeure** : le Product Owner décide de supprimer l'offre Starter. Livrez la bonne version, avec des notes de release qui préviennent les clients.

---

## Ce qui sera regardé

| Élément | Où |
|---|---|
| Le site en ligne avec la dernière version affichée | Lien GitHub Pages |
| Au moins 3 releases avec des numéros cohérents | Onglet **Releases** |
| Des PR toutes relues, avec au moins un commentaire de review | Onglet **Pull requests** (fermées) |
| L'historique des tests et des déploiements | Onglet **Actions** |
| Le post-mortem | Issue d'incident |
| Les réponses aux questions | Dans une issue `Réponses de l'équipe` |
