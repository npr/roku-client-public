'*****************************************************************
'**  Home screen: the entry display of the application
'**
'*****************************************************************

Function preShowHomeScreen(breadA=invalid, breadB=invalid) As Object

    if validateParam(breadA, "roString", "preShowHomeScreen", true) = false return -1
    if validateParam(breadA, "roString", "preShowHomeScreen", true) = false return -1

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    screen.SetListStyle("flat-category")
    screen.setListDisplayMode("zoom-to-fill")
    return screen

End Function


Function showHomeScreen(screen, servers) As Integer

    if validateParam(screen, "roPosterScreen", "showHomeScreen") = false return -1
	displayServerName = servers.count() > 1
	sectionList = CreateObject("roArray", 10, true)
	for each server in servers
    	sections = server.GetHomePageContent()
    	for each section in sections
    		if displayServerName then
    			section.Title = section.Title + " ("+server.name+")"
    			section.ShortDescriptionLine1 = section.ShortDescriptionLine1 + " ("+server.name+")"
    		endif
    		sectionList.Push(section)
    	end for
    	
	end for
    screen.SetContentList(sectionList)
    screen.Show()
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                print "list focused | index = "; msg.GetIndex(); " | category = "; m.curCategory
            else if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
                section = sectionList[msg.GetIndex()]
                print "section selected ";section.Title
                displaySection(section)
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while

    return 0

End Function

Function displaySection(section As Object) As Dynamic
    if validateParam(section, "roAssociativeArray", "displaySection") = false return -1
    
    if section.key = "globalsearch" then
    	queryString = getQueryString()
    	if len(queryString) > 0 then
    		showSearchGridScreen(section.server, queryString)
    	end if
    else
    	screen = preShowPosterScreen(section.Title, "")
    	showPosterScreen(screen, section)
    	'showGridScreen(section)
    endif
    return 0
End Function

Function getQueryString() As String
	queryString = ""
	
	searchHistory = CreateObject("roSearchHistory")
	port = CreateObject("roMessagePort") 
	searchScreen = CreateObject("roSearchScreen") 
	searchScreen.SetMessagePort(port)
	searchScreen.SetSearchTerms(searchHistory.GetAsArray())
	searchScreen.show()
	done = false
	while done = false
		msg = wait(0, searchScreen.getMessagePort())
		if type(msg) = "roSearchScreenEvent" then
			if msg.isFullResult() then
				queryString = msg.getMessage()
				if len(queryString) > 0 then
					searchHistory.Push(queryString)
				end if
				done = true
			else if msg.isScreenClosed() then
				done = true
			end if
		end if
	end while
	print "Query string:";queryString
	return queryString
End Function
