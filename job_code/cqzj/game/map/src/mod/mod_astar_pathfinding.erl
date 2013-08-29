%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2011, 
%%% @doc
%%%
%%% @end
%%% Created : 15 Jul 2011 by  <>
%%%-------------------------------------------------------------------
-module(mod_astar_pathfinding).

-include("mgeem.hrl").

-export([
         find_path/2,
         find_path/4]).

-record(r_map_node, {key, tx, ty, dir, g, f, p_parent}).

-define(DEFAULT_HEAP_SIZE, 150).
-define(ASTAR_OPEN_HEAP, astar_open_heap).
-define(ASTAR_CLOSE_LIST, astar_close_list).
-define(ASTAR_CLOSE_LIST_ELEMENT, astar_close_list_element).

%%
find_path(StartPos, EndPos) ->
    if StartPos#p_pos.tx =:= EndPos#p_pos.tx andalso 
       StartPos#p_pos.ty =:= EndPos#p_pos.ty ->
            [{StartPos#p_pos.tx, StartPos#p_pos.ty, StartPos#p_pos.dir}];
       true ->
            find_path(mgeem_map:get_mapid(), StartPos, EndPos, ?DEFAULT_HEAP_SIZE)
    end.

find_path(MapID, StartPos, EndPos, HeapSize) ->
    mod_minheap:new_heap(?ASTAR_OPEN_HEAP, HeapSize, fun cmp/2),
    set_close_list([]),
    StartNode = #r_map_node{key={StartPos#p_pos.tx, StartPos#p_pos.ty}, tx=StartPos#p_pos.tx, ty=StartPos#p_pos.ty, dir=StartPos#p_pos.dir, g=0},
    close_list_insert(StartNode),
    find_path2(MapID, StartNode, EndPos#p_pos.tx, EndPos#p_pos.ty).

find_path2(MapID, CurNode, EndTX, EndTY) ->
    case catch insert_aound_map_nodes(MapID, CurNode, EndTX, EndTY) of
        ok ->
            MinNode = mod_minheap:pop(?ASTAR_OPEN_HEAP),
            close_list_insert(MinNode),
            find_path2(MapID, MinNode, EndTX, EndTY);
        {ok, get_it} ->
            Path = [{EndTX, EndTY, get_dir(CurNode, EndTX, EndTY)}],
            mod_minheap:delete_heap(?ASTAR_OPEN_HEAP),
            find_path3(CurNode, Path);
        {error, _} ->
            close_list_delete(),
            mod_minheap:delete_heap(?ASTAR_OPEN_HEAP),
            false;
        _Error ->
            close_list_delete(),
            mod_minheap:delete_heap(?ASTAR_OPEN_HEAP),
            false
    end.

find_path3(#r_map_node{p_parent=undefined}=MapNode, Path) ->
    close_list_delete(),
    [{MapNode#r_map_node.tx, MapNode#r_map_node.ty, MapNode#r_map_node.dir}|Path];
find_path3(CurNode, Path) ->
    ParentNode = get_close_list(CurNode#r_map_node.p_parent),
    find_path3(ParentNode, [{CurNode#r_map_node.tx, CurNode#r_map_node.ty, CurNode#r_map_node.dir}|Path]).

insert_aound_map_nodes(MapID, CurNode, EndTX, EndTY) ->
    #r_map_node{tx=CTX, ty=CTY} = CurNode,
    lists:foreach(
      fun(TX) ->
              lists:foreach(
                fun(TY) ->
                        WalkTable = is_tile_walkable(MapID, TX, TY),
                        if TX =:= EndTX andalso TY =:= EndTY ->
                                erlang:throw({ok, get_it});
                           TX =:= CTX andalso TY =:= CTY ->
                                ignore;
                           not WalkTable ->
                                ignore;
                           true ->
                                insert_aound_map_nodes2(CurNode, EndTX, EndTY, TX, TY, close_list_member({TX, TY}))
                        end
                end, lists:seq(CTY-1, CTY+1))
      end, lists:seq(CTX-1, CTX+1)).

insert_aound_map_nodes2(_CurNode, _EndTX, _EndTY, _TX, _TY, true) ->
    ignore;
insert_aound_map_nodes2(CurNode, EndTX, EndTY, TX, TY, false) ->
    MapNode = get_map_node(TX, TY, CurNode, EndTX, EndTY),
    case mod_minheap:key_find(?ASTAR_OPEN_HEAP, {TX, TY}) of
        {error, _} ->
            case mod_minheap:insert(?ASTAR_OPEN_HEAP, MapNode, {TX, TY}) of
                {error, _} ->
                    erlang:throw({error, heap_full});
                _ ->
                    ok
            end;
        OldMapNode ->
            if MapNode#r_map_node.f >= OldMapNode#r_map_node.f ->
                    ignore;
               true ->
                    mod_minheap:update(?ASTAR_OPEN_HEAP, MapNode, {TX, TY})
            end
    end.

cmp(NodeA, NodeB) ->
    NodeA#r_map_node.f < NodeB#r_map_node.f.

get_map_node(TX, TY, CurNode, EndTX, EndTY) ->
    G = CurNode#r_map_node.g + 1,
    H = erlang:abs(TX-EndTX) + erlang:abs(TY-EndTY),
    #r_map_node{key={TX, TY}, tx=TX, ty=TY, g=G, f=G+H,
                p_parent={CurNode#r_map_node.tx, CurNode#r_map_node.ty},
                dir=get_dir(CurNode, TX, TY)}.

is_tile_walkable(MapID, TX, TY) ->
    mcm:is_walkable(MapID, {TX, TY}).

get_dir(StartNode, TX, TY) ->
    #r_map_node{tx=STX, ty=STY} = StartNode,
    if TX > STX ->
            if TY > STY -> 1;
               TY =:= STY -> 2;
               true -> 3
            end;
       TX =:= STX ->
            if TY > STY -> 0;
               true -> 4
            end;
       true ->
            if TY > STY -> 7;
               TY =:= STY -> 6;
               true -> 5
            end
    end.

set_close_list(L) ->
    erlang:put(?ASTAR_CLOSE_LIST, L).

get_close_list(EKey) ->
    case erlang:get({?ASTAR_CLOSE_LIST_ELEMENT, EKey}) of
        undefined ->
            {error, not_found};
        Node ->
            Node
    end.

get_close_list() ->
    case erlang:get(?ASTAR_CLOSE_LIST) of
        undefined ->
            [];
        L ->
            L
    end.

close_list_insert(MapNode) when is_record(MapNode,r_map_node) ->
    set_close_list([MapNode#r_map_node.key|get_close_list()]),
    erlang:put({?ASTAR_CLOSE_LIST_ELEMENT, MapNode#r_map_node.key}, MapNode);
close_list_insert(_MapNode) ->
%%     ?ERROR_MSG("MapNode=~w",[MapNode]),
    ignore.

close_list_delete() ->
    lists:foreach(
      fun(EKey) ->
              erlang:erase({?ASTAR_CLOSE_LIST_ELEMENT, EKey})
      end, get_close_list()),
    erlang:erase(?ASTAR_CLOSE_LIST).

close_list_member(EKey) ->
    case get_close_list(EKey) of
        {error, _} ->
            false;
        _ ->
            true
    end.
