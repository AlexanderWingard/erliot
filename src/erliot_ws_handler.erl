-module(erliot_ws_handler).
-include("erliot.hrl").

-export([init/2]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

init(Req, Opts) ->
    gproc:reg({p, l, ?erliot_json}),
    {cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
    Result = try
                 jiffy:decode(Msg, [return_maps])
             catch throw:Reason ->
                     Reason
             end,
    gproc:send({p, l, ?erliot_json}, {?erliot_json, jiffy:encode(Result)}),
    gproc:send({p, l, ?erliot_binary}, {?erliot_binary, term_to_binary(Result)}),
    {ok, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info({?erliot_json, Msg} , Req, State) ->
    io:format("JSON: ~p~n",[Msg]),
    {reply, {text, Msg}, Req, State};
websocket_info(Info, Req, State) ->
    io:format("Unexpected message: ~p", [Info]),
    {ok, Req, State}.
