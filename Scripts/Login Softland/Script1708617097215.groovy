import static com.kms.katalon.core.checkpoint.CheckpointFactory.findCheckpoint
import static com.kms.katalon.core.testcase.TestCaseFactory.findTestCase
import static com.kms.katalon.core.testdata.TestDataFactory.findTestData
import static com.kms.katalon.core.testobject.ObjectRepository.findTestObject
import static com.kms.katalon.core.testobject.ObjectRepository.findWindowsObject
import com.kms.katalon.core.checkpoint.Checkpoint as Checkpoint
import com.kms.katalon.core.cucumber.keyword.CucumberBuiltinKeywords as CucumberKW
import com.kms.katalon.core.mobile.keyword.MobileBuiltInKeywords as Mobile
import com.kms.katalon.core.model.FailureHandling as FailureHandling
import com.kms.katalon.core.testcase.TestCase as TestCase
import com.kms.katalon.core.testdata.TestData as TestData
import com.kms.katalon.core.testng.keyword.TestNGBuiltinKeywords as TestNGKW
import com.kms.katalon.core.testobject.TestObject as TestObject
import com.kms.katalon.core.webservice.keyword.WSBuiltInKeywords as WS
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI
import com.kms.katalon.core.windows.keyword.WindowsBuiltinKeywords as Windows
import internal.GlobalVariable as GlobalVariable
import org.openqa.selenium.Keys as Keys

//INICIO ABRE LA PÁGINA Y SE LOGIN
WebUI.openBrowser('')

WebUI.maximizeWindow()

WebUI.navigateToUrl('http://192.168.7.143:18700/')

WebUI.setText(findTestObject('Object Repository/Page_Softland Inicio de Sesin/input_Usuario_username'), 'ADMIN')

WebUI.setEncryptedText(findTestObject('Object Repository/Page_Softland Inicio de Sesin/input_Contrasea_pwd'), 'XmnPW7mE0VA=')

WebUI.click(findTestObject('Object Repository/Page_Softland Inicio de Sesin/button_Iniciar Sesin'))

//INICIO SELECCIÓN DE EMPRESA
WebUI.waitForPageLoad(5)

//Objeto manual, funciona bien :D
WebUI.click(findTestObject('Object Repository/Buttons_Login/CheckBox Empresa Final'))

WebUI.click(findTestObject('Object Repository/Buttons_login/Boton_Aceptar'))

WebUI.waitForPageLoad(5)

//FIN SELECCIÓN DE EMPRESA

////INICIO BUSCAR OBJETO 

//Para que funcionara la LUPA, tuvimos que revisar la lupa ya que tenia dos estados, una habilitada y otra deshabilitada, la que estabamos buscando es la-
	//que esta activa cuando pones el puntero sobre el icono, se ve a travez de la consola.

WebUI.click(findTestObject('Object Repository/Busca_Ingresa/botonLupa'))

//se completo a mano el FCRMVH, pero deberia venir de forma automática de la prueba
WebUI.setText(findTestObject('Object Repository/Busca_Ingresa/barraBusqueda'), 'FCRMVH')

WebUI.click(findTestObject('Object Repository/Busca_Ingresa/botonBuscar'))

WebUI.doubleClick(findTestObject('Object Repository/Busca_Ingresa/primerElemento'))

//FIN BUSCAR OBJETO

//INICIO COMPLETAR CAMPOS PASO I - FCRMVH

//Se posiciona sobre la ventana que se abrio de registración de facturación
WebUI.delay(8)

WebUI.switchToWindowTitle('Registración de facturación')

///Selecciona el campo, completa el campo y luego presiona ENTER (esto deberia llevar al campo VIRT_CIRAPL)
WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CIRCOM'))
WebUI.setText(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CIRCOM'), '0400')
WebUI.sendKeys(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CIRCOM'),Keys.chord(Keys.ENTER))
WebUI.delay(3)

//Forma de combinar el senKeys y el setText, no estoy seguro que reemplace el click
WebUI.sendKeys(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CIRAPL'), '0200' + Keys.chord(Keys.ENTER))

WebUI.delay(3)

//pruebas otros campos
//campos sensibles cuando no hay el registro que buscan  o se sobreescribe el mismo dato que viene por defecto
//WebUI.sendKeys(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CODCVT'), 'FC' + Keys.chord(Keys.ENTER))
WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CODCVT')) + Keys.chord(Keys.ENTER)
WebUI.delay(6)

//Se tuvo que agregar un espacio al final del nombre del reporte para que escriba el nombre completo
WebUI.clearText(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_REPGRP'))
WebUI.sendKeys(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_REPGRP'), 'FC_TPEN_GRP ' + Keys.chord(Keys.ENTER))
WebUI.delay(6)


WebUI.clearText(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_REPDET'))
WebUI.sendKeys(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_REPDET'), 'FC_TPEN_DET ' + Keys.chord(Keys.ENTER))
WebUI.delay(3)
WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_CRGMAN'))

//El campo "No actualiza encabezado" no se activa cuando se esta corriendo el script, se deshabilito temporalmente hasta encontrar una solución
//WebUI.delay(3)
//WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_NOACTH'))

//El campo Sucursal no recupera las sucursales a medida que se tipea el código correcto, la página deja de responder si se ingresa directamente el código y se da Enter
//Si se ingresa la sucursal mediante la lupa parece funcionar correctamente.
//WebUI.sendKeys(findTestObject('Object Repository/FCRMVH/PASO1/VIRT_SUCURS'), '0007' + Keys.chord(Keys.ENTER))
//Existe un pequeño bug que solo ocurre con KATALON y es que cuando se da enter en el paso anterior, se despliega la lista de forma vacia, aparentemente no afecta al script
WebUI.delay(3)
WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/lupaSucursal'))
WebUI.doubleClick(findTestObject('Object Repository/FCRMVH/PASO1/filaSucursal'))

WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/botonSiguiente'))

//supuestamente debe esperar 3 segundos, no pareciera hacerlo...
WebUI.delay(3, WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/botonAnterior')))

WebUI.delay(3, WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/botonSiguiente')))


//WebUI.click(findTestObject('Object Repository/FCRMVH/PASO1/botonCancelar'))

