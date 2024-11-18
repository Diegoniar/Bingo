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

FUNCTION Afiliado_ya_esta_en_el_bingo(idBingo, coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       idBingo           LIKE bingo.idbingo,
       cont              INTEGER
       
LET cont = 0

SELECT COUNT(*) INTO cont FROM bingo_formulario
WHERE  bingo_formulario.tipodocumento     = coddoc
AND    bingo_formulario.documentoafiliado = documentoAfiliado
AND    bingo_formulario.idbingo           = idBingo

IF cont > 0 THEN
    CALL fgl_winmessage("Bingos Comfaoriente","El Afiliado ya se encuentra inscrito en el Bingo","stop")
    RETURN FALSE
ELSE
    RETURN TRUE
END IF 
END FUNCTION 

FUNCTION calcular_cupos(coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       cupos             INTEGER,
       cont              INTEGER  

LET cupos = 1

LET cont = 0

select count(*) INTO cont from subsi21, subsi20
where  subsi21.cedcon     = subsi20.cedcon
and    subsi21.cedtra     = documentoAfiliado
and    subsi21.tipdoc_tra = coddoc
and    subsi20.estado = "A"

LET cupos = cupos + cont

LET cont  = 0

select COUNT(*) INTO cont from subsi23, subsi22
where  subsi23.codben     = subsi22.codben
and    subsi23.cedtra     = documentoAfiliado
and    subsi23.tipdoc_tra = coddoc
and    subsi22.estado     = "A"

LET cupos = cupos + cont

RETURN cupos
END FUNCTION 

FUNCTION traer_telefono(coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       telefono          LIKE subsi15.telefono,
       correo            LIKE subsi15.email

LET correo = ""
LET telefono = ""

SELECT subsi15.telefono, subsi15.email 
INTO   telefono, correo
FROM   subsi15
WHERE  subsi15.cedtra = documentoAfiliado
AND    subsi15.coddoc = coddoc

LET correo = correo CLIPPED
LET telefono = telefono CLIPPED 

RETURN telefono, correo
END FUNCTION 

FUNCTION traer_consecutivo_formulario ()
DEFINE consec INTEGER

LET consec = 0

SELECT MAX(idFormulario) INTO consec 
FROM bingo_formulario

IF consec = 0 OR consec IS NULL THEN
    LET consec = 1
ELSE
    LET consec = consec + 1
END IF 

RETURN consec
END FUNCTION 

FUNCTION existe_afiliado_bingo (coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       cont              INTEGER 

LET cont = 0

SELECT COUNT(*) INTO cont FROM bingo_afiliado
WHERE bingo_afiliado.tipodocumento     = coddoc
AND   bingo_afiliado.documentoafiliado = documentoAfiliado

IF cont > 0 THEN
    RETURN TRUE
ELSE
    RETURN FALSE
END IF 

END FUNCTION

FUNCTION datos_afiliado (coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       priape            LIKE subsi15.priape,
       segape            LIKE subsi15.segape,
       nombre            LIKE subsi15.segape,
       codzon            LIKE subsi15.codzon

SELECT subsi15.priape, subsi15.segape, subsi15.nombre, subsi15.codzon
INTO   priape, segape, nombre, codzon
FROM   subsi15
WHERE  subsi15.coddoc = coddoc
AND    subsi15.cedtra = documentoAfiliado
       
RETURN priape, segape,nombre,codzon
END FUNCTION  

FUNCTION existe_beneficiario(coddoc, documentoAfiliado)
DEFINE coddoc            LIKE bingo_formulario.tipodocumento,
       documentoAfiliado LIKE bingo_formulario.documentoafiliado,
       cont              INTEGER 

LET cont = 0

SELECT COUNT(*) INTO cont FROM bingo_beneficiario
WHERE bingo_beneficiario.tipodocumento         = coddoc
AND   bingo_beneficiario.documentobeneficiario = documentoAfiliado 

IF cont > 0 THEN
    RETURN TRUE
ELSE
    RETURN FALSE 
END IF 
END FUNCTION 

