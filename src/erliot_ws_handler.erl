-module(erliot_ws_handler).
-include("erliot.hrl").

-export([init/2]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

init(Req, Opts) ->
    gproc:reg({p, l, ?erliot_json}),
    {cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
    try
        Term = jiffy:decode(Msg, [return_maps]),
        websocket_handle_term(Term)
    catch Error ->
            io:format("JSON decode error: ~p~n", [Error])
    end,
    {ok, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_handle_term(Term) ->
    gproc:bcast({p, l, ?erliot_json}, {?erliot_json, jiffy:encode(Term)}),
    gproc:bcast({p, l, ?erliot_binary}, {?erliot_binary, term_to_binary(Term)}).

websocket_info(Msg, Req, State) ->
    Reply = websocket_handle_info(Msg),
    case Reply of
        {reply, R} ->
            {reply, R, Req, State};
        ok ->
            {ok, Req, State}
    end.

websocket_handle_info({?erliot_json, Msg}) ->
    {reply, {text, Msg}};
websocket_handle_info(_Msg) ->
    ok.
