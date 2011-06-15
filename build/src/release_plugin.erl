%% -----------------------------------------------------------------------------
%%
%% Nodewatch: Rebar OTP Release (Customisation) Plugin
%%
%% Copyright (c) 2010 Tim Watson (watson.timothy@gmail.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -----------------------------------------------------------------------------
%% @author Tim Watson [http://hyperthunk.wordpress.com]
%% @copyright (c) Tim Watson, 2010 - 2011
%% @since: April 2011
%%
%% @doc Custom rebar build plugin - only intended for use in the release build.
%%
%% -----------------------------------------------------------------------------
-module(release_plugin).

-export([compile/2, generate/2]).

-define(NOTICE, "%% THIS FILE WAS GENERATED BY A SCRIPT - DO NOT EDIT").
-define(TEMPLATE_MOD, reltool_config_template).
-define(INFO(Str, Args), rebar_log:log(info, Str, Args)).
-define(EXCLUDED_APPS, [dxcommon, dxdb, dxkit, 
                        parse_trans, rebar_dist_plugin, fastlog_parse_trans]).

compile(_Config, _) ->
    ?INFO("Is rebar_templater loaded? ~p~n", [code:is_loaded(rebar_templater)]),
    Path = rebar_utils:get_cwd(),
    Dest = filename:join([Path, "reltool.config"]),
    Src = Dest ++ ".src",
    ?INFO("Copying ~p to ~p~n", [Src, Dest]),
    Vsn = git_vsn_plugin:vsn(),

    write(Src, Dest, [{notice, ?NOTICE},
                      {version, Vsn},
                      {erts_vsn, erlang:system_info(version)},
                      {erl_libs, lib_dirs()},
                      {app_deps, incl_apps()}]),
    setup_gen:run([{conf, "nodewatch.conf"},
                   {outdir, "setup"},
                   {name, "nodewatch"},
                   {install, true},
                   {vsn, Vsn},
                   {sys, "files/app.config"}]),
    ok.

generate({_, Path, _Config}, _) ->
    %% For some reason, reltool doesn't like the nodewatch applications stating
    %% that a module (beam file) from *another* application is going to be the
    %% application callback module for them. We explicitly copy over the
    %% appstarter module here, because reltool silently ignores it when copying
    %% the appstart application into the release lib directory
    [TargetDir] = filelib:wildcard(
        filename:absname(filename:join(Path, "nodewatch/lib/appstart-*"))),
    Target = filename:join(TargetDir, filename:join("ebin", "appstarter.beam")),
    case file:copy(code:which(appstarter), Target) of
        {ok,_} -> ok;
        Err -> Err
    end.

lib_dirs() ->
    Paths = case filelib:is_dir("../lib") of
        true ->
            ["../lib"];
        false ->
            ["../lib"|reltool_utils:erl_libs()]
    end,
    Dirs = lists:filter(fun filelib:is_dir/1, Paths),
    lists:flatten([io_lib:format("\"~s\", ", [D]) || D <- Dirs] ++ "\"../\"").

incl_apps() ->
    ConfSet = lists:map(
        fun(F) ->
            {ok, Conf} = file:consult(F),
            proplists:get_value(deps, Conf, [])
        end,
        ["../rebar.config"|filelib:wildcard("../*/rebar.config")]),
    UniqApps = lists:usort([ element(1, D) || D <- lists:flatten(ConfSet) ]),
    Incl = [{app, App, [{incl_cond, include}]}
                        || App <- UniqApps,
                           not lists:member(App, ?EXCLUDED_APPS) ],
    string:join([io_lib:format("~p~n", [Inc]) || Inc <- Incl], ", ").

write(Src, Dest, Vars) ->
    {ok, Bin} = file:read_file(Src),
    Res = rebar_templater:render(Bin, dict:from_list(Vars)),
    case file:write_file(filename:absname(Dest), list_to_binary(Res)) of
        ok -> ok;
        {error, WriteError} ->
            io:format("Failed to write ~p: ~p\n", [Dest, WriteError]),
            halt(1)
    end.
