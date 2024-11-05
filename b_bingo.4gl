DATABASE empresa

FUNCTION b_bingo_main()
OPEN WINDOW w_bingo WITH FORM "b_bingo"

MENU
    ON ACTION Adicionar
        CALL adicionar_bingo()
    ON ACTION salir
        EXIT MENU
END MENU 
CLOSE WINDOW w_bingo
END FUNCTION 

FUNCTION adicionar_bingo()
END FUNCTION 