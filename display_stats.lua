
print("|cff00ccffStats Monitor|r loaded!");
print("Current version |cff00ccff0.3|r");

-- (1)
local f = CreateFrame("Frame", "YourFrameName", UIParent)
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
close:SetPoint("TOPRIGHT", f, "TOPRIGHT")
close:SetScript("OnClick", function()
	f:Hide()
end)

-- (5)
local addonText = f:CreateFontString(nil, "addonText", "GameFontDisable")
addonText:SetPoint("TOP", -10, -3)
addonText:SetText(" cast any spell");

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

myFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
myFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
myFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
myFrame:SetScript("OnEvent",
	function(self, event, arg1, arg2, arg3, arg4)
	localizedClass, englishClass, classIndex = UnitClass("player");
	--print("english Class: " .. englishClass) -- MAGE, PALADIN, WARRIOR etc...
	if englishClass == "MAGE" then
		local classRole = getClassRole()
		if(classRole == 2) then
			--print("FIRE TALENTS")
			addonText:SetText(" Fire Mage");
			displayRDPS("FIRE")
		end
	elseif englishClass == "PALADIN" then
		addonText:SetText(" Paladin Tank");
		displayTank()
	elseif englishClass == "DEATHKNIGHT" then
		addonText:SetText(" Death Knight")
		displayTank()
	elseif englishClass == "WARRIOR" then
		addonText:SetText(" Warrior Tank")
		displayTank()
	end
   end
);

function getClassRole()
	local classRole = processClassSpecialization(englishClass)  -- 1 Arcane, 2 Fire, 3 Frost
	if classRole[1] > classRole[2] and classRole[1] > classRole[3] then
	  return 1
	elseif classRole[2] > classRole[1] and classRole[2] > classRole[3] then
	  return 2
	else 
	  return 3
	end
end

function displayRDPS(talent)
		local spellDmg = 0
		local critChance = 0
	if talent == "FIRE" then
		 spellDmg = GetSpellBonusDamage(3);
		 critChance = GetRealSpellCrit(3);
	end
	    --1 for Physical
		--2 for Holy
		--3 for Fire
		--4 for Nature
		--5 for Frost
		--6 for Shadow
		--7 for Arcane
	   
	   local hitModifier = GetCombatRatingBonus(CR_HIT_SPELL)
	   local block = GetBlockChance();
	   
	   local max_health = UnitHealthMax("player");
	   local health = UnitHealth("player")
	   local healthWarningPercentage = 100 - (((max_health - health) / max_health) * 100)
	   
	   if(healthWarningPercentage < 25) then
			if(not warningSent) then
				--SendChatMessage("WARNING MAGE HEALTH LOW ".. health.. " !!!", "YELL");
				warningSent = true
			end
	   elseif (healthWarningPercentage > 21) then
			warningSent = false --reset
	   end
	   
	   if (spellDmg > 3000) then
	        armorText:SetText("|cff00ccffBonus dmg  |r " ..  "|c33fff6ff".. spellDmg .."|r")
	   else
			armorText:SetText("|cff00ccffBonus dmg  |r " .. spellDmg)
	   end
	   physDmgText:SetText(string.format("|cff00ccffHit chance|r %.2f %%", hitModifier))
	   dodgeText:SetText(string.format("|cff00ccffCritical  |r %.2f %%", critChance))
	   parryText:SetText(string.format("|cff00ccffHaste     |r %.2f %%", 0))
	   blockText:SetText(string.format("|cff00ccffSpeed    |r %.2f %%", 0))

end

function displayTank()
	baseArmor, totalArmor, bonusArmor, minusArmor = UnitResistance("player", 0)
	   
	   local parry = GetParryChance();
	   local dodge = GetDodgeChance();
	   local block = GetBlockChance();
	   local dmgReduction = ((totalArmor / (totalArmor + 15232.5)) * 100)
	   local max_health = UnitHealthMax("player");
	   local health = UnitHealth("player")
	   local healthWarningPercentage = 100 - (((max_health - health) / max_health) * 100)
	   
	   if(healthWarningPercentage < 25) then
			if(not warningSent) then
				SendChatMessage("WARNING TANK HEALTH LOW ".. health.. " !!!", "YELL");
				warningSent = true
			end
	   elseif (healthWarningPercentage > 21) then
			warningSent = false --reset
	   end
	   
	   if (bonusArmor > 3000) then
	        armorText:SetText("|cff00ccffArmor  |r " ..  "|c33fff6ff"..totalArmor.."|r")
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
	local talents = {0,0,0}

	for t=1, numTabs do
		--DEFAULT_CHAT_FRAME:AddMessage(GetTalentTabInfo(t)..":");
		local numTalents = GetNumTalents(t);
		local calculateTalents = 0
		for i=1, numTalents do
			nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(t,i);
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

    for i=(school+1), 7 do

        spellCrit = GetSpellCritChance(i);
        maxCrit = max(maxCrit, spellCrit);
        this.spellCrit[i] = spellCrit;

    end

    return maxCrit;

end