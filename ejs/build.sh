#!/bin/bash

echo "Building..."
# Create output directory if it doesn't exist
rm -rf ./dist   
mkdir -p ./dist

# First copy all assets
echo "Copying assets..."
cp -r ./assets ./dist/

# Remove files that will be optimized
echo "Removing files that will be optimized..."
rm ./dist/assets/css/style.css
rm ./dist/assets/js/custom.js

# Optimize CSS with esbuild
echo "Optimizing CSS..."
npx esbuild ./assets/css/style.css \
  --minify \
  --outfile=./dist/assets/css/style.css

# Optimize JavaScript
echo "Optimizing JavaScript..."
npx terser ./assets/js/custom.js \
  --compress \
  --mangle \
  --keep-classnames \
  --keep-fnames \
  --output ./dist/assets/js/custom.js


# Convert only uploads directory images to WebP
echo "Converting uploads images to WebP..."
find ./dist/assets/img/uploads -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read img; do
  webp_path="${img%.*}.webp"
  
  # Get image dimensions
  dimensions=$(identify -format "%wx%h" "$img")
  width=$(echo $dimensions | cut -d'x' -f1)
  

  target_size=150000
  initial_quality=60
  if [ ! -f "$webp_path" ]; then
    echo "Converting: $img (Target size: $(($target_size/1000))KB)"
    
    # First attempt with initial quality
    if cwebp -q $initial_quality -size $target_size "$img" -o "$webp_path" && [ -s "$webp_path" ]; then
      echo "Successfully converted: $img"
      rm "$img"
    fi
  fi
done

echo "Converting images to WebP completed!"

# Default data file paths
BASE_DATA="./data/base.json"
HOME_DATA="./data/data.json"
ABOUT_DATA="./data/about-data.json"
CONTACT_DATA="./data/contact-data.json"
ARCHITECTURE_DATA="./data/architecture-data.json"
TEXTILE_DATA="./data/textile-data.json"
GALLERY_DATA="./data/gallery-data.json"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --base-data)
      BASE_DATA="$2"
      shift 2
      ;;
    --home-data)
      HOME_DATA="$2"
      shift 2
      ;;
    --about-data)
      ABOUT_DATA="$2"
      shift 2
      ;;
    --contact-data)
      CONTACT_DATA="$2"
      shift 2
      ;;
    --architecture-data)
      ARCHITECTURE_DATA="$2"
      shift 2
      ;;
    --textile-data)
      TEXTILE_DATA="$2"
      shift 2
      ;;
    --gallery-data)
      GALLERY_DATA="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

echo "Merging base.json with page specific data..."
# Merge base.json with page specific data
jq -s '.[0] * .[1]' $BASE_DATA $HOME_DATA > ./dist/data.json
jq -s '.[0] * .[1]' $BASE_DATA $ABOUT_DATA > ./dist/about-data.json
jq -s '.[0] * .[1]' $BASE_DATA $CONTACT_DATA > ./dist/contact-data.json
jq -s '.[0] * .[1]' $BASE_DATA $ARCHITECTURE_DATA > ./dist/architecture-data.json
jq -s '.[0] * .[1]' $BASE_DATA $TEXTILE_DATA > ./dist/textile-data.json
jq -s '.[0] * .[1]' $BASE_DATA $GALLERY_DATA > ./dist/gallery-data.json

# First build HTML files
echo "Building HTML files..."
npx ejs ./views/home/base/base.ejs -o ./dist/index.html -f ./dist/data.json
npx ejs ./views/about/base/base.ejs -o ./dist/about.html -f ./dist/about-data.json
npx ejs ./views/contact/base/base.ejs -o ./dist/contact.html -f ./dist/contact-data.json
npx ejs ./views/architecture/base/base.ejs -o ./dist/architecture.html -f ./dist/architecture-data.json
npx ejs ./views/textile/base/base.ejs -o ./dist/textile.html -f ./dist/textile-data.json
npx ejs ./views/gallery/base/base.ejs -o ./dist/gallery.html -f ./dist/gallery-data.json

echo "Removing data files..."
rm ./dist/data.json
rm ./dist/about-data.json
rm ./dist/contact-data.json
rm ./dist/architecture-data.json
rm ./dist/textile-data.json
rm ./dist/gallery-data.json

echo "Copying to final destination..."
rm -rf  ../src/statik/dist
cp -r ./dist ../src/statik/
rm -rf ./dist

echo "Build completed! Output is in src/statik/dist directory"

