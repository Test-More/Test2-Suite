package Test2::Plugin::DataLine;
use strict;
use warnings;

use Test2::Event::V2;

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
                    my $fd = $event->facet_data;

                    if (my $line = $.) {
                        my $fh = eval '$${^LAST_FH}' || do { # Added in 5.18, the do is fallback
                            my $out;
                            local $SIG{__WARN__} = sub {
                                my $msg = shift;
                                $out = $msg;
                            };
                            warn "blah";
                            $out =~ m/<(.+)> line $line/ ? $1 : '?';
                        };

                        $fh =~ s/^\*(main::)?//;

                        my $msg = "Last filehandle read: <$fh> line $.";

                        push @{$fd->{info} //= []} => {
                            details => $msg,
                            tag => 'DIAG',
                            debug => 1,
                        };

                        return Test2::Event::V2->new(%$fd);
                    }
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

Test2::Plugin::DataLine - Add "<$fh> line X." diagnostics to failed tests.

=head1 DESCRIPTION

C<warn ...> and C<die ...> will append "<$fh> line X." to warnings and
exceptions if C<$.> is true. This is the last filehandle read, and the line
number that was read.

This plugin adds the same information to any failed tests.

Example: "Last filehandle read: <DATA> line 5"

=head1 SYNOPSIS

    use Test2::Plugin::DataLine;

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
