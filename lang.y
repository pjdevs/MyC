%{

#include "Table_des_symboles.h"
#include "Attribute.h"
#include "PCode/PCode.h"

#include <stdio.h>
  
extern int yylex();
extern int yyparse();

void yyerror(char* s)
{
    printf ("%s\n",s);
}
		

%}

%union
{ 
	struct ATTRIBUTE * att;
}

%token <att> NUM
%token TINT
%token <att> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <att> IF ELSE WHILE

%token <att> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <att> exp  typename
         

%%

prog : func_list               {}
;

func_list : func_list fun      {}
| fun                          {}
;


// I. Functions

fun : type fun_head fun_body        {}
;

fun_head : ID PO PF            {} // erreur si profondeur diff zero
| ID PO params PF              {}
;

params: type ID vir params     {}
| type ID                      {}

vlist: vlist vir ID            {}
| ID                           {}
;

vir : VIR                      {}
;

fun_body : AO block AF         {}
;

// Block
block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl_list decl     {}
|                              {}
;

decl: var_decl PV              {}
;

var_decl : type vlist          {}
;

type
: typename                     {}
;

typename
: TINT                          {}
| VOID                          {}
;

// II. Intructions

inst_list: inst inst_list   {}
| inst                      {}
;

pv : PV                       {}
;
 
inst:
exp pv                        {}
| ao block af                 {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                       {}
;

af : AF                       {}
;


// II.1 Affectations

aff : ID EQ exp               {}
;


// II.2 Return
ret : RETURN exp              {}
| RETURN PO PF                {}
;

// II.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst elsop       {}
;

// la regle avec else vient avant celle avec vide pour induire une resolution
// adequate du conflit shift / reduce avec ELSE en entrée

elsop : else inst             {}
|                             {}
;

bool_cond : PO exp PF         {}
;

if : IF                       {}
;

else : ELSE                   {}
;

// II.4. Iterations

loop : while while_cond inst  {}
;

while_cond : PO exp PF        {}

while : WHILE                 {}
;


// II.3 Expressions
exp
// II.3.1 Exp. arithmetiques
: MOINS exp %prec UNA         {}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {}
| exp MOINS exp               {}
| exp STAR exp                {}
| exp DIV exp                 {}
| PO exp PF                   {}
| ID                          {}
| app                         {}
| NUM                         {}


// II.3.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 {}
| exp SUP exp                 {}
| exp EQUAL exp               {}
| exp DIFF exp                {}
| exp AND exp                 {}
| exp OR exp                  {}

;

// II.4 Applications de fonctions

app : ID PO args PF           {}
;

args :  arglist               {}
|                             {}
;

arglist : exp VIR arglist     {}
| exp                         {}
;



%% 
int main()
{
    /* Ici on peut ouvrir le fichier source, avec les messages 
        d'erreur usuel si besoin, et rediriger l'entrée standard 
        sur ce fichier pour lancer dessus la compilation.
    */

    printf("Compiling MyC source code into PCode (Version 2021) !\n\n");
    return yyparse();
} 

