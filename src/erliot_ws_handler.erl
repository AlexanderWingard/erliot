-module(erliot_ws_handler).
-include("erliot.hrl").

-export([init/2]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

init(Req, Opts) ->
    gproc:reg({p, l, ?erliot_bcast}),
    {cowboy_websocket, Req, Opts}.

websocket_handle({text, JSON}, Req, State) ->
    try
        jiffy:decode(JSON, [return_maps]),
        Bcast = #?erliot_bcast{from = self(), data = JSON},
        gproc:bcast({p, l, ?erliot_bcast}, Bcast)
    catch Error ->
            io:format("JSON decode error: ~p~n", [Error])
    end,
    {ok, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info(#erliot_bcast{from = F, data = JSON}, Req, State) when F /= self() ->
    websocket_handle_info(JSON),
    {reply, {text, JSON}, Req, State};
websocket_info(_, Req, State) ->
    {ok, Req, State}.

websocket_handle_info(_) ->
    ok.
