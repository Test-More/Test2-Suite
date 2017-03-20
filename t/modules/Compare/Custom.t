use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Compare::Custom';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }

my $pass = $CLASS->new(code => sub { 1 });
my $fail = $CLASS->new(code => sub { 0 });

isa_ok($pass, $CLASS, 'Test2::Compare::Base');
isa_ok($fail, $CLASS, 'Test2::Compare::Base');

ok($pass->verify(got => "anything"), "always passes");
ok(!$fail->verify(got => "anything"), "always fails");

is($pass->operator, 'CODE(...)', "default operator");
is($pass->name, '<Custom Code>', "default name");

my $args;
my $under;
my $one = $CLASS->new(code => sub { $args = {@_}; $under = $_ }, name => 'the name', operator => 'the op');
$_ = undef;
$one->verify(got => 'foo', exists => 'x');
is($_, undef, '$_ restored');

is($args, {got => 'foo', exists => 'x', operator => 'the op', name => 'the name'}, "Got the expected args");
is($under, 'foo', '$_ was set');

like(
    dies { $CLASS->new() },
    qr/'code' is required/,
    "Need to provide code"
);

done_testing;
