-- -*- coding: utf-8 -*-
--[[

11/15 some stuff with '
05/15 first release

"script_scite_lexer_log.lua"
A SciTE script lexer for the *.log
(specially for python log...)

flatgreen -- julotsoft.free.fr
    
Some good references that'll help when scripting SciTE with Lua:
    http://www.scintilla.org/ScintillaDoc.html
    http://www.scintilla.org/ScriptLexer.html
    http://lua-users.org/wiki/UsingLuaWithScite
    
some good inspirations for lua lexers:
    https://github.com/tobyink/misc-scite-config/blob/master/.SciTE/n3.lexer.lua
    https://github.com/nkmathew/scite-hla-lexer/blob/master/script_hla.lua

    
Installation on a Windows machine:

- put this file in a "lexer" directory
- in "SciTEUser.properties" :
[lexer log]
file.patterns.log=*.log
#~ extension.$(file.patterns.log)=$(SciteDefaultHome)/lexers/script_scite_lexer_log.lua DON'T WORK
extension.$(file.patterns.log)=C:\program_perso\wscite\lexers\script_scite_lexer_log.lua
#~ extension.$(file.patterns.log)=script_scite_lexer_log.lua WORK ONLY in the directory of the script

lexer.$(file.patterns.log)=script_scite_lexer_log
#defaut
#~ style.script_scite_lexer_log.0=fore:#657b83
#identifier
#~ style.script_scite_lexer_log.1=fore:#000000
# Single and double quoted string
style.script_scite_lexer_log.2=$(colour.char)
# Back Ticks `
style.script_scite_lexer_log.3=fore:#A08080
# num, hour : bleu entre clair et fonce
style.script_scite_lexer_log.4=fore:#0070DF

#VERBOSE: vert
style.script_scite_lexer_log.10=fore:#007F7F
#INFO: violet
style.script_scite_lexer_log.11=fore:#400080
#DEBUG: gris
style.script_scite_lexer_log.12=fore:#666666
#WARNING, ERROR: rouge
style.script_scite_lexer_log.13=fore:#FF0000
style.script_scite_lexer_log.14=fore:#FF0000
#CRITICAL: rouge fond jaune
style.script_log.15=fore:#FFFF00,back:#FF0000,eolfilled
#TRACE: vert pale
style.script_scite_lexer_log.16=fore:#00CCCC


TODO :
    - URI and URL

]]

function OnStyle(styler)
        S_DEFAULT = 0
        S_IDENTIFIER = 1
        S_LITERAL = 2
        S_BACKTICKS = 3
        S_HOUR = 4
                
        S_VERBOSE = 10
        S_INFO = 11
        S_DEBUG = 12
        S_WARNING = 13
        S_ERROR = 14
        S_CRITICAL = 15
        S_TRACE = 16
        
        identifierCharacters = ":0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ%(%)./%%"
        -- Warn with '-_[]{}'
        -- identifierNumeric = "0123456789:"
        logWords = ' VERBOSE INFO DEBUG WARNING ERROR CRITICAL TRACE '
        
        styler:StartStyling(styler.startPos, styler.lengthDoc, styler.initStyle)
        while styler:More() do

                -- Exit state if needed
                if styler:State() == S_IDENTIFIER then
                        if not identifierCharacters:find(styler:Current(), 1, true) then
                                identifier = styler:Token()
                                -- find the log'keyword and assign the S_..
                                if logWords:find(" "..identifier.." ") then
                                    styler:ChangeState(_G["S_"..identifier:upper()])
                                --find the time
                                elseif identifier:match('[0-9][0-9]:[0-9][0-9]') then
                                    styler:ChangeState(S_HOUR)
                                end
                                styler:SetState(S_DEFAULT)
                        end
                elseif styler:State() == S_LITERAL then
                        if styler:Match("' ") or styler:Match('"') or styler:AtLineEnd() then
                                styler:ForwardSetState(S_DEFAULT)
                        end
                elseif styler:State() == S_BACKTICKS then
                        if styler:Match("`") then
                            styler:ForwardSetState(S_DEFAULT)
                        end
                
                end

                -- Enter state if needed
                if styler:State() == S_DEFAULT then
                        if styler:Match(" '") or styler:Match('"') then
                                styler:SetState(S_LITERAL)
                        elseif styler:Match("`") then
                                styler:SetState(S_BACKTICKS)
                        elseif identifierCharacters:find(styler:Current(), 1, true) then
                                styler:SetState(S_IDENTIFIER)
                        end
                end

                styler:Forward()
        end
        styler:EndStyling()
end