import argparse
import re
import sys
import urllib.request
import os

def get_content(source):
    """
    Retrieves M3U content from a URL or a local file.
    """
    # Check if source looks like a URL
    if source.lower().startswith(('http://', 'https://')):
        print(f"Downloading playlist from: {source}")
        try:
            with urllib.request.urlopen(source) as response:
                # Decode content to string (assuming utf-8)
                return response.read().decode('utf-8').splitlines()
        except Exception as e:
            print(f"Error fetching URL: {e}")
            sys.exit(1)
    
    # Otherwise treat as local file
    else:
        if not os.path.exists(source):
            print(f"Error: File '{source}' not found.")
            sys.exit(1)
        
        print(f"Reading local file: {source}")
        try:
            with open(source, 'r', encoding='utf-8') as f:
                return f.read().splitlines()
        except Exception as e:
            print(f"Error reading file: {e}")
            sys.exit(1)

def process_m3u(lines):
    """
    Iterates through lines, adds tvg-chno sequentially to #EXTINF lines.
    """
    new_lines = []
    channel_count = 1
    
    # Regex to match the start of an EXTINF line: #EXTINF: plus the duration (digits or -1)
    # Example matches: #EXTINF:-1  or #EXTINF:0
    start_pattern = re.compile(r'^(#EXTINF:[-0-9\.]+)')
    
    # Regex to remove existing tvg-chno tags to prevent duplicates
    # Matches: tvg-chno="123" or tvg-chno=123 (with leading space)
    existing_tag_pattern = re.compile(r' ?tvg-chno=["\']?[\d]+["\']?')

    for line in lines:
        line = line.strip()
        
        if line.startswith('#EXTINF:'):
            # 1. Remove existing tvg-chno tag if present
            clean_line = existing_tag_pattern.sub('', line)
            
            # 2. Insert new tvg-chno tag
            # We insert it right after the duration to be safe
            # \1 refers to the captured duration part (e.g., "#EXTINF:-1")
            replacement = f'\\1 tvg-chno="{channel_count}"'
            
            modified_line = start_pattern.sub(replacement, clean_line)
            
            new_lines.append(modified_line)
            channel_count += 1
        else:
            new_lines.append(line)
            
    return new_lines

def main():
    parser = argparse.ArgumentParser(description="Add sequential tvg-chno tags to an M3U playlist.")
    parser.add_argument("input", help="Input M3U file path OR URL")
    parser.add_argument("-o", "--output", default="numbered_playlist.m3u", help="Output file path (default: numbered_playlist.m3u)")
    
    args = parser.parse_args()

    # 1. Get Content
    lines = get_content(args.input)

    # 2. Process Content
    print("Processing channels...")
    processed_lines = process_m3u(lines)

    # 3. Save File
    try:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write('\n'.join(processed_lines))
        print(f"Success! Saved to: {args.output}")
    except Exception as e:
        print(f"Error writing output file: {e}")

if __name__ == "__main__":
    main()
