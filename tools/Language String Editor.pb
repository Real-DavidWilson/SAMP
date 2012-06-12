﻿Enumeration
	#XML
	#Window
	#List
	#InfoList
	#Splitter
	#Menu
	#PopupMenu
	#Menu_Reload
	#Menu_Save
	#Menu_Quit
	#Menu_Add
	#Menu_Edit
	#Menu_Delete
	#Menu_Goto
	#Menu_Search
	#Menu_SearchNext
	#Edit_Window
	#Edit_Text1
	#Edit_ID
	#Edit_OK
	#Edit_Cancel
	#Edit_FirstTextGadget
EndEnumeration

#Edit_FirstStringGadget = #Edit_FirstTextGadget + 100

#Title = "Language String Editor"

Structure Languages
	englishName.s
	localName.s
	tagName.s
EndStructure

Global editItemID
Global fileChanged
Global listColumn
Global xmlFile$

Global NewList Languages.Languages()

Procedure IsEqual(value1, value2)
	If value1 = value2
		ProcedureReturn #True
	EndIf
EndProcedure

Procedure.s TrimEx(string$)
	newString$ = Trim(string$, Chr(13))
	newString$ = Trim(newString$, Chr(10))
	newString$ = Trim(newString$)
	If newString$ <> string$
		newString$ = TrimEx(newString$)
	EndIf
	ProcedureReturn newString$
EndProcedure

Procedure UpdateWindowSize(window)
	Select window
		Case #Edit_Window
			ResizeGadget(#Edit_ID, #PB_Ignore, #PB_Ignore, WindowWidth(#Edit_Window) - 100, #PB_Ignore)
			ForEach Languages()
				ResizeGadget(#Edit_FirstStringGadget + ListIndex(Languages()), #PB_Ignore, #PB_Ignore, WindowWidth(#Edit_Window) - 100, #PB_Ignore)
			Next
			ResizeGadget(#Edit_OK, WindowWidth(#Edit_Window) - 220, #PB_Ignore, #PB_Ignore, #PB_Ignore)
			ResizeGadget(#Edit_Cancel, WindowWidth(#Edit_Window) - 110, #PB_Ignore, #PB_Ignore, #PB_Ignore)
		Case #Window
			ResizeGadget(#Splitter, #PB_Ignore, #PB_Ignore, WindowWidth(#Window), WindowHeight(#Window) - MenuHeight())
	EndSelect
EndProcedure

Procedure SetFileChangedState(state)
	fileChanged = state
	If fileChanged
		SetWindowTitle(#Window, #Title + " [Changed]")
	Else
		SetWindowTitle(#Window, #Title)
	EndIf
EndProcedure

Procedure IsDuplicateStringID(stringID, ignoreItemID)
	For item = 0 To CountGadgetItems(#List) - 1
		If item <> ignoreItemID And Val(GetGadgetItemText(#List, item, 0)) = stringID
			ProcedureReturn #True
		EndIf
	Next
EndProcedure

Procedure EditItem(item)
	editItemID = item
	items = CountGadgetItems(#List)
	If item = -1
		title$ = "Add language string"
		stringID = -1
		Repeat
			stringID + 1
			useID = #True
			For currentItem = 0 To items - 1
				If Val(GetGadgetItemText(#List, currentItem, 0)) = stringID
					useID = #False
				EndIf
			Next
		Until useID
	Else
		title$ = "Edit language string"
		stringID = Val(GetGadgetItemText(#List, item, 0))
	EndIf
	If OpenWindow(#Edit_Window, 100, 100, 500, 200, title$, #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_WindowCentered, WindowID(#Window))
		TextGadget(#Edit_Text1, 10, 10, 70, 20, "ID:")
		posY = 40
		ForEach Languages()
			TextGadget(#Edit_FirstTextGadget + ListIndex(Languages()), 10, posY, 70, 20, Languages()\englishName + " string:")
			posY + 30
		Next
		StringGadget(#Edit_ID, 90, 10, 0, 20, Str(stringID), #PB_String_Numeric)
		ForEach Languages()
			If item = -1
				string$ = ""
			Else
				string$ = GetGadgetItemText(#List, item, ListIndex(Languages()) + 1)
			EndIf
			StringGadget(#Edit_FirstStringGadget + ListIndex(Languages()), 90, GadgetY(#Edit_FirstTextGadget + ListIndex(Languages())), 0, 20, string$)
		Next
		ButtonGadget(#Edit_OK, 0, posY, 100, 30, "OK")
		ButtonGadget(#Edit_Cancel, 0, posY, 100, 30, "Cancel")
		DisableWindow(#Window, #True)
		ResizeWindow(#Edit_Window, #PB_Ignore, #PB_Ignore, #PB_Ignore, posY + 40)
		WindowBounds(#Edit_Window, 230, WindowHeight(#Edit_Window), #PB_Ignore, WindowHeight(#Edit_Window))
		UpdateWindowSize(#Edit_Window)
		AddKeyboardShortcut(#Edit_Window, #PB_Shortcut_Return, #Edit_OK)
		AddKeyboardShortcut(#Edit_Window, #PB_Shortcut_Escape, #Edit_Cancel)
	EndIf
EndProcedure

Procedure CloseEditWindow()
	DisableWindow(#Window, #False)
	CloseWindow(#Edit_Window)
EndProcedure

Procedure EditOK()
	stringID = Val(GetGadgetText(#Edit_ID))
	If stringID < 0
		MessageRequester("Invalid string ID", Str(stringID) + " is not a valid string ID!" + Chr(13) + Chr(13) + "Only use non-negative numbers!", #MB_ICONERROR)
	Else
		If IsDuplicateStringID(stringID, editItemID)
			MessageRequester("Duplicate string ID", "The string ID " + Str(stringID) + " already exists in the list!", #MB_ICONERROR)
		Else
			If editItemID = -1
				line$ = Str(stringID)
				ForEach Languages()
					line$ + Chr(10) + GetGadgetText(#Edit_FirstStringGadget + ListIndex(Languages()))
				Next
				AddGadgetItem(#List, -1, line$)
			Else
				SetGadgetItemText(#List, editItemID, Str(stringID), 0)
				ForEach Languages()
					SetGadgetItemText(#List, editItemID, GetGadgetText(#Edit_FirstStringGadget + ListIndex(Languages())), ListIndex(Languages()) + 1)
				Next
			EndIf
			CloseEditWindow()
			SetFileChangedState(#True)
		EndIf
	EndIf
EndProcedure

Procedure.s EscapeXMLCharacters(string$)
	string$ = ReplaceString(string$, "<", "&lt;")
	string$ = ReplaceString(string$, ">", "&gt;")
	ProcedureReturn string$
EndProcedure

Procedure FindListItem(gadget, item, column, searchString$) 
	ProcedureReturn FindString(LCase(GetGadgetItemText(gadget, item, column)), LCase(searchString$))
EndProcedure

Procedure LoadLanguageStrings()
	If LoadXML(#XML, xmlFile$)
		If XMLStatus(#XML) = #PB_XML_Success
			*mainNode = MainXMLNode(#XML)
			If *mainNode
				ClearGadgetItems(#List)
				*languagesNode = XMLNodeFromPath(*mainNode, "languages")
				If *languagesNode
					*languageNode = ChildXMLNode(*languagesNode)
					For column = listColumn To 1 Step -1
						RemoveGadgetColumn(#List, column)
					Next
					listColumn = 0
					ClearList(Languages())
					While *languageNode
						listColumn + 1
						AddElement(Languages())
						Languages()\tagName = GetXMLNodeName(*languageNode)
						Languages()\englishName = GetXMLAttribute(*languageNode, "name")
						Languages()\localName = GetXMLNodeText(*languageNode)
						AddGadgetColumn(#List, listColumn, GetXMLAttribute(*languageNode, "name"), 300)
						*languageNode = NextXMLNode(*languageNode)
					Wend
					*stringNode = XMLNodeFromPath(*mainNode, "string")
					While *stringNode
						stringID = Val(GetXMLAttribute(*stringNode, "id"))
						If IsDuplicateStringID(stringID, -1)
							AddGadgetItem(#InfoList, -1, "Duplicate string ID " + Str(stringID))
						Else
							line$ = Str(stringID)
							ForEach Languages()
								string$ = ""
								*languageNode = XMLNodeFromPath(*stringNode, Languages()\tagName)
								If *languageNode
									string$ = TrimEx(GetXMLNodeText(*languageNode))
								EndIf
								If Not string$
									AddGadgetItem(#InfoList, -1, "Missing " + Languages()\englishName + " language string for string ID " + Str(stringID))
								EndIf
								line$ + Chr(10) + string$
							Next
							AddGadgetItem(#List, -1, line$)
						EndIf
						*stringNode = NextXMLNode(*stringNode)
					Wend
					SetFileChangedState(#False)
					result = #True
				Else
					MessageRequester("No languages node", "No language definition found in XML file!", #MB_ICONERROR)
				EndIf
			Else
				MessageRequester("No main node", "No main node found in XML file!", #MB_ICONERROR)
			EndIf
		Else
			message$ = "Error in XML file!" + Chr(13)
			message$ + Chr(13)
			message$ + "Code: " + Str(XMLStatus(#XML)) + Chr(13)
			message$ + "Line: " + Str(XMLErrorLine(#XML)) + Chr(13)
			message$ + "Character: " + Str(XMLErrorPosition(#XML)) + Chr(13)
			message$ + Chr(13)
			message$ + XMLError(#XML)
			MessageRequester("XML error", message$, #MB_ICONERROR)
		EndIf
		FreeXML(#XML)
	Else
		MessageRequester("Error", "Can not load XML file!", #MB_ICONERROR)
	EndIf
	ProcedureReturn result
EndProcedure

Procedure SaveLanguageStrings()
	Structure TempList
		id.l
		List stringList.s()
	EndStructure
	NewList TempList.TempList()
	For item = 0 To CountGadgetItems(#List) - 1
		AddElement(TempList())
		TempList()\id = Val(GetGadgetItemText(#List, item, 0))
		ForEach Languages()
			AddElement(TempList()\stringList())
			TempList()\stringList() = GetGadgetItemText(#List, item, ListIndex(Languages()) + 1)
		Next
	Next
	SortStructuredList(TempList(), #PB_Sort_Ascending, OffsetOf(TempList\id), #PB_Sort_Long)
	file = CreateFile(#PB_Any, xmlFile$)
	If IsFile(file)
		WriteStringN(file, "<?xml version=" + Chr(34) + "1.0" + Chr(34) + " encoding=" + Chr(34) + "ISO-8859-1" + Chr(34) + "?>")
		WriteStringN(file, "<languagestrings>")
		WriteStringN(file, Chr(9) + "<languages>")
		ForEach Languages()
			WriteStringN(file, Chr(9) + Chr(9) +"<" + Languages()\tagName + " name=" + Chr(34) + Languages()\englishName + Chr(34) + ">" + Languages()\localName + "</" + Languages()\tagName + ">")
		Next
		WriteStringN(file, Chr(9) + "</languages>")
		ForEach TempList()
			WriteStringN(file, Chr(9) + "<string id=" + Chr(34) + Str(TempList()\id) + Chr(34) + ">")
			language = 0
			ForEach TempList()\stringList()
				SelectElement(Languages(), language)
				WriteStringN(file, Chr(9) + Chr(9) +"<" + Languages()\tagName + ">" + EscapeXMLCharacters(TempList()\stringList()) + "</" + Languages()\tagName + ">")
				language + 1
			Next
			WriteStringN(file, Chr(9) + "</string>")
		Next
		WriteString(file, "</languagestrings>")
		CloseFile(file)
		SetFileChangedState(#False)
		ProcedureReturn #True
	EndIf
EndProcedure

Procedure CheckQuit()
	If fileChanged
		Select MessageRequester("Unsaved changes", "There are unsaved changes!" + Chr(13) + Chr(13) + "Do you want to save before quit?", #MB_YESNOCANCEL | #MB_ICONQUESTION)
			Case #PB_MessageRequester_Yes
				If SaveLanguageStrings()
					End
				Else
					MessageRequester("Save language strings", "Can not write to file '" + xmlFile$ + "'!" + Chr(13) + Chr(13) + "Click OK to go back without exiting the application.", #MB_ICONERROR)
				EndIf
			Case #PB_MessageRequester_No
				End
		EndSelect
	Else
		End
	EndIf
EndProcedure

Procedure SearchStringInList(string$)
	startingItem = GetGadgetState(#List) + 1
	If startingItem >= CountGadgetItems(#List)
		startingItem = 0
	EndIf
	foundItem = -1
	For item = startingItem To CountGadgetItems(#List) - 1
		For column = 1 To listColumn
			If FindListItem(#List, item, column, string$)
				foundItem = item
				Break
			EndIf
		Next
		If foundItem <> -1
			Break
		EndIf
	Next
	If foundItem = -1 And startingItem > 0
		For item = 0 To startingItem -1
			For column = 1 To listColumn
				If FindListItem(#List, item, column, string$)
					foundItem = item
					Break
				EndIf
			Next
			If foundItem <> -1
				Break
			EndIf
		Next
	EndIf
	If foundItem = -1
		MessageRequester("Search string", "The entered string '" + string$ + "' was not found!", #MB_ICONERROR)
	Else
		SetGadgetState(#List, foundItem)
	EndIf
EndProcedure

xmlFile$ = ProgramParameter()
If Not xmlFile$
	mainPath$ = GetPathPart(ProgramFilename())
	serverRoot$ = GetPathPart(Left(mainPath$, Len(mainPath$) - 1))
	xmlFile$ = serverRoot$ + "scriptfiles\languagestrings.xml"
EndIf

If OpenWindow(#Window, 100, 100, 800, 500, #Title, #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
	If CreateMenu(#Menu, WindowID(#Window))
		MenuTitle("File")
		MenuItem(#Menu_Reload, "Reload")
		MenuItem(#Menu_Save, "Save" + Chr(9) + "Ctrl+S")
		MenuBar()
		MenuItem(#Menu_Quit, "Quit" + Chr(9) + "Alt+F4")
		MenuTitle("Edit")
		MenuItem(#Menu_Add, "Add" + Chr(9) + "Ins")
		MenuItem(#Menu_Edit, "Edit")
		MenuBar()
		MenuItem(#Menu_Delete, "Delete" + Chr(9) + "Del")
		MenuBar()
		MenuItem(#Menu_Goto, "Goto ID" + Chr(9) + "Ctrl+G")
		MenuItem(#Menu_Search, "Search" + Chr(9) + "Ctrl+F")
		MenuItem(#Menu_SearchNext, "Search next" + Chr(9) + "F3")
		DisableMenuItem(#Menu, #Menu_Edit, #True)
		DisableMenuItem(#Menu, #Menu_Delete, #True)
	EndIf
	ListIconGadget(#List, 0, 0, 0, 0, "ID", 50, #PB_ListIcon_FullRowSelect)
	ListViewGadget(#InfoList, 0, 0, 0, 0)
	SplitterGadget(#Splitter, 0, 0, 0, 0, #List, #InfoList, #PB_Splitter_Separator)
	UpdateWindowSize(#Window)
	AddKeyboardShortcut(#Window, #PB_Shortcut_Control | #PB_Shortcut_S, #Menu_Save)
	AddKeyboardShortcut(#Window, #PB_Shortcut_Insert, #Menu_Add)
	AddKeyboardShortcut(#Window, #PB_Shortcut_Delete, #Menu_Delete)
	AddKeyboardShortcut(#Window, #PB_Shortcut_Control | #PB_Shortcut_G, #Menu_Goto)
	AddKeyboardShortcut(#Window, #PB_Shortcut_Control | #PB_Shortcut_F, #Menu_Search)
	AddKeyboardShortcut(#Window, #PB_Shortcut_F3, #Menu_SearchNext)
	If Not LoadLanguageStrings()
		End
	EndIf
	Repeat
		Select WaitWindowEvent()
			Case #PB_Event_Gadget
				Select EventGadget()
					Case #List
						item = GetGadgetState(#List)
						DisableMenuItem(#Menu, #Menu_Edit, IsEqual(item, -1))
						DisableMenuItem(#Menu, #Menu_Delete, IsEqual(item, -1))
						Select EventType()
							Case #PB_EventType_LeftDoubleClick
								EditItem(item)
							Case #PB_EventType_RightClick
								If CreatePopupMenu(#PopupMenu)
									MenuItem(#Menu_Add, "Add" + Chr(9) + "Ins")
									If item <> -1
										MenuItem(#Menu_Edit, "Edit")
										MenuBar()
										MenuItem(#Menu_Delete, "Delete" + Chr(9) + "Del")
									EndIf
									DisplayPopupMenu(#PopupMenu, WindowID(#Window))
								EndIf
						EndSelect
					Case #Edit_OK
						EditOK()
					Case #Edit_Cancel
						CloseEditWindow()
				EndSelect
			Case #PB_Event_Menu
				item = GetGadgetState(#List)
				Select EventMenu()
					Case #Menu_Reload
						If fileChanged
							If MessageRequester("Reload file", "Are you sure to reload all language strings from the XML file?" + Chr(13) + Chr(13) + "You will lose all unsaved changes!", #MB_YESNO | #MB_ICONQUESTION) = #PB_MessageRequester_Yes
								LoadLanguageStrings()
							EndIf
						Else
							LoadLanguageStrings()
						EndIf
					Case #Menu_Save
						If SaveLanguageStrings()
							MessageRequester("Save language strings", "Language strings saved", #MB_ICONINFORMATION)
						Else
							MessageRequester("Save language strings", "Can not write to file '" + xmlFile$ + "'!", #MB_ICONERROR)
						EndIf
					Case #Menu_Quit
						CheckQuit()
					Case #Menu_Add
						EditItem(-1)
					Case #Menu_Edit
						If item <> -1
							EditItem(item)
						EndIf
					Case #Menu_Delete
						If item <> -1
							If MessageRequester("Delete language string", "Delete the selected language string?" + Chr(13) + Chr(13) + "ID: " + GetGadgetItemText(#List, item, 0), #MB_YESNO | #MB_ICONQUESTION) = #PB_MessageRequester_Yes
								RemoveGadgetItem(#List, item)
								SetFileChangedState(#True)
							EndIf
						EndIf
					Case #Menu_Goto
						string$ = Trim(InputRequester("Goto string ID", "Enter the string ID you want to go to.", ""))
						If string$
							stringID = Val(string$)
							If Str(stringID) = string$
								startingItem = GetGadgetState(#List) + 1
								If startingItem >= CountGadgetItems(#List)
									startingItem = 0
								EndIf
								foundItem = -1
								For item = startingItem To CountGadgetItems(#List) - 1
									If FindListItem(#List, item, 0, string$)
										foundItem = item
										Break
									EndIf
								Next
								If foundItem = -1 And startingItem > 0
									For item = 0 To startingItem -1
										If FindListItem(#List, item, 0, string$)
											foundItem = item
											Break
										EndIf
									Next
								EndIf
								If foundItem = -1
									MessageRequester("Goto string ID", "The entered string ID '" + string$ + "' was not found!", #MB_ICONERROR)
								Else
									SetGadgetState(#List, foundItem)
								EndIf
							Else
								MessageRequester("Not a number", "The entered text is not a number!", #MB_ICONERROR)
							EndIf
						EndIf
					Case #Menu_Search
						string$ = Trim(InputRequester("Search string", "Enter the string you want to search for.", searchedString$))
						If string$
							searchedString$ = string$
							SearchStringInList(string$)
						EndIf
					Case #Menu_SearchNext
						If searchedString$
							SearchStringInList(searchedString$)
						Else
							string$ = Trim(InputRequester("Search string", "Enter the string you want to search for.", searchedString$))
							If string$
								searchedString$ = string$
								SearchStringInList(string$)
							EndIf
						EndIf
					Case #Edit_OK
						EditOK()
					Case #Edit_Cancel
						CloseEditWindow()
				EndSelect
			Case #PB_Event_SizeWindow
				UpdateWindowSize(EventWindow())
			Case #PB_Event_CloseWindow
				Select EventWindow()
					Case #Window
						CheckQuit()
					Case #Edit_Window
						CloseEditWindow()
				EndSelect
		EndSelect
	ForEver
EndIf
; IDE Options = PureBasic 4.60 (Windows - x86)
; CursorPosition = 239
; FirstLine = 227
; Folding = ---
; EnableXP
; UseIcon = Language String Editor.ico
; Executable = Language String Editor.exe
; CommandLine = X:\Projects\SAMP-Server\scriptfiles\languagestrings.xml
; EnableCompileCount = 122
; EnableBuildCount = 9
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1,0,0,0
; VersionField1 = 1,0,0,0
; VersionField2 = SelfCoders
; VersionField3 = Language String Editor
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField6 = Language String Editor
; VersionField7 = Language String Editor
; VersionField8 = %EXECUTABLE
; VersionField13 = languagestringeditor@selfcoders.com
; VersionField14 = http://www.selfcoders.com
; VersionField15 = VOS_NT_WINDOWS32
; VersionField16 = VFT_APP
; VersionField17 = 0409 English (United States)
; VersionField18 = Build
; VersionField19 = Compile OS
; VersionField20 = Date
; VersionField21 = %BUILDCOUNT
; VersionField22 = %OS
; VersionField23 = %y-%m-%d %h:%i:%s