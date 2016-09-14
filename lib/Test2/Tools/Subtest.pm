package Test2::Tools::Subtest;
use strict;
use warnings;

our $VERSION = '0.000059';

use Test2::API qw/context run_subtest/;
use Test2::Util qw/try/;

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/subtest_streamed subtest_buffered/;
sub IMPORTER_MENU {
    return (
        export        => \@EXPORT,
        export_on_use => deprecate_pins_before(2),
        export_pins   => {
            root_name => 'no-pin',
            'v1'      => {inherit => 'no-pin'},
            'v2'      => {inherit => 'v1'},
        },
    );
}

sub subtest_streamed {
    my $name = shift;
    my $params = ref($_[0]) eq 'HASH' ? shift(@_) : {};
    my $code = shift;

    $params->{buffered} = 0 unless defined $params->{buffered};

    my $ctx = context();
    my $pass = run_subtest("Subtest: $name", $code, $params, @_);
    $ctx->release;
    return $pass;
}

sub subtest_buffered {
    my $name = shift;
    my $params = ref($_[0]) eq 'HASH' ? shift(@_) : {};
    my $code = shift;

    $params->{buffered} = 1 unless defined $params->{buffered};

    my $ctx = context();
    my $pass = run_subtest($name, $code, $params, @_);
    $ctx->release;
    return $pass;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Subtest - Tools for writing subtests

=head1 DESCRIPTION

This package exports subs that let you write subtests.

There are two types of subtests, buffered and streamed. Streamed subtests mimic
subtests from L<Test::More> in that they render all events as soon as they are
produced. Buffered subtests wait until the subtest completes before rendering
any results.

The main difference is that streamed subtests are unreadable when combined with
concurrency. Buffered subtests look fine with any number of concurrent threads
and processes.

=head1 SYNOPSIS

=head2 BUFFERED

    use Test2::Tools::Subtest qw/+v2 subtest_buffered/;

    subtest_buffered my_test => sub {
        ok(1, "subtest event A");
        ok(1, "subtest event B");
    };

This will produce output like this:

    ok 1 - my_test {
        ok 1 - subtest event A
        ok 2 - subtest event B
        1..2
    }

=head2 STREAMED

The default option is 'buffered'. If you want streamed subtests,
the way L<Test::Builder> does it, use this:

    use Test2::Tools::Subtest qw/+v2 subtest_streamed/;

    subtest_streamed my_test => sub {
        ok(1, "subtest event A");
        ok(1, "subtest event B");
    };

This will produce output like this:

    # Subtest: my_test
        ok 1 - subtest event A
        ok 2 - subtest event B
        1..2
    ok 1 - Subtest: my_test

=head1 IMPORTANT NOTE

You can use C<bail_out> or C<skip_all> in a subtest, but not in a BEGIN block
or C<use> statement. This is due to the way flow control works within a BEGIN
block. This is not normally an issue, but can happen in rare conditions using
eval, or script files as subtests.

=head1 EXPORTS

=head2 EXPORT PINS

B<The current pin used by all of Test::Suite is C<v2>.>

Export pins are how L<Test2::Suite> manages changes that could break backwords
compatability. If we need to break backwards compatability we will do so by
releasing a new pin. Old pins will continue to import the old functionality
while new pins will import the new functionality.

There are several ways to specify a pin:

    # Import all the defaults provided by the 'v2' pin
    use Package ':v2';

    # Import foo, bar, and baz deom the v2 pin.
    use Package '+v2' => [qw/foo bar baz/];

    # Import 'foo' from the v2 pin, and import 'bar' and 'baz' from the v1 pin
    use Package qw/+v2 foo +v1 bar baz/;

If you do not specify a pin the default is to use the C<v1> pin (for legacy
reasons). When the C<$AUTHOR_TESTING> environment variable is set, importing
without a pin will produce a warning. In the future this warning may occur
without the environment variable being set.

=head3 DIFFERENCES BETWEEN PINS

=over 4

=item From v1 to v2

This package does not have any differences between pins C<v1> and C<v2>. This
package has 'v2' because all Test2::Suite packages gain new pins at the same
time for consistency.

=back

=head2 EXPORTED SYMBOLS

=over 4

=item subtest_streamed $name => $sub

=item subtest_streamed($name, $sub, @args)

=item subtest_streamed $name => \%params, $sub

=item subtest_streamed($name, \%params, $sub, @args)

Run subtest coderef, stream events as they happen.

C<\%params> is a hashref with any arguments you wish to pass into hub
construction.

=item subtest_buffered $name => $sub

=item subtest_buffered($name, $sub, @args)

=item subtest_buffered $name => \%params, $sub

=item subtest_buffered($name, \%params, $sub, @args)

Run subtest coderef, render events all at once when subtest is complete.

C<\%params> is a hashref with any arguments you wish to pass into hub
construction.

=back

=head1 SOURCE

The source code repository for Test2-Suite can be found at
F<http://github.com/Test-More/Test2-Suite/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2016 Chad Granum E<lt>exodist@cpan.orgE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
