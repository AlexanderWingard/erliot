-module(erliot_registry).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
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

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

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
    {ok, Socket} = gen_tcp:connect(IP, Port, [{active, true}, {packet, 2}, binary]),
    gproc:reg({n, l, {tcp_serial, IP, Port}}),
    client_loop(Socket).

client_loop(Socket) ->
    gen_tcp:send(Socket, term_to_binary(<<"ping">>)),
    timer:sleep(1000),
    receive
        {tcp, Sock, Data} ->
            io:format("~p~n", [binary_to_term(Data)]),
            client_loop(Socket);
        {tcp_closed, _} ->
            gen_tcp:close(Socket)
    after 0 ->
            client_loop(Socket)
    end.
