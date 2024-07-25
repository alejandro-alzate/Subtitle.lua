--luacheck: ignore unused argument self
local Object = package.loaded.Object or require("Object")
local Subtitle = Object:extend()

-- -> CREATION
-----------------------------
function Subtitle:new(str) return Subtitle(str) end
function Subtitle:init(str)
	self.clock = 0
	self.cache = {}
	self.config = {}
	self.format = "Srt"
	self.baseString = tostring(str) or ""
	self.outputStack = {}
	self.outputString = ""
	self.fragmentCount = 0
	self.updateOnQuery = true
	self.outputFragment = {}
	self:parse()
end

-- -> PARSING
-----------------------------
function Subtitle:parsePlainSrt(str)
	if type(str) ~= "string" then return {} end

	local fragmentCount = 0
	local fragments = {}
	for
		srtIndex,
		hours1, minutes1, seconds1, millis1,
		hours2, minutes2, seconds2, millis2,
		coords, text
	in str:gmatch(
		"(%d+)\n"..
		"(%d%d):(%d%d):(%d%d),(%d%d%d) %-%-> (%d%d):(%d%d):(%d%d),(%d%d%d)"..
		"(.-)\n(.-)\n\n")
	do
		local X1, X2, Y1, Y2 = 0, 0, 0, 0
		local hasCustomPos = false

		for a, b, c, d in coords:gmatch(" X1:(%d+) X2:(%d+) Y1:(%d+) Y2:(%d+)") do
			hasCustomPos = true
			X1, X2, Y1, Y2 = a, b, c, d
		end

		fragmentCount = fragmentCount + 1
		local result1 = millis1 / 1000
		result1 = result1 + seconds1
		result1 = result1 + (minutes1 * 60)
		result1 = result1 + (hours1 * 3600)

		local result2 = millis2 / 1000
		result2 = result2 + seconds2
		result2 = result2 + (minutes2 * 60)
		result2 = result2 + (hours2 * 3600)

		local newFragment = {
			index		= srtIndex,
			start		= result1,
			finish		= result2,
			text		= text,
			position	= {
				X1 = tonumber(X1),
				X2 = tonumber(X2),
				Y1 = tonumber(Y1),
				Y2 = tonumber(Y2)
			},
			hasCustomPosition = hasCustomPos,
		}

		table.insert(fragments, newFragment)
	end

	return {
		fragments = fragments,
		fragmentCount = fragmentCount,
	}
end

function Subtitle:parseLRC(str)
	if type(str) ~= "string" then return {} end

	local fragmentCount = 0
	local fragments = {}

	-- Regex pattern to match LRC time tags and lyrics
	for timeTag, lyric in str:gmatch("%[(%d%d):(%d%d)%.(%d%d)%](.-)\n") do
		-- Skip lines that start with '#'
		if not lyric:find("^#") then
			local minutes = tonumber(timeTag:sub(1, 2))
			local seconds = tonumber(timeTag:sub(4, 5))
			local hundredths = tonumber(timeTag:sub(7, 8))

			local timeInSeconds = minutes * 60 + seconds + hundredths / 100

			fragmentCount = fragmentCount + 1

			local newFragment = {
				index = fragmentCount,
				start = timeInSeconds,
				finish = timeInSeconds, -- LRC does not specify end time, so we use start time
				text = lyric,
				position = nil, -- LRC does not have position information
				hasCustomPosition = false,
			}

			table.insert(fragments, newFragment)
		end
	end

	return {
		fragments = fragments,
		fragmentCount = fragmentCount,
	}
end

-- -> PROCESSING
-----------------------------
function Subtitle:detectFormat()
	self.format = "Unknown"

	--Find in the first line WEBVTT
	if self.baseString:sub(1, 6) == "WEBVTT" then
		self.format = "WebVTT"
		return
	end

	--Find the <?xml tag or the <tt tag
	if self.baseString:find("^<?xml") or self.baseString("<tt") then
		self.format = "XML"
		return
	end

	--Find this nonsense
	-- 1
	-- 00:00:00,000 --> 00:00:00,000
	if self.baseString:find("^%d+%s*\n%d%d:%d%d:%d%d,%d%d%d --> %d%d:%d%d:%d%d,%d%d%d") then
		self.format = "Srt"
		return
	end

	--Find this
	--Wikipedia article:
	--The original LRC format (sometimes called the Simple LRC format)
	--is formed of two types of tags (time tags and optional ID tags),
	--with one tag per line. Time tags have the format [mm:ss.xx]lyric
	--where mm is minutes, ss is seconds, xx is hundredths of a second,
	--and lyric is the lyric to be played at that time
	if self.baseString:find("%[%d%d:%d%d%.%d%d%]") then
		self.format = "LRC"
	end
end

function Subtitle:processFragmentTable(tbl)
	if tbl.fragments then
		self.cache = tbl.fragments
		self.fragmentCount = tbl.fragmentCount
		return true
	else
		self.cache = {}
		return false
	end
end

function Subtitle:parse()
	self.cache = {}

	if self.format == "Srt" then
		self:processFragmentTable(Subtitle:parsePlainSrt(self.baseString))
	--elseif self.format == "WebVTT" then
	--elseif self.format == "XML" then
	elseif self.format == "LRC" then
		self:processFragmentTable(Subtitle:parseLRC(self.baseString))
	end
end

function Subtitle:processCache()
	self.outputStack = {}
	self.outputFragment = {}

	for _, v in ipairs(self.cache) do
		if
			--When start and finish are diferent
			--We are dealing with a framed fragment
			(
				(v.start ~= v.finish)
				and v.start < self.clock
				and v.finish > self.clock
			)
			or
			--When start and finish are the same we just check for the nearest
			--fragment
			(
				(v.start == v.finish)
				and v.start < self.clock
			)

		then
			table.insert(self.outputStack, v)
			self.outputFragment = v
		end
	end
	self.outputString = self.outputFragment.text or ""
end

-- -> API
-----------------------------
function Subtitle:update(dt)
	if type(dt) ~= "number" then dt = 0 end
	self.clock = self.clock + dt
	self:processCache()
end

function Subtitle:getTime()
	return self.clock
end

function Subtitle:setTime(time)
	if type(time) ~= "number" then time = 0 end
	self.clock = time
	self:update(0)
end

function Subtitle:getText()
	if self.updateOnQuery then
		self:parse()
	end
	return self.outputString
end

function Subtitle:setText(str)
	self.cache = {}
	self.format = ""
	self.baseString = tostring(str) or ""
	self.outputStack = {}
	self.outputString = ""
	self.fragmentCount = 0
	self.outputFragment = {}
	self:detectFormat()
	self:parse()
	self:update(0)
end

function Subtitle:getCurrentFragmentStack()
	return self.outputStack
end

function Subtitle:getCurrentFragment()
	return self.outputFragment
end

function Subtitle:currentFragmentHasCustomPosition()
	return self.outputFragment.hasCustomPosition
end

function Subtitle:getCurrentFragmentPosition()
	if self.outputFragment.hasCustomPosition then
		return self.outputFragment.position
	else
		return false
	end
end

function Subtitle:__tostring()
	return self:getText()
end

return Subtitle