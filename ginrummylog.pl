%LABORATORIO 2 Grupo 18
%INTEGRANTES:
% Sebastian Uhlfelder, 5.510.433-2
% Facundo Lopez, 5.177.215-1
% Agustin Kuchura, 5.175.815-9
% Joaquín Brito, 5.393.701-4

%Caso Set:
is_meld([c(V,P1), c(V,P2), c(V,P3)]) :-
    P1 \= P2,
    P2 \= P3,
    P1 \= P3.

is_meld([c(V,P1), c(V,P2), c(V,P3), c(V,P4)]) :-
    P1 \= P2,
    P2 \= P3,
    P1 \= P3,
    P4 \= P2,
    P4 \= P3,
    P4 \= P1.

%Caso Run:
is_meld(Cartas) :-
    length(Cartas, N), N >= 3,
    mismo_palo(Cartas),
    ordenar_por_numero(Cartas,Ordenadas),
    secuencia_consecutiva(Ordenadas), !.


sucesor(a, 2).
sucesor(2, 3).
sucesor(3, 4).
sucesor(4, 5).
sucesor(5, 6).
sucesor(6, 7).
sucesor(7, 8).
sucesor(8, 9).
sucesor(9, 10).
sucesor(10, j).
sucesor(j, q).
sucesor(q, k).

escalera([c(_,Palo)],Palo).
escalera([c(V1,Palo), c(V2,Palo)|Resto], Palo):-
    sucesor(V1,V2),
    escalera([c(V2,Palo)|Resto],Palo).

%valor_deadwood
valorCartas(a,1).
valorCartas(j,10).
valorCartas(q,10).
valorCartas(k,10).
valorCartas(N,N):- number(N), N >= 2, N =< 10.

valor_deadwood([ ],0).
valor_deadwood([c(V1,_)| Resto],Valor):-
    valor_deadwood(Resto,Valor1),
    valorCartas(V1,V),
    Valor is Valor1 + V.

orden_rango(a, 1).
orden_rango(2, 2).
orden_rango(3, 3).
orden_rango(4, 4).
orden_rango(5, 5).
orden_rango(6, 6).
orden_rango(7, 7).
orden_rango(8, 8).
orden_rango(9, 9).
orden_rango(10, 10).
orden_rango(j, 11).
orden_rango(q, 12).
orden_rango(k, 13).

% sub_conjunto(+Lista, -Subconjunto)
% dada una mano de cartas, toma un subgrupo.
sub_conjunto([], []).
sub_conjunto([X|R], [X|Sub]) :-
    sub_conjunto(R, Sub).
sub_conjunto([_|R], Sub) :-
    sub_conjunto(R, Sub).

%saca un conjunto de cartas de una mano.
restar_cartas([],L,L).
restar_cartas([Carta | Resto], Mano,R) :-
    select(Carta, Mano, ManoAux),
    restar_cartas(Resto, ManoAux,R).

mismo_palo([]).
mismo_palo([c(_,P)|R]) :-
    mismo_palo(R,P).

mismo_palo([], _).
mismo_palo([c(_,P)|R], P) :-
    mismo_palo(R,P).


par_rango_carta(c(V,P), R-c(V,P)) :-
    orden_rango(V,R).

valores_pares([], []).
valores_pares([_-V|Cola],[V|Valores]) :-
    valores_pares(Cola,Valores).

%ordena las cartas por numero
ordenar_por_numero(Cartas,Ordenadas) :-
    maplist(par_rango_carta,Cartas, Pares),
    keysort(Pares, ParesOrdenados),
    valores_pares(ParesOrdenados, Ordenadas).

valor_rango_carta(c(V,_), R) :-
    orden_rango(V,R).


secuencia_consecutiva([_]).
secuencia_consecutiva([C1,C2|R]) :-
    valor_rango_carta(C1,R1),
    valor_rango_carta(C2,R2),
    R2 is R1 + 1,
    secuencia_consecutiva([C2|R]).

candidato_meld(Mano, Meld) :-
    meld_conjunto(Mano, Meld).
candidato_meld(Mano, Meld) :-
    meld_escalera(Mano, Meld).

%la idea aca es armar grupos que sean sets, agrupando todas las cartas por numeros
%y viendo si de algun numero hay 3 o 4 cartas.
meld_conjunto(Mano, Meld) :-
    agrupar_por_numero(Mano, Grupos),
    member(_V-Cards, Grupos),
    sub_conjunto(Cards, Meld),
    length(Meld, N),
    N >= 3,
    N =< 4.

%parecido al anterior: la idea es agrupar por palo, agarrar cada grupo de palos
% y ordenarlo por numero. Despues busco si hay al menos 3 consecutivas en ese subgrupo.
meld_escalera(Mano, Meld) :-
    agrupar_por_palo(Mano, Grupos),
    member(_P-Cards, Grupos),
    ordenar_por_numero(Cards, Orden),
    append(_, Cola, Orden),
    prefijo_escalera(Cola, Meld),
    length(Meld, N),
    N >= 3.

%para el predicado anterior, dada una lista intenta construir una escalera lo mas larga posible
prefijo_escalera([C1,C2|_], [C1,C2]) :-
    valor_rango_carta(C1,R1),
    valor_rango_carta(C2,R2),
    R2 is R1 + 1.
prefijo_escalera([C1,C2|Rest], [C1|Run]) :-
    valor_rango_carta(C1,R1),
    valor_rango_carta(C2,R2),
    R2 is R1 + 1,
    prefijo_escalera([C2|Rest], Run).

%arma un grupo para cada numero en una mano
agrupar_por_numero(Mano, Groups) :-
    agrupar_por_numero(Mano, [], Groups).

agrupar_por_numero([], Groups, Groups).
agrupar_por_numero([Card|Resto], Acc, Groups) :-
    Card = c(V,_),
    insertar_en_grupo(V, Card, Acc, Acc2),
    agrupar_por_numero(Resto, Acc2, Groups).

insertar_en_grupo(Key, Card, [], [Key-[Card]]).
insertar_en_grupo(Key, Card, [Key-Cards|Resto], [Key-[Card|Cards]|Resto]) :- !.
insertar_en_grupo(Key, Card, [Otra|Resto], [Otra|Resto2]) :-
    insertar_en_grupo(Key, Card, Resto, Resto2).

agrupar_por_palo(Mano, Groups) :-
    agrupar_por_palo(Mano, [], Groups).

agrupar_por_palo([], Groups, Groups).
agrupar_por_palo([Card|Resto], Acc, Groups) :-
    Card = c(_,P),
    insertar_en_grupo(P, Card, Acc, Acc2),
    agrupar_por_palo(Resto, Acc2, Groups).


%get_melds
get_melds(Mano, [], Mano).

%la idea de usar candidato_mels es reducir el numero de candidatos que se prueban
get_melds(Mano, [Meld|Resto], Sobrantes) :-
    candidato_meld(Mano, Meld),
    restar_cartas(Meld, Mano, NuevaMano),
    get_melds(NuevaMano, Resto, Sobrantes).



%best_melds(+Mano, ?MejorMelds, ?Sobrante, ?Valor)
% la idea es: se almacenan los candidatos en un formato estructurado opcion(valor, meld, sobras).
% setof ya ordena estos candidatos por el primer argumento y nos quedamos con la cabeza de la lista.

best_melds(Mano, MejorMelds, Sobrante, Valor) :-
    sort(Mano, _),
    setof(opcion(V, M, S), (get_melds(Mano, M, S), valor_deadwood(S, V)), [opcion(Valor, MejorMelds, Sobrante)|_]).


%robar(+Mano, +Descarte, +CartasVistas, +Estrategia, ?Lugar)

    %Estrategia Random:
    robar(_Mano, _, _,random, Lugar) :-
        random_member(Lugar, [mazo, descarte]), !.

    %Estrategia Greedy:
    robar(Mano, c(Valor,Palo), _, greedy, descarte) :-

        best_melds(Mano, _, _,DeadwoodActual),
        ManoConDescarte = [c(Valor,Palo)|Mano],
        descartar(ManoConDescarte, _, greedy, ManoX, _), %simulo un descarte
        best_melds(ManoX,_, _,DeadwoodConDescarte), %si despues del descarte ficticio mejoro deadwood, me sirve
        DeadwoodConDescarte < DeadwoodActual, !.

    robar(_,_,_, greedy, mazo). 



    %Estrategia Pro:
    robar(Mano, c(Valor,Palo), _, pro, descarte) :-
        best_melds(Mano, _, _,DeadwoodActual),
        ManoConDescarte = [c(Valor,Palo)|Mano],
        descartar(ManoConDescarte, _, greedy, ManoX, _), %simulo un descarte
        best_melds(ManoX,_, _,DeadwoodConDescarte), %si despues del descarte ficticio mejoro deadwood, me sirve
        DeadwoodConDescarte < DeadwoodActual, !.

    %Toma del descarte si ayuda a completar un set
    robar(Mano, c(Valor,_), CartasVistas, pro, descarte) :-
        valorCartas(Valor, V),
        V =< 7,
        member(c(Valor, _), Mano),
        member(P3, [c,d,t,p]),
        \+ member(c(Valor, P3), Mano),
        \+ member(c(Valor, P3), CartasVistas), !.

    %lo mismo con escalera
    robar(Mano, c(Valor,Palo), CartasVistas, pro, descarte) :-
        valorCartas(Valor, V),
        V =< 9,
        aux_escalera(Mano, c(Valor,Palo), CartasVistas), !.
    robar(_,_,_, pro, mazo).

    aux_escalera(Mano, c(Valor,Palo), CartasVistas) :-
    	sucesor(Valor,Vmano),
    	member(c(Vmano, Palo), Mano),
    	sucesor(Vmano,Val),
    	\+member(c(Val, Palo),CartasVistas),!.
    
    aux_escalera(Mano, c(Valor,Palo), CartasVistas) :-
    	sucesor(Valor,Vmano),
    	member(c(Vmano, Palo), Mano),
    	sucesor(V,Valor),
    	\+member(c(V, Palo),CartasVistas),!.
    
    aux_escalera(Mano, c(Valor,Palo), CartasVistas) :-
    	sucesor(Vmano,Valor),
    	member(c(Vmano, Palo), Mano),
    	sucesor(Valor,Val),
    	\+member(c(Val, Palo),CartasVistas),!.
    	
    aux_escalera(Mano, c(Valor,Palo), CartasVistas) :-
    	sucesor(Vmano,Valor),
    	member(c(Vmano, Palo), Mano),
    sucesor(V,Vmano),
    	\+member(c(V, Palo),CartasVistas),!.
    
    
%descartar(+OldMano, +CartasVistas, +Estrategia, ?NewMano, ?NewDescarte)

    %Estrategia Random:
    descartar(OldMano, _, random, NewMano, NewDescarte) :-
        random_member(NewDescarte, OldMano),
        select(NewDescarte, OldMano, NewMano), !.
    
    %Estrategia Greedy:
    descartar(OldMano,_, greedy, NewMano, NewDescarte) :-
        OldMano = [CartaInicial|_],
        select(CartaInicial, OldMano, ManoResultanteInicial),
        best_melds(ManoResultanteInicial, _, _, DeadwoodInicial),
        buscar_minimo(
            OldMano,
            OldMano,
            opcion(DeadwoodInicial, ManoResultanteInicial, CartaInicial),
            opcion(_, NewMano,NewDescarte)
        ).
    
    %Estrategia Pro:
    % Igual que greedy pero desempata usando cartas vistas
    descartar(OldMano, CartasVistas, pro, NewMano, NewDescarte) :-
        OldMano = [CartaInicial|_],
        select(CartaInicial, OldMano, ManoResultanteInicial),
        best_melds(ManoResultanteInicial, _, _, DeadwoodInicial),
        bono(CartaInicial, OldMano, CartasVistas, BonoInicial),
        ScoreInicial is DeadwoodInicial + BonoInicial,
        
        buscar_minimo_pro(
            OldMano,
            OldMano,
            CartasVistas,
            opcion(ScoreInicial, ManoResultanteInicial, CartaInicial),
            opcion(_, NewMano, NewDescarte)
        ).
    
    bono(Carta, Mano, CartasVistas, Bono) :-
        cartas_utiles(Carta, Mano, Utiles),
        exclude(esta_vista(CartasVistas),Utiles,UtilesDisponibles),
        length(UtilesDisponibles, N),
        sinergias_en_mano(Carta, Mano,S),
        Bono is N + (S * 2).

    
    sinergias_en_mano(c(V, P), Mano, S) :-
        findall(_, (
            member(c(V,P2), Mano), P2\= P  
            ;
            (sucesor(V, V2), member(c(V2,P), Mano))  % c sirve para run
            ;
            (sucesor(V2,V), member(c(V2, P),Mano))  % c sirve para run 
        ), Lista),
        length(Lista, S).

    esta_vista(CartasVistas, Carta) :-
        member(Carta, CartasVistas).

    % resuelve que cartas necesitaria esta carta para formar melds
    cartas_utiles(c(V, P), Mano, Utiles) :-
        findall(C,
            (carta_completa_meld(c(V,P), C),
            \+ member(C, Mano)),   % que no la tenga ya
            Utiles).

    carta_completa_meld(c(V, P), c(V2, P)) :-
        sucesor(V, V2).
    carta_completa_meld(c(V, P), c(V2, P)) :-
        sucesor(V2, V).

    carta_completa_meld(c(V, _), c(V, P2)) :-
        member(P2, [c, d, t, p]).

    % Igual que buscar_minimo pero con score que incluye bono
    buscar_minimo_pro([], _, _, X, X).

    
    buscar_minimo_pro([Carta|Resto], OldMano, CartasVistas, opcion(ScoreMin, _, _), Resultado) :-
        select(Carta, OldMano, ManoDe10),
        best_melds(ManoDe10, _, _, NuevoDeadwood),
        bono(Carta, OldMano, CartasVistas, Bono),
        NuevoScore is NuevoDeadwood + Bono,
        NuevoScore < ScoreMin, !,
        buscar_minimo_pro(Resto, OldMano, CartasVistas, opcion(NuevoScore, ManoDe10, Carta), Resultado).

    buscar_minimo_pro([_|Resto], OldMano, CartasVistas, MejorHastaAhora, Resultado) :-
        buscar_minimo_pro(Resto, OldMano, CartasVistas, MejorHastaAhora, Resultado).

%cerrar(+Mano, +CartasVistas, +Estrategia, ?Decision)
    
    %Estrategia Random:
    %si el deadwood es <=10, se decide aleatoriamente si cortar o no
    cerrar(Mano, _, random, Decision) :-
        best_melds(Mano, _, _, Deadwood),
        Deadwood =< 10, !,
        random_member(Decision, [continuar, cortar]).
    
    cerrar(_, _, random, continuar).

    %Estrategia Greedy:
    %si el deadwood es menor a 10, se cierra inmediatamente
    cerrar(Mano,_,greedy,cortar):-
        best_melds(Mano, _, _, Deadwood),
        Deadwood =< 10, !.
    cerrar(_,_,greedy,continuar).


    %Estrategia Pro:
    cerrar(Mano, _, pro, cortar) :-
        best_melds(Mano, _, _, Deadwood),
        Deadwood =< 10, !.
    cerrar(_, _, pro, continuar).


%funcion auxiliar, devuelve en Resultado la mejor carta para descartar
buscar_minimo([], _,X,X).

buscar_minimo([Carta |Resto], OldMano, opcion(DeadwoodMin, _, _), Resultado) :-
    select(Carta, OldMano, ManoDe10),
    best_melds(ManoDe10, _, _, NuevoDeadwood),
    NuevoDeadwood < DeadwoodMin, !, 
    buscar_minimo(Resto, OldMano, opcion(NuevoDeadwood,ManoDe10, Carta), Resultado).

buscar_minimo([_| Resto], OldMano, MejorHastaAhora, Resultado) :-
    buscar_minimo(Resto, OldMano, MejorHastaAhora, Resultado).
