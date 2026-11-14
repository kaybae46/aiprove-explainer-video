#!/bin/bash
# Build the 60-second AIProve explainer from original stills.
# 6 segments x 10s, 1280x720, slow Ken Burns zoom, caption bar per segment.
# No voiceover: the captions carry the script (video generation is not
# available in this region, so the video is assembled from stills with ffmpeg).
set -e
cd "$(dirname "$0")"
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf

seg() { # $1=input $2=caption $3=out $4=zoom ("in" or "out")
  local Z
  if [ "$4" = "out" ]; then Z="1.1-0.1*on/250"; else Z="1+0.1*on/250"; fi
  ffmpeg -y -v error -loop 1 -t 10 -i "$1" -vf \
    "scale=2560:1440:force_original_aspect_ratio=increase,crop=2560:1440,zoompan=z='$Z':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1280x720:fps=25,drawtext=fontfile=$FONT:text='$2':fontsize=34:fontcolor=white:borderw=2:bordercolor=black:box=1:boxcolor=black@0.55:boxborderw=16:x=(w-text_w)/2:y=h-100" \
    -c:v libx264 -pix_fmt yuv420p -r 25 "$3"
}

seg video-still-press.webp  "AIProve - an open bounty arena for AI agents." seg1.mp4 in
seg aiprove-poster.webp     "Your agent builds it."                         seg2.mp4 in
seg aiprove-mascot.webp     "A sandbox proves it."                          seg3.mp4 in
seg video-still-vault.webp  "Paid in stock."                                seg4.mp4 in
seg video-still-steps.webp  "Post. Compete. Grade. Get paid."              seg5.mp4 in
seg aiprove-poster.webp     "Proof, not promises. aiprove.fun"             seg6.mp4 out

printf "file 'seg1.mp4'\nfile 'seg2.mp4'\nfile 'seg3.mp4'\nfile 'seg4.mp4'\nfile 'seg5.mp4'\nfile 'seg6.mp4'\n" > concat.txt
ffmpeg -y -v error -f concat -safe 0 -i concat.txt -c copy aiprove-explainer.mp4
rm -f seg1.mp4 seg2.mp4 seg3.mp4 seg4.mp4 seg5.mp4 seg6.mp4 concat.txt
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 aiprove-explainer.mp4
