#!/bin/sh
cd /home/pi/scienceCentre/tests/stress
python stress.py &
cd /home/pi/scienceCentre/final
processing-java --sketch=display_v2 --run
