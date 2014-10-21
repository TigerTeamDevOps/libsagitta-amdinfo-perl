/*  Copyright 2014, Stricture Consulting Group LLC
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *      * Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *
 *      * Redistributions in binary form must reproduce the above copyright
 *        notice, this list of conditions and the following disclaimer in the
 *        documentation and/or other materials provided with the distribution.
 *
 *      * Neither the name of the Stricture Consulting Group LLC nor the
 *        names of its contributors may be used to endorse or promote products
 *        derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL STRICTURE CONSULTING GROUP LLC BE LIABLE FOR ANY
 *  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define LINUX
#include "include/adl_sdk.h"

void *ADL_Main_Memory_Alloc (int size)
{
    return (void *) malloc (size);
}

void ADL_Main_Memory_Free (void** lpBuffer)
{
    if (NULL != *lpBuffer)
    {
        free (*lpBuffer);
        *lpBuffer = NULL;
    }
}

void ADL_Init()
{
    ADL_Main_Control_Create (ADL_Main_Memory_Alloc, 1);
}

void ADL_Destroy()
{
    ADL_Main_Control_Destroy();
}

SV *ADL_Get_Adapters()
{
    AV *av = newAV();

    int adl_num_adapters = 0;
    int od_supported = 0;
    int od_enabled = 0;
    int od_version = 0;
    int i = 0;

    LPAdapterInfo adapter_info;

    ADL_Adapter_NumberOfAdapters_Get (&adl_num_adapters);

    if (adl_num_adapters < 1)
        return;

    adapter_info = (AdapterInfo *) calloc (adl_num_adapters, sizeof (AdapterInfo));
    ADL_Adapter_AdapterInfo_Get (adapter_info, adl_num_adapters * sizeof (AdapterInfo));

    for (i = 0; i < adl_num_adapters; i++)
    {
        int is_active = 0;

        if (ADL_OK != ADL_Adapter_Active_Get (adapter_info[i].iAdapterIndex, &is_active))
            continue;
        else
            if (is_active != ADL_TRUE)
                continue;

        if (ADL_OK != ADL_Overdrive_Caps (adapter_info[i].iAdapterIndex, &od_supported, &od_enabled, &od_version))
            continue;

        if (! od_supported)
            continue;

        av_push (av, newSViv (i));
    }

    ADL_Main_Memory_Free ((void **) &adapter_info);

    return newRV_noinc ((SV *) av);
}

SV *ADL_Get_AdapterName (SV *dev)
{
    SV *sv;
    int id = SvIV (dev);

    int adl_num_adapters = 0;
    LPAdapterInfo adapter_info;

    ADL_Adapter_NumberOfAdapters_Get (&adl_num_adapters);

    adapter_info = (AdapterInfo *) calloc (adl_num_adapters, sizeof (AdapterInfo));
    ADL_Adapter_AdapterInfo_Get (adapter_info, adl_num_adapters * sizeof (AdapterInfo));

    sv = newSVpv (adapter_info[id].strAdapterName, 0);

    ADL_Main_Memory_Free ((void **) &adapter_info);

    return newRV_noinc (sv);
}

SV *ADL_Get_Clocks (SV *dev)
{
    AV *av = newAV();
    int id = SvIV (dev);

    int od_supported = 0;
    int od_enabled = 0;
    int od_version = 0;
    int core = 0;
    int mem = 0;

    ADL_Overdrive_Caps (id, &od_supported, &od_enabled, &od_version);

    if (od_version == 6)
    {
        ADLOD6CurrentStatus current = {0};
        ADL_Overdrive6_CurrentStatus_Get (id, &current);
        core = current.iEngineClock / 100;
        mem = current.iMemoryClock / 100;
    }    
    else
    {
        ADLPMActivity current = {0};
        ADL_Overdrive5_CurrentActivity_Get (id, &current);
        core = current.iEngineClock / 100;
        mem = current.iMemoryClock / 100;
    }

    av_push (av, newSViv (core));
    av_push (av, newSViv (mem));

    return newRV_noinc ((SV *) av);
}

SV *ADL_Get_Activity (SV *dev)
{
    int id = SvIV (dev);

    int od_supported = 0;
    int od_enabled = 0;
    int od_version = 0;
    int activity = 0;

    ADL_Overdrive_Caps (id, &od_supported, &od_enabled, &od_version);

    if (od_version == 6)
    {
        ADLOD6CurrentStatus current = {0};
        ADL_Overdrive6_CurrentStatus_Get (id, &current);
        activity = current.iActivityPercent;
    }
    else
    {
        ADLPMActivity current = {0};
        ADL_Overdrive5_CurrentActivity_Get (id, &current);
        activity = current.iActivityPercent;
    }

    return newRV_noinc (newSViv (activity));
}

SV *ADL_Get_Temp (SV *dev)
{
    int id = SvIV (dev);

    int od_supported = 0;
    int od_enabled = 0;
    int od_version = 0;
    int temp = 0;

    ADL_Overdrive_Caps (id, &od_supported, &od_enabled, &od_version);

    if (od_version == 6)
    {
        ADL_Overdrive6_Temperature_Get (id, &temp);
    }
    else
    {
        ADLTemperature tempinfo = {0};
        ADL_Overdrive5_Temperature_Get (id, 0, &tempinfo);
        temp = tempinfo.iTemperature;
    }

    return newRV_noinc (newSViv ((int) temp / 1000));
}

SV *ADL_Get_Fanspeed (SV *dev)
{ 
    int id = SvIV (dev);

    int od_supported = 0;
    int od_enabled = 0;
    int od_version = 0;
    int fan = 0;

    ADL_Overdrive_Caps (id, &od_supported, &od_enabled, &od_version);

    if (od_version == 6)
    {
        ADLOD6FanSpeedInfo fan_info = {0};
        ADL_Overdrive6_FanSpeed_Get (id, &fan_info);
        fan = fan_info.iFanSpeedPercent;
    }
    else
    {
        ADLFanSpeedValue faninfo = {0};

        faninfo.iSize = sizeof (ADLFanSpeedValue);
        faninfo.iSpeedType = ADL_DL_FANCTRL_SPEED_TYPE_PERCENT;

        ADL_Overdrive5_FanSpeed_Get (id, 0, &faninfo);
        fan = faninfo.iFanSpeed;
    }

    return newRV_noinc (newSViv (fan));
}


MODULE = Sagitta::AMDInfo  PACKAGE = Sagitta::AMDInfo    

PROTOTYPES: DISABLE


void *
ADL_Main_Memory_Alloc (size)
    int    size

void
ADL_Init ()
    PREINIT:
    I32* temp;
    PPCODE:
    temp = PL_markstack_ptr++;
    ADL_Init();
    if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
      PL_markstack_ptr = temp;
      XSRETURN_EMPTY; /* return empty stack */
    }
        /* must have used dXSARGS; list context implied */
    return; /* assume stack size is correct */

void
ADL_Destroy ()
    PREINIT:
    I32* temp;
    PPCODE:
    temp = PL_markstack_ptr++;
    ADL_Destroy();
    if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
      PL_markstack_ptr = temp;
      XSRETURN_EMPTY; /* return empty stack */
    }
        /* must have used dXSARGS; list context implied */
    return; /* assume stack size is correct */

SV *
ADL_Get_Adapters ()

SV *
ADL_Get_AdapterName (dev)
    SV *    dev

SV *
ADL_Get_Clocks (dev)
    SV *    dev

SV *
ADL_Get_Activity (dev)
    SV *    dev

SV *
ADL_Get_Temp (dev)
    SV *    dev

SV *
ADL_Get_Fanspeed (dev)
    SV *    dev

