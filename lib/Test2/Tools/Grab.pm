package Test2::Tools::Grab;
use strict;
use warnings;

our $VERSION = '0.000059';

use Test2::Util::Grabber;

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/grab/;
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

sub grab { Test2::Util::Grabber->new() }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Grab - Temporarily intercept all events without adding a scope
level.

=head1 DESCRIPTION

This package provides a function that returns an object that grabs all events.
Once the object is destroyed events will once again be sent to the main hub.

=head1 SYNOPSIS

    use Test2::Tools::Grab ':v2';

    my $grab = grab();

    # Generate some events, they are intercepted.
    ok(1, "pass");
    ok(0, "fail");

    my $events_a = $grab->flush;

    # Generate some more events, they are intercepted.
    ok(1, "pass");
    ok(0, "fail");

    my $events_b = $grab->finish;

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

=item $grab = grab()

This lets you intercept all events for a section of code without adding
anything to your call stack. This is useful for things that are sensitive to
changes in the stack depth.

    my $grab = grab();
        ok(1, 'foo');
        ok(0, 'bar');

    my $events = $grab->finish;

    is(@$events, 2, "grabbed 2 events.");

If the C<$grab> object is destroyed without calling C<finish()>, it will
automatically clean up after itself and restore the parent hub.

    {
        my $grab = grab();
        # Things are grabbed
    }
    # Things are back to normal

By default the hub used has C<no_ending> set to true. This will prevent the hub
from enforcing that you issued a plan and ran at least 1 test. You can turn
enforcement back one like this:

    $grab->hub->set_no_ending(0);

With C<no_ending> turned off, C<finish> will run the post-test checks to
enforce the plan and that tests were run. In many cases this will result in
additional events in your events array.

=back

=head1 SEE ALSO

L<Test2::Util::Grabber> - The object constructed and returned by this tool.

=head1 SOURCE

The source code repository for Test2 can be found at
F<http://github.com/Test-More/Test-Stream/>.

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
