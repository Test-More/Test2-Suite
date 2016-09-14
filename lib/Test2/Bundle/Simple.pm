package Test2::Bundle::Simple;
use strict;
use warnings;

our $VERSION = '0.000059';

use Test2::Plugin::ExitSummary;

use Test2::Tools::Basic qw/+v2 ok plan done_testing skip_all/;

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/ok plan done_testing skip_all/;
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

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Bundle::Simple - ALMOST a drop-in replacement for Test::Simple.

=head1 DESCRIPTION

This bundle is intended to be a (mostly) drop-in replacement for
L<Test::Simple>. See L<"KEY DIFFERENCES FROM Test::Simple"> for details.

=head1 SYNOPSIS

    use Test2::Bundle::Simple ':v2';

    ok(1, "pass");

    done_testing;

=head1 EXPORT PINS

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

=head2 DIFFERENCES BETWEEN PINS

=over 4

=item From v1 to v2

This package does not have any differences between pins C<v1> and C<v2>. This
package has 'v2' because all Test2::Suite packages gain new pins at the same
time for consistency.

=back

=head1 PLUGINS

This loads L<Test2::Plugin::ExitSummary>.

=head1 TOOLS

These are all from L<Test2::Tools::Basic>.

=over 4

=item ok($bool, $name)

Run a test. If bool is true, the test passes. If bool is false, it fails.

=item plan($count)

Tell the system how many tests to expect.

=item skip_all($reason)

Tell the system to skip all the tests (this will exit the script).

=item done_testing();

Tell the system that all tests are complete. You can use this instead of
setting a plan.

=back

=head1 KEY DIFFERENCES FROM Test::Simple

=over 4

=item You cannot plan at import.

THIS WILL B<NOT> WORK:

    use Test2::Bundle::Simple tests => 5;

Instead you must plan in a separate statement:

    use Test2::Bundle::Simple;
    plan 5;

=item You have three subs imported for use in planning

Use C<plan($count)>, C<skip_all($reason)>, or C<done_testing()> for your
planning.

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
