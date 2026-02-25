local _, UUF = ...

function UUF:CreatePositionController()
    local ECDM = _G["EssentialCooldownViewer"]
    if not ECDM then
        UUF:PrettyPrint("|cFFFFCC00Essential Cooldown Viewer|r was not found.")
        return
    end

    local CDMAnchor = _G["UUF_CDMAnchor"] or CreateFrame("Frame", "UUF_CDMAnchor", UIParent)
    CDMAnchor:ClearAllPoints()
    CDMAnchor:SetAllPoints(ECDM)
    CDMAnchor:SetSize(ECDM:GetWidth() or 300, ECDM:GetHeight() or 48)
    CDMAnchor:SetShown(ECDM:IsShown())

    local function RefreshAnchoredFrames()
        CDMAnchor:ClearAllPoints()
        CDMAnchor:SetAllPoints(ECDM)
        CDMAnchor:SetSize(ECDM:GetWidth() or 300, ECDM:GetHeight() or 48)
        CDMAnchor:SetShown(ECDM:IsShown())
        if UUF.PLAYER then UUF:UpdateUnitFrame(UUF.PLAYER, "player") end
        if UUF.TARGET then UUF:UpdateUnitFrame(UUF.TARGET, "target") end
    end

    if not ECDM.UUFHooksRegistered then
        ECDM:HookScript("OnSizeChanged", RefreshAnchoredFrames)
        ECDM:HookScript("OnShow", RefreshAnchoredFrames)
        ECDM:HookScript("OnHide", RefreshAnchoredFrames)
        ECDM.UUFHooksRegistered = true
    end
end

function UUF:IsCDMAnchorActive()
    local ECDM = _G["EssentialCooldownViewer"]
    local CDMAnchor = _G["UUF_CDMAnchor"]
    return  ECDM and ECDM:IsShown() and CDMAnchor and CDMAnchor:IsShown()
end
