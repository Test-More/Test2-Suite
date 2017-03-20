use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Compare::Number';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


my $num    = $CLASS->new(input => '22.0');
my $untrue = $CLASS->new(input => 0);

isa_ok($num,    $CLASS, 'Test2::Compare::Base');
isa_ok($untrue, $CLASS, 'Test2::Compare::Base');

subtest name => sub {
    is($num->name,    '22.0', "got expected name for number");
    is($untrue->name, '0',    "got expected name for 0");
};

subtest operator => sub {
    is($num->operator(),      '',   "no operator for number + nothing");
    is($num->operator(undef), '',   "no operator for number + undef");
    is($num->operator(1),     '==', "== operator for number + number");

    is($untrue->operator(),      '',   "no operator for 0 + nothing");
    is($untrue->operator(undef), '',   "no operator for 0 + undef");
    is($untrue->operator(1),     '==', "== operator for 0 + number");
};

subtest verify => sub {
    ok(!$num->verify(exists => 0, got => undef), 'does not verify against DNE');
    ok(!$num->verify(exists => 1, got => {}),    'ref will not verify');
    ok(!$num->verify(exists => 1, got => undef), 'looking for a number, not undef');
    ok(!$num->verify(exists => 1, got => 'x'),   'not looking for a string');
    ok(!$num->verify(exists => 1, got => 1),     'wrong number');
    ok($num->verify(exists => 1, got => 22),     '22.0 == 22');
    ok($num->verify(exists => 1, got => '22.0'), 'exact match with decimal');

    ok(!$untrue->verify(exists => 0, got => undef), 'does not verify against DNE');
    ok(!$untrue->verify(exists => 1, got => {}),    'ref will not verify');
    ok(!$untrue->verify(exists => 1, got => undef), 'undef is not 0 for this test');
    ok(!$untrue->verify(exists => 1, got => 'x'),   'x is not 0');
    ok(!$untrue->verify(exists => 1, got => 1),     '1 is not 0');
    ok(!$untrue->verify(exists => 1, got => ''),    '"" is not 0');
    ok(!$untrue->verify(exists => 1, got => ' '),   '" " is not 0');
    ok($untrue->verify(exists => 1, got => 0),      'got 0');
    ok($untrue->verify(exists => 1, got => '0.0'),  '0.0 == 0');
    ok($untrue->verify(exists => 1, got => '-0.0'), '-0.0 == 0');
};

like(
    dies { $CLASS->new() },
    qr/input must be defined for 'Number' check/,
    "Cannot use undef as a number"
);

like(
    dies { $CLASS->new(input => '') },
    qr/input must be a number for 'Number' check/,
    "Cannot use empty string as a number"
);

like(
    dies { $CLASS->new(input => ' ') },
    qr/input must be a number for 'Number' check/,
    "Cannot use whitespace string as a number"
);

done_testing;
