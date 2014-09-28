#  Copyright 2014, Stricture Consulting Group LLC
#  All rights reserved.
# 
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
# 
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
# 
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
# 
#      * Neither the name of the Stricture Consulting Group LLC nor the
#        names of its contributors may be used to endorse or promote products
#        derived from this software without specific prior written permission.
# 
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL STRICTURE CONSULTING GROUP LLC BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package Sagitta::AMDInfo;

require Exporter;
*import = \&Exporter::import;

require DynaLoader;

$Sagitta::AMDInfo::VERSION = '1.00';

DynaLoader::bootstrap Sagitta::AMDInfo $Sagitta::AMDInfo::VERSION;

@Sagitta::AMDInfo::ISA = qw( Exporter );

%Sagitta::AMDInfo::EXPORT_TAGS = (
    'all' => [ qw(
            new
            init
            destroy
            get_adapters
            get_adaptername
            get_clocks
            get_activity
            get_temp
            get_fanspeed
        ) ]
);

@Sagitta::AMDInfo::EXPORT_OK = ( @{$EXPORT_TAGS{'all'}} );

@Sagitta::AMDInfo::EXPORT = ( @{$EXPORT_TAGS{'all'}} );


sub init
{
    ADL_Init();
}

sub new
{
    my $class = shift;

    ADL_Init();

    return bless {}, $class;
}

sub destroy
{
    ADL_Destroy();
}

sub get_adapters
{
    my $adapter_ref = ADL_Get_Adapters();
    return @{$adapter_ref};
}

sub get_adaptername
{
    my $dev = $_[1];
    return ${ADL_Get_AdapterName ($dev)};
}

sub get_clocks
{
    my $dev = $_[1];
    return @{ADL_Get_Clocks ($dev)};
}

sub get_activity
{
    my $dev = $_[1];
    return ${ADL_Get_Activity ($dev)};
}

sub get_temp
{
    my $dev = $_[1];
    return ${ADL_Get_Temp ($dev)};
}

sub get_fanspeed
{
    my $dev = $_[1];
    return ${ADL_Get_Fanspeed ($dev)};
}

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

1;
