# Symbol comparison between Amiga and Megadrive verisons of Speedball II

The purpose of this file is to give a visualisation of how the version
share a lot of in-memory structure, how much code is re-used, and
where platform-specific code was used.

In essence, this file is a copy of my Amiga Speedball II reversed
symbol table, in address order, annotated with the locations and names
of the equivalent symbols in my reversing of the Megadrive edition.

In practice, I am including all of the symbols from the Megadrive
side, too, and doing my best to keep them ordered by memory
location. The main exceptions are for variables in RAM, which face
plenty of rearrangements to put them where they can be overwrriten on
the Megadrive, and big blocks of sprites, which are a) represented
differently on the different platforms (and hence subject to different
groupings) and b) are overlayed into the same locations at different
times on the Amiga. I try to highlight when these rearrangements
occur.

## Data

TODO: Finish. Explain.


| Name                                    | Location            | Type              |
|-----------------------------------------|---------------------|-------------------|
| contains_3460                           | 00000000            | Data Label        |
| reset_pc                                | 00000004            | Data Label        |
| cp_key                                  | 00000008            | Data Label        |
| cp_addr                                 | 0000000c            | Data Label        |
| trap_illegal_vector                     | 00000010            | Data Label        |
| trap_trace_vector                       | 00000024            | Data Label        |
| extra_mem                               | 00000028            | Data Label        |
| trap_line_f_vector                      | 0000002c            | Data Label        |
| INT2                                    | 00000068            | Data Label        |
| INT3                                    | 0000006c            | Data Label        |
| INT4                                    | 00000070            | Data Label        |
| maybe_serial                            | 00000080            | Data Label        |
| entry                                   | 00000084            | Instruction Label |
| mystery_word                            | 00000090            | Data Label        |
| screen_next_front                       | 00000092            | Data Label        |
| screen_next_back                        | 00000096            | Data Label        |
| screen_front                            | 0000009a            | Data Label        |
| screen_back                             | 000000a4            | Data Label        |
| active_palette                          | 000000a8            | Data Label        |
| frame_timer_l                           | 000000e8            | Data Label        |
| frame_timer_w                           | 000000ea            | Data Label        |
| frame_timer                             | 000000eb            | Data Label        |
| frame_timer_2                           | 000000ec            | Data Label        |
| high_data_loaded                        | 000000ee            | Data Label        |
| match_kind                              | 000000ef            | Data Label        |
| current_overlay                         | 000000f0            | Data Label        |
| palette_game                            | 000000f2            | Data Label        |
| palette_management_a                    | 00000132            | Data Label        |

| Amiga Name                   | Location | Type       | Megadrive Name            |          |
|------------------------------|----------|------------|---------------------------|----------|
| misc_flags                   | 00000172 | Data Label | misc_flags                | 00ff009a |
|                              |          |            | zapper_light_counter      | 00ff009b |
| ball_charge                  | 00000173 | Data Label | ball_charge               | 00ff009c |
| frames_per_tick              | 00000174 | Data Label | frames_per_tick           | 00ff009d |
| match_time_frames            | 00000175 | Data Label | match_time_frames         | 00ff009e |
| match_time_seconds           | 00000176 | Data Label | match_time_seconds        | 00ff009f |
| flicker_ticker               | 00000177 | Data Label | flicker_ticker            | 00ff00a0 |
| match_half                   | 00000178 | Data Label | match_half                | 00ff00a1 |
| initial_playing_direction    | 00000179 | Data Label | initial_playing_direction | 00ff00a2 |
| flicker_pattern              | 0000017a | Data Label | flicker_pattern           | 00ff00a4 |
| move_dir_to_facing_dir_array | 0000017e | Data Label |                           |          |
| x_origin                     | 0000018e | Data Label | x_origin                  | 00ff00a8 |
| y_origin                     | 00000190 | Data Label | y_origin                  | 00ff00aa |
| y_max                        | 00000192 | Data Label | y_max                     | 00ff00ac |
| score_team_up                | 00000196 | Data Label | score_team_up             | 00ff00ae |
| score_team_down              | 0000019a | Data Label | score_team_down           | 00ff00b2 |
| stars_ptr_p1                 | 0000019e | Data Label | stars_ptr_p1              | 00ff00b6 |
| stars_ptr_p2                 | 000001a2 | Data Label | stars_ptr_p2              | 00ff00ba |
| player_sprite_p1             | 000001a6 | Data Label | player_sprite_p1          | 00ff00be |
| player_sprite_p2             | 000001aa | Data Label | player_sprite_p2          | 00ff00c2 |
| green_lit_p1                 | 000001ae | Data Label | green_lit_p1              | 00ff00c6 |
| green_lit_p2                 | 000001b2 | Data Label | green_lit_p2              | 00ff00ca |
| player_last_with_ball        | 000001b6 | Data Label | player_last_with_ball     | 00ff00ce |
| player_with_ball             | 000001ba | Data Label | player_with_ball          | 00ff00d2 |
| injured_player               | 000001be | Data Label | injured_player            | 00ff00d6 |
| our_team                     | 000001c2 | Data Label | our_team                  | 00ff00da |
| other_team                   | 000001c6 | Data Label | other_team                | 00ff00de |
| our_team_for_stats           | 000001ca | Data Label | our_team_for_stats        | 00ff00e2 |
| other_team_for_stats         | 000001ce | Data Label | other_team_for_stats      | 00ff00e6 |
| current_team_info_table      | 000001d2 | Data Label | current_team_info_table   | 00ff00ea |
| current_team                 | 000001d6 | Data Label | current_team              | 00ff00ee |
| current_team_stats           | 000001da | Data Label | current_team_stats        | 00ff00f2 |
| current_controller_cooked    | 000001de | Data Label | current_controller_cooked | 00ff00f6 |
| cash_p1                      | 000001e2 | Data Label | cash_p1                   | 00ff00fa |
| cash_p2                      | 000001e4 | Data Label | cash_p2                   | 00ff00fc |
| match_cash_p1                | 000001e6 | Data Label | match_cash_p1             | 00ff00fe |
| match_cash_p2                | 000001e8 | Data Label | match_cash_p2             | 00ff0100 |
| match_cash_start             | 000001ea | Data Label | match_cash_start          | 00ff0102 |
| match_cash_max_base          | 000001ec | Data Label | match_cash_max_base       | 00ff0104 |
| match_cash_max_p1            | 000001ee | Data Label | match_cash_max_p1         | 00ff0106 |
| match_cash_max_p2            | 000001f0 | Data Label | match_cash_max_p2         | 00ff0108 |
| stars_lit_p1                 | 000001f4 | Data Label | stars_lit_p1              | 00ff010c |
| stars_lit_p2                 | 000001f5 | Data Label | stars_lit_p2              | 00ff010d |

| Amiga Name                          | Location | Type       | Megadrive Name                    | Location |
|-------------------------------------|----------|------------|-----------------------------------|----------|
|                                     |          |            | palette_gold_a                    | 00029e5e |
|                                     |          |            | palette_gold_b                    | 00029e7e |
|                                     |          |            | palette_gold_c                    | 00029e9e |
|                                     |          |            | palette_mono                      | 00029ebe |
|                                     |          |            | palette_management_a              | 00029ede |
|                                     |          |            | palette_management_b              | 00029efe |
|                                     |          |            | palette_magenta_a                 | 00029f1e |
|                                     |          |            | palette_magenta_b                 | 00029f3e |
|                                     |          |            | palette_backdrop_a                | 00029f5e |
|                                     |          |            | palette_backdrop_b                | 00029f7e |
|                                     |          |            | sprites_push_start                | 00029fde |
|                                     |          |            | move_dir_to_facing_dir_array      | 0002a0de |
| tackle_noises                       | 000001f6 | Data Label |                                   |          |
| reaction_time_table                 | 000001fa | Data Label | reaction_time_table               | 0002a0ee |
| position_lookahead_table            | 0000020a | Data Label | position_lookahead_table          | 0002a0fe |
| sustain_table                       | 0000022a | Data Label | sustain_table                     | 0002a11e |
| speed_level_1                       | 0000023a | Data Label | speed_level_1                     | 0002a12e |
| speed_level_2                       | 0000023b | Data Label | speed_level_2                     | 0002a12f |
| speed_level_3                       | 0000023c | Data Label | speed_level_3                     | 0002a130 |
| tackle_angle_modifier               | 0000024a | Data Label | tackle_angle_modifier             | 0002a13e |
| sliding_tackle_modifier             | 0000025a | Data Label | sliding_tackle_modifier           | 0002a14e |
| defense_jumping_modifier            | 0000026a | Data Label | defense_jumping_modifier          | 0002a15e |
| coin_value                          | 00000276 | Data Label |                                   |          |
| match_half_length_seconds           | 00000279 | Data Label |                                   |          |
| pitch_map                           | 0000027a | Data Label |                                   |          |
| team_sprite_mask                    | 0000193a | Data Label |                                   |          |
| switch_line                         | 0000193e | Data Label |                                   |          |
| sprite_y_32x32                      | 00001940 | Data Label |                                   |          |
| x_word_offset                       | 00001942 | Data Label |                                   |          |
| sprite_x                            | 00001944 | Data Label |                                   |          |
| sprite_y                            | 00001946 | Data Label |                                   |          |
| screen_idx                          | 00001948 | Data Label |                                   |          |
| dirty_map                           | 000019ea | Data Label |                                   |          |
| str_replay                          | 000025ca | Data Label | str_replay                        | 0002a16e |
| str_overlay_half_time               | 000025d6 | Data Label | str_overlay_half_time             | 0002a179 |
| str_000_to_000_half_time            | 000025e2 | Data Label |                                   |          |
| str_overlay_match_over              | 000025ef | Data Label | str_overlay_match_over            | 0002a186 |
| str_000_to_000_match_over           | 00002604 | Data Label |                                   |          |
| str_overlay_p1_scored               | 0000261e | Data Label | str_overlay_p1_scored             | 0002a1a9 |
| str_overlay_p2_scored               | 00002629 | Data Label | str_overlay_p2_scored             | 0002a1b4 |
| str_injured                         | 00002634 | Data Label |                                   |          |
| str_injured_1                       | 00002636 | Data Label |                                   |          |
| str_overlay_own_goal                | 0000264b | Data Label | str_overlay_own_goal              | 0002a1bf |
| str_goal                            | 00002657 | Data Label |                                   |          |
| str_goal_1                          | 00002660 | Data Label |                                   |          |
| str_overlay_vs                      | 00002662 | Data Label | str_overlay_vs                    | 0002a1cb |
| str_disk_error                      | 0000266b | Data Label | str_disk_error                    | 0002a1d4 |
| str_insert_game_disk                | 0000269c | Data Label |                                   |          |
| position_names                      | 000026b5 | Data Label | position_names                    | 0002a21e |
| text_overlay_counter                | 0000270f | Data Label |                                   |          |
| overlay_message                     | 00002710 | Data Label |                                   |          |
| last_x_origin                       | 00002714 | Data Label |                                   |          |
| str_speedball_2_top                 | 00002716 | Data Label | str_speedball_2                   | 0002a278 |
| str_speedball_2_bottom              | 00002725 | Data Label | str_speedball_2b                  | 0002a287 |
| str_next_fixture                    | 00002734 | Data Label | str_next_fixture                  | 0002a296 |
| str_press_fire                      | 00002743 | Data Label | str_push_start                    | 0002a2a5 |
| str_division_1                      | 00002750 | Data Label |                                   |          |
| str_division_2                      | 0000275d | Data Label |                                   |          |
| str_select_team                     | 0000276a | Data Label | str_select_team                   | 0002a2b2 |
| str_select_game                     | 00002779 | Data Label | str_select_game                   | 0002a2c1 |
| str_select_match_top                | 00002788 | Data Label | str_select_match                  | 0002a2d0 |
| strs_statistics                     | 00002797 | Data Label | str_statistics                    | 0002a2df |
| str_fixture_list                    | 000027a4 | Data Label | str_fixture_list                  | 0002a2ec |
| str_two_player                      | 000027b3 | Data Label | str_two_player                    | 0002a2fb |
| str_results                         | 000027c0 | Data Label | str_results                       | 0002a308 |
| str_save_game                       | 000027ca | Data Label | str_save_game                     | 0002a312 |
| str_load_game                       | 000027d7 | Data Label | str_load_game                     | 0002a31f |
| str_disk_error_top                  | 000027e4 | Data Label |                                   |          |
| str_replay_goals                    | 000027f1 | Data Label | str_replay_goals                  | 0002a339 |
|                                     |          |            | str_password                      | 0002a348 |
| str_disk_error_bottom               | 00002800 | Data Label |                                   |          |
| str_a_g                             | 0000280d | Data Label |                                   |          |
| str_h_o                             | 00002817 | Data Label |                                   |          |
| str_p_r                             | 00002822 | Data Label |                                   |          |
| str_0000_2                          | 00002828 | Data Label |                                   |          |
| title_replay_goals                  | 00002834 | Data Label | title_replay_goals                | 0002a35a |
| messages_speedball_2                | 0000283c | Data Label |                                   |          |
| title_speedball_2_push_start        | 00002844 | Data Label | title_speedball_2_push_start      | 0002a36a |
| title_next_fixture                  | 0000284c | Data Label | title_next_fixture                | 0002a372 |
| title_division_1                    | 00002854 | Data Label | title_division_1                  | 0002a37a |
| title_division_2                    | 0000285c | Data Label | title_division_2                  | 0002a382 |
| title_results                       | 00002864 | Data Label | title_results                     | 0002a38a |
| title_select_game                   | 00002874 | Data Label | title_select_game                 | 0002a39a |
| title_select_match                  | 0000287c | Data Label | title_select_match                | 0002a3a2 |
| title_statistics                    | 00002884 | Data Label | title_statistics                  | 0002a3aa |
| title_fixture_list                  | 0000288c | Data Label | title_fixture_list                | 0002a3b2 |
| title_two_player                    | 00002894 | Data Label | title_two_player                  | 0002a3ba |
| title_save_game                     | 0000289c | Data Label | title_save_game_password          | 0002a3c2 |
| title_load_game                     | 000028a4 | Data Label | title_load_game                   | 0002a3ca |
| title_disk_error                    | 000028ac | Data Label |                                   |          |
| str_no_players_on_the_market        | 000028b4 | Data Label | str_no_players_on_the_market      | 0002a3d2 |
| str_agr                             | 000028d0 | Data Label | str_agr                           | 0002a3ee |
| str_att                             | 000028d6 | Data Label | str_att                           | 0002a3f4 |
| str_def                             | 000028dc | Data Label | str_def                           | 0002a3fa |
| str_spd                             | 000028e2 | Data Label | str_spd                           | 0002a400 |
| str_thr                             | 000028e8 | Data Label | str_thr                           | 0002a406 |
| str_pow                             | 000028ee | Data Label | str_pow                           | 0002a40c |
| str_sta                             | 000028f4 | Data Label | str_sta                           | 0002a412 |
| str_int                             | 000028fa | Data Label | str_int                           | 0002a418 |
| str_000                             | 00002900 | Data Label |                                   |          |
| str_0000                            | 00002904 | Data Label |                                   |          |
| str_000_crd                         | 00002909 | Data Label |                                   |          |
| current_player_max_stats            | 00002912 | Data Label |                                   |          |
| attributes                          | 00002916 | Data Label | attributes                        | 0002a41e |
| attr_agr                            | 00002936 | Data Label | attr_agr                          | 0002a43e |
| attr_att                            | 0000293e | Data Label | attr_att                          | 0002a446 |
| attr_def                            | 00002946 | Data Label | attr_def                          | 0002a44e |
| attr_spd                            | 0000294e | Data Label | attr_spd                          | 0002a456 |
| attr_thr                            | 00002956 | Data Label | attr_thr                          | 0002a45e |
| attr_pow                            | 0000295e | Data Label | attr_pow                          | 0002a466 |
| attr_str                            | 00002966 | Data Label | attr_sta                          | 0002a46e |
| attr_int                            | 0000296e | Data Label | attr_int                          | 0002a476 |
| str_play                            | 00002976 | Data Label |                                   |          |
| str_next_fixture_top                | 0000298c | Data Label |                                   |          |
| str_next_fixture_title              | 000029bf | Data Label |                                   |          |
| str_next_fixture_sep_1              | 000029e0 | Data Label |                                   |          |
| str_played_won_drawn_lost_points    | 00002a13 | Data Label |                                   |          |
| str_pwdlp_nums                      | 00002a46 | Data Label |                                   |          |
| str_next_fixture_sep_2              | 00002a79 | Data Label |                                   |          |
| str_next_fixture_sep_3              | 00002aac | Data Label |                                   |          |
| str_league_placing                  | 00002adf | Data Label |                                   |          |
| str_points_for                      | 00002b12 | Data Label |                                   |          |
| str_points_against                  | 00002b45 | Data Label |                                   |          |
| str_defense                         | 00002b78 | Data Label |                                   |          |
| str_midfield                        | 00002bab | Data Label |                                   |          |
| str_attack                          | 00002bde | Data Label |                                   |          |
| str_substitutes                     | 00002c11 | Data Label |                                   |          |
| str_next_fixture_sep_4              | 00002c44 | Data Label |                                   |          |
| str_next_fixture_bottom             | 00002c77 | Data Label |                                   |          |
| str_empty                           | 00002d5e | Data Label |                                   |          |
| str_league_placings_top             | 00002d61 | Data Label |                                   |          |
| str_league_placings_header          | 00002d94 | Data Label |                                   |          |
| str_league_placings_separator       | 00002dc7 | Data Label |                                   |          |
| str_league_placings_bottom          | 00002dfa | Data Label |                                   |          |
| str_league_team_details             | 00002e2d | Data Label |                                   |          |
| str_statistics_edge                 | 00002e60 | Data Label |                                   |          |
| str_statistics_top                  | 00002e8c | Data Label |                                   |          |
| str_statistics_team_names           | 00002eb8 | Data Label |                                   |          |
| str_statistics_top_sep              | 00002ee4 | Data Label |                                   |          |
| str_statistics_separator            | 00002f10 | Data Label |                                   |          |
| str_statistics_bottom               | 00002f3c | Data Label |                                   |          |
| str_shots_at_goal                   | 00002f68 | Data Label |                                   |          |
| str_goals_scored                    | 00002f94 | Data Label |                                   |          |
| str_goals_saved                     | 00002fc0 | Data Label |                                   |          |
| str_time_in_possession              | 00002fec | Data Label |                                   |          |
| str_time_in_opponents_half          | 00003018 | Data Label |                                   |          |
| str_successful_tackles              | 00003044 | Data Label |                                   |          |
| str_substitutions                   | 00003070 | Data Label |                                   |          |
| str_bonus_points                    | 0000309c | Data Label |                                   |          |
| str_fixture_list_top                | 000030c8 | Data Label |                                   |          |
| str_fixture_list_entry              | 000030fb | Data Label |                                   |          |
| str_fixture_list_separator          | 00003119 | Data Label |                                   |          |
| str_fixture_list_bottom             | 0000314c | Data Label |                                   |          |
| str_results_top                     | 0000317f | Data Label |                                   |          |
| str_results_division_1              | 000031b2 | Data Label |                                   |          |
| str_results_table_top               | 000031d2 | Data Label |                                   |          |
| str_league_match_result             | 00003205 | Data Label |                                   |          |
| str_results_separator               | 00003238 | Data Label |                                   |          |
| str_results_bottom                  | 0000326b | Data Label |                                   |          |
| str_results_division_2              | 0000329e | Data Label |                                   |          |
| strings_next_fixture                | 000032be | Data Label | strings_next_fixture              | 0002a48e |
| strings_league_placings             | 00003356 | Data Label | strings_league_placings           | 0002a526 |
| strings_results                     | 000033a8 | Data Label | strings_results                   | 0002a578 |
| strings_statistics                  | 000033fe | Data Label | strings_statistics                | 0002a5ce |
| strings_fixture_list                | 00003454 | Data Label | strings_fixture_list              | 0002a624 |
| arrow_position                      | 000034a2 | Data Label |                                   |          |
| current_menu                        | 000034a4 | Data Label |                                   |          |
| str_menu_game_select                | 000034a8 | Data Label | str_menu_game_select              | 0002a672 |
| menu_arrows_game_type               | 000034e0 | Data Label | menu_game_type                    | 0002a69c |
| menu_select_match                   | 00003500 | Data Label |                                   |          |
| str_menu_single_player_game_type    | 0000350e | Data Label | str_menu_single_player_game_type  | 0002a6b4 |
| menu_single_player_game_type        | 00003530 | Data Label | menu_single_player_game_type      | 0002a6d6 |
| menu_select_game                    | 00003550 | Data Label |                                   |          |
| str_menu_new_manager_load           | 0000355e | Data Label | str_menu_new_manager_load         | 0002a6f6 |
| menu_arrows_new_manager_load        | 00003582 | Data Label | menu_new_manager_load             | 0002a71a |
| menu_select_one_three_five          | 0000359a | Data Label |                                   |          |
| str_menu_one_three_five             | 000035a8 | Data Label | str_menu_one_three_five           | 0002a732 |
| menu_arrows_one_three_five          | 000035d2 | Data Label | menu_one_three_five               | 0002a75c |
| menu_select_retry_cancel            | 000035ea | Data Label |                                   |          |
| str_menu_retry_cancel               | 000035f8 | Data Label |                                   |          |
| menu_arrows_retry_cancel            | 00003608 | Data Label |                                   |          |
| menu_select_new_load                | 00003618 | Data Label |                                   |          |
| str_new_game_load_game              | 00003626 | Data Label |                                   |          |
| menu_arrows_new_load                | 0000363c | Data Label |                                   |          |
| str_insert_game_save_disk           | 0000364c | Data Label | str_insert_goal_save              | 0002a794 |
| str_insert_goal_save_disk           | 0000366c | Data Label | str_insert_game                   | 0002a7b4 |
| str_insert_game_save_disk_2         | 0000368c | Data Label | str_menu_retry_cancel             | 0002a7cf |
| str_match                           | 000036a7 | Data Label | str_menu_new_load                 | 0002a7f0 |
| str_player_wins                     | 000036b1 | Data Label | menu_new_load                     | 0002a806 |
| str_player_0                        | 000036c1 | Data Label |                                   |          |
| str_round_one                       | 000036cc | Data Label | str_round_1                       | 0002a816 |
| str_round_two                       | 000036d8 | Data Label | str_round_2                       | 0002a822 |
| str_semi_final                      | 000036e4 | Data Label | str_semi_final                    | 0002a82e |
| str_grand_final                     | 000036f1 | Data Label | str_grand_final                   | 0002a83b |
| strings_cup_rounds                  | 00003700 | Data Label | strings_cup_rounds                | 0002a84a |
| str_promotion                       | 00003710 | Data Label |                                   |          |
| str_relegate                        | 0000371c | Data Label | str_relegate                      | 0002a866 |
| str_playoff                         | 00003729 | Data Label | str_playoff                       | 0002a873 |
| str_second_leg                      | 00003733 | Data Label | str_second_leg                    | 0002a87d |
| str_new_season                      | 00003740 | Data Label | str_new_season                    | 0002a88a |
|                                     |          |            | str_password_valid                | 0002a897 |
|                                     |          |            | str_password_wrong                | 0002a8a8 |
|                                     |          |            | str_cheat_mode                    | 0002a8b9 |
| str_total_score_win                 | 0000374d | Data Label |                                   |          |
| str_total_score_win_2               | 00003753 | Data Label |                                   |          |
| str_score                           | 00003772 | Data Label |                                   |          |
| str_total                           | 00003785 | Data Label |                                   |          |
| str_score_win                       | 00003798 | Data Label |                                   |          |
| str_blue_win                        | 000037b7 | Data Label | str_blue_win                      | 0002a8c6 |
| str_red_win                         | 000037c8 | Data Label | str_red_win                       | 0002a8d7 |
| str_match_drawn                     | 000037d8 | Data Label | str_match_drawn                   | 0002a8e7 |
| str_game_over                       | 000037e6 | Data Label | str_game_over                     | 0002a8f5 |
| str_replays_over                    | 000037f2 | Data Label | str_replays_over                  | 0002a901 |
| match_permutations                  | 00003801 | Data Label | match_permutations                | 0002a910 |
| division_displayed_start            | 00003839 | Data Label |                                   |          |
| cup_teams                           | 0000383a | Data Label |                                   |          |
| cup_teams_div2                      | 0000385a | Data Label |                                   |          |
| round_number                        | 0000387a | Data Label |                                   |          |
| num_matches                         | 0000387c | Data Label |                                   |          |
| cup_team_1                          | 0000387e | Data Label |                                   |          |
| cup_team_2                          | 00003880 | Data Label |                                   |          |
| round_num                           | 00003882 | Data Label |                                   |          |
| match_num                           | 00003884 | Data Label |                                   |          |
| num_management_rounds               | 00003886 | Data Label |                                   |          |
| num_buyable_players                 | 00003888 | Data Label |                                   |          |
| division_1                          | 0000388a | Data Label |                                   |          |
| division_1_rage_2000                | 000038a2 | Data Label |                                   |          |
| division_1_bottom                   | 000038a6 | Data Label |                                   |          |
| division_2                          | 000038aa | Data Label |                                   |          |
| division_2_damocles                 | 000038ae | Data Label |                                   |          |
| division_2_b                        | 000038ca | Data Label |                                   |          |
| division_1_b                        | 000038ea | Data Label |                                   |          |
| division_ptr                        | 0000390e | Data Label |                                   |          |
| results_div_1                       | 00003912 | Data Label |                                   |          |
| results_div_2                       | 00003922 | Data Label |                                   |          |
| results_ptr                         | 00003932 | Data Label |                                   |          |
| upgrade_bitmap_shades               | 00003936 | Data Label | upgrade_bitmap_shades             | 0002ab50 |
| upgrade_barge_pads                  | 00003948 | Data Label | upgrade_barge_pads                | 0002ab62 |
| upgrade_chest_guard                 | 0000395a | Data Label | upgrade_chest_guard               | 0002ab74 |
| upgrade_speed_boots                 | 0000396c | Data Label | upgrade_speed_boots               | 0002ab86 |
| upgrade_power_elbows                | 0000397e | Data Label | upgrade_power_elbows              | 0002ab98 |
| upgrade_power_gloves                | 00003990 | Data Label | upgrade_power_gloves              | 0002abaa |
| upgrade_thunder_thighs              | 000039a2 | Data Label | upgrade_thunder_thighs            | 0002abbc |
| upgrade_brain_boost                 | 000039b4 | Data Label | upgrade_brain_boost               | 0002abce |
| cp_junk                             | 000039c6 | Data Label |                                   |          |
| str_bitmap                          | 000039d2 | Data Label | str_bitmap                        | 0002abe0 |
| str_shades                          | 000039d9 | Data Label | str_shades                        | 0002abe7 |
| str_barge                           | 000039e0 | Data Label | str_barge                         | 0002abee |
| str_pads                            | 000039e6 | Data Label | str_pads                          | 0002abf4 |
| str_chest                           | 000039eb | Data Label | str_chest                         | 0002abf9 |
| str_guard                           | 000039f1 | Data Label | str_guard                         | 0002abff |
| str_speed                           | 000039f7 | Data Label | str_speed                         | 0002ac05 |
| str_boots                           | 000039fd | Data Label | str_boots                         | 0002ac0b |
| str_power                           | 00003a03 | Data Label | str_power                         | 0002ac11 |
| str_elbows                          | 00003a09 | Data Label | str_elbows                        | 0002ac17 |
| str_power_2                         | 00003a10 | Data Label | str_power2                        | 0002ac1e |
| str_gloves                          | 00003a16 | Data Label | str_gloves                        | 0002ac24 |
| str_thunder                         | 00003a1d | Data Label | str_thunder                       | 0002ac2b |
| str_thighs                          | 00003a25 | Data Label | str_thighs                        | 0002ac33 |
| str_brain                           | 00003a2c | Data Label | str_brain                         | 0002ac3a |
| str_boost                           | 00003a32 | Data Label | str_boost                         | 0002ac40 |
| upgrade_name_bitmap_shades          | 00003a38 | Data Label | upgrade_name_bitmap_shades        | 0002ac46 |
| upgrade_name_barge_pads             | 00003a50 | Data Label | upgrade_name_barge_pads           | 0002ac5e |
| upgrade_name_chest_guard            | 00003a68 | Data Label | upgrade_name_chest_guard          | 0002ac76 |
| upgrade_name_speed_boots            | 00003a80 | Data Label | upgrade_name_speed_boots          | 0002ac8e |
| upgrade_name_power_elbows           | 00003a98 | Data Label | upgrade_name_power_elbows         | 0002aca6 |
| upgrade_name_power_gloves           | 00003ab0 | Data Label | upgrade_name_power_gloves         | 0002acbe |
| upgrade_name_thunder_thighs         | 00003ac8 | Data Label | upgrade_name_thunder_thighs       | 0002acd6 |
| upgrade_name_brain_boost            | 00003ae0 | Data Label | upgrade_name_brain_boost          | 0002acee |
| str_not                             | 00003af8 | Data Label | str_not                           | 0002ad06 |
| str_enough                          | 00003afc | Data Label | str_enough                        | 0002ad0a |
| str_cash                            | 00003b03 | Data Label | str_cash                          | 0002ad11 |
| upgrade_name_not_enough_cash        | 00003b08 | Data Label | upgrade_name_not_enough_cash      | 0002ad16 |
| str_maximum                         | 00003b20 | Data Label | str_maximum                       | 0002ad2e |
| str_boost_2                         | 00003b28 | Data Label | str_boost2                        | 0002ad36 |
| str_already                         | 00003b2e | Data Label | str_already                       | 0002ad3c |
| upgrade_maximum_boost_already       | 00003b36 | Data Label | upgrade_maximum_boost_already     | 0002ad44 |
| upgrades_table                      | 00003b4e | Data Label | upgrades_table                    | 0002ad5c |
| buy_all_upgrades_table              | 00003b6e | Data Label | buy_all_upgrades_table            | 0002ad7c |
| armour_brain_boost                  | 00003b8e | Data Label | armour_brain_boost                | 0002ad9c |
| armour_barge_pads_1                 | 00003b94 | Data Label | armour_barge_pads_1               | 0002ada2 |
| armour_barge_pads_2                 | 00003b9a | Data Label | armour_barge_pads_2               | 0002ada8 |
| armour_power_elbows_1               | 00003ba0 | Data Label | armour_power_elbows_1             | 0002adae |
| armour_power_elbows_2               | 00003ba6 | Data Label | armour_power_elbows_2             | 0002adb4 |
| armour_speed_boots_5                | 00003bac | Data Label | armour_speed_boots_5              | 0002adba |
| armour_speed_boots_6                | 00003bb2 | Data Label | armour_speed_boots_6              | 0002adc0 |
| armour_thunder_thighs_1             | 00003bb8 | Data Label | armour_thunder_thighs_1           | 0002adc6 |
| armour_thunder_thighs_2             | 00003bbe | Data Label | armour_thunder_thighs_2           | 0002adcc |
| armour_speed_boots_1                | 00003bc4 | Data Label | armour_speed_boots_1              | 0002add2 |
| armour_speed_boots_2                | 00003bca | Data Label | armour_speed_boots_2              | 0002add8 |
| armour_speed_boots_3                | 00003bd0 | Data Label | armour_speed_boots_3              | 0002adde |
| armour_speed_boots_4                | 00003bd6 | Data Label | armour_speed_boots_4              | 0002ade4 |
| armour_chest_guard_1                | 00003bdc | Data Label | armour_chest_guard_1              | 0002adea |
| armour_chest_guard_2                | 00003be2 | Data Label | armour_chest_guard_2              | 0002adf0 |
| armour_power_gloves_1               | 00003be8 | Data Label | armour_power_gloves_1             | 0002adf6 |
| armour_power_gloves_2               | 00003bee | Data Label | armour_power_gloves_2             | 0002adfc |
| armour_body                         | 00003bf4 | Data Label |                                   |          |
| armour_bitmap_shades                | 00003bfa | Data Label | armour_bitmap_shades              | 0002ae08 |
| armours_barge_pads                  | 00003c00 | Data Label | armours_barge_pads                | 0002ae0e |
| armours_chest_guard                 | 00003c0c | Data Label | armours_chest_guard               | 0002ae1a |
| armours_speed_boots                 | 00003c18 | Data Label | armours_speed_boots               | 0002ae26 |
| armours_power_elbows                | 00003c34 | Data Label | armours_power_elbows              | 0002ae42 |
| armours_power_gloves                | 00003c40 | Data Label | armours_power_gloves              | 0002ae4e |
| armours_thunder_thighs              | 00003c4c | Data Label | armours_thunder_thighs            | 0002ae5a |
| armours_brain_boost                 | 00003c58 | Data Label | armours_brain_boost               | 0002ae66 |
| armours_bitmap_shades               | 00003c60 | Data Label | armours_bitmap_shades             | 0002ae6e |
| upgrade_y                           | 00003c68 | Data Label |                                   |          |
| upgrade_x                           | 00003c6a | Data Label |                                   |          |
| selected_upgrade_price              | 00003c6c | Data Label |                                   |          |
| selected_upgrade_name_string        | 00003c6e | Data Label |                                   |          |
| current_upgrade                     | 00003c72 | Data Label |                                   |          |
| selected_upgrade_armours            | 00003c76 | Data Label |                                   |          |
| previously_selected_upgrade_armours | 00003c7a | Data Label |                                   |          |
| selected_upgrade_stats_index        | 00003c7e | Data Label |                                   |          |
| current_keypad                      | 00003c80 | Data Label |                                   |          |
| keypad_y                            | 00003c84 | Data Label |                                   |          |
| keypad_x                            | 00003c86 | Data Label |                                   |          |
| selected_buy_mode                   | 00003c88 | Data Label |                                   |          |
| buy_index                           | 00003c8c | Data Label |                                   |          |
| player_grid_y                       | 00003c8e | Data Label |                                   |          |
| player_grid_x                       | 00003c90 | Data Label |                                   |          |
| player_grid_idx                     | 00003c92 | Data Label |                                   |          |
| player_table_x                      | 00003c94 | Data Label |                                   |          |
| player_table_y                      | 00003c96 | Data Label |                                   |          |
| team_info_table_offset              | 00003c98 | Data Label |                                   |          |
| player_grid_left                    | 00003c9a | Data Label | player_grid_left                  | 0002ae76 |
| player_grid_right                   | 00003cb2 | Data Label | player_grid_right                 | 0002ae8e |
| player_grid_up                      | 00003cca | Data Label | player_grid_up                    | 0002aea6 |
| player_grid_down                    | 00003ce2 | Data Label | player_grid_down                  | 0002aebe |
| selected_buy_mode_idx               | 00003cfa | Data Label |                                   |          |
| buy_mode_player                     | 00003cfc | Data Label | buy_mode_player                   | 0002aed6 |
| position_strings                    | 00003d0c | Data Label |                                   |          |
| buy_mode_group                      | 00003d3c | Data Label | buy_mode_group                    | 0002af16 |
| buy_mode_team                       | 00003d4c | Data Label | buy_mode_team                     | 0002af26 |
| buy_mode_transfer                   | 00003d5c | Data Label | buy_mode_transfer                 | 0002af36 |
| buy_mode_table                      | 00003d6c | Data Label | buy_mode_table                    | 0002af46 |
| manager_keypad_table                | 00003d7c | Data Label | manager_keypad_table              | 0002af56 |
| keypad_manager_transfer             | 00003dac | Data Label | keypad_manager_transfer           | 0002af86 |
| keypad_manager_noop                 | 00003db8 | Data Label | keypad_manager_noop               | 0002af92 |
| keypad_manager_exit                 | 00003dc4 | Data Label | keypad_manager_exit               | 0002af9e |
| keypad_manager_left                 | 00003dd0 | Data Label | keypad_manager_left               | 0002afaa |
| keypad_manager_table                | 00003ddc | Data Label | keypad_manager_table              | 0002afb6 |
| keypad_manager_gym                  | 00003de8 | Data Label | keypad_manager_gym                | 0002afc2 |
| keypad_manager_fixture              | 00003df4 | Data Label | keypad_manager_fixture            | 0002afce |
| keypad_manager_right                | 00003e00 | Data Label | keypad_manager_right              | 0002afda |
| keypad_manager_stats                | 00003e0c | Data Label | keypad_manager_stats              | 0002afe6 |
| keypad_manager_substitute           | 00003e18 | Data Label | keypad_manager_substitute         | 0002aff2 |
| transfer_keypad_table               | 00003e24 | Data Label | transfer_keypad_table             | 0002affe |
| keypad_transfer_noop_1              | 00003e54 | Data Label | keypad_transfer_noop_1            | 0002b02e |
| keypad_transfer_noop_2              | 00003e60 | Data Label | keypad_transfer_noop_2            | 0002b03a |
| keypad_transfer_exit                | 00003e6c | Data Label | keypad_transfer_exit              | 0002b046 |
| keypad_transfer_left                | 00003e78 | Data Label | keypad_transfer_left              | 0002b052 |
| keypad_transfer_noop_3              | 00003e84 | Data Label | keypad_transfer_noop_3            | 0002b05e |
| keypad_transfer_noop_4              | 00003e90 | Data Label | keypad_transfer_noop_4            | 0002b06a |
| keypad_transfer_fixture             | 00003e9c | Data Label | keypad_transfer_fixture           | 0002b076 |
| keypad_transfer_right               | 00003ea8 | Data Label | keypad_transfer_right             | 0002b082 |
| keypad_transfer_noop_5              | 00003eb4 | Data Label | keypad_transfer_noop_5            | 0002b08e |
| keypad_transfer_buy                 | 00003ec0 | Data Label | keypad_transfer_buy               | 0002b09a |
| gym_keypad_table                    | 00003ecc | Data Label | gym_keypad_table                  | 0002b0a6 |
| keypad_gym_player                   | 00003efc | Data Label | keypad_gym_player                 | 0002b0d6 |
| keypad_gym_noop                     | 00003f08 | Data Label | keypad_gym_noop                   | 0002b0e2 |
| keypad_gym_exit                     | 00003f14 | Data Label | keypad_gym_exit                   | 0002b0ee |
| keypad_gym_left                     | 00003f20 | Data Label | keypad_gym_left                   | 0002b0fa |
| keypad_gym_group                    | 00003f2c | Data Label | keypad_gym_group                  | 0002b106 |
| keypad_gym_buy_all                  | 00003f38 | Data Label | keypad_gym_buy_all                | 0002b112 |
| keypad_gym_next_fixture             | 00003f44 | Data Label | keypad_gym_next_fixture           | 0002b11e |
| keypad_gym_right                    | 00003f50 | Data Label | keypad_gym_right                  | 0002b12a |
| keypad_gym_team                     | 00003f5c | Data Label | keypad_gym_team                   | 0002b136 |
| keypad_gym_buy                      | 00003f68 | Data Label | keypad_gym_buy                    | 0002b142 |
| base_team_sprite_offsets            | 00003f74 | Data Label | base_team_sprite_offsets          | 0002b14e |
| base_team_names                     | 00003fb0 | Data Label | base_team_names                   | 0002b18a |
| green_lights_array                  | 00003fe0 | Data Label |                                   |          |
|                                     |          |            | armour_id_to_stat                 | 0002b1ba |
|                                     |          |            | powerup_fns                       | 0002b1c2 |
|                                     |          |            | powerdown_fns                     | 0002b1fe |
|                                     |          |            | pitch_blocks                      | 0002b23e |
|                                     |          |            | player_sprite_lookup              | 0002b9de |
|                                     |          |            | status_bar_mapping                | 0002bace |
| player_ball_offsets                 | 00003ff8 | Data Label | player_ball_offsets               | 0002bb6e |
| player_sprite_offsets               | 000040e2 | Data Label | player_sprite_offsets             | 0002bc58 |
| steps_multiplier_left_up            | 000042c2 | Data Label | steps_multiplier_left_up          | 0002bd48 |
| steps_multiplier_left_down          | 00004326 | Data Label | steps_multiplier_left_down        | 0002bdac |
| steps_multiplier_right_down         | 0000438a | Data Label | steps_multiplier_right_down       | 0002be10 |
| steps_multiplier_right_up           | 000043ee | Data Label | steps_multiplier_right_up         | 0002be74 |
| cfwd_support_point_lookup           | 00004452 | Data Label | cfwd_support_point_lookup         | 0002bed8 |
| wing_support_point_lookup           | 0000452a | Data Label | wing_support_point_lookup         | 0002bfb0 |
| armour_id_to_stat                   | 0000460b | Data Label |                                   |          |
| current_armour                      | 00004613 | Data Label |                                   |          |
| armour_pickups_left                 | 00004614 | Data Label |                                   |          |
| powerup_fns                         | 00004616 | Data Label |                                   |          |
| powerdown_fns                       | 00004652 | Data Label |                                   |          |
| powerup_seconds_remaining           | 00004692 | Data Label |                                   |          |
| active_powerup_id                   | 00004693 | Data Label |                                   |          |
| active_powerup_player               | 00004694 | Data Label |                                   |          |
| replay_buf                          | 00004698 | Data Label |                                   |          |
| replay_buf_end                      | 0000528c | Data Label |                                   |          |
| replay_buf_tail_ptr                 | 00005290 | Data Label |                                   |          |
| replay_buf_head_ptr                 | 00005294 | Data Label |                                   |          |
| replay_buf_tail_ptr_saved           | 00005298 | Data Label |                                   |          |
| opponent_directions                 | 0000529c | Data Label |                                   |          |
| score_team_1                        | 000052a0 | Data Label |                                   |          |
| score_team_2                        | 000052a2 | Data Label |                                   |          |
| bonus_points_p1                     | 000052a4 | Data Label |                                   |          |
| bonus_points_p2                     | 000052a6 | Data Label |                                   |          |
| cup_score_1                         | 000052a8 | Data Label |                                   |          |
| cup_score_2                         | 000052aa | Data Label |                                   |          |
| time_in_opponents_half_p1           | 000052ac | Data Label |                                   |          |
| time_in_opponents_half_p2           | 000052ae | Data Label |                                   |          |
| player_1_score                      | 000052b0 | Data Label |                                   |          |
| player_2_score                      | 000052b2 | Data Label |                                   |          |
| score_multiplier_p1                 | 000052b4 | Data Label |                                   |          |
| score_multiplier_p2                 | 000052b5 | Data Label |                                   |          |
| third_screen_pointer                | 000052ba | Data Label |                                   |          |
| next_ball_slowdown_time             | 000052be | Data Label |                                   |          |
| injury_state                        | 000052bf | Data Label |                                   |          |
| medibot_1_target_x                  | 000052c0 | Data Label |                                   |          |
| medibot_1_target_y                  | 000052c2 | Data Label |                                   |          |
| medibot_2_target_x                  | 000052c4 | Data Label |                                   |          |
| medibot_2_target_y                  | 000052c6 | Data Label |                                   |          |
| multiplier_origin_x                 | 000052c8 | Data Label |                                   |          |
| multiplier_origin_y                 | 000052ca | Data Label |                                   |          |
| multiplier_animation_ptr            | 000052cc | Data Label |                                   |          |
| multiplier_animation_step           | 000052d0 | Data Label |                                   |          |
| screen_row_offsets                  | 000052d2 | Data Label |                                   |          |
| div_10_table                        | 000054d2 | Data Label |                                   |          |
| screen_line_table                   | 000055d2 | Data Label |                                   |          |
| blit_fns_32x32_player_2             | 00005776 | Data Label |                                   |          |
| blit_fns_32x32_player_1             | 0000578a | Data Label |                                   |          |
| blit_fns_unused_1                   | 0000579e | Data Label |                                   |          |
| blit_fns_unused_2                   | 000057b2 | Data Label |                                   |          |
| blit_fns_32x32_no_mask              | 000057c6 | Data Label |                                   |          |
| blit_fns_16x16_masked               | 000057da | Data Label |                                   |          |
| blit_fns_16x16_no_mask              | 000057e6 | Data Label |                                   |          |
| start_positions                     | 000057f2 | Data Label |                                   |          |
| player_1_defense_1_stats            | 0000583a | Data Label |                                   |          |
| player_1_defense_2_stats            | 00005845 | Data Label |                                   |          |
| player_1_defense_3_stats            | 00005850 | Data Label |                                   |          |
| player_1_midfield_1_stats           | 0000585b | Data Label |                                   |          |
| player_1_midfield_2_stats           | 00005866 | Data Label |                                   |          |
| player_1_midfield_3_stats           | 00005871 | Data Label |                                   |          |
| player_1_attack_1_stats             | 0000587c | Data Label |                                   |          |
| player_1_attack_2_stats             | 00005887 | Data Label |                                   |          |
| player_1_attack_3_stats             | 00005892 | Data Label |                                   |          |
| player_1_subs_1_stats               | 0000589d | Data Label |                                   |          |
| player_1_subs_2_stats               | 000058a8 | Data Label |                                   |          |
| player_1_subs_3_stats               | 000058b3 | Data Label |                                   |          |
| player_2_defense_1_stats            | 000058be | Data Label |                                   |          |
| player_2_defense_2_stats            | 000058c9 | Data Label |                                   |          |
| player_2_defense_3_stats            | 000058d4 | Data Label |                                   |          |
| player_2_midfield_1_stats           | 000058df | Data Label |                                   |          |
| player_2_midfield_2_stats           | 000058ea | Data Label |                                   |          |
| player_2_midfield_3_stats           | 000058f5 | Data Label |                                   |          |
| player_2_attack_1_stats             | 00005900 | Data Label |                                   |          |
| player_2_attack_2_stats             | 0000590b | Data Label |                                   |          |
| player_2_attack_3_stats             | 00005916 | Data Label |                                   |          |
| player_2_subs_1_stats               | 00005921 | Data Label |                                   |          |
| player_2_subs_2_stats               | 0000592c | Data Label |                                   |          |
| player_2_subs_3_stats               | 00005937 | Data Label |                                   |          |
| player_temp_stats                   | 00005942 | Data Label |                                   |          |
| player_1_player_stats_table         | 0000594e | Data Label | player_1_player_stats_table       | 0002c888 |
| player_2_player_stats_table         | 0000597e | Data Label | player_2_player_stats_table       | 0002c8b8 |
| player_1_defense_1                  | 000059ae | Data Label |                                   |          |
| player_1_defense_2                  | 000059bc | Data Label |                                   |          |
| player_1_defense_3                  | 000059ca | Data Label |                                   |          |
| player_1_midfield_1                 | 000059d8 | Data Label |                                   |          |
| player_1_midfield_2                 | 000059e6 | Data Label |                                   |          |
| player_1_midfield_3                 | 000059f4 | Data Label |                                   |          |
| player_1_attack_1                   | 00005a02 | Data Label |                                   |          |
| player_1_attack_2                   | 00005a10 | Data Label |                                   |          |
| player_1_attack_3                   | 00005a1e | Data Label |                                   |          |
| player_1_subs_1                     | 00005a2c | Data Label |                                   |          |
| player_1_subs_2                     | 00005a3a | Data Label |                                   |          |
| player_1_subs_3                     | 00005a48 | Data Label |                                   |          |
| player_temp                         | 00005a56 | Data Label |                                   |          |
| team_info_table                     | 00005a64 | Data Label | team_info_table                   | 0002c8e8 |
| player_2_defense_1                  | 00005a94 | Data Label |                                   |          |
| player_2_defense_2                  | 00005aa2 | Data Label |                                   |          |
| player_2_defense_3                  | 00005ab0 | Data Label |                                   |          |
| player_2_midfield_1                 | 00005abe | Data Label |                                   |          |
| player_2_midfield_2                 | 00005acc | Data Label |                                   |          |
| player_2_midfield_3                 | 00005ada | Data Label |                                   |          |
| player_2_attack_1                   | 00005ae8 | Data Label |                                   |          |
| player_2_attack_2                   | 00005af6 | Data Label |                                   |          |
| player_2_attack_3                   | 00005b04 | Data Label |                                   |          |
| player_2_subs_1                     | 00005b12 | Data Label |                                   |          |
| player_2_subs_2                     | 00005b20 | Data Label |                                   |          |
| player_2_subs_3                     | 00005b2e | Data Label |                                   |          |
| team_info_table_other               | 00005b3c | Data Label | team_info_table_other             | 0002c918 |
| stats_jams                          | 00005b6c | Data Label |                                   |          |
| stats_norman                        | 00005b77 | Data Label |                                   |          |
| stats_caza                          | 00005b82 | Data Label |                                   |          |
| stats_weiss                         | 00005b8d | Data Label |                                   |          |
| stats_garrik                        | 00005b98 | Data Label |                                   |          |
| stats_roscopp                       | 00005ba3 | Data Label |                                   |          |
| stats_montez                        | 00005bae | Data Label |                                   |          |
| stats_shorn                         | 00005bb9 | Data Label |                                   |          |
| stats_quiss                         | 00005bc4 | Data Label |                                   |          |
| stats_quaid                         | 00005bcf | Data Label |                                   |          |
| stats_rocco                         | 00005bda | Data Label |                                   |          |
| stats_luthor                        | 00005be5 | Data Label |                                   |          |
| stats_jenson                        | 00005bf0 | Data Label |                                   |          |
| stats_cooper                        | 00005bfb | Data Label |                                   |          |
| stats_stavia                        | 00005c06 | Data Label |                                   |          |
| stats_midia                         | 00005c11 | Data Label |                                   |          |
| stats_seline                        | 00005c1c | Data Label |                                   |          |
| stats_bodini                        | 00005c27 | Data Label |                                   |          |
| player_jams                         | 00005c32 | Data Label |                                   |          |
| player_norman                       | 00005c44 | Data Label |                                   |          |
| player_caza                         | 00005c56 | Data Label |                                   |          |
| player_weiss                        | 00005c68 | Data Label |                                   |          |
| player_garrik                       | 00005c7a | Data Label |                                   |          |
| player_roscopp                      | 00005c8c | Data Label |                                   |          |
| player_montez                       | 00005c9e | Data Label |                                   |          |
| player_shorn                        | 00005cb0 | Data Label |                                   |          |
| player_quiss                        | 00005cc2 | Data Label |                                   |          |
| player_quaid                        | 00005cd4 | Data Label |                                   |          |
| player_rocco                        | 00005ce6 | Data Label |                                   |          |
| player_luthor                       | 00005cf8 | Data Label |                                   |          |
| player_jenson                       | 00005d0a | Data Label |                                   |          |
| player_cooper                       | 00005d1c | Data Label |                                   |          |
| player_stavia                       | 00005d2e | Data Label |                                   |          |
| player_midia                        | 00005d40 | Data Label |                                   |          |
| player_seline                       | 00005d52 | Data Label |                                   |          |
| player_bodini                       | 00005d64 | Data Label |                                   |          |
| players_market                      | 00005d76 | Data Label | players_market                    | 0002c948 |
| str_def_mid_fwd                     | 00005dbe | Data Label | str_def_mid_fwd                   | 0002c990 |
| str_jams                            | 00005dca | Data Label | str_jams                          | 0002c99c |
| str_norman                          | 00005dcf | Data Label | str_norman                        | 0002c9a1 |
| str_caza                            | 00005dd6 | Data Label | str_caza                          | 0002c9a8 |
| str_weiss                           | 00005ddb | Data Label | str_weiss                         | 0002c9ad |
| str_garrik                          | 00005de1 | Data Label | str_garrik                        | 0002c9b3 |
| str_roscopp                         | 00005de8 | Data Label | str_roscopp                       | 0002c9ba |
| str_montez                          | 00005df0 | Data Label | str_montez                        | 0002c9c2 |
| str_shorn                           | 00005df7 | Data Label | str_shorn                         | 0002c9c9 |
| str_quiss                           | 00005dfd | Data Label | str_quiss                         | 0002c9cf |
| str_quaid                           | 00005e03 | Data Label | str_quaid                         | 0002c9d5 |
| str_rocco                           | 00005e09 | Data Label | str_rocco                         | 0002c9db |
| str_luthor                          | 00005e0f | Data Label | str_luthor                        | 0002c9e1 |
| str_jenson                          | 00005e16 | Data Label | str_jenson                        | 0002c9e8 |
| str_cooper                          | 00005e1d | Data Label | str_cooper                        | 0002c9ef |
| str_stavia                          | 00005e24 | Data Label | str_stavia                        | 0002c9f6 |
| str_midia                           | 00005e2b | Data Label | str_midia                         | 0002c9fd |
| str_seline                          | 00005e31 | Data Label | str_seline                        | 0002ca03 |
| str_bodini                          | 00005e38 | Data Label | str_bodini                        | 0002ca0a |
| str_barry                           | 00005e3f | Data Label | str_barry                         | 0002ca11 |
| str_colin                           | 00005e45 | Data Label | str_colin                         | 0002ca17 |
| str_justin                          | 00005e4b | Data Label | str_justin                        | 0002ca1d |
| str_nigel                           | 00005e52 | Data Label | str_nigel                         | 0002ca24 |
| str_darren                          | 00005e58 | Data Label | str_darren                        | 0002ca2a |
| str_graham                          | 00005e5f | Data Label | str_graham                        | 0002ca31 |
| str_arnold                          | 00005e66 | Data Label | str_arnold                        | 0002ca38 |
| str_robin                           | 00005e6d | Data Label | str_robin                         | 0002ca3f |
| str_trevor                          | 00005e73 | Data Label | str_trevor                        | 0002ca45 |
| str_stuart                          | 00005e7a | Data Label | str_stuart                        | 0002ca4c |
| str_gordon                          | 00005e81 | Data Label | str_gordon                        | 0002ca53 |
| str_kevin                           | 00005e88 | Data Label | str_kevin                         | 0002ca5a |
| sprite_background_tile              | 00005e8e | Data Label |                                   |          |
| sprite_face                         | 00005eb6 | Data Label |                                   |          |
| sprite_char_2x2                     | 00005ede | Data Label |                                   |          |
| sprite_char_1x1                     | 00005f06 | Data Label |                                   |          |
| sprite_upgrade_lights               | 00005f2e | Data Label |                                   |          |
| sprite_upgrade                      | 00005f56 | Data Label |                                   |          |
| sprite_keypad                       | 00005f7e | Data Label |                                   |          |
| sprite_management_armour            | 00005fa6 | Data Label |                                   |          |
| sprite_ball                         | 00005fce | Data Label |                                   |          |
| sprite_ball_launcher                | 00005ff6 | Data Label |                                   |          |
| sprite_big_ball                     | 0000601e | Data Label |                                   |          |
| sprite_coin_1                       | 00006046 | Data Label |                                   |          |
| sprite_coin_2                       | 0000606e | Data Label |                                   |          |
| sprite_coin_3                       | 00006096 | Data Label |                                   |          |
| sprite_coin_4                       | 000060be | Data Label |                                   |          |
| sprite_power_up_1                   | 000060e6 | Data Label |                                   |          |
| sprite_power_up_2                   | 0000610e | Data Label |                                   |          |
| sprite_armour                       | 00006136 | Data Label |                                   |          |
| sprite_blue_player_marker           | 0000615e | Data Label |                                   |          |
| sprite_red_player_marker            | 00006186 | Data Label |                                   |          |
| sprite_status_bar                   | 000061ae | Data Label |                                   |          |
| sprite_score_multiplier_1           | 000061d6 | Data Label |                                   |          |
| sprite_score_multiplier_2           | 000061fe | Data Label |                                   |          |
| sprite_score_multiplier_3           | 00006226 | Data Label |                                   |          |
| sprite_score_multiplier_4           | 0000624e | Data Label |                                   |          |
| sprite_bumper_top                   | 00006276 | Data Label |                                   |          |
| sprite_bumper_bottom                | 000062a0 | Data Label |                                   |          |
| sprite_zapper_left                  | 000062ca | Data Label |                                   |          |
| sprite_zapper_right                 | 000062f4 | Data Label |                                   |          |
| sprite_player_1_defense_1           | 0000631e | Data Label |                                   |          |
| sprite_player_1_defense_2           | 00006390 | Data Label |                                   |          |
| sprite_player_1_defense_3           | 00006402 | Data Label |                                   |          |
| sprite_player_1_midfield_1          | 00006474 | Data Label |                                   |          |
| sprite_player_1_midfield_2          | 000064e6 | Data Label |                                   |          |
| sprite_player_1_midfield_3          | 00006558 | Data Label |                                   |          |
| sprite_player_1_attack_1            | 000065ca | Data Label |                                   |          |
| sprite_player_1_attack_2            | 0000663c | Data Label |                                   |          |
| sprite_player_1_attack_3            | 000066ae | Data Label |                                   |          |
| sprite_player_2_defense_1           | 00006720 | Data Label |                                   |          |
| sprite_player_2_defense_2           | 00006792 | Data Label |                                   |          |
| sprite_player_2_defense_3           | 00006804 | Data Label |                                   |          |
| sprite_player_2_midfield_1          | 00006876 | Data Label |                                   |          |
| sprite_player_2_midfield_2          | 000068e8 | Data Label |                                   |          |
| sprite_player_2_midfield_3          | 0000695a | Data Label |                                   |          |
| sprite_player_2_attack_1            | 000069cc | Data Label |                                   |          |
| sprite_player_2_attack_2            | 00006a3e | Data Label |                                   |          |
| sprite_player_2_attack_3            | 00006ab0 | Data Label |                                   |          |
| sprite_medibot_1                    | 00006b22 | Data Label |                                   |          |
| sprite_medibot_2                    | 00006b4a | Data Label |                                   |          |
| sprite_nowhere                      | 00006b72 | Data Label |                                   |          |
| blit_masks                          | 00006b9a | Data Label |                                   |          |
| sprites_table_player_1              | 00006bda | Data Label | sprites_table_player_1            | 0002ca60 |
| PTR_sprite_player_1_attack_3        | 00006bfa | Data Label |                                   |          |
| sprites_table_player_2              | 00006bfe | Data Label | sprites_table_player_2            | 0002ca84 |
| PTR_sprite_player_2_attack_3        | 00006c1e | Data Label |                                   |          |
| p1_multiplier_sprite_ptr            | 00006c22 | Data Label | p1_multiplier_sprite_ptr          | 0002caa8 |
| p2_multiplier_sprite_ptr            | 00006c26 | Data Label | p2_multiplier_sprite_ptr          | 0002caac |
| anim_ball_high_throw                | 00006c32 | Data Label | anim_ball_high_throw              | 0002cab8 |
| anim_ball_low_throw                 | 00006c94 | Data Label | anim_ball_low_throw               | 0002cb1a |
| anim_ball_being_caught              | 00006cb8 | Data Label | anim_ball_being_caught            | 0002cb3e |
| anim_ball_held                      | 00006cf4 | Data Label | anim_ball_held                    | 0002cb7a |
| anim_ball_on_multiplier             | 00006d2a | Data Label | anim_ball_on_multiplier           | 0002cbb0 |
| anim_ball_launch                    | 00006d8a | Data Label | anim_ball_launch                  | 0002cc10 |
| anim_ball_launcher                  | 00006dcc | Data Label | anim_ball_launcher                | 0002cc52 |
| anim_big_ball                       | 00006e1c | Data Label | anim_big_ball                     | 0002cca2 |
| anim_coin_spin                      | 00006e34 | Data Label | anim_coin_spin                    | 0002ccba |
| anim_standing_player_n              | 00006e66 | Data Label | anim_standing_player_n            | 0002ccec |
| anim_standing_player_ne             | 00006e6a | Data Label | anim_standing_player_ne           | 0002ccf0 |
| anim_standing_player_e              | 00006e6e | Data Label | anim_standing_player_e            | 0002ccf4 |
| anim_standing_player_se             | 00006e72 | Data Label | anim_standing_player_se           | 0002ccf8 |
| anim_standing_player_s              | 00006e76 | Data Label | anim_standing_player_s            | 0002ccfc |
| anim_standing_player_sw             | 00006e7a | Data Label | anim_standing_player_sw           | 0002cd00 |
| anim_standing_player_w              | 00006e7e | Data Label | anim_standing_player_w            | 0002cd04 |
| anim_standing_player_nw             | 00006e82 | Data Label | anim_standing_player_nw           | 0002cd08 |
| anims_sliding_player_n              | 00006e86 | Data Label | anims_sliding_player_n            | 0002cd0c |
| anims_sliding_player_ne             | 00006ea8 | Data Label | anims_sliding_player_ne           | 0002cd2e |
| anims_sliding_player_e              | 00006eca | Data Label | anims_sliding_player_e            | 0002cd50 |
| anims_sliding_player_se             | 00006eec | Data Label | anims_sliding_player_se           | 0002cd72 |
| anims_sliding_player_s              | 00006f0e | Data Label | anims_sliding_player_s            | 0002cd94 |
| anims_sliding_player_sw             | 00006f30 | Data Label | anims_sliding_player_sw           | 0002cdb6 |
| anims_sliding_player_w              | 00006f52 | Data Label | anims_sliding_player_w            | 0002cdd8 |
| anims_sliding_player_nw             | 00006f74 | Data Label | anims_sliding_player_nw           | 0002cdfa |
| anims_hitting_player_n              | 00006f96 | Data Label | anims_hitting_player_n            | 0002ce1c |
| anims_hitting_player_ne             | 00006fa0 | Data Label | anims_hitting_player_ne           | 0002ce26 |
| anims_hitting_player_e              | 00006faa | Data Label | anims_hitting_player_e            | 0002ce30 |
| anims_hitting_player_se             | 00006fb4 | Data Label | anims_hitting_player_se           | 0002ce3a |
| anims_hitting_player_s              | 00006fbe | Data Label | anims_hitting_player_s            | 0002ce44 |
| anims_hitting_player_sw             | 00006fc8 | Data Label | anims_hitting_player_sw           | 0002ce4e |
| anims_hitting_player_w              | 00006fd2 | Data Label | anims_hitting_player_w            | 0002ce58 |
| anims_hitting_player_nw             | 00006fdc | Data Label | anims_hitting_player_nw           | 0002ce62 |
| anims_move_player_n                 | 00006fe6 | Data Label | anims_move_player_n               | 0002ce6c |
| anims_move_player_ne                | 00006ff8 | Data Label | anims_move_player_ne              | 0002ce7e |
| anims_move_player_e                 | 0000700a | Data Label | anims_move_player_e               | 0002ce90 |
| anims_move_player_se                | 0000701c | Data Label | anims_move_player_se              | 0002cea2 |
| anims_move_player_s                 | 0000702e | Data Label | anims_move_player_s               | 0002ceb4 |
| anims_move_player_sw                | 00007040 | Data Label | anims_move_player_sw              | 0002cec6 |
| anims_move_player_w                 | 00007052 | Data Label | anims_move_player_w               | 0002ced8 |
| anims_move_player_nw                | 00007064 | Data Label | anims_move_player_nw              | 0002ceea |
| anims_throwing_player_n             | 00007076 | Data Label | anims_throwing_player_n           | 0002cefc |
| anims_throwing_player_ne            | 00007088 | Data Label | anims_throwing_player_ne          | 0002cf0e |
| anims_throwing_player_e             | 0000709a | Data Label | anims_throwing_player_e           | 0002cf20 |
| anims_throwing_player_se            | 000070ac | Data Label | anims_throwing_player_se          | 0002cf32 |
| anims_throwing_player_s             | 000070be | Data Label | anims_throwing_player_s           | 0002cf44 |
| anims_throwing_player_sw            | 000070d0 | Data Label | anims_throwing_player_sw          | 0002cf56 |
| anims_throwing_player_w             | 000070e2 | Data Label | anims_throwing_player_w           | 0002cf68 |
| anims_throwing_player_nw            | 000070f4 | Data Label | anims_throwing_player_nw          | 0002cf7a |
| anims_jumping_player_n              | 00007106 | Data Label | anims_jumping_player_n            | 0002cf8c |
| anims_jumping_player_ne             | 00007130 | Data Label | anims_jumping_player_ne           | 0002cfb6 |
| anims_jumping_player_e              | 0000715a | Data Label | anims_jumping_player_e            | 0002cfe0 |
| anims_jumping_player_se             | 00007184 | Data Label | anims_jumping_player_se           | 0002d00a |
| anims_jumping_player_s              | 000071ae | Data Label | anims_jumping_player_s            | 0002d034 |
| anims_jumping_player_sw             | 000071d8 | Data Label | anims_jumping_player_sw           | 0002d05e |
| anims_jumping_player_w              | 00007202 | Data Label | anims_jumping_player_w            | 0002d088 |
| anims_jumping_player_nw             | 0000722c | Data Label | anims_jumping_player_nw           | 0002d0b2 |
| anims_catching_player_n             | 00007256 | Data Label | anims_catching_player_n           | 0002d0dc |
| anims_catching_player_ne            | 0000725e | Data Label | anims_catching_player_ne          | 0002d0e4 |
| anims_catching_player_e             | 00007266 | Data Label | anims_catching_player_e           | 0002d0ec |
| anims_catching_player_se            | 0000726e | Data Label | anims_catching_player_se          | 0002d0f4 |
| anims_catching_player_s             | 00007276 | Data Label | anims_catching_player_s           | 0002d0fc |
| anims_catching_player_sw            | 0000727e | Data Label | anims_catching_player_sw          | 0002d104 |
| anims_catching_player_w             | 00007286 | Data Label | anims_catching_player_w           | 0002d10c |
| anims_catching_player_nw            | 0000728e | Data Label | anims_catching_player_nw          | 0002d114 |
| anim_tackled                        | 00007296 | Data Label | anim_tackled                      | 0002d11c |
| anim_lying_down                     | 000072de | Data Label | anim_lying_down                   | 0002d164 |
| anim_picked_up_injured              | 000072e2 | Data Label | anim_picked_up_injured            | 0002d168 |
| anim_goal_scored_dir_s              | 000072ea | Data Label | anim_goal_scored_dir_s            | 0002d170 |
| anim_goal_scored_dir_n              | 0000734c | Data Label | anim_goal_scored_dir_n            | 0002d1d2 |
| anim_goal_scored_dir_s_scorer       | 000073ae | Data Label | anim_goal_scored_dir_s_scorer     | 0002d234 |
| anim_goal_scored_dir_n_scorer       | 00007410 | Data Label | anim_goal_scored_dir_n_scorer     | 0002d296 |
| anims_diving_goalie_up_e            | 00007472 | Data Label | anims_diving_goalie_up_e          | 0002d2f8 |
| anims_diving_goalie_up_w            | 00007494 | Data Label | anims_diving_goalie_up_w          | 0002d31a |
| anims_goalie_diving_down_e          | 000074b6 | Data Label | anims_goalie_diving_down_e        | 0002d33c |
| anims_goalie_diving_down_w          | 000074d8 | Data Label | anims_goalie_diving_down_w        | 0002d35e |
| anim_medibot_dir_n                  | 000074fa | Data Label | anim_medibot_dir_n                | 0002d380 |
| anim_medibot_dir_ne                 | 000074fe | Data Label | anim_medibot_dir_ne               | 0002d384 |
| anim_medibot_dir_se                 | 00007502 | Data Label | anim_medibot_dir_se               | 0002d388 |
| anim_medibot_dir_s                  | 00007506 | Data Label | anim_medibot_dir_s                | 0002d38c |
| anim_medibot_dir_sw                 | 0000750a | Data Label | anim_medibot_dir_sw               | 0002d390 |
| anim_medibot_dir_nw                 | 0000750e | Data Label | anim_medibot_dir_nw               | 0002d394 |
| anim_medibot_dir_e                  | 00007512 | Data Label | anim_medibot_dir_e                | 0002d398 |
| anim_medibot_dir_w                  | 00007516 | Data Label | anim_medibot_dir_w                | 0002d39c |
| anim_medibot_pick_up_l              | 0000751a | Data Label | anim_medibot_pick_up_l            | 0002d3a0 |
| anim_medibot_pick_up_r              | 00007522 | Data Label | anim_medibot_pick_up_r            | 0002d3a8 |
| anim_standing_goalie_n              | 0000752a | Data Label | anim_standing_goalie_n            | 0002d3b0 |
| anims_move_goalie_up_side           | 0000752e | Data Label | anims_move_goalie_up_side         | 0002d3b4 |
| anims_catching_goalie_up_facing     | 00007540 | Data Label | anims_catching_goalie_up_facing   | 0002d3c6 |
| anim_standing_goalie_s              | 00007548 | Data Label | anim_standing_goalie_s            | 0002d3ce |
| anims_move_goalie_down_side         | 0000754c | Data Label | anims_move_goalie_down_side       | 0002d3d2 |
| anims_catching_goalie_down_facing   | 0000755e | Data Label | anims_catching_goalie_down_facing | 0002d3e4 |
| anims_move_goalie_up_s              | 00007566 | Data Label | anims_move_goalie_up_s            | 0002d3ec |
| anims_move_goalie_down_n            | 00007578 | Data Label | anims_move_goalie_down_n          | 0002d3fe |
| anim_zapper_left                    | 0000758a | Data Label |                                   |          |
| anim_zapper_right                   | 00007592 | Data Label |                                   |          |
| anim_bumper_light_up                | 0000759a | Data Label | anim_bumper_light_up              | 0002d410 |
| anims_standing_player               | 000075a2 | Data Label | anims_standing_player             | 0002d418 |
| anims_sliding_player                | 000075c2 | Data Label | anims_sliding_player              | 0002d438 |
| anims_hitting_player                | 000075e2 | Data Label | anims_hitting_player              | 0002d458 |
| anims_move_player                   | 00007602 | Data Label | anims_move_player                 | 0002d478 |
| anims_throwing_player               | 00007622 | Data Label | anims_throwing_player             | 0002d498 |
| anims_jumping_player                | 00007642 | Data Label | anims_jumping_player              | 0002d4b8 |
| anims_tackled                       | 00007662 | Data Label | anims_tackled                     | 0002d4d8 |
| anims_catching_player               | 00007682 | Data Label | anims_catching_player             | 0002d4f8 |
| anims_catching_goalie_up            | 000076a2 | Data Label | anims_catching_goalie_up          | 0002d518 |
| anims_catching_goalie_down          | 000076c2 | Data Label | anims_catching_goalie_down        | 0002d538 |
| anims_standing_goalie_up            | 000076e2 | Data Label | anims_standing_goalie_up          | 0002d558 |
| anims_move_goalie_up                | 00007702 | Data Label | anims_move_goalie_up              | 0002d578 |
| anims_standing_goalie_down          | 00007722 | Data Label | anims_standing_goalie_down        | 0002d598 |
| anims_move_goalie_down              | 00007742 | Data Label | anims_move_goalie_down            | 0002d5b8 |
| anims_diving_goalie_up              | 00007762 | Data Label | anims_diving_goalie_up            | 0002d5d8 |
| anims_diving_goalie_down            | 00007782 | Data Label | anims_goalie_diving_down          | 0002d5f8 |
| anim_goal_scored                    | 000077a2 | Data Label | anims_goal_scored                 | 0002d618 |
| anims_medibot                       | 000077e2 | Data Label | anims_medibot                     | 0002d658 |
| facing_direction_flip_x             | 00007802 | Data Label | facing_direction_flip_x           | 0002d678 |
| facing_direction_flip_y             | 0000780a | Data Label | facing_direction_flip_y           | 0002d680 |
| direction_to_velocity               | 00007812 | Data Label | direction_to_velocity             | 0002d688 |
| direction_to_velocity_1             | 00007832 | Data Label | direction_to_velocity_1           | 0002d6a8 |
| direction_to_velocity_2             | 00007852 | Data Label | direction_to_velocity_2           | 0002d6c8 |
| direction_to_velocity_3             | 00007872 | Data Label | direction_to_velocity_3           | 0002d6e8 |
| direction_to_velocity_4             | 00007892 | Data Label | direction_to_velocity_4           | 0002d708 |
| direction_to_velocity_5             | 000078b2 | Data Label | direction_to_velocity_5           | 0002d728 |
|                                     |          |            | direction_to_velocity_6           | 0002d748 |
| direction_to_velocity_7             | 000078f2 | Data Label | direction_to_velocity_7           | 0002d768 |
| direction_to_velocity_8             | 00007912 | Data Label | direction_to_velocity_8           | 0002d788 |
| str_player_1                        | 00007932 | Data Label |                                   |          |
| str_player_2                        | 0000793d | Data Label |                                   |          |
| str_brutal_deluxe                   | 00007948 | Data Label |                                   |          |
| str_revolver                        | 00007958 | Data Label |                                   |          |
| str_raw_messiahs                    | 00007963 | Data Label |                                   |          |
| str_violent_desire                  | 00007972 | Data Label |                                   |          |
| str_baroque                         | 00007983 | Data Label |                                   |          |
| str_the_renegades                   | 0000798d | Data Label |                                   |          |
| str_damocles                        | 0000799d | Data Label |                                   |          |
| str_steel_fury                      | 000079a8 | Data Label |                                   |          |
| str_powerhouse                      | 000079b5 | Data Label |                                   |          |
| str_rage_2000                       | 000079c2 | Data Label |                                   |          |
| str_mean_machine                    | 000079ce | Data Label |                                   |          |
| str_explosive_lords                 | 000079dd | Data Label |                                   |          |
| str_lethal_formula                  | 000079ef | Data Label |                                   |          |
| str_turbo_hammers                   | 00007a00 | Data Label |                                   |          |
| str_fatal_justice                   | 00007a10 | Data Label |                                   |          |
| str_super_nashwan                   | 00007a20 | Data Label |                                   |          |
| str_s_player_1                      | 00007a30 | Data Label |                                   |          |
| str_s_player_2                      | 00007a3c | Data Label |                                   |          |
| str_s_brutal_deluxe                 | 00007a48 | Data Label |                                   |          |
| str_s_revolver                      | 00007a55 | Data Label |                                   |          |
| str_s_raw_messiahs                  | 00007a61 | Data Label |                                   |          |
| str_s_violent_desire                | 00007a6d | Data Label |                                   |          |
| str_s_baroque                       | 00007a7a | Data Label |                                   |          |
| str_the_renegades                   | 00007a85 | Data Label |                                   |          |
| str_s_damocles                      | 00007a91 | Data Label |                                   |          |
| str_s_steel_fury                    | 00007a9d | Data Label |                                   |          |
| str_s_powerhouse                    | 00007aaa | Data Label |                                   |          |
| str_s_rage_2000                     | 00007ab7 | Data Label |                                   |          |
| str_s_mean_machine                  | 00007ac3 | Data Label |                                   |          |
| str_s_explosive_lords               | 00007ad0 | Data Label |                                   |          |
| str_s_lethal_formula                | 00007add | Data Label |                                   |          |
| str_s_turbo_hammers                 | 00007aea | Data Label |                                   |          |
| str_s_fatal_justice                 | 00007af7 | Data Label |                                   |          |
| str_s_super_nashwan                 | 00007b04 | Data Label |                                   |          |
| team_player_2                       | 00007b10 | Data Label |                                   |          |
| team_brutal_deluxe                  | 00007b50 | Data Label |                                   |          |
| team_revolver                       | 00007b90 | Data Label |                                   |          |
| team_raw_messiahs                   | 00007bd0 | Data Label |                                   |          |
| team_violent_desire                 | 00007c10 | Data Label |                                   |          |
| team_baroque                        | 00007c50 | Data Label |                                   |          |
| team_renegades                      | 00007c90 | Data Label |                                   |          |
| team_damocles                       | 00007cd0 | Data Label |                                   |          |
| team_steel_fury                     | 00007d10 | Data Label |                                   |          |
| team_powerhouse                     | 00007d50 | Data Label |                                   |          |
| team_rage_2000                      | 00007d90 | Data Label |                                   |          |
| team_mean_machine                   | 00007dd0 | Data Label |                                   |          |
| team_explosive_lords                | 00007e10 | Data Label |                                   |          |
| team_lethal_formula                 | 00007e50 | Data Label |                                   |          |
| team_turbo_hammers                  | 00007e90 | Data Label |                                   |          |
| team_fatal_justice                  | 00007ed0 | Data Label |                                   |          |
| team_super_nashwan                  | 00007f10 | Data Label |                                   |          |
| teams_all                           | 00007f50 | Data Label | teams_all                         | 0002d7a8 |
| teams_division_2                    | 00007f54 | Data Label | teams_division_2                  | 0002d7ac |
| teams_division_1                    | 00007f74 | Data Label | teams_division_1                  | 0002d7cc |
|                                     |          |            | sprites_password_font             | 0002d7ec |
|                                     |          |            | pitch_block_map                   | 0002e0ec |
|                                     |          |            | dot_array                         | 0002e3bc |
|                                     |          |            | sprite_fns_table                  | 0002e3fc |
|                                     |          |            | zeroes                            | 0002e460 |
|                                     |          |            | shift_masks                       | 0002e4e0 |
|                                     |          |            | maskify                           | 0002e520 |
|                                     |          |            | z80_code                          | 0002e620 |


## Code

The main code body is pretty simple to match up, since, unlike data,
it did not need to be rearranged to deal with the ROM/RAM split on the
Megadrive side, and the overlays on the Amiga side.

The Megadrive version places all its code at the start of the ROM,
with the exception of chunks of data that are used to initialise RAM,
that are situated next to the code that does the copying.

It's quite easy to see the regions where hardware details force
divergence - intialisation, save/load, graphics/blitting, interrupts,
compression and sound. I finish this section at the point where it
turns into purely Amiga-specific code.

| Amiga Name                              | Location | Type              | Megadrive Name                         | Location |
|-----------------------------------------|----------|-------------------|----------------------------------------|----------|
| start                                   | 00007f94 | Function          |                                        |          |
| preload_data                            | 00008056 | Function          |                                        |          |
| load_mgmt_data                          | 00008216 | Function          |                                        |          |
| load_game_data                          | 000082d6 | Function          |                                        |          |
| code_modifier                           | 0000836a | Data Label        |                                        |          |
| load_all_game_data                      | 0000838a | Function          |                                        |          |
| load_arena_data                         | 00008394 | Function          |                                        |          |
| load_overlay                            | 00008414 | Function          |                                        |          |
| init_bitmaps                            | 00008432 | Function          |                                        |          |
| init_noop                               | 000084a4 | Function          |                                        |          |
|                                         |          |                   | noop_interrupt_handler                 | 000000fc |
|                                         |          |                   | start                                  | 00000200 |
|                                         |          |                   | skip_init                              | 0000028c |
|                                         |          |                   | useful_constants                       | 0000028e |
|                                         |          |                   | hw_ptrs                                | 00000294 |
|                                         |          |                   | vdp_register_initialisation            | 000002a8 |
|                                         |          |                   | start2                                 | 000002fa |
|                                         |          |                   | dead_debugging                         | 00000312 |
|                                         |          |                   | vdp_address_set                        | 00000330 |
|                                         |          |                   | dead_set_palette                       | 0000034c |
|                                         |          |                   | dead_colour_mangle                     | 000003b8 |
|                                         |          |                   | dead_get_palette                       | 000003da |
|                                         |          |                   | controller_init                        | 00000412 |
|                                         |          |                   | vint                                   | 00000440 |
|                                         |          |                   | controller_read                        | 00000490 |
|                                         |          |                   | controller_presence_check              | 000004e6 |
|                                         |          |                   | z80_bus_request                        | 00000538 |
|                                         |          |                   | z80_bus_release                        | 00000560 |
|                                         |          |                   | z80_program                            | 0000058a |
|                                         |          |                   | z80_read                               | 000005f4 |
|                                         |          |                   | init_vars                              | 00000614 |
|                                         |          |                   | rom_block_1                            | 000007c4 |
|                                         |          |                   | rom_block_1_end                        | 000013b5 |
|                                         |          |                   | init_players_ram                       | 000013ba |
|                                         |          |                   | rom_block_2                            | 000013d4 |
|                                         |          |                   | rom_block_2_end                        | 00001850 |
|                                         |          |                   | init_sprites_ram                       | 00001850 |
|                                         |          |                   | rom_block_3                            | 00001872 |
|                                         |          |                   | rom_block_3_end                        | 000025a6 |
|                                         |          |                   | init_team_table                        | 000025a6 |
|                                         |          |                   | team_table_rom                         | 000025cc |
|                                         |          |                   | team_table_rom_end                     | 00002bea |
|                                         |          |                   | main                                   | 00002bea |
|                                         |          |                   | init_everything                        | 00002c2a |
|                                         |          |                   | no_op                                  | 00002c52 |
|                                         |          |                   | init_match_display                     | 00002c54 |
| init_tables                             | 000084a6 | Function          | init_tables                            | 00002c6c |
| init_line_table                         | 000084f0 | Function          |                                        |          |
| trap_f_2                                | 00008518 | Function          |                                        |          |
| init_player_mid_range_fields            | 0000851e | Function          | init_player_mid_range_fields           | 00002c9e |
| display_fade_out                        | 00008554 | Function          | display_fade_out                       | 00002cd6 |
| display_fade_in                         | 000085cc | Function          | display_fade_in                        | 00002d46 |
| wait_40ms                               | 00008654 | Function          | wait_40ms                              | 00002dde |
| display_fade_transition                 | 00008662 | Function          | dead_display_fade_in                   | 00002df0 |
| display_fade_transition_hide_status_bar | 000086ee | Function          |                                        |          |
| draw_menu_arrows                        | 00008786 | Function          | draw_menu_arrows                       | 00002e50 |
|                                         |          |                   | clear_menu_arrows                      | 00002e7a |
| shared_menu_function                    | 000087ae | Function          |                                        |          |
| init_team_players_names_and_sprites     | 00008894 | Function          | init_team_players_names_and_sprites    | 00002ea4 |
| main_menu                               | 000088c4 | Function          | main_menu                              | 00002edc |
| blit_screen_third_to_back               | 00008ad4 | Function          |                                        |          |
| blit_screen_front_to_back               | 00008ae4 | Function          | keypad_move_stub                       | 00003182 |
| copy_area_front_to_back                 | 00008afa | Function          |                                        |          |
| game_single_player                      | 00008b1c | Function          | game_single_player                     | 00003184 |
| game_practice                           | 00008b72 | Function          | game_practice                          | 000032ce |
| game_two_player                         | 00008bca | Function          | game_two_player                        | 0000330a |
| menu_one_three_five                     | 00008d84 | Function          | menu_one_three_five                    | 0000354e |
| gym_two_player                          | 00008d8e | Function          | gym_two_player                         | 00003634 |
| construct_league_placing_string         | 00008e52 | Function          | construct_league_placing_string        | 0000373a |
| update_league_placings                  | 00008ee0 | Function          | update_league_placings                 | 000037d6 |
| team_bubble_pass                        | 00008f36 | Function          | team_bubble_pass                       | 0000383a |
| display_league_placings                 | 00008f7c | Function          | display_league_placings                | 00003880 |
| display_league_placings_div_1           | 00008fca | Function          | display_league_placings_div_1          | 000038de |
| display_league_placings_div_2           | 00008fea | Function          | display_league_placings_div_2          | 0000390e |
| show_league_placings                    | 0000900e | Function          | show_league_placings                   | 00003940 |
| display_team_on_team_slot               | 0000908c | Function          | display_team_on_team_slot              | 000039cc |
| display_box_on_team_slot                | 000090d2 | Function          | display_box_on_team_slot               | 00003a1e |
| league_promote_relegate_announce        | 00009128 | Function          | league_promote_relegate_announce       | 00003a6e |
| league_promote_relegate                 | 00009178 | Function          | league_promote_relegate                | 00003ae2 |
| league_playoffs                         | 000091c4 | Function          | league_playoffs                        | 00003b32 |
| cup_league_match                        | 00009292 | Function          | cup_league_match                       | 00003c4c |
| cup_league_match_bd                     | 000092ee | Function          | cup_league_match_bd                    | 00003cc6 |
| game_league                             | 00009308 | Function          | game_league                            | 00003ce4 |
| league_season_middle                    | 00009466 | Function          | dead_league_season_middle              | 00003e74 |
| league_season                           | 00009482 | Function          | league_season                          | 00003e94 |
| league_round                            | 000094ae | Function          | league_round                           | 00003ec8 |
| display_league_results                  | 0000952c | Function          | display_league_results                 | 00003f60 |
| display_league_match_result             | 00009594 | Function          | display_league_match_result            | 00003fec |
| league_match                            | 000095f2 | Function          | league_match                           | 00004054 |
| set_league_teams                        | 00009616 | Function          | set_league_teams                       | 00004080 |
| menu_disk_error                         | 0000964e | Function          |                                        |          |
| keypad_manager_fn_save                  | 0000966a | Function          |                                        |          |
| write_cup_config                        | 0000972e | Function          |                                        |          |
| write_league_config                     | 0000974e | Function          |                                        |          |
| write_market                            | 00009762 | Function          |                                        |          |
| write_player_stats                      | 0000978c | Function          |                                        |          |
| write_teams                             | 000097a2 | Function          |                                        |          |
| write_player_stat                       | 000097e6 | Function          |                                        |          |
| save_league                             | 0000980a | Function          |                                        |          |
| save_cup                                | 00009860 | Function          |                                        |          |
|                                         |          |                   | init_save_buffer                       | 000040c4 |
|                                         |          |                   | do_save                                | 000040d6 |
|                                         |          |                   | write_upgrades_to_save_buffer          | 0000412a |
|                                         |          |                   | upgrade_weights                        | 0000417e |
|                                         |          |                   | write_players_to_save_buffer           | 0000418e |
|                                         |          |                   | reverse_lookup_player                  | 000041ae |
|                                         |          |                   | player_name_list                       | 000041d0 |
|                                         |          |                   | lookup_player                          | 00004248 |
|                                         |          |                   | sprite_index                           | 00004260 |
|                                         |          |                   | write_placings_to_save_buffer          | 0000429c |
|                                         |          |                   | teams_list                             | 000042b8 |
| do_load                                 | 000098b6 | Function          | do_load                                | 000042f8 |
| read_cup_config                         | 00009978 | Function          |                                        |          |
| read_league_config                      | 00009992 | Function          |                                        |          |
| read_market                             | 000099a0 | Function          |                                        |          |
| read_player_stats                       | 000099ca | Function          |                                        |          |
| read_teams                              | 000099e0 | Function          |                                        |          |
| read_player_stat                        | 00009a22 | Function          |                                        |          |
| load_league                             | 00009a46 | Function          |                                        |          |
| load_cup                                | 00009a96 | Function          |                                        |          |
|                                         |          |                   | read_players_from_save_buffer          | 00004360 |
|                                         |          |                   | read_placings_from_save_buffer         | 000043ba |
|                                         |          |                   | mark_players_bought                    | 0000441a |
|                                         |          |                   | check_cheat_modes                      | 00004458 |
|                                         |          |                   | check_cheat_mode                       | 00004486 |
|                                         |          |                   | cheat_easier_game                      | 000044e0 |
|                                         |          |                   | cheat_playtesters                      | 00004500 |
|                                         |          |                   | check_save                             | 00004520 |
|                                         |          |                   | display_password_state                 | 0000456c |
|                                         |          |                   | write_checksum_to_save_buffer          | 000045a0 |
|                                         |          |                   | init_save                              | 000045c6 |
|                                         |          |                   | write_to_save_buffer                   | 000045da |
|                                         |          |                   | read_from_save_buffer                  | 00004626 |
|                                         |          |                   | show_save_buffer                       | 00004662 |
|                                         |          |                   | enter_saved_state                      | 00004694 |
|                                         |          |                   | print_save_buffer                      | 0000485e |
|                                         |          |                   | draw_char_grid                         | 0000489c |
|                                         |          |                   | put_char                               | 000048d0 |
|                                         |          |                   | draw_xor_keyboard_square               | 000048fe |
|                                         |          |                   | update_text_cursor                     | 0000491c |
|                                         |          |                   | update_screen_save_state               | 00004962 |
|                                         |          |                   | put_char_save_state                    | 0000497c |
|                                         |          |                   | save_string_x_offset                   | 00004990 |
| league_new_game                         | 00009ae6 | Function          | league_new_game                        | 000049a0 |
| shuffle_league                          | 00009b10 | Function          | shuffle_league                         | 000049d0 |
| put_bd_first                            | 00009b42 | Function          | put_bd_first                           | 00004a02 |
| init_market                             | 00009b74 | Function          | init_market                            | 00004a34 |
| init_cup                                | 00009ba2 | Function          | init_cup                               | 00004a68 |
| league_menu                             | 00009bce | Function          | league_menu                            | 00004a9c |
| shuffle_half_league                     | 00009bd8 | Function          | shuffle_half_league                    | 00004b80 |
| shuffle_final_four                      | 00009c0a | Function          | shuffle_final_four                     | 00004bb2 |
| put_bd_first_2_divs                     | 00009c3c | Function          | put_bd_first_2_divs                    | 00004be4 |
| menu_new_load                           | 00009c6e | Function          | dead_menu_new_load                     | 00004c16 |
| game_cup                                | 00009c78 | Function          | game_cup                               | 00004cea |
| cup_match                               | 00009db4 | Function          | cup_match                              | 00004e76 |
| display_fixture_list                    | 00009e92 | Function          | display_fixture_list                   | 00004f9a |
| print_cup_fixture                       | 00009ee4 | Function          | print_cup_fixture                      | 00005008 |
| display_total_match_result              | 00009f30 | Function          | display_total_match_result             | 00005056 |
| total_victory                           | 00009fb4 | Function          | total_victory                          | 000050fa |
| total_defeat                            | 0000a026 | Function          | total_defeat                           | 00005160 |
| format_total_score                      | 0000a082 | Function          | format_total_score                     | 000051be |
| draw_total_string                       | 0000a096 | Function          | draw_total_string                      | 000051d6 |
| generate_team_total_stats               | 0000a0a6 | Function          | generate_team_total_stats              | 000051e8 |
| cup_league_match_not_bd                 | 0000a0d2 | Function          | cup_league_match_not_bd                | 00005214 |
| init_cup_teams_list                     | 0000a11e | Function          | init_cup_teams_list                    | 00005268 |
| game_knockout                           | 0000a134 | Function          | game_knockout                          | 00005282 |
| win_league                              | 0000a1b6 | Function          | win_league                             | 0000532a |
| win_shared                              | 0000a1ee | Function          |                                        |          |
| win_promo                               | 0000a22e | Function          | win_promo                              | 00005366 |
| win_cup                                 | 0000a266 | Function          | win_cup                                | 000053a2 |
| win_knockout                            | 0000a2a2 | Function          | win_knockout                           | 000053de |
| dead_select_team                        | 0000a2de | Function          | dead_select_team                       | 0000541a |
| load_replay_goals                       | 0000a338 | Function          | dead_replay_goal                       | 0000547e |
| load_replay_goal                        | 0000a3c8 | Function          | dead_load_replay_goal                  | 000054f8 |
| zero_screen                             | 0000a48a | Function          | dead_replay_goal_3                     | 000055aa |
| populate_opposition_player_stats        | 0000a49e | Function          | populate_opposition_player_stats       | 000055ac |
| populate_opposition_player_group_stats  | 0000a4c8 | Function          | populate_opposition_player_group_stats | 000055d6 |
| init_player_stats                       | 0000a4e6 | Function          | init_player_stats                      | 000055f4 |
| do_manager_screen                       | 0000a504 | Function          | do_manager_screen                      | 00005612 |
| update_market                           | 0000a590 | Function          | update_market                          | 000056c6 |
| do_player_grid                          | 0000a650 | Function          | do_player_grid                         | 00005798 |
| update_player_grid_idx                  | 0000a80e | Function          | update_player_grid_idx                 | 000059ba |
| draw_player_table_cursor                | 0000a820 | Function          | draw_player_table_cursor               | 000059d2 |
| undraw_player_table_cursor              | 0000a8a8 | Function          | undraw_player_table_cursor             | 00005a54 |
| do_transfer_screen                      | 0000a8e8 | Function          | do_transfer_screen                     | 00005a98 |
| do_gym_screen                           | 0000a92c | Function          | do_gym_screen                          | 00005ae8 |
| do_keypad                               | 0000aa9a | Function          | do_keypad                              | 00005c96 |
| keypad_fn_noop                          | 0000ac36 | Function          |                                        |          |
| keypad_transfer_fn_left                 | 0000ac52 | Function          | keypad_transfer_fn_left                | 00005e74 |
| previous_buyable_player                 | 0000ac90 | Function          | previous_buyable_player                | 00005e92 |
| keypad_transfer_fn_right                | 0000acb6 | Function          | keypad_transfer_fn_right               | 00005ec2 |
| next_buyable_player                     | 0000acf4 | Function          | next_buyable_player                    | 00005ee0 |
| keypad_fn_left                          | 0000ad28 | Function          | keypad_fn_left                         | 00005f22 |
| keypad_fn_right                         | 0000ad6a | Function          | keypad_fn_right                        | 00005f48 |
| keypad_manager_fn_table                 | 0000adb2 | Function          | keypad_manager_fn_table                | 00005f76 |
| keypad_manager_fn_gym                   | 0000adda | Function          | keypad_manager_fn_gym                  | 00005fa0 |
| keypad_manager_fn_transfer              | 0000adea | Function          | keypad_manager_fn_transfer             | 00005fb0 |
| keypad_manager_fn_fixture               | 0000ae02 | Function          | keypad_manager_fn_fixture              | 00005fca |
| keypad_manager_fn_stats                 | 0000ae0c | Function          | keypad_manager_fn_stats                | 00005fd4 |
| keypad_fn_gym_next_fixture              | 0000ae16 | Function          | keypad_fn_gym_next_fixture             | 00005fde |
| keypad_transfer_fn_fixture              | 0000ae20 | Function          | keypad_transfer_fn_fixture             | 00005fe8 |
| keypad_fn_exit                          | 0000ae2a | Function          | keypad_fn_exit                         | 00005ff2 |
| keypad_fn_gym_player                    | 0000ae2c | Function          | keypad_fn_gym_player                   | 00005ff4 |
| keypad_fn_gym_group                     | 0000ae78 | Function          | keypad_fn_gym_group                    | 0000601c |
| keypad_fn_gym_team                      | 0000aec6 | Function          | keypad_fn_gym_team                     | 00006046 |
| select_buy_mode                         | 0000af0c | Function          | select_buy_mode                        | 00006068 |
| keypad_fn_buy                           | 0000af22 | Function          | keypad_fn_buy                          | 00006086 |
| get_max_boost                           | 0000af8a | Function          | get_max_boost                          | 000060ca |
| buy_for_player                          | 0000b028 | Function          | buy_for_player                         | 0000616e |
| buy_for_group                           | 0000b0ce | Function          | buy_for_group                          | 0000623a |
| buy_for_team                            | 0000b11e | Function          | buy_for_team                           | 000062a4 |
| keypad_fn_gym_buy_all                   | 0000b160 | Function          | keypad_fn_gym_buy_all                  | 000062fe |
| dead_boost_cash                         | 0000b1b0 | Function          | dead_boost_cash                        | 00006364 |
| keypad_manager_fn_substitute            | 0000b1be | Function          | keypad_manager_fn_substitute           | 0000637c |
| find_market_player_position             | 0000b290 | Function          | find_market_player_position            | 0000643a |
| find_market_player                      | 0000b2a0 | Function          | find_market_player                     | 0000644a |
| get_player_value                        | 0000b2c6 | Function          | get_player_value                       | 00006472 |
| keypad_transfer_fn_buy                  | 0000b326 | Function          | keypad_transfer_fn_buy                 | 000064d8 |
| swap_bytes                              | 0000b3be | Function          | swap_bytes                             | 00006584 |
| draw_keypad_key_light                   | 0000b3ce | Function          | draw_keypad_key_light                  | 00006594 |
| draw_keypress_pressed_key               | 0000b418 | Function          | draw_keypress_pressed_key              | 000065e4 |
| draw_keypad                             | 0000b46c | Function          | draw_keypad                            | 0000663c |
| activate_current_upgrade_light          | 0000b4da | Function          | activate_current_upgrade_light         | 000066ac |
| deactivate_all_upgrade_lights           | 0000b538 | Function          | deactivate_all_upgrade_lights          | 00006712 |
| select_current_upgrade                  | 0000b584 | Function          | select_current_upgrade                 | 00006760 |
| set_selected_upgrade_variables          | 0000b5c6 | Function          | set_selected_upgrade_variables         | 00006774 |
| copy_monitor_front_to_back              | 0000b5e4 | Function          |                                        |          |
| copy_cash_front_to_back                 | 0000b5f2 | Function          |                                        |          |
| copy_upgrade_description_front_to_back  | 0000b602 | Function          |                                        |          |
| copy_armour_front_to_back               | 0000b610 | Function          |                                        |          |
| display_selected_upgrade_description    | 0000b622 | Function          | display_selected_upgrade_description   | 0000679c |
| highlight_armour_aux                    | 0000b696 | Function          | highlight_armour_aux                   | 00006818 |
| highlight_armour                        | 0000b6dc | Function          | highlight_armour                       | 00006866 |
| draw_plays                              | 0000b726 | Function          | draw_plays                             | 000068ac |
| format_5_decimal_digits                 | 0000b75e | Function          | format_5_decimal_digits                | 000068ea |
| format_4_decimal_digits                 | 0000b762 | Function          | format_4_decimal_digits                | 000068ee |
| format_3_decimal_digits                 | 0000b766 | Function          | format_3_decimal_digits                | 000068f2 |
| format_2_decimal_digits                 | 0000b76a | Function          | format_2_decimal_digits                | 000068f6 |
| format_decimal_digit                    | 0000b76e | Function          | format_decimal_digit                   | 000068fa |
| generate_group_stats                    | 0000b784 | Function          | generate_group_stats                   | 00006910 |
| generate_team_stats                     | 0000b7b6 | Function          | generate_team_stats                    | 00006942 |
| average_8                               | 0000b7f8 | Function          | average_8                              | 00006988 |
| generate_team_fixture_strings           | 0000b80e | Function          | generate_team_fixture_strings          | 0000699e |
| generate_fixture_strings                | 0000b94a | Function          | generate_fixture_strings               | 00006af4 |
| display_next_fixture                    | 0000b960 | Function          | display_next_fixture                   | 00006b0e |
| sum_team_stat                           | 0000b992 | Function          | sum_team_stat                          | 00006b54 |
| stats_format_decimal                    | 0000b9ac | Function          | stats_format_decimal                   | 00006b6e |
| write_team_statistics                   | 0000b9b4 | Function          | write_team_statistics                  | 00006b76 |
| display_statistics                      | 0000ba0a | Function          | display_statistics                     | 00006bd8 |
| draw_string_list                        | 0000baaa | Function          | draw_string_list                       | 00006ca8 |
| substitute_player                       | 0000bacc | Function          | substitute_player                      | 00006cca |
| round_player_stats                      | 0000bb5a | Function          | round_player_stats                     | 00006d60 |
| copy_player                             | 0000bb7a | Function          | copy_player                            | 00006d80 |
| show_title                              | 0000bba0 | Function          | show_title                             | 00006da6 |
| display_screen_block                    | 0000bbde | Function          | display_screen_block                   | 00006de0 |
| draw_attribute_strings                  | 0000bbf8 | Function          | draw_attribute_strings                 | 00006e12 |
| draw_manager_screen                     | 0000bc20 | Function          | draw_manager_screen                    | 00006e3c |
| draw_transfer_screen                    | 0000bc7a | Function          | draw_transfer_screen                   | 00006ea8 |
| draw_gym_screen                         | 0000bd06 | Function          | draw_gym_screen                        | 00006f4e |
| redraw_cash                             | 0000bd6e | Function          | redraw_cash                            | 00006fc8 |
| draw_stats                              | 0000bdb8 | Function          | draw_stats                             | 00007016 |
| draw_buying_player_stats                | 0000be70 | Function          | draw_buying_player_stats               | 000070d0 |
| draw_buying_group_stats                 | 0000beb0 | Function          | draw_buying_group_stats                | 0000711a |
| draw_buying_team_stats                  | 0000becc | Function          | draw_buying_team_stats                 | 0000713c |
| draw_player_to_buy_stats                | 0000bee2 | Function          | draw_player_to_buy_stats               | 00007156 |
| draw_box_colour                         | 0000bf06 | Function          |                                        |          |
| draw_current_buyable                    | 0000bf22 | Function          | draw_current_buyable                   | 00007182 |
| clear_buying_text                       | 0000bf70 | Function          | clear_buying_text                      | 000071ce |
| draw_buying_player                      | 0000bf84 | Function          | draw_buying_player                     | 000071de |
| draw_buying_group                       | 0000c036 | Function          | draw_buying_group                      | 0000729c |
| draw_buying_team                        | 0000c054 | Function          | draw_buying_team                       | 000072bc |
| draw_player_to_buy                      | 0000c06a | Function          | draw_player_to_buy                     | 000072d2 |
| draw_player_table                       | 0000c0f2 | Function          | draw_player_table                      | 00007362 |
| draw_player_name_for_table              | 0000c138 | Function          | draw_player_name_for_table             | 000073b0 |
| draw_face                               | 0000c1c4 | Function          | draw_face                              | 00007438 |
| draw_group_logo                         | 0000c22a | Function          | draw_group_logo                        | 000074b6 |
| player_sprites_to_start_positions       | 0000c2aa | Function          | player_sprites_to_start_positions      | 00007534 |
| play_match                              | 0000c2d0 | Function          | play_match                             | 000075b6 |
|                                         |          |                   | do_cheat                               | 000079cc |
|                                         |          |                   | do_cheat_playtest                      | 00007a12 |
|                                         |          |                   | do_cheat_easier_game                   | 00007a60 |
| display_string                          | 0000c650 | Function          | display_string                         | 00007b10 |
| display_2x2_char                        | 0000c694 | Function          |                                        |          |
| display_string_space                    | 0000c6c8 | Function          |                                        |          |
| draw_management_background              | 0000c6d8 | Function          | draw_management_background             | 00007b54 |
| draw_mgmt_bkgnd_tile                    | 0000c70c | Function          |                                        |          |
| draw_mgmt_bkgnd_step_coords             | 0000c72e | Function          |                                        |          |
| draw_string                             | 0000c744 | Function          | draw_string                            | 00007bf2 |
| draw_char                               | 0000c788 | Function          | draw_char                              | 00007c2e |
| expand_char                             | 0000c7c8 | Function          |                                        |          |
| advance_cursor                          | 0000c7e2 | Function          | advance_cursor                         | 00007c84 |
| draw_string_alt                         | 0000c7f2 | Function          | draw_string_alt                        | 00007c94 |
| draw_char_alt                           | 0000c82e | Function          | draw_char_alt                          | 00007cc4 |
| draw_string_pixel                       | 0000c86a | Function          | draw_string_pixel                      | 00007d18 |
| draw_char_pixel                         | 0000c8ae | Function          | draw_char_pixel                        | 00007d50 |
| move_next_char_small                    | 0000c8e8 | Function          | move_next_char_small                   | 00007da2 |
| format_score_win                        | 0000c8ec | Function          | format_score_win                       | 00007da6 |
| load_victory                            | 0000c8fe | Function          |                                        |          |
| load_defeat                             | 0000c936 | Function          |                                        |          |
| victory                                 | 0000c96e | Function          | victory                                | 00007dba |
| defeat                                  | 0000c9de | Function          | defeat                                 | 00007e2e |
| display_match_result                    | 0000ca3a | Function          | display_match_result                   | 00007e8c |
| draw_score_string                       | 0000cabe | Function          | draw_score_string                      | 00007f2e |
| format_score_string                     | 0000cace | Function          | format_score_string                    | 00007f40 |
| update_match_stats                      | 0000cae4 | Function          | update_match_stats                     | 00007f5a |
| clear_match_stats                       | 0000cb70 | Function          | clear_match_stats                      | 00007fee |
| wait_no_keypress                        | 0000cb92 | Function          | wait_no_keypress                       | 00008012 |
|                                         |          |                   | wait_any_abcs_pressed                  | 00008014 |
| wait_any_fire_pressed_timeout           | 0000cbb8 | Function          | wait_any_abcs_2s                       | 00008034 |
|                                         |          |                   | wait_no_buttons                        | 0000806c |
| wait_fire_pressed                       | 0000cc28 | Function          | wait_any_abcs_down                     | 00008082 |
| init_screen_status_bar                  | 0000cc74 | Function          |                                        |          |
| expand_320_to_336                       | 0000ccd8 | Function          |                                        |          |
| draw_xor_vertical_line                  | 0000ccf0 | Function          | dead_replay_goal_4                     | 00008098 |
| draw_xor_horizontal_line                | 0000ccfc | Function          |                                        |          |
| draw_xor_square                         | 0000cd08 | Function          |                                        |          |
| xor_mode                                | 0000cd38 | Data Label        |                                        |          |
| target_screen_buffer                    | 0000cd3a | Data Label        |                                        |          |
| draw_colour_h_line                      | 0000cd3e | Function          |                                        |          |
| draw_colour_h_line_bitplane             | 0000cd98 | Function          |                                        |          |
| draw_sub_byte_hline                     | 0000cdea | Function          |                                        |          |
| draw_colour_vertical_line               | 0000ce20 | Function          |                                        |          |
| step_match                              | 0000cf10 | Function          | step_match                             | 0000809a |
| match_tick                              | 0000d052 | Function          | match_tick                             | 00008208 |
|                                         |          |                   | set_monitor_overlay                    | 00008248 |
|                                         |          |                   | add_monitor_overlay                    | 000082e4 |
| build_text_overlay                      | 0000d0f2 | Function          | build_text_overlay                     | 00008326 |
| draw_text_overlay                       | 0000d22e | Function          | draw_text_overlay                      | 0000845e |
| draw_overlay_char                       | 0000d26e | Function          | draw_overlay_char                      | 000084a0 |
| green_light_active_player               | 0000d2bc | Function          | green_light_active_player              | 000084fa |
| draw_status_bar_position                | 0000d3a8 | Function          |                                        |          |
| clear_status_green_lights               | 0000d402 | Function          | clear_status_green_lights              | 000085c0 |
|                                         |          |                   | draw_status_bar_position               | 000085fe |
| draw_health_meter                       | 0000d476 | Function          | draw_health_meter                      | 0000868c |
| draw_health_meter_blue                  | 0000d49a | Function          |                                        |          |
| draw_health_meter_blue_word             | 0000d4b2 | Function          |                                        |          |
| draw_health_meter_red                   | 0000d502 | Function          |                                        |          |
| draw_health_meter_red_word              | 0000d51a | Function          |                                        |          |
|                                         |          |                   | draw_health_meter_aux                  | 000086c2 |
|                                         |          |                   | health_bar_masks_p1                    | 00008730 |
|                                         |          |                   | health_bar_masks_p2                    | 00008754 |
| update_match_time                       | 0000d576 | Function          | update_match_time                      | 00008778 |
| check_all_stars_lit                     | 0000d682 | Function          | check_all_stars_lit                    | 000088c6 |
| update_time_stats                       | 0000d6e0 | Function          | update_time_stats                      | 00008924 |
| display_time                            | 0000d71c | Function          |                                        |          |
| step_prepare_ball_launch                | 0000d73c | Function          | step_prepare_ball_launch               | 0000896e |
| step_ball_launch                        | 0000d816 | Function          | step_ball_launch                       | 00008a62 |
| step_slow_ball                          | 0000d89a | Function          | step_slow_ball                         | 00008ae2 |
| update_players_location_info            | 0000d95e | Function          | update_players_location_info           | 00008bb2 |
| update_player_location_info             | 0000d992 | Function          | update_player_location_info            | 00008bea |
| update_active_players                   | 0000d9aa | Function          | update_active_players                  | 00008c0a |
| select_active_player                    | 0000d9ea | Function          | select_active_player                   | 00008c5c |
| calculate_player_distances              | 0000da02 | Function          | calculate_player_distances             | 00008c74 |
| update_offscreen_bit                    | 0000da5e | Function          | update_offscreen_bit                   | 00008cd6 |
| is_point_offscreen                      | 0000daa0 | Function          | is_point_offscreen                     | 00008d1c |
| distance_to_point                       | 0000daca | Function          | distance_to_point                      | 00008d4a |
| vector_length                           | 0000daf6 | Function          | vector_length                          | 00008d76 |
| handle_score_goal                       | 0000db22 | Function          | handle_score_goal                      | 00008da2 |
| goal_sound_function                     | 0000dc8c | Function          |                                        |          |
| award_points                            | 0000dcca | Function          | award_points                           | 00008f3e |
| play_sound_downwards                    | 0000dd30 | Function          |                                        |          |
| step_start_multiplier                   | 0000dd60 | Function          | step_start_multiplier                  | 00008fae |
| change_score_multiplier                 | 0000df02 | Function          | change_score_multiplier                | 00009188 |
| step_run_multiplier                     | 0000dfe8 | Function          | step_run_multiplier                    | 00009288 |
| step_warp                               | 0000e072 | Function          | step_warp                              | 00009324 |
| step_stars                              | 0000e118 | Function          | step_stars                             | 000093d0 |
| stars_light_p1                          | 0000e200 | Function          | stars_light_p1                         | 000094cc |
| stars_light_p2                          | 0000e28c | Function          | stars_light_p2                         | 00009516 |
| stars_unlight_p1                        | 0000e318 | Function          | stars_unlight_p1                       | 00009560 |
| stars_unlight_p2                        | 0000e32e | Function          | stars_unlight_p2                       | 0000958c |
| stars_unlight_all_p1                    | 0000e3a6 | Function          | stars_unlight_all_p1                   | 000095b8 |
| stars_unlight_all_p2                    | 0000e3b6 | Function          | stars_unlight_all_p2                   | 000095c6 |
| step_bumpers                            | 0000e3c6 | Function          | step_bumpers                           | 000095d4 |
| step_bumper                             | 0000e3ea | Function          | step_bumper                            | 000095fe |
| step_zappers                            | 0000e498 | Function          | step_zappers                           | 000096ae |
| step_zapper                             | 0000e4cc | Function          | step_zapper                            | 00009702 |
| light_zapper                            | 0000e548 | Function          | light_zapper                           | 0000977e |
|                                         |          |                   | unlight_zapper                         | 000097b4 |
| set_goal_scored_animation               | 0000e55e | Function          | set_goal_scored_animation              | 000097e2 |
| constrain_sprites                       | 0000e5de | Function          | constrain_sprites                      | 00009870 |
| constrain_sprite                        | 0000e62a | Function          | constrain_sprite                       | 000098c8 |
| update_camera                           | 0000e71c | Function          | update_camera                          | 0000998e |
| get_camera_speed                        | 0000e7b2 | Function          | get_camera_speed                       | 00009a5e |
| step_sprites                            | 0000e7ce | Function          | step_sprites                           | 00009a7a |
| step_player                             | 0000e86c | Function          | step_player                            | 00009b28 |
| spawn_cash                              | 0000e894 | Function          | spawn_cash                             | 00009b50 |
| spawn_powerup                           | 0000e8f2 | Function          | spawn_powerup                          | 00009bba |
| spawn_armour                            | 0000e924 | Function          | spawn_armour                           | 00009bee |
| control_player                          | 0000e95e | Function          | control_player                         | 00009c2c |
| check_player_onscreen                   | 0000ea92 | Function          | check_player_onscreen                  | 00009d6e |
| handle_collisions                       | 0000eac8 | Function          | handle_collisions                      | 00009da8 |
| handle_collision                        | 0000eb28 | Function          | handle_collision                       | 00009e0e |
| get_ball                                | 0000eb9c | Function          | get_ball                               | 00009e82 |
| zap_player                              | 0000ed12 | Function          | zap_player                             | 00009fa0 |
| goalie_deflect_ball                     | 0000ed52 | Function          | goalie_deflect_ball                    | 00009fe8 |
| deflection_direction                    | 0000edf4 | Data Label        | deflection_direction                   | 0000a092 |
| user_controlled_player                  | 0000ee04 | Function          | user_controlled_player                 | 0000a0a2 |
| active_player_ai                        | 0000ee22 | Function          | active_player_ai                       | 0000a0c0 |
| get_opposing_player_directions          | 0000efe2 | Function          | get_opposing_player_directions         | 0000a28c |
| check_collectibles                      | 0000f05a | Function          | check_collectibles                     | 0000a30a |
| check_collectible                       | 0000f0b8 | Function          | check_collectible                      | 0000a376 |
| try_moving_mostly_forward               | 0000f0fc | Function          | try_moving_mostly_forward              | 0000a3ba |
| try_moving_left                         | 0000f132 | Function          | try_moving_left                        | 0000a3f0 |
| try_moving_right                        | 0000f14a | Function          | try_moving_right                       | 0000a408 |
| find_route_left_first                   | 0000f162 | Function          | find_route_left_first                  | 0000a420 |
| find_route_right_first                  | 0000f20e | Function          | find_route_right_first                 | 0000a4cc |
| active_defensive_player_pass_ai         | 0000f2c4 | Function          | active_defensive_player_pass_ai        | 0000a582 |
| use_court_hardware_ai                   | 0000f3a8 | Function          | use_court_hardware_ai                  | 0000a66a |
| use_zapper                              | 0000f50c | Function          | use_zapper                             | 0000a7d6 |
| get_player_observe_distance             | 0000f55a | Function          | get_player_observe_distance            | 0000a824 |
| get_sustain                             | 0000f564 | Function          | get_sustain                            | 0000a82e |
| set_goal_throw_location                 | 0000f580 | Function          | set_goal_throw_location                | 0000a84e |
| active_forward_player_with_ball_ai      | 0000f60a | Function          | active_forward_player_with_ball_ai     | 0000a8d8 |
| is_teammate_blocked                     | 0000f738 | Function          | is_teammate_blocked                    | 0000aa0c |
| base_player_ai                          | 0000f752 | Function          | base_player_ai                         | 0000aa26 |
| find_closest_available_enemy            | 0000f866 | Function          | find_closest_available_enemy           | 0000ab3c |
| is_point_in_player_bounds               | 0000f8cc | Function          | is_point_in_player_bounds              | 0000aba6 |
| get_defender_to_support                 | 0000f8f2 | Function          | get_defender_to_support                | 0000abcc |
| adjust_support_nearby_attacker          | 0000f920 | Function          | adjust_support_nearby_attacker         | 0000abfe |
| adjust_support_target                   | 0000f992 | Function          | adjust_support_target                  | 0000ac70 |
| centre_x                                | 0000fa12 | Function          | centre_x                               | 0000acf0 |
| constrain_y_diagonally                  | 0000fa1e | Function          | constrain_y_diagonally                 | 0000acfc |
| attackers_targeting                     | 0000fa5c | Function          | attackers_targeting                    | 0000ad3a |
| dead_unknown                            | 0000fae8 | Function          | dead_unknown                           | 0000adca |
| constrain_x                             | 0000faf4 | Function          | constrain_x                            | 0000add6 |
| constrain_y                             | 0000fb12 | Function          | constrain_y                            | 0000adf4 |
| base_goalie_set_intercept_position      | 0000fb30 | Function          | base_goalie_set_intercept_position     | 0000ae12 |
| get_goalie_back_y                       | 0000fca6 | Function          | get_goalie_back_y                      | 0000af8c |
| get_active_goalie_back_y                | 0000fcbc | Function          | get_active_goalie_back_y               | 0000afa2 |
| get_diagonal_left_goal_intercept        | 0000fcd2 | Function          | get_diagonal_left_goal_intercept       | 0000afb8 |
| get_diagonal_right_goal_intercept       | 0000fce4 | Function          | get_diagonal_right_goal_intercept      | 0000afca |
| active_goalie_no_ball_ai                | 0000fcf4 | Function          | active_goalie_no_ball_ai               | 0000afda |
| get_predicted_ball_position_for_goalie  | 0000fed0 | Function          | get_predicted_ball_position_for_goalie | 0000b1ba |
| handle_local_interaction_ai             | 0000ff2e | Function          | handle_local_interaction_ai            | 0000b21c |
| distance_check                          | 00010030 | Function          | distance_check                         | 0000b332 |
| slide_or_jump_at_target                 | 00010058 | Function          | slide_or_jump_at_target                | 0000b35a |
| active_player_slide_or_jump             | 0001012c | Function          | active_player_slide_or_jump            | 0000b43e |
| do_slide                                | 00010138 | Function          | do_slide                               | 0000b44a |
| base_player_attack                      | 000101ca | Function          | base_player_attack                     | 0000b4ee |
| avoid_enemy_player                      | 0001020e | Function          | avoid_enemy_player                     | 0000b536 |
| start_player_move_action_fn             | 00010250 | Function          | start_player_move_action_fn            | 0000b578 |
| player_moving_action_fn                 | 000102e2 | Function          | player_moving_action_fn                | 0000b60a |
| preconfigure_player_move                | 000103cc | Function          | preconfigure_player_move               | 0000b700 |
| hitting_action_fn                       | 0001042c | Function          | hitting_action_fn                      | 0000b770 |
| do_tackle                               | 00010468 | Function          | do_tackle                              | 0000b7b2 |
| get_tackle_difficulty                   | 000105ba | Function          | get_tackle_difficulty                  | 0000b8c4 |
| damage_player                           | 0001061a | Function          | damage_player                          | 0000b92a |
| do_goal_throw_ai                        | 0001066e | Function          | do_goal_throw_ai                       | 0000b97e |
| do_throw_punt_ai                        | 0001069a | Function          | do_throw_punt_ai                       | 0000b9ac |
| do_throw_high_ai                        | 0001071e | Function          | do_throw_high_ai                       | 0000ba0a |
| do_throw_low_ai                         | 00010742 | Function          | do_throw_low_ai                        | 0000ba2e |
| do_throw_common_ai                      | 00010766 | Function          | do_throw_common_ai                     | 0000ba52 |
| throwing_action_fn                      | 000107be | Function          | throwing_action_fn                     | 0000bab0 |
| set_ball_speed                          | 000108e0 | Function          | set_ball_speed                         | 0000bbe8 |
| set_standing_catch_animation            | 000108fa | Function          | set_standing_catch_animation           | 0000bc08 |
| start_player_standing_action_fn         | 00010958 | Function          | start_player_standing_action_fn        | 0000bc6c |
| preconfigure_player_standing            | 000109a2 | Function          | preconfigure_player_standing           | 0000bcb8 |
| jumping_action_fn                       | 000109d6 | Function          | jumping_action_fn                      | 0000bcf6 |
| complete_action_fn                      | 00010a28 | Function          | complete_action_fn                     | 0000bd4a |
| goalie_sliding_action_fn                | 00010a7a | Function          | goalie_sliding_action_fn               | 0000bd9e |
| sliding_action_fn                       | 00010a82 | Function          | sliding_action_fn                      | 0000bda6 |
| noop                                    | 00010a8a | Function          | noop                                   | 0000bdae |
| reset_player_timer                      | 00010a8c | Function          | reset_player_timer                     | 0000bdb0 |
| target_predicted_position               | 00010aaa | Function          | target_predicted_position              | 0000bdd2 |
| reflect_x                               | 00010ae8 | Function          | reflect_x                              | 0000be14 |
| reflect_y                               | 00010b0a | Function          | reflect_y                              | 0000be36 |
| get_object_to_point_direction           | 00010b2c | Function          | get_object_to_point_direction          | 0000be58 |
| get_direction_to_target                 | 00010b90 | Function          | get_direction_to_target                | 0000bebc |
| handle_user_input                       | 00010bc4 | Function          | handle_user_input                      | 0000bef0 |
| convert_move_dir_to_facing_dir          | 00010cde | Function          | convert_move_dir_to_facing_dir         | 0000c01a |
| configure_sprite_for_direction          | 00010cee | Function          | configure_sprite_for_direction         | 0000c02c |
| step_sprite_animations                  | 00010d04 | Function          | step_sprite_animations                 | 0000c042 |
| set_player_sprite_offset                | 00010dfe | Function          | set_player_sprite_offset               | 0000c13e |
| start_injury                            | 00010e16 | Function          | start_injury                           | 0000c164 |
| step_injury                             | 00010fac | Function          | step_injury                            | 0000c2f4 |
| step_injury_0                           | 0001100a | Function          | step_injury_0                          | 0000c35c |
| step_injury_1                           | 000110aa | Function          | step_injury_1                          | 0000c41c |
| step_injury_2                           | 000111aa | Function          | step_injury_2                          | 0000c54a |
| step_injury_3                           | 0001122e | Function          | step_injury_3                          | 0000c5ca |
| limit_player_movement                   | 00011304 | Function          | limit_player_movement                  | 0000c6a8 |
| test_powerup_reverse                    | 0001137c | Function          | test_powerup_reverse                   | 0000c726 |
| test_block_powerup                      | 00011398 | Function          | test_block_powerup                     | 0000c746 |
| test_shield_powerup                     | 000113bc | Function          | test_shield_powerup                    | 0000c772 |
| collect_coin                            | 000113d4 | Function          | collect_coin                           | 0000c78e |
| randomise_coin                          | 00011418 | Function          | randomise_coin                         | 0000c7de |
| collect_powerup                         | 00011436 | Function          | collect_powerup                        | 0000c7fa |
| draw_status_bar_powerup                 | 0001147e | Function          | draw_status_bar_powerup                | 0000c848 |
|                                         |          |                   | overwrite_cell                         | 0000c890 |
| randomise_powerup                       | 0001151a | Function          | randomise_powerup                      | 0000c900 |
| collect_armour                          | 00011558 | Function          | collect_armour                         | 0000c944 |
| randomise_armour                        | 0001158c | Function          | randomise_armour                       | 0000c97c |
| distance_to_collectable                 | 000115c2 | Function          | distance_to_collectable                | 0000c9b6 |
| randomise_powerup_positions             | 00011612 | Function          | randomise_powerup_position             | 0000ca08 |
| randomise_coin_position                 | 00011646 | Function          | randomise_coin_position                | 0000ca38 |
| randomise_armour_position               | 00011692 | Function          | randomise_armour_position              | 0000ca80 |
| apply_armour                            | 000116b8 | Function          | apply_armour                           | 0000caa2 |
| tackle_drop_armour                      | 0001170e | Function          | tackle_drop_armour                     | 0000cafe |
| clear_powerup                           | 00011794 | Function          | clear_powerup                          | 0000cb8c |
| powerup_shield                          | 000117f4 | Function          |                                        |          |
| powerup_freeze                          | 0001180c | Function          | powerup_freeze                         | 0000cbfc |
|                                         |          |                   | powerup_reverse                        | 0000cc1a |
| powerup_stats_down                      | 00011824 | Function          | powerup_stats_down                     | 0000cc3a |
| powerdown_stats_down                    | 0001185a | Function          | powerdown_stats_down                   | 0000cc7a |
| powerup_stats_up                        | 00011872 | Function          | powerup_stats_up                       | 0000cc96 |
| powerdown_stats_up                      | 000118aa | Function          | powerdown_stats_up                     | 0000ccd8 |
| powerup_stats_up_both                   | 000118c2 | Function          | powerup_stats_up_both                  | 0000ccf4 |
| powerdown_stats_up_both                 | 000118f0 | Function          | powerdown_stats_up_both                | 0000cd2c |
| powerup_slow                            | 00011902 | Function          | powerup_slow                           | 0000cd42 |
| powerdown_slow                          | 00011936 | Function          | powerdown_slow                         | 0000cd80 |
| powerup_grab                            | 0001194e | Function          | powerup_grab                           | 0000cd9c |
| powerup_teleport                        | 00011972 | Function          | powerup_teleport                       | 0000cdc4 |
| powerup_reverse                         | 000119b6 | Function          |                                        |          |
| powerup_block                           | 000119d0 | Function          | powerup_block                          | 0000ce10 |
|                                         |          |                   | powerup_shield                         | 0000ce30 |
| powerup_energy                          | 000119ea | Function          | powerup_energy                         | 0000ce50 |
| powerup_zap                             | 00011a00 | Function          | powerup_zap                            | 0000ce66 |
| for_all_active_players                  | 00011a96 | Function          | for_all_active_players                 | 0000cf0a |
| set_stats                               | 00011aa6 | Function          | set_stats                              | 0000cf1a |
| revert_stats                            | 00011ab0 | Function          | revert_stats                           | 0000cf24 |
| set_slow_down                           | 00011aba | Function          | set_slow_down                          | 0000cf2e |
| revert_slow_down                        | 00011ac4 | Function          | revert_slow_down                       | 0000cf38 |
| set_stats_aux                           | 00011ace | Function          | set_stats_aux                          | 0000cf42 |
| revert_stats_aux                        | 00011aec | Function          | revert_stats_aux                       | 0000cf60 |
| set_slow_down_aux                       | 00011b0c | Function          | set_slow_down_aux                      | 0000cf80 |
| revert_slow_down_aux                    | 00011b1a | Function          | revert_slow_down_aux                   | 0000cf8e |
| dirty_map_all                           | 00011b28 | Function          |                                        |          |
| dirty_map_edge                          | 00011b3a | Function          |                                        |          |
| redraw_pitch                            | 00011b88 | Function          |                                        |          |
|                                         |          |                   | init_vdp                               | 0000cf9c |
|                                         |          |                   | display_configure_non_match            | 0000d074 |
|                                         |          |                   | display_configure_match                | 0000d1d6 |
|                                         |          |                   | vdp_data_write                         | 0000d3c2 |
|                                         |          |                   | display_push_start_match               | 0000d3d2 |
|                                         |          |                   | display_push_start_non_match           | 0000d3d8 |
|                                         |          |                   | push_start_indices                     | 0000d414 |
|                                         |          |                   | init_pitch_cell_map                    | 0000d428 |
|                                         |          |                   | write_background_cell_mapping          | 0000d574 |
|                                         |          |                   | transfer_cell_map_with_scroll          | 0000d596 |
|                                         |          |                   | set_hw_scroll                          | 0000d656 |
|                                         |          |                   | display_match                          | 0000d68c |
| display_scores                          | 00011d7e | Function          | display_scores                         | 0000d6b4 |
| display_scores_inner                    | 00011d92 | Function          |                                        |          |
| display_score                           | 00011dae | Function          |                                        |          |
| display_digit                           | 00011dbc | Function          |                                        |          |
| display_digit_inner                     | 00011dce | Function          |                                        |          |
|                                         |          |                   | display_score_digit                    | 0000d6e8 |
|                                         |          |                   | display_time                           | 0000d782 |
|                                         |          |                   | display_time_digit                     | 0000d7b8 |
| draw_game                               | 00011e0c | Function          | draw_game                              | 0000d852 |
| draw_score_multipliers                  | 00011ece | Function          | draw_score_multipliers                 | 0000d922 |
| draw_powerups                           | 00011ee0 | Function          |                                        |          |
| draw_player_markers                     | 00011f1a | Function          | draw_player_markers                    | 0000d938 |
| sort_players_vertically                 | 00011f40 | Function          | sort_players_vertically                | 0000d966 |
| players_sorted_vertically               | 00011f8c | Data Label        |                                        |          |
| draw_all_players                        | 00011fdc | Function          | draw_all_players                       | 0000d9b6 |
| draw_ball                               | 00011ff0 | Function          | draw_ball                              | 0000d9ce |
| save_replay_origin                      | 00011ffa | Function          | save_replay_origin                     | 0000d9da |
| write_replay_buf                        | 00012018 | Function          | write_replay_buf                       | 0000d9fe |
| read_replay_buffer                      | 00012050 | Function          | read_replay_buffer                     | 0000da42 |
| run_replay                              | 00012062 | Function          | run_replay                             | 0000da56 |
| save_replay                             | 000121b8 | Function          | dead_save_replay                       | 0000dbc0 |
|                                         |          |                   | dead_something_3                       | 0000dc5a |
| disk_error_message                      | 00012272 | Function          | dead_disk_error                        | 0000dc5c |
| replay_frame                            | 00012302 | Function          | replay_frame                           | 0000dcda |
|                                         |          |                   | dead_disk_error_aux                    | 0000dd62 |
| add_monitor_overlay                     | 000123ce | Function          |                                        |          |
| dirty_map_top_left                      | 00012492 | Function          |                                        |          |
| draw_sprite                             | 000124ca | Function          | draw_sprite                            | 0000dd64 |
| save_sprite_for_replay                  | 0001256c | Function          | save_sprite_for_replay                 | 0000ddf4 |
| mark_sprite_dirty                       | 000125ca | Function          |                                        |          |
| sprite_fn_32x32_masked                  | 00012662 | Function          |                                        |          |
| blit_16x16_masked_right                 | 00012780 | Function          |                                        |          |
| blit_16x16_masked_left                  | 00012792 | Function          |                                        |          |
| blit_16x16_masked_onscreen              | 000127a6 | Function          |                                        |          |
| blit_32x32_red_onscreen                 | 000127c6 | Function          |                                        |          |
| blit_32x32_red_shared                   | 000127e2 | Function          |                                        |          |
| sprite_is_5_bits                        | 000129f4 | Data Label        |                                        |          |
| bitplane_stride                         | 000129f6 | Data Label        |                                        |          |
| source_mod_adjust                       | 000129fa | Data Label        |                                        |          |
| sprite_16x16_size                       | 000129fc | Data Label        |                                        |          |
| blit_32x32_red_near_right               | 000129fe | Function          |                                        |          |
| blit_32x32_red_near_left                | 00012a28 | Function          |                                        |          |
| blit_32x32_red_far_right                | 00012a48 | Function          |                                        |          |
| blit_32x32_red_far_left                 | 00012a7a | Function          |                                        |          |
| sprite_fn_32x32_no_mask                 | 00012ab0 | Function          |                                        |          |
| sprite_prepare_16x16                    | 00012bbc | Function          |                                        |          |
| sprite_fn_16x16_masked                  | 00012c64 | Function          |                                        |          |
| sprite_fn_16x16_no_mask                 | 00012cce | Function          |                                        |          |
| blit_16x16_no_mask_right                | 00012d38 | Function          |                                        |          |
| blit_16x16_no_mask_left                 | 00012d4a | Function          |                                        |          |
| blit_16x16_no_mask_onscreen             | 00012d68 | Function          |                                        |          |
| blit_16x16_no_mask_shared               | 00012d6e | Function          |                                        |          |
| blit_32x32_no_mask_near_right           | 00012d8c | Function          |                                        |          |
| blit_32x32_no_mask_near_left            | 00012db6 | Function          |                                        |          |
| blit_32x32_no_mask_far_right            | 00012dd6 | Function          |                                        |          |
| blit_32x32_no_mask_far_left             | 00012e0c | Function          |                                        |          |
| blit_32x32_no_mask_onscreen             | 00012e44 | Function          |                                        |          |
| blit_32x32_no_mask_shared               | 00012e62 | Function          |                                        |          |
| ones_mask                               | 0001309e | Data Label        |                                        |          |
| blanks                                  | 000130a2 | Data Label        |                                        |          |
| blit_screen                             | 000130d2 | Function          |                                        |          |
| copy_to_screen                          | 00013184 | Function          |                                        |          |
| config_blitter_for_pitch_block          | 0001323a | Function          |                                        |          |
| zero_pitch_block                        | 00013274 | Function          |                                        |          |
| pitch_block_positive                    | 000132f6 | Function          |                                        |          |
| pitch_block_negative                    | 000133b4 | Function          |                                        |          |
| blit_32x32_blue_onscreen                | 0001347a | Function          |                                        |          |
| blit_32x32_blue_shared                  | 00013496 | Function          |                                        |          |
| blit_32x32_blue_near_left               | 000136bc | Function          |                                        |          |
| blit_32x32_blue_far_right               | 000136dc | Function          |                                        |          |
| blit_32x32_blue_far_left                | 0001370e | Function          |                                        |          |
| blit_32x32_blue_near_right              | 00013748 | Function          |                                        |          |
| generate_player_team_masks              | 00013772 | Function          |                                        |          |
|                                         |          |                   | clear_hw_sprites                       | 0000de5e |
|                                         |          |                   | build_hw_sprite                        | 0000de86 |
|                                         |          |                   | transfer_hw_sprites                    | 0000dee6 |
|                                         |          |                   | init_background_save_stack             | 0000dfb2 |
|                                         |          |                   | draw_background_sprites                | 0000dfbe |
|                                         |          |                   | restore_background                     | 0000e00a |
|                                         |          |                   | update_background_sides                | 0000e040 |
|                                         |          |                   | draw_left_edge_piece                   | 0000e102 |
|                                         |          |                   | draw_right_edge_piece                  | 0000e10e |
|                                         |          |                   | nuke_offscreen_markers                 | 0000e144 |
|                                         |          |                   | clear_offscreen_markers                | 0000e156 |
|                                         |          |                   | clear_offscreen_markers_aux            | 0000e172 |
|                                         |          |                   | draw_cell_marker                       | 0000e1ac |
|                                         |          |                   | draw_cell_markers_aux                  | 0000e1d6 |
|                                         |          |                   | sprite_fn_player                       | 0000e43a |
|                                         |          |                   | sprite_fn_ball_launcher                | 0000e472 |
|                                         |          |                   | sprite_fn_bumper                       | 0000e4a0 |
|                                         |          |                   | sprite_fn_big_ball                     | 0000e4dc |
|                                         |          |                   | sprite_fn_ball                         | 0000e510 |
|                                         |          |                   | sprite_fn_coin                         | 0000e542 |
|                                         |          |                   | sprite_fn_power_up_1                   | 0000e55e |
|                                         |          |                   | sprite_fn_power_up_2                   | 0000e568 |
|                                         |          |                   | sprite_fn_power_up_3                   | 0000e572 |
|                                         |          |                   | sprite_fn_power_up_common              | 0000e57a |
|                                         |          |                   | draw_background_sprite                 | 0000e59c |
|                                         |          |                   | sprite_fn_blue_marker                  | 0000e5f0 |
|                                         |          |                   | sprite_fn_red_marker                   | 0000e622 |
|                                         |          |                   | sprite_fn_player_number                | 0000e654 |
|                                         |          |                   | sprite_fn_medibot_1                    | 0000e686 |
|                                         |          |                   | sprite_fn_medibot_2                    | 0000e6ba |
|                                         |          |                   | sprite_fn_multiplier_top               | 0000e6ee |
|                                         |          |                   | sprite_fn_multiplier_bottom            | 0000e7a0 |
|                                         |          |                   | display_splash                         | 0000e852 |
|                                         |          |                   | sprite_fn_simple_unmasked              | 0000e9a4 |
|                                         |          |                   | sprite_fn_simple_masked                | 0000e9e2 |
|                                         |          |                   | dead_put_4x4                           | 0000ea20 |
|                                         |          |                   | dead_put_4x1                           | 0000ea4e |
|                                         |          |                   | sprite_fn_armour                       | 0000ea7a |
|                                         |          |                   | put_4x1_masked                         | 0000eaa8 |
|                                         |          |                   | sprite_fn_keypad                       | 0000ead4 |
|                                         |          |                   | put_3x1                                | 0000eb00 |
|                                         |          |                   | put_3x3_masked                         | 0000eb22 |
|                                         |          |                   | put_3x1_masked                         | 0000eb46 |
|                                         |          |                   | display_2x2_char                       | 0000eb68 |
|                                         |          |                   | put_cell                               | 0000ebaa |
|                                         |          |                   | put_masked_cell                        | 0000ec08 |
|                                         |          |                   | schedule_cell_transfer                 | 0000ec80 |
|                                         |          |                   | transfer_cells                         | 0000ecde |
|                                         |          |                   | draw_box_colour                        | 0000ed82 |
|                                         |          |                   | draw_xor_square_48x48                  | 0000edc6 |
|                                         |          |                   | draw_xor_square_16x16                  | 0000edd2 |
|                                         |          |                   | draw_xor_square                        | 0000edda |
|                                         |          |                   | schedule_box                           | 0000ee62 |
|                                         |          |                   | draw_colour_h_line                     | 0000eede |
|                                         |          |                   | lhs_mask                               | 0000ef84 |
|                                         |          |                   | rhs_mask                               | 0000efa4 |
|                                         |          |                   | draw_xor_horizontal_line               | 0000efc4 |
|                                         |          |                   | horizontal_start_bitmask_table         | 0000f042 |
|                                         |          |                   | horizontal_end_bitmask_table           | 0000f062 |
|                                         |          |                   | draw_xor_vertical_line                 | 0000f082 |
|                                         |          |                   | vertical_bitmask_table                 | 0000f0b2 |
| strlen                                  | 000137a8 | Function          | strlen                                 | 0000f0d4 |
| reset_team                              | 000137b8 | Function          | reset_team                             | 0000f0e4 |
| reset_player                            | 000137ca | Function          | reset_player                           | 0000f0f6 |
| swap_x_constraints                      | 0001380a | Function          | swap_x_constraints                     | 0000f136 |
| swap_y_constraints                      | 0001381a | Function          | swap_y_constraints                     | 0000f146 |
| swap_facing_direction                   | 0001382a | Function          | swap_facing_direction                  | 0000f156 |
| swap_playing_direction                  | 0001383a | Function          | swap_playing_direction                 | 0000f166 |
| change_ends                             | 00013860 | Function          | change_ends                            | 0000f18c |
|                                         |          |                   | init_rand                              | 0000f1f6 |
|                                         |          |                   | rand                                   | 0000f20c |
|                                         |          |                   | dead_read_write_palette_entry          | 0000f242 |
|                                         |          |                   | init_hardware                          | 0000f272 |
|                                         |          |                   | h_interrupt_handler                    | 0000f2bc |
|                                         |          |                   | v_interrupt_handler                    | 0000f2d2 |
|                                         |          |                   | qpac_decompress                        | 0000f3bc |
|                                         |          |                   | read_8_bits                            | 0000f54e |
|                                         |          |                   | QPAC_MAGIC_ID                          | 0000f5d2 |
|                                         |          |                   | sound_init_dac                         | 0000f5e2 |
|                                         |          |                   | sound_set_sharp_decay                  | 0000f664 |
|                                         |          |                   | sound_wait_idle                        | 0000f68e |
|                                         |          |                   | sound_start_note                       | 0000f6a0 |
|                                         |          |                   | dt1_mul_reg_for_channel_again          | 0000f8c8 |
|                                         |          |                   | offset_for_channel_again2              | 0000f8ce |
|                                         |          |                   | fb_algo_for_channel                    | 0000f8d4 |
|                                         |          |                   | sound_step_note                        | 0000f8da |
|                                         |          |                   | offset_for_channel_again               | 0000f942 |
|                                         |          |                   | sound_stop                             | 0000f948 |
|                                         |          |                   | dt1_mul_reg_for_channel                | 0000f9a6 |
|                                         |          |                   | offset_for_channel                     | 0000f9ac |
|                                         |          |                   | sound_set_freq                         | 0000f9b2 |
|                                         |          |                   | freq_reg_for_channel                   | 0000fa32 |
|                                         |          |                   | sound_buggy_dual_divide                | 0000fa38 |
|                                         |          |                   | vibrato_table                          | 0000fa6e |
|                                         |          |                   | sound_note_table                       | 0000faae |
|                                         |          |                   | sound_note_table_2                     | 0000fb0e |
|                                         |          |                   | sound_note_table_3                     | 0000fb6e |
|                                         |          |                   | sound_note_table_4                     | 0000fbce |
|                                         |          |                   | sound_note_table_5                     | 0000fc2e |
|                                         |          |                   | sound_note_table_6                     | 0000fc8e |
|                                         |          |                   | sound_note_table_7                     | 0000fcee |
|                                         |          |                   | sound_note_table_8                     | 0000fd4e |
|                                         |          |                   | sound_convert_to_fm_freq               | 0000fdae |
| int_audio                               | 000138b6 | Function          |                                        |          |
| sound_table                             | 00013958 | Data Label        |                                        |          |
| sound_play                              | 00013aa8 | Function          | sound_play                             | 0000fde4 |
| sound_effects                           | 00013b5a | Data Label        |                                        |          |
| sound_envelopes                         | 00013cb4 | Data Label        |                                        |          |
| sound_service_channel                   | 00013cc4 | Function          |                                        |          |
| sound_update                            | 00013d24 | Function          | sound_int_handler                      | 0000fe66 |
| sound_update_hardware                   | 00013d48 | Function          |                                        |          |
| sound_update_hardware_channel           | 00013d66 | Function          |                                        |          |
| sound_envelope                          | 00013dc2 | Function          |                                        |          |
| sound_envelope_channel                  | 00013de6 | Function          |                                        |          |
| sound_envelope_channel_aux              | 00013e08 | Function          |                                        |          |
| sound_init                              | 00013e9a | Function          | sound_init                             | 0000fe9e |
| sound_channel_settings                  | 0001407c | Data Label        |                                        |          |
|                                         |          |                   | sound_seq_stack_table_again            | 0000ff6c |
|                                         |          |                   | sound_play_sample                      | 0000ff7c |
|                                         |          |                   | z80_program_main_code                  | 0000ffda |
| sound_play_channel                      | 0001408c | Function          | sound_init_sequence                    | 0000fff4 |
|                                         |          |                   | sound_voice_table                      | 00010048 |
| sound_stack_pointers                    | 00014158 | Data Label        | sound_seq_stack_table                  | 00010058 |
| sound_update_channels                   | 00014168 | Function          | sound_update                           | 00010068 |
| sound_next_command                      | 000141d8 | Instruction Label | sound_next_command                     | 00010096 |
| sound_switch                            | 000141ea | Data Label        | sound_command_table                    | 000100a8 |
| sound_op_cont                           | 000142b2 | Function          | sound_op_cont                          | 00010108 |
|                                         |          |                   | sound_process_voice                    | 0001014c |
| sound_op_set_vol                        | 00014398 | Function          | sound_op_set_36                        | 0001016e |
| sound_op_noop_84                        | 000143a2 | Function          |                                        |          |
| sound_op_goto_start                     | 000143a8 | Function          | sound_op_goto_start                    | 00010178 |
| sound_op_set_note_len                   | 000143b4 | Function          | sound_op_set_note_len                  | 00010184 |
| sound_op_set_tempo                      | 000143c2 | Function          | sound_op_set_tempo                     | 00010192 |
| sound_op_silence                        | 000143d2 | Function          |                                        |          |
| sound_op_effect                         | 000143f0 | Function          | sound_op_noop_1b_operand               | 0001019c |
| sound_op_noop_a0                        | 00014434 | Function          |                                        |          |
| sound_op_noop_a4                        | 0001443a | Function          |                                        |          |
| sound_op_set_loop_flags                 | 00014440 | Function          | sound_op_or_38                         | 000101a2 |
| sound_op_stop                           | 0001444a | Function          | sound_op_stop                          | 000101ac |
| sound_op_call                           | 00014484 | Function          | sound_op_call                          | 000101d6 |
| sound_op_return                         | 000144a6 | Function          | sound_op_ret                           | 000101ec |
| sound_op_add_transposition              | 000144ac | Function          | sound_op_add_3a                        | 000101f2 |
| sound_op_set_transposition              | 000144c2 | Function          | sound_op_set_3a                        | 00010208 |
| sound_op_for                            | 000144ce | Function          | sound_op_for                           | 00010214 |
| sound_op_next                           | 000144e2 | Function          | sound_op_next                          | 00010228 |
| sound_op_set_envelope                   | 00014502 | Function          |                                        |          |
| sound_op_clear_envelope                 | 00014514 | Function          |                                        |          |
| sound_op_set_instrument                 | 0001451c | Function          | sound_op_set_instrument                | 00010248 |
| sound_init_pitch_table                  | 00014552 | Function          |                                        |          |
| sound_op_jump                           | 00014576 | Function          | sound_op_jmp                           | 0001026c |
| sound_vibrato_reset                     | 00014596 | Function          |                                        |          |
| sound_tremolo_reset                     | 000145ae | Function          |                                        |          |
| sound_channel_0                         | 000145c6 | Data Label        |                                        |          |
| sound_channel_1                         | 0001465a | Data Label        |                                        |          |
| sound_channel_2                         | 000146ee | Data Label        |                                        |          |
| sound_channel_3                         | 00014782 | Data Label        |                                        |          |
| sound_stack_0                           | 00014896 | Data Label        |                                        |          |
| sound_stack_1                           | 00014916 | Data Label        |                                        |          |
| sound_stack_2                           | 00014996 | Data Label        |                                        |          |
| sound_stack_3                           | 00014a16 | Data Label        |                                        |          |
| sound_tempo                             | 00014a1a | Data Label        |                                        |          |
| sound_priorities                        | 00014a1c | Data Label        |                                        |          |
| sound_weird_broken_lookup               | 00014a2c | Data Label        |                                        |          |
| sound_lock                              | 00014a34 | Data Label        |                                        |          |
| sound_pitch_table_0                     | 00014a9a | Data Label        |                                        |          |
| sound_pitch_table_1                     | 00014afa | Data Label        |                                        |          |
| sound_pitch_table_2                     | 00014b5a | Data Label        |                                        |          |
| sound_default_instrument                | 00014e5a | Data Label        |                                        |          |
| sound_zero_sample                       | 00014e68 | Data Label        |                                        |          |
| rand                                    | 00014e78 | Function          |                                        |          |
| init_rand                               | 00014eae | Function          |                                        |          |
| rand_seed_1                             | 00014ec4 | Data Label        |                                        |          |
| rand_seed_2                             | 00014ec8 | Data Label        |                                        |          |
| rand_val                                | 00014ecc | Data Label        |                                        |          |
| dead_init_sprites                       | 00014ed0 | Function          |                                        |          |
| init_hw_aux                             | 00014f0a | Function          |                                        |          |
| init_periodic                           | 00014f2a | Function          |                                        |          |
| trap0                                   | 00014f88 | Function          |                                        |          |
| wait_vertb                              | 00014f94 | Function          |                                        |          |
| line_table                              | 00014fac | Data Label        |                                        |          |
| trap_f_1                                | 0001506c | Function          |                                        |          |
| trap_illegal_1                          | 0001507c | Function          |                                        |          |
| trap_illegal_2                          | 0001509c | Function          |                                        |          |
| cp_end                                  | 000159bc | Instruction Label |                                        |          |
| int_vertb                               | 000159c0 | Function          |                                        |          |
| current_screen                          | 00015a44 | Data Label        |                                        |          |
| controllers_update                      | 00015a48 | Function          |                                        |          |
| read_joystick                           | 00015ac2 | Function          |                                        |          |
| dead_update_colours                     | 00015af8 | Function          |                                        |          |
| dead_update_colours_aux                 | 00015b3e | Function          |                                        |          |
| disable_status_bar                      | 00015b70 | Function          |                                        |          |
| init_screen_line_table                  | 00015bca | Function          |                                        |          |
| copper_tweak                            | 00015be8 | Function          |                                        |          |
| enable_status_bar                       | 00015c44 | Function          |                                        |          |
| init_copper                             | 00015c6a | Function          |                                        |          |
| init_copper_set                         | 00015d04 | Function          |                                        |          |
| set_int_keyboard                        | 00015d96 | Function          |                                        |          |
| set_int_keyboard_aux                    | 00015dbc | Function          |                                        |          |
| int_keyboard                            | 00015dda | Function          |                                        |          |
| read_write_palette_entry                | 00015e4c | Function          |                                        |          |
| switch_screens                          | 00015ea8 | Function          |                                        |          |

## Disk I/O

This covers a purely Amiga pile of code. The code from `loader`
onwards is identical to the code used in the second-stage disk loader.

| Amiga Name                  | Location | Type       |
|-----------------------------|----------|------------|
| read_overlay                | 00015ee4 | Function   |
| read_check_overlay_index    | 00015f3a | Function   |
| write_data                  | 00015f68 | Function   |
| read_overlay_index          | 00015fbe | Function   |
| loader                      | 00015fe4 | Function   |
| read_track                  | 000160e2 | Function   |
| write_track                 | 000161d0 | Function   |
| create_sector_headers       | 0001625e | Function   |
| read_next_sector_header     | 000162a4 | Function   |
| decode_sectors              | 000162fc | Function   |
| sectors_to_bytes            | 00016428 | Function   |
| mark_sector_read            | 00016438 | Function   |
| clear_sector_ends           | 00016448 | Function   |
| mfm_get_info                | 0001645a | Function   |
| mfm_decode_long             | 0001647c | Function   |
| mfm_check_header_checksum   | 00016492 | Function   |
| mfm_checksum_header         | 000164a2 | Function   |
| mfm_checksum                | 000164a8 | Function   |
| fill_aa                     | 000164c2 | Function   |
| blitter_mfm_decode          | 000164f4 | Function   |
| blitter_mfm_encode          | 0001652a | Function   |
| blitter_wait_dma_completion | 000165de | Function   |
| blitter_init                | 000165ea | Function   |
| mfm_encode                  | 00016614 | Function   |
| mfm_fixup                   | 00016622 | Function   |
| mfm_encode_evens            | 00016640 | Function   |
| drive_read_dma              | 0001666c | Function   |
| drive_wait_block_finished   | 000166aa | Function   |
| drive_clear_dskblk          | 000166ce | Function   |
| drive_stop_if_reading       | 000166e2 | Function   |
| drive_set_motor             | 000166f2 | Function   |
| drive_start_motor           | 00016710 | Function   |
| drive_seek_track_side       | 0001672a | Function   |
| drive_seek_track_zero       | 0001677e | Function   |
| drive_step_head             | 000167b4 | Function   |
| drive_set_side              | 000167de | Function   |
| drive_get_flags             | 000167ea | Function   |
| wait                        | 0001681e | Function   |
| try_continue_timer          | 00016832 | Function   |
| start_timer                 | 00016840 | Function   |
| drives                      | 0001685a | Data Label |
| init_hw                     | 00016862 | Function   |

## TODO: Misc Amiga, mostly variables.

TODO: Back to random

| display_splash                          | 00016868            | Function          |
| unpack_iff_image                        | 000168a8            | Function          |
| palette_non_game                        | 00016994            | Data Label        |
| copper_template                         | 000169d4            | Data Label        |
| screen_status_bar                       | 00016b20            | Data Label        |
| controller_2_cooked                     | 00016b28            | Data Label        |
| controller_1_cooked                     | 00016b29            | Data Label        |
| current_keyboard                        | 00016b2a            | Data Label        |
| controller_2_raw                        | 00016b2c            | Data Label        |
| controller_1_raw                        | 00016b2d            | Data Label        |
| screen_1                                | 00016b30            | Data Label        |
| screen_2                                | 00016b34            | Data Label        |
| screen_3                                | 00016b38            | Data Label        |
| copper_1                                | 00016b3c            | Data Label        |
| copper_2                                | 00016b48            | Data Label        |
| copper_3                                | 00016b54            | Data Label        |
| screen_to_display                       | 00016b60            | Data Label        |
| colours_copper_list                     | 00016b64            | Data Label        |
| screen_1_bitplane_ptrs                  | 00016ba4            | Data Label        |
| screen_2_bitplane_ptrs                  | 00016bbc            | Data Label        |
| screen_3_bitplane_ptrs                  | 00016bd4            | Data Label        |
| copper_1_buf_no_sb                      | 00016bec            | Data Label        |
| copper_1_buf_sb                         | 00016d38            | Data Label        |
| copper_2_buf_no_sb                      | 00016e84            | Data Label        |
| copper_2_buf_sb                         | 00016fd0            | Data Label        |
| copper_3_buf_no_sb                      | 0001711c            | Data Label        |
| copper_3_buf_sb                         | 00017268            | Data Label        |
| copper_started                          | 000173b4            | Data Label        |
| ints_started                            | 000173b6            | Data Label        |
| vertb_count                             | 000173ba            | Data Label        |
| sprites_monitor_goal                    | 000173be            | Data Label        |
| sprites_monitor_injury                  | 000182be            | Data Label        |
| sprites_monitor_final_score             | 000191be            | Data Label        |
| sprites_monitor_text                    | 0001a0be            | Data Label        |
| sprites_game_font                       | 0001afbe            | Data Label        |
| sprite_number_font                      | 0001b55e            | Data Label        |
| buffer                                  | 0001b6ee            | Data Label        |
| overlay_index                           | 0001b7ee            | Data Label        |
| trap_trace_3                            | 0001bb22            | Function          |
| trap_illegal_3                          | 0001bb3e            | Function          |
| trap_trace_2                            | 0001bb76            | Function          |
| trap_trace                              | 0001bbc6            | Function          |
| sprite_char_buf                         | 0001bbee            | Data Label        |
| stored_stack                            | 0001bc3a            | Data Label        |

# TODO: Soundy bit. Compare and contrast between Megadrive and Amiga

| sound_base                              | 0001bc3e            | Data Label        |
| sequence_table_index                    | 0001bc3e            | Data Label        |
| instrument_table_index                  | 0001bc42            | Data Label        |
| overlay28_index                         | 0001bc46            | Data Label        |
| sound_sequence_1                        | 0001bc4c            | Data Label        |
| sound_sequence_8                        | 0001bc67            | Data Label        |
| sound_sequence_11                       | 0001bd3b            | Data Label        |
| sound_sequence_14                       | 0001bdc8            | Data Label        |
| sound_sequence_16                       | 0001bfc0            | Data Label        |
| sound_sequence_21                       | 0001c074            | Data Label        |
| sound_sequence_2                        | 0001c0f6            | Data Label        |
| sound_sequence_7                        | 0001c1cb            | Data Label        |
| sound_sequence_17                       | 0001c1de            | Data Label        |
| sound_sequence_9                        | 0001c366            | Data Label        |
| sound_sequence_13                       | 0001c379            | Data Label        |
| sound_sequence_22                       | 0001c44b            | Data Label        |
| sound_sequence_3                        | 0001c53d            | Data Label        |
| sound_sequence_5                        | 0001c5f3            | Data Label        |
| sound_sequence_6                        | 0001c608            | Data Label        |
| sound_sequence_15                       | 0001c62f            | Data Label        |
| sound_sequence_19                       | 0001c73d            | Data Label        |
| sound_sequence_23                       | 0001c7af            | Data Label        |
| sound_sequence_4                        | 0001c86f            | Data Label        |
| sound_sequence_10                       | 0001ca0f            | Data Label        |
| sound_sequence_12                       | 0001ca65            | Data Label        |
| sound_sequence_18                       | 0001cc69            | Data Label        |
| sound_sequence_20                       | 0001cd31            | Data Label        |
| sound_sequence_24                       | 0001cfbc            | Data Label        |
| sound_sequence_25                       | 0001cfcc            | Data Label        |
| sound_sequence_26                       | 0001cfd8            | Data Label        |
| sequence_table                          | 0001cfe4            | Data Label        |
| sound_sample_0                          | 0001d050            | Data Label        |
| sound_sample_1                          | 0001d060            | Data Label        |
| sound_sample_2                          | 0001d070            | Data Label        |
| sound_sample_3                          | 0001d080            | Data Label        |
| sound_sample_4                          | 0001d088            | Data Label        |
| sound_sample_5                          | 0001d0a8            | Data Label        |
| sound_sample_6                          | 0001d0c0            | Data Label        |
| sound_sample_7                          | 0001d0c8            | Data Label        |
| sound_sample_8                          | 0001d0d8            | Data Label        |
| sound_sample_9                          | 0001d0f8            | Data Label        |
| sound_sample_10                         | 0001e4ca            | Data Label        |
| sound_sample_11                         | 0001f89e            | Data Label        |
| sound_sample_12                         | 0001fbda            | Data Label        |
| sound_sample_13                         | 00020694            | Data Label        |
| sound_sample_14                         | 00021c6e            | Data Label        |
| sound_sample_15                         | 00022730            | Data Label        |
| sound_sample_16                         | 000231ae            | Data Label        |
| sound_sample_17                         | 00023b56            | Data Label        |
| sound_sample_19                         | 000244d0            | Data Label        |
| sound_sample_18                         | 000244d0            | Data Label        |
| sound_sample_20                         | 00026c62            | Data Label        |
| sound_sample_21                         | 0002dada            | Data Label        |
| sound_sample_22                         | 0002fd66            | Data Label        |
| sound_sample_23                         | 00032160            | Data Label        |
| sound_sample_24                         | 00034544            | Data Label        |
| sound_sample_25                         | 0003805a            | Data Label        |
| sound_sample_26                         | 00038876            | Data Label        |
| sound_sample_27                         | 00038fe4            | Data Label        |
| sound_sample_28                         | 000397d6            | Data Label        |
| sound_sample_29                         | 0003ac62            | Data Label        |
| sound_sample_30                         | 0003b7f6            | Data Label        |
| sound_sample_31                         | 0003c4b4            | Data Label        |
| sound_sample_32                         | 0003cfaa            | Data Label        |
| sound_sample_33                         | 0003dcfc            | Data Label        |
| sound_sample_34                         | 0003fa5a            | Data Label        |
| sound_sample_35                         | 00041964            | Data Label        |
| sound_sample_36                         | 000438a6            | Data Label        |
| sound_sample_37                         | 0004587e            | Data Label        |
| sound_sample_38                         | 000461a4            | Data Label        |
| sound_sample_39                         | 00047b42            | Data Label        |
| instrument_table                        | 0004940a            | Data Label        |

# TODO: Intro bit. Compare and contrast w/ Megadrive

| intro_presents                          | 0004963a            | Function          |
| intro                                   | 00049650            | Function          |
| display_text_presents                   | 00049718            | Function          |
| display_string_and_wait_presents        | 00049738            | Function          |
| display_text_intro                      | 0004979a            | Function          |
| display_string_and_wait_intro           | 000497f0            | Function          |
| display_text_credits                    | 00049846            | Function          |
| display_string_and_wait_credits         | 00049892            | Function          |
| draw_arena_backdrop                     | 000498e8            | Function          |
| wait_100ms                              | 00049906            | Function          |
| display_string                          | 00049940            | Function          |
| display_title_font_char                 | 00049a12            | Function          |
| mask_char_to_screen                     | 00049a36            | Function          |
| copy_16x16_to_screen                    | 00049aaa            | Function          |
| copy_16x16_from_screen                  | 00049ad2            | Function          |
| fill_screen_zero                        | 00049afa            | Function          |
| display_fade_transition_sound           | 00049b34            | Function          |
| splash_title_screen                     | 00049e5e            | Data Label        |
| splash_arena_backdrop                   | 00052d0e            | Data Label        |
| sprites_title_font                      | 0005ae00            | Data Label        |
| skip_flags                              | 0005ca20            | Data Label        |

# TODO: Amiga BSS & optional overlay saving

| free                                    | 0005ca24            | Data Label        |
| screen_3_buf                            | 0005fbaa            | Data Label        |
| screen_2_buf                            | 0006a71c            | Data Label        |
| screen_1_buf                            | 0007528e            | Data Label        |
| stack_bottom                            | 0007fe00            | Data Label        |
| low_ram_top                             | 00080000            | Data Label        |
| saved_overlay_27                        | 00091a74            | Data Label        |
| saved_overlay_28                        | 00094496            | Data Label        |
| saved_overlay_18                        | 00097c34            | Data Label        |
| saved_overlay_14                        | 000ad734            | Data Label        |
| saved_overlay_12                        | 000b2df6            | Data Label        |
| saved_overlay_17                        | 000b99f4            | Data Label        |
| saved_overlay_16                        | 000bd984            | Data Label        |
| saved_overlay_15                        | 000c192e            | Data Label        |
| saved_overlay_14                        | 000c58f6            | Data Label        |
| saved_overlay_26                        | 000c98ee            | Data Label        |
| saved_overlay_1                         | 000d82ae            | Data Label        |

TODO: Overlays should probably be incorporated into the main memory map at the point they appear.

## Overlay #0: Main game sounds

Megadrive's sufficiently different to not match up.

| Name                     | Location           | Type       |
|--------------------------|--------------------|------------|
| sequence_table_index_0   | overlay0::0001bc3e | Data Label |
| instrument_table_index_0 | overlay0::0001bc42 | Data Label |
| overlay28_index_0        | overlay0::0001bc46 | Data Label |
| sound_sequence_0_1       | overlay0::0001bc50 | Data Label |
| sound_sequence_0_2       | overlay0::0001bc5b | Data Label |
| sound_sequence_0_3       | overlay0::0001bc66 | Data Label |
| sound_sequence_0_4       | overlay0::0001bc74 | Data Label |
| sound_sequence_0_5       | overlay0::0001bc85 | Data Label |
| sound_sequence_0_6       | overlay0::0001bc93 | Data Label |
| sound_sequence_0_72      | overlay0::0001bca1 | Data Label |
| sound_sequence_0_73      | overlay0::0001bcaf | Data Label |
| sound_sequence_0_74      | overlay0::0001bcbd | Data Label |
| sound_sequence_0_75      | overlay0::0001bccb | Data Label |
| sound_sequence_0_7       | overlay0::0001bcd9 | Data Label |
| sound_sequence_0_8       | overlay0::0001bce7 | Data Label |
| sound_sequence_0_9       | overlay0::0001bcf5 | Data Label |
| sound_sequence_0_68      | overlay0::0001bd08 | Data Label |
| sound_sequence_0_69      | overlay0::0001bd1b | Data Label |
| sound_sequence_0_70      | overlay0::0001bd2e | Data Label |
| sound_sequence_0_10      | overlay0::0001bd41 | Data Label |
| sound_sequence_0_11      | overlay0::0001bd54 | Data Label |
| sound_sequence_0_13      | overlay0::0001bd5f | Data Label |
| sound_sequence_0_14      | overlay0::0001bd6a | Data Label |
| sound_sequence_0_15      | overlay0::0001bd78 | Data Label |
| sound_sequence_0_16      | overlay0::0001bd98 | Data Label |
| sound_sequence_0_17      | overlay0::0001bdb8 | Data Label |
| sound_sequence_0_18      | overlay0::0001bdcb | Data Label |
| sound_sequence_0_19      | overlay0::0001bdda | Data Label |
| sound_sequence_0_20      | overlay0::0001bded | Data Label |
| sound_sequence_0_21      | overlay0::0001bdfd | Data Label |
| sound_sequence_0_22      | overlay0::0001be15 | Data Label |
| sound_sequence_0_23      | overlay0::0001be30 | Data Label |
| sound_sequence_0_24      | overlay0::0001be3c | Data Label |
| sound_sequence_0_25      | overlay0::0001be4b | Data Label |
| sound_sequence_0_26      | overlay0::0001be60 | Data Label |
| sound_sequence_0_27      | overlay0::0001be7b | Data Label |
| sound_sequence_0_28      | overlay0::0001be8a | Data Label |
| sound_sequence_0_29      | overlay0::0001bea4 | Data Label |
| sound_sequence_0_71      | overlay0::0001beb4 | Data Label |
| sound_sequence_0_30      | overlay0::0001bec2 | Data Label |
| sound_sequence_0_76      | overlay0::0001bee0 | Data Label |
| sound_sequence_0_31      | overlay0::0001bf01 | Data Label |
| sound_sequence_0_32      | overlay0::0001bf20 | Data Label |
| sound_sequence_0_33      | overlay0::0001bf36 | Data Label |
| sound_sequence_0_34      | overlay0::0001bf4c | Data Label |
| sound_sequence_0_35      | overlay0::0001bf5a | Data Label |
| sound_sequence_0_36      | overlay0::0001bf6a | Data Label |
| sound_sequence_0_37      | overlay0::0001bf78 | Data Label |
| sound_sequence_0_38      | overlay0::0001bf8e | Data Label |
| sound_sequence_0_39      | overlay0::0001bf9f | Data Label |
| sound_sequence_0_40      | overlay0::0001bfb4 | Data Label |
| sound_sequence_0_41      | overlay0::0001bfca | Data Label |
| sound_sequence_0_77      | overlay0::0001c01e | Data Label |
| sound_sequence_0_42      | overlay0::0001c075 | Data Label |
| sound_sequence_0_43      | overlay0::0001c085 | Data Label |
| sound_sequence_0_44      | overlay0::0001c09c | Data Label |
| sound_sequence_0_45      | overlay0::0001c0ac | Data Label |
| sound_sequence_0_46      | overlay0::0001c0bc | Data Label |
| sound_sequence_0_47      | overlay0::0001c0d5 | Data Label |
| sound_sequence_0_48      | overlay0::0001c162 | Data Label |
| sound_sequence_0_62      | overlay0::0001c1b7 | Data Label |
| sound_sequence_0_12      | overlay0::0001c1dd | Data Label |
| sound_sequence_0_63      | overlay0::0001c232 | Data Label |
| sound_sequence_0_64      | overlay0::0001c275 | Data Label |
| sound_sequence_0_49      | overlay0::0001c2c8 | Data Label |
| sound_sequence_0_50      | overlay0::0001c2ee | Data Label |
| sound_sequence_0_51      | overlay0::0001c32e | Data Label |
| sound_sequence_0_52      | overlay0::0001c34f | Data Label |
| sound_sequence_0_53      | overlay0::0001c380 | Data Label |
| sound_sequence_0_54      | overlay0::0001c3ba | Data Label |
| sound_sequence_0_55      | overlay0::0001c3cf | Data Label |
| sound_sequence_0_56      | overlay0::0001c3e5 | Data Label |
| sound_sequence_0_57      | overlay0::0001c407 | Data Label |
| sound_sequence_0_58      | overlay0::0001c41a | Data Label |
| sound_sequence_0_59      | overlay0::0001c428 | Data Label |
| sound_sequence_0_60      | overlay0::0001c464 | Data Label |
| sound_sequence_0_61      | overlay0::0001c4b7 | Data Label |
| sound_sequence_0_65      | overlay0::0001c4c5 | Data Label |
| sound_sequence_0_66      | overlay0::0001c4d5 | Data Label |
| sound_sequence_0_67      | overlay0::0001c4e8 | Data Label |
| sequence_table_0         | overlay0::0001c4fa | Data Label |
| sound_sample_0_0         | overlay0::0001c632 | Data Label |
| sound_sample_0_1         | overlay0::0001c642 | Data Label |
| sound_sample_0_2         | overlay0::0001c652 | Data Label |
| sound_sample_0_3         | overlay0::0001c662 | Data Label |
| sound_sample_0_4         | overlay0::0001c66a | Data Label |
| sound_sample_0_5         | overlay0::0001c68a | Data Label |
| sound_sample_0_6         | overlay0::0001c6a2 | Data Label |
| sound_sample_0_7         | overlay0::0001c6aa | Data Label |
| sound_sample_0_8         | overlay0::0001c6ba | Data Label |
| sound_sample_0_9         | overlay0::0001c6da | Data Label |
| sound_sample_0_34        | overlay0::0001d1e2 | Data Label |
| sound_sample_0_35        | overlay0::0001dd51 | Data Label |
| sound_sample_0_36        | overlay0::0001e8c0 | Data Label |
| sound_sample_0_37        | overlay0::0001f42e | Data Label |
| sound_sample_0_11        | overlay0::0001ff9e | Data Label |
| sound_sample_0_10        | overlay0::0001ff9e | Data Label |
| sound_sample_0_13        | overlay0::00022466 | Data Label |
| sound_sample_0_38        | overlay0::00022c58 | Data Label |
| sound_sample_0_39        | overlay0::0002344a | Data Label |
| sound_sample_0_40        | overlay0::0002344a | Data Label |
| sound_sample_0_12        | overlay0::00023c3a | Data Label |
| sound_sample_0_14        | overlay0::00026102 | Data Label |
| sound_sample_0_15        | overlay0::000272a0 | Data Label |
| sound_sample_0_16        | overlay0::00027a20 | Data Label |
| sound_sample_0_17        | overlay0::0002816c | Data Label |
| sound_sample_0_18        | overlay0::00029234 | Data Label |
| sound_sample_0_19        | overlay0::0002a1ae | Data Label |
| sound_sample_0_30        | overlay0::0002a780 | Data Label |
| sound_sample_0_20        | overlay0::0002a780 | Data Label |
| sound_sample_0_21        | overlay0::0002b43a | Data Label |
| sound_sample_0_23        | overlay0::0002be88 | Data Label |
| sound_sample_0_24        | overlay0::0002c5bc | Data Label |
| sound_sample_0_32        | overlay0::0002e3ca | Data Label |
| sound_sample_0_33        | overlay0::0002f568 | Data Label |
| sound_sample_0_41        | overlay0::0002faea | Data Label |
| sound_sample_0_42        | overlay0::0003045c | Data Label |
| sound_sample_0_22        | overlay0::00030d56 | Data Label |
| sound_sample_0_25        | overlay0::00030d56 | Data Label |
| sound_sample_0_26        | overlay0::00031d72 | Data Label |
| sound_sample_0_27        | overlay0::00032d46 | Data Label |
| sound_sample_0_28        | overlay0::000344f4 | Data Label |
| sound_sample_0_29        | overlay0::00034bdc | Data Label |
| sound_sample_0_31        | overlay0::000353ec | Data Label |
| instrument_table_0       | overlay0::00035f7c | Data Label |
| base_status_bar          | overlay0::000361d6 | Data Label |

## Overlay #1: Management graphics

Megadrive has pretty much the same symbols, but different encoding to
match the machine's hardware. The symbols are mostly in a different
order, so I'm not going to match them up.

| splash_backdrop             | overlay1::000361d6 | Data Label |
| sprites_mgmt_background     | overlay1::0003d744 | Data Label |
| sprites_font_orange         | overlay1::00044364 | Data Label |
| sprites_menu_font           | overlay1::00044b5c | Data Label |
| sprites_fonts_titles_top    | overlay1::0004631c | Data Label |
| sprites_fonts_titles_bottom | overlay1::0004677c | Data Label |
| sprites_fonts_cash          | overlay1::00046a9c | Data Label |
| sprites_fonts_mgr_xfer_gym  | overlay1::00046bdc | Data Label |
| sprites_fonts_small_green   | overlay1::0004703c | Data Label |
| sprites_fonts_white         | overlay1::000475dc | Data Label |
| sprites_mgmt_lights         | overlay1::00047b7c | Data Label |
| sprites_mgmt_buttons        | overlay1::0004857c | Data Label |
| sprites_mgmt_armour         | overlay1::0004d57c | Data Label |
| sprites_player_faces        | overlay1::000531fc | Data Label |
| sprites_group_logo          | overlay1::0005b8fc | Data Label |
| scores_table                | overlay1::0005d51c | Data Label |
| gym_tile_map                | overlay1::0005dd1c | Data Label |
| manager_transfer_tile_map   | overlay1::0005de20 | Data Label |

## Overlays #18 and #26: Game graphics

Similar to overlay #1.

| Name                      | Location            | Type       |
|---------------------------|---------------------|------------|
| sprites_players_team_mask | overlay18::000361d6 | Data Label |
| sprites_game_misc         | overlay18::0003a2d6 | Data Label |
| sprites_players           | overlay18::0003cf56 | Data Label |
| sprites_big_ball          | overlay18::0004d356 | Data Label |
| sprites_launcher          | overlay18::0004dd56 | Data Label |
| sprites_arena_offset      | overlay26::0004fe36 | Data Label |
| sprites_arena             | overlay26::0004fed6 | Data Label |

## Overlays #27 and #28: Sound patches

Patches the sound samples between management mode and game mode.

| Name      | Location            | Type       |
|-----------|---------------------|------------|
| overlay27 | overlay27::00030d56 | Data Label |
| overlay28 | overlay28::00030d56 | Data Label |
