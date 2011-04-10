%% ------------------------------------------------------------------------------
%%
%% Erlang System Monitoring Dashboard: Bridges a process to dxkit_event_handler
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
%% ------------------------------------------------------------------------------
%%
%% @doc TBC
%%
%% ------------------------------------------------------------------------------

-module(dxweb_event_bridge).
-author('Tim Watson <watson.timothy@gmail.com>').
-behaviour(gen_event).

-export([init/1
        ,handle_event/2
        ,handle_call/2
        ,handle_info/2
        ,terminate/2
        ,code_change/3]).

-include("../include/types.hrl").

-record(state, {logfile, level}).

init([]) ->
  {ok, #state{}}.

handle_event(_Message, State) ->
  {ok, State}.

%%
%% @private
%% 
handle_call(_, State) ->
  {ok, ignored, State}.

%%
%% @private
%% 
handle_info(_Info, State) ->
  {ok, State}.

%%
%% @private
%% 
terminate(_Reason, _State) ->
  ok.

%%
%% @private
%% 
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
