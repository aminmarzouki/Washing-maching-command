	errorlevel -302
;*---------------------------DÉFINITION DU PIC ET IMPORTATION DES BIBLIOS----------------------------*
	list p=16F877
	#include <P16F877.INC>
	__CONFIG _HS_OSC & _WDT_OFF & _CP_OFF & _CPD_OFF & _LVP_OFF
;*------------------------------------------------------------------------------------------------------------------*
;*-------------------------------DÉCLARATION DES DIFFÉRENTS VARIABLES--------------------------------*
X1 EQU .100
X2 EQU .220
X3 EQU .226

X4 EQU .200
X5 EQU .219
X6 EQU .227

X7 EQU .255
X8 EQU .255
X9 EQU .255

X10 EQU .100
X11 EQU .40
X12 EQU .5

X13 EQU .1
X14 EQU .1
X15 EQU .1

X16 EQU .1
X17 EQU .1
X18 EQU .1

	CBLOCK 0X20
	CMPT1:1
	CMPT2:1
	CMPT3:1
	
	CMPT4:1
	CMPT5:1
	CMPT6:1
	
	CMPT7:1
	CMPT8:1
	CMPT9:1
	
	CMPT10:1
	CMPT11:1
	CMPT12:1
	
	CMPT13:1
	CMPT14:1
	CMPT15:1
	
	CMPT16:1
	CMPT17:1
	CMPT18:1
	
	TEMP_W:1	
	TEMP_ST:1
	
	N: 1
	nn: 1
	vv: 1
	bb: 1
	nnn: 1
	vvv: 1
	bbb: 1
	nnnn: 1
	vvvv: 1
	bbbb: 1
	yy: 1
	TEMPERATURE: 1
	VITESSE: 1
	RINCAGE: 1
	ESSORAGE: 1
	SEC_U: 1
	SEC_D: 1
	MIN_U: 1
	MIN_D: 1
	MIN_D_MAX: 1
	SELPROG: 1
	SELTEMP: 1
	SELSPD: 1
	SELRINC: 1
	SELESS: 1
	CMPTF: 1	
	ENDC
;*------------------------------------------------------------------------------------------------------------------*
;*-----------------------------------------DÉFINITION DES MACROS------------------------------------------*
BANK0 macro
	bsf STATUS, RP0
	bsf STATUS, RP1
	endm

BANK1 macro
	bcf STATUS, RP0
	bsf STATUS, RP1
	endm

BANK2 macro
	bsf STATUS, RP0
	bcf STATUS, RP1
	endm

BANK3 macro
	bcf STATUS, RP0
	bcf STATUS, RP1
	endm
;*------------------------------------------------------------------------------------------------------------------*
;*-------------------------------DÉFINITION VECTEUR RESET ET INTERRUPT--------------------------------*
;Vecteur RESET
	org 0
	goto main_program
	
;Vecteur INTERRUPT
	org 4
	goto PROGRAM_SELECT
;*------------------------------------------------------------------------------------------------------------------*
;*--------------------------------------------INTERRUPT ROUTINE---------------------------------------------*
PROGRAM_SELECT:
					        ;----------------------------------------
					      ;SAUVEGARDER L'ENVIRONNEMENT
	movwf TEMP_W
	swapf STATUS,W
	movwf TEMP_ST
					      ;ALLUMER LA LED DU CHARGEMENT
	bsf PORTC,3
			     ;DES TESTS SUR LES FLAGS (PRIORITIZATION: INT/RBI/TMR0)
TESTS:
	btfss INTCON,INTF
	goto CHECK_HEAT
	goto TRAITEMENT_INT
					             ;TRAITEMENT INT INTERRUPT
TRAITEMENT_INT:
	bcf INTCON,INTF
	movlw 0x07
	movwf SELPROG
	decfsz SELPROG,f
	goto TESTS
	goto TRAITEMENT_INT
						  ;TRAITEMENT RBI INTERRUPTS
CHECK_HEAT:
	btfss PORTB,RB4
	goto CHECK_SPD
	bcf INTCON,RBIF
FINSELTEMP:
	movlw 0x05
	movwf SELTEMP
	decfsz SELTEMP,f
	goto TESTS
	goto FINSELTEMP

CHECK_SPD:
	btfss PORTB,RB5
	goto CHECK_RINC
	bcf INTCON,RBIF
FINSELSPD:
	movlw 0x05
	movwf SELSPD
	decfsz SELSPD,f
	goto TESTS
	goto FINSELSPD

CHECK_RINC:
	btfss PORTB,RB6
	goto CHECK_ESS
	bcf INTCON,RBIF
FINSELRINC:
	movlw 0x04
	movwf SELRINC
	decfsz SELRINC,f
	goto TESTS
	goto FINSELRINC

CHECK_ESS:
	btfss PORTB,RB7
	goto TRAITEMENT_VALIDATION
	bcf INTCON,RBIF
FINSELESS:
	movlw 0x04
	movwf SELESS
	decfsz SELESS,f
	goto TESTS
	goto TEST_TMR0
						 ;TRAITEMENT TMR0 INTERRUPT
TEST_TMR0:
	btfss PORTA,1
	goto TRAITEMENT_VALIDATION
	goto TRAITEMENT_AFFICHE

TRAITEMENT_VALIDATION:
	bcf	INTCON,T0IF
	decfsz N,f
	goto ETEINDRE_CHARGEMENT
  	movlw .244
  	movwf N

  	incf SEC_U,f
  	movlw .10
  	subwf SEC_U,W
  	btfss STATUS,Z
  	goto ETEINDRE_CHARGEMENT
  
Clear_Sec_Digit1:

 	clrf SEC_U
 	incf SEC_D,f
 	movlw .3
 	subwf SEC_D,W
 	btfss STATUS,Z
 	goto ETEINDRE_CHARGEMENT
 	goto Clear_Sec_Digit2

Clear_Sec_Digit2:
 	clrf SEC_D
 	movf SEC_U,f
 	btfsc STATUS,Z
 	goto SUITE_TRAITEMENT
 	goto ETEINDRE_CHARGEMENT
SUITE_TRAITEMENT:
 	btfss PORTA,0
 	goto END_PROGRAM
 	goto ETEINDRE_CHARGEMENT
 
END_PROGRAM:
 	clrf PORTA
 	clrf PORTB
 	clrf PORTC
 	clrf PORTD
 	swapf TEMP_ST,W
 	movwf STATUS
 	swapf TEMP_W,f
 	swapf TEMP_W,W
 	goto EEND
 	retfie
TRAITEMENT_AFFICHE:
 	bcf	INTCON,T0IF
  	decfsz N,f
  	goto ETEINDRE_CHARGEMENT
					
  	movlw .244
  	movwf N

  	incf SEC_U,f
  	movlw .10
  	subwf SEC_U,W
  	btfss STATUS,Z
  	goto ETEINDRE_CHARGEMENT

 	clrf SEC_U
 	incf SEC_D,f
	movlw .6
 	subwf SEC_D,W
 	btfss STATUS,Z
 	goto ETEINDRE_CHARGEMENT

	clrf SEC_D

rtc_min: 					
	incf MIN_U,f
 	movlw .10
 	subwf MIN_U,W
 	btfss STATUS,Z
 	goto ETEINDRE_CHARGEMENT

Clear_Min_Digit1:
	clrf MIN_U

 	incf MIN_D,f
 	movf MIN_D_MAX,W
 	subwf MIN_D,W
 	btfsc STATUS,Z
 	goto ETEINDRE_CHARGEMENT

Clear_Min_Digit2:
	clrf MIN_D
					       ;ÉTEINDRE LA LED DU CHARGEMENT
ETEINDRE_CHARGEMENT:
	bcf PORTC,3
						;RESTAURER L'ENVIRONNEMENT
	swapf TEMP_ST,W
 	movwf STATUS
 	swapf TEMP_W,f
 	swapf TEMP_W,W
 	retfie
					        ;----------------------------------------
;*------------------------------------------------------------------------------------------------------------------*
;*-------------------------------------DÉBUT PROGRAMME PRINCIPALE--------------------------------------*
main_program:
					        ;----------------------------------------
						     ;PORTS CONFIGURATION
	call		IOSETTINGS
						      ;TMR0 CONFIGURATION
	call		TMR0CONFIG
						;INTERRUPTS CONFIGURATION
	call		INTSETTINGS
						        ;TMR0 INITIALIZATION
	call		TMR0INIT
					        ;----------------------------------------
						  ;TRAITEMENT MAIN PROGRAM
CHARGEMENT:
	movlw 0x01
	subwf SELPROG,W
	btfss STATUS,Z
	goto else1 
	call COTTON
	goto VERROUILLAGE_PORTE
else1:
		movlw 0x02
		subwf SELPROG,W
		btfss STATUS,Z
		goto else2 
		call LINGE_MAISON
		goto VERROUILLAGE_PORTE
else2:
		movlw 0x03
		subwf SELPROG,W
		btfss STATUS,Z
		goto else3 
		call SYNTHETIQUE
		goto VERROUILLAGE_PORTE
else3:
		movlw 0x04
		subwf SELPROG,W
		btfss STATUS,Z
		goto else4 
		call HYGIENE
		goto VERROUILLAGE_PORTE
else4:
		movlw 0x05
		subwf SELPROG,W
		btfss STATUS,Z
		goto else5 
		call BABYCARE
		goto VERROUILLAGE_PORTE
else5:
		movlw 0x06
		subwf SELPROG,W
		btfss STATUS,Z
		goto else6 
		call COUETTE
		goto VERROUILLAGE_PORTE
else6:
		movlw 0x07
		subwf SELPROG,W
		btfss STATUS,Z
		goto VERROUILLAGE_PORTE 
		call DELICAT

VERROUILLAGE_PORTE:
	btfss PORTA,1
	goto ETEINDRE_MACHINE
	bsf PORTC,0
	goto REMP_CHAUFF_EAU

ETEINDRE_MACHINE:
 	clrf PORTA
 	clrf PORTB
 	clrf PORTC
 	clrf PORTD
 	goto EEND
 
REMP_CHAUFF_EAU:
 	movlw 0x01
	subwf SELPROG,W
	btfss STATUS,Z
	goto else11
	call REMP_CHAUFF_1
	goto LAVAGE
else11:
		movlw 0x02
		subwf SELPROG,W
		btfss STATUS,Z
		goto else21 
		call REMP_CHAUFF_2
		goto LAVAGE
else21:
		movlw 0x03
		subwf SELPROG,W
		btfss STATUS,Z
		goto else31 
		call REMP_CHAUFF_3
		goto LAVAGE
else31:
		movlw 0x04
		subwf SELPROG,W
		btfss STATUS,Z
		goto else41
		call REMP_CHAUFF_1
		goto LAVAGE
else41:
		movlw 0x05
		subwf SELPROG,W
		btfss STATUS,Z
		goto else51 
		call REMP_CHAUFF_2
		goto LAVAGE
else51:
		movlw 0x06
		subwf SELPROG,W
		btfss STATUS,Z
		goto else61
		call REMP_CHAUFF_2
		goto LAVAGE
else61:
		call REMP_CHAUFF_1
		goto LAVAGE

LAVAGE:
	movlw 0x01
	subwf VITESSE,W
	btfss STATUS,Z
	goto else1112
	goto LAV_1
else1112:
		movlw 0x02
		subwf VITESSE,W
		btfss STATUS,Z
		goto else2112 
		goto LAV_2
else2112:
		movlw 0x03
		subwf VITESSE,W
		btfss STATUS,Z
		goto else3112 
		goto LAV_3
else3112:
		movlw 0x04
		subwf VITESSE,W
		btfss STATUS,Z
		goto else4112
		goto LAV_4
else4112:
		goto LAV_5

LAV_1:
	movlw 0x01
	movwf MIN_D_MAX
	bsf PORTB,4
  	bsf PORTB,2
  	movf  MIN_U,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bsf PORTB,1
  	movf  MIN_D,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bcf PORTB,4
  	goto VIDANGE
  
LAV_2:
	movlw 0x02
	movwf MIN_D_MAX
	bsf PORTB,4
  	bsf PORTB,2
  	movf  MIN_U,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bsf PORTB,1
  	movf  MIN_D,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bcf PORTB,4
  	goto VIDANGE
  
LAV_3:
	movlw 0x03
	movwf MIN_D_MAX
	bsf PORTB,4
  	bsf PORTB,2
  	movf  MIN_U,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bsf PORTB,1
  	movf  MIN_D,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bcf PORTB,4
  	goto VIDANGE
  
LAV_4:
	movlw 0x04
	movwf MIN_D_MAX
	bsf PORTB,4
  	bsf PORTB,2
  	movf  MIN_U,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bsf PORTB,1
  	movf  MIN_D,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bcf PORTB,4
  	goto VIDANGE
  
LAV_5:
	movlw 0x06
	movwf MIN_D_MAX
	bsf PORTB,4
  	bsf PORTB,2
  	movf  MIN_U,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bsf PORTB,1
  	movf  MIN_D,W
  	call  tabBCD_Cathodes_Communes
  	movwf PORTD
  	call  tempo
  	bcf PORTB,4
  	goto VIDANGE

VIDANGE:
	movlw 0x01
	subwf SELPROG,W
	btfss STATUS,Z
	goto else111
	call VIDANGE_1
	goto RINÇAGE
else111:
		movlw 0x02
		subwf SELPROG,W
		btfss STATUS,Z
		goto else211 
		call VIDANGE_2
		goto RINÇAGE
else211:
		movlw 0x03
		subwf SELPROG,W
		btfss STATUS,Z
		goto else311 
		call VIDANGE_3
		goto RINÇAGE
else311:
		movlw 0x04
		subwf SELPROG,W
		btfss STATUS,Z
		goto else411
		call VIDANGE_1
		goto RINÇAGE
else411:
		movlw 0x05
		subwf SELPROG,W
		btfss STATUS,Z
		goto else511
		call VIDANGE_2
		goto RINÇAGE
else511:
		movlw 0x06
		subwf SELPROG,W
		btfss STATUS,Z
		goto else611
		call VIDANGE_2
		goto RINÇAGE
else611:
		call VIDANGE_1
		goto RINÇAGE

RINÇAGE:
	movlw 0x01
	subwf RINCAGE,W
	btfss STATUS,Z
	goto else113
	goto RINCAGE_1
else113:
		movlw 0x02
		subwf RINCAGE,W
		btfss STATUS,Z
		goto else213 
		goto RINCAGE_2
else213:
		movlw 0x03
		subwf RINCAGE,W
		btfss STATUS,Z
		goto else313 
		goto RINCAGE_3
else313:
		goto RINCAGE_4

RINCAGE_1:
	bsf PORTB,6
	movlw 0x02
	movwf yy
dic	decfsz yy,f
	goto traitement_rin
	goto end_rincage
traitement_rin:
	call REMP_CHAUFF_1
	call VIDANGE_1
end_rincage:
	goto ESSORAGE_TRT

RINCAGE_2:
	bsf PORTB,6
	movlw 0x02
	movwf yy
dic1	decfsz yy,f
	goto traitement_rin1
	goto end_rincage1
traitement_rin1:
	call REMP_CHAUFF_2
	call VIDANGE_2
end_rincage1:
	goto ESSORAGE_TRT

RINCAGE_3:
	bsf PORTB,6
	movlw 0x02
	movwf yy
dic2	decfsz yy,f
	goto traitement_rin2
	goto end_rincage2
traitement_rin2:
	call REMP_CHAUFF_3
	call VIDANGE_3
end_rincage2:
	goto ESSORAGE_TRT

RINCAGE_4:
	bsf PORTB,6
	movlw 0x04
	movwf yy
dic3	decfsz yy,f
	goto traitement_rin3
	goto end_rincage3
traitement_rin3:
	call REMP_CHAUFF_3
	call VIDANGE_3
end_rincage3:
	goto ESSORAGE_TRT

ESSORAGE_TRT:
	movlw 0x01
	subwf ESSORAGE,W
	btfss STATUS,Z
	goto else1111
	call ESSORAGE_1
	goto DEVERR_PORTE
else1111:
		movlw 0x02
		subwf ESSORAGE,W
		btfss STATUS,Z
		goto else2111
		call ESSORAGE_2
		goto DEVERR_PORTE
else2111:
		call ESSORAGE_3
		goto DEVERR_PORTE

DEVERR_PORTE:
	clrf PORTA
 	clrf PORTB
 	clrf PORTC
 	clrf PORTD
 	goto EEND
					        ;----------------------------------------
;*------------------------------------------------------------------------------------------------------------------*
;*--------------------------------------------------FUNCTIONS--------------------------------------------------*
IOSETTINGS
	BANK1
	movlw 0x06
	movwf ADCON1
	BANK0
	movlw 0x00
	movwf TRISC
	movlw 0xF1
	movwf TRISB
	movlw 0xFF
	movwf TRISD
	movlw 0x03
	movwf TRISA
	return

TMR0CONFIG
	BANK1
	movlw 0XC4
	movwf OPTION_REG
	BANK0
	return

INTSETTINGS
	clrf INTCON
	movlw 0xB8
	movwf INTCON
	return

TMR0INIT
	clrf TMR0
	movlw .244
	movwf N
	clrf SEC_U
	clrf SEC_D
	return

VARINIT
	return

COTTON 
	movlw 0x03
	movwf TEMPERATURE
	movlw 0x05
	movwf VITESSE
	movlw 0x04
	movwf RINCAGE
	movlw 0x03
	movwf ESSORAGE
	return

LINGE_MAISON 
	movlw 0x04
	movwf TEMPERATURE
	movlw 0x05
	movwf VITESSE
	movlw 0x04
	movwf RINCAGE
	movlw 0x03
	movwf ESSORAGE
	return

SYNTHETIQUE 
	movlw 0x03
	movwf TEMPERATURE
	movlw 0x04
	movwf VITESSE
	movlw 0x03
	movwf RINCAGE
	movlw 0x02
	movwf ESSORAGE
	return

HYGIENE 
	movlw 0x03
	movwf TEMPERATURE
	movlw 0x05
	movwf VITESSE
	movlw 0x04
	movwf RINCAGE
	movlw 0x03
	movwf ESSORAGE
	return

BABYCARE 
	movlw 0x04
	movwf TEMPERATURE
	movlw 0x03
	movwf VITESSE
	movlw 0x02
	movwf RINCAGE
	movlw 0x02
	movwf ESSORAGE
	return

COUETTE 
	movlw 0x03
	movwf TEMPERATURE
	movlw 0x03
	movwf VITESSE
	movlw 0x02
	movwf RINCAGE
	movlw 0x02
	movwf ESSORAGE
	return

DELICAT 
	movlw 0x01
	movwf TEMPERATURE
	movlw 0x02
	movwf VITESSE
	movlw 0x01
	movwf RINCAGE
	movlw 0x01
	movwf ESSORAGE
	return

TEMPO_15S
		movlw X1
		movwf CMPT1 
dec1:		movlw X2
	       	movwf CMPT2
dec2:      	movlw X3
	       	movwf CMPT3 
dec3:      	decfsz CMPT3,f       
	       	goto dec3 	       
	       	decfsz CMPT2,f 
	       	goto dec2 
	       	decfsz CMPT1,f
	       	goto dec1 
		return

TEMPO_30S
		movlw X4
		movwf CMPT4 
dec11:	movlw X5
	       	movwf CMPT5
dec21:      	movlw X6
	       	movwf CMPT6 
dec31:      	decfsz CMPT6,f       
	       	goto dec31 	       
	       	decfsz CMPT5,f 
	       	goto dec21
	       	decfsz CMPT4,f
	       	goto dec11
		return

TEMPO_50S
		movlw X7
		movwf CMPT7 
dec111:	movlw X8
	       	movwf CMPT8
dec211:      	movlw X9
	       	movwf CMPT9 
dec311:      	decfsz CMPT9,f       
	       	goto dec311 	       
	       	decfsz CMPT8,f 
	       	goto dec211
	       	decfsz CMPT7,f
	       	goto dec111
		return

tempo
	       movlw X10
	       movwf CMPT10
dec12:      movlw X11
	       movwf CMPT11
dec22:      movlw X12
	       movwf CMPT12
dec32:      decfsz CMPT12,f       
	       goto dec32 	       
	       decfsz CMPT11,f 
	       goto dec22
	       decfsz CMPT10,f
	       goto dec12
		   return

REMP_CHAUFF_1:
	bsf PORTC,1
	bsf PORTC,2
	movlw 0x04
	movwf nn
con
		decfsz nn,f
		goto traitement_tempo_1
		goto end_r_c_1
traitement_tempo_1
		call TEMPO_30S
		goto con
end_r_c_1
		bcf PORTC,1
		bcf PORTC,2
		return

REMP_CHAUFF_2:
	bsf PORTC,1
	bsf PORTC,2
	movlw 0x07
	movwf vv
con1
		decfsz vv,f
		goto traitement_tempo_2
		goto end_r_c_2
traitement_tempo_2
		call TEMPO_15S
		goto con1
end_r_c_2
		bcf PORTC,1
		bcf PORTC,2
		return

REMP_CHAUFF_3:
	bsf PORTC,1
	bsf PORTC,2
	movlw 0x03
	movwf bb
con2
		decfsz bb,f
		goto traitement_tempo_3
		goto end_r_c_3
traitement_tempo_3
		call TEMPO_30S
		goto con2
end_r_c_3
		bcf PORTC,1
		bcf PORTC,2
		return

VIDANGE_1:
	bsf PORTC,5
	movlw 0x04
	movwf nnn
con4
		decfsz nnn,f
		goto traitement_tempo_11
		goto end_r_c_11
traitement_tempo_11
		call TEMPO_30S
		goto con4
end_r_c_11
		bcf PORTC,5
		return

VIDANGE_2:
	bsf PORTC,5
	movlw 0x07
	movwf vvv
con5
		decfsz vvv,f
		goto traitement_tempo_21
		goto end_r_c_21
traitement_tempo_21
		call TEMPO_15S
		goto con5
end_r_c_21
		bcf PORTC,5
		return

VIDANGE_3:
	bsf PORTC,5
	movlw 0x03
	movwf bbb
con6
		decfsz bbb,f
		goto traitement_tempo_31
		goto end_r_c_31
traitement_tempo_31
		call TEMPO_30S
		goto con6
end_r_c_31
		bcf PORTC,5
		return

ESSORAGE_1:
	bsf PORTC,7
	movlw .6
	movwf nnnn
con7
		decfsz nnnn,f
		goto traitement_tempo_111
		goto end_r_c_111
traitement_tempo_111
		call TEMPO_50S
		goto con7
end_r_c_111
		bcf PORTC,7
		return

ESSORAGE_2:
	bsf PORTC,7
	movlw .10
	movwf vvvv
con8
		decfsz vvvv,f
		goto traitement_tempo_211
		goto end_r_c_211
traitement_tempo_211
		call TEMPO_50S
		goto con8
end_r_c_211
		bcf PORTC,7
		return

ESSORAGE_3:
	bsf PORTC,7
	movlw .17
	movwf bbbb
con9
		decfsz bbbb,f
		goto traitement_tempo_311
		goto end_r_c_311
traitement_tempo_311
		call TEMPO_50S
		goto con9
end_r_c_311
		bcf PORTC,7
		return

tabBCD_Cathodes_Communes:
	ADDWF PCL,F
	retlw 0x3F	; BCD 0
	retlw 0x06  ; BCD 1
	retlw 0x5B  ; BCD 2
	retlw 0x4F  ; BCD 3
	retlw 0x66  ; BCD 4
	retlw 0x6D  ; BCD 5
	retlw 0x7D	; BCD 6
	retlw 0x07	; BCD 7
	retlw 0x7F	; BCD 8
	retlw 0x6F	; BCD 9
	retlw 0x77	; BCD A
	retlw 0x7C	; BCD B
	retlw 0x39	; BCD C
	retlw 0x5E	; BCD D
	retlw 0x79	; BCD E
	retlw 0x71	; BCD F
;*------------------------------------------------------------------------------------------------------------------*
;*--------------------------------------FIN PROGRAMME ASSEMBLEUR---------------------------------------
EEND:
	END
;*------------------------------------------------------------------------------------------------------------------*