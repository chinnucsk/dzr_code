%%%-------------------------------------------------------------------
%%% @author odinxu
%%% @date 2010-01-11
%%% @desc the control module
%%%-------------------------------------------------------------------

-define(STATUS_SUCCESS, 0).
-define(STATUS_ERROR,   1).
-define(STATUS_USAGE,   2).
-define(STATUS_BADRPC,  3).

%% mnesia�������ݿ����ڽ�����
-define(STATUS_MNESIA_UPDATING, 4).
%% mnesia�������ݿ������
-define(STATUS_MNESIA_UPDATE_DONE, 5).
-define(STATUS_MNESIA_UPDATE_ERROR, 6).