# Switchless 50/60Hz mod for Sega Saturn (PIC12F629)

English:

This repository documents a small "switchless" modification for the Sega Saturn that allows toggling between 50Hz and 60Hz using the reset button. The implementation uses a PIC12F629 microcontroller. Below are extra installation details illustrated by the provided photos.

Quick summary of behavior
- Short press on reset (< 2s): normal console reset on release.
- Long press on reset (≥ 2s): toggle 50Hz/60Hz on release without resetting the console.
- LED signalling: one LED stays ON in 60Hz and BLINKS (2×/s) in 50Hz. Use one of the console "power" LEDs for mode signalling; both LEDs must be handled as described below.

Wiring and photo references
- Chip install.jpg: This photo shows the PIC installed. In this setup:
  - PIC pin 1 is connected to 5V and PIC pin 8 is connected to GND; both are tied to the capacitor CE42 on the board.
  - PIC pin 5 is connected to pin 79 of IC14 (signal injection point for 50/60Hz).
  - BEFORE connecting the PIC to pin 79 of IC14, you MUST disconnect pin 79 from the motherboard: carefully lift the IC14 pin 79 from its pad (use a very thin blade like an X‑Acto and a soldering iron) so the PIC drives the signal alone. This step requires a steady hand and proper ESD/soldering precautions.

- Reset.jpg: This photo shows the reset wire that must be CUT so you can insert the PIC lines for pin 6 and pin 7. The wires you add use two distinct colours to make wiring clear — follow the colour code you used (the photo shows which colour goes where). You will connect the two reset wire ends to the PIC so the PIC can detect presses and generate/reset signals on its GP0/GPIO pins (see firmware pin mapping).
- LED.jpg: This photo shows the LED modification. The wire coming from the PIC pin 3 is routed to the original LED. You must add a 220 Ω resistor in series with the original LED as shown. IMPORTANT: you must cut the PCB trace that connects the two power LEDs on the console so they are independent before wiring the PIC LED output. This prevents the LEDs from interfering with each other when the PIC drives one LED to indicate mode.

Hardware summary (wires)
- 5V (Vcc) — PIC pin 1
- GND — PIC pin 8
- Reset sense / button wiring — cut the original reset wire (see Image 1) and connect the two ends to the PIC reset input/output pins (pin numbers per firmware)
- FREQ control — PIC pin 5 -> pin 79 of IC14 (after removing the IC14 pin 79 from the PCB)
- LED (optional) — PIC pin 3 -> series 220 Ω resistor -> existing power LED (after cutting the trace between the two LEDs)

LED resistor
- Use 220 Ω resistors in series with each LED you re-use from the console.

Repository folders
- images/ — installation photos
- firmware/ — firmware files: pic12f629.asm (source) and pic12f629.hex (compiled hex)


---

Français :

Ce dépôt décrit une modification "switchless" pour la Sega Saturn permettant de basculer entre 50Hz et 60Hz avec le bouton reset. La modification utilise un PIC12F629. Voici les précisions d'installation illustrées par les photos fournies.

Résumé comportement
- Appui court sur reset (< 2s) : reset normal de la console au relâchement.
- Appui long sur reset (≥ 2s) : bascule 50Hz/60Hz au relâchement sans reset.
- Indication par LED : une LED reste allumée en 60Hz et CLIGNOTE (2×/s) en 50Hz. Utiliser l'une des LED "power" existantes pour l'indication ; les deux LED doivent être traitées comme expliqué ci‑dessous.

Câblage et références des photos
- chip install.jpg : montre la puce installée. Dans cette configuration :
  - Pin 1 du PIC = 5V et pin 8 = GND ; ces lignes sont raccordées au condensateur CE42.
  - Pin 5 du PIC est raccordée à la pin 79 de IC14 (point d'injection du signal 50/60Hz).
  - AVANT de connecter le PIC sur la pin 79 du IC14, il FAUT d'abord déconnecter la pin 79 du IC14 de la carte mère : soulever délicatement la broche 79 du IC14 à l'aide d'une lame très fine (type X‑Acto) et d'un fer à souder afin qu'elle ne soit plus reliée au routage de la carte. Cette opération demande de la précision et il faut respecter les règles de soudure et d'ESD.

- reset.jpg : montre le fil du reset à COUPER pour insérer les lignes vers les pins 6 et 7 de la puce. Les fils ajoutés ont deux couleurs pour distinguer les connexions — suis la convention de couleurs que tu as utilisée (la photo montre l'affectation). Tu raccorderas les deux extrémités du fil reset au PIC pour que le PIC détecte les appuis et pilote les reset via ses broches GP0/GPIO (voir mappage dans le firmware).
- LED.jpg : montre la modification de la LED. On voit le fil venant de la pin 3 de la puce relié à la LED d'origine. Il faut ajouter une résistance de 220 Ω en série avec la LED. IMPORTANT : il faut couper la piste sur le PCB qui relie les deux LED d'alimentation de la console afin qu'elles soient indépendantes avant de brancher la sortie du PIC. Cela évitera des interactions indésirables lorsque le PIC commande une LED.

Résumé des fils
- 5V (Vcc) — pin 1 du PIC
- GND — pin 8 du PIC
- Reset (bouton) — couper le fil reset d'origine (voir Image 1) et connecter les deux bouts sur les entrées/sorties du PIC
- Contrôle fréquence — pin 5 du PIC -> pin 79 de IC14 (après avoir soulevé la broche 79)
- LED (optionnelle) — pin 3 du PIC -> résistance 220 Ω -> LED d'origine (après avoir coupé la piste entre les deux LED)

Résistance LED
- Utiliser des résistances de 220 Ω en série avec chaque LED réutilisée.

Fichiers 
- images/ — photos d'installation (chip install.jpg, ...)
- firmware/ — source (pic12f629.asm) et le pic12f629.hex
