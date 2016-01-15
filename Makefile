
run:
	rebar compile && erl -pa .. -pa ebin -pa deps/*/ebin -eval "application:ensure_all_started(erlhive), sync:go()."
