DATABASE empresa

FUNCTION llenar_combo_tipo_documento ()
DEFINE cb      ui.ComboBox,
       r_gen18 RECORD
        coddoc LIKE gener18.coddoc,
        detdoc LIKE gener18.detdoc
       END RECORD 

LET cb = ui.ComboBox.forName("gener18.coddoc")

CALL cb.CLEAR()

DECLARE c_coddoc CURSOR FOR
SELECT gener18.coddoc, gener18.detdoc 
FROM gener18
WHERE gener18.estado = "A"

INITIALIZE r_gen18.* TO NULL 

FOREACH c_coddoc INTO r_gen18.*
    CALL cb.addItem(r_gen18.coddoc CLIPPED, r_gen18.detdoc CLIPPED)
END FOREACH 

CLOSE c_coddoc

RETURN cb
END FUNCTION 

FUNCTION llenar_combo_bingo ()
DEFINE cb      ui.ComboBox,
       r_bingo RECORD 
        idBingo     LIKE bingo.idbingo,
        nombreBingo LIKE bingo.nombrebingo
       END RECORD  

LET cb = ui.ComboBox.forName("bingo.idbingo")

CALL cb.CLEAR()
       
DECLARE c_bingo CURSOR FOR
SELECT bingo.idBingo, bingo.nombreBingo
FROM   bingo
WHERE  bingo.estado = "A"

INITIALIZE r_bingo.* TO NULL

FOREACH c_bingo INTO r_bingo.*
    CALL cb.addItem(r_bingo.idBingo, r_bingo.nombreBingo)
END FOREACH  

CLOSE c_bingo

RETURN cb
END FUNCTION 