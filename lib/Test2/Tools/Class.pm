package Test2::Tools::Class;
use strict;
use warnings;

our $VERSION = '0.000059';

use Test2::API qw/context/;
use Test2::Util::Ref qw/render_ref/;

use Scalar::Util qw/blessed/;

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/can_ok isa_ok DOES_ok/;
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

# For easier grepping
# sub isa_ok  is defined here
# sub can_ok  is defined here
# sub DOES_ok is defined here
BEGIN {
    for my $op (qw/isa can DOES/) {
        my $sub = sub($;@) {
            my ($thing, @args) = @_;
            my $ctx = context();

            my (@items, $name);
            if (ref($args[0]) eq 'ARRAY') {
                $name  = $args[1];
                @items = @{$args[0]};
            }
            else {
                @items = @args;
            }

            my $thing_name = ref($thing) ? render_ref($thing) : defined($thing) ? "$thing" : "<undef>";
            $thing_name =~ s/\n/\\n/g;
            $thing_name =~ s/#//g;
            $thing_name =~ s/\(0x[a-f0-9]+\)//gi;

            $name ||= @items == 1 ? "$thing_name\->$op('$items[0]')" : "$thing_name\->$op(...)";

            unless ($thing && (blessed($thing) || !ref($thing))) {
                my $thing = defined($thing)
                    ? ref($thing) || "'$thing'"
                    : '<undef>';

                $ctx->ok(0, $name, ["$thing is neither a blessed reference or a package name."]);

                $ctx->release;
                return 0;
            }

            unless(UNIVERSAL->can($op) || $thing->can($op)) {
                $ctx->skip($name, "'$op' is not supported on this platform");
                $ctx->release;
                return 1;
            }

            my $file = $ctx->trace->file;
            my $line = $ctx->trace->line;

            my @bad;
            for my $item (@items) {
                my ($bool, $ok, $err);

                {
                    local ($@, $!);
                    $ok = eval qq/#line $line "$file"\n\$bool = \$thing->$op(\$item); 1/;
                    $err = $@;
                }

                die $err unless $ok;
                next if $bool;

                push @bad => $item;
            }

            $ctx->ok( !@bad, $name, [map { "Failed: $thing_name\->$op('$_')" } @bad]);

            $ctx->release;

            return !@bad;
        };

        no strict 'refs';
        *{$op . "_ok"} = $sub;
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Class - Test2 implementation of the tools for testing classes.

=head1 DESCRIPTION

L<Test2> based tools for validating classes and objects. These are similar to
some tools from L<Test::More>, but they have a more consistent interface.

=head1 SYNOPSIS

    use Test2::Tools::Class ':v2';

    isa_ok($CLASS_OR_INSTANCE, $PARENT_CLASS1, $PARENT_CLASS2, ...);
    isa_ok($CLASS_OR_INSTANCE, [$PARENT_CLASS1, $PARENT_CLASS2, ...], "Test Name");

    can_ok($CLASS_OR_INSTANCE, $METHOD1, $METHOD2, ...);
    can_ok($CLASS_OR_INSTANCE, [$METHOD1, $METHOD2, ...], "Test Name");

    DOES_ok($CLASS_OR_INSTANCE, $ROLE1, $ROLE2, ...);
    DOES_ok($CLASS_OR_INSTANCE, [$ROLE1, $ROLE2, ...], "Test Name");

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

=item can_ok($thing, @methods)

=item can_ok($thing, \@methods, $test_name)

This checks that C<$thing> (either a class name, or a blessed instance) has the
specified methods.

If the second argument is an arrayref then it will be used as the list of
methods leaving the third argument to be the test name.

=item isa_ok($thing, @classes)

=item isa_ok($thing, \@classes, $test_name)

This checks that C<$thing> (either a class name, or a blessed instance) is or
subclasses the specified classes.

If the second argument is an arrayref then it will be used as the list of
classes leaving the third argument to be the test name.

=item DOES_ok($thing, @roles)

=item DOES_ok($thing, \@roles, $test_name)

This checks that C<$thing> (either a class name, or a blessed instance) does
the specified roles.

If the second argument is an arrayref then it will be used as the list of
roles leaving the third argument to be the test name.

B<Note 1:> This uses the C<< $class->DOES(...) >> method, not the C<does()>
method Moose provides.

B<Note 2:> Not all perls have the C<DOES()> method, if you use this on those
perls the test will be skipped.

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
