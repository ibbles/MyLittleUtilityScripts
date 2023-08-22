#!/bin/bash

function printCurrent {
    echo "Frequencly scaling governors are:"
    for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do cat $i; done
}


if [ $# -eq 1 ] ; then
  if [[ "$1" == "-s" ]] ; then
    shift
    printCurrent
    exit
  fi

  if [[ "$1" == "-g" ]] ; then
    shift
    echo "The clock scaling governors available on standard Linux distributions using kernel version 2.6.36."
    echo " - Performance: keeps the CPU at the highest possible frequency"
    echo " - Powersave: keeps the CPU at the lowest possible frequency"
    echo " - Userspace: exports the available frequency information to the user level (through the /sys file system) and permits user-space control of the CPU frequency"
    echo " - Ondemand: scales the CPU frequencies according to the CPU usage (like does the userspace frequency scaling daemons, but in kernel)"
    echo " - Conservative: acts like the ondemand but increases frequency step by step"
    echo "        source http://www.mjmwired.net/kernel/Documentation/cpu-freq/governors.txt"
    exit
  fi

  if [[ "$1" == "-p" ]] ; then
      shift
      performance="true"
      preSet="true"
  fi

  if [[ "$1" == "-c" ]] ; then
      shift
      conservative="true"
      preSet="true"
  fi
fi

# Print help message if used incorrecly.
if [ $# -ne 0 ] ; then
    echo "Usage: `basename $0` [-s|-g]"
    echo ""
    echo "  -s :  Show current scaling governor for all processors and exit. No changes are made."
    echo "  -g :  Show a description of the standard governors."
    echo ""
    echo "This is a script used to set frequencly scaling governors for the CPUs in the system."
    echo "It is an interactive script that first displays a list of the available governors to "
    echo "the user and then reads an selection from standard in. The selection is assumed to be"
    echo "in the form of a number that matches one of the alternatives just printed. A verification"
    echo "question is asked before making any changes. "
    echo
    echo "The script assuems that the set of available governors are the same for all CPUs."
    exit
fi

if [ $UID -ne 0 ] ; then
  echo "Need root privilges to set CPU settings. Nothing done".
  printCurrent
  exit
fi

# Get list of available governors from CPU 0.
if [[ ! "$preSet" == "true" ]] ; then
    index="0"
    for scaling in `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors` ; do
        echo "${index} = ${scaling}"
        scalings[${index}]=${scaling}
        index=$((${index} + 1 ))
    done
fi

if [ "$performance" == "true" ] ; then
  chosen="performance"
  input="y"
elif [ "$conservative" == "true" ] ; then
  chosen="conservative"
  input="y"
else
# Ask user for one to use.
    echo "Pick one"
    read input
    chosen=${scalings[${input}]}
    echo "Do you want frequencly scaling governor '${chosen}' [y/n]?"
    read input
fi



# Ask for confirmation and then apply changes.
if [ ${input} == "y" ] ; then
    for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo ${chosen} > $i; done
else
    echo "Nothing done"
fi

# Write result of change, just to be sure.
printCurrent

