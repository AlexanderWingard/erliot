-module(erliot_ws_client).
-include("erliot.hrl").

-behaviour(websocket_client_handler).

-export([
         start_link/1,
         init/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).

-record(?MODULE, {}).

start_link(URL) ->
    crypto:start(),
    ssl:start(),
    websocket_client:start_link(URL, ?MODULE, []).

init([], _ConnState) ->
    gproc:reg({p, l, ?erliot_bcast}),
    {ok, #?MODULE{}}.

websocket_handle({text, JSON}, _ConnState, State) ->
    try
        jiffy:decode(JSON, [return_maps]),
        websocket_handle_JSON(JSON)
    catch Error ->
            io:format("JSON decode error: ~p~n", [Error])
    end,
    {ok, State}.

websocket_handle_JSON(JSON) ->
    Bcast = #?erliot_bcast{from = self(), data = JSON},
    gproc:bcast({p, l, ?erliot_bcast}, Bcast).


websocket_info(#erliot_bcast{from = F, data = JSON}, _, State) when F /= self() ->
    websocket_handle_info(JSON),
    {reply, {text, JSON}, State};
websocket_info(_, _, State) ->
    {ok, State}.

websocket_handle_info(JSON) ->
    ok.

websocket_terminate(Reason, _ConnState, State) ->
    ok.
