DECLARE
 arquivoOut Utl_File.file_type;
 CURSOR listaProdutos IS selec * form TB_PRODUTO;
    
BEGIN    
  arquivoOut := UTL_FILE.fopen('C:\Users\t_carlosb\Documents','texto.txt','w');
  FOR produtoLinha IN listaProdutos
    LOOP
      UTL_FILE.put_line(arquivoOut, produtoLinha.nm_produto);  
    END LOOP;
    UTL_FILE.fclose(arquivoOut);
    dbms_output.put_line('Arquivo gerado com sucesso.');
END;  

 
