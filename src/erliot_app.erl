-module(erliot_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {file, "priv/index.html"}},
			{"/websocket", erliot_ws_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{ip, {0,0,0,0,0,0,0,0}},{port, 8080}], [{env, [{dispatch, Dispatch}]}]),
	erliot_sup:start_link().

stop(_State) ->
	ok.
