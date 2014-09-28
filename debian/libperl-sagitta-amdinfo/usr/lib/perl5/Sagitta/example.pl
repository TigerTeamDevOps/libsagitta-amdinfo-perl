#!/usr/bin/env perl
# WTFPL license.

use Sagitta::AMDInfo;

my $amdinfo = 'Sagitta::AMDInfo'->new;
my(@adapters) = $amdinfo->get_adapters;

print "\n". 'Found ' . scalar @adapters .' adapters' ."\n\n";

for (my $i = 0; $i < scalar @adapters; ++$i)
{
    my(@clocks) = $amdinfo->get_clocks($adapters[$i]);
    my $activity = $amdinfo->get_activity($adapters[$i]);
    my $temp = $amdinfo->get_temp($adapters[$i]);
    my $fan = $amdinfo->get_fanspeed($adapters[$i]);
    my $name = $amdinfo->get_adaptername($adapters[$i]);

    printf ("Device %d (%s): id %02d, core %d Mhz, mem %d Mhz, activity %d%%, temp %dC, fan %d%%\n",
            $i, $name, $adapters[$i], $clocks[0], $clocks[1], $activity, $temp, $fan);
}

print "\n";

$amdinfo->destroy;

