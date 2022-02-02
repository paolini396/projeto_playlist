#Include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#Include 'Set.CH'
#Include 'FWMVCDEF.ch'
#include "parmtype.ch"
#include "dbstruct.ch"

/*/{Protheus.doc} User Function MusicList
  @author Paolini
  @since 27/12/2021
  @version 1.0
  @description Tela para Buscar músicas na API VAGALUME
  @type  Function
/*/
User Function MusicList()

	Local aArea := GetArea()
	Local oLayer as object
	Local aSize as array

	Private cTitulo  := "Lista de Músicas"
	Private oDlgTela as object
	Private oBrowse as object
	Private oCbxFiltro as object
	Private cSearch := Space(200)
	Private cAliasQry := GetNextAlias()
	Private cAliasTmp := GetNextAlias()
	Private cTableName := ""
	Private aBrwData  as array
	Private aRotina		:= MenuDef()

	aSize	:= FWGetDialogSize( oMainWnd )
	oDlgtela := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitulo,,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )
	oLayer := FWLayer():New()
	oLayer:Init(oDlgTela,.F.,.T.)

	//-- DIVISOR DE TELA SUPEIROR [ FILTRO ]

	oLayer:AddLine("LINESUP", 25 )
	oLayer:AddCollumn("BOX01", 100,, "LINESUP" )
	oLayer:AddWindow("BOX01", "PANEL01", "Filtros", 100, .F.,,, "LINESUP" ) //"Filtros"
	//-- DIVISOR DE TELA INFERIOR [ GRID ]
	oLayer:AddLine("LINEINF", 75 )
	oLayer:AddCollumn( "BOX02", 100,, "LINEINF" )
	oLayer:AddWindow( "BOX02", "PANEL02", cTitulo	, 100, .F.,,, "LINEINF" )

	FPanel01( oLayer:GetWinPanel( "BOX01", "PANEL01", "LINESUP" ) ) //Contrução do Painel de Filtros
	FPanel02( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINEINF" ) ) //Contrução do Painel de Musicas

	oDlgtela:Activate()
	RestArea(aArea)

Return

Static Function FPanel01( oPanel )

	Local bFiltrar	:=	Nil

	//-- Inclui a borda pora apresentacao dos componentes em tela
	TGroup():New( 005, 005, (oPanel:nHeight/2) - 005, (oPanel:nWidth/2) - 010 , "", oPanel,,, .T. ) //"Filtros"

	TSay():New( 010, 250, { || "Digite o nome da Música"    }, oPanel,,,,,, .T.,,, 110, 010 )
	TGet():New( 020, 250, { |u| If(PCount()>0,cSearch := u, cSearch)},oPanel,200,010,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSearch",,)

	//Inclui botao filtrar
	bFiltrar := { || HandleSearch("Buscando Música") }
	TButton():New( 020,460, "Buscar", oPanel, bFiltrar, 060, 013,,,, .T. ) //"Filtrar"

Return()


/* Static Function FPanel02( oPanel )

	Local aBrwModel as array
	Local aBrwCol as array
	Local aBrwSeek as array

	Local nIndex as numeric

	Local bAddPlayList	:=	Nil

	aBrwModel := {}
	aBrwCol := {}
	aBrwData := {}
	aBrwSeek := {}

	aAdd(aBrwData, {"TESTE 01", "Paolini"} )
	aAdd(aBrwData, {"TESTE 02", "Paolini"} )

	aAdd(aBrwModel, {'Nome'        , '@!'    , 25, 10, 1})
	aAdd(aBrwModel, {'Banda'  , '@!'    , 25, 00, 1})
	
	bAddPlayList := { || HandleSearch("Buscando Play List") }
	TButton():New( 001, 185, "Adicionar a Play List",oPanel,bAddPlayList, 060, 013,,,, .T. )


	for nIndex := 1 to Len(aBrwModel)

		aAdd(aBrwCol, FwBrwColumn():New())

		aBrwCol[Len(aBrwCol)]:SetData( &('{ || aBrwData[oBrowse:nAt,' + cValToChar(nIndex) + ']}') )
		aBrwCol[Len(aBrwCol)]:SetTitle(aBrwModel[nIndex,1])
		aBrwCol[Len(aBrwCol)]:SetPicture(aBrwModel[nIndex,2])
		aBrwCol[Len(aBrwCol)]:SetSize(aBrwModel[nIndex,3])
		aBrwCol[Len(aBrwCol)]:SetDecimal(aBrwModel[nIndex,4])
		aBrwCol[Len(aBrwCol)]:SetAlign(aBrwModel[nIndex,5])

	Next nIndex

	oBrowse := FWBrowse():New()

	//oBrowse:DisableReport()

	oBrowse:SetDataArray()
	oBrowse:SetArray(aBrwData)
	oBrowse:SetColumns(aBrwCol)

	oBrowse:SetOwner(oPanel)


	oBrowse:Activate()

Return() */

Static Function FPanel02( oPanel )

	Local aArea       := GetArea()
  Local cFunBkp     := FunName()
  Local aFields     := {}
  Local aBrowse     := {}
  Local aIndex      := {}
	Local aValores    := {}
	local oFWTTable     as object

	Local cSQLInsert := ""

	Local nField      := 0
	Local nValue     := 0

	aAdd(aFields, { "TMP_BANDA", "C", 50, 0 })
	aAdd(aFields, { "TMP_NOME",  "C", 50, 0 })

	oFWTTable := FWTemporaryTable():new(cAliasTmp, aFields)

	oFWTTable:AddIndex("01", {"TMP_BANDA"})
	oFWTTable:AddIndex("02", {"TMP_NOME"})
	oFWTTable:AddIndex("93", {"TMP_BANDA", "TMP_NOME"})

	oFWTTable:Create()

	cTableName := oFWTTable:getRealName()

	//Definindo as colunas que serão usadas no browse
  aAdd(aBrowse, {"Banda",    "TMP_BANDA", "C", 06, 0, "@!"})
  aAdd(aBrowse, {"Nome", "TMP_NOME", "C", 50, 0, "@!"})

	aAdd(aValores, {"Paolini", "Musica Paolini"})
	aAdd(aValores, {"Teste banda", "Musica testando"})

  //-------------------------------
    //Inserção de dados via INSERT
  //-------------------------------
 cSQLInsert := "INSERT INTO "
 cSQLInsert += cTableName
 cSQLInsert += " ("
	for nField := 1 to Len(aFields)
		cSQLInsert += aFields[nField][1]
cSQLInsert += IIf(nField == len(aFields), "", ",")
	next nField
	cSQLInsert += ") "
	cSQLInsert += "VALUES "
	for nValue := 1 to Len(aValores)
		cSQLInsert += " ("
		cSQLInsert += "'"
		cSQLInsert += aValores[nValue][1]
		cSQLInsert += "'"
		cSQLInsert += ","
		cSQLInsert += "'"
		cSQLInsert += aValores[nValue][2]
		cSQLInsert += "'"
		cSQLInsert += ")"
		cSQLInsert += IIf(nValue == len(aValores), ";", ",")
	next nValue

	begin transaction
		if(TCSQLExec(cSQLInsert) < 0)
				DisarmTransaction()
				UserException(TCSQlError())
		endIf

	end transaction

	//Criando o browse da temporária
  oBrowse := FWMBrowse():New()
  oBrowse:SetAlias(cAliasTmp)
  oBrowse:SetQueryIndex(aIndex)
  oBrowse:SetTemporary(.T.)
  oBrowse:SetFields(aBrowse)
  oBrowse:DisableDetails()
  oBrowse:SetDescription(cTitulo)
	oBrowse:SetOwner(oPanel)
  oBrowse:Activate()
  SetFunName(cFunBkp)
  RestArea(aArea)

Return()

Static Function MenuDef()
	Local aRotina 	:= {}
		
	AADD(aRotina, {"Adicionar a Play List"			, { || HandleAddPlayList("Buscando Play List") }		, 0, 3, 0, Nil })
	
Return( aRotina )

Static Function HandleSearch(cMensagem)

	Default cMensagem	:=  ""

	If !Empty(cMensagem)
		FWMsgRun( ,{|| UpdateBrw() },"Aguarde",cMensagem)
	Else
		CursorWait()
		UpdateBrw()
		CursorArrow()
	EndIf

Return

Static Function HandleAddPlayList(cMensagem)

	Default cMensagem	:=  ""

	If !Empty(cMensagem)
		FWMsgRun( ,{|| },"Aguarde",cMensagem)
	Else
		CursorWait()
		//UpdateBrw()
		CursorArrow()
	EndIf

Return

Static Function UpdateBrw()
	Local oMusicService as Object
	Local oMusicList as Object
	Local nIndex as numeric

	oMusicService := MusicService():new()
	oMusicList := oMusicService:FilterList(cSearch)

	If (!Empty(oMusicList["error"]) .and. !Empty(oMusicList["message"]))

		MsgAlert(oMusicList["message"],oMusicList["error"])

		Return
	EndIf

	aBrwData := {}
	for nIndex := 1 to Len(oMusicList["data"])

		aAdd(aBrwData, {oMusicList["data"][nIndex]["CTITULO"], oMusicList["data"][nIndex]["CBANDA"]})

	Next nIndex
	
	oBrowse:DeActivate(.T.)
	oBrowse:SetDataArray()
	oBrowse:SetArray(aBrwData)
	oBrowse:Activate()
	oBrowse:UpdateBrowse(.T.)
Return
