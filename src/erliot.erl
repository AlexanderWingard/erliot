-module(erliot).
-include_lib("stdlib/include/ms_transform.hrl").

dbg() ->
    dbg:start(),
    dbg:tracer(),
    dbg:tpl(erliot_registry, client, []),
    dbg:tpl(erliot_registry, client_handle, []),
    dbg:tpl(erliot_ws_handler, websocket_handle_info, []),
    dbg:tpl(erliot_ws_handler, websocket_handle_term, []),
    dbg:tpl(erliot_ws_client, websocket_handle_info, []),
    dbg:tpl(erliot_ws_client, websocket_handle_term, []),
    dbg:tpl(erliot_ws_client, websocket_terminate, []),
    dbg:p(all, c).

stop_dbg() ->
    seq_trace:set_token([]),
    dbg:stop_clear().

gproc() ->
    gproc:select([{{'$1','$2','$3'},[],['$$']}]).
