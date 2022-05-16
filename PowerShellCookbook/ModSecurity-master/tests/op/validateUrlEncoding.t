### Empty
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "",
	ret => 0,
},

### General
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "Hello%20World!",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "Hello+World!",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "HelloWorld!",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%00Hello%20World!",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "Hello%20World!%00",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%00",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%ff",
	ret => 0,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%0",
	ret => 1,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%f",
	ret => 1,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%",
	ret => 1,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%0z",
	ret => 1,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%z0",
	ret => 1,
},
{
	type => "op",
	name => "validateUrlEncoding",
	param => "",
	input => "%0%",
	ret => 1,
},
