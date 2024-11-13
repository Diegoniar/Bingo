DATABASE empresa

DEFINE r_formulario, c_formulario RECORD
        idBingo           LIKE bingo.idbingo,
        coddoc            LIKE gener18.coddoc,
        documentoAfiliado LIKE bingo_formulario.documentoafiliado,
        nombreAfiliado    STRING, 
        nit               LIKE subsi15.nit,
        razsoc            LIKE subsi02.razsoc,
        codcat            LIKE subsi15.codcat,
        cupos             LIKE bingo_formulario.cupos,
        telefono          LIKE bingo_formulario.telefono,
        correo            LIKE bingo_formulario.correo
       END RECORD 

FUNCTION abrir_formulario_principal ()
DEFINE cb_codoc ui.ComboBox,
       cb_bingo ui.Combobox
   
OPEN WINDOW w_formulario WITH FORM "b_formulario"

CALL oculta_campo("label10")
CALL oculta_campo("label11")
CALL oculta_campo("label12")
CALL oculta_campo("telefono")
CALL oculta_campo("correo")


LET cb_bingo = llenar_combo_bingo ()
LET cb_codoc = llenar_combo_tipo_documento ()

MENU
    ON ACTION Adicionar
        CALL adicionar_formulario ()
    ON ACTION salir
        EXIT MENU
END MENU 
CLOSE WINDOW w_formulario
END FUNCTION 

FUNCTION adicionar_formulario()
IF int_flag THEN
    LET int_flag = FALSE
END IF

CLEAR FORM

MESSAGE "ESTADO: ADICIÓN DE FORMULARIO"  ATTRIBUTE(BLUE)

INITIALIZE r_formulario.* TO NULL
lABEL Ent_formulario:

INPUT BY NAME r_formulario.idBingo THRU r_formulario.correo WITHOUT DEFAULTS
AFTER FIELD idBingo
    IF r_formulario.idBingo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No seleccionó un bingo","stop")
        NEXT FIELD idBingo
    END IF 

AFTER FIELD coddoc
    IF r_formulario.coddoc IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No seleccionó un bingo","stop")
        NEXT FIELD coddoc
    END IF 

AFTER FIELD documentoAfiliado
    IF r_formulario.documentoAfiliado IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No digitó ningún documento","stop")
        NEXT FIELD documentoAfiliado
    ELSE
        IF NOT existe_afiliado (r_formulario.coddoc, r_formulario.documentoAfiliado) AND 
               Afiliado_ya_esta_en_el_bingo(r_formulario.idBingo,r_formulario.coddoc, r_formulario.documentoAfiliado) THEN
            NEXT FIELD coddoc
        ELSE
            CALL traer_nombre_afiliado(r_formulario.coddoc, r_formulario.documentoAfiliado) RETURNING r_formulario.nombreAfiliado
            CALL traer_empresa(r_formulario.coddoc, r_formulario.documentoAfiliado)         RETURNING r_formulario.nit, r_formulario.razsoc, r_formulario.codcat
            CALL calcular_cupos(r_formulario.coddoc, r_formulario.documentoAfiliado)        RETURNING r_formulario.cupos
            CALL traer_telefono(r_formulario.coddoc, r_formulario.documentoAfiliado)        RETURNING r_formulario.telefono, r_formulario.correo
            
            DISPLAY BY NAME r_formulario.nit, r_formulario.razsoc, r_formulario.codcat, r_formulario.nombreAfiliado,
                            r_formulario.cupos,r_formulario.telefono, r_formulario.correo

            CALL mostrar_campos_telefono_email ("label10","label11","label12","telefono","correo")
            NEXT FIELD telefono
        END IF 
    END IF

AFTER FIELD telefono
    IF r_formulario.telefono IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No digito un numero de telefono válido","stop")
        NEXT FIELD telefono
    ELSE
        LET r_formulario.telefono = r_formulario.telefono CLIPPED 
        IF NOT telefono_es_valido(r_formulario.telefono) THEN
            NEXT FIELD telefono
        END IF 
    END IF 

AFTER FIELD correo 
    IF r_formulario.correo IS NULL THEN
        CALL fgl_winmessage("Bingos Comfaoriente","No digito un correo electrónico válido","stop")
        NEXT FIELD correo
    ELSE
        LET r_formulario.correo = r_formulario.correo CLIPPED 
        IF NOT email_es_valido(r_formulario.correo) THEN
            CALL fgl_winmessage("Bingos Comfaoriente","El correo electrónico no es válido","stop")
            NEXT FIELD correo
        END IF 
    END IF 

AFTER INPUT 
    IF int_flag THEN
      EXIT INPUT
    ELSE 
        IF NOT validar_input_formulario() THEN
            CALL FGL_WINMESSAGE("Bingos Comfaoriente","CAMPOS OBLIGATORIOS ESTAN VACIOS","stop")
            GO TO Ent_FORMULARIO
        END IF 
    END IF 
END INPUT 
END FUNCTION 

FUNCTION validar_input_formulario()
IF r_formulario.idBingo IS NULL THEN
    RETURN FALSE 
END IF 

IF r_formulario.coddoc IS NULL THEN
    RETURN FALSE
END IF 

IF r_formulario.documentoAfiliado IS NULL THEN
    RETURN FALSE 
ELSE
    IF NOT existe_afiliado (r_formulario.coddoc, r_formulario.documentoAfiliado) AND 
            Afiliado_ya_esta_en_el_bingo(r_formulario.idBingo,r_formulario.coddoc, r_formulario.documentoAfiliado) THEN
        RETURN FALSE 
    END IF 
END IF

IF r_formulario.telefono IS NULL THEN
    RETURN FALSE 
ELSE
    LET r_formulario.telefono = r_formulario.telefono CLIPPED 
    IF NOT telefono_es_valido(r_formulario.telefono) THEN
        RETURN FALSE 
    END IF 
END IF 

IF r_formulario.correo IS NULL THEN
    RETURN FALSE 
ELSE
    LET r_formulario.correo = r_formulario.correo CLIPPED 
    IF NOT email_es_valido(r_formulario.correo) THEN
        RETURN FALSE 
    END IF 
END IF 

RETURN TRUE 
END FUNCTION 