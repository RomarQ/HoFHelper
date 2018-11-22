OTHelper = {
    name            = "OTHelper",
    version         = "1.0",
    author          = "RoMarQ",
    color           = "7c10b2",    
    menuName        = "OT Helper",

    trialZoneId = 975,

    defaultSettings = {
        trackSpinnerSpawn = true,
        trackCenturionSpawn = true,
        trackRod = true,
        trackArchcustodian = true,
        trackMeteors = true,
        trackCenturionHA = true,
        trackChanneledLightning = true,
        trackReducerFire = true,
        OTHelperTLWLeft = 500,
        OTHelperTLWTop = 500 ,
        NotificationLeft = 700,
        NotificationTop = 300,
        OTHelperArchcustodianLeft = 700,
        OTHelperArchcustodianTop = 500,
    },

    --
    CENTURION_UPDATE_RATE = 1000, -- ms
    CENTURION_FIRST_COOLDOWN = 7,
    CENTURION_COOLDOWN = 60,
    
    centurionTimer = 0,
    --

    --
    ROD_UPDATE_RATE = 1000,
    ROD_COOLDOWN = 70,

    rodTimer = 0,
    --

    --
    METEORS_COOLDOWN = 9,

    meteorsTimer = 0,
    --

    --
    ARCHCUSTODIAN_FIRST_COOLDOWN = 25,
    ARCHCUSTODIAN_SECOND_COOLDOWN = 22,
    ARCHCUSTODIAN_THIRD_COOLDOWN = 22,
    ARCHCUSTODIAN_STUN_COOLDOWN = 12.5,

    stunTimer = 0,
    archcustodianTimer = 0,
    leversPulled = 0,
    --

    --
    CL_DUTATION = 3,
    cl_timer = 0
    --

}

local LUNIT = LibStub:GetLibrary("LibUnits")

--/script id=43769 StartChatInput('['..id..']=true,--'..GetAbilityName(id))

function OTHelper.StaticShield(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, tName, tType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    
    if (hitValue ~= 1 or not OTHelper.savedVariables.trackArchcustodian) then return end

    EVENT_MANAGER:UnregisterForUpdate("STUN_TIMER")

    if OTHelper.leversPulled == 0 then
        OTHelper.archcustodianTimer = OTHelper.ARCHCUSTODIAN_FIRST_COOLDOWN
    elseif OTHelper.leversPulled == 1 then
        OTHelper.archcustodianTimer = OTHelper.ARCHCUSTODIAN_SECOND_COOLDOWN
    elseif OTHelper.leversPulled == 2 then
        OTHelper.archcustodianTimer = OTHelper.ARCHCUSTODIAN_THIRD_COOLDOWN
    else
        OTHelper_Archcustodian_Timer:SetText("")
        OTHelper_Archcustodian:SetHidden(true)
        return
    end

    OTHelper_Archcustodian_Timer:SetText(string.format("%d", OTHelper.archcustodianTimer))
    OTHelper_Archcustodian:SetHidden(false)
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    EVENT_MANAGER:UnregisterForUpdate("STATIC_SHIELD_TIMER")
    EVENT_MANAGER:RegisterForUpdate("STATIC_SHIELD_TIMER", 1000, function()

        OTHelper.archcustodianTimer = OTHelper.archcustodianTimer - 1 

        if OTHelper.archcustodianTimer < 2 then
            EVENT_MANAGER:UnregisterForUpdate("STATIC_SHIELD_TIMER")
            OTHelper_Archcustodian_Timer:SetText("NOW")
            OTHelper.archcustodianTimer = 0
            return
        end
    
        OTHelper_Archcustodian_Timer:SetText(string.format("%d", OTHelper.archcustodianTimer))
    end)

end

function OTHelper.Switch(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, tName, tType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if (hitValue == 0 or not OTHelper.savedVariables.trackArchcustodian) then return end

    EVENT_MANAGER:UnregisterForUpdate("STATIC_SHIELD_TIMER")

    OTHelper.leversPulled = hitValue
    OTHelper.stunTimer = OTHelper.ARCHCUSTODIAN_STUN_COOLDOWN

    OTHelper_Archcustodian_Timer:SetText(string.format("|c3aff00 %.1f |r", OTHelper.stunTimer))
    OTHelper_Archcustodian:SetHidden(false)
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    EVENT_MANAGER:UnregisterForUpdate("STUN_TIMER")
    EVENT_MANAGER:RegisterForUpdate("STUN_TIMER", 100, function()

        OTHelper.stunTimer = OTHelper.stunTimer - 0.1

        if OTHelper.stunTimer < 0 then
            EVENT_MANAGER:UnregisterForUpdate("STUN_TIMER")
            OTHelper.stunTimer = 0
            return
        end
    
        OTHelper_Archcustodian_Timer:SetText(string.format("|c3aff00 %.1f |r", OTHelper.stunTimer))
    end)

end

function OTHelper.RodActivate(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    
    if ( result ~= ACTION_RESULT_EFFECT_GAINED or not OTHelper.savedVariables.trackRod or not OTHelper.pinnacleFactotum ) then return end

    OTHelper.rodTimer = OTHelper.ROD_COOLDOWN

    OTHelperTLW_RodTimer:SetText(string.format("%d", OTHelper.rodTimer))
    OTHelperTLW:SetHidden(false)
    OTHelperTLW_RodFrame:SetHidden(false)
    OTHelperTLW_RodTimer:SetHidden(false)
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    EVENT_MANAGER:UnregisterForUpdate("ROD_ACTIVATED")
    EVENT_MANAGER:RegisterForUpdate("ROD_ACTIVATED", OTHelper.ROD_UPDATE_RATE, OTHelper.RodTimerTick)

end

function OTHelper.CenturionSpinnerAwaken(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    
    if ( result ~= ACTION_RESULT_EFFECT_GAINED or not OTHelper.savedVariables.trackSpinnerSpawn or not OTHelper.pinnacleFactotum ) then return end

    OTHelper_Notification:SetHidden(false)
    OTHelper_Notification_Label:SetText("SPINNER IS SPAWNING!")
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    zo_callLater(function() OTHelper_Notification:SetHidden(true); OTHelper_Notification_Label:SetText("") end, 2000)

end

function OTHelper.Meteors(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    
    if ( result ~= ACTION_RESULT_EFFECT_GAINED or not OTHelper.savedVariables.trackMeteors or not OTHelper.pinnacleFactotum ) then return end

    OTHelper.meteorsTimer = OTHelper.METEORS_COOLDOWN

    OTHelperTLW_MeteorTimer:SetText(string.format("%d", OTHelper.meteorsTimer))
    OTHelperTLW:SetHidden(false)
    OTHelperTLW_MeteorIcon:SetHidden(false)
    OTHelperTLW_MeteorTimer:SetHidden(false)
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    EVENT_MANAGER:UnregisterForUpdate("METEORS_")
    EVENT_MANAGER:RegisterForUpdate("METEORS_", 1000, function()

        OTHelper.meteorsTimer = OTHelper.meteorsTimer - 1 

        if OTHelper.meteorsTimer < 0 then
            EVENT_MANAGER:UnregisterForUpdate("METEORS_")
            OTHelper.meteorsTimer = 0
            OTHelperTLW_MeteorIcon:SetHidden(true)
            OTHelperTLW_MeteorTimer:SetHidden(true)
            OTHelperTLW_MeteorTimer:SetText("")
            return
        end
    
        OTHelperTLW_MeteorTimer:SetText(string.format("%d", OTHelper.meteorsTimer))
    end)

end

function OTHelper.ChanneledLightning(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if not OTHelper.savedVariables.trackChanneledLightning then return end

    if ( result == ACTION_RESULT_BEGIN or targetType ~= COMBAT_UNIT_TYPE_PLAYER ) then

        OTHelper.clTimer = OTHelper.CL_DUTATION

        OTHelper_Notification:SetHidden(false)
        OTHelper_Notification_CL:SetText(string.format("|cA500FE DON'T INTERRUPT |r |c3aff00 %.1f |r", OTHelper.clTimer))
        PlaySound(SOUNDS.SKILL_LINE_ADDED)

        EVENT_MANAGER:UnregisterForUpdate("CHANNELED_LIGHTNING_TIMER")
        EVENT_MANAGER:RegisterForUpdate("CHANNELED_LIGHTNING_TIMER", 100, function()
    
            OTHelper.clTimer = OTHelper.clTimer - 0.1
    
            if OTHelper.clTimer < 0 then
                OTHelper_Notification_CL:SetText("")
                EVENT_MANAGER:UnregisterForUpdate("CHANNELED_LIGHTNING_TIMER")
                OTHelper.clTimer = 0
                return
            end
            OTHelper_Notification_CL:SetText(string.format("|cA500FE DON'T INTERRUPT |r |c3aff00 %.1f |r", OTHelper.clTimer))
        end)

    elseif result == ACTION_RESULT_EFFECT_FADED then

        OTHelper_Notification_CL:SetText("");
        EVENT_MANAGER:UnregisterForUpdate("CHANNELED_LIGHTNING_TIMER")

    end
end

function OTHelper.CenturionHeavyAttack(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if ( result ~= ACTION_RESULT_BEGIN or targetType ~= COMBAT_UNIT_TYPE_PLAYER or not OTHelper.savedVariables.trackCenturionHA ) then return end

    OTHelper_Notification:SetHidden(false)
    OTHelper_Notification_HA:SetText("|cFF4500Block!|r Heavy Attack")
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    zo_callLater(function() OTHelper_Notification_HA:SetText(""); end, 3000)

end

function OTHelper.ReducerFireWhirl(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if ( result ~= ACTION_RESULT_BEGIN or not OTHelper.savedVariables.trackReducerFire ) then return end

    OTHelper_Notification:SetHidden(false)
    OTHelper_Notification_Label:SetText("|cFF4500Block!|r Fire Inc")
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    zo_callLater(function() OTHelper_Notification_Label:SetText(""); end, 3000)

end

function OTHelper.CenturionAwaken(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    
    if ( result ~= ACTION_RESULT_EFFECT_GAINED or not OTHelper.savedVariables.trackCenturionSpawn or not OTHelper.pinnacleFactotum ) then return end

    OTHelper.centurionTimer = OTHelper.CENTURION_COOLDOWN

    OTHelperTLW_CenturionTimer:SetText(string.format("%d", OTHelper.centurionTimer))
    OTHelperTLW:SetHidden(false);
    OTHelperTLW_CenturionFrame:SetHidden(false)
    OTHelperTLW_CenturionTimer:SetHidden(false)
    PlaySound(SOUNDS.SKILL_LINE_ADDED)

    EVENT_MANAGER:UnregisterForUpdate("CENTURION_AWAKEN")
    EVENT_MANAGER:RegisterForUpdate("CENTURION_AWAKEN", OTHelper.CENTURION_UPDATE_RATE, OTHelper.CenturionTimerTick)

    --[[
    d(
        string.format("---\nresult: %s \t abilityId: %s \t abilityName: %s \t time: %s\n ------", result, abilityId, GetAbilityName(abilityId), GetGameTimeMilliseconds()/1000)
    )


    d(
        string.format("---\nresult: %s \t abilityName: %s \t abilityGraphic: %s \t abilityActionSlotType: %s \t sourceName: %s \t sourceType: %s \t targetName: %s \t targetType: %s \t hitValue: %s \t powerType: %s \t damageType: %s \t log: %s \t sourceUnitId: %s \t targetUnitId: %s \t abilityId: %s \n -------",
        result, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, tostring(log), sourceUnitId, targetUnitId, abilityId)
    )
]]
end

function OTHelper.CenturionTimerTick()

	OTHelper.centurionTimer = OTHelper.centurionTimer - 1

	if OTHelper.centurionTimer < 0 then
        EVENT_MANAGER:UnregisterForUpdate("CENTURION_AWAKEN")
        OTHelperTLW_CenturionFrame:SetHidden(true)
        OTHelperTLW_CenturionTimer:SetHidden(true)
        OTHelperTLW_CenturionTimer:SetText("")
        OTHelper.centurionTimer = 0
        return
	end

	OTHelperTLW_CenturionTimer:SetText(string.format("%d", OTHelper.centurionTimer))
end

function OTHelper.RodTimerTick()

	OTHelper.rodTimer = OTHelper.rodTimer - 1

	if OTHelper.rodTimer < 0 then
		EVENT_MANAGER:UnregisterForUpdate("ROD_ACTIVATED")
        OTHelper.rodTimer = 0
        OTHelperTLW_RodFrame:SetHidden(true)
        OTHelperTLW_RodTimer:SetHidden(true)
        OTHelperTLW_RodTimer:SetText("")
        OTHelperTLW_RodFrame:SetColor(1,1,1,1)
        return
    end

    if OTHelper.rodTimer == 10 then
        OTHelperTLW_RodFrame:SetColor(0.66, 0.09, 0.09, 1)
    end

	OTHelperTLW_RodTimer:SetText(string.format("%d", OTHelper.rodTimer))
end

function OTHelper.PlayerCombatState( )
	if ( IsUnitInCombat("player") ) then
        
        if string.find(string.lower(GetUnitName("boss1")), "pinnacle factotum") then

            OTHelper.pinnacleFactotum = true;
            OTHelper.centurionTimer = OTHelper.CENTURION_FIRST_COOLDOWN

            OTHelperTLW_CenturionTimer:SetText(string.format("%d", OTHelper.centurionTimer))
            OTHelperTLW_CenturionFrame:SetHidden(false)
            OTHelperTLW_CenturionTimer:SetHidden(false)
            OTHelperTLW:SetHidden(false);
            PlaySound(SOUNDS.SKILL_LINE_ADDED)

            EVENT_MANAGER:UnregisterForUpdate("CENTURION_AWAKEN")
            EVENT_MANAGER:RegisterForUpdate("CENTURION_AWAKEN", OTHelper.CENTURION_UPDATE_RATE, OTHelper.CenturionTimerTick)

        elseif string.find(string.lower(GetUnitName("boss1")), "archcustodian") then
            OTHelper.archcustodian = true;
        end


	else
		-- Avoid false positives of combat end, often caused by combat rezzes
        zo_callLater(
            function() 
                if (not IsUnitInCombat("player")) then 
                    OTHelperTLW:SetHidden(true)
                    OTHelperTLW_RodFrame:SetHidden(true)
                    OTHelperTLW_RodTimer:SetHidden(true)
                    OTHelperTLW_CenturionFrame:SetHidden(true)
                    OTHelperTLW_CenturionTimer:SetHidden(true)
                    OTHelperTLW_MeteorIcon:SetHidden(true)
                    OTHelperTLW_MeteorTimer:SetHidden(true)
                    OTHelper.rodTimer = 0
                    OTHelper.centurionTimer = 0
                    OTHelper.meteorsTimer = 0
                    OTHelperTLW_RodTimer:SetText("")
                    OTHelperTLW_CenturionTimer:SetText("")
                    OTHelperTLW_MeteorTimer:SetText("")
                    OTHelperTLW_RodFrame:SetColor(1,1,1,1)

                    OTHelper.pinnacleFactotum = false
                    OTHelper.archcustodian = false
                    OTHelper.leversPulled = 0
                    OTHelper_Archcustodian:SetHidden(true)
                end 
            end
        , 3000)
	end
end

------------------------------------------------------------------------------------
---------------------------------- ADDON STARTUP -----------------------------------
------------------------------------------------------------------------------------

function OTHelper.unlockUI()

	OTHelperTLW:SetHidden(false)
    OTHelperTLW_RodFrame:SetHidden(false)
    OTHelperTLW_RodTimer:SetHidden(false)
    OTHelperTLW_RodTimer:SetText("70")
    OTHelperTLW_CenturionFrame:SetHidden(false)
    OTHelperTLW_CenturionTimer:SetHidden(false)
    OTHelperTLW_CenturionTimer:SetText("60")
    OTHelperTLW_MeteorIcon:SetHidden(false)
    OTHelperTLW_MeteorTimer:SetHidden(false)
    OTHelperTLW_MeteorTimer:SetText("9")
    OTHelper_Notification:SetHidden(false)
    OTHelper_Notification_Label:SetText("Spinner is spawning!")
    OTHelper_Notification_CL:SetText("|cA500FE DON'T INTERRUPT |r |c3aff00 2.7 |r")
    OTHelper_Notification_HA:SetText("|cFF4500Block!|r Heavy Attack")
    OTHelper_Archcustodian:SetHidden(false)
    OTHelper_Archcustodian_Timer:SetText("12.5")

end

function OTHelper.lockUI()

	OTHelperTLW:SetHidden(true)
    OTHelperTLW_RodFrame:SetHidden(true)
    OTHelperTLW_RodTimer:SetHidden(true)
    OTHelperTLW_RodTimer:SetText("")
    OTHelperTLW_CenturionFrame:SetHidden(true)
    OTHelperTLW_CenturionTimer:SetHidden(true)
    OTHelperTLW_CenturionTimer:SetText("")
    OTHelperTLW_MeteorIcon:SetHidden(true)
    OTHelperTLW_MeteorTimer:SetHidden(true)
    OTHelperTLW_MeteorTimer:SetText("")
    OTHelper_Notification:SetHidden(true)
    OTHelper_Notification_Label:SetText("")
    OTHelper_Notification_CL:SetText("")
    OTHelper_Notification_HA:SetText("")
    OTHelper_Archcustodian:SetHidden(true)
    OTHelper_Archcustodian_Timer:SetText("")

end

function OTHelper.OnArchcustodianTimerMove()
    OTHelper.savedVariables.OTHelperArchcustodianLeft = OTHelper_Archcustodian:GetLeft()
    OTHelper.savedVariables.OTHelperArchcustodianTop = OTHelper_Archcustodian:GetTop()
end

function OTHelper.OnNotificationMove()
    OTHelper.savedVariables.NotificationLeft = OTHelper_Notification:GetLeft()
    OTHelper.savedVariables.NotificationTop = OTHelper_Notification:GetTop()
end

function OTHelper.OnOTHelperTLWMove()
    OTHelper.savedVariables.OTHelperTLWLeft = OTHelperTLW:GetLeft()
    OTHelper.savedVariables.OTHelperTLWTop = OTHelperTLW:GetTop()
end

-- Gets the saved positions and applies them
function OTHelper.LoadSettings()

    OTHelperTLW:ClearAnchors()
    OTHelperTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OTHelper.savedVariables.OTHelperTLWLeft, OTHelper.savedVariables.OTHelperTLWTop)

    OTHelper_Notification:ClearAnchors()
    OTHelper_Notification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OTHelper.savedVariables.NotificationLeft, OTHelper.savedVariables.NotificationTop)

    OTHelper_Archcustodian:ClearAnchors()
    OTHelper_Archcustodian:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OTHelper.savedVariables.OTHelperArchcustodianLeft, OTHelper.savedVariables.OTHelperArchcustodianTop)

end

OTHelper.Activated = function(e)

    if (GetZoneId(GetUnitZoneIndex("player")) == OTHelper.trialZoneId and not OTHelper.active) then

        OTHelper.active = true
        OTHelper.LoadSettings()   

        EVENT_MANAGER:RegisterForEvent("CENTURION_AWAKEN", EVENT_COMBAT_EVENT, OTHelper.CenturionAwaken)
        EVENT_MANAGER:AddFilterForEvent("CENTURION_AWAKEN", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 90887)

        EVENT_MANAGER:RegisterForEvent("CENTURION_SPINNER_AWAKEN", EVENT_COMBAT_EVENT, OTHelper.CenturionSpinnerAwaken)
        EVENT_MANAGER:AddFilterForEvent("CENTURION_SPINNER_AWAKEN", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94780) 

        EVENT_MANAGER:RegisterForEvent("ROD_ACTIVATE", EVENT_COMBAT_EVENT, OTHelper.RodActivate)
        EVENT_MANAGER:AddFilterForEvent("ROD_ACTIVATE", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 91000)

        EVENT_MANAGER:RegisterForEvent("METEORS", EVENT_COMBAT_EVENT, OTHelper.Meteors)
        EVENT_MANAGER:AddFilterForEvent("METEORS", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 90951)

        EVENT_MANAGER:RegisterForEvent("CHANNELED_LIGHTNING", EVENT_COMBAT_EVENT, OTHelper.ChanneledLightning)
        EVENT_MANAGER:AddFilterForEvent("CHANNELED_LIGHTNING", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 90876)

        EVENT_MANAGER:RegisterForEvent("CENTURION_HEAVY_ATTACK", EVENT_COMBAT_EVENT, OTHelper.CenturionHeavyAttack)
        EVENT_MANAGER:AddFilterForEvent("CENTURION_HEAVY_ATTACK", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 90889)

        -- 3rd boss
        EVENT_MANAGER:RegisterForEvent("STATIC_SHIELD", EVENT_COMBAT_EVENT, OTHelper.StaticShield)
        EVENT_MANAGER:AddFilterForEvent("STATIC_SHIELD", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94867) --94805

        EVENT_MANAGER:RegisterForEvent("SWITCH", EVENT_COMBAT_EVENT, OTHelper.Switch )
        EVENT_MANAGER:AddFilterForEvent("SWITCH", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 94341)
        --

        -- 4th boss
        EVENT_MANAGER:RegisterForEvent("REDUCER_FIRE_WHIRL", EVENT_COMBAT_EVENT, OTHelper.ReducerFireWhirl)
        EVENT_MANAGER:AddFilterForEvent("REDUCER_FIRE_WHIRL", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 90293)
        --

        EVENT_MANAGER:RegisterForEvent("IN_COMBAT", EVENT_PLAYER_COMBAT_STATE, OTHelper.PlayerCombatState )

    else

        if(OTHelper.active) then

            OTHelper.active = false

            EVENT_MANAGER:UnregisterForEvent("CENTURION_AWAKEN")
            EVENT_MANAGER:UnregisterForEvent("CENTURION_SPINNER_AWAKEN")
            EVENT_MANAGER:UnregisterForEvent("ROD_ACTIVATE")
            EVENT_MANAGER:UnregisterForEvent("METEORS")
            EVENT_MANAGER:UnregisterForEvent("STATIC_SHIELD")
            EVENT_MANAGER:UnregisterForEvent("SWITCH")
            EVENT_MANAGER:UnregisterForEvent("IN_COMBAT")

            OTHelperTLW:SetHidden(true);
            OTHelper_Notification:SetHidden(true)

        end

    end

end
-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(OTHelper.name, EVENT_PLAYER_ACTIVATED, OTHelper.Activated)


OTHelper.OnAddOnLoaded = function(event, addonName)

    if addonName ~= OTHelper.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(OTHelper.name, EVENT_ADD_ON_LOADED)
    
    -- Getting addon variables from savedVariables file, if it doesn't exist or version is different then create a new file.
    OTHelper.savedVariables = ZO_SavedVars:New("OTHelperSavedVariables", 3, nil, OTHelper.defaultSettings)
    
    OTHelper.buildMenu()

    SLASH_COMMAND_AUTO_COMPLETE:InvalidateSlashCommandCache() -- Reset autocomplete cache to update it.
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(OTHelper.name, EVENT_ADD_ON_LOADED, OTHelper.OnAddOnLoaded)
