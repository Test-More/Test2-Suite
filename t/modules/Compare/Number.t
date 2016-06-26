use Test2::Bundle::Extended -target => 'Test2::Compare::Number';

my $num    = $CLASS->new( input => '22.0' );
my $untrue = $CLASS->new( input => 0 );
my $negate = $CLASS->new( input => '22.0', negate => 1 );

isa_ok( $num,    $CLASS, 'Test2::Compare::Base' );
isa_ok( $untrue, $CLASS, 'Test2::Compare::Base' );

subtest name => sub {
    is( $num->name,    '22.0', "got expected name for number" );
    is( $untrue->name, '0',    "got expected name for 0" );
    is( $negate->name, '22.0', "got expected name for negate numebr" );
};

subtest operator => sub {
    is( $num->operator(),         '', "no operator for number + nothing" );
    is( $num->operator(undef),    '', "no operator for number + undef" );
    is( $num->operator('string'), '', "no operator for string" );
    is( $num->operator(1), '==', "== operator for number equality comparison" );

    is( $untrue->operator(),         '', "no operator for 0 + nothing" );
    is( $untrue->operator(undef),    '', "no operator for 0 + undef" );
    is( $untrue->operator('string'), '', "no operator for string" );
    is( $untrue->operator(1),
        '==', "== operator for number equality comparison" );

    is( $negate->operator(),         '', "no operator for 0 + nothing" );
    is( $negate->operator(undef),    '', "no operator for 0 + undef" );
    is( $negate->operator('string'), '', "no operator for string" );
    is( $negate->operator(1),
        '!=', "!= operator for number equality comparison" );

};

subtest verify => sub {
    ok( !$num->verify( exists => 0, got => undef ),
        'does not verify against DNE' );
    ok( !$num->verify( exists => 1, got => {} ), 'ref will not verify' );
    ok(
        !$num->verify( exists => 1, got => undef ),
        'looking for a number, not undef'
    );
    ok( !$num->verify( exists => 1, got => 'x' ), 'not looking for a string' );
    ok( !$num->verify( exists => 1, got => 1 ),   'wrong number' );
    ok( $num->verify( exists => 1, got => 22 ), '22.0 == 22' );
    ok( $num->verify( exists => 1, got => '22.0' ),
        'exact match with decimal' );

    ok( !$untrue->verify( exists => 0, got => undef ),
        'does not verify against DNE' );
    ok( !$untrue->verify( exists => 1, got => {} ), 'ref will not verify' );
    ok( !$untrue->verify( exists => 1, got => undef ),
        'undef is not 0 for this test' );
    ok( !$untrue->verify( exists => 1, got => 'x' ), 'x is not 0' );
    ok( !$untrue->verify( exists => 1, got => 1 ),   '1 is not 0' );
    ok( !$untrue->verify( exists => 1, got => '' ),  '"" is not 0' );
    ok( !$untrue->verify( exists => 1, got => ' ' ), '" " is not 0' );
    ok( $untrue->verify( exists => 1, got => 0 ),      'got 0' );
    ok( $untrue->verify( exists => 1, got => '0.0' ),  '0.0 == 0' );
    ok( $untrue->verify( exists => 1, got => '-0.0' ), '-0.0 == 0' );

    ok( !$negate->verify( exists => 0, got => undef ),
        'does not verify against DNE' );
    ok( !$negate->verify( exists => 1, got => {} ), 'ref will not verify' );
    ok( !$negate->verify( exists => 1, got => undef ),
        'looking for a number, not undef' );
    ok( !$negate->verify( exists => 1, got => 'x' ),
        'not looking for a string' );
    ok( !$negate->verify( exists => 1, got => '22.0' ), '!22.0 != 22' );
    ok( $negate->verify( exists => 1, got => 2 ), '2 != 22.0' );

};

like(
    dies { $CLASS->new() },
    qr/input must be defined for 'Number' check/,
    "Cannot use undef as a number"
);

like(
    dies { $CLASS->new( input => '' ) },
    qr/input must be a number for 'Number' check/,
    "Cannot use empty string as a number"
);

like(
    dies { $CLASS->new( input => ' ' ) },
    qr/input must be a number for 'Number' check/,
    "Cannot use whitespace string as a number"
);

like(
    dies { $CLASS->new( input => 'not_a_number' ) },
    qr/input must be a number for 'Number' check/,
    "Cannot use string as a number"
);

done_testing;
