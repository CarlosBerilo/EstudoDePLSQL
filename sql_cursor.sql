DECLARE

  CURSOR listaProdutos IS select * from TB_PRODUTO;  
  vProduto TB_PRODUTO%ROWTYPE;
   
BEGIN    
   -- Forma simples
   dbms_output.put_line('** Uso de CURSOR Forma simples'); 
   FOR p IN listaProdutos
   LOOP
      dbms_output.put_line(p.cd_produto);
   END LOOP;
   
   -- Forma Completa
   dbms_output.put_line('** Uso de CURSOR Forma completa');  
   OPEN listaProdutos;
   LOOP
      FETCH listaProdutos INTO vProduto;
      EXIT WHEN listaProdutos%NOTFOUND;
      dbms_output.put_line(vProduto.nm_produto);
   END LOOP; 
   CLOSE listaProdutos;    
   
END;  
