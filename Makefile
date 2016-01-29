.PHONY: compile

compile: deps
	./rebar compile

deps: rebar rebar.config
	./rebar get-deps

rebar:
	curl -OL https://github.com/rebar/rebar/wiki/rebar
	chmod a+x rebar
