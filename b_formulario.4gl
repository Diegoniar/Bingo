DATABASE empresa

FUNCTION abrir_formulario_principal ()
DEFINE cb_codoc ui.ComboBox,
       cb_bingo ui.Combobox

OPEN WINDOW w_formulario WITH FORM "b_formulario"

LET cb_bingo = llenar_combo_bingo ()
--LET cb_codoc = llenar_combo_tipo_documento ()
MENU
    ON ACTION salir
        EXIT MENU
END MENU 
CLOSE WINDOW w_formulario
END FUNCTION 