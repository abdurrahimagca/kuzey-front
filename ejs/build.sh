#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

# Verify required environment variables
if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo "Error: GOOGLE_MAPS_API_KEY environment variable is not set"
    exit 1
fi

# Create output directory if it doesn't exist
rm -rf ./dist   
mkdir -p ./dist

# Create assets directory in output if it doesn't exist 
mkdir -p ./dist/assets

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

# Merge base.json with page specific data
jq -s '.[0] * .[1]' $BASE_DATA $HOME_DATA > ./dist/data.json
jq -s '.[0] * .[1]' $BASE_DATA $ABOUT_DATA > ./dist/about-data.json
jq -s '.[0] * .[1]' $BASE_DATA $CONTACT_DATA > ./dist/contact-data.json
jq -s '.[0] * .[1]' $BASE_DATA $ARCHITECTURE_DATA > ./dist/architecture-data.json
jq -s '.[0] * .[1]' $BASE_DATA $TEXTILE_DATA > ./dist/textile-data.json
jq -s '.[0] * .[1]' $BASE_DATA $GALLERY_DATA > ./dist/gallery-data.json
# Build pages using merged data
npx ejs ./views/home/base/base.ejs -o ./dist/index.html -f ./dist/data.json
npx ejs ./views/about/base/base.ejs -o ./dist/about.html -f ./dist/about-data.json
npx ejs ./views/contact/base/base.ejs -o ./dist/contact.html -f ./dist/contact-data.json
npx ejs ./views/architecture/base/base.ejs -o ./dist/architecture.html -f ./dist/architecture-data.json
npx ejs ./views/textile/base/base.ejs -o ./dist/textile.html -f ./dist/textile-data.json
npx ejs ./views/gallery/base/base.ejs -o ./dist/gallery.html -f ./dist/gallery-data.json
# Copy assets directory
cp -r ./assets/* ./dist/assets/

# Replace API key in custom.js
sed -i.bak "s/{{GOOGLE_MAPS_API_KEY}}/$GOOGLE_MAPS_API_KEY/g" ./dist/assets/js/custom.js
rm ./dist/assets/js/custom.js.bak

# Clean up temporary data files
rm ./dist/data.json
rm ./dist/about-data.json
rm ./dist/contact-data.json
rm ./dist/architecture-data.json
rm ./dist/textile-data.json
rm ./dist/gallery-data.json
rm -rf  ../src/statik/dist
cp -r ./dist ../src/statik/
rm -rf ./dist


echo "Build completed! Output is in src/statik/dist directory"
