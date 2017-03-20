use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Tools::Exception';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


{
    package Foo;
    use Test2::Tools::Exception qw/dies lives try_ok/;
    ::imported_ok(qw/dies lives try_ok/);
}

use Test2::API qw/intercept/;

like(
    dies { die 'xyz' },
    qr/xyz/,
    "Got exception"
);

is(dies { 0 }, undef, "no exception");

{
    local $@ = 'foo';
    ok(lives { 0 }, "it lives!");
    is($@, "foo", "did not change \$@");
}

ok(!lives { die 'xxx' }, "it died");
like($@, qr/xxx/, "Exception is available");

try_ok { 0 } "No Exception from try_ok";

my $err;
is(
    intercept { try_ok { die 'abc' } "foo"; $err = $@; },
    array {
        fail_events Ok => sub {
            call name => "foo";
            call pass => 0;
        };
        event Diag => sub { msg => match qr/abc/; };
    },
    "Got failure + diag from try_ok"
);

like($err, qr/abc/, '$@ has the exception');

done_testing;
