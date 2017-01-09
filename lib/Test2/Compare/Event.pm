package Test2::Compare::Event;
use strict;
use warnings;

use Scalar::Util qw/blessed/;

use Test2::Compare::EventMeta();

use base 'Test2::Compare::Object';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/etype/;

sub name {
    my $self = shift;
    my $etype = $self->etype;
    return "<EVENT: $etype>";
}

sub meta_class  { 'Test2::Compare::EventMeta' }
sub object_base { 'Test2::Event' }

sub got_lines {
    my $self = shift;
    my ($event) = @_;
    return unless $event;
    return unless blessed($event);
    return unless $event->isa('Test2::Event');
    return unless $event->trace;

    return ($event->trace->line);
}

1;

# ABSTRACT: Event specific Object subclass

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

This module is used to represent an expected event in a deep comparison.

=cut
