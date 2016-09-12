use Test2::Bundle::Extended ':v2', -target => 'Test2::Util::Misc';

use Test2::Util::Misc qw/deprecate_pins_before/;

imported_ok qw/deprecate_pins_before/;

my $sub = deprecate_pins_before(5);
ref_ok($sub, 'CODE', "Got a code ref");

my $caller = [ __PACKAGE__, 'a_file', 42 ];

ok(!warning { $sub->($caller, 'v5') }, "No warnings when using latest pin");

ok(!warning { $sub->($caller, 'v1') }, "No warnings when using older pin");

like(
    warning { $sub->($caller, undef) },
    <<"    EOT",
Importing from main without a pin is deprecated at a_file line 42.
This can be fixed by using the 'v1' pin:
    use main ':v1';

Or you can use the latest pin (API may change between pins)
    use main ':v5';
    EOT
    "Got warning with no pin"
);

{
    local $ENV{T2_WARN_OLD_PINS} = 1;

    ok(!warning { $sub->($caller, 'v5') }, "No warnings when using latest pin");

    like(
        warning { $sub->($caller, 'v4') },
        "Importing from main using old pin v4, latest pin is v5 at a_file line 42.\n",
        "Can ask to warn about old pins",
    );

    ok(!warning { $sub->($caller, 'xyz') }, "No warnings when using non-version pin");
}

done_testing;
