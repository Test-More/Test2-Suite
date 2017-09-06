package MyTest::Target;

use Test2::Tools::Basic qw( fail );

use overload bool => sub { fail( 'illegal use of overloaded bool') } ;
use overload '""' => sub { $_[0] };

1;
