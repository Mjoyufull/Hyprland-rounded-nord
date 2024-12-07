#!/bin/bash
# Write the PID of the script to a file for later retrieval
echo $$ > /tmp/wallpaper_slideshow_pid
# Clean up the PID file on exit
trap 'rm -f /tmp/wallpaper_slideshow_pid' EXIT
# Set the paths to both directories
wallpapersDir1="$HOME/Pictures/newpc/miku/Norded/Twitter"
wallpapersDir2="$HOME/Pictures/newpc/miku/Norded/"
# Combine both directories into one array
allWallpapers=("${wallpapersDir1}"/* "${wallpapersDir2}"/*)
# Initialize the index for the wallpaper with a random value
currentIndex=$((RANDOM % ${#allWallpapers[@]}))
# Log to see exactly what's going on
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /tmp/wallpaper_slideshow.log
}
# Function to change the wallpaper based on the current index
change_wallpaper() {
    selectedWallpaper="${allWallpapers[$currentIndex]}"
    log_message "Changing wallpaper to: $selectedWallpaper"
    # Apply the wallpaper
    swww img --fill-color 3b4252 --resize crop -f CatmullRom --transition-type grow --transition-pos 0.854,0.977 --transition-step 90 --transition-fps 60 "$selectedWallpaper"
}
# Function to move to the next wallpaper
next_wallpaper() {
    currentIndex=$(( (currentIndex + 1) % ${#allWallpapers[@]} ))
    log_message "Switching to next wallpaper: ${allWallpapers[$currentIndex]}"
    change_wallpaper
}
# Function to move to the previous wallpaper
prev_wallpaper() {
    currentIndex=$(( (currentIndex - 1 + ${#allWallpapers[@]}) % ${#allWallpapers[@]} ))
    log_message "Switching to previous wallpaper: ${allWallpapers[$currentIndex]}"
    change_wallpaper
}
# Start by changing to a random wallpaper
log_message "Starting with random wallpaper index: $currentIndex"
change_wallpaper
# Trap signals for next and previous wallpaper actions
trap 'log_message "Next wallpaper signal received"; next_wallpaper' SIGUSR1
trap 'log_message "Previous wallpaper signal received"; prev_wallpaper' SIGUSR2
# Infinite loop to wait for the next command
while true; do
    log_message "Sleeping for 4 minutes before the next wallpaper change"
    sleep 240 &  # Sleep in the background
    wait $!  # Wait for the sleep to finish or a signal to be caught

    # Check if a signal was received
    if [ $? -eq 0 ]; then
        # No signal received, change to next wallpaper
        next_wallpaper
    fi
done
