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
        IF existe_afiliado (r_formulario.coddoc, r_formulario.documentoAfiliado)  THEN
            IF NOT Afiliado_ya_esta_en_el_bingo(r_formulario.idBingo,r_formulario.coddoc, r_formulario.documentoAfiliado) THEN 
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
        ELSE
            NEXT FIELD correo
        END IF 
    END IF 

ON ACTION ACCEPT  
        IF NOT validar_input_formulario() THEN
            CALL FGL_WINMESSAGE("Bingos Comfaoriente","CAMPOS OBLIGATORIOS ESTAN VACIOS","stop")
            GO TO Ent_FORMULARIO
        ELSE
            IF registrar_formulario () THEN
                CALL registro_beneficiarios () 
                CALL envio_cartones()
                CALL FGL_WINMESSAGE("Bingos Comfaoriente","REGISTRO EXITOSO Y ENVIO DE CARTONES AL CORREO EXITOSO","information")
            ELSE
                CALL FGL_WINMESSAGE("Bingos Comfaoriente","NO SE PUDO REALIZAR EL REGISTRO Y ENVIO","stop")
            END IF 
        END IF 

ON ACTION CANCEL
    EXIT INPUT 
    CLEAR FORM
    CALL FGL_WINMESSAGE("Bingos Comfaoriente","EL REGISTRO FUE CANCELADO","STOP")
    MESSAGE ""
    INITIALIZE r_formulario.* TO NULL
    RETURN
    
AFTER INPUT
    IF int_flag THEN
      EXIT INPUT
    ELSE 
        IF NOT validar_input_formulario() THEN
            CALL FGL_WINMESSAGE("Bingos Comfaoriente","CAMPOS OBLIGATORIOS ESTAN VACIOS","stop")
            GO TO Ent_FORMULARIO
        
        ELSE
            CALL FGL_WINMESSAGE("Bingos Comfaoriente","ingreso OK","information")
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

FUNCTION registrar_formulario ()
DEFINE consec_form INTEGER,
       priape      LIKE subsi15.priape,
       segape      LIKE subsi15.segape,
       nombre      LIKE subsi15.nombre,
       codzon      LIKE subsi15.codzon

BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT 

CALL traer_consecutivo_formulario () RETURNING consec_form


IF NOT existe_afiliado_bingo (r_formulario.coddoc, r_formulario.documentoAfiliado) THEN
    CALL datos_afiliado (r_formulario.coddoc, r_formulario.documentoAfiliado) RETURNING priape, segape,nombre,codzon
    INSERT INTO bingo_afiliado (tipodocumento,documentoafiliado,priape,segape,nombre,
                                categoria,codigomunicipio,nit)
                        VALUES (r_formulario.coddoc, r_formulario.documentoAfiliado,priape, segape,
                                nombre,r_formulario.codcat,codzon,r_formulario.nit)

    IF status <> 0 THEN
        DISPLAY "Error al guardar el afiliado: ",SQLERRMESSAGE
        ROLLBACK WORK 
        RETURN FALSE 
    ELSE
        CALL guardar_bingo_formulario(consec_form)

        IF status <> 0 THEN
            DISPLAY "Error al guardar el formulario: ",SQLERRMESSAGE
            ROLLBACK WORK 
            RETURN FALSE 
        ELSE 
            COMMIT WORK 
            RETURN TRUE
        END IF 
    END IF 
ELSE
    CALL guardar_bingo_formulario(consec_form)
    
    IF status <> 0 THEN
        DISPLAY "Error al guardar el formulario: ",SQLERRMESSAGE
        ROLLBACK WORK 
        RETURN FALSE 
    ELSE 
        COMMIT WORK
        RETURN TRUE 
    END IF 
END IF 
       
END FUNCTION

FUNCTION guardar_bingo_formulario(consec_form)
DEFINE consec_form LIKE bingo_formulario.idformulario
INSERT INTO bingo_formulario 
        (idformulario,tipodocumento,documentoafiliado,cupos,telefono,correo,idbingo)
        VALUES 
        (consec_form, r_formulario.coddoc, r_formulario.documentoAfiliado,r_formulario.cupos,
        r_formulario.telefono, r_formulario.correo, r_formulario.idBingo)
END FUNCTION 

FUNCTION registro_beneficiarios ()
DEFINE tipodocumento         LIKE bingo_beneficiario.tipodocumento,
       documentobeneficiario LIKE bingo_beneficiario.documentobeneficiario,
       priape                LIKE bingo_beneficiario.priape,
       segape                LIKE bingo_beneficiario.segape, 
       nombre                LIKE bingo_beneficiario.nombre

select subsi20.tipdoc,trim(subsi21.cedcon),
trim(subsi20.priape),NVL(trim(subsi20.segape),""),trim(subsi20.nombre)
INTO  tipodocumento,documentobeneficiario,priape,
      segape,nombre
FROM  subsi21,subsi20 
where subsi21.cedcon     = subsi20.cedcon
and   subsi21.cedtra     = r_formulario.documentoAfiliado
and   subsi21.tipdoc_tra = r_formulario.coddoc
and   subsi20.estado     = "A"

IF documentobeneficiario IS NOT NULL  THEN 
    IF NOT existe_beneficiario(tipodocumento, documentobeneficiario) THEN 
        INSERT INTO bingo_beneficiario(tipodocumento,documentobeneficiario,priape,
                                        segape,nombre,tipodocafi,documentoafil)
                                 VALUES(tipodocumento,documentobeneficiario,priape,
                                        segape,nombre,r_formulario.coddoc,
                                        r_formulario.documentoAfiliado)

        IF status <> 0 THEN
            DISPLAY "Error al registrar un beneficiario: ", SQLERRMESSAGE 
        ELSE
            DISPLAY "Conyugue registrado con éxito"
            CALL registrar_otros_beneficiarios ()
        END IF 
    ELSE
        CALL registrar_otros_beneficiarios ()
    END IF 
ELSE
    CALL registrar_otros_beneficiarios ()
END IF 

END FUNCTION

FUNCTION registrar_otros_beneficiarios ()
DEFINE tipodocumento         LIKE bingo_beneficiario.tipodocumento,
       documentobeneficiario LIKE bingo_beneficiario.documentobeneficiario,
       priape                LIKE bingo_beneficiario.priape,
       segape                LIKE bingo_beneficiario.segape, 
       nombre                LIKE bingo_beneficiario.nombre
       
DECLARE c_b CURSOR FOR
select subsi22.coddoc,trim(subsi22.documento),
trim(subsi22.priape),trim(subsi22.segape),trim(subsi22.nombre)
FROM  subsi23,subsi22 
where subsi22.codben     = subsi23.codben
and   subsi23.cedtra     = r_formulario.documentoAfiliado
and   subsi23.tipdoc_tra = r_formulario.coddoc
and   subsi22.estado     = "A"

FOREACH c_b INTO tipodocumento, documentobeneficiario, priape, segape,nombre
    IF NOT existe_beneficiario(tipodocumento, documentobeneficiario) THEN 
        INSERT INTO bingo_beneficiario VALUES (tipodocumento, documentobeneficiario,
                                               priape,segape,nombre,
                                               r_formulario.coddoc, r_formulario.documentoAfiliado )
        IF status <> 0 THEN
            DISPLAY "Error al registrar un beneficiario: ", SQLERRMESSAGE 
        END IF 
    END IF 
    LET tipodocumento         = ""
    LET documentobeneficiario = "" 
    LET priape                = "" 
    LET segape                = ""
    LET nombre                = ""
END FOREACH 

END FUNCTION   

FUNCTION envio_cartones()
DEFINE i              INTEGER,
       dato_adjunto   STRING,
       idCarton       INTEGER,
       lista_adjuntos STRING    

LET lista_adjuntos = ""
       
CALL traer_archivo_adjunto() RETURNING dato_adjunto

IF NOT dato_adjunto.equals("") THEN  
    CALL enviar_correo(dato_adjunto)
END IF 
END FUNCTION 

FUNCTION enviar_correo(lista_adjuntos)
DEFINE lista_adjuntos STRING,
       comando        STRING,
       mensaje        STRING,
       titulo         STRING  

LET titulo  = "ENVIO CARTONES DEL BINGO"
LET mensaje = "Hacemos envío de ",r_formulario.cupos USING "<<<<", " cartones de Bingo, Suerte!" 
LET comando = "echo ",mensaje," | mail -v -s """,titulo,"""",lista_adjuntos," ", r_formulario.correo
RUN comando 
END FUNCTION 

FUNCTION traer_archivo_adjunto()
DEFINE dato_adjunto STRING,
       id           INTEGER,
       lista        STRING  

DECLARE c_f_l CURSOR FOR  
SELECT FIRST r_formulario.cupos rutacarton, idCarton 
INTO   dato_adjunto, id 
FROM   bingo_carton
WHERE  idBingo = r_formulario.idBingo
AND    documentoafiliado IS NULL 
ORDER BY idCarton

LET lista = ""

BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT 

FOREACH c_f_l INTO dato_adjunto, id 
LET lista = lista," -a /home/cartones_bingo/",dato_adjunto

UPDATE bingo_carton 
SET    bingo_carton.tipodocafil       = r_formulario.coddoc,
       bingo_carton.documentoafiliado = r_formulario.documentoAfiliado
WHERE  bingo_carton.idcarton          = id

IF status <> 0 THEN
    CALL fgl_winmessage("Bingos Comfaoriente","No se pudo actualizar el Cartón "||SQLERRMESSAGE,"stop")
    ROLLBACK WORK 
    LET lista = ""
    EXIT FOREACH 
END IF 
END FOREACH 

IF NOT dato_adjunto.equals("") THEN
    COMMIT WORK 
END IF 

RETURN lista
END FUNCTION 