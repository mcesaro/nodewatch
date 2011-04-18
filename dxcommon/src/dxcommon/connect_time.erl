%% -----------------------------------------------------------------------------
%%
%% Erlang System Monitoring Commons: Library API
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
-module(dxcommon.connect_time).
-author('Tim Watson <watson.timothy@gmail.com>').
-compile({parse_transform, exprecs}).

-include("dxcommon.hrl").

-export([new/0, sync/1]).
-export_records([connect_time]).

-import(calendar).
-import(erlang).
-import(dxcommon).

new() ->
    %% shortcut
    GSecs = dxcommon.datetime:snapshot(),
    #connect_time{snapshot=GSecs}.

sync(#connect_time{elapsed=Elapsed,
                   snapshot=ThenGS}=CT) ->
    NowGS = dxcommon.datetime:snapshot(),
    CT#connect_time{elapsed=(Elapsed + (NowGS - ThenGS)),
                    snapshot=NowGS}.
    