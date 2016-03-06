package Test2::Util::Events;
use strict;
use warnings;

our $VERSION = '0.000021';

use Test2::API qw/context/;
use Test2::Tools;

our @EXPORT_OK = qw{
    dump_events
};
use base 'Exporter';

# This is not intended for external use, it's just that being able to set it
# temporarily with local makes implementing indentation for nested subtests
# much simpler.
our $Indent = 0;

sub dump_events {
	my $events = shift;

	for my $event (@{$events}) {
		if ($event->isa('Test2::Event::Subtest')) {
			_diag_indented(_dump_one_event($event, qw{name pass}) . ' {');
			{
				local $Indent = $Indent + 2;
				dump_events($event->subevents);
			}
			_diag_indented('}');
		}
		elsif ($event->isa('Test2::Event::Diag')
			|| $event->isa('Test2::Event::Note'))
		{
			_diag_indented(_dump_one_event($event, 'message'));
		}
		elsif ($event->isa('Test2::Event::Exception')) {
			_diag_indented(_dump_one_event($event, 'error'));
		}
		elsif ($event->isa('Test2::Event::Ok')) {
			_diag_indented(_dump_one_event($event, qw{pass name}));
		}
		elsif ($event->isa('Test2::Event::Plan')) {
			_diag_indented(_dump_one_event($event, qw{directive reason max}));
		}
		else {
			_diag_indented(_dump_one_event($event));
		}
	}

	return $events;
}

sub _dump_one_event {
	my $event = shift;

	my ($type) = (ref $event) =~ /Test2::Event::(.+)/;
	$type = ref $event unless defined $type;

	my $msg = $type;
	my @attr;
	for my $attr (@_) {
		my $v = $event->$attr;
		next unless defined $v && length $v;
		push @attr, "$attr: " . _escape($v);
	}

	if (@attr) {
		$msg .= '(';
		$msg .= join ', ', @attr;
		$msg .= ')';
	}

	return $msg;
}

sub _escape {
	my $str = shift;
	$str =~ s/\n/\\n/g;
	$str =~ s/\r/\\r/g;
	return $str;
}

sub _diag_indented {
	my $ctx = context();
	my $i   = q{ } x $Indent;
	$ctx->diag($i . $_[0]);
	$ctx->release;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Util::Events - Tools for debugging test streams

=head1 DESCRIPTION

Utilities for debugging event streams.

=head1 EXPORTS

All exports are optional, you must specify subs to import.

=over 4

=item dump_events(intercept { ... })

This subroutine takes an array reference of C<Test2::Event> events and turns
it into a set of Diag events describing the captured events.

If you are writing a testing tool and using C<intercept> to capture events,
then this subroutine can be a useful debugging tool.

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

=item Kent Fredric E<lt>kentnl@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2015 Chad Granum E<lt>exodist7@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
