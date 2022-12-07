/*
   SCRIPT INICIAL PARA CRIAR UM USUÁRIO TESTE
*/

alter session set "_ORACLE_SCRIPT"=true; 
 
CREATE USER PLSQL_TEST IDENTIFIED BY "123456" DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP ACCOUNT UNLOCK;

GRANT CREATE SESSION TO PLSQL_TEST;

ALTER USER PLSQL_TEST QUOTA UNLIMITED ON USERS;

GRANT EXP_FULL_DATABASE TO PLSQL_TEST;

GRANT CONNECT TO PLSQL_TEST;

GRANT create session, alter session TO PLSQL_TEST;

GRANT create procedure to PLSQL_TEST;

GRANT execute any procedure to PLSQL_TEST;

GRANT create table TO PLSQL_TEST;

GRANT create sequence TO PLSQL_TEST;

GRANT create trigger to PLSQL_TEST;

GRANT create type to PLSQL_TEST;

GRANT create view to PLSQL_TEST;

GRANT create any index, create indextype to PLSQL_TEST;

GRANT debug connect session to PLSQL_TEST;

GRANT debug any procedure to PLSQL_TEST;

GRANT DBA TO PLSQL_TEST;

/*
  Logar no usuário PLSQL_TEST para rodar o restante do script abaixo, caso não deseje criar um usuário favor ignorar os scripts acima
*/

--CLIENTE
CREATE TABLE TBL_CUSTOMERS  (
   CSM_ID               NUMBER(6)                       NOT NULL,
   CSM_NAME             VARCHAR2(50 CHAR)               NOT NULL,
   CONSTRAINT CSM_PK PRIMARY KEY (CSM_ID)
);

--STATUS DO PRODUTO
CREATE TABLE TBL_PRODUCTS_STATUS  (
   PRS_ID               NUMBER(1)                       NOT NULL,
   PRS_DESCRIPTION      VARCHAR2(10 CHAR)               NOT NULL,
   CONSTRAINT PRS_PK PRIMARY KEY (PRS_ID)
);

--PRODUTO
CREATE TABLE TBL_PRODUCTS  (
   PRO_ID               NUMBER(6)                       NOT NULL,
   PRS_ID               NUMBER(1)                       NOT NULL,
   PRO_NAME             VARCHAR2(50 CHAR)               NOT NULL,
   PRO_PRICE            NUMBER(9,2)                     NOT NULL,
   PRO_QTY              NUMBER(6)                      DEFAULT 0 NOT NULL,
   CONSTRAINT PRO_PK PRIMARY KEY (PRO_ID)
);

--TIPO DE MOVIMENTAÇÃO DO PRODUTO (Entrada, Saída)
CREATE TABLE TBL_PRODUCTS_MOV_TYPES  (
   PMT_ID               NUMBER(1)                       NOT NULL,
   PMT_DESCRIPTION      VARCHAR2(10 CHAR)               NOT NULL,
   CONSTRAINT PMT_PK PRIMARY KEY (PMT_ID)
);

--MOV_PRODUTO
CREATE TABLE TBL_PRODUCTS_MOV  (
   PRM_ID               NUMBER(6)                       NOT NULL,
   PRO_ID               NUMBER(6)                       NOT NULL,
   PMT_ID               NUMBER(1)                       NOT NULL,
   PRM_QTY              NUMBER(6)                       NOT NULL,
   ORI_ID               NUMBER(6)                       NOT NULL,
   CONSTRAINT PRM_PK PRIMARY KEY (PRM_ID)
);

--STATUS DO PEDIDO
CREATE TABLE TBL_ORDERS_STATUS  (
   ORS_ID               NUMBER(1)                       NOT NULL,
   ORS_DESCRIPTION      VARCHAR2(10 CHAR)               NOT NULL,
   CONSTRAINT ORS_PK PRIMARY KEY (ORS_ID)
);

--PEDIDO
CREATE TABLE TBL_ORDERS  (
   ORD_ID               NUMBER(6)                       NOT NULL,
   CSM_ID               NUMBER(6)                       NOT NULL,
   ORS_ID               NUMBER(1)                       NOT NULL,
   ORD_VALUE            NUMBER(9,2)                     NOT NULL,
   ORT_ID               NUMBER(1)                       NOT NULL,
   CONSTRAINT ORD_PK PRIMARY KEY (ORD_ID)
);

--MOV_PEDIDO
CREATE TABLE TBL_ORDERS_ITEMS  (
   ORI_ID               NUMBER(6)                       NOT NULL,
   PRO_ID               NUMBER(6)                       NOT NULL,
   ORD_ID               NUMBER(6)                       NOT NULL,
   ORI_QTY              NUMBER(6)                       NOT NULL,
   ORI_PRICE            NUMBER(9,2)                     NOT NULL,
   CONSTRAINT ORI_PK PRIMARY KEY (ORI_ID)
);

CREATE TABLE TBL_ORDERS_TYPES  (
   ORT_ID               NUMBER(1)                       NOT NULL,
   ORT_DESCRIPTION      VARCHAR2(10)                    NOT NULL,
   CONSTRAINT ORT_FK PRIMARY KEY (ORT_ID)
);


/*
  Criar refências entre as tabelas
*/
ALTER TABLE TBL_ORDERS_ITEMS
   ADD CONSTRAINT ORI_ORD_FK FOREIGN KEY (ORD_ID)
      REFERENCES TBL_ORDERS (ORD_ID);

ALTER TABLE TBL_ORDERS_ITEMS
   ADD CONSTRAINT ORI_PRO_FK FOREIGN KEY (PRO_ID)
      REFERENCES TBL_PRODUCTS (PRO_ID);

ALTER TABLE TBL_ORDERS
   ADD CONSTRAINT ORD_CSM_FK FOREIGN KEY (CSM_ID)
      REFERENCES TBL_CUSTOMERS (CSM_ID);

ALTER TABLE TBL_ORDERS
   ADD CONSTRAINT ORD_ORS_FK FOREIGN KEY (ORS_ID)
      REFERENCES TBL_ORDERS_STATUS (ORS_ID);


ALTER TABLE TBL_PRODUCTS_MOV
   ADD CONSTRAINT PRM_PMT_FK FOREIGN KEY (PMT_ID)
      REFERENCES TBL_PRODUCTS_MOV_TYPES (PMT_ID);

ALTER TABLE TBL_PRODUCTS_MOV
   ADD CONSTRAINT PRM_PRO_FK FOREIGN KEY (PRO_ID)
      REFERENCES TBL_PRODUCTS (PRO_ID);

ALTER TABLE TBL_PRODUCTS
   ADD CONSTRAINT PRO_PRS_FK FOREIGN KEY (PRS_ID)
      REFERENCES TBL_PRODUCTS_STATUS (PRS_ID);

ALTER TABLE TBL_PRODUCTS_MOV
   ADD CONSTRAINT PRM_ORI_FK FOREIGN KEY (ORI_ID)
      REFERENCES TBL_ORDERS_ITEMS (ORI_ID);

ALTER TABLE TBL_ORDERS
   ADD CONSTRAINT ORD_ORT_FK FOREIGN KEY (ORT_ID)
      REFERENCES TBL_ORDERS_TYPES (ORT_ID);

--SEQUÊNCIAS
CREATE SEQUENCE SEQ_CSM; --CLIENTE

CREATE SEQUENCE SEQ_ORD; --PEDIDO

CREATE SEQUENCE SEQ_ORI;--MOV_PEDIDO

CREATE SEQUENCE SEQ_PRO;--PRODUTO

CREATE SEQUENCE SEQ_PRM;--MOV_PRODUTO

/*
  Triggers para não precisar cadastrar a PK ao inserir a uma tabela. "AUTO-INCREMENTO"
*/
CREATE OR REPLACE TRIGGER TRG_CSM_INS
  BEFORE INSERT
  ON TBL_CUSTOMERS
  FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.CSM_ID IS NULL THEN
    :NEW.CSM_ID := SEQ_CSM.NEXTVAL;
  END IF;
END;

CREATE OR REPLACE TRIGGER TRG_ORD_INS
  BEFORE INSERT
  ON TBL_ORDERS
  FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.ORD_ID IS NULL THEN
    :NEW.ORD_ID := SEQ_ORD.NEXTVAL;
  END IF;
END;

CREATE OR REPLACE TRIGGER TRG_ORI_INS
  BEFORE INSERT
  ON TBL_ORDERS_ITEMS
  FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.ORI_ID IS NULL THEN
    :NEW.ORI_ID := SEQ_ORI.NEXTVAL;
  END IF;
END;


CREATE OR REPLACE TRIGGER TRG_PRO_INS
  BEFORE INSERT
  ON TBL_PRODUCTS
  FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.PRO_ID IS NULL THEN
    :NEW.PRO_ID := SEQ_PRO.NEXTVAL;
  END IF;
END;

CREATE OR REPLACE TRIGGER TRG_PRM_INS
  BEFORE INSERT
  ON TBL_PRODUCTS_MOV
  FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.PRM_ID IS NULL THEN
    :NEW.PRM_ID := SEQ_PRM.NEXTVAL;
  END IF;
END;

/*
  cadastro dos status que o produto vai ter
*/

INSERT INTO TBL_PRODUCTS_STATUS(PRS_ID, PRS_DESCRIPTION)
                         VALUES(0, 'Liberado');

INSERT INTO TBL_PRODUCTS_STATUS(PRS_ID, PRS_DESCRIPTION)
                         VALUES(1, 'Bloqueado');

COMMIT;

/*
  Cadastro dos tipos de movimentação de produto
*/

INSERT INTO TBL_PRODUCTS_MOV_TYPES(PMT_ID, PMT_DESCRIPTION)
                            VALUES(0, 'Entrada');
                            
INSERT INTO TBL_PRODUCTS_MOV_TYPES(PMT_ID, PMT_DESCRIPTION)
                            VALUES(1, 'Saída'); 

COMMIT;

/*
  Cadastro dos status dos pedidos
*/

INSERT INTO TBL_ORDERS_STATUS(ORS_ID, ORS_DESCRIPTION)
                       VALUES(0, 'Pendente');
                            
INSERT INTO TBL_ORDERS_STATUS(ORS_ID, ORS_DESCRIPTION)
                       VALUES(1, 'Efetivado');

INSERT INTO TBL_ORDERS_STATUS(ORS_ID, ORS_DESCRIPTION)
                       VALUES(2, 'Cancelado');  

COMMIT;

/*
  Cadastro dos tipos de pedido
*/                

INSERT INTO TBL_ORDERS_TYPES(ORT_ID, ORT_DESCRIPTION)
                            VALUES(0, 'Compra');
                            
INSERT INTO TBL_ORDERS_TYPES(ORT_ID, ORT_DESCRIPTION)
                            VALUES(1, 'Venda');              

COMMIT;

-------------------------------------------------------------------------------------------------------------------------------

--Triggers


--MUDAR O ESTOQUE DO PRODUTO QUANDO UM ITEM FOR ALTERADO NOS ITENS DO PEDIDO
CREATE OR REPLACE TRIGGER TRG_ORI_STOCK
  AFTER INSERT OR UPDATE OR DELETE
  OF ORI_QTY
  ON TBL_ORDERS_ITEMS
  FOR EACH ROW
DECLARE
  ORT_ID_ TBL_ORDERS_TYPES.ORT_ID%TYPE;
BEGIN  
  SELECT ORT_ID
  INTO ORT_ID_
  FROM TBL_ORDERS
  WHERE ORD_ID = NVL(:NEW.ORD_ID, :OLD.ORD_ID);

  --PMT_ID = 1 = SAÍDA, PMT_ID = 0 = ENTRADA
  -- ORT_ID_ = 1 = VENDA, ORT_ID_ = 0 = COMPRA
  IF INSERTING THEN
    INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                          VALUES(:NEW.PRO_ID, ORT_ID_, :NEW.ORI_QTY, :NEW.ORI_ID);
  ELSIF UPDATING THEN
    IF ORT_ID_ = 1 THEN --VENDA
      INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                            VALUES(:NEW.PRO_ID, 0, :OLD.ORI_QTY, :NEW.ORI_ID);
                            
      INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                            VALUES(:NEW.PRO_ID, 1, :NEW.ORI_QTY, :NEW.ORI_ID);
    ELSE --COMPRA
      INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                            VALUES(:NEW.PRO_ID, 1, :OLD.ORI_QTY, :NEW.ORI_ID);
                            
      INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                            VALUES(:NEW.PRO_ID, 0, :NEW.ORI_QTY, :NEW.ORI_ID);
    END IF;
  ELSIF DELETING THEN
    IF ORT_ID_ = 1 THEN --VENDA
      INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                            VALUES(:OLD.PRO_ID, 0, :OLD.ORI_QTY, :OLD.ORI_ID);
    ELSE --COMPRA
      INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                            VALUES(:OLD.PRO_ID, 1, :OLD.ORI_QTY, :OLD.ORI_ID);
    END IF;    
  END IF;
END;

--MUDAR O ESTOQUE DO PRODUTO QUANDO FOR ALTERADO UM ITEM
CREATE OR REPLACE TRIGGER TRG_PRM_CHANGE
  BEFORE INSERT OR UPDATE OR DELETE
  ON TBL_PRODUCTS_MOV
  FOR EACH ROW
DECLARE
BEGIN  
  --PMT_ID = 1 = SAÍDA, PMT_ID = ENTRADA
  IF INSERTING THEN
    IF :NEW.PMT_ID = 1 THEN
      UPDATE TBL_PRODUCTS SET PRO_QTY = PRO_QTY - :NEW.PRM_QTY
      WHERE PRO_ID = :NEW.PRO_ID;
    ELSE
      UPDATE TBL_PRODUCTS SET PRO_QTY = PRO_QTY + :NEW.PRM_QTY
      WHERE PRO_ID = :NEW.PRO_ID;
    END IF;
  ELSIF UPDATING THEN
    RAISE_APPLICATION_ERROR (-20500, 'Não é permitido alterações nas movimentações do estoque', TRUE);
  ELSIF DELETING THEN
    RAISE_APPLICATION_ERROR (-20500, 'Não é permitido excluir dados de movimentações de estoque', TRUE);
  END IF;
END;

--ALTERAÇÕES PARA MUDANÇA NO PREÇO DO ITEM
CREATE OR REPLACE TRIGGER TRG_ORI_PRICE
  AFTER INSERT OR UPDATE OR DELETE
  OF ORI_QTY, ORI_PRICE
  ON TBL_ORDERS_ITEMS
  FOR EACH ROW
DECLARE
BEGIN  

  IF INSERTING THEN
    UPDATE TBL_ORDERS SET ORD_VALUE = ORD_VALUE + (:NEW.ORI_QTY * :NEW.ORI_PRICE)
    WHERE ORD_ID = :NEW.ORD_ID;   
    
  ELSIF UPDATING THEN
    UPDATE TBL_ORDERS SET ORD_VALUE = ORD_VALUE + ((:NEW.ORI_QTY * :NEW.ORI_PRICE) - (:OLD.ORI_QTY * :OLD.ORI_PRICE))
    WHERE ORD_ID = :NEW.ORD_ID;   
       
  ELSIF DELETING THEN
    UPDATE TBL_ORDERS SET ORD_VALUE = ORD_VALUE - (:OLD.ORI_QTY * :OLD.ORI_PRICE)
    WHERE ORD_ID = :OLD.ORD_ID;   
    
  END IF;
END;

--VALIDAÇÕES NAS MUDANÇAS DA TABELA DE ITENS DO PEDIDO
CREATE OR REPLACE TRIGGER TRG_ORI_VALID
  BEFORE INSERT OR UPDATE OR DELETE
  OF ORI_QTY, ORI_PRICE
  ON TBL_ORDERS_ITEMS
  FOR EACH ROW
DECLARE
  ORS_ID_ TBL_ORDERS_STATUS.ORS_ID%TYPE;
BEGIN  
  IF :NEW.ORI_PRICE < 0 THEN
    RAISE_APPLICATION_ERROR (-20500, 'O preço não pode ser negativo', TRUE);
  END IF;
  IF :NEW.ORI_QTY < 0 THEN
    RAISE_APPLICATION_ERROR (-20500, 'A quantidade não pode ser menor que 0', TRUE);
  END IF;
  --ORS_ID = 0 = PENDENTE, ORS_ID_ = 1 = EFETIVADO, ORS_ID_ = 2 = CANCELADO
  --Só pode alterar o pedido quando o status estiver pendente
  SELECT ORS_ID
  INTO ORS_ID_
  FROM TBL_ORDERS
  WHERE ORD_ID = NVL(:NEW.ORD_ID, :OLD.ORD_ID);
  
  IF ORS_ID_ <> 0 THEN
    RAISE_APPLICATION_ERROR (-20500, 'Não é permitido alterar o pedido com o status diferente de "Pendente"', TRUE);
  END IF;
END;

--TRIGGER PAR QUANDO O PEDIDO FOR CANCELADO VOLTAR O ESTOQUE
CREATE OR REPLACE TRIGGER TRG_ORD_CANCEL_STOCK
  AFTER INSERT OR UPDATE
  OF ORS_ID
  ON TBL_ORDERS
  FOR EACH ROW
DECLARE
    TYPE T_ITEM IS RECORD(  
         PRO_ID TBL_PRODUCTS.PRO_ID%TYPE,   
         ORI_ID TBL_ORDERS_ITEMS.ORI_ID%TYPE,
         ORI_QTY TBL_ORDERS_ITEMS.ORI_QTY%TYPE);
    TYPE T_ITEMS IS TABLE OF T_ITEM INDEX BY PLS_INTEGER; 
    A_T_ITEMS T_ITEMS;
    I_ TBL_ORDERS_ITEMS.ORI_ID%TYPE := 1; 
BEGIN  
  --ORS_ID = 0 = PENDENTE, ORS_ID_ = 1 = EFETIVADO, ORS_ID_ = 2 = CANCELADO
  IF :NEW.ORS_ID <> 2 THEN
    RETURN;
  END IF;
  -- SE ESTIVER CANCELADO VOLTA O ESTOQUE
 
  
  FOR SEC IN (SELECT PRO_ID, ORI_QTY, ORI_ID
              FROM TBL_ORDERS_ITEMS
              WHERE ORD_ID = :NEW.ORD_ID) LOOP
                
    A_T_ITEMS(I_).PRO_ID := SEC.PRO_ID;
    A_T_ITEMS(I_).ORI_QTY := SEC.ORI_QTY;
    A_T_ITEMS(I_).ORI_ID := SEC.ORI_ID;
    I_ := I_ + 1;
  END LOOP;
   --PMT_ID = 1 = SAÍDA, PMT_ID = ENTRADA
   -- ORT_ID_ = 1 = VENDA, ORT_ID_ = 0 = COMPRA
  IF :NEW.ORT_ID = 1 THEN
    FORALL I IN A_T_ITEMS.FIRST .. A_T_ITEMS.LAST
    INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                          VALUES(A_T_ITEMS(I).PRO_ID, 0, A_T_ITEMS(I).ORI_QTY, A_T_ITEMS(I).ORI_ID);
  ELSE                        
    FORALL I IN A_T_ITEMS.FIRST .. A_T_ITEMS.LAST
    INSERT INTO TBL_PRODUCTS_MOV(PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
                          VALUES(A_T_ITEMS(I).PRO_ID, 1, A_T_ITEMS(I).ORI_QTY, A_T_ITEMS(I).ORI_ID);
  END IF;
END;

--Validação para estoque
CREATE OR REPLACE TRIGGER TRG_PRO_STOCK_VALID
  BEFORE INSERT OR UPDATE
  OF PRO_QTY
  ON TBL_PRODUCTS
  FOR EACH ROW
DECLARE
BEGIN  
  IF :NEW.PRO_QTY < 0 THEN
    RAISE_APPLICATION_ERROR (-20500, 'Produto sem estoque', TRUE);
  END IF;
END;

--Criar views

CREATE OR REPLACE FORCE VIEW CUSTOMERS
(CSM_ID, CSM_NAME)
AS 
SELECT "CSM_ID","CSM_NAME" FROM TBL_CUSTOMERS;

CREATE OR REPLACE FORCE VIEW PRODUCTS_STATUS 
(PRS_ID, PRS_DESCRIPTION)
AS 
SELECT "PRS_ID","PRS_DESCRIPTION" FROM TBL_PRODUCTS_STATUS;

CREATE OR REPLACE FORCE VIEW PRODUCTS 
(PRO_ID, PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
AS 
SELECT "PRO_ID","PRS_ID","PRO_NAME","PRO_PRICE", "PRO_QTY" FROM TBL_PRODUCTS;

CREATE OR REPLACE FORCE VIEW PRODUCTS_MOV_TYPES 
(PMT_ID, PMT_DESCRIPTION)
AS 
SELECT "PMT_ID","PMT_DESCRIPTION" FROM TBL_PRODUCTS_MOV_TYPES;

CREATE OR REPLACE FORCE VIEW PRODUCTS_MOV 
(PRM_ID, PRO_ID, PMT_ID, PRM_QTY, ORI_ID)
AS 
SELECT "PRM_ID","PRO_ID","PMT_ID","PRM_QTY", "ORI_ID" FROM TBL_PRODUCTS_MOV;

CREATE OR REPLACE FORCE VIEW ORDERS_STATUS 
(ORS_ID, ORS_DESCRIPTION)
AS 
SELECT "ORS_ID","ORS_DESCRIPTION" FROM TBL_ORDERS_STATUS;

CREATE OR REPLACE FORCE VIEW ORDERS 
(ORD_ID, CSM_ID, ORS_ID, ORD_VALUE, ORT_ID)
AS 
SELECT "ORD_ID","CSM_ID","ORS_ID","ORD_VALUE", "ORT_ID" FROM TBL_ORDERS;

--PEDIDO
CREATE OR REPLACE FORCE VIEW ORDERS_ITEMS 
(ORI_ID, PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
AS 
SELECT "ORI_ID","PRO_ID","ORD_ID","ORI_QTY", "ORI_PRICE" FROM TBL_ORDERS_ITEMS;

CREATE OR REPLACE FORCE VIEW ORDERS_TYPES 
(ORT_ID, ORT_DESCRIPTION)
AS 
SELECT "ORT_ID","ORT_DESCRIPTION" FROM TBL_ORDERS_TYPES;

/*
  CADASTROS
*/

/*
  PROCEDURE DE VALIDAÇÃO DOS PEDIDOS
*/
CREATE OR REPLACE PROCEDURE PCD_UPDATE_STATUS_ORDER(ORD_ID_ TBL_ORDERS.ORD_ID%TYPE, ORS_ID_ TBL_ORDERS_STATUS.ORS_ID%TYPE) IS
  ORS_ID_OLD_ TBL_ORDERS_STATUS.ORS_ID%TYPE;
  ORS_DESCRIPTION_ TBL_ORDERS_STATUS.ORS_DESCRIPTION%TYPE;
BEGIN
  BEGIN
    SELECT ORS_DESCRIPTION
    INTO ORS_DESCRIPTION_
    FROM TBL_ORDERS_STATUS
    WHERE ORS_ID = ORS_ID_;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20500, 'Status inexistente', TRUE);
  END;
  BEGIN
    SELECT ORS_ID
    INTO ORS_ID_OLD_
    FROM TBL_ORDERS
    WHERE ORD_ID = ORD_ID_ FOR UPDATE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR (-20500, 'Pedido não encontrado', TRUE);
  END;
  

  -- ORS_ID. 0=Pendente, 1=Efetivado, 2=Cancelado 
  
  IF ORS_ID_OLD_ = ORS_ID_ THEN
     RAISE_APPLICATION_ERROR (-20500, 'O pedido já está no status de "' || ORS_DESCRIPTION_ || '"', TRUE);
   ELSIF ORS_ID_OLD_ = 2 THEN
     RAISE_APPLICATION_ERROR (-20500, 'O pedido só pode ser editado no status de "Cancelado"', TRUE);    
   END IF;

  --Verificar se o pedido está com uma divergência de mais de 10%
  IF ORS_ID_ = 1 THEN
    FOR SEC IN (SELECT I.ORI_PRICE, 
                         P.PRO_NAME, P.PRO_PRICE
                  FROM ORDERS_ITEMS I, PRODUCTS P
                  WHERE I.PRO_ID = P.PRO_ID
                    AND ORD_ID = ORD_ID_) LOOP
      IF SEC.ORI_PRICE > SEC.PRO_PRICE * 1.1 OR SEC.ORI_PRICE < SEC.PRO_PRICE * 0.9 THEN
        RAISE_APPLICATION_ERROR (-20500, 'O item ' || SEC.PRO_NAME || ' está com uma divergência de mais de 10 % do preço original do produto', TRUE);
      END IF;
                  
    END LOOP;  
  END IF;
  
  UPDATE TBL_ORDERS SET ORS_ID = ORS_ID_
  WHERE ORD_ID = ORD_ID_;
END;

--Clientes
INSERT INTO TBL_CUSTOMERS(CSM_NAME)
                   VALUES('Lucas Pechebelok');
                   
INSERT INTO TBL_CUSTOMERS(CSM_NAME)
                   VALUES('Lucas Hernandes');

COMMIT;

--PRODUCTS + SIMULAÇÃO DE UMA ENTRADA COM COMPRA
BEGIN
  DECLARE 
    PRO_ID_ TBL_PRODUCTS.PRO_ID%TYPE;
    PRO_PRICE_ TBL_PRODUCTS.PRO_PRICE%TYPE;
    ORD_ID_ TBL_ORDERS.ORD_ID%TYPE;
  BEGIN
    INSERT INTO TBL_ORDERS(CSM_ID, ORD_ID, ORD_VALUE, ORT_ID, ORS_ID)
                    VALUES((SELECT CSM_ID
                            FROM TBL_CUSTOMERS
                            WHERE CSM_NAME = 'Lucas Pechebelok'), 0, 0, 0, 0) RETURNING ORD_ID INTO ORD_ID_;
  
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Mouse', 15.54, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;
    
    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 5, PRO_PRICE_);                         
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Teclado', 20, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 5, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Celular', 500, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 10, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Carregador', 50.5, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 50, PRO_PRICE_);     

    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Monitor', 155.8, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 6, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(1, 'Teste', 50.5, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 4, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Memoria RAM', 150, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'HD', 200, 0);

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i5', 503.9, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 1º geração', 350, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 2º geração', 360, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  

    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 3º geração', 370, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 4º geração', 380, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 5º geração', 390, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 6º geração', 400.5, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 7º geração', 405.5, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 8º geração', 415, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 9º geração', 425, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 10º geração', 435, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 11º geração', 445, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 2, PRO_PRICE_);  
                
    INSERT INTO TBL_PRODUCTS(PRS_ID, PRO_NAME, PRO_PRICE, PRO_QTY)
                      VALUES(0, 'Processador i3 12º geração', 455, 0) RETURNING PRO_ID, PRO_PRICE INTO PRO_ID_, PRO_PRICE_;

    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES(PRO_ID_, ORD_ID_, 4, PRO_PRICE_);  
  END;
END;

COMMIT;

/*
   PEDIDO DE VENDA
*/

SELECT *
FROM PRODUCTS
WHERE PRO_NAME = 'Mouse' OR PRO_NAME = 'Celular'
ORDER BY PRO_NAME;

/*
  O celular tem 10 unidades
  O mouse tem 5 unidades
  
  Vai ser criado um pedido de venda com itens de 
  3 unidade de celular
  2 unidades de mouse
*/



BEGIN
  DECLARE 
    ORD_ID_ TBL_ORDERS.ORD_ID%TYPE;
  BEGIN
    INSERT INTO TBL_ORDERS(CSM_ID, ORD_VALUE, ORT_ID, ORS_ID)
                    VALUES((SELECT CSM_ID
                            FROM TBL_CUSTOMERS
                            WHERE CSM_NAME = 'Lucas Hernandes'), 0, 1, 0) RETURNING ORD_ID INTO ORD_ID_;
                            
    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES((SELECT PRO_ID
                                  FROM TBL_PRODUCTS
                                  WHERE PRO_NAME = 'Mouse'), ORD_ID_, 2, 20.5);  
                            
    INSERT INTO TBL_ORDERS_ITEMS(PRO_ID, ORD_ID, ORI_QTY, ORI_PRICE)
                          VALUES((SELECT PRO_ID
                                  FROM TBL_PRODUCTS
                                  WHERE PRO_NAME = 'Celular'), ORD_ID_, 3, 502.1);                                    
  END;
END;

COMMIT;

/*
  O celular ficou com 7 unidades
  O mouse   ficou com 3 unidades
*/

SELECT *
FROM PRODUCTS
WHERE PRO_NAME = 'Mouse' OR PRO_NAME = 'Celular'
ORDER BY PRO_NAME;

/*
  SELECT I.ORI_PRICE, 
         P.PRO_NAME, P.PRO_PRICE
  FROM ORDERS_ITEMS I, PRODUCTS P
  WHERE I.PRO_ID = P.PRO_ID
    AND ORD_ID = 1; --CÓDIGO DO PEDIDO
  ORDER BY P.PRO_NAME;
  
  O preço original dos produtos são:

  O celular ficou com 500 unidades
  O mouse   ficou com 15,54 unidades

  O preço no pedido é:

  O celular ficou com 502,1 unidades
  O mouse   ficou com 20,5 unidades

  O mouse teve uma divergência de mais de 10% do preço original do produto, então ao efetivar a venda vai dar o erro com essa alerta.

*/

EXEC PCD_UPDATE_STATUS_ORDER(1, 1);

--Alterando o pedido para não ter mais essa divergência de preço
UPDATE TBL_ORDERS_ITEMS SET ORI_PRICE = 15
WHERE ORI_ID = 22;

-- O status do produto segue em Pendente
SELECT O.ORD_ID, O.ORD_VALUE,
       C.CSM_NAME,
       S.ORS_DESCRIPTION
FROM ORDERS O, CUSTOMERS C, ORDERS_STATUS S
WHERE O.CSM_ID = C.CSM_ID
  AND O.ORS_ID = S.ORS_ID
  AND O.ORD_ID = 1;


EXEC PCD_UPDATE_STATUS_ORDER(1, 1);

-- Status agora está como efetivado
SELECT O.ORD_ID, O.ORD_VALUE,
       C.CSM_NAME,
       S.ORS_DESCRIPTION
FROM ORDERS O, CUSTOMERS C, ORDERS_STATUS S
WHERE O.CSM_ID = C.CSM_ID
  AND O.ORS_ID = S.ORS_ID
  AND O.ORD_ID = 1;

--Cancelar o pedido e o status vai estar em Cancelado

EXEC PCD_UPDATE_STATUS_ORDER(1, 2);

--Ao cancelar o pedido o estoque volta ao produto, como no SQL abaixo, nele é possível conferir as movimentações do produtos e suas origens


SELECT P.PRO_NAME, M.PRM_QTY, O.ORD_ID, D.PMT_DESCRIPTION
FROM PRODUCTS P, PRODUCTS_MOV M, ORDERS_ITEMS I, ORDERS O, ORDERS_TYPES T, PRODUCTS_MOV_TYPES D
WHERE P.PRO_ID = M.PRO_ID
  AND M.ORI_ID = I.ORI_ID
  AND I.ORD_ID = O.ORD_ID
  AND O.ORT_ID = T.ORT_ID
  AND M.PMT_ID = D.PMT_ID
  AND P.PRO_NAME = 'Celular'
ORDER BY M.PRM_ID;


--Como o pedido foi cancelado seu estoque inicial

SELECT *
FROM PRODUCTS
WHERE PRO_NAME = 'Mouse' OR PRO_NAME = 'Celular'
ORDER BY PRO_NAME;


----------------------------------------------------------------------------------------------------------------------------------------------------------------
---                    CONTINUAÇÃO
----------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
  Montar uma consulta para conciliar se o saldo dos produtos na tabela de “PRODUTO” está correto, o saldo
  de um produto é a soma de todas as entradas subtraindo todas as saídas registradas na tabela de
  movimento do produto MOV_PRODUTO
*/

SELECT P.PRO_ID, P.PRO_NAME, P.PRO_QTY, 
       M.PRM_BALANCE
FROM PRODUCTS P,
     (SELECT SUM(DECODE(PMT_ID, 0, PRM_QTY, PRM_QTY * -1)) PRM_BALANCE, -- PMT_ID = 0 = ENTRADA, PMT_ID = 1 = SAÍDA 
             M.PRO_ID
      FROM PRODUCTS_MOV M
      GROUP BY M.PRO_ID) M
WHERE P.PRO_ID = M.PRO_ID(+); --SE O PRODUTO NÃO TEM NENHUMA MOVIMENTAÇÃO NO ESTOQUE

/*
 Montar uma consulta para apresentar os clientes e o valor total gasto por cliente
*/

SELECT C.CSM_ID, C.CSM_NAME,
       O.ORD_VALUE_SALES, O.ORD_VALUE_PURCHASES
FROM CUSTOMERS C,
     (SELECT SUM(DECODE(O.ORT_ID, 1, O.ORD_VALUE, 0)) ORD_VALUE_SALES,  -- ORT_ID = 0 = COMPRA
             SUM(DECODE(O.ORT_ID, 0, O.ORD_VALUE, 0)) ORD_VALUE_PURCHASES, -- ORT_ID = 1 = VENDA
             O.CSM_ID
      FROM ORDERS O
      GROUP BY O.CSM_ID
     ) O
WHERE C.CSM_ID = O.CSM_ID(+);

/*
  Montar uma consulta com os 20 produtos que têm mais saída e a soma total dos valores vendidos destes
  produtos.
*/

--Coloquei apelidos para ficar mais fácil a visualização
SELECT P.PRO_ID COD_PRODUTO, P.PRO_NAME NOME_PRODUTO, P.PRO_QTY QTD_PRODUTO_EM_ESTOQUE, 
       M.PRM_PURCHASES TOTAL_QTD_MOV_COMPRAS, M.PRM_SALES TOTAL_QTD_MOV_VENDAS,
       O.ORI_VALUE_SALES TOTAL_VALOR_VENDAS, O.ORI_VALUE_PURCHASES TOTAL_VALOR_COMPRAS
FROM PRODUCTS P,
     (SELECT SUM(DECODE(PMT_ID, 0, PRM_QTY, 0)) PRM_PURCHASES, -- PMT_ID = 0 = ENTRADA
             SUM(DECODE(PMT_ID, 1, PRM_QTY, 0)) PRM_SALES, --PMT_ID = 1 = SAÍDA 
             M.PRO_ID
      FROM PRODUCTS_MOV M
      GROUP BY M.PRO_ID) M,
      (SELECT SUM(DECODE(O.ORT_ID, 1, I.ORI_PRICE * I.ORI_QTY, 0)) ORI_VALUE_SALES,  -- ORT_ID = 0 = COMPRA
              SUM(DECODE(O.ORT_ID, 0, I.ORI_PRICE * I.ORI_QTY, 0)) ORI_VALUE_PURCHASES, -- ORT_ID = 1 = VENDA
              I.PRO_ID
       FROM ORDERS O, ORDERS_ITEMS I
       WHERE O.ORD_ID = I.ORD_ID
       GROUP BY I.PRO_ID) O
WHERE P.PRO_ID = M.PRO_ID(+)
  AND P.PRO_ID = O.PRO_ID(+)
ORDER BY NVL(M.PRM_SALES, 0) DESC --ORDENAR PARA OS PRODUTOS QUE TIVERAM MAIS VENDAS EM TERMO DE QUANTIDADE
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY --PRONTO PARA A PAGINAÇÃO/ 20 PRODUTOS



