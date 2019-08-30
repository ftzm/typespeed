let
  tag = env:DOCKER_TAG as Text

in
  { name =
  	"typespeed"
  , port =
  	80
  , tag =
  	tag
  , gateway =
  	"main-gateway"
  , hosts =
  	[ "typespeed.fitzsimmons.io"]
  }
