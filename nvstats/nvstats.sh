#!/bin/sh
#Nvstats : Basic stats logging script to use with the Nvidia blob.
#Nvidia-smi doesn't properly log GPU utilisation, so I made that script
#		-Santo G.

gpulist=`nvidia-settings -t -q gpus | sed -e 's/^ *//' | grep -e '^\['` #No leading spaces, to get lines starting in '['

echo $gpulist | while read LINE; do
	gpuid=`echo "$LINE" | cut -d \  -f 2 | grep -E -o '\[.*\]'`
	gpuname=`echo "$LINE" | cut -d \  -f 3-`
	
	gpuutilstats=`nvidia-settings -t -q "$gpuid"/GPUUtilization | tr ',' '\n'`
	gpuclockstats=`nvidia-settings -t -q "$gpuid"/GPUCurrentClockFreqsString | tr ',' '\n'`
	gputemp=`nvidia-settings -t -q "$gpuid"/GPUCoreTemp`
	gputotalmem=`nvidia-settings -t -q "$gpuid"/TotalDedicatedGPUMemory`
	gpuusedmem=`nvidia-settings -t -q "$gpuid"/UsedDedicatedGPUMemory`

	gpuusage=`echo "$gpuutilstats"|grep graphics=|sed 's/[^0-9]//g'`
	memoryusage=`echo "$gpuutilstats"|grep memory=|sed 's/[^0-9]//g'`
	bandwidthusage=`echo "$gpuutilstats"|grep PCIe=|sed 's/[^0-9]//g'`

	gpufreq=`echo "$gpuclockstats"|grep nvclock=|sed 's/[^0-9]//g'`
	gpumemfreq=`echo "$gpuclockstats"|grep memclock=|sed 's/[^0-9]//g'`

	echo "$gpuid $gpuname"
	echo -e "\tGPU running at $gpufreq Mhz\n\t\tat a $gpuusage% worcycle"
	echo -e "\tCurrent temperature : $gputemp°C"
	echo -e "\tMemory usage : $gpuusedmem MB/$gputotalmem MB"
	echo -e "\tMemory running at $gpumemfreq Mhz\n\t\tat a $memoryusage% workcycle"
	echo -e "\tPCIe bandwidth usage : $bandwidthusage%"
done

fanlist=`nvidia-settings -t -q fans | sed -e 's/^ *//' | grep -e '^\['` #No leading spaces, to get lines starting in '['

echo $fanlist | while read LINE; do
	fanid=`echo "$LINE" | cut -d \  -f 2 | grep -E -o '\[.*\]'`
	fanusage=`nvidia-settings -t -q "$fanid"/GPUCurrentFanSpeed`
	fanrpm=`nvidia-settings -t -q "$fanid"/GPUCurrentFanSpeedRPM`

	echo "$fanid : $fanrpm RPM ($fanusage%)"
done
##https://devtalk.nvidia.com/default/topic/524402/gpu-utilization-on-geforce-cards/?offset=4
##https://devtalk.nvidia.com/default/topic/624699/a-lot-of-nvidia-settings-query-is-blank/

##These lines require the coolbit option in yout Xorg to be set at 4 (manual freq fans only) or 5 (manual freq all all)
##nvidia-settings -a [gpu:0]/GPUFanControlState=1	##Switch to manual control, 0 resets to autumatic
##nvidia-settings -a [fan:0]/GPUCurrentFanSpeed=30 ##Idle
##nvidia-settings -a [fan:0]/GPUCurrentFanSpeed=50	##Stock maximum
