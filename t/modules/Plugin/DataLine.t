use Test2::V0;
use Test2::API qw/intercept/;

my $events = intercept {
    require Test2::Plugin::DataLine;
    Test2::Plugin::DataLine->import;

    package #
        main;

    is(<DATA>, 'nope', "Read data, not correct");
    ok(1, "pass");

    package #
        Foo::Bar;

    open(my $fh, '<', __FILE__) or die "Could not open: $!";
    main::is(<$fh>, 'nope', "Read data, not correct again");
    main::ok(1, "pass");
};

my @failures = map { $_->facet_data } grep { $_->causes_fail } @$events;
my @other    = map { $_->facet_data } grep { !$_->causes_fail } @$events;

is(@failures, 2, "Got 2 failures");

like(
    \@failures,
    [
        {info => bag {{tag => 'DIAG', debug => T(), details => 'Last filehandle read: <DATA> line 1'}}},
        {info => bag {{tag => 'DIAG', debug => T(), details => 'Last filehandle read: <Foo::Bar::$fh> line 1'}}},
    ],
    "Added the extra diagnostics to all failures",
);

ok(!(grep { $_->{info} && $_->{info}->[-1]->{details} !~ m/Last filehandle read/ } @other), "Diags not added to any other events");

done_testing;

__DATA__
ooga booga
oga boga
