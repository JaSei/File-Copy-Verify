#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 4;
use Path::Tiny;
use Test::Exception;

use_ok('File::Copy::Verify');

subtest 'file copy to nonexists file' => sub {
    my $workdir = Path::Tiny->tempdir;
    my $src = Path::Tiny->tempfile;
    my $dst = path("$workdir/b");

    File::Copy::Verify::copy($src, $dst);

    ok($dst->exists, 'copy');
};

subtest 'file copy to exists file' => sub {
    my $src = Path::Tiny->tempfile;
    $src->spew('new');
    my $dst = Path::Tiny->tempfile;

    ok($dst->exists, 'exists before');
    is($dst->slurp, '', 'file is empty');

    File::Copy::Verify::copy($src, $dst);

    ok($dst->exists, 'exists after');
    is($dst->slurp, 'new', 'file is rewrited');
};

subtest 'file copy to dir' => sub {
    my $workdir = Path::Tiny->tempdir;
    my $src = Path::Tiny->tempfile;

    File::Copy::Verify::copy($src, "$workdir");

    ok(path($workdir,$src->basename)->exists, 'file copied to dir');
};

subtest 'manualy set hash' => sub {
    my $workdir = Path::Tiny->tempdir;
    my $src = Path::Tiny->tempfile;
    my $dst = path("$workdir/b");

    lives_ok {
        File::Copy::Verify::copy($src, $dst, {src_hash => '0', dst_hash => '0'});
    } 'copy without exception';

    ok($dst->exists(), 'src was copied');
    $dst->remove();

    throws_ok {
        File::Copy::Verify::copy($src, $dst, {src_hash => '0', dst_hash => '1'});
    } qr/isn't equal/, "Hashes aren't equal";

    ok(!$dst->exists(), 'src wasn\'t copied');

    done_testing(4);
};
