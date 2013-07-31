serve:
	mix do compile, server

watch:
	( sass --watch priv/sass:priv/static/css & )
	while true; do sleep 1; done
