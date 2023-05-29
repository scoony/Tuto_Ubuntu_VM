# Tuto_Ubuntu_VM
Tutoriel complet pour avoir une VM de jeux sur Ubuntu.

Une VM de jeu, c'est un ordinateur virtuel qui sera sous Windows et qui se comportera comme un vrai ordinateur. Nous allons y relier une vrai carte graphique et tout ce que l'on veut.

Nous aurons donc deux ordinateurs dans un seul.

Chez moi par exemple j'ai l'HDMI de ma GeForce qui est relié à mon moniteur et le Display Port de ma carte mère au même moniteur. Il me suffit de changer la source sur mon écran et d'alterner entre HDMI ou DP et je bascule d'un système à l'autre.

## Prérequis
- Un systeme d'exploitation Ubuntu 22.04 LTS
- Deux cartes graphiques (pour mon exemple une vrai et une intégrée)
- Une connexion internet
- Du temps devant soit

## Préambule

Je fais beaucoup de script bash et je vous conseille de faire comme moi, les regrouper tous au même endroit est plutot pratique.

## Attention

Pour que la vrai carte graphique soit utilisée par la VM il faut qu'un écran soit connecté, que ce soit un véritable écran (même si il est éteint) ou une clé HDMI ou DP qui simule un écran (on en trouve sur Amazon ou autre (dummy HDMI key)


## Aide:

- Pour sauvegarder sous nano: CTRL+O
- Pour quitter sous nano: CTRL+X
- Pour coller dans le terminal: SHIFT+INSER (ou via le clique droit de la souris)