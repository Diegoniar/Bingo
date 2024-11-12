DATABASE empresa

DEFINE r_formulario, c_formulario RECORD
        idBingo           LIKE bingo.idbingo,
        coddoc            LIKE gener18.coddoc,
        documentoAfiliado LIKE bingo_formulario.documentoafiliado,
        nombreAfiliado    STRING, 
        nit               LIKE subsi15.nit,
        razsoc            LIKE subsi02.razsoc,
        codcat            LIKE subsi15.codcat
       END RECORD 

FUNCTION abrir_formulario_principal ()
DEFINE cb_codoc ui.ComboBox,
       cb_bingo ui.Combobox
   
OPEN WINDOW w_formulario WITH FORM "b_formulario"

--LET n = image( ui.Interface.filenameToURI("/home/jinformix/posters/bingo-story-julio-2024-576x1024.png"),
  --                          100,100,50,50, "xMidYMid meet" )

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

INPUT BY NAME r_formulario.idBingo THRU r_formulario.documentoAfiliado WITHOUT DEFAULTS
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
        IF NOT existe_afiliado (r_formulario.coddoc, r_formulario.documentoAfiliado) THEN
            NEXT FIELD coddoc
        ELSE
            CALL traer_nombre_afiliado(r_formulario.coddoc, r_formulario.documentoAfiliado) RETURNING r_formulario.nombreAfiliado
            CALL traer_empresa(r_formulario.coddoc, r_formulario.documentoAfiliado) RETURNING r_formulario.nit, r_formulario.razsoc, r_formulario.codcat
            DISPLAY BY NAME r_formulario.nit, r_formulario.razsoc, r_formulario.codcat, r_formulario.nombreAfiliado
        END IF 
    END IF
END INPUT 
END FUNCTION 