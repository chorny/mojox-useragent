#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use MojoX::UserAgent;

plan tests => 30;

my $ua = MojoX::UserAgent->new;

my @urls1 =
  ( 'http://lh3.ggpht.com/_bvKfYeSTo5U/SnSC17xJJyI/AAAAAAAAGQs/Z_aRDN6So0U/s640/Eileens%20vase.jpg',
    'http://lh3.ggpht.com/_9UOrGPMWZ4o/SW3ML4d7pcI/AAAAAAAALTM/gFidELjRGSE/s640/DSC07800%20copy.JPG',
    'http://lh3.ggpht.com/_ojqv06j4HLU/SnqFEIt4OpI/AAAAAAAAecc/KbSWJ6Vw94I/s800/20090805-_MG_9289.jpg',
    'http://lh3.ggpht.com/_3GH-BcEZ-2g/ShhXl8CdDzI/AAAAAAABu1A/X-p-CjH7XcI/s640/_AAA4137.jpg',
    'http://lh3.ggpht.com/_VPQcjXrNuoI/SnQUsUOQFTI/AAAAAAAAgBo/I3sv_B0Icgc/DSC06663.JPG',
    'http://lh3.ggpht.com/_N-_W204Ydgg/SnszHFGzAjI/AAAAAAAAdj0/77g__rJAOYo/sierpie%C5%84%20212.jpg',
    'http://lh3.ggpht.com/_ckL20nhzvvU/SnAu8r25ERI/AAAAAAAABYo/PDZR9CYHCGY/s800/099.JPG',
    'http://lh3.ggpht.com/_h4Me0BEbap8/Sia2E5nskjI/AAAAAAAAH6U/2ineC_aAO7g/s800/163.JPG',
    'http://lh3.ggpht.com/_eCIgUPca7gk/SnONVfVB4JI/AAAAAAAACSk/isu9zHqM99w/_DSC0801.jpg',
    'http://lh3.ggpht.com/_rZAyQE6QxdE/SkMRqMF_iyI/AAAAAAAAXWU/a6gmWwIHQRo/20060913_001.jpg',
    'http://lh3.ggpht.com/_wna6FqpjZY8/SgxgBd6_DJI/AAAAAAAAc-0/Vwh8AwfoptU/s800/IMG_0829.jpg',
    'http://lh3.ggpht.com/_LfiU-WOccFk/Sg7T8qk-awI/AAAAAAAAn2Q/6VFRRnRlz1s/s800/IMG_4312.JPG',
    'http://lh3.ggpht.com/_bAOBkMn7wuo/SnzDbcpaZvI/AAAAAAAACTQ/vgqthv4cur0/s800/P7300350.JPG'
  );

$ua->maxconnections(2);
$ua->maxpipereqs(3);

$ua->pipeline_method('horizontal');

is($ua->maxconnections, 2);
is($ua->maxpipereqs, 3);

for my $url (@urls1) {
    $ua->get($url);
}

my $act_count = $ua->crank_all;

is ($act_count, 2);

# Peekaboo
my $slots = $ua->_active->{'lh3.ggpht.com:80'};
is (scalar @{$slots}, 2);
is (ref $slots->[0], 'Mojo::Pipeline');
is (ref $slots->[1], 'Mojo::Pipeline');

is (scalar @{$slots->[0]->transactions}, 3);
is (scalar @{$slots->[1]->transactions}, 3);

is (scalar @{$ua->_ondeck->{'lh3.ggpht.com:80'}}, 7);

$ua->run_all;

$slots = $ua->_active->{'lh3.ggpht.com:80'};
is ($slots, undef);

my @urls2 =
  ( 'http://lh4.ggpht.com/_bvKfYeSTo5U/SnSC17xJJyI/AAAAAAAAGQs/Z_aRDN6So0U/s640/Eileens%20vase.jpg',
    'http://lh4.ggpht.com/_9UOrGPMWZ4o/SW3ML4d7pcI/AAAAAAAALTM/gFidELjRGSE/s640/DSC07800%20copy.JPG',
    'http://lh4.ggpht.com/_ojqv06j4HLU/SnqFEIt4OpI/AAAAAAAAecc/KbSWJ6Vw94I/s800/20090805-_MG_9289.jpg'
   );

for my $url (@urls2) {
    $ua->get($url);
}

$act_count = $ua->crank_all;

is ($act_count, 2);

# Peekaboo
$slots = $ua->_active->{'lh4.ggpht.com:80'};
is (scalar @{$slots}, 2);
is (ref $slots->[0], 'Mojo::Pipeline');
is (ref $slots->[1], 'MojoX::UserAgent::Transaction');

is (scalar @{$slots->[0]->transactions}, 2);

is (scalar @{$ua->_ondeck->{'lh4.ggpht.com:80'}}, 0);

$ua->run_all;

ok($ua->is_idle);


# Play it safe
$ua = MojoX::UserAgent->new;

$ua->maxconnections(3);
$ua->maxpipereqs(3);

$ua->pipeline_method('vertical');


my @urls3 =
  ( 'http://lh5.ggpht.com/_bvKfYeSTo5U/SnSC17xJJyI/AAAAAAAAGQs/Z_aRDN6So0U/s640/Eileens%20vase.jpg',
    'http://lh5.ggpht.com/_9UOrGPMWZ4o/SW3ML4d7pcI/AAAAAAAALTM/gFidELjRGSE/s640/DSC07800%20copy.JPG',
    'http://lh5.ggpht.com/_ojqv06j4HLU/SnqFEIt4OpI/AAAAAAAAecc/KbSWJ6Vw94I/s800/20090805-_MG_9289.jpg'
   );

for my $url (@urls3) {
    $ua->get($url);
}

$act_count = $ua->crank_all;

is ($act_count, 1);
# Peekaboo
$slots = $ua->_active->{'lh5.ggpht.com:80'};
is (scalar @{$slots}, 1);
is (ref $slots->[0], 'Mojo::Pipeline');
is (scalar @{$slots->[0]->transactions}, 3);

$ua->run_all;

for my $url (@urls1) {
    $ua->get($url);
}

$act_count = $ua->crank_all;

is ($act_count, 3);
# Peekaboo
$slots = $ua->_active->{'lh3.ggpht.com:80'};
is (scalar @{$slots}, 3);
is (ref $slots->[0], 'Mojo::Pipeline');
is (ref $slots->[1], 'Mojo::Pipeline');
is (ref $slots->[2], 'Mojo::Pipeline');

is (scalar @{$slots->[0]->transactions}, 3);
is (scalar @{$slots->[1]->transactions}, 3);
is (scalar @{$slots->[2]->transactions}, 3);

is (scalar @{$ua->_ondeck->{'lh3.ggpht.com:80'}}, 4);

$ua->run_all;
