.PHONY: run

compile: rebar3
	./rebar3 shell

rebar3:
	curl -O https://s3.amazonaws.com/rebar3/rebar3
	chmod a+x rebar3
