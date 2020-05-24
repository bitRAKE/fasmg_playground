--[[ An example file

proc clip(int a)
« Clip into the positive zone »
if (a > 0) a
0
end 
]]

-- Define style numbers
S_DEFAULT = 0
S_IDENTIFIER = 1
S_KEYWORD = 2
S_UNICODECOMMENT = 3

-- Anytime a file is switched, check to see if it needs styled
npp.AddEventHandler("OnSwitchFile", function(filename, bufferid)
    if npp:GetExtPart() == ".fasmg" then
        -- Add the event handler for our custom style function
        npp.AddEventHandler("OnStyle", fasmgStyle)
        
        -- Make sure to set the lexer as a custom container
        editor.Lexer = SCLEX_CONTAINER
        
        -- Set up the styles as appropriate
        editor.StyleFore[S_DEFAULT] = 0x7f007f
        editor.StyleBold[S_DEFAULT] = true
        editor.StyleFore[S_IDENTIFIER] = 0x000000
        editor.StyleFore[S_KEYWORD] = 0x800000
        editor.StyleBold[S_KEYWORD] = true
        editor.StyleFore[S_UNICODECOMMENT] = 0x008000
        editor.StyleFont[S_UNICODECOMMENT] = "Georgia"
        editor.StyleItalic[S_UNICODECOMMENT] = true
        editor.StyleSize[S_UNICODECOMMENT] = 9 
        
        -- Clear any style and re-lex the entire document
        editor:ClearDocumentStyle()
        editor:Colourise(0, -1)
    else
        -- Can remove the handler if it's not needed
        npp.RemoveEventHandler("OnStyle", fasmgStyle)
    end

    return false
end)

-- Style the document. Handles UTF-8 characters
function fasmgStyle(styler)
	numericalCharacters = [[$0123456789]]
	syntacticalCharacters = [[+-/*=<>()[]{}:?!,.|&~#`\;]]
	identifierCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

	styler:StartStyling(styler.startPos, styler.lengthDoc, styler.initStyle)
	while styler:More() do
		-- Exit state if needed
		if styler:State() == S_SYNTACTICAL then
			if not syntacticalCharacters:find(styler:Current(), 1, true) then
				styler:SetState(S_DEFAULT)
			end
		elseif styler:State() == S_UNICODESTRING then
			styler:Token()
			if styler:Match("'") then
				styler:ForwardSetState(S_SYNTACTICAL)
			elseif styler:Match('"') then
				styler:ForwardSetState(S_SYNTACTICAL)
			end
		elseif styler:State() == S_UNICODECOMMENT then
			if styler:AtLineEnd() then
				styler:ForwardSetState(S_DEFAULT)				
			end
		end

		-- Enter state if needed

		if styler:State() == S_DEFAULT then
			if syntacticalCharacters:find(styler:Current(), 1, true) then
				styler:SetState(S_SYNTACTICAL)
				if styler:Match("'") then
					styler:ForwardSetState(S_UNICODESTRING)
				elseif styler:Match('"') then
					styler:ForwardSetState(S_UNICODESTRING)
				elseif styler:Match(";") then
					styler:ForwardSetState(S_UNICODECOMMENT)
				end
			elseif numberCharacters:find(styler:Current(), 1, true) then
				styler:SetState(S_NUMERICAL)
				if styler:Match("0x") then
			
			end
		end

		styler:Forward()
	end
	styler:EndStyling()
end