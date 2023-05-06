%skeleton "lalr1.cc"
%require "3.7.5"
%defines

%define api.token.raw 

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires{
    #include <string>
    #include <cmath>
    class driver;
}

%param {driver& drv}

%locations

%define parse.trace
%define parse.error detailed
%define parse.lac full

%code {
    #include "driver.hh"
}

%define api.token.prefix {TOK_}
%token
    ASSIGN "->"
    MINUS "-"
    PLUS "+"
    STAR "*"
    SLASH "/"
    LPAREN "("
    RPAREN ")"
    COMA ","
    IF_MAYOR "si_mayor"
    IF_MENOR "si_menor"
    FOR "por_cada"
    ;

%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%nterm <int> exp

%printer { yyo << $$;} <*>;

%%

%start unit;

unit: 
    assignments exp        {drv.result = $2;}
    ;

assignments:
    %empty                     {}
    | assignments assignment   {}
    ;

assignment:
    "identifier" "->" exp       { drv.variables[$1] = $3;}
    ;

%left "+" "-";
%left "*" "/";
%left "^";

exp:
    "number"
    | "identifier"          { $$ = drv.variables[$1];}
    | exp "+" exp           { $$ = $1 + $3;}
    | exp "-" exp           { $$ = $1 - $3;}
    | exp "*" exp           { $$ = $1 * $3;}
    | exp "/" exp           { $$ = $1 / $3;}
    | "si_mayor" "(" exp "," exp ")"       { $$ = ($3 > $5) ? $3 : $5; }
    | "si_menor" "(" exp "," exp ")"       { $$ = ($3 < $5) ? $3 : $5; }
    ;

%%

void yy::parser::error(const location_type& l, const std::string& m) {
	std::cerr << l << ": " << m << std::endl;
}

