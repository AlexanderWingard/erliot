-module(erliot_registry).
-behaviour(gen_server).

-include("erliot.hrl").

-export([start_link/0]).

-export([init/1, handle_info/2,
         terminate/2, code_change/3, client/2]).

-define(SERVER, ?MODULE).

-record(state, {multisocket}).
-record(udp, {socket, ip, inportno, packet}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, S} = gen_udp:open(6000, [{active, true}, {mode, binary}]),
    {ok, #state{multisocket = S}}.

handle_info(#udp{ip = IP, packet = P}, State) ->
    {erliot_announce, tcp_serial, Port} = binary_to_term(P),
    case gproc:lookup_pids({n, l, {tcp_serial, IP, Port}}) of
        [] ->
            spawn_link(?MODULE, client, [IP, Port]),
            gproc:await({n, l, {tcp_serial, IP, Port}});
        _Pid ->
            ok
    end,
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

client(IP, Port) ->
    {ok, Socket} = gen_tcp:connect(IP, Port, [{active, true},
                                              {packet, 2},
                                              {exit_on_close, true},
                                              {send_timeout, 5000},
                                              {send_timeout_close, true},
                                              binary]),
    gproc:reg({n, l, {tcp_serial, IP, Port}}),
    gproc:reg({p, l, ?erliot_bcast}),
    client_loop(Socket).

client_loop(Socket) ->
    receive
        #?erliot_bcast{from = F} when F == self() ->
            client_loop(Socket);
        #?erliot_bcast{data = Msg} ->
            client_handle(Socket, Msg);
        Other ->
            client_handle(Socket, Other)
    end.

client_handle(Socket, {tcp, Sock, Data}) ->
    Term = binary_to_term(Data),
    JSON = jiffy:encode(Term),
    gproc:bcast({p, l, ?erliot_bcast}, #?erliot_bcast{from = self(), data = JSON}),
    client_loop(Socket);
client_handle(Socket, {tcp_closed, _}) ->
    gen_tcp:close(Socket);
client_handle(Socket, {tcp_error, _, Reason}) ->
    gen_tcp:close(Socket);
client_handle(Socket, JSON) ->
    Term = jiffy:decode(JSON, [return_maps]),
    Bin = term_to_binary(Term),
    case gen_tcp:send(Socket, Bin) of
        ok ->
            client_loop(Socket)
    end.


