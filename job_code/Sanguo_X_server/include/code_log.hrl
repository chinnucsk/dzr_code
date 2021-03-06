%% 日志处理
-define(LOG_PATH,"sg.log").


-define(DEBUG(Tag,Format, Args),
    dragon_logger:debug_msg(Tag,?MODULE, ?LINE,erlang:get(id),Format, Args)).

-define(DEBUG(Tag,Format),
    dragon_logger:debug_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).

-define(INFO(Tag,Format, Args),
    dragon_logger:info_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(INFO(Tag,Format),
    dragon_logger:info_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
			      
-define(WARNING(Tag,Format, Args),
    dragon_logger:warning_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(WARNING(Tag,Format),
    dragon_logger:warning_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
			      
-define(ERR(Tag,Format, Args),
    dragon_logger:error_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(ERR(Tag,Format),
    dragon_logger:error_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).

-define(CRITICAL(Tag,Format, Args),
    dragon_logger:critical_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(CRITICAL(Tag,Format),
    dragon_logger:critical_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).

-define(EXCEPTION_LOG(Type, What, Fun, Args),
		?ERR(exception, "~nexception happened when call function: ~w~n"
						"    arguments: ~w~n"
						"    type: ~w, what: ~w~n"
						"    stack trace: ~w~n~n", 
			 [Fun, Args, Type, What, erlang:get_stacktrace()])).
