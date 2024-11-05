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