DATABASE empresa

DEFINE r_carton, g_carton RECORD
    idBingo LIKE bingo.idbingo
END RECORD 

FUNCTION bingo_cartones_principal()
DEFINE cb_bingo ui.Combobox

OPEN WINDOW w_carton WITH FORM "b_carton"
LET cb_bingo = llenar_combo_bingo ()

MENU
    ON ACTION sel_bingo
        CALL cargar_cartones ()
    ON ACTION salir
        EXIT MENU
END MENU 
CLOSE WINDOW w_carton
END FUNCTION 

FUNCTION cargar_cartones ()
INITIALIZE r_carton.* TO NULL
lABEL Ent_carton:

INPUT BY NAME r_carton.idBingo THRU r_carton.idBingo WITHOUT DEFAULTS
BEFORE FIELD idBingo
    SELECT FIRST 1 bingo.idBingo INTO r_carton.idBingo
    FROM   bingo
    WHERE  bingo.estado = "A"
    AND    bingo.fechabingo >= TODAY 
    ORDER  BY 1 ASC 
    
AFTER FIELD idBingo
    IF r_carton.idBingo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No seleccionó un bingo","stop")
        NEXT FIELD idBingo
    ELSE

        NEXT FIELD idBingo
    END IF 

ON ACTION cargar_cartones
    IF r_carton.idBingo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No seleccionó un bingo","stop")
        GO TO Ent_carton
    END IF 
    CALL cargar_cartones_lista()
    
AFTER INPUT 
    IF r_carton.idBingo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No seleccionó un bingo","stop")
        GO TO Ent_carton
    END IF 
END INPUT 
    
END FUNCTION 

FUNCTION cargar_cartones_lista()
DEFINE mruta2 STRING

CREATE TEMP TABLE cartones (nombre_carton VARCHAR(50))

CALL traer_ruta_carga () RETURNING mruta2
       
LOAD FROM mruta2
INSERT INTO cartones
IF status > 0 THEN
   CALL fgl_winmessage("Bingos Comfaoriente","EL ERROR: "||SQLERRMESSAGE,"stop")
END IF 

IF guardar_cartones() THEN
    CALL fgl_winmessage("Bingos Comfaoriente","CARTONES CARGADOS CON ÉXITO","information")
    DROP TABLE cartones
ELSE
    CALL fgl_winmessage("Bingos Comfaoriente","SE HA PRESENTADO UN ERROR, REVISE EL PLANO E INTENTE CARGARLO DE NUEVO","stop")
    DROP TABLE cartones
END IF 

END FUNCTION

FUNCTION guardar_cartones ()
DEFINE r_cartones RECORD
        nombre_carton VARCHAR(50)
       END RECORD,
       consec_car INTEGER, 
       cont       INTEGER   

INITIALIZE r_cartones.* TO NULL

DECLARE c_c CURSOR FOR
SELECT * FROM cartones

BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT 
FOREACH c_c INTO r_cartones.*
    IF existe_carton (r_cartones.nombre_carton, r_carton.idBingo) = 0 THEN 
        CALL traer_consecutivo_cartones () RETURNING consec_car
        
        INSERT INTO bingo_carton VALUES (consec_car,r_carton.idBingo,
                                         r_cartones.nombre_carton,NULL,NULL)
        IF status <> 0 THEN
            DISPLAY "Hubo problemas al guardar el carton: ",SQLERRMESSAGE 
            ROLLBACK WORK 
            RETURN FALSE 
        END IF 
    END IF 
END FOREACH 

COMMIT WORK 
RETURN TRUE 
END FUNCTION  