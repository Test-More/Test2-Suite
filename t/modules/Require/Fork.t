use strict;
use warnings;

# Prevent Test2::Util from making 'CAN_FORK' a constant
my $forks;
BEGIN {
    require Test2::Util;
    local $SIG{__WARN__} = sub { 1 }; # no warnings is not sufficient on older perls
    *Test2::Util::CAN_FORK = sub { $forks };
}

use lib './t/lib';
use Test2::Bundle::Extended -target => 'MyTest::Test2::Require::Fork';

{
    $forks = 0;
    is($CLASS->skip(), 'This test requires a perl capable of forking.', "will skip");

    $forks = 1;
    is($CLASS->skip(), undef, "will not skip");
}

done_testing;
