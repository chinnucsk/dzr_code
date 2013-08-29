%%% -------------------------------------------------------------------
%%% Author  : dzr
%%% Description :
%%%
%%% Created : 2012-2-9
%%% -------------------------------------------------------------------
-module(gen_cache).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% -include("ets_sql_map.hrl").
-include("common.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1, init_ets/1]).
%% 增删查改方法
-export([lookup/2, lookup/3, update_element/3, update_record/2, insert/2, 
		 remove_cache_data/2, delete/2, update_counter/3, tab2list/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================
start_link(GenCacheState) ->
	UpdateIndexEts = cache_util:get_update_index_ets(GenCacheState#gen_cache_state.record),
	RegisterName = cache_util:get_register_name(GenCacheState#gen_cache_state.record),
	GenCacheState1 = GenCacheState#gen_cache_state{update_index = UpdateIndexEts,
												   cache_ref = RegisterName},
	
	%% init_ets(GenCacheState1), %% 将ets表的初始化放在这个gen_server之外
	
	gen_server:start_link({local, RegisterName}, ?MODULE, [GenCacheState1], []).

init_ets(GenCacheState) ->
	UpdateIndexEts = cache_util:get_update_index_ets(GenCacheState#gen_cache_state.record),
	GenCacheState1 = GenCacheState#gen_cache_state{update_index = UpdateIndexEts},
	Mapper = GenCacheState1#gen_cache_state.mapper, 
	#map{ets_tab = RecEts, key_classic = KeyClassic} =  Mapper,
	case KeyClassic of
		1 -> ok;
		_ ->
			RecEtsIndex = cache_util:get_key_index_ets(RecEts),
			%% index表是用来对一个id有多条记录的数据做一个关键字的索引的
			ets:new(RecEtsIndex, [named_table, public, set, {keypos,1}])
	end,

	ets:new(RecEts, [named_table, public, set, {keypos,2}]),
	ets:new(GenCacheState1#gen_cache_state.update_index, 
			[named_table, public, set, {keypos, #update_index.key}]),
	ok.

%% 增删查改方法
%% 下面的参数说明：
%% 		CacheRef为gen_cache进程的名称或是pid
%%		Key为对应ets表的关键字（即对应record的第一个字段）
%%		ElementList与ets:update_element/3方法的第3个参数是一样的，为[{record_field_index, Val}]

%% lookup支持两种查询：
%% 1.Key只是玩家的id（或是其他的id），如果是多关键字的表，gen_cache会对这个id自动做索引的
%% 2.Key是真正的Key，不管其对应的ets表的关键字是一个id还是一个组合的元组key
lookup(CacheRef, Key) ->
	gen_server:call(CacheRef, {lookup, Key}).

%% 获取key对应的所有记录的在位置Pos处的字段的值的列表
%% 注意Pos的值应该是：#record_name.xxx_field
%% 返回[] 如果你传递的Pos是错的，否则返回：[字段值]
lookup(CacheRef, Key, Pos) ->
	gen_server:call(CacheRef, {lookup, Key, Pos}).

update_element(CacheRef, Key, ElementList) ->
	gen_server:cast(CacheRef, {update_element, Key, ElementList}).

%% 增加某一个位置上的字段的计数值
%% UpdateOp={Pos, Incr}
%% Pos的值应该是：#record_name.xxx_field
%% Incr是要增加的值
update_counter(CacheRef, Key, UpdateOp) ->
	gen_server:cast(CacheRef, {update_counter, Key, UpdateOp}).

update_record(CacheRef, RecordData) ->
	gen_server:cast(CacheRef, {update_record, RecordData}).

insert(CacheRef, RecordData) ->
	gen_server:cast(CacheRef, {insert, RecordData}).

%% 删除在cache和db中的RecordData所对应的数据
%% 这里支持当没有关键字的记录的删除，这是RecordData需要是完整的
%% 对于有关键字的删除，RecordData里可以只填充key字段的值
delete(CacheRef, RecordData) ->
	gen_server:cast(CacheRef, {delete, RecordData}).

remove_cache_data(CacheRef, Key) ->
	gen_server:cast(CacheRef, {remove_cache_data, Key}).

%% 获取当前cache中的数据并转换为list返回
tab2list(CacheRef) ->
	gen_server:call(CacheRef, tab2list).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([GenCacheState]) ->
	erlang:process_flag(trap_exit, true),

	case map_data:gen_cache_opt(GenCacheState#gen_cache_state.record) of
		undefined -> 
			GenCacheState1 = GenCacheState;
		GenCacheOpt ->
			GenCacheState1 = GenCacheState#gen_cache_state{
				update_interval = GenCacheOpt#gen_cache_opt.update_interval},
			case GenCacheOpt#gen_cache_opt.pre_load of
				true ->
					do_pre_load(GenCacheState1);
				false ->
					skip
			end
	end,
	timer:apply_after(GenCacheState1#gen_cache_state.update_interval, cache_util, 
					  start_update_to_db, [GenCacheState1#gen_cache_state.cache_ref]),
	?INFO(gen_cache, "init gen_cache of state : ~w", [GenCacheState1]),
    {ok, GenCacheState1}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({lookup, LookupKey}, _From, State) ->
	Reply = lookup_help(LookupKey, State),
    {reply, Reply, State};

handle_call({lookup, LookupKey, Pos}, _From, State) ->
	RecordList = lookup_help(LookupKey, State),
	Fun = fun(RecordData, Acc) ->
		[erlang:element(Pos, RecordData) | Acc]
	end,
	case catch lists:foldl(Fun, [], RecordList) of
		{'EXIT', Error} ->
			?ERR(gen_cache, "Error: ~w", [Error]), 
			Reply = [];
		Reply -> ok
	end,
    {reply, Reply, State};

handle_call(tab2list, _From, State) ->
	#map{ets_tab = RecEts} = State#gen_cache_state.mapper,
    {reply, ets:tab2list(RecEts), State};

handle_call(Msg, From, State) ->
	?INFO(gen_cache, "~w recieve unknown call message: ~w, from ~w", 
						[State#gen_cache_state.cache_ref, Msg, From]),
	{reply, unknown_msg, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({update_element, Key, ElementList}, State) ->
	make_sure_in_cache(State, Key),
	#map{ets_tab = RecEts} = State#gen_cache_state.mapper,
	case ets:update_element(RecEts, Key, ElementList) of
		true ->
			%% 记录该Key对应的数据更新了
			ets:insert(State#gen_cache_state.update_index, #update_index{key = Key}),
			?INFO(gen_cache, "~w update elements: ~w, by key = ~w", 
					[State#gen_cache_state.cache_ref, ElementList, Key]);
		false -> %% 没有该Key的记录存在
			?ERR(gen_cache, "there is no element to update, Key: ~w, ElementList: ~w, State: ~w", 
				 [Key, ElementList, State])
	end,
    {noreply, State};

handle_cast({update_counter, Key, UpdateOp}, State) ->
	make_sure_in_cache(State, Key),
	#map{ets_tab = RecEts} = State#gen_cache_state.mapper,
	ets:update_counter(RecEts, Key, UpdateOp),
	?INFO(gen_cache,"update index is ~w",[State#gen_cache_state.update_index]),
	ets:insert(State#gen_cache_state.update_index, #update_index{key = Key}),
	?INFO(gen_cache, "~w update counter: ~w, by key = ~w", 
		  [State#gen_cache_state.cache_ref, UpdateOp, Key]),
    {noreply, State};


handle_cast({update_record, RecordData}, State) ->
	update_record_help(State, RecordData),
    {noreply, State};

handle_cast({insert, RecordData}, State) ->
	Mapper = State#gen_cache_state.mapper,
	cache_util:insert(State#gen_cache_state.record, RecordData),
	
	insert_to_cache(Mapper, [RecordData]),
	?INFO(gen_cache, "~w insert record: ~w", [State#gen_cache_state.cache_ref, RecordData]),
    {noreply, State};

handle_cast({delete, RecordData}, State) ->
	#map{ets_tab = RecEts, key_classic = KeyClassic} = State#gen_cache_state.mapper,
	Key = erlang:element(2, RecordData),

	case KeyClassic of
		1 ->  ok;
		_ -> %% 多关键字的
			IndexEts = cache_util:get_key_index_ets(RecEts),
			[Id | _] = erlang:tuple_to_list(Key),
			case ets:lookup(IndexEts, Id) of
				[] -> ok;
				[{Id, KeyList}] ->
					ets:insert(IndexEts, {Id, lists:delete(Key, KeyList)})
			end
			
	end,
	ets:delete(State#gen_cache_state.update_index, Key),
	
	ets:delete(RecEts, Key),
	cache_util:delete(State#gen_cache_state.record, RecordData),
	
	?INFO(gen_cache, "~w delete record: ~w", [State#gen_cache_state.cache_ref, RecordData]),
    {noreply, State};

handle_cast({remove_cache_data, Id}, State) ->	
	remove_cache_data_help(Id, State),
    {noreply, State};

handle_cast(start_update_to_db, State) ->
	UpdateList = ets:tab2list(State#gen_cache_state.update_index),
	?INFO(gen_cache, "cache ~w begin start update to db, UpdateList: ~w", 
			  [State#gen_cache_state.cache_ref, UpdateList]),
	
	ets:delete_all_objects(State#gen_cache_state.update_index),
	%%timer:apply_after(100, cache_util, update_to_db, [State#gen_cache_state.cache_ref, UpdateList]),
	cache_util:update_to_db(State#gen_cache_state.cache_ref, UpdateList),
	timer:apply_after(State#gen_cache_state.update_interval, cache_util, 
					  start_update_to_db, [State#gen_cache_state.cache_ref]),
    {noreply, State};

handle_cast({update_to_db, UpdateList}, State) ->
	Mapper = State#gen_cache_state.mapper,
	case UpdateList of
		[] -> 
			?INFO(gen_cache, "End of cache: ~w update data to db", 
					  [State#gen_cache_state.cache_ref]);
		[#update_index{key = Key} | Rest] ->
			%% TODO: 下面这句由可能会返回[]
			case ets:lookup(erlang:element(2, Mapper), Key) of
				[] ->
					?ERR(gen_cache, "There is no recrod data with this update key: ~w, record: ~w", 
						 [Key, State#gen_cache_state.record]);
				[RecordData] ->
					cache_util:update(State#gen_cache_state.record, RecordData),
					?INFO(gen_cache, "record data : ~w updated to db", [RecordData])
			end,
			timer:apply_after(20, cache_util, update_to_db, [State#gen_cache_state.cache_ref, Rest])
	end,
    {noreply, State};

handle_cast(Msg, State) ->
	?INFO(gen_cache, "~w recieve unknown cast message: ~w", [State#gen_cache_state.cache_ref, Msg]),
    {noreply, State}.

update_record_help(State, RecordData) ->
	LookupKey = erlang:element(2, RecordData),
	make_sure_in_cache(State, LookupKey),
	Mapper = State#gen_cache_state.mapper,
	RecEts = erlang:element(2, Mapper),
	case ets:lookup(RecEts, LookupKey) of
		[] -> OldRecordData = [];
		[OldRecordData] -> ok
	end,
	%% 如果没有数据，就来update，就默认执行callback函数了，而且默认插入更新
	case State#gen_cache_state.call_back#gen_cache_call_back.update_record of
		undefined -> 
			NewRecordData = RecordData,
			Do = true;
		{Mod, Fun} ->
			case Mod:Fun(OldRecordData, RecordData) of
				{true, NewRecordData} -> Do = true;
				false -> NewRecordData = RecordData, Do = false
			end
	end,
	case Do == true andalso OldRecordData /= [] of
		true ->
			ets:insert(RecEts, NewRecordData),
			%% 记录该Key对应的数据更新了
			Key = erlang:element(2, NewRecordData),
			ets:insert(State#gen_cache_state.update_index, #update_index{key = Key}),
			?INFO(gen_cache, "~w update record: ~w", [State#gen_cache_state.cache_ref, NewRecordData]);
		false ->
			?ERR(gen_cache, "update_record action cancled, RecordData: ~w, old data: ~w", 
				  [NewRecordData, OldRecordData])
	end.
%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(illegal_msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	UpdateList = ets:tab2list(State#gen_cache_state.update_index),
	do_update_to_db(UpdateList, State),
	?INFO(gen_cache, "gen_cache terminate with reason: ~w, when state is: ~w", 
			  [Reason, State]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

lookup_help(LookupKey, State) ->
	Mapper = State#gen_cache_state.mapper,
	#map{ets_tab = RecEts, key_classic = KeyClassic} = Mapper,
	case KeyClassic of
		1 -> 
			case ets:lookup(RecEts, LookupKey) of
				[] -> %% 缓存中没有，从数据库中获取
					?INFO(gen_cache, "~w read data from db by id: ~w", 
								[State#gen_cache_state.cache_ref, LookupKey]),
					RecordList = cache_util:select(State#gen_cache_state.record, Mapper, LookupKey),
					% ets:insert(Mapper#map.ets_tab, RecordList), %% 插入缓存中
					IsFromDb = true,
					RecordList;
				Objects ->
					IsFromDb = false, 
					RecordList = Objects
			end;
		_ -> %% 多关键字的
			case erlang:is_tuple(LookupKey) of
				true -> [Id | _] = erlang:tuple_to_list(LookupKey);
				false -> Id = LookupKey
			end,
			IndexEts = cache_util:get_key_index_ets(RecEts),
			case ets:lookup(IndexEts, Id) of
				[] ->
					?INFO(gen_cache, "~w read data from db by id: ~w", 
									[State#gen_cache_state.cache_ref, Id]),
					RecordList = cache_util:select(State#gen_cache_state.record, Mapper, Id),
					% ets:insert(Mapper#map.ets_tab, RecordList), %% 插入缓存中
					% IndexDatas = [erlang:element(2, R) || R <- RecordList],
					% ets:insert(IndexEts, {Id, IndexDatas}),
					IsFromDb = true;
				[{Id, KeyList}] ->
					IsFromDb = false,
					Fun = fun(Key, Acc) ->
%% 						[Rec] = ets:lookup(Mapper#map.ets_tab, Key),
						case ets:lookup(Mapper#map.ets_tab, Key) of
							[] ->
								%% 删除错误的keyindex然后dump掉 	
								case erlang:is_tuple(Key) of
									true -> [_Id1,Id2|_] = erlang:tuple_to_list(Key);
									false -> Id2 = Key
								end,	
								Pred = fun(E) ->
									case lists:keymember(Id2,2,[E]) of
										true ->
											false;
										false ->
											true	
									end	
								end,
								KeyListNew = lists:filter(Pred, KeyList),
								ets:insert(IndexEts, {Id, KeyListNew}),
								?INFO(gen_cache,"Key ~w",[[Id, KeyList,KeyListNew]]),	
								%% 继续dump 								
								[Rec] = ets:lookup(Mapper#map.ets_tab, Key),
								[Rec | Acc];
							[Rec] ->	  		
								[Rec | Acc]
						end
					end,
					RecordList = lists:foldl(Fun, [], KeyList)
			end
			
	end,
	case State#gen_cache_state.call_back#gen_cache_call_back.lookup of
		undefined -> 
			NewRecordList = RecordList, Do = false;
		{CbMod, CbFun} ->
			case CbMod:CbFun(IsFromDb, Mapper, LookupKey, RecordList) of
				{true, NewRecordList} -> Do = true;
				false -> NewRecordList = RecordList, Do = false
			end
	end,
	case IsFromDb of
		true -> insert_to_cache(Mapper, NewRecordList);
		false -> ok
	end,
	case (Do andalso NewRecordList /= []) of
		true ->
			[update_record_help(State, R) || R <- NewRecordList];
		false ->
			ok
	end,
	Reply = case erlang:is_tuple(LookupKey) of
		true ->  
			case lists:keyfind(LookupKey, 2, NewRecordList) of
				false -> [];
				Rec -> [Rec]
			end;
		false -> NewRecordList
	end,
	Reply.

make_sure_in_cache(State, LookupKey) ->
	Mapper = State#gen_cache_state.mapper,
	#map{ets_tab = RecEts, key_classic = KeyClassic} = Mapper,
	case KeyClassic of
		1 -> 
			case ets:lookup(RecEts, LookupKey) of
				[] -> %% 缓存中没有，从数据库中获取
					RecordList = cache_util:select(State#gen_cache_state.record, Mapper, LookupKey),
					IsFromDb = true;
				RecordList -> IsFromDb = false
			end;
		_ -> %% 多关键字的
			case erlang:is_tuple(LookupKey) of
				true -> [Id | _] = erlang:tuple_to_list(LookupKey);
				false -> Id = LookupKey
			end,
			IndexEts = cache_util:get_key_index_ets(RecEts),
			case ets:lookup(IndexEts, Id) of
				[] ->
					RecordList = cache_util:select(State#gen_cache_state.record, Mapper, Id),
					IsFromDb = true;
				_ -> IsFromDb = false, RecordList = []
			end
			
	end,
	case IsFromDb of
		true -> 
			?INFO(gen_cache, "~w read data from db by id: ~w", [State#gen_cache_state.cache_ref, LookupKey]),
			insert_to_cache(Mapper, RecordList);
		false -> ok
	end.

insert_to_cache(Mapper, RecordDataList) ->
	#map{ets_tab = RecEts, key_classic = KeyClassic} = Mapper,
	ets:insert(RecEts, RecordDataList),
	case KeyClassic of
		1 -> %% 无需更新key index 表
			ok;
		_ ->
			IndexEts = cache_util:get_key_index_ets(RecEts),
			Fun = fun(Rec) ->
				Key = erlang:element(2, Rec),
				Id = erlang:element(1, Key),
				case ets:lookup(IndexEts, Id) of
					[] -> 
						ExistKeysNew = [Key];
					[{Id, ExistKeys}] ->	
						?INFO(test,"~w",[[Id,ExistKeys]]),
						case lists:member(Key, ExistKeys) of
							true ->
								ExistKeysNew = ExistKeys;
							false ->
								ExistKeysNew = [Key|ExistKeys]
						end		
				end,
				ets:insert(IndexEts, {Id, ExistKeysNew})
			end,
			lists:foreach(Fun, RecordDataList)		
						

%% 			Fun = fun(Rec, Acc) ->
%% 				Key = erlang:element(2, Rec),
%% 				[Key | Acc]
%% 			end,
%% 			Keys = lists:foldl(Fun, [], RecordDataList),
%% 			IndexEts = cache_util:get_key_index_ets(RecEts),
%% 			case RecordDataList of
%% 				[] -> ok;
%% 				[RecordData | _] ->
%% 					Key = erlang:element(2, RecordData),
%% 					Id = erlang:element(1, Key),
%% 					case ets:lookup(IndexEts, Id) of
%% 						[] -> 
%% %% 							ExistKeys1 = Keys;
%% 							KeyFun = fun(Rec, Acc) ->
%% 								case lists:keymember(Id,1,[Rec]) of
%% 									true ->
%% 										case lists:member(Rec, Acc) of
%% 											true ->
%% 												Acc;
%% 											false ->
%% 												[Rec| Acc]
%% 										end;
%% 									false ->
%% 										Acc
%% 								end	
%% 							end,
%% 							ExistKeys1 = lists:foldl(KeyFun, [], Keys),
%% 							?INFO(test,"~w",[[Id,ExistKeys1]]);	
%% 						[{Id, ExistKeys}] ->
%% %% 							ExistKeys1 = Keys ++ ExistKeys
%% 							KeyFun = fun(Rec, Acc) ->
%% 								case lists:keymember(Id,1,[Rec]) of
%% 									true ->
%% 										case lists:member(Rec, Acc) of
%% 											true ->
%% 												Acc;
%% 											false ->
%% 												[Rec| Acc]
%% 										end;
%% 									false ->
%% 										Acc
%% 								end	
%% 							end,
%% 							ExistKeys1 = lists:foldl(KeyFun, ExistKeys, Keys)						
%% 					end,
%% 					?INFO(test,"~w",[[Id,ExistKeys1]]),	
%% 					ets:insert(IndexEts, {Id, ExistKeys1})
%% 			end
	end.

remove_cache_data_help(Id, State) ->
	Mapper = State#gen_cache_state.mapper,
	#map{ets_tab = RecEts, key_classic = KeyClassic} = Mapper,
	Fun = fun(Key) ->
		case ets:lookup(State#gen_cache_state.update_index, Key) of
			[] -> ok;%% 该数据没有更新过
			_ ->
				%% TODO: 下面这句由可能会返回[]
				case ets:lookup(RecEts, Key) of
					[] -> ok;
					[RecordData] ->
						cache_util:update(State#gen_cache_state.record, RecordData)
				end
		end,
		ets:delete(RecEts, Key)
	end,
	case KeyClassic of
		1 -> 
			Fun(Id);
		_ -> %% 多关键字的
			IndexEts = cache_util:get_key_index_ets(RecEts),
			case ets:lookup(IndexEts, Id) of
				[] -> ok;
				[{Id, KeyList}] ->
					[Fun(K) || K <- KeyList],
					ets:delete(IndexEts, Id)
			end
			
	end.

do_pre_load(GenCacheState) ->
	Mapper = GenCacheState#gen_cache_state.mapper,
	RecordList = cache_util:select_all(GenCacheState#gen_cache_state.record, Mapper),
	insert_to_cache(Mapper, RecordList).
%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
do_update_to_db([], _State) -> ok;
do_update_to_db([#update_index{key = Key} | Rest], State) ->
	Mapper = State#gen_cache_state.mapper,
	[RecordData] = ets:lookup(erlang:element(2, Mapper), Key),
	cache_util:update(State#gen_cache_state.record, RecordData),
	do_update_to_db(Rest, State).	
	
