local _, UUF = ...
local oUF = UUF.oUF

local function ApplyScripts(unitFrame)
    unitFrame:RegisterForClicks("AnyUp")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "togglemenu")
    unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
    unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
end

function UUF:CreateUnitFrame(unitFrame, unit)
    if not unit or not unitFrame then return end
    UUF:CreateUnitContainer(unitFrame, unit)
    if unit ~= "targettarget" and unit ~= "focustarget" then UUF:CreateUnitCastBar(unitFrame, unit) end
    UUF:CreateUnitHealthBar(unitFrame, unit)
    if unit == "player" or unit == "target" or unit == "focus" then UUF:CreateUnitDispelHighlight(unitFrame, unit) end
    UUF:CreateUnitHealPrediction(unitFrame, unit)
    if unit ~= "targettarget" and unit ~= "focustarget" then UUF:CreateUnitPortrait(unitFrame, unit) end
    UUF:CreateUnitPowerBar(unitFrame, unit)
    if unit == "player" then UUF:CreateUnitAlternativePowerBar(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:CreateUnitRaidTargetMarker(unitFrame, unit)
    if unit == "player" or unit == "target" then UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if unit == "player" or unit == "target" then UUF:CreateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:CreateUnitRestingIndicator(unitFrame, unit) end
    -- if unit == "player" then UUF:CreateUnitTotems(unitFrame, unit) end
    UUF:CreateUnitMouseoverIndicator(unitFrame, unit)
    UUF:CreateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:CreateUnitAuras(unitFrame, unit)
    UUF:CreateUnitTags(unitFrame, unit)
    ApplyScripts(unitFrame)
    return unitFrame
end

function UUF:LayoutBossFrames()
    local Frame = UUF.db.profile.Units.boss.Frame
    if #UUF.BOSS_FRAMES == 0 then return end
    local bossFrames = UUF.BOSS_FRAMES
    if Frame.GrowthDirection == "UP" then
        bossFrames = {}
        for i = #UUF.BOSS_FRAMES, 1, -1 do bossFrames[#bossFrames+1] = UUF.BOSS_FRAMES[i] end
    end
    local layoutConfig = UUF.LayoutConfig[Frame.Layout[1]]
    local frameHeight = bossFrames[1]:GetHeight()
    local containerHeight = (frameHeight + Frame.Layout[5]) * #bossFrames - Frame.Layout[5]
    local offsetY = containerHeight * layoutConfig.offsetMultiplier
    if layoutConfig.isCenter then offsetY = offsetY - (frameHeight / 2) end
    local initialAnchor = AnchorUtil.CreateAnchor(layoutConfig.anchor, UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4] + offsetY)
    AnchorUtil.VerticalLayout(bossFrames, initialAnchor, Frame.Layout[5])
end

function UUF:SpawnUnitFrame(unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if not UnitDB or not UnitDB.Enabled then
        if UnitDB and UnitDB.ForceHideBlizzard then oUF:DisableBlizzard(unit) end
        return
    end
    local FrameDB = UnitDB.Frame

    oUF:RegisterStyle(UUF:FetchFrameName(unit), function(unitFrame) UUF:CreateUnitFrame(unitFrame, unit) end)
    oUF:SetActiveStyle(UUF:FetchFrameName(unit))

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            UUF[unit:upper() .. i] = oUF:Spawn(unit .. i, UUF:FetchFrameName(unit .. i))
            UUF[unit:upper() .. i]:SetSize(FrameDB.Width, FrameDB.Height)
            UUF.BOSS_FRAMES[i] = UUF[unit:upper() .. i]
            UUF[unit:upper() .. i]:SetFrameStrata(FrameDB.FrameStrata)
            UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit .. i), unit .. i)
            UUF:RegisterRangeFrame(UUF:FetchFrameName(unit .. i), unit .. i)
        end
        UUF:LayoutBossFrames()
    else
        UUF[unit:upper()] = oUF:Spawn(unit, UUF:FetchFrameName(unit))
        UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName(unit), unit)
        UUF[unit:upper()]:SetFrameStrata(FrameDB.FrameStrata)
        if unit == "player" or unit == "target" or unit == "focus" then UUF:RegisterDispelHighlightEvents(UUF[unit:upper()], unit) end
    end

    if unit == "player" or unit == "target" then
        local parentFrame = UUF.db.profile.Units[unit].HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        local parentFrame = _G[UUF.db.profile.Units[unit].Frame.AnchorParent] or UIParent
        UUF[unit:upper()]:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        UUF[unit:upper()]:SetSize(FrameDB.Width, FrameDB.Height)
    end
    if unit ~= "player" then UUF:RegisterRangeFrame(UUF:FetchFrameName(unit), unit) end

    if UnitDB.Enabled then
        RegisterUnitWatch(UUF[unit:upper()])
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UUF[unit:upper() .. i]:Show()
            end
        else
            UUF[unit:upper()]:Show()
        end
    else
        UnregisterUnitWatch(UUF[unit:upper()])
        if unit == "boss" then
            for i = 1, UUF.MAX_BOSS_FRAMES do
                UUF[unit:upper() .. i]:Hide()
            end
        else
            UUF[unit:upper()]:Hide()
        end
    end

    return UUF[unit:upper()]
end

function UUF:UpdateUnitFrame(unitFrame, unit)
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if unit ~= "targettarget" and unit ~= "focustarget" then UUF:UpdateUnitCastBar(unitFrame, unit) end
    UUF:UpdateUnitHealthBar(unitFrame, unit)
    UUF:UpdateUnitHealPrediction(unitFrame, unit)
    UUF:UpdateUnitPortrait(unitFrame, unit)
    UUF:UpdateUnitPowerBar(unitFrame, unit)
    if unit == "player" then UUF:UpdateUnitAlternativePowerBar(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitSecondaryPowerBar(unitFrame, unit) end
    UUF:UpdateUnitRaidTargetMarker(unitFrame, unit)
    if unit == "player" or unit == "target" then UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit) end
    if unit == "player" or unit == "target" then UUF:UpdateUnitCombatIndicator(unitFrame, unit) end
    if unit == "player" then UUF:UpdateUnitRestingIndicator(unitFrame, unit) end
    -- if unit == "player" then UUF:UpdateUnitTotems(unitFrame, unit) end
    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
    UUF:UpdateUnitTargetGlowIndicator(unitFrame, unit)
    UUF:UpdateUnitAuras(unitFrame, unit)
    UUF:UpdateUnitTags()
    unitFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
end

function UUF:UpdateBossFrames()
    for i in pairs(UUF.BOSS_FRAMES) do
        UUF:UpdateUnitFrame(UUF["BOSS"..i], "boss"..i)
    end
    UUF:CreateTestBossFrames()
    UUF:LayoutBossFrames()
end


function UUF:UpdateAllUnitFrames()
    for unit, _ in pairs(UUF.db.profile.Units) do
        if UUF[unit:upper()] then
            UUF:UpdateUnitFrame(UUF[unit:upper()], unit)
        end
    end
end

function UUF:ToggleUnitFrameVisibility(unit)
    if not unit then return end
    local UnitKey = unit:upper()
    local UnitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
    if not UnitDB then return end
    if UnitDB.Enabled then
        if unit == "boss" then
            if not UUF["BOSS1"] then UUF:SpawnUnitFrame(unit) end
        elseif not UUF[UnitKey] then
            UUF:SpawnUnitFrame(unit)
        end
    elseif UnitDB.ForceHideBlizzard then
        oUF:DisableBlizzard(unit)
    end

    if unit == "boss" then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local unitFrame = UUF["BOSS"..i]
            if unitFrame then (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame) unitFrame:SetShown(UnitDB.Enabled) end
        end
        return
    end

    local unitFrame = UUF[UnitKey]
    if not unitFrame then return end
    (UnitDB.Enabled and RegisterUnitWatch or UnregisterUnitWatch)(unitFrame)
    unitFrame:SetShown(UnitDB.Enabled)
end

local function CanForceFrameVisible(unit)
    if unit ~= "player" and unit ~= "target" then return true end
    local UnitDB = UUF.db and UUF.db.profile and UUF.db.profile.Units and UUF.db.profile.Units[unit]
    if not UnitDB or not UnitDB.HealthBar or not UnitDB.HealthBar.AnchorToCooldownViewer then return true end
    -- If the external cooldown viewer intentionally hides while mounted, avoid forcing player/target visible.
    return not IsMounted()
end

local function ReanchorUnitFrame(unit)
    local unitFrame = UUF[unit:upper()]
    local UnitDB = UUF.db.profile.Units[unit]
    if not unitFrame or not UnitDB then return end

    if unit == "player" or unit == "target" then
        if UnitDB.HealthBar.AnchorToCooldownViewer and not _G["UUF_CDMAnchor"] and _G["EssentialCooldownViewer"] then
            UUF:CreatePositionController()
        end
    end

    local FrameDB = UnitDB.Frame
    local parentFrame

    if unit == "player" or unit == "target" then
        parentFrame = UnitDB.HealthBar.AnchorToCooldownViewer and _G["UUF_CDMAnchor"] or UIParent
    elseif unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet" then
        parentFrame = _G[FrameDB.AnchorParent] or UIParent
    end

    if parentFrame then
        unitFrame:ClearAllPoints()
        unitFrame:SetPoint(FrameDB.Layout[1], parentFrame, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
        unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
    end
end

function UUF:RevalidateUnitFrameVisibility()
    if not UUF.db or not UUF.db.profile or not UUF.db.profile.Units then return end
    if InCombatLockdown() then
        UUF._deferredVisibilityRecovery = true
        return
    end

    local function refreshUnit(unit)
        local UnitDB = UUF.db.profile.Units[unit]
        local unitFrame = UUF[unit:upper()]
        if not UnitDB or not unitFrame then return end

        if UnitDB.Enabled then
            ReanchorUnitFrame(unit)
            RegisterUnitWatch(unitFrame)
            if UnitExists(unitFrame.unit) and not unitFrame:IsShown() and CanForceFrameVisible(unit) then
                unitFrame:Show()
            end
        else
            UnregisterUnitWatch(unitFrame)
            unitFrame:Hide()
        end
    end

    refreshUnit("player")
    refreshUnit("target")
    refreshUnit("targettarget")
    refreshUnit("focus")
    refreshUnit("focustarget")
    refreshUnit("pet")

    local bossDB = UUF.db.profile.Units.boss
    if bossDB and bossDB.Enabled then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local bossFrame = UUF["BOSS" .. i]
            if bossFrame then
                RegisterUnitWatch(bossFrame)
                if UnitExists(bossFrame.unit) and not bossFrame:IsShown() then
                    bossFrame:Show()
                end
            end
        end
    elseif bossDB then
        for i = 1, UUF.MAX_BOSS_FRAMES do
            local bossFrame = UUF["BOSS" .. i]
            if bossFrame then
                UnregisterUnitWatch(bossFrame)
                bossFrame:Hide()
            end
        end
    end
end

function UUF:InitializeUnitFrameRecovery()
    if UUF._unitFrameRecoveryHandler then return end

    local recoveryHandler = CreateFrame("Frame")
    recoveryHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
    recoveryHandler:RegisterEvent("UNIT_ENTERED_VEHICLE")
    recoveryHandler:RegisterEvent("UNIT_EXITED_VEHICLE")
    recoveryHandler:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    recoveryHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
    recoveryHandler:SetScript("OnEvent", function(_, event, unit)
        if (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and unit ~= "player" then return end

        if event == "PLAYER_REGEN_ENABLED" then
            if not UUF._deferredVisibilityRecovery then return end
            UUF._deferredVisibilityRecovery = nil
        end

        UUF:RevalidateUnitFrameVisibility()
        C_Timer.After(0.2, function()
            UUF:RevalidateUnitFrameVisibility()
        end)
    end)

    UUF._unitFrameRecoveryHandler = recoveryHandler
end
