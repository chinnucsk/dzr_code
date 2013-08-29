-module(common_global).
-author("Bob Ippolito <bob@mochimedia.com>").
-export([get/1, get/2, put/2, put/3, delete/1, delete/2]).

-include("common.hrl").

-spec get(atom()) -> any() | undefined.
%% @equiv get(K, undefined)
get(K) ->
    get(K, undefined).

-spec get(atom(), T) -> any() | T.
%% @doc Get the term for K or return Default.
get(K, Default) ->
    get(K, Default, key_to_module(K)).

get(_K, Default, Mod) ->
    try Mod:term()
    catch error:undef ->
            Default
    end.

-spec put(atom(), any()) -> ok.
%% @doc Store term V at K, replaces an existing term if present.
put(K, V) ->
	put(K, V, key_to_module(K)).

put(_K, V, Mod) ->
    Bin = compile(Mod, V),
    code:purge(Mod),
    {module, Mod} = code:load_binary(Mod, atom_to_list(Mod) ++ ".erl", Bin),
    ok.

-spec delete(atom()) -> boolean().
%% @doc Delete term stored at K, no-op if non-existent.
delete(K) ->
	delete(K, key_to_module(K)).

delete(_K, Mod) ->
    code:purge(Mod),
    code:delete(Mod).

-spec key_to_module(atom()) -> atom().
key_to_module(K) ->
    list_to_atom("common_global:" ++ atom_to_list(K)).

-spec compile(atom(), any()) -> binary().
compile(Module, T) ->
    {ok, Module, Bin} = compile:forms(forms(Module, T),
                                      [verbose, report_errors]),
    Bin.

-spec forms(atom(), any()) -> [erl_syntax:syntaxTree()].
forms(Module, T) ->
    [erl_syntax:revert(X) || X <- term_to_abstract(Module, term, T)].

-spec term_to_abstract(atom(), atom(), any()) -> [erl_syntax:syntaxTree()].
term_to_abstract(Module, Getter, T) ->
    [%% -module(Module).
     erl_syntax:attribute(
       erl_syntax:atom(module),
       [erl_syntax:atom(Module)]),
     %% -export([Getter/0]).
     erl_syntax:attribute(
       erl_syntax:atom(export),
       [erl_syntax:list(
         [erl_syntax:arity_qualifier(
            erl_syntax:atom(Getter),
            erl_syntax:integer(0))])]),
     %% Getter() -> T.
     erl_syntax:function(
       erl_syntax:atom(Getter),
       [erl_syntax:clause([], none, [erl_syntax:abstract(T)])])].
