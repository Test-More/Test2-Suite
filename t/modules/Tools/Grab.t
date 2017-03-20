use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Util::Grabber';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }

use Test2::Tools::Grab;

ok(1, "initializing");

my $grab = grab();
ok(1, "pass");
my $one = $grab->events;
ok(0, "fail");
my $events = $grab->finish;

is(@$one, 1, "Captured 1 event");
is(@$events, 3, "Captured 3 events");

like(
    $one,
    array {
        event Ok => { pass => 1 };
    },
    "Got expected event"
);

like(
    $events,
    array {
        event Ok => { pass => 1 };
        event Ok => { pass => 0 };
        event Diag => { };
        end;
    },
    "Got expected events"
);

done_testing;
