#!/bin/bash

source=$1
target=$2
log_file=$3

# Get dropped frame numbers from log file
frame_numbers=$(cat $log_file | grep "frames number" | awk '{print "eq(n,"$8")"}' | paste -sd "+")

# Delete dropped frames from source video
echo "Dropping frames from source video $source..."
ffmpeg -v error -i $source -vf "select='not($frame_numbers)',setpts=N/FRAME_RATE/TB" -f yuv4mpegpipe -pix_fmt yuv420p source_dropped.yuv

./vmaf -r source_dropped.yuv -d $target

rm source_dropped.yuv

# Calculate dropped rate
frames=$(ffprobe -v error -count_frames -show_entries stream=nb_read_frames -print_format default=nokey=1:noprint_wrappers=1 $target)
dropped_frames=$(cat $log_file | grep "frames number" | wc -l)
total_frames=$(echo "$frames+$dropped_frames" | bc)

dropped_rate=$(echo "scale=4; 100*$dropped_frames/($total_frames)" | bc)

echo "Drop rate: $dropped_rate% ($dropped_frames / $total_frames)"
