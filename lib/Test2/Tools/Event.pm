package Test2::Tools::Event;
use strict;
use warnings;

our $VERSION = '0.000059';

use Test2::Util qw/pkg_to_file/;

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/gen_event/;
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

sub gen_event {
    my ($type, %fields) = @_;

    $type = "Test2::Event::$type" unless $type =~ s/^\+//;

    require(pkg_to_file($type));

    $fields{trace} ||= Test2::Util::Trace->new(frame => [caller(0)]);

    return $type->new(%fields);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Event - Tools for generating test events.

=head1 DESCRIPTION

This module provides tools for generating events quickly by bypassing the
context/hub. This is particularly useful when testing other L<Test2> packages.

=head1 SYNOPSIS

    use Test2::Tools::Event ':v2';

    my $event = gen_event Ok => ( pass => 1, name => 'foo' );

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

=item $e = gen_event($TYPE)

=item $e = gen_event($TYPE, %FIELDS)

=item $e = gen_event 'Ok';

=item $e = gen_event Ok => ( ... )

=item $e = gen_event '+Test2::Event::Ok' => ( ... )

This will produce an event of the specified type. C<$TYPE> is assumed to be
shorthand for C<Test2::Event::$TYPE>, you can prefix C<$TYPE> with a '+' to
drop the assumption.

An L<Test2::Util::Trace> will be generated using C<caller(0)> and will be put in
the 'trace' field of your new event, unless you specified your own 'trace'
field.

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
