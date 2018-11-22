OTHelperMenu = {}

OTHelper.buildMenu = function()
	local LAM = LibStub('LibAddonMenu-2.0')
    local settings = ZO_DeepTableCopy(OTHelper.savedVariables, settings)

    local selectedEffectToRemove

    -- Wraps text with a color.
    local function Colorize(text, color)
        -- Default to addon's .color.
        if not color then color = OTHelper.color end

        text = "|c" .. color .. text .. "|c"
    end

    -- Settings menu.
    local panelData = {
        type = "panel",
        name = OTHelper.menuName,
        displayName = Colorize(OTHelper.menuName),
        author = Colorize(OTHelper.author, "AAF0BB"),
        version = Colorize(OTHelper.version, "AA00FF"),
        slashCommand = "/OTHelper",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(OTHelper.menuName, panelData)

    local optionsTable = {
        {
            type = "header",
            name = "vHoF - 2nd Boss",
            width = "full",
        },
        {
            type = "checkbox",
            name = 'Track Centurion Spawns',
            getFunc = function() return settings.trackCenturionSpawn end,
            setFunc = function(value) 
                OTHelperTLW_CenturionFrame:SetHidden(not value)
                OTHelperTLW_CenturionTimer:SetHidden(not value)
                OTHelperTLW:SetHidden(not value and not OTHelper.savedVariables.trackRod and not OTHelper.savedVariables.trackMeteors);
                OTHelper.savedVariables.trackCenturionSpawn = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Track Planar Rift Duration',
            getFunc = function() return settings.trackRod end,
            setFunc = function(value)
                OTHelper.savedVariables.trackRod = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Notify when Spinner spawns',
            getFunc = function() return settings.trackSpinnerSpawn end,
            setFunc = function(value)
                OTHelper.savedVariables.trackSpinnerSpawn = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Track Meteors ( Unstable Energy )',
            getFunc = function() return settings.trackMeteors end,
            setFunc = function(value)
                OTHelper.savedVariables.trackMeteors = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Track Archcustodian Cooldowns',
            getFunc = function() return settings.trackArchcustodian end,
            setFunc = function(value)
                OTHelper.savedVariables.trackArchcustodian = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Track Centurion Heavy Attack (2nd Boss)',
            getFunc = function() return settings.trackCenturionHA end,
            setFunc = function(value)
                OTHelper.savedVariables.trackCenturionHA = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Track Channeled Lightning (2nd Boss) ',
            getFunc = function() return settings.trackChanneledLightning end,
            setFunc = function(value)
                OTHelper.savedVariables.trackChanneledLightning = value
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = 'Track Reducer Fire Whirl',
            getFunc = function() return settings.trackReducerFire end,
            setFunc = function(value)
                OTHelper.savedVariables.trackReducerFire = value
            end,
            width = "half",
        },
        {
            type = "header",
            name = "Positioning"
        },
        {
            type = "checkbox",
            name = "UI Locked",
            tooltip = "Allows to reposition the frames",
            getFunc = function() return false end,
            setFunc = function(value)
                if value then
                    OTHelper.unlockUI()
                else
                    OTHelper.lockUI()
                end
            end
        },
    }

    LAM:RegisterOptionControls(OTHelper.menuName, optionsTable)

end