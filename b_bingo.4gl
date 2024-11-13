DATABASE empresa

DEFINE r_bingo, c_bingo RECORD
	idbingo     LIKE bingo.idbingo,
	nombrebingo LIKE bingo.nombrebingo,
	fechabingo  LIKE bingo.fechabingo,
	estado      LIKE bingo.estado,
    imagen      STRING 
END RECORD

FUNCTION b_bingo_main()
OPEN WINDOW w_bingo WITH FORM "b_bingo"

MENU
    ON ACTION Adicionar
        CALL adicionar_bingo()

    ON ACTION Consulta
        CALL consulta_bingo ()
        
    ON ACTION salir
        EXIT MENU
END MENU 
CLOSE WINDOW w_bingo
END FUNCTION 

FUNCTION adicionar_bingo()
DEFINE gerrflag SMALLINT 

IF int_flag THEN
    LET int_flag = FALSE
END IF

CLEAR FORM

MESSAGE "ESTADO: ADICION DE UN BINGO"  ATTRIBUTE(BLUE)

INITIALIZE r_bingo.* TO NULL
lABEL Ent_bingo:

INPUT BY NAME r_bingo.nombrebingo THRU r_bingo.estado WITHOUT DEFAULTS
BEFORE FIELD nombrebingo
    LET r_bingo.idbingo = traer_consecutivo_bingo ()
    DISPLAY r_bingo.idbingo TO idbingo

AFTER FIELD nombrebingo
    IF r_bingo.nombrebingo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No dígito un nombre para el bingo","stop")
        NEXT FIELD nombrebingo
    ELSE
        NEXT FIELD fechabingo
    END IF 

AFTER FIELD fechabingo
    IF r_bingo.fechabingo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No dígito una fecha para el bingo","stop")
        NEXT FIELD fechabingo
    ELSE
        IF NOT validar_fecha (r_bingo.fechabingo) THEN
            CALL fgl_winmessage("Bingos Comfaoriente","La fecha debe ser superior a hoy","stop")
            NEXT FIELD fechabingo
        ELSE
            NEXT FIELD estado
        END IF 
    END IF 

AFTER FIELD estado
    IF r_bingo.estado IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No seleccionó ningún estado","stop")
        NEXT FIELD fechabingo
    END IF

--ON ACTION poster 
    --LET r_bingo.imagen = agregar_imagenes ()

AFTER INPUT
    IF int_flag THEN
      EXIT INPUT
    ELSE 
        IF r_bingo.nombrebingo IS NULL OR r_bingo.fechabingo IS NULL OR 
           r_bingo.estado IS NULL OR (r_bingo.nombrebingo = "0") OR 
           (r_bingo.nombrebingo IS NULL) THEN
            CALL FGL_WINMESSAGE("Bingos Comfaoriente","CAMPOS OBLIGATORIOS ESTAN VACIOS","stop")
            GO TO Ent_bingo
        END IF 
    END IF 
END INPUT 

IF int_flag THEN
      CLEAR FORM
      CALL FGL_WINMESSAGE("Bingos Comfaoriente","LA ADICION FUE CANCELADA","STOP")
      MESSAGE ""
      INITIALIZE r_bingo.* TO NULL
      RETURN
END IF 

MESSAGE  "ADICIONANDO EL BINGO " ATTRIBUTE(REVERSE)
LET gerrflag = FALSE
BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT 

IF guardar_bingo (r_bingo.*) THEN
    CALL fgl_winmessage ("Bingos Comfaoriente","BINGO AGREGADO CON ÉXITO","informartion")
    COMMIT WORK 
ELSE
    ROLLBACK WORK 
END IF 
 
END FUNCTION 

FUNCTION consulta_bingo ()
END FUNCTION 