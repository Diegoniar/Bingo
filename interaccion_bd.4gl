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

FUNCTION existe_afiliado (coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       cont              INTEGER 

LET cont = 0

SELECT COUNT(*) INTO cont FROM subsi15
WHERE subsi15.coddoc = coddoc
AND   subsi15.cedtra = documentoAfiliado

IF cont > 0 THEN
    IF afiliado_activo (coddoc, documentoAfiliado) THEN
        IF es_categoria_a_b(coddoc, documentoAfiliado) THEN
            RETURN TRUE
        ELSE
            RETURN FALSE 
        END IF 
    ELSE
        RETURN FALSE 
    END IF 
ELSE
    CALL fgl_winmessage("Bingos Comfaoriente","La persona no esta relacionada con comfaoriente, por favor revise el tipo y número de documento","stop")
    RETURN FALSE 
END IF 

END FUNCTION 

FUNCTION afiliado_activo (coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       cont              INTEGER 

SELECT COUNT(*) INTO cont FROM subsi15
WHERE subsi15.coddoc = coddoc
AND   subsi15.cedtra = documentoAfiliado
AND   subsi15.estado = "A"

IF cont > 0 THEN
    RETURN TRUE
ELSE
    CALL fgl_winmessage("Bingos Comfaoriente","El afiliado se encuentra inactivo","stop")
    RETURN FALSE 
END IF 

END FUNCTION 

FUNCTION es_categoria_a_b(coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       cont              INTEGER 

SELECT COUNT(*) INTO cont FROM subsi15
WHERE subsi15.coddoc = coddoc
AND   subsi15.cedtra = documentoAfiliado
AND   subsi15.estado = "A"
AND   subsi15.codcat IN ("A","B")

IF cont > 0 THEN
    RETURN TRUE
ELSE
    CALL fgl_winmessage("Bingos Comfaoriente","El afiliado debe ser Categoria A ó B","stop")
    RETURN FALSE 
END IF 

END FUNCTION 

FUNCTION traer_empresa (coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       nit               LIKE subsi15.nit,
       razsoc            LIKE subsi02.razsoc,
       codcat            LIKE subsi15.codcat

LET nit    = ""
LET razsoc = ""

SELECT subsi15.nit, subsi02.razsoc, subsi15.codcat INTO 
       nit, razsoc, codcat
FROM   subsi15, subsi02
WHERE  subsi15.nit    = subsi02.nit
AND    subsi15.cedtra = documentoAfiliado
AND    subsi15.coddoc = coddoc

LET nit = nit CLIPPED
LET razsoc = razsoc [1,52]

RETURN nit, razsoc, codcat
END FUNCTION 

FUNCTION traer_nombre_afiliado(coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       nombreAfiliado    STRING 

LET nombreAfiliado = ""

SELECT trim(nombre)||" "||trim(priape)||" "||NVL(trim(segape),"")
INTO nombreAfiliado
FROM   subsi15
WHERE  subsi15.coddoc = coddoc
AND    subsi15.cedtra = documentoAfiliado

RETURN nombreAfiliado
END FUNCTION 