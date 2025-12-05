;******************************************************************************
; Commutateur switchless 50/60Hz pour Sega Saturn par Grangou - 2025.
; 
; Fonctionne avec un PIC12F629
;
; GP0 (pin7) : Entrée bouton reset (actif bas, avec pull-up interne)
; GP1 (pin6) : Sortie reset CPU (impulsion 0V pendant 0.1s si appui bouton reset < 2s)
; GP2 (pin5) : Sortie commande pin79 de IC14 50/60Hz (5V=60Hz, 0V=50Hz) si appui bouton reset > 2s
; GP4 (pin3) : Indicateur LED (fixe en 60Hz, clignote 2x/s en 50Hz)
;******************************************************************************

        LIST    P=12F629
        INCLUDE <P12F629.INC>

        __CONFIG _MCLRE_OFF & _CP_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

;******************************************************************************
; Définitions des broches
;******************************************************************************
#define BTN         GPIO,0          ; Bouton reset
#define CPU_RST     GPIO,1          ; Reset CPU console
#define FREQ_OUT    GPIO,2          ; Sortie 50/60Hz
#define LED         GPIO,4          ; LED indicateur

;******************************************************************************
; Variables RAM
;******************************************************************************
        CBLOCK  0x20
            temp1                   ; Variable temporaire 1
            temp2                   ; Variable temporaire 2
            temp3                   ; Variable temporaire 3
            compteur_lo             ; Compteur temps appui (octet bas)
            compteur_hi             ; Compteur temps appui (octet haut)
            etat_bouton             ; 0=relâché, 1=appuyé
            mode_freq               ; 0=50Hz, 1=60Hz
            compteur_blink          ; Compteur pour clignotement LED
        ENDC

;******************************************************************************
; Vecteur de reset
;******************************************************************************
        ORG     0x000
        goto    init

;******************************************************************************
; Initialisation
;******************************************************************************
init
        ; Banque 0 par défaut
        banksel GPIO
        
        ; Désactiver comparateur analogique
        movlw   0x07
        movwf   CMCON
        
        ; Passer en banque 1 pour configuration
        bsf     STATUS,RP0
        
        ; Configuration GPIO: GP0 et GP3 en entrée, reste en sortie
        movlw   b'00001001'         ; GP0 et GP3 en entrée
        movwf   TRISIO
        
        ; Activer pull-up sur GP0
        movlw   b'00000001'         ; WPU sur GP0
        movwf   WPU
        
        ; Activer les weak pull-ups globalement
        bcf     OPTION_REG,NOT_GPPU
        
        ; Retour en banque 0
        bcf     STATUS,RP0
        
        ; Variables à zéro
        clrf    etat_bouton
        clrf    compteur_lo
        clrf    compteur_hi
        clrf    compteur_blink
        
        ; Mode initial: 60Hz
        movlw   0x01
        movwf   mode_freq
        
        ; Sorties initiales: CPU_RST=1, FREQ_OUT=1 (60Hz), LED=1
        movlw   b'00010110'
        movwf   GPIO

;******************************************************************************
; Boucle principale
;******************************************************************************
boucle
        ; Test état du bouton
        btfsc   BTN                 ; Si BTN=0 (appuyé), skip
        goto    relache
        
        ; Bouton appuyé
        movf    etat_bouton,f
        btfss   STATUS,Z            ; Déjà en cours d'appui ?
        goto    compte_appui
        
        ; Début nouvel appui
        movlw   0x01
        movwf   etat_bouton
        clrf    compteur_lo
        clrf    compteur_hi
        
compte_appui
        ; Incrémenter compteur temps
        incf    compteur_lo,f
        btfsc   STATUS,Z
        incf    compteur_hi,f
        
        ; Limiter compteur à 250
        movf    compteur_hi,w
        btfss   STATUS,Z
        goto    attente
        movlw   .250
        subwf   compteur_lo,w
        btfss   STATUS,C
        goto    attente
        movlw   .250
        movwf   compteur_lo
        
attente
        call    delai_10ms
        
        ; Gérer clignotement si mode 50Hz
        btfsc   mode_freq,0         ; Mode 60Hz ? skip clignotement
        goto    boucle
        
        ; Mode 50Hz: clignoter LED
        incf    compteur_blink,f
        movlw   .25                 ; 25 x 10ms = 250ms
        subwf   compteur_blink,w
        btfss   STATUS,C
        goto    boucle
        
        ; Basculer LED
        clrf    compteur_blink
        btfss   LED
        goto    allumer_led
        bcf     LED
        goto    boucle
allumer_led
        bsf     LED
        goto    boucle

;******************************************************************************
; Bouton relâché
;******************************************************************************
relache
        movf    etat_bouton,f
        btfsc   STATUS,Z            ; N'était pas appuyé ?
        goto    idle_loop
        
        ; Fin d'appui
        clrf    etat_bouton
        
        ; Vérifier durée: >= 200 (2 secondes) ?
        movf    compteur_hi,w
        btfss   STATUS,Z            ; Si hi != 0, appui long
        goto    appui_long
        
        movlw   .200
        subwf   compteur_lo,w
        btfsc   STATUS,C            ; Si C=1, >= 200
        goto    appui_long
        
        ; Appui court: générer reset
appui_court
        bcf     CPU_RST             ; 0V sur reset CPU
        call    delai_100ms         ; 100ms
        bsf     CPU_RST             ; Revenir à 5V
        goto    fin_action

        ; Appui long: changer fréquence
appui_long
        movf    mode_freq,w
        xorlw   0x01                ; Basculer bit 0
        movwf   mode_freq
        
        btfsc   mode_freq,0
        goto    passer_60hz
        
        ; Passer en 50Hz
        bcf     FREQ_OUT            ; 0V
        clrf    compteur_blink
        goto    fin_action
        
passer_60hz
        bsf     FREQ_OUT            ; 5V
        bsf     LED                 ; LED fixe ON
        clrf    compteur_blink

fin_action
        clrf    compteur_lo
        clrf    compteur_hi

idle_loop
        call    delai_10ms
        
        ; Gérer clignotement si mode 50Hz
        btfsc   mode_freq,0
        goto    boucle
        
        incf    compteur_blink,f
        movlw   .25
        subwf   compteur_blink,w
        btfss   STATUS,C
        goto    boucle
        
        clrf    compteur_blink
        btfss   LED
        goto    allumer_led2
        bcf     LED
        goto    boucle
allumer_led2
        bsf     LED
        goto    boucle

;******************************************************************************
; Délai 10ms (oscillateur interne 4MHz)
;******************************************************************************
delai_10ms
        movlw   .13
        movwf   temp1
d10_ext
        movlw   .255
        movwf   temp2
d10_int
        decfsz  temp2,f
        goto    d10_int
        decfsz  temp1,f
        goto    d10_ext
        retlw   0

;******************************************************************************
; Délai 100ms
;******************************************************************************
delai_100ms
        movlw   .10
        movwf   temp3
d100_loop
        call    delai_10ms
        decfsz  temp3,f
        goto    d100_loop
        retlw   0

        END