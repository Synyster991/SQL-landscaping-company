﻿DROP COLLECTION PROC16;
CREATE COLLECTION PROC16;

REVOKE ALL ON SCHEMA PROC16 FROM PUBLIC;	

GRANT ALL ON SCHEMA PROC16 TO DS201D24;
GRANT ALL ON SCHEMA PROC16 TO DS201C02;
GRANT ALL ON SCHEMA PROC16 TO DS201C21;
GRANT ALL ON SCHEMA PROC16 TO DS201C13;

-- VIEW 1

CREATE TABLE PROC16.WORK_TEAM(
    TEAM_NO          NUMERIC(2)   PRIMARY KEY CHECK (TEAM_NO > 0),
    WORKTEAMDESC       VARCHAR(45)  NOT NULL
);
 
CREATE TABLE PROC16.CUSTOMER(
    CUST_NO              NUMERIC(4)   PRIMARY KEY CHECK (CUST_NO > 0),
    CUSTFIRSTNAME       VARCHAR(20) NOT NULL,
    CUSTLASTNAME        VARCHAR(20) NOT NULL,
    CUSTPCODE           CHAR(6) NOT NULL
);

CREATE TABLE PROC16.CUSTOMER_ADDRESS(
    CUSTPCODE       CHAR(6) PRIMARY KEY NOT NULL,
    CUSTADDRESS     VARCHAR(60) NOT NULL,
    CUSTCITY        VARCHAR(20) NOT NULL with default 'Toronto',
    CUSTPROV        CHAR(2) NOT NULL with default 'ON'
);

ALTER TABLE PROC16.CUSTOMER
    ADD FOREIGN KEY (CUSTPCODE) REFERENCES PROC16.CUSTOMER_ADDRESS(CUSTPCODE);
    
CREATE TABLE PROC16.EQUIPMENT(
    EQUIP#      NUMERIC(3)  PRIMARY KEY CHECK (EQUIP# > 0),
    EQUIPDESC   VARCHAR(60) NOT NULL
);
    
CREATE TABLE PROC16.SERVICE(
    SERVICE#        CHAR(2)     PRIMARY KEY,
    SERVICEDESC     VARCHAR(60) NOT NULL,
    HOURLYCHARGE    DECIMAL(7,2) NOT NULL
);

CREATE TABLE PROC16.INVOICE(
    INVOICE_ID      NUMERIC(4)  PRIMARY KEY,
    INVOICE_DATE    CHAR(6)     NOT NULL,
    SALE_ID         NUMERIC     DEFAULT 0,
    ASSISTANT_ID    NUMERIC     NOT NULL,   
    TEAM_NO         NUMERIC(2)  CHECK (TEAM_NO > 0),
    CUST_NO         NUMERIC(4)  CHECK (CUST_NO > 0),
    SERVICE#        CHAR(2)
);

ALTER TABLE PROC16.INVOICE
    ADD FOREIGN KEY (TEAM_NO) REFERENCES PROC16.WORK_TEAM(TEAM_NO);

ALTER TABLE PROC16.INVOICE
    ADD FOREIGN KEY (CUST_NO) REFERENCES PROC16.CUSTOMER(CUST_NO);    
    
ALTER TABLE PROC16.INVOICE
    ADD FOREIGN KEY (SERVICE#) REFERENCES PROC16.SERVICE(SERVICE#);
 
--CREATING THE EQUIPMENT JUNCTION TABLE    
CREATE TABLE PROC16.EQUIPMENT_INVOICE(
   INVOICE_ID        NUMERIC(4),
   EQUIP#          NUMERIC(3) CHECK (EQUIP# > 0)
);

--ADDING THE FOREIGN KEYS TO THE EQUIPMENT JUNCTION (EQUIPMENT_INVOICE)
ALTER TABLE PROC16.EQUIPMENT_INVOICE
    ADD FOREIGN KEY (INVOICE_ID) REFERENCES PROC16.INVOICE(INVOICE_ID);
    
ALTER TABLE PROC16.EQUIPMENT_INVOICE
    ADD FOREIGN KEY (EQUIP#) REFERENCES PROC16.EQUIPMENT(EQUIP#);
    
--CREATING THE SERVICE JUNCTION TABLE
CREATE TABLE PROC16.SERVICE_INVOICE(
    INVOICE_ID        NUMERIC(4),
    SERVICE#        CHAR(2),
    WORKDURATION    DECIMAL(4,2)       
);

--ADDING THE FOREIGN KEY TO THE SERVICE JUNCTION TABLE (SERVICE_INVOICE)
ALTER TABLE PROC16.SERVICE_INVOICE
    ADD FOREIGN KEY (INVOICE_ID) REFERENCES PROC16.INVOICE(INVOICE_ID);
    
ALTER TABLE PROC16.SERVICE_INVOICE
    ADD FOREIGN KEY (SERVICE#) REFERENCES PROC16.SERVICE(SERVICE#);

-- VIEW 2
CREATE TABLE PROC16.EMP (
    EMP_ID      NUMERIC         PRIMARY KEY,
    POS         VARCHAR(10)    CHECK (POS IN ('supervisor', 'lawn care')),
    F_NAME      VARCHAR(15)    NOT NULL,
    L_NAME      VARCHAR(15)    NOT NULL,
    OHIP        CHAR(9)     NOT NULL,
    HOME_PHONE  CHAR(12)    NOT NULL,
    START_DATE  CHAR(9)     NOT NULL,
    TEAM_NO        NUMERIC(2)  CHECK (TEAM_NO > 0)
);

CREATE TABLE PROC16.SKILL_JUNC (
    SKILL_ID    NUMERIC,
    EMP_ID      NUMERIC,
    TEAM_NO        NUMERIC(2)   CHECK (TEAM_NO > 0)   
);

CREATE TABLE PROC16.SKILL (
    SKILL_ID    NUMERIC         PRIMARY KEY,
    SKILL_DESC  VARCHAR(45)    NOT NULL
);

ALTER TABLE PROC16.SKILL_JUNC
    ADD CONSTRAINT PROC16.PK PRIMARY KEY (SKILL_ID, EMP_ID);

ALTER TABLE PROC16.SKILL_JUNC
    ADD CONSTRAINT PROC16.ID_SKILL FOREIGN KEY (SKILL_ID) REFERENCES PROC16.SKILL(SKILL_ID);

ALTER TABLE PROC16.SKILL_JUNC
    ADD CONSTRAINT PROC16.EMP_SKILL FOREIGN KEY (EMP_ID) REFERENCES PROC16.EMP(EMP_ID);

ALTER TABLE PROC16.SKILL_JUNC
    ADD CONSTRAINT PROC16.SKILL_TEAM FOREIGN KEY (TEAM_NO) REFERENCES PROC16.WORK_TEAM (TEAM_NO);
    
ALTER TABLE PROC16.EMP
    ADD CONSTRAINT PROC16.TEAM_EMP FOREIGN KEY (TEAM_NO) REFERENCES PROC16.WORK_TEAM (TEAM_NO);
   
-- VIEW 3

CREATE TABLE PROC16.ASSISTANT (
    ASSISTANT_ID    NUMERIC         PRIMARY KEY,
    F_NAME          VARCHAR(15)     NOT NULL,
    L_NAME          VARCHAR(15)     NOT NULL
);
    
CREATE TABLE PROC16.SALE (
    SALE_ID         NUMERIC      PRIMARY KEY,
    INVOICE_ID      NUMERIC(4),
    PROD_ID         NUMERIC,
    PROD_QTY        NUMERIC,
    PROD_COST       DECIMAL(4,2),
    ASSISTANT_ID    NUMERIC
);  

-- VIEW 4
CREATE TABLE PROC16.PRODUCT (
	PROD_ID numeric PRIMARY KEY, /* FK */
	PROD_DESC varchar(30),
           SUPPLIER VARCHAR(45)
);

CREATE TABLE PROC16.PRODUCTCLASS (
	PROD_CLASS char(2),
	CLASSIFICATION varchar(30),
	PROD_ID numeric, /* FK */
    PRIMARY KEY (PROD_CLASS, PROD_ID)
);

CREATE TABLE PROC16.PRODUCTCOST (
    PROD_ID numeric PRIMARY KEY,
	COST decimal(6,2),
	MARKUP decimal(2,1),
	CHARGE decimal(4,2)
);

ALTER TABLE PROC16.PRODUCTCLASS
	ADD CONSTRAINT PROC16.PROD_ID FOREIGN KEY(PROD_ID) REFERENCES PROC16.PRODUCT (PROD_ID);

ALTER TABLE PROC16.PRODUCTCOST
	ADD CONSTRAINT PROC16.PRODCOST_ID FOREIGN KEY(PROD_ID) REFERENCES PROC16.PRODUCT (PROD_ID);

ALTER TABLE PROC16.SALE
    ADD CONSTRAINT PROC16.SALE_PROD_ID FOREIGN KEY (PROD_ID) REFERENCES PROC16.PRODUCT (PROD_ID);

ALTER TABLE PROC16.SALE
    ADD CONSTRAINT PROC16.INV_ID FOREIGN KEY (INVOICE_ID) REFERENCES PROC16.INVOICE (INVOICE_ID);
 
ALTER TABLE PROC16.SALE
    ADD CONSTRAINT PROC16.INV_ASS FOREIGN KEY (ASSISTANT_ID) REFERENCES PROC16.ASSISTANT (ASSISTANT_ID);

ALTER TABLE PROC16.INVOICE
    ADD CONSTRAINT PROC16.INV_SALE_ID FOREIGN KEY (SALE_ID) REFERENCES PROC16.SALE (SALE_ID);
    

-- --VIEW 5

CREATE TABLE PROC16.INVENTORY(
    PROD_ID     NUMERIC     PRIMARY KEY,
    INVENTORY   NUMERIC     NOT NULL,
    AISLE       NUMERIC     NOT NULL
);

ALTER TABLE PROC16.INVENTORY
    ADD CONSTRAINT PROC16.INV_PROD_ID FOREIGN KEY (PROD_ID) REFERENCES PROC16.PRODUCT (PROD_ID);
    
-- DATA ENTRY

-- VIEW 1 DATA:
INSERT INTO PRACDBS.CUSTOMER VALUES
(
    56,
    'JOHN',
    'ADAMS',
    'M2S4S3'
    );
   
INSERT INTO PRACDBS.CUSTOMER_ADDRESS VALUES
(
    'M2S4S3',
    '234 Bloor st',
    'Toronto',
    'ON' 
);

INSERT INTO PRACDBS.CUSTOMER VALUES
(
    7,
    'FILLIP',
    'BOX',
    'M2S7AP'
    );
   
INSERT INTO PRACDBS.CUSTOMER_ADDRESS VALUES
(
    'M2S7AP',
    '222 Keele st',
    'Toronto',
    'ON' 
);

INSERT INTO PRACDBS.EQUIPMENT VALUES
(
    100,
    'XXXX'
);

INSERT INTO PRACDBS.EQUIPMENT VALUES
(
    200,
    'ZZZZ'
);

INSERT INTO PRACDBS.WORK_TEAM VALUES
(
    1,
    'X FACTOR'
);

INSERT INTO PRACDBS.WORK_TEAM VALUES
(
    2,
    'MY TEAM'
);

INSERT INTO PRACDBS.SERVICE VALUES
(
    'AB',
    'CLEANING',
    7.00
);

INSERT INTO PRACDBS.SERVICE VALUES
(
    'CD',
    'CUTTING GRASS',
    20.00
);

INSERT INTO PRACDBS.SERVICE_INVOICE VALUES
(
    123,
    'AB',
    3.5
);
INSERT INTO PRACDBS.SERVICE_INVOICE VALUES
(
    456,
    'CD',
    5.6
);

INSERT INTO PRACDBS.INVOICE VALUES
(
    1000,
    190223,
    1,
    56,
    'AB'
);


INSERT INTO PRACDBS.INVOICE VALUES
(
    2000,
    190224,
    2,
    7,
    'CD'
);
CREATE VIEW PRACDBS.SERVICE_VIEW AS
    SELECT 
    PRACDBS.SERVICE.SERVICE# AS "SERVICE",
    PRACDBS.SERVICE.SERVICEDESC AS "DESCRIPTION",
    PRACDBS.SERVICE.HOURLYCHARGE AS "HOURLY CHARGE",
    PRACDBS.SERVICE_INVOICE.WORKDURATION "WORK DURATION",
    PRACDBS.SERVICE_INVOICE.WORKDURATION * PRACDBS.SERVICE.HOURLYCHARGE AS "TOTAL CHARGE"
    FROM
    PRACDBS.SERVICE,
    PRACDBS.SERVICE_INVOICE
    WHERE PRACDBS.SERVICE.SERVICE# = PRACDBS.SERVICE_INVOICE.SERVICE#;
   
 SELECT SUM("TOTAL CHARGE") AS "TOTAL" 
          FROM PRACDBS.SERVICE_VIEW;
  
CREATE VIEW PRACDBS.INVOICE_VIEW AS    
 SELECT 
     PRACDBS.INVOICE.INVOICE_ID AS "INVOICE NUMBER", 
     PRACDBS.INVOICE.INVOICEDATE AS "INVOICE DATE",
     PRACDBS.INVOICE.TEAM_NO AS "WORK TEAM",
     PRACDBS.INVOICE.CUST_NO AS "CUSTOMER",
     PRACDBS.INVOICE.SERVICE# AS "SERVICE"
    FROM
    PRACDBS.INVOICE;
    

CREATE VIEW PRACDBS.COMPLETE_VIEW AS          
SELECT 
     PRACDBS.INVOICE.INVOICE_ID AS "INVOICE NUMBER", 
     PRACDBS.INVOICE.INVOICEDATE AS "INVOICE DATE",
     PRACDBS.INVOICE.TEAM_NO AS "WORK TEAM",
     PRACDBS.INVOICE.CUST_NO AS "CUSTOMER",
     PRACDBS.CUSTOMER.CUSTFIRSTNAME ||' '|| PRACDBS.CUSTOMER.CUSTLASTNAME AS "CUSTOMER NAME",
     PRACDBS.CUSTOMER_ADDRESS.CUSTADDRESS AS "CUSTOMER ADDRESS",
     PRACDBS.CUSTOMER_ADDRESS.CUSTCITY AS "CUSTOMER CITY",
     PRACDBS.CUSTOMER_ADDRESS.CUSTPROV AS "PROV",
     PRACDBS.CUSTOMER_ADDRESS.CUSTPCODE AS "POSTAL CODE",
     PRACDBS.INVOICE.SERVICE# AS "SERVICE",
    PRACDBS.SERVICE.SERVICEDESC AS "DESCRIPTION",
    PRACDBS.SERVICE.HOURLYCHARGE AS "HOURLY CHARGE",
    PRACDBS.SERVICE_INVOICE.WORKDURATION "WORK DURATION",
    PRACDBS.SERVICE_INVOICE.WORKDURATION * PRACDBS.SERVICE.HOURLYCHARGE AS "SUBTOTAL"
    FROM
    PRACDBS.INVOICE,
    PRACDBS.SERVICE,
    PRACDBS.SERVICE_INVOICE,
    PRACDBS.CUSTOMER,
    PRACDBS.CUSTOMER_ADDRESS
    WHERE PRACDBS.SERVICE.SERVICE# = PRACDBS.SERVICE_INVOICE.SERVICE# AND
          PRACDBS.INVOICE.SERVICE# = PRACDBS.SERVICE.SERVICE# AND
          PRACDBS.CUSTOMER.CUST_NO = PRACDBS.INVOICE.CUST_NO AND
          PRACDBS.CUSTOMER.CUSTPCODE = PRACDBS.CUSTOMER_ADDRESS.CUSTPCODE;


-- VIEW 2 DATA:
INSERT INTO PROC16.WORK_TEAM
    VALUES  (1, 'General Contracting'),
            (2, 'Pruning and Planting'),
            (3, 'General Maintenance');

INSERT INTO PROC16.EMP
    VALUES  (120, 'supervisor', 'Cindy', 'Lee', '219032002', '905-338-1234','1-jan-98', 1),
            (121, 'lawn care', 'Paula', 'Corelli', '325443001', '416-458-4562', '30-jun-98', 2),
            (122, 'lawn care', 'Amy', 'Smith', '34111991', '905-338-1234', '30-jun-99', 1),
            (123, 'supervisor', 'Paul', 'Huang', '54222991', '416-932-4533', '30-jun-05', 2),
            (124, 'lawn care', 'Maria', 'Wong', '43524532', '905-345-5366', '23-aug-98', 3),
            (126, 'supervisor', 'Phil', 'Ramirez', '32543555', '416-435-6599', '3-mar-17', 3);

INSERT INTO PROC16.SKILL
    VALUES  (100, 'electrical'),
            (101, 'plumbing'),
            (102, 'general contractor'),
            (103, 'irrigation'),
            (104, 'lawn maintenance'),
            (105, 'pruning'),
            (106, 'fertilizing'),
            (107, 'A license');
           
INSERT INTO PROC16.SKILL_JUNC (SKILL_ID, EMP_ID, TEAM_NO)
    VALUES  (100, 120, 1),
            (100, 126, 3),
            (101, 120, 1),
            (101, 126, 3),
            (102, 120, 1),
            (102, 123, 2),
            (103, 122, 1),
            (103, 121, 2),
            (103, 126, 3),
            (104, 122, 1),
            (104, 124, 3),
            (105, 121, 2),
            (105, 124, 3),
            (106, 121, 2),
            (107, 123, 2);
            
CREATE VIEW PROC16.TEAM_EMPLOYEE_REPORTS AS
    SELECT PROC16.EMP.TEAM_NO AS "TEAM",
                    PROC16.WORK_TEAM.WORKTEAMDESC AS "DESCRIPTION",
                    PROC16.EMP.POS AS "POSITION",
                    PROC16.EMP.F_NAME || ' ' ||
                    PROC16.EMP.L_NAME AS "NAME",
                    PROC16.EMP.EMP_ID,
                    PROC16.EMP.OHIP,
                    PROC16.EMP.HOME_PHONE AS "HOME PHONE",
                    PROC16.EMP.START_DATE AS "START DATE",
                    PROC16.SKILL.SKILL_DESC AS "SKILLS"
                    FROM PROC16.EMP, PROC16.SKILL, PROC16.SKILL_JUNC, PROC16.WORK_TEAM
                        WHERE PROC16.EMP.EMP_ID = PROC16.SKILL_JUNC.EMP_ID
                        AND PROC16.SKILL_JUNC.SKILL_ID = PROC16.SKILL.SKILL_ID
                        AND PROC16.EMP.TEAM_NO = PROC16.SKILL_JUNC.TEAM_NO
                        AND PROC16.WORK_TEAM.TEAM_NO = PROC16.EMP.TEAM_NO
                        AND PROC16.EMP.TEAM_NO = PROC16.WORK_TEAM.TEAM_NO; 
      
-- VIEW 3 DATA:
INSERT INTO PROC16.ASSISTANT
    VALUES (144, 'Paul', 'Smith'),
        (145, 'Maria', 'Wong');
        

INSERT INTO PROC16.SALE
    VALUES  (1, 1356, 10, 1, 12.00, 144);
            (2, 1356, 40, 1, 8.00, 144),
            (3, 1367, 50, 1, 8.00, 145),
            (4, 1405, 50, 1, 7.00, 145);
        
CREATE VIEW Product_Sales_Report  AS;
SELECT pc.PROD_CLASS AS "PROD. CLASS",
    		pc.PROD_ID AS "PROD ID",
    		pd.PROD_DESC AS "PRODUCT",
    		'$' || ps.PROD_COST AS "CHARGE",
    		ps.PROD_QTY AS "QTY",
    		ps.INVOICE_ID AS "INVOICE ID",
    		pn.INVOICE_DATE AS "INVOICE DATE",
    		pa.ASSISTANT_ID || '-' || pa.F_NAME|| ' ' || pa.L_NAME  AS "SALES ASSISTANT",
    		pn.CUST_NO AS "CUST NO."
    	FROM PROC16.INVOICE pn, PROC16.ASSISTANT pa, PROC16.SALE ps, PROC16.PRODUCT pd, PROC16.PRODUCTCLASS pc, PROC16.CUSTOMER pu
    	WHERE pc.PROD_ID = ps.PROD_ID
    	AND ps.INVOICE_ID = ps.INVOICE_ID
    	AND pa.ASSISTANT_ID = pn.ASSISTANT_ID
    	AND pn.CUST_NO = pu.CUST_NO;


-- VIEW 4 DATA:
INSERT INTO PROC16.PRODUCT 
    VALUES (10, '6 foot garden rake', 'Sheffield-Gander inc.'),
        (20, '7 foot leaf rake', 'Sheffield-Gander inc.'),
        (30, 'Round mouth shovel', 'Husky Inc.'),
        (40, 'Flat-nosed Shovel', 'Husky Inc.'),
        (50, 'Garden pitch-fork', 'Husky Inc.'),
        (60, '8 inch hand shears', 'Sheffield-Gander inc.'),
        (70, '12 inch trimming shears', 'Sheffield-Gander inc.');
        
INSERT INTO PROC16.PRODUCTCLASS
    VALUES ('GT', 'Garden Tools', 10),
            ('GT', 'Garden Tools', 20),
            ('GT', 'Garden Tools', 30),
            ('GT', 'Garden Tools', 40),
            ('GT', 'Garden Tools', 50),
            ('GT', 'Garden Tools', 60),
            ('GT', 'Garden Tools', 70);
                        
INSERT INTO PROC16.PRODUCTCOST
    VALUES (10, 9.23, 0.3, 12.00),
        (20, 7.69, 0.3, 10.00),
        (30, 7.69, 0.3, 10.00),
        (40, 6.15, 0.3, 8.00),
        (50, 5.38, 0.3, 7.00),
        (60, 11.54, 0.3, 15.00),
        (70, 14.62, 0.3, 19.00);

CREATE VIEW PRODUCT_REPORT_VW2 AS
    SELECT pc.PROD_CLASS AS "PRODUCT CLASS: ", pc.CLASSIFICATION, pr.PROD_ID AS "PRODUCT ID: ",
                    pr.PROD_DESC AS "DESCRIPTION", '$' || pt.COST AS COST, CAST(pt.MARKUP * 100 AS INT) || '%' AS MARKUP, '$' || pt.CHARGE AS "CHARGE"
                    FROM PROC16.PRODUCT pr, PROC16.PRODUCTCLASS pc, PROC16.PRODUCTCOST pt
                        WHERE pr.PROD_ID = pc.PROD_ID
                        AND pc.PROD_ID = pt.PROD_ID;
                                 
-- VIEW 5 DATA:

INSERT INTO PROC16.INVENTORY
    VALUES(10, 5, 1),
        (20, 5, 1),
        (30, 4, 1),
        (40, 2, 1),
        (50, 6, 1),
        (60, 9, 2),
        (70, 10, 2);

CREATE VIEW INVENTORY_REPORT_VW2 AS
    SELECT pn.PROD_ID, pr.PROD_DESC AS "DESCRIPTION", 
        pn.INVENTORY, pn.AISLE AS "AISLE#", pr.SUPPLIER
            FROM PROC16.INVENTORY pn, PROC16.PRODUCT pr
            WHERE pn.PROD_ID = pr.PROD_ID;
            