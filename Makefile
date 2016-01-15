.PHONY: run

run: deps
	./rebar compile && erl -pa .. -pa ebin -pa deps/*/ebin -eval "application:ensure_all_started(erliot), sync:go()."

deps: rebar rebar.config
	./rebar get-deps

rebar:
	curl -OL https://github.com/rebar/rebar/wiki/rebar
	chmod a+x rebar
