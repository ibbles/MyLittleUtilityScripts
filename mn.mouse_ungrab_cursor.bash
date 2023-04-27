#!/bin/bash

# This script tries to abort a mouse cursor grab action. For example, when
# debugging GUI applications with a debugger attached in a click callback we may
# end up in a state where the current halted click prevent any new clicks from
# registering making it difficult to use IDE-integrated debuggers.

setxkbmap -option grab:break_actions
xdotool key XF86Ungrab
