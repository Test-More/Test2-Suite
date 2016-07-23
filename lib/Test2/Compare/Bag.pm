package Test2::Compare::Bag;
use strict;
use warnings;

use base 'Test2::Compare::Base';

our $VERSION = '0.000054';

use Test2::Util::HashBase qw/ending items/;

use Carp qw/croak confess/;
use Scalar::Util qw/reftype looks_like_number/;

sub init {
    my $self = shift;

    $self->{+ITEMS} ||= [];

    $self->SUPER::init();
}

sub name { '<BAG>' }

sub verify {
    my $self = shift;
    my %params = @_;

    return 0 unless $params{exists};
    my $got = $params{got} || return 0;
    return 0 unless ref($got);
    return 0 unless reftype($got) eq 'ARRAY';
    return 1;
}

sub add_item {
    my $self = shift;
    my $check = pop;
    my ($idx) = @_;

    push @{$self->{+ITEMS}}, $check;
}

sub deltas {
    my $self = shift;
    my %params = @_;
    my ($got, $convert, $seen) = @params{qw/got convert seen/};

    my @deltas;
    my $closed = $self->{+ENDING};
    my @checks = map { $convert->($_) } @{$self->{+ITEMS}};
    my @list = @$got;

    # special cases

    # empty, closed bag vs. non-empty input
    if (!@checks && $closed && @list) {
        # deltas = all input elements
        for my $list_idx (0..$#list) {
            my $val = $list[$list_idx];
            push @deltas => $self->delta_class->new(
                dne      => 'check',
                verified => undef,
                id       => [ARRAY => $list_idx],
                got      => $val,
                check    => undef,
            );
        }
        return @deltas;
    }

    # empty bag
    if (!@checks) {
        # always matches
        return ();
    }

    # non-empty bag vs. empty input
    if (@checks && !@list) {
        # deltas = all items
        for my $check (@checks) {
            push @deltas => $self->delta_class->new(
                dne      => 'got',
                verified => undef,
                id       => [ARRAY => '*'],
                got      => undef,
                check    => $check,
            );
        }
        return @deltas;
    }

    # ok, now we know that both @list and @checks contain elements
    die "wtf?" unless @list && @checks;

    my @delta_matrix;
    for my $check_idx (0..$#checks) {
        my $check = $checks[$check_idx];

        my $match = 0;
        for my $list_idx (0..$#list) {
            my $val = $list[$list_idx];

            push @{$delta_matrix[$check_idx]->[$list_idx]}, $check->run(
                id      => [ARRAY => $list_idx],
                convert => $convert,
                seen    => $seen,
                exists  => 1,
                got     => $val,
            );

        }
    }

    _show_matrix(\@checks,\@list,\@delta_matrix);

    # each item must have matched at least one input
    for my $check_idx (0..$#checks) {
        my $matches = grep {
            @{$_} == 0
        } @{$delta_matrix[$check_idx]};
        next if $matches;
        push @deltas => $self->delta_class->new(
            dne      => 'got',
            verified => undef,
            id       => [ARRAY => '*'],
            got      => undef,
            check    => $checks[$check_idx],
        );
    }

    if ($closed) {
        my $inputs_with_matches = 0;
        # each input must have matched at least one item
        for my $list_idx (0..$#list) {
            my $matches = grep {
                @{$_->[$list_idx]} == 0
            } @delta_matrix;
            if ($matches) {
                ++$inputs_with_matches;
                next;
            }
            push @deltas => $self->delta_class->new(
                dne      => 'check',
                verified => undef,
                id       => [ARRAY => $list_idx],
                got      => $list[$list_idx],
                check    => undef,
            );
        }
        # the number of inputs matched must be the same as the number
        # of items
        if ($inputs_with_matches != @checks) {
            # this delta is wrong
            push @deltas => $self->delta_class->new(
                dne      => 'check',
                verified => undef,
                id       => [ARRAY => '*'],
                got      => $list[0],
                check    => undef,
            );
        }
    }

    return @deltas;
}

sub _show_matrix {
    my ($checks,$list,$m) = @_;
    require Text::Table;
    my $t = Text::Table->new( '', @$list );
    for my $i (0..$#$checks) {
        $t->load([
            $checks->[$i]->render,
            map {
                -scalar @{$_}
            } @{$m->[$i]},
        ]);
    }
    ::note($t);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Compare::Bag - Internal representation of a bag comparison.

=head1 DESCRIPTION

This module is an internal representation of a bag for comparison purposes.

=head1 METHODS

=over 4

=item $bool = $arr->ending

=item $arr->set_ending($bool)

Set this to true if you would like to fail when the array being validated has
more items than the check. That is, if you check for 4 items but the array has
5 values, it will fail and list that unmatched item in the array as
unexpected. If set to false then it is assumed you do not care about extra
items.

=item $hashref = $arr->items()

Returns the arrayref of values to be checked in the array.

=item $arr->set_items($arrayref)

Accepts an arrayref.

B<Note:> that there is no validation when using C<set_items>, it is better to
use the C<add_item> interface.

=item $name = $arr->name()

Always returns the string C<< "<BAG>" >>.

=item $bool = $arr->verify(got => $got, exists => $bool)

Check if C<$got> is an array reference or not.

=item $arr->add_item($item)

Push an item onto the list of values to be checked.

=item @deltas = $arr->deltas(got => $got, convert => \&convert, seen => \%seen)

Find the differences between the expected bag values and those in the C<$got>
arrayref.

=back

=head1 SOURCE

The source code repository for Test2-Suite can be found at
F<http://github.com/Test-More/Test2-Suite/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=item Gianni Ceccarelli E<lt>dakkar@thenautilus.netE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=item Gianni Ceccarelli E<lt>dakkar@thenautilus.netE<gt>

=back

=head1 COPYRIGHT

Copyright 2016 Chad Granum E<lt>exodist@cpan.orgE<gt>.

Copyright 2016 Gianni Ceccarelli E<lt>dakkar@thenautilus.netE<gt>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
