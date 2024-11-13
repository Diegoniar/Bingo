DATABASE empresa

FUNCTION traer_consecutivo_bingo ()
DEFINE consec INTEGER 

SELECT MAX(bingo.idBingo) INTO consec FROM bingo

IF (consec IS NULL) OR (consec = 0) THEN
    LET consec = 1
    RETURN consec
ELSE
    LET consec = consec + 1
    RETURN consec
END IF 
END FUNCTION 

FUNCTION validar_fecha (fechabingo)
DEFINE fechabingo DATE

IF fechabingo >= TODAY THEN
    RETURN TRUE
ELSE
    RETURN FALSE 
END IF 
END FUNCTION 

FUNCTION agregar_imagenes ()
DEFINE mrut, mruta, mruta2 STRING
DEFINE usu CHAR (3)
DEFINE mruta3 CHAR (150)
DEFINE cont INTEGER 
DEFINE extension CHAR (4)

LET mruta =""
CALL WINOPENFILE( "C:\\",mrut,"jpg jpeg png", "SELECCIONE EL ARCHIVO A AGREGAR") returning mruta
DISPLAY mruta
DISPLAY fgl_getenv("HOME")

LET mruta = mruta CLIPPED 

IF mruta IS NOT NULL THEN 
    CALL quitar_espacios (mruta) RETURNING mruta2
    LET mruta = mruta clipped
    Let mruta2 = fgl_getenv("HOME"),"/posters","/",mruta2
ELSE
    CALL fgl_winmessage ("Administrador","No selecciono ninguna imagen","stop")
    RETURN "0"
END IF 

LET mruta2 = mruta2 CLIPPED 
--DISPLAY "Longitud",mruta2.getLength()
DISPLAY mruta2
CALL longitud_sin_punto (mruta2) RETURNING cont 
IF cont > 0 THEN
    CALL retorna_extension(mruta2) RETURNING extension
ELSE
    CALL fgl_winmessage ("Administrador","No selecciono ninguna imagen","stop")
    RETURN "0"
END IF 

IF NOT (extension = "png") OR (extension = "jpg") OR extension = ("jpeg") THEN
    CALL fgl_winmessage ("Administrador","El elemento seleccionado no es una imagén","stop")
    RETURN "0"
END IF 
LET mruta3 = mruta2

LET mruta2 = mruta2.subString(1,cont),".",extension
LET mruta2 = mruta2 CLIPPED

TRY
   CALL FGL_GETFILE(mruta , mruta2)
   DISPLAY mruta2
CATCH 
   ERROR status 
END TRY 
RETURN mruta2
END FUNCTION 

FUNCTION longitud_sin_punto (ruta)
DEFINE ruta STRING
DEFINE cont,i INTEGER 
LET cont=0
FOR i=1 TO ruta.getLength()
    IF ruta.getCharAt(i).equals(".") THEN
        LET cont = i-1
        DISPLAY "Longitud sin el punto ",cont 
        RETURN cont 
    END IF 
END FOR 
RETURN cont 
END FUNCTION 

FUNCTION retorna_extension(mruta2) 
DEFINE mruta2 STRING
DEFINE mruta3 CHAR (150)
DEFINE ext CHAR (4)
DEFINE cont,i,j INTEGER

LET mruta3 = mruta2
FOR i=1 TO mruta2.getLength()
    IF mruta2.getCharAt(i).equals(".") THEN
        LET cont = i
    END IF 
END FOR 
LET j=1
FOR i=cont+1 TO mruta2.getLength()
    LET ext[j] = mruta2.getCharAt(i)
    LET j=j+1
END FOR 

RETURN ext
END FUNCTION 

FUNCTION quitar_espacios (ruta)
DEFINE ruta STRING
DEFINE ruta2 CHAR (100)
DEFINE i INTEGER

FOR i=1 TO ruta.getLength()
    IF ruta.getCharAt(i).equals(" ") THEN
         LET ruta2[i] = "_"
    ELSE
        LET ruta2[i] = ruta.getCharAt(i)
    END IF 
END FOR 
DISPLAY "ES asi: ",ruta2
RETURN ruta2
END FUNCTION 

FUNCTION oculta_campo(campo)
DEFINE campo  STRING
    ,w ui.WINDOW
    ,f ui.FORM
    
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()
    CALL f.setElementHidden(campo,1)
    CALL f.setFieldHidden(campo,1)

END FUNCTION

FUNCTION muestra_campo(campo)
DEFINE campo  STRING
    ,w ui.WINDOW
    ,f ui.FORM
    
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()
    CALL f.setElementHidden(campo,0)
    CALL f.setFieldHidden(campo,0)

END FUNCTION

FUNCTION mostrar_campos_telefono_email (campo1,campo2,campo3,campo4,campo5)
DEFINE campo1,campo2,campo3,campo4,campo5 STRING 

CALL muestra_campo(campo1)
CALL muestra_campo(campo2)
CALL muestra_campo(campo3)
CALL muestra_campo(campo4)
CALL muestra_campo(campo5)
END FUNCTION 

FUNCTION telefono_es_valido (telefono)
DEFINE telefono LIKE bingo_formulario.telefono

IF LENGTH(telefono) <> 10 THEN
    CALL fgl_winmessage("Bingos Comfaoriente","No digitaste un número de teléfono válido","stop")
    RETURN FALSE
ELSE
    IF telefono[1,3] >= "300" AND telefono[1,3] < "360" THEN
        IF solo_es_numero (telefono) THEN
            RETURN TRUE 
        ELSE
            RETURN FALSE 
        END IF 
    ELSE
        CALL fgl_winmessage("Bingos Comfaoriente","Los primeros tres números de telefono debe estar en el rango de 300 a 359","stop")
        RETURN FALSE 
    END IF 
END IF 

END FUNCTION 

FUNCTION solo_es_numero (telefono)
DEFINE telefono STRING,
       i        INTEGER  

FOR i = 1 TO telefono.getLength()
    IF NOT sin_letra_ni_simbolos(telefono.getCharAt(i)) THEN
        CALL fgl_winmessage("Bingos Comfaoriente","Sólo se admiten números","stop")
        RETURN FALSE 
    END IF 
END FOR

RETURN TRUE 
END FUNCTION 

FUNCTION sin_letra_ni_simbolos(a)
DEFINE a CHAR(1)

IF (a = "1") OR (a = "2") OR (a = "3") OR (a = "4") OR (a = "5")
OR (a = "6") OR (a = "7") OR (a = "8") OR (a = "9") OR (a = "0") 
THEN
    RETURN TRUE
ELSE
    RETURN FALSE 
END IF    
END FUNCTION 

FUNCTION email_es_valido(correo)
DEFINE correo  STRING,
       usuario STRING,
       dominio STRING  

IF NOT hay_ene(correo) THEN
    RETURN FALSE 
END IF  
       
IF (contar_arrobas(correo) <> 1)
OR (correo.getCharAt(1).equals('@')) 
OR (correo.getCharAt(correo.getLength()).equals('@')) THEN 
    RETURN FALSE 
END IF 

CALL separar_usuario_dominio (correo) RETURNING usuario, dominio

IF usuario.getLength() < 1 THEN
    RETURN FALSE 
END IF 

IF NOT hay_un_punto(dominio) THEN
    RETURN FALSE 
END IF 

RETURN TRUE 
END FUNCTION 

FUNCTION hay_un_punto(dominio)
DEFINE dominio STRING,
       i       INTEGER,
       cont    INTEGER 

LET cont = 0

FOR i = 1 TO dominio.getLength()
    IF dominio.getCharAt(i).equals('.') THEN
        LET cont = cont + 1
    END IF 
END FOR 

IF NOT (cont > 0 AND cont < 3) THEN   
    RETURN FALSE 
END IF 

IF (dominio.getCharAt(1).equals('.')) OR (dominio.getCharAt(dominio.getLength()).equals('.')) THEN
    RETURN FALSE 
END IF 

IF NOT examen_dominio(dominio, cont) THEN
    RETURN FALSE 
END IF 

RETURN TRUE 
END FUNCTION 

FUNCTION examen_dominio(dominio, cont)
DEFINE dominio STRING,
       cont    INTEGER, 
       dom1    STRING,
       dom2    STRING, 
       dom3    STRING,
       punto1  INTEGER,
       punto2  INTEGER 

LET dom1   = ""
LET dom2   = ""
LET dom3   = ""
LET punto1 = 0
LET punto2 = 0

CALL devolver_indices_puntos(dominio,cont) RETURNING punto1, punto2

IF punto1 = (punto2-1) THEN
    RETURN FALSE 
END IF 

IF cont = 1 THEN
    LET dom1 = dominio.subString(1,punto1-1)
    LET dom2 = dominio.subString(punto1+1,dominio.getLength())
    IF (dom1.getLength() = 0) OR (dom2.getLength() = 0) THEN
        RETURN FALSE 
    END IF 
ELSE
    LET dom1 = dominio.subString(1,punto1-1)
    LET dom2 = dominio.subString(punto1+1,punto2-1)
    LET dom3 = dominio.subString(punto2+1,dominio.getLength())
    IF (dom1.getLength() < 2) OR (dom2.getLength() < 2) OR (dom3.getLength() < 2) THEN
        RETURN FALSE 
    END IF 
END IF 

RETURN true
END FUNCTION 

FUNCTION devolver_indices_puntos(dominio,cont)
DEFINE cont    INTEGER, 
       p1      INTEGER,
       p2      INTEGER,
       i       INTEGER,
       dominio STRING    

LET p1 = 0
LET p2 = 0
       
IF cont = 1 THEN 
    FOR i = 1 TO dominio.getLength()
        IF dominio.getCharAt(i).equals('.') THEN
            LET p1 = i
            LET p2 = 0
        END IF 
    END FOR
    RETURN p1,p2
ELSE
    FOR i = 1 TO dominio.getLength()
        IF dominio.getCharAt(i).equals('.') THEN
            IF p1 = 0 THEN
                LET p1 = i
            ELSE
                LET p2 = i
            END IF 
        END IF 
    END FOR
    RETURN p1,p2
END IF 

END FUNCTION 

function separar_usuario_dominio (correo)
DEFINE correo  STRING,
       usuario STRING,
       dominio STRING,
       arroba  INTEGER,
       i       INTEGER   

LET usuario = ""
LET dominio = ""

FOR i = 1 TO correo.getLength()
    IF correo.getCharAt(i).equals('@') THEN
        LET arroba = i
        EXIT FOR 
    END IF 
END FOR 

LET usuario = correo.subString(1,arroba-1)
LET dominio = correo.subString(arroba + 1, correo.getLength())

RETURN usuario, dominio
END FUNCTION 

FUNCTION contar_arrobas(correo)
DEFINE correo STRING,
       i      INTEGER,
       cont   INTEGER 

LET cont = 0

FOR i = 1 to correo.getlength()
    IF correo.getCharAt(i).equals('@') THEN
        LET cont = cont + 1
    END IF 
END FOR 

RETURN cont 
END FUNCTION 

FUNCTION hay_ene(email)
DEFINE email STRING,
       i     INTEGER 

FOR i = 1 TO email.getLength()
    IF (email.getCharAt(i).equals('ñ')) OR (email.getCharAt(i).equals('Ñ')) THEN
        RETURN FALSE 
    END IF 
END FOR 
RETURN TRUE     
END FUNCTION 