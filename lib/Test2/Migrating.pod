=pod

=head1 MIGRATING

There are good reasons for migrating from the Test:: family of modules to
the Test2:: modules. This document as well as describing some of these
reaasons also aims to give some simple guidance on how to migrate your
tests to Test2.

=head1 EXAMPLE

=head2 Test::

	use strict;
	use utf8;
	use warnings;

	use Test::Deep;
	use Test::Fatal;
	use Test::More;
	use Test::Warnings;

	binmode Test::More->builder->$_, ':encoding(UTF-8)'
	    for qw/failure_output output/;

	ok 1;

	is $foo, $bar;

	is_deeply $foo => [1..9];

	like $foo, qr/A-Z/;

	cmp_deeply $foo => {
	    bar => ignore,
	    baz => re(qr(A-Z)),
	    qux => 1,
	};

	is warning { ... }, 'foo';

	dies_ok { ... };

	done_testing;

=head2 Test2::

	use Test2::V0;

	ok 1;

	is $foo, $bar;

	is $foo => [1..9];

	like $foo, qr/A-Z/;

	like $foo => {
	    baz => qr(A-Z),
	    qux => 1,
	};

	is warning { ... }, 'foo';

	ok dies { ... };

	done_testing;

=cut

