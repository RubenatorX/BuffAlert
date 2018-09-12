--[[Copyright © 2018, Rubenator
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of TreasurePool nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL KENSHI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'BuffAlert'
_addon.author = 'Rubenator'
_addon.version = '0.1'
require("luau")

local buffs_to_watch = {["Mana Wall"]={buff_duration=5*60, alert_time=1*60}
					   }
local sound_path = "alert.wav"
local sound_in_addon_folder = true
local message = true

function warning(buff)
	if buffs_to_watch[buff] == nil then return end
	if buffs_to_watch[buff].canceled == nil or not buffs_to_watch[buff].canceled then
		local buff_data = buffs_to_watch[buff]
		local minutes = math.floor(buff_data.alert_time / 60)
		local seconds = buff_data.alert_time % 60
		local time_string = string.format("%d:%00d",minutes, seconds)
		--output log message?
		if message then
			windower.add_to_chat(4, buff.." will wear off in "..time_string..".")
		end
		--make sound?
		local path = sound_path
		if sound_in_addon_folder then
			path = windower.addon_path .. sound_path
		end
		if sound_path then
			print("playing sound ", path)
			windower.play_sound(path)
		end
		print("sound done")
	end
end

function get_buff_name(buff_id)
	if res.buffs[buff_id] and res.buffs[buff_id].en then
		return res.buffs[buff_id].en
	else
		return nil
	end
end

windower.register_event('gain buff', function(buff_id)
	local buff = get_buff_name(buff_id)	
	if buffs_to_watch[buff] ~= nil then
		buffs_to_watch[buff].canceled = false
		coroutine.schedule(function()
			warning(buff)
		end, buffs_to_watch[buff].buff_duration - buffs_to_watch[buff].alert_time)
	end
end)

windower.register_event('lose buff', function(buff_id)
	local buff = get_buff_name(buff_id)
	if buffs_to_watch[buff] ~= nil then
		buffs_to_watch[buff].canceled = true
	end
end)