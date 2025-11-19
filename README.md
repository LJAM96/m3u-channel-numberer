# m3u-channel-numberer

A lightweight Python script that automatically adds sequential channel numbers (`tvg-chno`) to M3U playlists. 

This is useful for IPTV players (like TiviMate, Kodi, or Jellyfin) that rely on the `tvg-chno` tag to order channels correctly. If your playlist is sorting alphabetically or randomly, this script forces it to follow the order of the file, starting from channel 1.

##  Features

*   **Versatile Input:** Works with local `.m3u` files OR directly from a URL.
*   **Smart Tagging:** Inserts `tvg-chno="x"` correctly into the `#EXTINF` line.
*   **Clean Update:** Detects and removes existing channel number tags before adding new ones to prevent duplicates.
*   **Zero Dependencies:** Uses only standard Python libraries. No `pip install` required.

##  Prerequisites

*   **Python 3.x** installed on your system.

##  Installation

1.  Clone this repository or download the script.
    ```bash
    git clone https://github.com/yourusername/m3u-channel-numberer.git
    ```
2.  Navigate to the folder.
    ```bash
    cd m3u-channel-numberer
    ```

##  Usage

### Basic Usage (Local File)
Run the script passing your existing M3U file as an argument. By default, it will save the result as `numbered_playlist.m3u`.

```bash
python m3u_numbering.py my_playlist.m3u
