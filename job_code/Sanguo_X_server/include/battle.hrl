
-define(BATTLE_FIELD_SIZE,        12).
-define(BATTLE_ROW_SIZE,           3).
-define(BATTLE_WAIT_BEGIN,     data_battle:get_wait_begin_time()).
-define(BATTLE_WAIT_FINISH,    data_battle:get_wait_finish_time()).
-define(BATTLE_WAIT_QUIT,      data_battle:get_wait_quit_time()).
-define(UNDEFINED, undefined).

-define(BOSS_POSITION, 11).


%==========================================================================================
% battle type
%==========================================================================================

-define(BATTLE_TYPE_ARENA, 5).
-define(BATTLE_TYPE_BOSS, 10).


%% Range define.
-define(SINGLE,      1).
-define(ALL,         2).
-define(ALLENEMY,    3).
-define(ALLFRIENDLY, 4).
-define(HORIZONTAL,  5).
-define(VERTICAL,    6).
-define(ADJACENT,    7).
-define(ENEMYFRONT,  8).
-define(ENEMYBACK,   9).
-define(FRIENDFRONT, 10).
-define(FRIENDBACK,  11).
-define(OBLIQUE,     12).

-define(HP_MAX, 100000000).


-define(BUFF_PDEF_UP,    1).     %% 坚盾
-define(BUFF_PDEF_DOWN,  2).
-define(BUFF_MDEF_UP,    3).     %% 法盾
-define(BUFF_MDEF_DOWN,  4).     
-define(BUFF_ATT_UP,     5).     %% 强力
-define(BUFF_ATT_DOWN,   6).
-define(BUFF_LUCK_UP,    7).
-define(BUFF_LUCK_DOWN,  8).

-define(BUFF_SPEED_UP,   9).     %% 敏捷
-define(BUFF_SPEED_DOWN, 10).
-define(BUFF_CRIT,       12).    %% 暴擊
-define(BUFF_FATAL,      13).    %% 致命
-define(BUFF_HIT_UP,     14).    %% 命中
-define(BUFF_HIT_DOWN,   15).    %% 模糊(降命中)
-define(BUFF_REBOUND,    16).    %% 反彈
-define(BUFF_COUNTER,    17).    %% 反击.
-define(BUFF_LIFE_DRAIN, 18).    %% 吸血
-define(BUFF_MANA_DRAIN, 19).    %% 吸魔 
-define(BUFF_REFRESH,    20).    %% 生命回複
-define(BUFF_SCORN,      21).    %% 嘲讽
-define(BUFF_SCORNED,    22).    %% 被嘲讽
-define(BUFF_ASSIST,     23).    %% 援護: 自動成為攻擊目標
-define(BUFF_FAINT,      24).
-define(BUFF_DEADLY,     25).    %% 致命
-define(BUFF_FRENZY,     26).    %% 狂暴
-define(BUFF_WEAKNESS,   27).    %% 降低治疗量
-define(BUFF_TOXIC,      28).    %% 中毒

-define(BUFF_BLOCK_UP,   31).    %% 格挡(抗暴击)
-define(BUFF_BLOCK_DOWN, 32).    %% 格挡下降

-define(BUFF_CRIT_UP,    33).
-define(BUFF_CRIT_DOWN,  34).

-define(BUFF_DAMAGE_ADD, 35).    %% 

-define(BUFF_TEST,       12).


%=============================================================================================
% passive skill: use buff to implement
%=============================================================================================
-define(PSKILL_PROTECT,    201).    %% 守護
-define(PSKILL_DOUBLE_HIT, 203).    %% 連擊: 有機率向同一目標攻擊2次
-define(PSKILL_POISON,     202).    %% 毒撃 
-define(PSKILL_REVIVE,     205).    %% 天使加護: 有一定幾率複活
-define(PSKILL_ANGER,      214).    %% 憤怒: 攻擊時能獲取更多的怒氣值
-define(PSKILL_CALM,       207).    %% 破怒: 攻擊時會降低敵方的怒氣值
-define(PSKILL_LIFE_DRAIN, 206).    %% 吸血

%=============================================================================================
% special skill definition
%=============================================================================================

-define(SKILL_COMMON_ATTACK, 100001). %% 普通攻擊

%=============================================================================================
% type definition
%=============================================================================================
-type check_spec()   :: term().
-type camp()         :: att | def.
-type buff_settle()  :: pre | post.
-type buff_op()      :: add | remove.
-type buff_type()    :: att | ass.   %% attack type | assist type
-type buff_id()      :: integer().
-type battle_camp()  :: att | def.
-type battle_cmd()   :: {integer(), integer(), integer()}.

%=============================================================================================
% record definition
%=============================================================================================

-record(battle_start, %% startup information
	{
		mod,               %% pve, pvp...	 
	 	type      = 0,     %% 
		att_id,            %% Attacker's ID
		att_mer   = [],    %% Attacker's mercenary list
		def_id,            %% Defender's ID
		def_mer   = [],    %% Defender's Mercenary list
	 	monster,           %% MonsterID
		maketeam  = false, %% true | false
		checklist = [],    %% [check_spec()]
		caller,            %% caller module's name or pid
		callback           %% term()
	}
).

-record(battle_data,
	{
		mod,
		type = 0,
		procedure = [],
		attorder  = [],
		attacker,  %% list()
		defender,  %% list()
		att_buff,
		def_buff,
		player,    %% array()
	    timeout,   %% {LastTime, Timeout}
		monster,  
		round = 0,
		award,
		winner,    %% camp()
	    caller,   
	    callback,
		%%=============================================
		% statistic
		%%=============================================
		statistic
	}		
).

-record(battle_status,
	{
	 	id,
		name,	
		cat,
		job,
		level,
		star        = 0,
		skill       = [],
		p_skill     = [],
	 	hp,
		hp_max,
		mp          = 0,
		mp_max      = 100,
		p_att,
		m_att,
		p_def,
		m_def,
		speed       = 0,
		hit         = 100,
		dodge       = 100,
		crit        = 100,
		luck        = 100,
		agility     = 100,
		counter     = 100,
		block       = 100,
		buff        = [],
		cd          = [],
		cmd,
		damage_deal   = 0,
		damage_suffer = 0,
		is_lead, %%
		is_alive = true
	}		
).

-record(mon_group,
	{
	 	id,       %% monster group ID
		type,
		level,   
	 	pos,      %% [{MonsterID, Position}]
		pts,      %% Practice   军功
		items,    %% [{ItemID, DropRate, ItemCount}]
		exp	      %% Experience 经验
	}			
).

-record(mon_attr, 
	{
		id,
		name = "",
		cat,
		level = 1,
		hp,
		mp = 0,
		p_att,
		m_att,
		p_def,
		m_def,
		speed,
  		hit,			
 		dodge,	             %% 躲避
 		crit,		   
 		luck,                %% 幸运: 降低被攻击时触发暴击的可能性
		break, 	             %% 破甲: 目前作用不明
		agility,             %% 敏捷: 目前作用不明		
      	strength,       
		block = 0,
		counter,             %% 反击
      	spirit,              %% 元神
      	physique,            %% 体魄
      	godhood, 
      	att_count,
 		skills,
 		star = 0
	}			
).


-record(player_info,
	{
	 	id,                  %% ID
		pid,                 %% player pid
		finish_play = true,  %% true | false | quit :: quit is when client quit the battle(ask for clearing)
		online      = true,  %% true | false
		lead,
	 	mer_list
	}		
).

-record(buff,
	{
	 	name,                %% integer(), usually is a macro
		value = 0,           %% ?UNDEFINED | float() | integer()   %% some buff may not have value
		level = 1,         
		type,                %% buff_type()
		duration,            %% integer()
		settle = pre,        %% buff_settle()
		by_rate = ?UNDEFINED %% boolean()
	}		
).

-record(attack_spec,
	{
		targets,
		addition,
		attr_chg = [],
		buff_add = [], %% [#buff{}]                                                                                                                                                                                                              
		%% if hit, enemy carry this debuff list
		%% attacker carry this buff list
	 	debuff   = [], %% [{#buff{}, rate, buff_op()]
		buff     = []  %% [{#buff{}, Rate, buff_op}]
	}	
).

-record(assist_spec, 
	{
	 	pos, 
		rate = 1.0, 
		eff  = [], %% eff element = {type, value, byrate} 
		buff = []
	}		
).


%% every round produce a battle_pro
-record(battle_pro,
	{
	 	round = 0,
		is_last_round = false,
	 	attack_pro = []
	}		
).

%% every skill or action produce a attack_pro
-record(attack_pro,
	{
		is_miss,           %% at least hit one target
		pos,
		skillid,
		hp = 0,           %% final hp
		mp = 0,           %% final mp 
		hp_inc = 0,       %% hp affected by skill
		mp_inc = 0,       %% mp affected by skill  
	 	attack_info = [], %% attack
		buff_info   = []
	}			
).

%% attack_info describes an attack action
%% default to miss the target, so almost every field is zero
-record(attack_info,
	{
		pos,                %% skill target's position
		assist_pos = 0,     %% may be assist by other member
	 	is_miss    = true, %% is miss?
	 	is_crit    = false, %% is critical hit?
		hp         = 0,
		mp         = 0,
		hp_inc     = 0,     %% hp's incretement
		mp_inc     = 0,
		hp_absorb  = 0,     %% drained by attacker
		mp_absorb  = 0,     %% drained by attacker
		hp_rebound = 0,
		hp_counter = 0      %% counter strike
	}			
).

-record(buff_info,
	{
		settle    = pre,      %% pre | post
		name,
	 	owner     = 0,
		hp        = 0,
		mp        = 0,
		hp_inc    = 0,
		mp_inc    = 0,
		duration  = 0,
		is_new    = false,
		is_remove = false,
		by_rate   = false,
		value     = 0
	}		
).

-record(battle_award,
	{
		gold   = 0,
		silver = 0, 
		donate = 0,     %% guild donation   
		exp    = 0,        %% experience
		items  = []       %% dispatch list [{ID, ItemList}, ...]
	}		
).


-record(battle_result, 
	{
		is_win,			%% boolean()
		mon_id,         %% integer() | undefined
		type,           %% battle_type
		statistic,		%% #battle_statistic{}
	    callback
	}		
).


-record(battle_statistic,
	{
		max_damage_deal   = 100,         %% 
		max_damage_suffer = 100,         %% 
		round = 10
	}			
).


-record(battle_skill, 
	{
		id,                 %% integer(),
		level,              %% integer(),
	 	hp,                 %% integer() | float(),
		hp_by_rate = false, %% boolean()
	 	mp,                 %% integer(),
		cd,
		type,               %% super | common | passive
		target,             %% self  | friend | enemy
		param = {}
	}	
).










