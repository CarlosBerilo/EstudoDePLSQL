/*   
CRUD para treinamento no uso de plsql.
Partindo de que uma boa prática de programação é separar em pequenas partes testaveis.

-- Inclusão de produto   
-- Atualização de produto
-- Exclusão/Desativação do item
-- Lista os produtos
-- Soma o total de valores inclusos na tabela
-- Busca de produto por código   
-- Busca de produtos por nome usando LIKE
-- Busca de produtos por intervalo de datas  
-- Busca de produtos por intervalo de valor
*/

DECLARE
  -- Pega a data atual que será usada para datar o cadastro e a atualização
  vDataAtual DATE := SYSDATE;
  vDataInicioPesquisa VARCHAR2(50);
  vValorTotal NUMBER:= 0;
  total NUMBER:= 0;
  
  -- Cursor com a lista de produtos com status 1(ativo)
  CURSOR listaDeProdutos IS SELECT * FROM TB_PRODUTO p WHERE p.cd_status = 1; 
  -- Busca o último código de produto cadastrado
  -- (CURSOR não ultilizado)CURSOR ultimoCDinserido IS SELECT max(p.cd_produto)FROM TB_PRODUTO p;
  -- Busca o produto pelo seu código de cadastro.
  CURSOR CR_BuscaProduto(CD_PRODUTO_TEMP NUMBER) IS SELECT * FROM TB_PRODUTO p WHERE p.cd_produto = CD_PRODUTO_TEMP ;
  CURSOR CR_BuscaPorNome(NM_Produto_Pesquisar VARCHAR2) IS SELECT * FROM TB_PRODUTO p WHERE lower(p.nm_produto) LIKE lower('%'|| NM_Produto_Pesquisar ||'%');
  CURSOR CR_BuscaPorPeriodo(vInicio VARCHAR2, vTermino VARCHAR2) IS SELECT * FROM TB_PRODUTO p WHERE p.dt_cadastro BETWEEN TO_DATE(vInicio,'mm/dd/yyyy') AND TO_DATE(vTermino,'mm/dd/yyyy hh24:mi:ss'); 
  CURSOR CR_BuscaPorIntervaloDeValor(vValorInicial NUMBER, vValorTermino NUMBER) IS SELECT * FROM TB_PRODUTO p WHERE p.vl_produto BETWEEN vValorInicial AND vValorTermino; 

-- Procedimento para soma de valores    
  PROCEDURE PR_soma(valor in NUMBER) IS
  BEGIN
    vValorTotal := vValorTotal+valor;
  END; 

-- Procedimento que lista produtos
   PROCEDURE PR_ListaDeProdutos IS
     BEGIN
        dbms_output.put_line('Lista de produtos.');
        vValorTotal := 0;
        FOR produto IN listaDeProdutos
          LOOP
             dbms_output.put_line( produto.CD_PRODUTO || ' - ' || produto.NM_PRODUTO || ' - R$ ' || TO_CHAR(produto.VL_PRODUTO,'FM999G999G999D90', 'nls_numeric_characters='',.''') || ' - ' || TO_CHAR(produto.DT_CADASTRO,'dd/MM/yyyy SS:MI:HH24'));
             PR_soma(produto.VL_PRODUTO);
          END LOOP;
        dbms_output.put_line('Valor Total R$ ' || TO_CHAR( vValorTotal,'FM999G999G999D90', 'nls_numeric_characters='',.'''));
     END;

-- Procedimento para inclusão de produto
  PROCEDURE PR_AddProduto(NM_PRODUTO_TEMP VARCHAR2, VL_PRODUTO_TEMP NUMBER, CD_STATUS_TEMP NUMBER) IS 
    vCDlast NUMBER := 0;
            
    BEGIN
       -- Busca o valor do último código de produto inserido adiciona na variável vCDlast.
       SELECT max(p.cd_produto) into vCDlast FROM TB_PRODUTO p;
       -- O valor da vCDlast é atualizado para o valor atual de vCDlas mais um.
       vCDlast := vCDlast + 1;
       -- Script de inclusão de produto
       INSERT INTO TB_PRODUTO(CD_PRODUTO,NM_PRODUTO,VL_PRODUTO,CD_STATUS,DT_CADASTRO,DT_ALTERACAO )VALUES(vCDlast,NM_PRODUTO_TEMP, VL_PRODUTO_TEMP, CD_STATUS_TEMP, vDataAtual, vDataAtual); 
       COMMIT;
       dbms_output.put_line('Inclusão realizada com sucesso.');
    END;
    
-- Procedimento para atualização de produto
  PROCEDURE PR_UpdateProduto (CD_PRODUTO_TEMP NUMBER, NM_PRODUTO_TEMP VARCHAR2, VL_PRODUTO_TEMP NUMBER, CD_STATUS_TEMP NUMBER) IS
    BEGIN       
       -- A validação é feita so para ver se consta um codigo.Deve ser alterado para verificar se o produto já consta no banco de dados.
       IF CD_PRODUTO_TEMP > 0 THEN 
          UPDATE TB_PRODUTO SET NM_PRODUTO = NM_PRODUTO_TEMP, VL_PRODUTO = VL_PRODUTO_TEMP, CD_STATUS = CD_STATUS_TEMP, DT_ALTERACAO = vDataAtual WHERE CD_PRODUTO = CD_PRODUTO_TEMP;
          COMMIT;
          dbms_output.put_line('Atualização realizada com sucesso.');
       ELSE
          dbms_output.put_line('PRODUTO não encontrado.');
       END IF;       
    END;
    
-- Procedimento para busca de produto por código
-- OBS: Refatorar o código para o uso de '%TYPE', já que deve-se retornar um único item.
   PROCEDURE PR_BuscaPorCodigo(CD_PRODUTO_TEMP NUMBER) IS
     BEGIN
        vValorTotal := 0;
        FOR produto IN CR_BuscaProduto(CD_PRODUTO_TEMP)
          LOOP          
             dbms_output.put_line( produto.CD_PRODUTO || ' - ' || produto.NM_PRODUTO || ' - R$ ' || TO_CHAR(produto.VL_PRODUTO,'FM999G999G999D90', 'nls_numeric_characters='',.''') || ' - ' || TO_CHAR(produto.DT_CADASTRO,'dd/MM/yyyy SS:MI:HH24') || ' - ' || TO_CHAR(produto.DT_ALTERACAO,'dd/MM/yyyy SS:MI:HH24'));
             PR_soma(produto.VL_PRODUTO);
          END LOOP;
        dbms_output.put_line('Valor Total R$ ' || TO_CHAR( vValorTotal,'FM999G999G999D90', 'nls_numeric_characters='',.'''));
     END;
   
   -- Procedimento para busca por NOME usado LIKE.
   PROCEDURE PR_BuscaPorNome(NM_Produto_Pesquisar in VARCHAR2) IS
     BEGIN
       vValorTotal := 0;
       FOR produto IN CR_BuscaPorNome(NM_Produto_Pesquisar)
         LOOP
           dbms_output.put_line( produto.CD_PRODUTO || ' - ' || produto.NM_PRODUTO || ' - R$ ' || TO_CHAR(produto.VL_PRODUTO,'FM999G999G999D90', 'nls_numeric_characters='',.''') || ' - ' || TO_CHAR(produto.DT_CADASTRO,'dd/MM/yyyy SS:MI:HH24')); 
           PR_soma(produto.VL_PRODUTO);
         END LOOP; 
       dbms_output.put_line('Valor Total R$ ' || TO_CHAR( vValorTotal,'FM999G999G999D90', 'nls_numeric_characters='',.'''));  
     END;
    
   -- Procedimento para busca por periodo de cadastro
   PROCEDURE PR_BuscaPorPeriodo(vInicio VARCHAR2, vTermino VARCHAR2) IS
     vTermino_temp VARCHAR2(50):= vTermino || ' 23:59:59'; 
     BEGIN
       vValorTotal := 0; 
       FOR produto IN CR_BuscaPorPeriodo(vInicio, vTermino_temp)
         LOOP
           dbms_output.put_line( produto.CD_PRODUTO || ' - ' || produto.NM_PRODUTO || ' - R$ ' || TO_CHAR(produto.VL_PRODUTO,'FM999G999G999D90', 'nls_numeric_characters='',.''') || ' - ' || TO_CHAR(produto.DT_CADASTRO,'dd/MM/yyyy SS:MI:HH24')); 
           PR_soma(produto.VL_PRODUTO);
         END LOOP;
         dbms_output.put_line('Valor Total R$ ' || TO_CHAR( vValorTotal,'FM999G999G999D90', 'nls_numeric_characters='',.'''));
     END;  
        

   -- Procedimento para exclusão/desativação do item
  PROCEDURE PR_ExcluirProduto(CD_PRODUTO_TEMP NUMBER) IS
    BEGIN
       -- Como solicitado para não fazer exclusão o código apenas altera o STATUS para 0.  
       UPDATE TB_PRODUTO SET CD_STATUS = 0, DT_ALTERACAO = vDataAtual WHERE CD_PRODUTO = CD_PRODUTO_TEMP;
       COMMIT;
       dbms_output.put_line('Desativação realizada com sucesso.');
    END;
   
  PROCEDURE PR_BuscaPorIntervaloDeValor(vValorInicial NUMBER, vValorTermino NUMBER)IS 
    BEGIN
       vValorTotal := 0;
       FOR produto IN CR_BuscaPorIntervaloDeValor(vValorInicial, vValorTermino)
         LOOP
           dbms_output.put_line( produto.CD_PRODUTO || ' - ' || produto.NM_PRODUTO || ' - R$ ' || TO_CHAR(produto.VL_PRODUTO,'FM999G999G999D90', 'nls_numeric_characters='',.''') || ' - ' || TO_CHAR(produto.DT_CADASTRO,'dd/MM/yyyy SS:MI:HH24')); 
           PR_soma(produto.VL_PRODUTO);
       END LOOP;
       dbms_output.put_line('Valor Total R$ ' || TO_CHAR( vValorTotal,'FM999G999G999D90', 'nls_numeric_characters='',.'''));
    END;       
    
      
/************************************/
/**   Bloco de inicio do sistema   **/
/************************************/
BEGIN
   
   -- Inclusão de produto
   dbms_output.put_line('');
   dbms_output.put_line('******** Inclusão de produto ********');
   --PR_AddProduto('Jeep compass', 150000, 1);
   
   -- Atualização de produto
   dbms_output.put_line('');
   dbms_output.put_line('******** Atualização de produto ********');
   PR_UpdateProduto( 100, 'JETA', 90369.36, 1); 
   
   -- Exclusão/Desativação do item
   dbms_output.put_line('');
   dbms_output.put_line('******** Exclusão/Desativação do item ********');
   PR_ExcluirProduto(30);
   
   -- Procedure que lista os produtos
   dbms_output.put_line('');
   dbms_output.put_line('******** Procedure que lista os produtos ********');
   PR_ListaDeProdutos;
      
   -- Busca de produto por código
   dbms_output.put_line('');
   dbms_output.put_line('*****  Busca de produto por código  ********');
   PR_BuscaPorCodigo(36);
   
   -- Procedure de busca de produtos por nome
   dbms_output.put_line('');
   dbms_output.put_line('******** Busca por NOME ********');
   PR_BuscaPorNome('honda');
   
   -- Busca de produtos por intervalo de datas
   dbms_output.put_line('');
   dbms_output.put_line('******** Busca por Periodo de cadastro ********');
   PR_BuscaPorPeriodo('08/14/2019', '08/16/2019'); 
   
   -- Procedure para busca de produtos por intervalo de valor
   dbms_output.put_line('');   
   dbms_output.put_line('******** Busca por intervalo de valor ********');
   PR_BuscaPorIntervaloDeValor(50, 100);
   
   dbms_output.put_line(''); 
   dbms_output.put_line('******** Todos as procedures realizados com sucesso. ********');
      
-- Exception para controle de erros 
EXCEPTION
   WHEN OTHERS THEN
     dbms_output.put_line('Erro ...');
          
END;
 
   

 




