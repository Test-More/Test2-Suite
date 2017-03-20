use Test2::Bundle::Extended;

{ package Target;

  use base 'Test2::Require::AuthorTesting';

  use Test2::Tools::Basic qw( fail );
  main::imported_ok(qw/fail/);
  
  use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
  use overload '""' => sub { $_[0] };
}

my $CLASS = 'Target';
sub CLASS() { $CLASS }


{
    local %ENV = %ENV;
    $ENV{AUTHOR_TESTING} = 0;
    is($CLASS->skip(), 'Author test, set the $AUTHOR_TESTING environment variable to run it', "will skip");

    $ENV{AUTHOR_TESTING} = 1;
    is($CLASS->skip(), undef, "will not skip");
}

done_testing;
