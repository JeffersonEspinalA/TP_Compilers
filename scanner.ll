%{
#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cstring>
#include <string>

#include "driver.hh"
#include "parser.hh"
%}

%option noyywrap nounput noinput batch debug

%{
yy::parser::symbol_type
make_NUMBER(const std::string& s, const yy::parser::location_type& loc);
%}

id    [a-zA-Z][a-zA-Z_0-9]*
int   [0-9]+
blank [ \t\r]

%{
#define YY_USER_ACTION loc.columns(yyleng);
%}

%%

%{
	yy::location& loc = drv.location;
	loc.step();
%}

{blank}+      loc.step();
\n+           loc.lines(yyleng); loc.step();

"+"           return yy::parser::make_PLUS(loc);
"-"           return yy::parser::make_MINUS(loc);
"*"           return yy::parser::make_STAR(loc);
"/"           return yy::parser::make_SLASH(loc);
"("           return yy::parser::make_LPAREN(loc);
")"           return yy::parser::make_RPAREN(loc);
"->"          return yy::parser::make_ASSIGN(loc);
"si_mayor" 	      return yy::parser::make_IF_MAYOR(loc);
"si_menor"	      return yy::parser::make_IF_MENOR(loc);
"por_cada"    return yy::parser::make_FOR(loc);
"," 	      return yy::parser::make_COMA(loc);

{int}         return make_NUMBER(yytext, loc);
{id}          return yy::parser::make_IDENTIFIER(yytext, loc);
.             {
	            throw yy::parser::syntax_error(loc, "invalid character: " + std::string(yytext));
              }
<<EOF>>       return yy::parser::make_YYEOF(loc);

%%

yy::parser::symbol_type
make_NUMBER(const std::string& s, const yy::parser::location_type& loc) {
	errno = 0;
	long n = strtol(s.c_str(), nullptr, 10);
	if (!(INT_MIN <= n && n <= INT_MAX && errno != ERANGE)) {
		throw yy::parser::syntax_error(loc, "integer is out of range: " + s);
	}
	return yy::parser::make_NUMBER((int)n, loc);
}

void driver::scan_begin() {
	yy_flex_debug = trace_scanning;
	if (file.empty() || file == "-") {
		yyin = stdin;
	} else if (!(yyin = fopen(file.c_str(), "r"))) {
		std::cerr << "cannot open " << file << ": " << strerror(errno) << std::endl;
		exit(EXIT_FAILURE);
	}
}

void driver::scan_end() {
	fclose(yyin);
}
