# Geany Base16 Template (flavours)
# Generated from your active Base16 scheme

[theme_info]
name=Base16 {{ scheme | default(value="Custom") }} Dark
description=Base16-driven Geany theme
version=1.0
author=flavours

[named_styles]
#    foreground           ; background          ; bold ; italic
default=#{{base05-hex}}   ;#{{base00-hex}}      ;false;false
error=#{{base08-hex}}

# Editor Styles
#-------------------------------------------------------------------------------
selection=#{{base03-hex}} ;#{{base02-hex}}      ;false;true
current_line=              ;#{{base01-hex}}      ;true ;false
brace_good=#{{base0A-hex}} ;;true ;false
brace_bad=#{{base08-hex}}  ;#{{base01-hex}}      ;true ;false
margin_line_number=#{{base01-hex}};#{{base00-hex}};true;false
margin_folding=#{{base02-hex}}
fold_symbol_highlight=#{{base01-hex}}
indent_guide=#{{base01-hex}}
caret=#{{base05-hex}}
marker_line=#{{base07-hex}}
marker_search=#{{base07-hex}};#{{base0B-hex}};false;false
marker_mark=#{{base07-hex}}  ;#{{base0B-hex}}
call_tips=#{{base03-hex}}    ;;false;false
white_space=#{{base02-hex}}  ;;true ;false

# Programming languages
#-------------------------------------------------------------------------------
comment=#{{base03-hex}}
comment_doc=#{{base03-hex}}
comment_line=#{{base03-hex}}
comment_line_doc=#{{base03-hex}}
comment_doc_keyword=#{{base03-hex}};;true;false
comment_doc_keyword_error=#{{base03-hex}};;false;true

number=#{{base0B-hex}}
number_1=#{{base0A-hex}}
number_2=#{{base0A-hex}}

type=#{{base0A-hex}};;true
class=#{{base0A-hex}};;true
function=#{{base0D-hex}};;false;false
parameter=#{{base06-hex}}

keyword=#{{base0E-hex}};;true;false
keyword_1=#{{base0E-hex}};;false;false
keyword_2=#{{base0A-hex}};;false;false
keyword_3=#{{base05-hex}};;false;false
keyword_4=#{{base0A-hex}};;false;true

identifier=#{{base05-hex}};;false;false
identifier_1=#{{base05-hex}};;false;false
identifier_2=#{{base05-hex}};;false;false
identifier_3=#{{base0D-hex}};;true;false
identifier_4=#{{base0E-hex}};;false;false

string=#{{base0A-hex}}
string_1=#{{base0B-hex}}
string_2=#{{base0B-hex}}
string_3=#{{base05-hex}}
string_4=#{{base0D-hex}}
string_eol=#{{base0E-hex}};;false;true

character=string_1
backtick=#{{base0A-hex}}
here_doc=#{{base0A-hex}}
scalar=#{{base0A-hex}}
label=#{{base06-hex}};;true;false
preprocessor=#{{base0D-hex}}
regex=number_1
operator=#{{base0D-hex}};;false;false
decorator=#{{base0D-hex}};;false;false
other=#{{base08-hex}}

# Markup-type languages
#-------------------------------------------------------------------------------
tag=#{{base0A-hex}};;true;false
tag_unknown=#{{base08-hex}};;true;false
tag_end=#{{base0A-hex}};;false;false
attribute=#{{base0A-hex}};;false;false
attribute_unknown=#{{base0B-hex}};;false;false
value=#{{base0D-hex}}
entity=#{{base0A-hex}}

# Diff
#-------------------------------------------------------------------------------
line_added=#{{base0B-hex}}
line_removed=#{{base08-hex}}
line_changed=#{{base0D-hex}}
