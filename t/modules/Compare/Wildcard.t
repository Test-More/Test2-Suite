use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Compare::Wildcard';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


my $one = $CLASS->new(expect => 'foo');
isa_ok($one, $CLASS, 'Test2::Compare::Base');

ok(defined $CLASS->new(expect => 0), "0 is a valid expect value");
ok(defined $CLASS->new(expect => undef), "undef is a valid expect value");
ok(defined $CLASS->new(expect => ''), "'' is a valid expect value");

like(
    dies { $CLASS->new() },
    qr/'expect' is a require attribute/,
    "Need to specify 'expect'"
);

done_testing;
