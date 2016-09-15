use Test2::Bundle::Extended ':v2';

use Test2::Suite;

pass("Loaded Test2::Suite");

ok($Test2::Suite::VERSION, "have a version");

done_testing;
