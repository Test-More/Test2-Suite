use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Require::Perl';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


is($CLASS->skip('v5.6'), undef, "will not skip");
is($CLASS->skip('v10.10'), 'Perl v10.10.0 required', "will skip");

done_testing;
