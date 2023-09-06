import "CoreLibs/graphics"
import "lume"

local pd <const> = playdate
local gfx <const> = pd.graphics
local lume <const> = lume

launchPower = MIN_LAUNCH_POWER
launchAngle = DEFAULT_LAUNCH_ANGLE
ANGLE_CHANGE_RATE = .25 -- delta per tick (in degrees)

function updateLaunchDetails()
    updateLaunchPower()
    updateLaunchAngle()
end

function updateLaunchAngle()
    gfx.drawText("Angle: "..launchAngle, 50, 10)

    if not readyToFire then
        return
    end

    if pd.buttonIsPressed(pd.kButtonUp) then
        launchAngle = math.min(MAX_LAUNCH_ANGLE, launchAngle + ANGLE_CHANGE_RATE)
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        launchAngle = math.max(MIN_LAUNCH_ANGLE, launchAngle - ANGLE_CHANGE_RATE)
    end

    if pd.buttonIsPressed(pd.kButtonLeft) then
        launchAngle = math.min(MAX_LAUNCH_ANGLE, launchAngle + ANGLE_CHANGE_RATE)
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        launchAngle = math.max(MIN_LAUNCH_ANGLE, launchAngle - ANGLE_CHANGE_RATE)
    end
end

function updateLaunchPower()
    change = pd.getCrankChange()
	if readyToFire and (change > 1 or pd.buttonIsPressed(pd.kButtonA)) then
        launchPower = activelyRaiseLaunchPower()
    else
        launchPower = idlyLowerLaunchPower()
    end

    -- draw "power bar"
    gfx.setLineWidth(10)
    gfx.drawRect(
        10,                                             -- starting 10 pixels right of the left border
        10,                                             -- and 10 px down from the top,
        POWER_BAR_WIDTH + gfx.getLineWidth(),           -- draw a rectangle WIDTH wide
        POWER_BAR_HEIGHT + gfx.getLineWidth())          -- and HEIGHT tall, with an added buffer since it's the outline bar
    gfx.fillRect(
        10 + gfx.getLineWidth()/2,                                          -- starting 10px + half a line-width in
        10 + gfx.getLineWidth()/2 + POWER_BAR_HEIGHT - 2*launchPower,       -- and 10px + half a line-width + OFFSET down
        POWER_BAR_WIDTH,
        2*launchPower)
end

function idlyLowerLaunchPower()
    launchPower = math.max(MIN_LAUNCH_POWER, launchPower - IDLE_LAUNCH_POWER_DECREASE_RATE)
    return launchPower
end

function activelyRaiseLaunchPower()
    launchPower = math.min(MAX_LAUNCH_POWER, launchPower + CRANK_LAUNCH_POWER_INCREASE_RATE)
    return launchPower
end

function resetLaunchPower()
    launchPower = MIN_LAUNCH_POWER
    return launchPower
end