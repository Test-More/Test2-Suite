use strict;
use warnings;
use Test2::V0;


use ok 'Scalar::Util' => qw/blessed reftype/;
use ok 'List::Util' => qw/min max shuffle/;


ok(require Exporter, "Loaded Exporter");

{
    package p1;
    sub p1 { 'p1' }
    package p2;
    sub p2 { 'p2' }
    our @ISA = ('p1');
}

our @ISA = ('p2');

sub new { my $class = shift; bless {@_}, $class }


isa_ok(__PACKAGE__, ['p2', 'p1'], "Check ISA");


can_ok(__PACKAGE__, ['p1', 'p2'], "Check methods");


can_ok(__PACKAGE__, [qw/blessed reftype min max shuffle/], "Check imports");

SKIP: {
    my $todo = todo "foo";
    skip foo => 1;

    die "Should not see this";
}

SKIP: {
    skip bar => 1;

    die "Should not see this";
}

todo 'baz' => sub {
    ok(0, "fixme later");
};



is(
    [1, 2, 3],
    [1, 2, 3],
    "Arrays are the same"
);



is(
    {a => 1, b => 2},
    {a => 1, b => 2},
    "Hashes are the same"
);


use Test2::Tools::Compare qw/bag item/;
is(
    [1, 3, 2],
    bag {
        item 1;
        item 2;
        item 3;
    },
    "Sets are the same"
);

use Data::Dumper;
note Dumper(['a', 'b', 'c']);

ok(my $x = __PACKAGE__->new(a => 1), "Made a new object");
is($x->p1, 'p1', "test p1 method");

my $x2 = $x;
ref_is($x, $x2, '$x and $x2 are the same reference');

todo 'example failure' => sub {
    is(
        {a => 1, b => 2, c => [qw/a b c/], x => {a => 1}, y => '0.0'},
        {a => 2, b => 3, c => [qw/d e f/], x => {b => 2}, y => 0},
        "This will fail"
    );
};

plan 16;
