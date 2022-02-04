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
	Private cAliasTmp := GetNextAlias()
	Private cTableName := ""
	Private aBrwData  as array
	Private aRotina		:= MenuDef()
	Private oFWTTable     as object


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

Static Function FPanel02( oPanel )

	Local aArea       := GetArea()
	Local aIndex      := {}
	Local aValues      := {}

	TmpTable(aValues)

	//Criando o browse da temporária
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasTmp)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(GetColumns())
	oBrowse:DisableDetails()
	oBrowse:SetDescription("Selecione uma Música")
	oBrowse:SetOwner(oPanel)
	oBrowse:Activate()
	RestArea(aArea)

Return()


Static Function ModalPList()

	Local oModal
	Local aColumns := {}

	aAdd(aColumns, {"Codigo",    "A1_COD", "C", 06, 0, "@!"})
  aAdd(aColumns, {"Nome",      "A1_NOME", "C", 50, 0, "@!"})

	oModal := FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Lista de Play List")
	oModal:setSubTitle("SubTitulo da Janela")

	//Seta a largura e altura da janela em pixel
	oModal:setSize(200, 500)

	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar") 

	oModal:Activate()

Return

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

	ModalPList()
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

		aAdd(aBrwData, {oMusicList["data"][nIndex]["CBANDA"], oMusicList["data"][nIndex]["CTITULO"]})

	Next nIndex 

	TmpTable(aBrwData)
	
 	oBrowse:SetAlias(cAliasTmp)
	oBrowse:UpdateBrowse(.T.)
	
Return


Static Function TmpTable(aValues)

	Local aFields     := {}
	Local nField      := 0
	Local nValue      := 0

	if (!Empty(cTableName) .and. ValType(oFWTTable) == 'O')
			oFWTTable:Delete()
	endIf

	aAdd(aFields, { "TMP_BANDA", "C", 50, 0 })
	aAdd(aFields, { "TMP_NOME",  "C", 50, 0 })

	oFWTTable := FWTemporaryTable():new(cAliasTmp, aFields)

	oFWTTable:AddIndex("01", {"TMP_BANDA"})
	oFWTTable:AddIndex("02", {"TMP_NOME"})
	oFWTTable:AddIndex("03", {"TMP_BANDA", "TMP_NOME"})

	oFWTTable:Create()

	cTableName := oFWTTable:getRealName()

  //-------------------------------
    //Inserção de dados via INSERT
  //-------------------------------


// Válida se existe valores para cadastrar na tabela temporária 
	if (!Len(aValues) > 0)
		Return
	endIf

 	cSQLInsert := "INSERT INTO "
 	cSQLInsert += cTableName
 	cSQLInsert += " ("

	for nField := 1 to Len(aFields)
		cSQLInsert += aFields[nField][1]
		cSQLInsert += IIf(nField == len(aFields), "", ",")
	next nField

	cSQLInsert += ") "
	cSQLInsert += "VALUES "

	for nValue := 1 to Len(aValues)
		cSQLInsert += " ("

		for nField := 1 to Len(aValues[nValue])
			cSQLInsert += "'"
			cSQLInsert += aValues[nValue][nField]
			cSQLInsert += "'"
			cSQLInsert += IIf(nField == Len(aValues[nValue]), "", ",")
		next nField
		
		cSQLInsert += ")"
		cSQLInsert += IIf(nValue == len(aValues), ";", ",")
	next nValue

	begin transaction
		if(TCSQLExec(cSQLInsert) < 0)
				DisarmTransaction()
				UserException(TCSQlError())
		endIf

	end transaction
	
Return


Static Function GetColumns()
  Local aColumns := {}

	aAdd(aColumns, {"Banda",    "TMP_BANDA", "C", 06, 0, "@!"})
  aAdd(aColumns, {"Nome", "TMP_NOME", "C", 50, 0, "@!"})

Return aColumns
