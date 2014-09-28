# Sagitta::AMDInfo

## Description

AMD ADL bindings for Perl, developed by Stricture Group for use in Sagitta Hashstack.

These are not full ADL bindings. We do not wrap every single ADL function, nor do we attempt to follow the same syntax as the original C functions. Instead, we create simpler Perl methods for only the functionality we needed in Hashstack.

## Synopsis

```perl
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
```

## Methods

### new ()

Initializes a new object

### destroy ()

Destroys the object & frees its memory

### get\_adapters ()

Returns a list of active adapter IDs

### get\_adaptername (_int_ adapter\_id)

Returns the name of the adapter as a string

### get\_clocks (_int_ adapter\_id) 

Returns a list of current adapter clocks. The first array element is the core clock, the second element is the memory clock.

### get\_activity (_int_ adapter\_id)

Returns the GPU activity as a percentage.

### get\_temp (_int_ adapter\_id)

Returns the GPU temperature in Celcius

### get\_fanspeed (_int_ adapter\_id)

Returns the GPU fan speed as a percentage.

