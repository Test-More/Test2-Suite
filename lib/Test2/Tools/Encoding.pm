package Test2::Tools::Encoding;
use strict;
use warnings;

use Carp qw/croak/;

use Test2::API qw/test2_stack/;

our $VERSION = '0.000059';

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/set_encoding/;
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

sub set_encoding {
    my $enc = shift;
    my $format = test2_stack->top->format;

    unless ($format && eval { $format->can('encoding') }) {
        $format = '<undef>' unless defined $format;
        croak "Unable to set encoding on formatter '$format'";
    }

    $format->encoding($enc);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Encoding - Tools for managing the encoding of L<Test2> based
tests.

=head1 DESCRIPTION

This module exports a function that lets you dynamically change the output
encoding at will.

=head1 SYNOPSIS

    use Test2::Tools::Encoding ':v2';

    set_encoding('utf8');

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


All subs are exported by default.

=over 4

=item set_encoding($encoding)

This will set the encoding to whatever you specify. This will only affect the
output of the current formatter, which is usually your TAP output formatter.

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
