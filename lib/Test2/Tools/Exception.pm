package Test2::Tools::Exception;
use strict;
use warnings;

our $VERSION = '0.000059';

use Test2::API qw/context/;

use Test2::Util::Misc qw/deprecate_pins_before/;
use Importer Importer => qw/import/;

our @EXPORT = qw/dies lives try_ok/;
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

sub dies(&) {
    my $code = shift;
    local ($@, $!, $?);
    my $ok = eval { $code->(); 1 };
    my $err = $@;

    return undef if $ok;

    unless ($err) {
        my $ctx = context();
        $ctx->alert("Got exception as expected, but exception is falsy (undef, '', or 0)...");
        $ctx->release;
    }

    return $err;
}

sub lives(&) {
    my $code = shift;

    my $err;
    {
        local ($@, $!, $?);
        eval { $code->(); 1 } and return 1;
        $err = $@;
    }

    # If the eval failed we want to set $@ to the error.
    $@ = $err;
    return 0;
}

sub try_ok(&;$) {
    my ($code, $name) = @_;

    my $ok = &lives($code);
    my $err = $@;

    # Context should be obtained AFTER code is run so that events inside the
    # codeblock report inside the codeblock itself. This will also preserve $@
    # as thrown inside the codeblock.
    my $ctx = context();
    chomp(my $diag = "Exception: $err");
    $ctx->ok($ok, $name, [$diag]);
    $ctx->release;

    $@ = $err unless $ok;
    return $ok;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Exception - Test2 based tools for checking exceptions

=head1 DESCRIPTION

This is the L<Test2> implementation of code used to test exceptions. This is
similar to L<Test::Fatal>, but it intentionally does much less.

=head1 SYNOPSIS

    use Test2::Tools::Exception '+v2' => [qw/dies lives/];

    like(
        dies { die 'xxx' },
        qr/xxx/,
        "Got exception"
    );

    ok(lives { ... }, "did not die") or note($@);

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

=item $e = dies { ... }

This will trap any exception the codeblock throws. If no exception is thrown
the sub will return undef. If an exception is thrown it will be returned. This
function preserves C<$@>, it will not be altered from its value before the sub
is called.

=item $bool = lives { ... }

This will trap any exception thrown in the codeblock. It will return true when
there is no exception, and false when there is. C<$@> is preserved from before
the sub is called when there is no exception. When an exception is trapped
C<$@> will have the exception so that you can look at it.

=item $bool = try_ok { ... }

=item $bool = try_ok { ... } "Test Description"

This will run the code block trapping any exception. If there is no exception a
passing event will be issued. If the test fails a failing event will be issued,
and the exception will be reported as diagnostics.

B<Note:> This function does not preserve C<$@> on failure, it will be set to
the exception the codeblock throws, this is by design so that you can obtain
the exception if desired.

=back

=head1 DIFFERENCES FROM TEST::FATAL

L<Test::Fatal> sets C<$Test::Builder::Level> such that failing tests inside the
exception block will report to the line where C<exception()> is called. I
disagree with this, and think the actual line of the failing test is
more important. Ultimately, though L<Test::Fatal> cannot be changed, people
probably already depend on that behavior.

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
