%% -----------------------------------------------------------------------------
%%
%% Erlang System Monitoring Dashboard: Top Level Supervisor
%%
%% Copyright (c) 2008-2010 Tim Watson (watson.timothy@gmail.com)
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
%%
%% @doc Supervisor for the main web application.
%%
%% The HTTP supervision tree is maintained by the virtual dxweb_http_server,
%% which is itself a supervisor. The notification bridge handles the pub/sub 
%% between events coming out of dxkit and websocket *sessions* (per client).
%%
%% -----------------------------------------------------------------------------

-module(dxweb_sup).
-behaviour(supervisor).

%% API
-export([start_link/1]).
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link(StartArgs) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [StartArgs]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([StartArgs]) ->
    WebConfig = proplists:get_value(webconfig, StartArgs),
    Children = [
        {dxweb_event_sink, 
            {dxweb_event_sink, start_link, []},
            permanent, 5000, worker, [gen_server]},
        {dxweb_http_server,
            {dxweb_http_server, start_link, [WebConfig]},
            permanent, infinity, supervisor, [supervisor]},
        {dxweb_post_start, 
            {dxweb_event_sink, start_listening, []},
            temporary, brutal_kill, worker, dynamic}
    ],
    {ok, {{one_for_one, 10, 10}, Children}}.
