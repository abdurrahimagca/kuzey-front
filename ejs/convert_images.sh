#!/bin/bash

# Check if a directory was provided
if [ $# -eq 0 ]; then
    echo "Please provide a directory path"
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Go to the specified directory
cd "$1" || exit

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first:"
    exit 1
fi

# Convert each image to WebP and delete original
for img in *.{jpg,jpeg,png}; do
    # Skip if no files found
    [ -f "$img" ] || continue
    
    filename="${img%.*}"
    
    # Try conversion with ImageMagick
    if convert "$img" -quality 85 "${filename}.webp"; then
        echo "Converted $img to WebP"
        # Only remove original if new file exists and has size > 0
        if [ -f "${filename}.webp" ] && [ -s "${filename}.webp" ]; then
            rm "$img"
            echo "Deleted original $img"
        else
            echo "Warning: Conversion may have failed for $img"
        fi
    else
        echo "Failed to convert $img"
    fi
done

echo "Conversion complete!" 