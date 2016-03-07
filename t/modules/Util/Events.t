use Test2::Bundle::Extended;

use Test2::Util::Events qw{dump_events};

use Test2::API qw{context_do run_subtest};

{

	package My::Event;
    $INC{'My/Event.pm'} = 1;

	use base 'Test2::Event';
}

my $events = intercept {
	dump_events(
		intercept {
			context_do {
				my $ctx = shift;

				$ctx->plan(42);
				$ctx->diag("D\niag");
				$ctx->note("N\note");
				$ctx->ok(1, 'named');
				$ctx->ok(0);

				run_subtest(
					'subtest',
					sub {
						context_do {
							my $ctx = shift;
							$ctx->ok(1);
                            $ctx->diag('foo');
						};
					}
				);

				$ctx->send_event(
					'Test2::Event::Exception',
					error => 'death',
				);
				$ctx->send_event('+My::Event');
			};
		}
	);
};

is(
	$events,
	array {
		event Diag => sub {
			call message => 'Plan(max: 42)';
		};
		event Diag => sub {
			call message => 'Diag(message: D\\niag)';
		};
		event Diag => sub {
			call message => 'Note(message: N\\note)';
		};
		event Diag => sub {
			call message => 'Ok(pass: 1, name: named)';
		};
		event Diag => sub {
			call message => 'Ok(pass: 0)';
		};
		event Diag => sub {
			call message => match qr/\QDiag(message:\E\s*(?:\\n)?\s*\QFailed test at \E.+\)/,
		};
		event Diag => sub {
			call message => 'Note(message: subtest)';
		};
		event Diag => sub {
			call message => 'Subtest(name: subtest, pass: 1) {';
		};
		event Diag => sub {
			call message => '  Ok(pass: 1)';
		};
		event Diag => sub {
			call message => '  Diag(message: foo)';
		};
		event Diag => sub {
			call message => '  Plan(max: 1)';
		};
		event Diag => sub {
			call message => '}';
		};
		event Diag => sub {
			call message => 'Exception(error: death)';
		};
		event Diag => sub {
			call message => 'My::Event';
		};
		end();
	},
	'dump_events sends expected Diag events'
);

done_testing;
