# *Subtitle.lua*
A spiritual successor of [srt.lua][srt]

## To do:
- [ ] Formats to be supported
	- [ ] XML Timed Content
	- [ ] WebVTT
	- [ ] VTT
	- [ ] SBV
- [ ] Luarocks package
- [ ] Good docs
- [ ] Format conversion

## Features
- Formats supported
	- SRT
- Simple API (pretty much backwards compatible with [srt.lua][srt])
- Will try to detect the format given automatically

## Flaws
- ~~Inefficient~~ → (Not that much anymore. content is cached)
- Requires [Object.lua][obj] in order to function.
- Docs mention format yet to be included

## Getting started
1. 📡 Get a copy of srt.lua from the [Official Repository][sub]
2. 💾 Copy `Subtitle.lua` where you like to use it, or just on the root directory of the project.3. ⚙ Add it to your project like this
	```lua
	local Subtitle = require("path/to/srt")
	```
4. 📃 Pass a plain text representation of the file
	```lua
	local captionsData = io.read("path/to/captions")
	local captionsObject = Subtitle:new(captionsData)
	--or
	local captionsObject = Subtitle(captionsData)
	```
5. 🎬 Tell in what part of the media we are right now, since this is a generic pure lua function a better example is done with the [LÖVE2D framework][l2d], so we can get a real world example
	```lua
	local coolVideo = love.graphics.newVideo("path/to/cool/video.ogg")

	function love.update(dt)
		--A media source on love returns a number in seconds when the method :tell() is called
		--srt.lua takes the elapsed time in seconds so be aware of passing seconds as an integer
		local tellTime = coolVideo:tell()

		--We pass the time elapsed in seconds
		captionsObject:setTime(tellTime)

		--We tell srt.lua to apply changes, an optional argument is the delta so we account the lag
		--This method has been deprecated since setTime calls it internally but has not been removed
		--For the lag compensation feature that has. Beware of not using it alone since you could get
		--out of sync with the media being played with.
		captionsObject:update(dt)
	end
	```

6. 💎 Profit.
	(jokes aside once changes are applied we can ask for the text and use it,
	⚠ But take note that the result is raw from the file,
	so any gibberish has to be cleaned manually r/NotMyJob)
	Yes this behavior is inherited from [srt.lua][srt].
	```lua
	function love.draw()
		--We draw the video
		love.graphics.draw(coolVideo)

		--We draw the subs
		love.graphics.setFont(48)
		local captionsText = captionsObject:getText()
		local windowWidth, windowHeight = love.graphics.getDimensions()
		love.graphics.print(captionsText, 0, windowHeight - 48)
	end

	```

## Documentation
The documentation can be found on the [doc][doc] folder.


<!--Links-->
[srt]: https://github.com/alejandro-alzate/srt-lua
[sub]: https://github.com/alejandro-alzate/Subltitle.lua
[obj]: https://github.com/alejandro-alzate/Object.lua
[l2d]: https://love2d.org/

[doc]: https://github.com/alejandro-alzate/Subtitle.lua/tree/main/doc