DEF DIG0 0x90           ; Kijelzõ DIG0 adatregiszter           (írható/olvasható)
DEF DIG1 0x91           ; Kijelzõ DIG1 adatregiszter           (írható/olvasható)
DEF BT   0x84           ; Nyomógomb adatregiszter              (csak olvasható)
DEF LD   0x80

CODE
init:                   ;Initialisation aller Register, die benutzt wird
    mov r0, #0x00
    mov r1, #0x00
    mov r8, #0x00
    mov r9, #0x00
    mov r10, #0x00
    mov r11, #0x00
    mov r12, #0x00
    mov r13, #0x00
    mov r14, #0x00
    mov r15, #0x00

wait_bt:
    mov r1, BT          ;Zustand der Drucktasten wird eingelesen
    tst r1, #0x01       ;Maskierung ob BT0 gedruckt ist
    jnz pressed         ;Wenn BT0 gedruckt war, springen wir weiter
    add r0, #0x01       ;Zunahme der "Zufallszahl"
    cmp r0, #0x51       ;Ist die Wert der Zufallszahl 81?
    jnz wait_bt         ;Nein -> wir springen züruck und testen die Drucktasten noch einmal
    mov r0, #0x00       ;Ja -> die Wert der Zufallszahl wird auf 0 gestellt
    jmp wait_bt         ;springt züruck bedingungslos
    
pressed:
    add r0, #0x0A       ;die Wert der Zufallszahl wird zwischen 10 und 90 sein -> so viel mal soll das Programm 0,1 Sekunde warten
    jsr print_digits    ;die neue Wert der Zufallszahl wird auf dem 7 Segmente Anzeige gedruckt
leds_on:
    mov r1, #0x01       ;r1 = 1
    mov LD, r1          ;erste LED ist aufgeschaltet
    jsr wait_1sec       ;das Programm wartet 1 Sekunde
    sl1 r1              ;r1 = 3, binär: 0000_0011
    mov LD, r1          ;erste und zweite LED sind aufgeschaltet
    jsr wait_1sec       ;das Programm wartet 1 Sekunde
    sl1 r1              ;r1 = 7, binär: 0000_0111
    mov LD, r1          ;erste drei LEDs sind aufgeschaltet
    jsr wait_1sec       ;Das Programm wartet 1 Sekunde
    sl1 r1              ;r1 = 15, binär: 0000_1111
    mov LD, r1          ;erste vier LEDs sind aufgeschaltet
    jsr wait_1sec       ;das Programm wartet 1 Sekunde
    sl1 r1              ;r1 = 31, binär: 0001_1111
    mov LD, r1          ;erste fünf LEDs sind aufgeschaltet
countdown:
    jsr wait_01sec      ;das Programm wartet 0,1 Sekunde
    sub r0, #0x01       ;Reduktion der Wert der Zufallszahl
    cmp r0, #0x00       ;Ist die Wert der Zufallszahl 0?
    jz leds_off         ;Ja -> Ausschalten der LEDs
    jmp countdown       ;Nein -> das Programm springt bedingungslos züruckt und reduziert die Wert weiter

leds_off:
    mov LD, r0          ;r0 ist sicherlich null -> LEDs ausgeschaltet
    jmp leds_off        ;Unendliche Schleife, das Programm beendet nicht

print_digits:           ;Berechnung von Ganzteil und Bruchteil, dann ausdrucken
    mov r11, r0         ;die Wert der Zufallszahl wird in r11 kopiert
    sub r11, #0x0A      ;die Wert is sicherlich größer als 10, wegen der Linie 37
get_int:                ;Ganzteil
    add r12, #0x01      ;Bezählung wie viel mal können wir 10 aus der Zufallszahl subtrahieren
    sub r11, #0x0A      ;Subtrahierung
    jz counting_done    ;Wenn r11 0 beträgt, gibt es keine Bruchteil und wir können die Zahl ausdrucken
    jnn get_int         ;Wenn r11 weder 0 noch negativ ist, wiederholen wir diese Zyklus
    add r11, #0x0A      ;Wenn r11 negativ ist -> r11 + 10 ergibt die Bruchteil
counting_done:
    mov r10, #DISP_LUT  ;Anfangsadresse der LUT
    mov r9, r10         ;r9 wird auf die Anfangsadresse der LUT zeigen
    add r9, r12         ;Verschiebung der Zeiger mit der Wert der Ganzteil
    mov r8, (r9)        ;r8 = die Wert auf die von r9 gezeigte Adresse
    or r8, #0x80        ;Dezimalkomma wird zugefügt
    mov DIG1, r8        ;die Ganzteil wird auf DIG1 angezeigt
    mov r9, r10         ;r9 wird auf die Anfangsadresse der LUT zeigen
    add r9, r11         ;Verschiebung der Zeiger mit der Wert der Bruchteil
    mov r8, (r9)        ;r8 = die Wert auf die von r9 gezeigte Adresse
    mov DIG0, r8        ;die Bruchteil wird auf DIG0 angezeigt
rts


wait_1sec:              ;5.592.411 Anweisung * 187,5ns(FETCH, DECODE, EXECUTE) * 10^-9 = 1,049s
    mov r13, #0x00
    mov r14, #0x00
    mov r15, #0x00
count:
    add r13, #0x0C
    adc r14, #0x00
    adc r15, #0x00
    jnc count
rts


wait_01sec:             ;559.247 Anweisung * 187,5ns * 10^-9 = 0,1049s
    mov r13, #0x00
    mov r14, #0x00
    mov r15, #0x00
count01:
    add r13, #0x78
    adc r14, #0x00
    adc r15, #0x00
    jnc count01
rts

DATA
    DISP_LUT:           ;LOOKUPTABLE für die 7 Segment Anzeige
    DB 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F