# *Subtitle.lua* Documentation - The constructor

## Summary

The `Subtitle` class is designed to parse and decode subtitles in various
formats, such as but not limited to SRT, WebVTT, XML, and LRC. It provides an API for 
updating the current time and retrieving the text of the subtitle at 
that time. The class also supports detecting a custom properties for 
some formats such as time and positioning for
individual fragments within the subtitle file.

The `Subtitle` constructor takes one parameter:

1. `optional` `string` `str`: The string to be parsed as a subtitle. This can be any format 
supported by Subtitle.lua, including SRT, WebVTT, XML, and LRC.
