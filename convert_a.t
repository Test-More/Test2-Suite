use strict;
use warnings;
use Test::More tests => 16;

BEGIN {
    use_ok 'Scalar::Util' => qw/blessed reftype/;
    use_ok 'List::Util'   => qw/min max shuffle/;
}

require_ok 'Exporter';

{
    package p1;
    sub p1 { 'p1' }
    package p2;
    sub p2 { 'p2' }
    our @ISA = ('p1');
}

our @ISA = ('p2');

sub new { my $class = shift; bless {@_}, $class }

# Note, this is wrong, but passes!!!
isa_ok(__PACKAGE__, 'p2', 'p1');

# Make sure these methods are available
can_ok(__PACKAGE__, 'p1', 'p2');

# Check imports
can_ok(__PACKAGE__, qw/blessed reftype min max shuffle/);

TODO: {
    local $TODO = 'foo';
    todo_skip foo => 1;

    die "Should not see this";
}

SKIP: {
    skip bar => 1;

    die "Should not see this";
}

{
    local $TODO = 'baz';

    ok(0, "fixme later");
}

ok(
    eq_array(
        [1, 2, 3],
        [1, 2, 3],
    ),
    "Arrays are the same"
);

ok(
    eq_hash(
        {a => 1, b => 2},
        {a => 1, b => 2}
    ),
    "Hashes are the same"
);

ok(
    eq_set(
        [1, 3, 2],
        [1, 2, 3]
    ),
    "Sets are the same"
);



note explain(['a', 'b', 'c']);


my $x = new_ok(__PACKAGE__, [a => 1]);
is($x->p1, 'p1', "test p1 method");

my $x2 = $x;
is($x, $x2, '$x and $x2 are the same reference');

{
    local $TODO = 'example failure';
    is_deeply(
        {a => 1, b => 2, c => [qw/a b c/], x => {a => 1}},
        {a => 2, b => 3, c => [qw/d e f/], x => {b => 2}},
        "This will fail"
    );
}
