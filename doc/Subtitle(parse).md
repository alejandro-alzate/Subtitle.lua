# *Subtitle.lua* Documentation - The parsing method

## Summary

The `parse()` method parses the input string and builds a cache of 
fragments that can be accessed through the `getCurrentFragmentStack()`, 
`getCurrentFragment()`, `currentFragmentHasCustomPosition()`, and 
`getCurrentFragmentPosition()` methods. The `updateOnQuery` flag 
determines whether the subtitle should update automatically or not.
