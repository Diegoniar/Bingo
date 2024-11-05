DATABASE empresa

MAIN

OPEN WINDOW w_main WITH FORM "b_main"
MENU
ON ACTION gestion_bingos
    CALL b_bingo_main()

ON ACTION formulario
    CALL abrir_formulario_principal ()
    
ON ACTION Salir
    EXIT MENU 
END MENU 

CLOSE WINDOW w_main
END MAIN 





