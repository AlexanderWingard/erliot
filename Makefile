
run:
	rebar compile && erl -pa .. -pa ebin -pa deps/*/ebin -eval "application:ensure_all_started(erliot), sync:go()."
