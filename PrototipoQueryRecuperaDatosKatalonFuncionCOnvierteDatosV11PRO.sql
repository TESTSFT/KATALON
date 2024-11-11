--Select * from VALORES_RECUPERADOS
--DROP TABLE VALORES_RECUPERADOS
--GO
GEN_RBT_KT 'IDCRBT007', 'FCRMVH', 675
GO

ALTER PROCEDURE GEN_RBT_KT @CODEMP VARCHAR(10), @CODUSO VARCHAR(40), @NUMERO NUMERIC(18)
AS
BEGIN



/* ####### Función ######*/

/*
CREATE OR ALTER FUNCTION dbo.ExtractQuotedValues (@inputText VARCHAR(MAX))
RETURNS @values TABLE (Valores_Recuperados VARCHAR(MAX)/*, Campo VARCHAR(MAX), Valor Varchar(25), TipoDato VARCHAR(25), Carpeta VARCHAR(25)*/)
AS

BEGIN
    DECLARE @start INT = 1;
    DECLARE @end INT = 1;
    DECLARE @currentValue VARCHAR(MAX) = '';  -- Variable para acumular valores
	DECLARE @currentCampo VARCHAR(MAX) = '';  -- Variable para acumular valores
 
	BEGIN
            -- Si no hay más comillas y no empieza con DIM, asigna a la variable @currentValue el valor tal cual de la fila para ser insertado como viene, el WHILE lo ignora.
            IF LEN(@inputText) > 0 and @inputText not like '%"%' and @inputText not like 'Dim%'
            BEGIN
				--SET @currentValue = LEFT(@inputText, CHARINDEX('.', @inputText,1))
				SET @currentValue = SUBSTRING(@inputText, CHARINDEX('.', @inputText) + 1, LEN(@inputText));

            END
            
     END

	/*####### Busca el script, busca si encuentra comillas dobles (") y recupera el valor que se encuentra entre comillas dobles #######*/
    WHILE @start > 0 AND @end > 0

    BEGIN
        SET @start = CHARINDEX('"', @inputText, @end);
        IF @start > 0

        BEGIN
            SET @end = CHARINDEX('"', @inputText, @start + 1);
            IF @end > 0
            BEGIN
                DECLARE @newValue VARCHAR(MAX);
                SET @newValue = SUBSTRING(@inputText, @start + 1, @end - @start - 1);
 
                -- Si @currentValue no está vacío, agrega una coma antes del nuevo valor
                IF LEN(@currentValue) > 0
                BEGIN
                    SET @currentValue = @currentValue + '/' + @newValue;
                END
                ELSE
                BEGIN
                    SET @currentValue = @newValue;
                END
 
                SET @end = @end + 1;
            END
        END
    END
 
    /*####### Inserta el valor acumulado en la tabla de retorno #######*/

    INSERT INTO @values (Valores_Recuperados)
    VALUES (@currentValue);

    RETURN
END;

/*####### Fin de la función #######*/

*/
 
--#################

/*####### Crea una tabla temporal mediante un WITH para luego insertar los valores en una tabla utilizando la función ExtractQuotedValues #######*/

 

DECLARE @nombres VARCHAR(MAX);
DECLARE @COMPAN VARCHAR(MAX);
DECLARE @CodPru VARCHAR(MAX);
DECLARE @NroPru int;

--Si existe la tabla VALORES_RECUPERADOS la borra y la vuelve a crear
IF OBJECT_ID('VALORES_RECUPERADOS', 'U') IS NOT NULL
	BEGIN
		DROP TABLE VALORES_RECUPERADOS
	END

CREATE TABLE VALORES_RECUPERADOS (Orden INT ,Empresa_Prueba VARCHAR(MAX),Caso_Prueba VARCHAR(MAX),Numero_Prueba int, Valores_Recuperados VARCHAR(MAX), Campo VARCHAR(MAX), Campo_Valor Varchar(MAX), Campo_TipoDato VARCHAR(25), Repositorio_Objetos VARCHAR(MAX), Repositorio_TestCase VARCHAR(MAX), Repositorio_Script VARCHAR(MAX));

-- Obtener el script de la columna y reemplazar los saltos de línea por el carácter '#'
SET @nombres = ( 
    SELECT  REPLACE(CONVERT(VARCHAR(MAX), RBTTESTCASE_SCRIPT), CHAR(13) + CHAR(10), '#')
    FROM SLRBTTESTCASE 
    WHERE RBTTESTCASE_CODUSO = @CODUSO AND RBTTESTCASE_NUMERO = @NUMERO and RBTTESTCASE_COMPAN = @CODEMP
);


-- Usar la CTE para dividir el texto
WITH SCRIPT_FILAS (LINEA_SCRIPT) AS (
    SELECT  Value
    FROM  STRING_SPLIT (@nombres, '#')
    WHERE Value <> '' AND Value NOT IN ('TestCase.ExecAllAutoInits', 'TestCase.ExecAllAutoVPs') and Value not like '%testcase.execsql("%' and Value not like '%Error.DoExplicitOk%' and Value not like '%NextObject%' and Value not like '%CloseABM%' )
 
INSERT INTO VALORES_RECUPERADOS (Orden,Empresa_Prueba,Caso_Prueba,Numero_Prueba,Valores_Recuperados)
SELECT ROW_NUMBER() OVER (ORDER BY @CODEMP) as TEST,@CODEMP,@CODUSO,@NUMERO,Valores_Recuperados
FROM SCRIPT_FILAS
CROSS APPLY dbo.ExtractQuotedValues(CAST(LINEA_SCRIPT AS VARCHAR(MAX)))
WHERE Valores_Recuperados <> '' 


/*####### Fin de la tabla temporal #######*/



/*####### Actualiza los campos de la tabla VALORES_RECUPERADOS #######*/

	Update VALORES_RECUPERADOS 
	set Campo = REVERSE(SUBSTRING(REVERSE((Valores_Recuperados)), 1, CHARINDEX('/', REVERSE((Valores_Recuperados)), CHARINDEX('/', REVERSE((Valores_Recuperados))) + 1) - 1)), 
	Campo_Valor = REVERSE(SUBSTRING(REVERSE((Valores_Recuperados)), 1, CHARINDEX('/', REVERSE((Valores_Recuperados)), CHARINDEX('/', REVERSE((Valores_Recuperados))) + 1) - 1))
	From VALORES_RECUPERADOS where Valores_Recuperados like '%/%'

	Update VALORES_RECUPERADOS set Campo = LEFT(Campo, CHARINDEX('/', Campo, 1) - 1), -- Se extrae el valor antes de la primera barra
	Campo_Valor = SUBSTRING(Campo_Valor, CHARINDEX('/', Campo_Valor) + 1, LEN(Campo_Valor)) -- Se extrae el valor antes de la primera barra
	From VALORES_RECUPERADOS where Valores_Recuperados like '%/%'

	Update VALORES_RECUPERADOS set Campo = Valores_Recuperados From VALORES_RECUPERADOS where Valores_Recuperados not like '%/%'


/*####### Actualiza el Tipo de Dato de la tabla VALORES_RECUPERADOS, si es Virtual le pone el valor "v". #######*/

Update VALORES_RECUPERADOS  SET Campo_TipoDato = ISNULL(DATA_TYPE, 'v')
From VALORES_RECUPERADOS LEFT JOIN INFORMATION_SCHEMA.COLUMNS ON Campo = COLUMN_NAME

/*####### Actualiza el Tipo de Dato de la tabla VALORES_RECUPERADOS para los campos del tipo acción (Siguiente, Finalizar, etc), le pone el valor "a". #######*/

Update VALORES_RECUPERADOS  SET Campo_TipoDato = Valores_Recuperados
From VALORES_RECUPERADOS 
where Valores_Recuperados IN ('MoveNext','SaveAndClose', 'Finish', 'Cancel', 'Save')

/*####### Actualiza el primer Tipo de Dato de la tabla VALORES_RECUPERADOS para el objeto que va a abrir, le pone 'ob'. #######*/

Update VALORES_RECUPERADOS SET Campo_TipoDato = 'ob'
From VALORES_RECUPERADOS 
where Valores_Recuperados = (Select TOP 1 Valores_Recuperados From VALORES_RECUPERADOS)


/*####### Actualiza el campo 'valor' de los tipos fecha #######*/


Update VALORES_RECUPERADOS set Campo_Valor =(
   SUBSTRING(Campo_Valor, 7, 2) + -- Día
   SUBSTRING(Campo_Valor, 5, 2) + -- Mes
   SUBSTRING(Campo_Valor, 1, 4) -- Año
)
from 
VALORES_RECUPERADOS where Campo_TipoDato='datetime'



/*####### Actualiza el Tipo de Dato para los campos fisicos del tipo check de los objetos de la tabla VALORES_RECUPERADOS , le pone 'check'. #######*/

Update VALORES_RECUPERADOS SET Campo_TipoDato = 'check'
From VALORES_RECUPERADOS 
where Campo = 'CWA_INT_SEL' or 'ABoolean' = (Select TOP 1 Alias From cwtmfields where FIeldName = Campo)


/*####### Actualiza el tipo de Dato para los campo Tipo Lista #######*/
Update VALORES_RECUPERADOS SET Campo_TipoDato = 'lista'
From VALORES_RECUPERADOS 
where EXISTS(Select 1  From cwTMDatatypes where name = (Select TOP 1 Alias From cwtmfields where FieldName = Campo) and DataList_ARG <> '' and DataList_ARG IS NOT NULL)



/*####### Completo el campo Carpeta #######*/


Update VALORES_RECUPERADOS Set Repositorio_Objetos = 

    CASE 
        WHEN CHARINDEX('/1/', Valores_Recuperados) > 0 AND NOT Valores_Recuperados IN ('MoveNext','SaveAndClose', 'Finish', 'Cancel', 'Save') AND Valores_Recuperados not like '1/1/%' THEN (Select '/Object Repository/'+(Select ModuleName From cwOMObjects where Name = (Select Valores_Recuperados From VALORES_RECUPERADOS where Campo_TipoDato = 'ob') and Class in ('4', '6')) +'/'+REPLACE(STUFF(Valores_Recuperados, CHARINDEX('/1/', Valores_Recuperados), 3, '/'), Campo+'/'+Campo_Valor,''))
		WHEN Campo_TipoDato = 'ob'  THEN '/Object Repository/ClickABM/' 
		WHEN Campo_TipoDato IN ('MoveNext','SaveAndClose',  'Finish', 'Cancel', 'Save') THEN  '/Object Repository/ObjetosComunes/'
		WHEN Valores_Recuperados like '1/1/%' THEN ( Select 'Object Repository/'+ModuleName +'/'+ (Select Valores_Recuperados From VALORES_RECUPERADOS where Campo_TipoDato = 'ob') +'/'+ 'ParamRepo/'  From cwOMObjects where Name = (Select Valores_Recuperados From VALORES_RECUPERADOS where Campo_TipoDato = 'ob') )
        ELSE Valores_Recuperados 
    END
	
From VALORES_RECUPERADOS 


/*####### Actualiza las rutas de los repositorios de TestCase/Script. #######*/

Update VALORES_RECUPERADOS SET Repositorio_TestCase = (
Select ( Select '/Test Cases/'+ModuleName +'/'+Valores_Recuperados+'/'+Empresa_Prueba+'/'+Caso_Prueba+'/'+Caso_Prueba+'-'+Convert(VARCHAR(MAX),Numero_Prueba)
From cwOMObjects where Name = (Select Valores_Recuperados From VALORES_RECUPERADOS where Campo_TipoDato = 'ob') )
),
Repositorio_Script = (
Select ( Select '/Scripts/'+ModuleName +'/'+Valores_Recuperados+'/'+Empresa_Prueba+'/'+Caso_Prueba+'/'+Caso_Prueba+'-'+Convert(VARCHAR(MAX),Numero_Prueba)
From cwOMObjects where Name = (Select Valores_Recuperados From VALORES_RECUPERADOS where Campo_TipoDato = 'ob') )
)
From VALORES_RECUPERADOS 
where Campo_TipoDato = 'ob'


Select 
Orden,
Empresa_Prueba FLD001, 
Caso_Prueba			FLD002,  
Numero_Prueba		FLD003,  
Valores_Recuperados	FLD004, 
Campo				FLD005, 
Campo_Valor			FLD006, 
Campo_TipoDato		FLD007, 
Repositorio_Objetos	FLD008, 
Repositorio_TestCase FLD009, 
Repositorio_Script	FLD010
 From VALORES_RECUPERADOS

END

GO

select * from VALORES_RECUPERADOS


/*####### 

PENDIENTE:

--CONSIDERACIONES:
	--Por el momento NO se contemplan las lineas del script que contengan querys de ejecución(testcase.exec("")), tampoco contempla validaciones de mensajes de errores (ErrorDoOK).

	--OBEJTOS - STTTPH-4
	--WIZZARS - COCIECOMWIZ-5
	--COBRANZA - VTRRCH-54

	8/11--- FALTA ID A LAS TABLAS,COLUMNA SCRIPT Y TEST CASE 


--TABLA DE EQUIVALENCIAS (TABLA AUXILIAR)
--DEFINIR EL REPOSITORIO DE KATALON (CARPETAS)

#######*/


--Si existe la tabla VALORES_RECUPERADOS la borra y la vuelve a crear
IF OBJECT_ID('EQUIVALENCIAS_RBT_KAT', 'U') IS NOT NULL
	BEGIN
		DROP TABLE EQUIVALENCIAS_RBT_KAT
	END

CREATE TABLE EQUIVALENCIAS_RBT_KAT (Orden TIMESTAMP, TipoDato VARCHAR(MAX), KATALON VARCHAR(MAX))

Select REPLACE(REPLACE(REPLACE(REPLACE(KATALON , '@Script',ISNULL(Valores_Recuperados,'')),'@Repositorio',ISNULL(Repositorio_Objetos, '')),'@Campo', ISNULL(Campo, '')), '@Valor', ISNULL(Campo_Valor,'')), *
From VALORES_RECUPERADOS as VR RIGHT JOIN  EQUIVALENCIAS_RBT_KAT  as EQ  ON 
VR.Campo_TipoDato = EQ.TipoDato
--WHERE Campo_TipoDato = 'ob'
order by VR.Orden, EQ.Orden

Select * From VALORES_RECUPERADOS --where Campo_TipoDato = 'ob'
Select * From EQUIVALENCIAS_RBT_KAT --where TipoDato = 'ob'




INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('ob',
 'WebUI.click(findTestObject(''ObjetosComunes/span_Ver''))'),('ob',
 'WebUI.delay(2) '),('ob',
 'WebUI.click(findTestObject(''Object Repository/Page_LogicWEB/div_BuscarCtrlF'')) '),('ob',
 'WebUI.delay(2) '),('ob',
 'WebUI.setText(findTestObject(''Object Repository/Page_LogicWEB/inputsearchText''), ''@Script'') '),('ob',
 'WebUI.delay(2) '),('ob',
 'WebUI.sendKeys(findTestObject(''Object Repository/Page_LogicWEB/inputsearchText''), Keys.chord(Keys.ENTER))  '),('ob',
 'WebUI.delay(2) '),('ob',
 'WebUI.doubleClick(findTestObject(''@Repositoriotd_@Script'')) '),('ob',
 'WebUI.delay(2) '),('ob',
 'WebUI.switchToWindowIndex(1)'),('ob',
 'WebUI.delay(10) ')





 INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('char',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('char',
 'WebUI.delay(3) '),('char',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), ''@Valor'') '),('char',
 'WebUI.delay(3) ')

  INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('varchar',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('varchar',
 'WebUI.delay(3) '),('varchar',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), ''@Valor'') '),('varchar',
 'WebUI.delay(3) ')

   INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('numeric',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('numeric',
 'WebUI.delay(3) '),('numeric',
 'WebUI.sendKeys(findTestObject(''@Repositorio@Campo''),  ''@Valor'')'),('numeric',
 'WebUI.delay(3) ')

     INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('int',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('int',
 'WebUI.delay(3) '),('int',
 'WebUI.sendKeys(findTestObject(''@Repositorio@Campo''),  ''@Valor'')'),('int',
 'WebUI.delay(3) ')

    INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('smallint',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('smallint',
 'WebUI.delay(3) '),('smallint',
 'WebUI.sendKeys(findTestObject(''@Repositorio@Campo''),  ''@Valor'')'),('smallint',
 'WebUI.delay(3) ')


 INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('check',
 'WebUI.check(findTestObject(''@Repositorio@Campo''))'),('check',
 'WebUI.delay(3) ')


  INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('lista',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('lista',
 'WebUI.delay(3) '),('lista',
 'WebUI.selectOptionByValue(findTestObject(''@Repositorio@Campo''), ''@Valor'', true)'),('lista',
 'WebUI.delay(3) ')


 INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('SaveAndClose',
 'WebUI.click(findTestObject(''@Repositorio@Campo''))'),('SaveAndClose',
 'WebUI.delay(3) '),('SaveAndClose',
 'WebUI.switchToWindowIndex(1)'),('SaveAndClose',
 'WebUI.delay(3) ') ,('SaveAndClose',
 'WebUI.click(findTestObject(''Object Repository/Page_LogicWEB/button_OK''))'),('SaveAndClose',
 'WebUI.closeBrowser()')

 INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('MoveNext',
 ' WebUI.click(findTestObject(''@Repositorio@Campo''))'),('MoveNext',
 'WebUI.delay(3) ')

  INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('Finish',
 ' WebUI.click(findTestObject(''@Repositorio@Campo''))'),('Finish',
 'WebUI.delay(3) ')


   INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('Cancel',
 ' WebUI.click(findTestObject(''@Repositorio@Campo''))'),('Cancel',
 'WebUI.delay(3) ')

   INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('v',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('v',
 'WebUI.delay(3) '),('v',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), ''@Valor'') '),('v',
 'WebUI.delay(3) ')


    INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('Save',
 'WebUI.click(findTestObject(''Object Repository/ObjetosComunes/span_Archivo'')) '),('Save',
 'WebUI.delay(3) '),('Save',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('Save',
 'WebUI.delay(3) ')


   INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('datetime',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('datetime',
 'WebUI.delay(3) '),('datetime',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), ''@Valor'') '),('datetime',
 'WebUI.delay(3) ')


    INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('text',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('text',
 'WebUI.delay(3) '),('text',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), ''@Valor'') '),('text',
 'WebUI.delay(3) ')

     INSERT INTO EQUIVALENCIAS_RBT_KAT (TipoDato, KATALON) VALUES ('float',
 'WebUI.click(findTestObject(''@Repositorio@Campo'')) '),('float',
 'WebUI.delay(3) '),('float',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), ''@Valor'') '),('float',
 'WebUI.delay(3) '),('float',
 'WebUI.setText(findTestObject(''@Repositorio@Campo''), Keys.chord(Keys.ENTER) '),('float',
 'WebUI.delay(3) ')



*/