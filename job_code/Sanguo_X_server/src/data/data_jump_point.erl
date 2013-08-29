-module(data_jump_point).

-compile(export_all).



%% 获取从哪个点跳转: get_from(FromScene, ToScene) -> PointInFromScene.
get_from(1000, 1100) -> {318, 183};

get_from(1000, 1300) -> {6, 183};

get_from(1000, 1500) -> {303, 33};

get_from(1100, 1000) -> {165, 146};

get_from(1100, 4000) -> {18, 18};

get_from(1300, 1000) -> {18, 18};

get_from(1500, 1000) -> {18, 18};

get_from(3100, 3100) -> {38, 61};

get_from(4000, 1100) -> {19, 18}.


%%================================================
%% 获取跳转到目的地图的哪个点: get_to(FromScene, ToScene) -> PointInToScene.
get_to(1000, 1100) -> {164, 147};

get_to(1000, 1300) -> {17, 17};

get_to(1000, 1500) -> {17, 17};

get_to(1100, 1000) -> {318, 184};

get_to(1100, 4000) -> {18, 18};

get_to(1300, 1000) -> {7, 183};

get_to(1500, 1000) -> {302, 34};

get_to(3100, 3100) -> {15, 64};

get_to(4000, 1100) -> {19, 18}.


%%================================================
%% 获取离开副本后的目的点
get_leave_dungeon(1200) -> {1000, 133, 98};

get_leave_dungeon(1400) -> {1000, 154, 87};

get_leave_dungeon(1600) -> {1000, 162, 117}.


%%================================================
%% 获取离开英雄塔后的目的点
get_leave_tower(3100) -> {1000, 295, 92}.


%%================================================
%% 获取离开boss场景的目的点
get_leave_boss_scene(3000) -> {1000, 113, 121}.


%%================================================