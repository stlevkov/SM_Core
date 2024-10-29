print("|cff00ccffStats Monitor by Lqlqdum|r loaded! Current version |cff00ccff0.3|r");
print("|cff00ccffType /togglestats to show/hide the stats monitor|r");

-- (1)
local f = CreateFrame("Frame", "WindowFrame", UIParent)
f:SetSize(150, 130)
f:SetPoint("CENTER")

-- (2)
f:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
})
f:SetBackdropColor(0, 0, 0, .5)
f:SetBackdropBorderColor(0, 0, 0)

-- (3)
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:SetScript("OnHide", f.StopMovingOrSizing)

-- (4)

local close = CreateFrame("Button", "YourCloseButtonName", f, "UIPanelCloseButton")
close:SetSize(20, 20)
close:SetPoint("TOPRIGHT", f, "TOPRIGHT")
close:SetScript("OnClick", function()
    f:Hide()
end)

-- (5)
-- Define the function to toggle the frame visibility and manage events
local function ToggleStatsFrame()
    if f:IsShown() then
        f:Hide()
        myFrame:UnregisterEvent("UNIT_AURA")
        myFrame:UnregisterEvent("UNIT_SPELLCAST_SENT")
        myFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    else
        f:Show()
        myFrame:RegisterEvent("UNIT_AURA")
        myFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
        myFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end
end

-- Register the slash command
SLASH_TOGGLESTATS1 = "/togglestats"
SlashCmdList["TOGGLESTATS"] = ToggleStatsFrame

-- (6)
local addonText = f:CreateFontString(nil, "addonText", "GameFontDisable")
addonText:SetPoint("TOP", -10, -3)
addonText:SetText(" cast any spell");

-- (7)
local armorText = f:CreateFontString(nil, "armor", "GameFontGreenLarge")
armorText:SetPoint("LEFT", 0, 30)
armorText:SetJustifyH("LEFT")
armorText:SetJustifyV("TOP")

local physDmgText = f:CreateFontString(nil, "physDmg", "GameFontGreenLarge")
physDmgText:SetPoint("LEFT", 0, 10)
physDmgText:SetJustifyH("LEFT")
physDmgText:SetJustifyV("TOP")

local dodgeText = f:CreateFontString(nil, "dodge", "GameFontGreenLarge")
dodgeText:SetPoint("LEFT", 0, -10)
dodgeText:SetJustifyH("LEFT")
dodgeText:SetJustifyV("TOP")

local parryText = f:CreateFontString(nil, "parry", "GameFontGreenLarge")
parryText:SetPoint("LEFT", 0, -30);
parryText:SetJustifyH("LEFT")
parryText:SetJustifyV("TOP")

local blockText = f:CreateFontString(nil, "block", "GameFontGreenLarge")
blockText:SetPoint("LEFT", 0, -50);
blockText:SetJustifyH("LEFT")
blockText:SetJustifyV("TOP")

local myFrame = CreateFrame("Frame");
local myCurrentCast;
local warningSent
warningSent = false

local myFrame = CreateFrame("Frame");
local warningSent = false

-- Register only relevant events
myFrame:RegisterEvent("UNIT_AURA")
myFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
myFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

-- Event handler function
myFrame:SetScript("OnEvent", function(self, event, arg1)
    -- Filter only for player actions
    if arg1 == "player" then
        if event == "UNIT_AURA" then
            -- Handle aura updates (buffs/debuffs)
            handlePlayerAura()
        elseif event == "UNIT_SPELLCAST_SENT" then
            -- Handle spell cast started
            handleSpellCastSent()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            -- Handle spell cast succeeded
            handleSpellCastSuccess()
        end
    end
end)

-- Function to handle player auras (buffs/debuffs)
function handlePlayerAura()
    -- Example: Check for a specific buff or effect on the player
    local hasHasteBuff = UnitBuff("player", "Haste Buff") -- Replace with an actual buff name
    if hasHasteBuff then
        print("Player has Haste Buff!")
    else
        print("No Haste Buff active.")
    end
end

-- Function to handle spell cast sent
function handleSpellCastSent()
    print("Spell cast started.")
end

-- Function to handle spell cast success
function handleSpellCastSuccess()
    print("Spell cast successful!")
end

myFrame:SetScript("OnEvent",
    function(self, event, arg1, arg2, arg3, arg4)
        localizedClass, englishClass, classIndex = UnitClass("player")
        --print("Debug: Entering OnEvent function for class: " .. englishClass)
        if englishClass == "MAGE" then
            local classRole = getClassRole()
            if classRole == 2 then
                addonText:SetText(" Fire Mage")
                displayCasters("FIRE")
            end
        elseif englishClass == "PALADIN" then
            local classRole = getClassRole()
            if classRole == 2 then
                addonText:SetText(" Paladin Tank")
                DisplayTank()
            elseif classRole == 3 then
                addonText:SetText(" Paladin Retri")
                displayMDPS()
            end
        elseif englishClass == "DEATHKNIGHT" then
            addonText:SetText(" Death Knight")
            DisplayTank()
        elseif englishClass == "WARRIOR" then
            local classRole = getClassRole()
            if classRole == 2 then
                addonText:SetText(" Warrior Fury")
                displayMDPS()
            elseif classRole == 3 then
                addonText:SetText(" Warrior Tank")
                DisplayTank()
            end
        elseif englishClass == "WARLOCK" then
            local classRole = getClassRole()
            --print("Debug: Entering Warlock classRole: " .. classRole)
            if classRole == 1 then
                addonText:SetText(" Warlock Affli")
                displayCasters("AFFLICTION")
            elseif classRole == 2 then
                addonText:SetText(" Warlock Demo")
                displayCasters("DEMONOLOGY")
            end
        elseif englishClass == "SHAMAN" then
            local classRole = getClassRole()
            if classRole == 1 then
                addonText:SetText(" Shaman Elemental")
                displayCasters("ELEMENTAL")
            elseif classRole == 2 then
                addonText:SetText(" Shaman Enhancement")
                displayMDPS("ENHANCEMENT")
            elseif classRole == 3 then
                addonText:SetText(" Shaman Restoration")
                displayHealers("RESTORATION")
            end
        end
    end
);

function getClassRole()
    local classRole = processClassSpecialization(englishClass)
    if englishClass == "PALADIN" then
        if classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return 3 -- Retribution
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return 2 -- Protection
        else
            return 1 -- Holy
        end
    elseif englishClass == "WARRIOR" then
        if classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return 2 -- Fury
        elseif classRole[3] > classRole[1] and classRole[3] > classRole[2] then
            return 3 -- Protection
        else
            return 1 -- Arms
        end
    else
        -- Existing logic for other classes
        if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
            return 1
        elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
            return 2
        else
            return 3
        end
    end
end

--1 for Physical
--2 for Holy
--3 for Fire
--4 for Nature
--5 for Frost
--6 for Shadow
--7 for Arcane
function displayCasters(talent)
    --print("Debug: Entering displayCasters function for talent: " .. talent)
    local spellDmg = 0
    local critChance = 0
    local haste = GetCombatRating(18)
    critChance = GetRealSpellCrit(3);
    if talent == "FIRE" then
        spellDmg = GetSpellBonusDamage(3);
    elseif talent == "AFFLICTION" then
        spellDmg = GetSpellBonusDamage(6);
    end

    local hitModifier = GetCombatRatingBonus(CR_HIT_SPELL)
    local block = GetBlockChance();

    local max_health = UnitHealthMax("player");
    local health = UnitHealth("player")
    local healthWarningPercentage = 100 - (((max_health - health) / max_health) * 100)

    if (healthWarningPercentage < 25) then
        if (not warningSent) then
            --SendChatMessage("WARNING MAGE HEALTH LOW ".. health.. " !!!", "YELL");
            warningSent = true
        end
    elseif (healthWarningPercentage > 21) then
        warningSent = false --reset
    end

    if (spellDmg > 3000) then
        armorText:SetText("|cff00ccffBonus dmg   |r " .. "|c33fff6ff" .. spellDmg .. "|r")
    else
        armorText:SetText("|cff00ccffBonus dmg   |r " .. spellDmg)
    end
    physDmgText:SetText(string.format("|cff00ccffHit Rate     |r %.2f%%", hitModifier))
    dodgeText:SetText(string.format("|cff00ccffCritical       |r %.2f%%", critChance))
    parryText:SetText(string.format("|cff00ccffHaste  Rate     |r " .. haste))

    --blockText:SetText(string.format("|cff00ccffSpeed    |r %.2f %%", 0))
end

function displayHealers(talent)
    local bonusHeal = GetSpellBonusHealing(3)
    local critChance = GetRealSpellCrit(3);
    local haste = GetCombatRating(18)

    local baseRegen, castingRegen = GetManaRegen(3)
    local block = GetBlockChance();

    local max_health = UnitHealthMax("player");
    local health = UnitHealth("player")
    local healthWarningPercentage = 100 - (((max_health - health) / max_health) * 100)

    if (healthWarningPercentage < 25) then
        if (not warningSent) then
            --SendChatMessage("WARNING MAGE HEALTH LOW ".. health.. " !!!", "YELL");
            warningSent = true
        end
    elseif (healthWarningPercentage > 21) then
        warningSent = false --reset
    end

    if (bonusHeal > 3000) then
        armorText:SetText("|cff00ccffBonus heal  |r " .. "|c33fff6ff" .. bonusHeal .. "|r")
    else
        armorText:SetText("|cff00ccffBonus heal  |r " .. bonusHeal)
    end
    physDmgText:SetText(string.format("|cff00ccffMana reg |r %.2f", baseRegen))
    dodgeText:SetText(string.format("|cff00ccffCritical    |r %.2f %%", critChance))
    parryText:SetText(string.format("|cff00ccffHaste       |r ", haste))

    blockText:SetText(string.format("|cff00ccffSpeed       |r %.2f %%", 0))
end

function displayMDPS()
    -- print("Debug: Entering displayMDPS function")

    local base, posBuff, negBuff = UnitAttackPower("player")
    local attackPower = base + posBuff + negBuff
    local hitRating = GetCombatRating(CR_HIT_MELEE) -- for melee hit rating
    -- local spellHitRating = GetCombatRating(CR_HIT_SPELL) -- for spell hit rating
    -- local rangedHitRating = GetCombatRating(CR_HIT_RANGED) -- for ranged hit rating
    local meleCrit = GetRealMeleeCrit()
    local expertiseRating, expertiseValue = GetRealExpertise()
    -- print("Debug: expertiseRating: " .. expertiseRating .. " expertiseValue: " .. expertiseValue)
    -- Cap: 173 rating for orcs using axes & dwarves using maces, 189 for humans using swords or maces, 214 for others
    local armorPenetrationRating = GetRealArmorPenetration()
    -- print("Debug: armorPenetrationRating: " .. armorPenetrationRating)
    -- Cap: 1400 rating

    local haste = GetCombatRating(18)
    -- print("Current Haste: " .. haste .. "%")

    local max_health = UnitHealthMax("player")
    local health = UnitHealth("player")
    local healthWarningPercentage = 100 - (((max_health - health) / max_health) * 100)

    if healthWarningPercentage < 25 then
        if not warningSent then
            -- SendChatMessage("WARNING HEALTH LOW ".. health.. " !!!", "YELL")
            warningSent = true
        end
    elseif healthWarningPercentage > 21 then
        warningSent = false -- reset
    end
    HasGreatBlessingOfMight()
    armorText:SetText("|cff00ccffAttack Pwr   |r " .. attackPower)
    physDmgText:SetText(string.format("|cff00ccffCrit Rate  |r %.2f %%", meleCrit))
    dodgeText:SetText(("|cff00ccffHaste Rate       |r" .. haste))
    parryText:SetText(string.format("|cff00ccffARP Rate       |r" .. armorPenetrationRating))
    blockText:SetText(string.format("|cff00ccffHit/E  |r %d / %.2f", hitRating, expertiseValue))
    -- print("Debug: Exiting displayMDPS function")
end

function DisplayTank()
    baseArmor, totalArmor, bonusArmor, minusArmor = UnitResistance("player", 0)

    local parry = GetParryChance();
    local dodge = GetDodgeChance();
    local block = GetBlockChance();
    local dmgReduction = ((totalArmor / (totalArmor + 15232.5)) * 100)
    local max_health = UnitHealthMax("player");
    local health = UnitHealth("player")
    local healthWarningPercentage = 100 - (((max_health - health) / max_health) * 100)

    if (healthWarningPercentage < 25) then
        if (not warningSent) then
            SendChatMessage("WARNING TANK HEALTH LOW " .. health .. " !!!", "YELL");
            warningSent = true
        end
    elseif (healthWarningPercentage > 21) then
        warningSent = false --reset
    end

    if (bonusArmor > 3000) then
        armorText:SetText("|cff00ccffArmor  |r " .. "|c33fff6ff" .. totalArmor .. "|r")
    else
        armorText:SetText("|cff00ccffArmor  |r " .. totalArmor)
    end

    physDmgText:SetText(string.format("|cff00ccffReduc  |r %.2f %%", dmgReduction))
    dodgeText:SetText(string.format("|cff00ccffDodge  |r %.2f %%", dodge))
    parryText:SetText(string.format("|cff00ccffParry     |r %.2f %%", parry))
    blockText:SetText(string.format("|cff00ccffBlock    |r %.2f %%", block))
end

function processClassSpecialization()
    --https://wowwiki-archive.fandom.com/wiki/API_GetTalentInfo
    local numTabs = GetNumTalentTabs();
    local talents = { 0, 0, 0 }

    for t = 1, numTabs do
        --DEFAULT_CHAT_FRAME:AddMessage(GetTalentTabInfo(t)..":");
        local numTalents = GetNumTalents(t);
        local calculateTalents = 0
        for i = 1, numTalents do
            nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i);
            --	DEFAULT_CHAT_FRAME:AddMessage("- "..nameTalent..": "..currRank.."/"..maxRank);
            calculateTalents = calculateTalents + currRank
        end
        --print("Total: " .. calculateTalents)
        talents[t] = calculateTalents
    end
    return talents
end

function GetRealSpellCrit(school)
    local maxCrit = GetSpellCritChance(school);
    local spellCrit;

    this.spellCrit = {};
    this.spellCrit[school] = maxCrit;

    for i = (school + 1), 7 do
        spellCrit = GetSpellCritChance(i);
        maxCrit = max(maxCrit, spellCrit);
        this.spellCrit[i] = spellCrit;
    end
    return maxCrit;
end

function GetRealMeleeCrit()
    local maxCrit = GetCritChance(); -- Get the overall melee crit chance
    local meleeCrit;

    this.meleeCrit = {};
    this.meleeCrit[1] = maxCrit; -- Store the max crit for the first index

    -- In Classic WoW, there are no additional schools for melee like spells
    -- So we'll simply store the overall melee crit chance
    for i = 2, 7 do
        meleeCrit = GetCritChance(); -- Get the same crit chance as it applies to all melee
        maxCrit = max(maxCrit, meleeCrit);
        this.meleeCrit[i] = meleeCrit;
    end

    return maxCrit; -- Return the max melee crit
end

function GetRealExpertise()
    local expertiseRating = GetCombatRating(CR_EXPERTISE);     -- Get expertise rating
    local expertiseValue = GetCombatRatingBonus(CR_EXPERTISE); -- Get expertise value (actual expertise)

    this.expertise = {};
    this.expertise.rating = expertiseRating;
    this.expertise.value = expertiseValue;

    return expertiseRating, expertiseValue; -- Return both rating and value
end

function GetRealArmorPenetration()
    local armorPenetrationRating = GetCombatRating(25); -- Get effective armor penetration
    this.armorPenetration = {};
    this.armorPenetration.rating = armorPenetrationRating;

    return armorPenetrationRating; -- Return the armor penetration rating
end

function HasGreatBlessingOfMight()
    local buffName = "Great Blessing of Might"
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        --      print(name)
        if not name then
            break -- No more buffs, exit the loop
        end
        if name == buffName then
            print("Great Blessing of Might is active!")
            return true
        end
    end
    return false
end

-- Combat Rating Constants
-- CR_WEAPON_SKILL = 1
-- CR_DEFENSE_SKILL = 2
-- CR_DODGE = 3
-- CR_PARRY = 4
-- CR_BLOCK = 5
-- CR_HIT_MELEE = 6
-- CR_HIT_RANGED = 7
-- CR_HIT_SPELL = 8
-- CR_CRIT_MELEE = 9
-- CR_CRIT_RANGED = 10
-- CR_CRIT_SPELL = 11
-- CR_HIT_TAKEN_MELEE = 12
-- CR_HIT_TAKEN_RANGED = 13
-- CR_HIT_TAKEN_SPELL = 14
-- COMBAT_RATING_RESILIENCE_CRIT_TAKEN = 15
-- COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN = 16
-- CR_CRIT_TAKEN_SPELL = 17
-- CR_HASTE_MELEE = 18
-- CR_HASTE_RANGED = 19
-- CR_HASTE_SPELL = 20
-- CR_WEAPON_SKILL_MAINHAND = 21
-- CR_WEAPON_SKILL_OFFHAND = 22
-- CR_WEAPON_SKILL_RANGED = 23
-- CR_EXPERTISE = 24
-- CR_ARMOR_PENETRATION = 25
-- CR_MASTERY = 26
-- CR_VERSATILITY = 29
-- Versatility = 30 (bug?)

-- Include the info button logic
-- (4.1)
-- Create the info button
local capsInfo = CreateFrame("Button", "CapsInfoButton", f)
capsInfo:SetSize(20, 20)                                            -- Set the size of the button
capsInfo:SetPoint("TOPLEFT", f, "TOPLEFT")                          -- Position the button
capsInfo:SetNormalTexture("Interface\\Icons\\INV_Misc_Information") -- Use the Info icon
capsInfo:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
capsInfo:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

-- Create the new frame to be shown when the info button is pressed
local infoFrame = CreateFrame("Frame", "InfoFrame", UIParent)
infoFrame:SetSize(300, 200)
infoFrame:SetPoint("CENTER")
infoFrame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
})
infoFrame:SetBackdropColor(0, 0, 0, 0.5)  -- Slightly transparent background
infoFrame:SetBackdropBorderColor(1, 1, 1) -- Visible border
infoFrame:Hide()                          -- Initially hide the frame

-- Make the info frame movable
infoFrame:SetMovable(true)
infoFrame:EnableMouse(true)
infoFrame:RegisterForDrag("LeftButton")
infoFrame:SetScript("OnDragStart", infoFrame.StartMoving)
infoFrame:SetScript("OnDragStop", infoFrame.StopMovingOrSizing)

-- Add a close button to the new frame
local closeButton = CreateFrame("Button", nil, infoFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", infoFrame, "TOPRIGHT")

-- Set the script for the info button click event
capsInfo:SetScript("OnClick", function()
    if infoFrame:IsShown() then
        infoFrame:Hide()
    else
        infoFrame:Show()
    end
end)
