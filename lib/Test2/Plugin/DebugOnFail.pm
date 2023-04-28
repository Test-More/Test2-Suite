package Test2::Plugin::DebugOnFail;
use strict;
use warnings;

our $VERSION = '0.000154';

use B();

use Test2::API qw{
    test2_add_callback_post_load
    test2_stack
};

sub import {
    my $class = shift;

    test2_add_callback_post_load(sub {
        my $hub = test2_stack()->top;

        $hub->pre_filter(
            sub {
                my ($hub, $event) = @_;

                if ($event->causes_fail) {
                    warn "Test failure detected, stopping debugger...\n";
                    $DB::single = 1;
                }

                return $event;
            },
            inherit => 1,
        );
    });
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Plugin::DebugOnFail - Set "$DB::single = 1" on test failure.

=head1 DESCRIPTION

This will set C<$DB::single = 1> on any failure in the test suite.

=head1 SYNOPSIS

    use Test2::Plugin::DebugOnFail;

=head1 SOURCE

The source code repository for Test2-Suite can be found at
F<https://github.com/Test-More/Test2-Suite/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2018 Chad Granum E<lt>exodist@cpan.orgE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
