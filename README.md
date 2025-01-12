# 藤 -Resizer-

This tool is used to resize multiple images in one shot. It is quite handy because you just drag your image files to the window after specifying the size of future images.
It also supports to drag a folder itself that contains multiple images. What is more, you can automatically name these files according to the generation rule you define.
You can get the highest quality of resized images thanks to 3-lobed Lanczos-windowed sinc interpolation.
This tool has a feature to automatically output a HTML file so that it is easy to upload the images to the web with thumbnail.

The following items are required knowledge and understanding before using this tool:

- Zip file and its unpacking
- Path and file extension
- Drag operation

Note that on system earlier than Windows Vista, you must NOT put the executable under 'Program Files' directory because it creates ini file on the same directory as the executable.

## System Confirmed to Run

- Windows XP
- Windows 7 (32bit/64bit)
- Windows 8 (32bit/64bit)
- Windows 10 (64bit)

## System Not Confirmed to Run

- Not yet

## Note

- Drag and drop the images not to the executable (or shortcut) but to the window booted up.

## Feature Comparison Table for Major Version

Item                                     |2.x         |3.x (32bit) |3.x (64bit) |4.x (32bit) |4.x (64bit)
-----------------------------------------|------------|------------|------------|------------|------------
Binary size                              |◎          |○          |△          |△          |×
Default number of import image format    |× (IL)     |○ (WIC)    |○ (WIC)    |○ (WIC)    |○ (WIC)
Susie plugin support                     |○          |○          |○          |○          |○
AtoB Converter plugin support            |○          |○          |×          |○          |×
JPEG subsampling-off compression support |○          |○          |○          |×          |×
Parallel processing support              |×          |○          |○          |○          |○
Taskbar progress indicator               |×          |○          |○          |○          |○
High DPI support                         |×          |×          |×          |○          |○
Ref: Version of Delphi used to build     |Delphi 2007 |Delphi XE2  |Delphi XE2  |Delphi 12.1 |Delphi 12.1
