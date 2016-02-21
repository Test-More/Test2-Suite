use Test2::Bundle::Extended;
use Test2::Tools::AsyncSubtest;
use Test2::IPC;
use Test2::Util qw/CAN_REALLY_FORK CAN_THREAD get_tid/;

my $t1 = subtest_start('t1');
my $t2 = subtest_start('t2');

subtest_run($_ => sub {
    ok(1, "not concurrent A");
}) for $t1, $t2;

ok(1, "Something else");

if (CAN_REALLY_FORK) {
    my @pids;

    subtest_run($_ => sub {
        my $pid = fork;
        die "Failed to fork!" unless defined $pid;
        if ($pid) {
            push @pids => $pid;
            return;
        }

        ok(1, "from proc $$");

        exit 0;
    }) for $t1, $t2;

    waitpid($_, 0) for @pids;
}

ok(1, "Something else");

if (CAN_THREAD) {
    require threads;
    my @threads;

    subtest_run($_ => sub {
        push @threads => threads->create(sub {
            ok(1, "from thread " . get_tid);
        });
    }) for $t1, $t2;

    $_->join for @threads;
}

subtest_run($_ => sub {
    ok(1, "not concurrent B");
}) for $t1, $t2;

ok(1, "Something else");

subtest_finish($_) for $t1, $t2;

done_testing;
