# instagram-reel-generator

A shell script that turns a folder of mixed photos into an Instagram-ready video — with a custom background image showing through wherever photos don't fill the frame.

**What it produces:**
- A 9:16 video (native Reels format) with your content centered in a 4:5 safe zone
- Your background image fills the full canvas 
- Each photo displays for about 0.4 seconds with slight random variation for an organic feel
- Portrait, landscape, and square photos all work — no cropping, no black bars

---

## Requirements

- **Mac only** (the script uses macOS Terminal)
- **ffmpeg** must be installed (free — see setup instructions below)
- Python 3 (comes pre-installed on modern Macs)

---

## Usage

```bash
./make_reel.sh /path/to/your/images /path/to/background/photo
```

You can leave out the background photo parameter if you save your background file as "background.jpg" in the same folder where you saved the script.
The output file `reel_output.mp4` will also appear in the folder where you saved the script.
Save all the images that you want to feature in the video in their own folder.

**Supported image formats:** JPG, JPEG, PNG, WEBP

**Image order:** Images are sorted alphabetically by filename. To control order, name your files `01_photo.jpg`, `02_photo.jpg`, etc. The script picks up images **one level deep only** — don't put images in subfolders inside your image folder.

**To change the display duration**, open the script in a text editor and change the `BASE_DURATION` value (in seconds). `VARIANCE` controls how much the timing randomizes.

---

## Examples

The `examples/` folder contains a sample background and a few images with different aspect ratios so you can see how each is handled:

- Portrait photo → fills the full 4:5 frame
- Landscape photo → fits width, background shows top and bottom
- Square photo → fits width, background shows top and bottom

---

## Limitations

- **Mac only.** The script uses bash features and assumes a macOS environment. It has not been tested on Linux or Windows (WSL may work but is untested).
- **No audio.** The output video has no sound. Add music separately in Instagram or a video editor after export.
- **No transitions.** Hard cuts only — no crossfades or effects.
- **Large image sets may be slow.** FFmpeg processes everything in a single pass; 50+ images may take a few minutes.

---

## Step-by-step instructions for first-timers

If you've never used Terminal before, you can follow these steps. You only need to do the setup once.

### Step 1 — Install ffmpeg

1. Open **Terminal** (press `Cmd + Space`, type "Terminal", press Enter)
2. 
3. Paste this command and press Enter:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   This installs Homebrew, a package manager for Mac. It may take a few minutes and ask for your password.
   
4. Once that finishes, paste this and press Enter:
   ```
   brew install ffmpeg
   ```
   This may take several minutes. That's normal.

### Step 2 — Download the script

Download `make_reel.sh` from this repository and save it somewhere you'll remember — your Desktop or a project folder works fine.

### Step 3 — Prepare your files

1. Put all your photos in a single folder (e.g. `Desktop/my-photos/`)
2. Name them so they sort in the order you want: `01_image.jpg`, `02_image.jpg`, etc.
3. Have your background image ready (JPG or PNG)

### Step 4 — Run the script

1. Open Terminal
2. Make the script executable by typing this (you only need to do this once):
   ```
   chmod +x
   ```
   Then drag the `make_reel.sh` file from Finder into the Terminal window — it will paste the full path. Press Enter.

3. Now type:
   ```
   ./make_reel.sh
   ```
   Then drag your **image folder** into Terminal (pastes the path), add a space, then drag your **background image** into Terminal (pastes that path). Don't make any edits to the paths that appear, even if they look weird. Press Enter.

   It should look something like:
   ```
   ./make_reel.sh /Users/yourname/Desktop/my-photos /Users/yourname/Desktop/background.jpg
   ```

4. Wait for it to finish. When you see `✓ Done → reel_output.mp4`, the file is ready.

### Step 5 — Find your video

The file `reel_output.mp4` will be in whichever folder your Terminal was pointing to when you ran the script. If you're not sure where that is, you can type `open .` in Terminal to open that folder in Finder.
