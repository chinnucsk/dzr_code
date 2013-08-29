-module(db_sql).
-export(
    [
        execute/1,
        transaction/1,
        select_limit/3,
        select_limit/4,
        get_one/1,
        get_one/2,
        get_row/1,
        get_row/2,
        get_all/1,
        get_all/2,
        make_insert_sql/3,
        make_replace_sql/3,
        make_update_sql/5,
        sql_format/1,
		sql_str_escape/2,
		execute/2
    ]
).
-include("common.hrl").

%%define a timeout for gen server call
-define(TIMEOUT,60*1000).

%% ִ��һ��SQL��ѯ,����Ӱ�������
%% execute(Sql) ->
%%     case mysql:fetch(?DB, Sql) of
%%         {updated, {_, _, _, R, _}} -> R;
%%         {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason]);
%% 		{data, {_, _, ResultList, _, _}} -> ResultList
%%     end.
%% execute(Sql, Args) when is_atom(Sql) ->
%%     case mysql:execute(?DB, Sql, Args) of
%%         {updated, {_, _, _, R, _}} -> R;
%%         {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
%%     end;
%% execute(Sql, Args) ->
%%     mysql:prepare(s, Sql),
%%     case mysql:execute(?DB, s, Args) of
%%         {updated, {_, _, _, R, _}} -> R;
%%         {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
%%     end.

execute(Connection,Sql) ->
	%%?DEBUG(who, "~p", [self()]),
    case mysql:fetch(Connection, Sql,?TIMEOUT) of
        {data, {_, _, ResultList, _, _}} ->
            {ok, ResultList};
        {updated, _} ->
            {ok, updated};
        {error, {_, _, _, _, Reason}} ->
            ?ERR(db, "~n[Database Error]: ~nQuery:   ~ts~nError:   ~ts", [Sql, Reason]),
            error
    end.


%% ִ��һ��sql���
%% @spec execute(Sql) -> {ok, Result} | error
execute(Sql) ->
	%%?DEBUG(who, "~p", [self()]),
    case mysql:fetch(?DB, Sql,?TIMEOUT) of
        {data, {_, _, ResultList, _, _}} ->
            {ok, ResultList};
        {updated, _} ->
            {ok, updated};
        {error, {_, _, _, _, Reason}} ->
            ?ERR(db, "~n[Database Error]: ~nQuery:   ~ts~nError:   ~ts", [Sql, Reason]),
            error
    end.

%% ������
transaction(F) ->
    case mysql:transaction(?DB, F,?TIMEOUT) of
        {atomic, R} -> R;
        {updated, {_, _, _, R, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Reason]);
        {aborted, {Reason, _}} -> mysql_halt([Reason]);
        Error -> mysql_halt([Error])
    end.

%% ִ�з�ҳ��ѯ���ؽ���е�������
select_limit(Sql, Offset, Num) ->
    S = list_to_binary([Sql, <<" limit ">>, integer_to_list(Offset), <<", ">>, integer_to_list(Num)]),
    case mysql:fetch(?DB, S,?TIMEOUT) of
        {data, {_, _, R, _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.
select_limit(Sql, Args, Offset, Num) ->
    S = list_to_binary([Sql, <<" limit ">>, list_to_binary(integer_to_list(Offset)), <<", ">>, list_to_binary(integer_to_list(Num))]),
    mysql:prepare(s, S),
    case mysql:execute(?DB, s, Args,?TIMEOUT) of
        {data, {_, _, R, _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

%% ȡ����ѯ����еĵ�һ�е�һ��
%% δ�ҵ�ʱ����null
get_one(Sql) ->
    case mysql:fetch(?DB, Sql,?TIMEOUT) of
        {data, {_, _, [], _, _}} -> null;
        {data, {_, _, [[R]], _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.
get_one(Sql, Args) when is_atom(Sql) ->
    case mysql:execute(?DB, Sql, Args,?TIMEOUT) of
        {data, {_, _, [], _, _}} -> null;
        {data, {_, _, [[R]], _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end;
get_one(Sql, Args) ->
    mysql:prepare(s, Sql),
    case mysql:execute(?DB, s, Args,?TIMEOUT) of
        {data, {_, _, [], _, _}} -> null;
        {data, {_, _, [[R]], _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

%% ȡ����ѯ����еĵ�һ��
get_row(Sql) ->
    case mysql:fetch(?DB, Sql,?TIMEOUT) of
        {data, {_, _, [], _, _}} -> [];
        {data, {_, _, R, _, _}} -> hd(R);
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.
get_row(Sql, Args) when is_atom(Sql) ->
    case mysql:execute(?DB, Sql, Args,?TIMEOUT) of
        {data, {_, _, [], _, _}} -> [];
        {data, {_, _, R, _, _}} -> hd(R);
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end;
get_row(Sql, Args) ->
    mysql:prepare(s, Sql),
    case mysql:execute(?DB, s, Args,?TIMEOUT) of
        {data, {_, _, [], _, _}} -> [];
        {data, {_, _, R, _, _}} -> hd(R);
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

%% ȡ����ѯ����е�������
get_all(Sql) ->
    case mysql:fetch(?DB, Sql,?TIMEOUT) of
        {data, {_, _, R, _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.
get_all(Sql, Args) when is_atom(Sql) ->
    case mysql:execute(?DB, Sql, Args,?TIMEOUT) of
        {data, {_, _, R, _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end;
get_all(Sql, Args) ->
    mysql:prepare(s, Sql),
    case mysql:execute(?DB, s, Args,?TIMEOUT) of
        {data, {_, _, R, _, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

%% @doc ��ʾ�˿��Կ��ö��Ĵ�����Ϣ
mysql_halt([Sql, Reason]) ->
    erlang:error({db_error, [Sql, Reason]}).

%%���mysql insert���
%% ʹ�÷�ʽmake_insert_sql(test,["row","r"],["����",123]) �൱ insert into `test` (row,r) values('����','123')
%%Table:����
%%Field���ֶ�
%%Data:����
make_insert_sql(Table, Field, Data) ->
    L = make_conn_sql(Field, Data, []),
    lists:concat(["insert into `", Table, "` set ", L]).

%%���mysql replace���
%% ʹ�÷�ʽmake_replace_sql(test,["row","r"],["����",123]) �൱ replace into `test` (row,r) values('����','123')
%%Table:����
%%Field���ֶ�
%%Data:����
make_replace_sql(Table, Field, Data) ->
    L = make_conn_sql(Field, Data, []),
    lists:concat(["replace into `", Table, "` set ", L]).

    
%%���mysql insert���
%% ʹ�÷�ʽmake_update_sql(test,["row","r"],["����",123],"id",1) �൱ update `test` set row='����', r = '123' where id = '1'
%%Table:����
%%Field���ֶ�
%%Data:����
%%Key:��
%%Data:ֵ
make_update_sql(Table, Field, Data, Key, Value) ->
    L = make_conn_sql(Field, Data, []),
    lists:concat(["update `", Table, "` set ",L," where ",Key,"= '",sql_format(Value),"'"]).

    
make_conn_sql([], _, L ) ->
    L ;
make_conn_sql(_, [], L ) ->
    L ;
make_conn_sql([F | T1], [D | T2], []) ->
    L  = [F," = '",sql_format(D),"'"],
    make_conn_sql(T1, T2, L);
make_conn_sql([F | T1], [D | T2], L) ->
    L1  = L ++ [",", F," = '",sql_format(D),"'"],
    make_conn_sql(T1, T2, L1).

sql_format(S) when is_integer(S)->
    integer_to_list(S);
sql_format(S) when is_float(S)->
    float_to_list(S);
sql_format(S) when is_list(S) ->
	sql_str_escape(S, "");
sql_format(S) ->
    S.

sql_str_escape([], Acc) ->
	lists:reverse(Acc);
sql_str_escape([H | T], Acc) ->
	NewAcc = 
		case H of
			$"  -> [H, $\\ | Acc];
			$'  -> [H, $\\ | Acc];
			$\\ -> [H, $\\ | Acc];
			_   -> [H | Acc]
		end,
	sql_str_escape(T, NewAcc);

sql_str_escape(<<>>, Acc) ->
	Acc;
sql_str_escape(<<H:8, T/binary>>, Acc) ->
	NewAcc = 
		case H of
			$"  -> <<Acc/binary, $\\:8, H:8>>;
			$'  -> <<Acc/binary, $\\:8, H:8>>;
			$\\ -> <<Acc/binary, $\\:8, H:8>>;
			_   -> <<Acc/binary, H:8>>
		end,
	sql_str_escape(T, NewAcc).
