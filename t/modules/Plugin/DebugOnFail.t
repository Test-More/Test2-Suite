use Test2::V0;
use Test2::API qw/intercept/;

my ($start, $second, $third);
my $events = intercept {
    require Test2::Plugin::DebugOnFail;
    Test2::Plugin::DebugOnFail->import;

    my $warn;
    local $SIG{__WARN__} = sub { ($warn) = @_ };

    $start = $warn;
    ok(1);
    $second = $warn;
    ok(0);
    $third = $warn;
};

is($start, undef, "Not set initially");
is($second, undef, "Not set after pass");
is($third, "Test failure detected, stopping debugger...\n", "Is set after pass");

done_testing;
