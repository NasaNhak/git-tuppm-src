--TUPPM Header

local this = {}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table








function this.MissionOpeningSoundSetting()
	
	
end




function this.GameOverSoundSetting()
	
	
	
end




function this.MissionClearJingleSetting()
	
	
end



this.bgmList = {
		--r56 It is possible to add music/sounds from other missions via the sdf files - bgm_mtbs_phase.sdf in this case
		--loadBanks was updated with bgm_s10030
		--There is no specific MB check required in TUPPM.PlayPulloutBGMFromM2() since if the sound bank is not loaded, the BGM will not be played
		bgm_mtbs_departure = {
			start = "Play_bgm_s10030_departure",
			finish = "Stop_bgm_s10030_departure",
			switch = {
				"Set_Switch_bgm_s10030_helicall",
				"Set_Switch_bgm_s10030_departure",
			}
		},
}




function this.SetScene_ShootingRange()
	TppSound.SetSceneBGM("bgm_shooting_range")
end




return this
