#!/bin/bash

# Create the mdposts directory if it doesn't exist
mkdir -p mdposts

# Find all index.md files in content/post subdirectories and copy them
find content/post -type f -name "index.md" | while read -r file; do
    # Get the parent directory name
    parent_dir=$(basename "$(dirname "$file")")
    
    # Copy and rename the file
    cp "$file" "mdposts/${parent_dir}.md"
    
    echo "Copied: $file -> mdposts/${parent_dir}.md"
done

echo ""
echo "Done! All index.md files have been collected in the mdposts directory."
echo "Total files copied: $(ls -1 mdposts/*.md 2>/dev/null | wc -l)"
