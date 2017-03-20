use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Compare::Bool';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


my $one = $CLASS->new(input => 'foo');
is($one->name, '<TRUE (foo)>', "Got name");
is($one->operator, '==', "Got operator");

$one = $CLASS->new(input => 0, negate => 1);
is($one->name, '<FALSE (0)>', "Got name");
is($one->operator, '!=', "Got operator");

done_testing;
