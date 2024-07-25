# *Subtitle.lua* Documentation - Home

## Summary

This is a Lua module that implements the Subtitle class, which can be used
to parse and manipulate subtitle files in various formats. The module 
includes several functions for parsing subtitle files, updating the 
subtitle time, and getting the current subtitle text. It also includes 
support for detecting the format of the subtitle file and converting 
between different formats.

## API
Here is a quick but detailed explanation of each method in the Subtitle class:

1. [`Subtitle()`][__call]: The constructor for the Subtitle class. It initializes
the object with default values for the subtitle time, base string, output 
stack, and output fragment. For compatibility this is also accessible by using
[`new()`][__call] that just redirects the call to [`__call`][__call]

2. [`parse()`][parse]: Parses the subtitle file based on the detected format. If 
the format is "Srt", it uses the `parsePlainSrt()` function to parse the 
SRT file. If the format is "XML", it uses the `parseXml()` function to 
parse the XML file. Otherwise, it assumes that the format is "Srt" and 
uses the `parsePlainSrt()` function to parse the SRT file.

3. [`detectFormat()`][detectFormat]: Detects the format of the subtitle file based on the 
first line of the file. If the first line starts with "WEBVTT", it sets 
the format to "WebVTT". If the first line contains "`<?xml`" or "`<tt`", it 
sets the format to "XML". Otherwise, it assumes that the format is "Srt".

4. [`processFragmentTable()`][processFragmentTable]: Processes a table of subtitle fragments. It 
takes the fragment table as an argument and updates the cache with the 
fragments. If the table contains a "fragments" field, it sets the fragment
count to the length of the "fragments" field. Otherwise, it clears the 
cache and returns false.

5. [`processCache()`][processCache]: Processes the cache of subtitle fragments based on 
the current time. It iterates through the cache and adds any fragments 
that start before the current time and finish after the current time to 
the output stack. If there are no fragments in the cache, it clears the 
output stack and returns false. Otherwise, it sets the output fragment to 
the last fragment in the output stack and returns true.

6. [`update()`][update]: Updates the subtitle time based on a delta time (dt). It 
adds dt to the current time and then processes the cache based on the new 
time. If the updateOnQuery flag is set, it parses the subtitle file again 
after updating the time.

7. [`getTime()`][getTime]: Returns the current subtitle time.

8. [`setTime()`][setTime]: Sets the current subtitle time to a specific value (time).
It then processes the cache based on the new time and updates the output 
string. If the updateOnQuery flag is set, it parses the subtitle file 
again after updating the time.

9. [`getText()`][getText]: Returns the current subtitle text. If the updateOnQuery 
flag is set, it parses the subtitle file again before returning the text.

10. [`setText()`][setText]: Sets the base string of the subtitle to a specific value 
(str). It then clears the cache and sets the output stack and output 
fragment to nil. It also detects the format of the subtitle file based on 
the first line and parses the file using the appropriate function. If the 
updateOnQuery flag is set, it updates the time after parsing the subtitle 
file.

11. [`getCurrentFragmentStack()`][getCurrentFragmentStack]: Returns the current output stack (a table
of fragments).

12. [`getCurrentFragment()`][getCurrentFragment]: Returns the current output fragment (the last 
fragment in the output stack).

13. [`__tostring()`][__tostring]: Overrides the default tostring() method for the 
Subtitle class. It returns the current subtitle text.


<!--links-->
[__call]:							./Subtitle(__call).md
[parse]:							./Subtitle(parse).md
[detectFormat]:						./Subtitle(detectFormat).md
[processFragmentTable]:				./Subtitle(processFragmentTable).md
[processCache]:						./Subtitle(processCache).md
[update]:							./Subtitle(update).md
[getTime]:							./Subtitle(getTime).md
[setTime]:							./Subtitle(setTime).md
[getText]:							./Subtitle(getText).md
[setText]:							./Subtitle(setText).md
[getCurrentFragmentStack]:			./Subtitle(getCurrentFragmentStack).md
[getCurrentFragment]:				./Subtitle(getCurrentFragment).md
[__tostring]:						./Subtitle(__tostring).md