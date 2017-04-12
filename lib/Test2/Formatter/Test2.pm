package Test2::Formatter::Test2;
use strict;
use warnings;

use Scalar::Util qw/blessed/;
use Test2::Util::Term qw/USE_ANSI_COLOR term_size/;
use Test2::Util qw/IS_WIN32/;

BEGIN { require Test2::Formatter; our @ISA = qw(Test2::Formatter) }

sub import {
    my $class = shift;
    return if $ENV{HARNESS_ACTIVE};
    $class->SUPER::import;
}

use Test2::Util::HashBase qw/last_depth _buffered io _encoding show_buffer color tty/;

sub TAG_WIDTH() { 8 }

sub hide_buffered() { 0 }

sub DEFAULT_TAG_COLOR() {
    return (
        'DEBUG'    => Term::ANSIColor::color('bold red'),
        'DIAG'     => Term::ANSIColor::color('yellow'),
        'ERROR'    => Term::ANSIColor::color('red'),
        'FATAL'    => Term::ANSIColor::color('bold red'),
        'FAIL'     => Term::ANSIColor::color('bold red'),
        'HALT'     => Term::ANSIColor::color('bold red'),
        'PASS'     => Term::ANSIColor::color('bold green'),
        '! PASS !' => Term::ANSIColor::color('cyan'),
        'TODO'     => Term::ANSIColor::color('cyan'),
        'NO  PLAN' => Term::ANSIColor::color('yellow'),
        'SKIP'     => Term::ANSIColor::color('bold cyan'),
        'SKIP ALL' => Term::ANSIColor::color('bold white on_blue'),
        'STDERR'   => Term::ANSIColor::color('yellow'),
    );
}

sub DEFAULT_FACET_COLOR() {
    return (
        about   => Term::ANSIColor::color('magenta'),
        amnesty => Term::ANSIColor::color('cyan'),
        assert  => Term::ANSIColor::color('bold bright_white'),
        control => Term::ANSIColor::color('bold red'),
        error   => Term::ANSIColor::color('yellow'),
        info    => Term::ANSIColor::color('yellow'),
        meta    => Term::ANSIColor::color('magenta'),
        parent  => Term::ANSIColor::color('magenta'),
        trace   => Term::ANSIColor::color('bold red'),
    );
}

sub DEFAULT_COLOR() {
    return (
        reset      => Term::ANSIColor::color('reset'),
        blob       => Term::ANSIColor::color('bold bright_black on_white'),
        tree       => Term::ANSIColor::color('bold bright_white'),
        tag_border => Term::ANSIColor::color('bold bright_white'),
    );
}

sub init {
    my $self = shift;

    unless ($self->{+IO}) {
        open(my $io, '>&', STDOUT) or die "Can't dup STDOUT:  $!";
        $self->{+IO} = $io;
    }

    my $io = $self->{+IO};
    $io->autoflush(1);

    $self->{+TTY} = -t $io unless defined $self->{+TTY};

    if ($self->{+TTY} && USE_ANSI_COLOR) {
        $self->{+SHOW_BUFFER} = 1 unless defined $self->{+SHOW_BUFFER};
        $self->{+COLOR} = {
            DEFAULT_COLOR(),
            TAGS   => {DEFAULT_TAG_COLOR()},
            FACETS => {DEFAULT_FACET_COLOR()},
        } unless defined $self->{+COLOR};
    }
    else {
        $self->{+SHOW_BUFFER} = 0 unless defined $self->{+SHOW_BUFFER};
    }
}

sub encoding {
    my $self = shift;

    if (@_) {
        my ($enc) = @_;

        # https://rt.perl.org/Public/Bug/Display.html?id=31923
        # If utf8 is requested we use ':utf8' instead of ':encoding(utf8)' in
        # order to avoid the thread segfault.
        if ($enc =~ m/^utf-?8$/i) {
            binmode($self->{+IO}, ":utf8");
        }
        else {
            binmode($self->{+IO}, ":encoding($enc)");
        }
        $self->{+_ENCODING} = $enc;
    }

    return $self->{+_ENCODING};
}

if ($^C) {
    no warnings 'redefine';
    *write = sub {};
}
sub write {
    my ($self, $e, $num, $f) = @_;
    $f ||= $e->facet_data;

    $self->encoding($f->{control}->{encoding}) if $f->{control}->{encoding};

    my $depth = $f->{trace}->{nested};

    return if $depth && !$self->{+SHOW_BUFFER};

    my $lines;
    if ($depth) {
        my $tree = $self->render_tree($f, '>');
        $lines = $self->render_buffered_event($f, $tree);
    }
    else {
        my $tree = $self->render_tree($f,);
        $lines = $self->render_event($f, $tree);
    }

    return unless $lines && @$lines;

    my $io = $self->{+IO};
    if ($self->{+_BUFFERED}) {
        print $io "\r\e[K" if $self->{+_BUFFERED};
        $self->{+_BUFFERED} = 0;
    }

    if ($depth) {
        $self->{+_BUFFERED} = 1;
        print $io $lines->[0];
    }
    else {
        print $io "$_\n" for @$lines;
    }
}

sub render_buffered_event {
    my $self = shift;
    my ($f, $tree) = @_;

    return [$self->render_halt($f, $tree)] if $f->{control}->{halt};
    return [$self->render_assert($f, $tree)] if $f->{assert};
    return [$self->render_errors($f, $tree)] if $f->{errors};
    return [$self->render_plan($f, $tree)] if $f->{plan};
    return [$self->render_info($f, $tree)] if $f->{info};

    return [$self->render_about($f, $tree)] if $f->{about};

    return;
}

sub render_event {
    my $self = shift;
    my ($f, $tree) = @_;

    my @out;

    push @out => $self->render_halt($f, $tree) if $f->{control}->{halt};
    push @out => $self->render_plan($f, $tree) if $f->{plan};

    if ($f->{assert}) {
        push @out => $self->render_assert($f, $tree);
        push @out => $self->render_debug($f, $tree) unless $f->{assert}->{pass} || $f->{assert}->{no_debug};
        push @out => $self->render_amnesty($f, $tree) if $f->{amnesty} && ! $f->{assert}->{pass};
    }

    push @out => $self->render_info($f, $tree) if $f->{info};
    push @out => $self->render_errors($f, $tree) if $f->{errors};
    push @out => $self->render_parent($f, $tree) if $f->{parent};

    push @out => $self->render_about($f, $tree)
        if $f->{about} && !(@out || grep { $f->{$_} } qw/stop plan info nest assert/);

    return \@out;
}

sub render_tree {
    my $self = shift;
    my ($f, $char) = @_;
    $char ||= '|';

    my $depth = $f->{trace}->{nested} || 0;

    my @pipes = (' ', map $char, 1 .. $depth);
    return join(' ' => @pipes) . ' ';
}

sub build_line {
    my $self = shift;
    my ($facet, $tag, $tree, $text, $ps, $pe) = @_;

    $tree ||= '';
    $tag  ||= '';
    $text ||= '';
    chomp($text);

    substr($tree, -2, 1, '+') if $facet eq 'assert';

    my $max = term_size() || 80;
    my $color = $self->{+COLOR};
    my $reset = $color ? $color->{reset} || '' : '';
    my $tcolor = $color ? $color->{TAGS}->{$tag} || $color->{FACETS}->{$facet} || '' : '';

    ($ps, $pe) = ('[', ']') unless $ps;

    $tag = uc($tag);
    my $length = length($tag);
    if ($length > TAG_WIDTH) {
        $tag = substr($tag, 0, TAG_WIDTH);
    }
    elsif($length < TAG_WIDTH) {
        my $pad = (TAG_WIDTH - $length) / 2;
        my $padl = $pad + (TAG_WIDTH - $length) % 2;
        $tag = (' ' x $padl) . $tag . (' ' x $pad);
    }

    my $start;
    if ($color) {
        my $border = $color->{tag_border} || '';
        $start = "${reset}${border}${ps}${reset}${tcolor}${tag}${reset}${border}${pe}${reset}";
    }
    else {
        $start = "${ps}${tag}${pe}";
    }
    $start .= "  ";

    if ($tree) {
        if ($color) {
            my $trcolor = $color->{tree} || '';
            $start .= $trcolor . $tree . $reset;
        }
        else {
            $start .= $tree;
        }
    }

    my @lines = split /[\r\n]/, $text;
    @lines = ($text) unless @lines;

    my @out;
    for my $line (@lines) {
        if( length("$ps$tag$pe  $tree$line") > $max) {
            @out = ();
            last;
        }

        if ($color) {
            push @out => "${start}${tcolor}${line}$reset";
        }
        else {
            push @out => "${start}${line}";
        }
    }

    return @out if @out;

    return (
        "$start----- START -----",
        $text,
        "$start------ END ------",
    ) unless $color;

    my $blob = $color->{blob} || '';
    return (
        "$start${blob}----- START -----$reset",
        "${tcolor}${text}${reset}",
        "$start${blob}------ END ------$reset",
    );
}

sub render_halt {
    my $self = shift;
    my ($f, $tree) = @_;

    return $self->build_line('control', 'HALT', $tree, $f->{control}->{details});
}

sub render_plan {
    my $self = shift;
    my ($f, $tree) = @_;

    my $plan = $f->{plan};
    return $self->build_line('plan', 'NO  PLAN', $tree, $f->{plan}->{details}) if $plan->{none};

    if ($plan->{skip}) {
        return $self->build_line('plan', 'SKIP ALL', $tree, $f->{plan}->{details})
            if $f->{plan}->{details};

        return $self->build_line('plan', 'SKIP ALL', $tree, "No reason given");
    }

    return $self->build_line('plan', 'PLAN', $tree, "Expected asserions: $f->{plan}->{count}");
}

sub render_assert {
    my $self = shift;
    my ($f, $tree) = @_;

    substr($tree, -2, 2, '+-') if $f->{parent};

    return $self->build_line('assert', 'PASS', $tree, $f->{assert}->{details})
        if $f->{assert}->{pass};

    return $self->build_line('assert', '! PASS !', $tree, $f->{assert}->{details})
        if $f->{amnesty} && @{$f->{amnesty}};

    return $self->build_line('assert', 'FAIL', $tree, $f->{assert}->{details})
}

sub render_amnesty {
    my $self = shift;
    my ($f, $tree) = @_;

    my %seen;
    return map {
        $seen{join '' => @{$_}{qw/tag details/}}++
            ? ()
            : $self->build_line('amnesty', $_->{tag}, $tree, $_->{details}, '(', ')');
    } @{$f->{amnesty}};
}

sub render_debug {
    my $self = shift;
    my ($f, $tree) = @_;

    my $name  = $f->{assert}->{details};
    my $trace = $f->{trace};

    my $debug;
    if ($trace) {
        $debug = $trace->{details};
        if(!$debug && $trace->{frame}) {
            my $frame = $trace->{frame};
            $debug = "$frame->[1] line $frame->[2]";
        }
    }

    $debug ||= "[No trace info available]";

    chomp($debug);

    return $self->build_line('trace', 'DEBUG', $tree, $debug);
}

sub render_info {
    my $self = shift;
    my ($f, $tree) = @_;

    return map {
        my $details = $_->{details};

        my $msg;
        if (ref($details)) {
            require Data::Dumper;
            my $dumper = Data::Dumper->new([$details])->Indent(2)->Terse(1)->Useqq(1)->Sortkeys(1);
            chomp($msg = $dumper->Dump);
        }
        else {
            chomp($msg = $details);
        }

        $self->build_line('info', $_->{tag}, $tree, $details, '(', ')')
    } @{$f->{info}};
}

sub render_about {
    my $self = shift;
    my ($f, $tree) = @_;

    my $type = substr($f->{about}->{package}, 0 - TAG_WIDTH, TAG_WIDTH);

    return $self->build_line('info', $type, $tree, $f->{about}->{details});
}

sub render_parent {
    my $self = shift;
    my ($f, $tree) = @_;

    my @out;
    for my $sf (@{$f->{parent}->{children}}) {
        my $tree = $self->render_tree($sf);
        push @out => @{$self->render_event($sf, $tree)};
    }

    push @out => (
        $self->build_line('parent', '', "$tree^", '', ' ', ' '),
        $self->build_line('', '', $tree, '', ' ', ' '),
    );

    return @out;
}


sub render_error {
    my $self = shift;
    my ($f, $tree) = @_;

    return map {
        my $details = $_->{details};

        my $msg;
        if (ref($details)) {
            require Data::Dumper;
            my $dumper = Data::Dumper->new([$details])->Indent(2)->Terse(1)->Useqq(1)->Sortkeys(1);
            chomp($msg = $dumper->Dump);
        }
        else {
            chomp($msg = $details);
        }

        $self->build_line('error', $_->{fail} ? 'FATAL' : 'ERROR', $tree, $details, '<', '>')
    } @{$f->{errors}};
}

1;
