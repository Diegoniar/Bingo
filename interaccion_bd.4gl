DATABASE empresa

FUNCTION guardar_bingo (r_bingo)
DEFINE r_bingo RECORD
	idbingo     LIKE bingo.idbingo,
	nombrebingo LIKE bingo.nombrebingo,
	fechabingo  LIKE bingo.fechabingo,
	estado      LIKE bingo.estado,
    imagen      STRING 
END RECORD

INSERT INTO bingo
VALUES (r_bingo.idbingo,r_bingo.nombrebingo,r_bingo.fechabingo,r_bingo.estado,r_bingo.imagen)

IF status <> 0 THEN
    CALL fgl_winmessage("Bingos Comfaoriente","Ocurrió un error durante el registro: "||SQLERRMESSAGE,"stop")
    RETURN FALSE
ELSE
    RETURN TRUE 
END IF 
END FUNCTION 