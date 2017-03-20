use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Compare::Event';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


my $one = $CLASS->new(etype => 'Ok');
is($one->name, '<EVENT: Ok>', "got name");
is($one->meta_class, 'Test2::Compare::EventMeta', "correct meta class");
is($one->object_base, 'Test2::Event', "Event is the base class");

my $trace = Test2::Util::Trace->new(frame => ['Foo', 'foo.t', 42, 'foo']);
my $Ok = Test2::Event::Ok->new(trace => $trace, pass => 1);

is($one->got_lines(), undef, "no lines");
is($one->got_lines('xxx'), undef, "no lines");
is($one->got_lines(bless {}, 'XXX'), undef, "no lines");
is($one->got_lines($Ok), 42, "got the correct line");

done_testing;
