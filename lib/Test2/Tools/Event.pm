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

=head1 EXPORTS

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
