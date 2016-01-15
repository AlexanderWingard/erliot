-module(ws_handler).

-export([init/2]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

-define(WSKEY, {pubsub,wsbroadcast}).

init(Req, Opts) ->
    gproc:reg({p, l, ?WSKEY}),
    {cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
    Result = try
                 R = jiffy:decode(Msg, [return_maps]),
                 term_to_binary(R)
             catch throw:Reason ->
                     Reason
             end,
    Str = io_lib:format("~w", [Result]),
    gproc:send({p, l, ?WSKEY}, {self(), ?WSKEY, Str}),
    {ok, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info({_PID,?WSKEY, Msg} , Req, State) ->
    {reply, {text, Msg}, Req, State};
websocket_info(Info, Req, State) ->
    io:format("Unexpected message: ~p", [Info]),
    {ok, Req, State}.
