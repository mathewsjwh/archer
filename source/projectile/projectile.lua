import "CoreLibs/graphics"
import "cannon"

local pd <const> = playdate
local gfx <const> = pd.graphics

local projX = nil
local projY = nil
local projYVel = DEFAULT_VELOCITY
local projXVel = DEFAULT_VELOCITY
readyToFire = true
local deltaX = 0
local deltaY = 0
local minYVel = 0
local hardResetCounter = 0
local flightAngle = launchAngle

-- returns min x/y and max x/y values that the center of the projectile can be drawn at
-- given the projectile's radius and any ceilings/floors/walls acting as buffers

function __init() end
function getProjectileBounds()
	local minProjX = PROJECTILE_RADIUS
    local minProjY = CEILING_WIDTH + PROJECTILE_RADIUS

    local maxProjX, maxProjY = pd.display.getSize()
	maxProjY -= (FLOOR_WIDTH + PROJECTILE_RADIUS)
    maxProjX -= (PROJECTILE_RADIUS)

    return minProjX, minProjY, maxProjX, maxProjY
end

function moveWithVelocityUnlessBlocked(pos, vel, min, max)
    if vel > 0 then
        return math.min(pos + vel, max)
    elseif vel < 0 then
        return math.max(pos + vel, min)
    else
        return pos
    end
end

-- returns the deltaX and deltaY (abs distance that x and y moved last tick)
function updateProjectilePosition()
    local minProjX, minProjY, maxProjX, maxProjY = getProjectileBounds()

    local startingX = projX
    local startingY = projY

    projX = moveWithVelocityUnlessBlocked(projX, projXVel, minProjX, maxProjX)
    projY = moveWithVelocityUnlessBlocked(projY, projYVel, minProjY, maxProjY)
    return math.abs(startingX - projX), math.abs(startingY - projY)
end

function updateProjectileVelocities()
    -- if we're not moving up and down but are still moving laterally, decrease speed due to friction
    if deltaY == 0 and deltaX ~= 0 then
        projXVel = math.max(projXVel - FRICTION_COEFF, 0)
    elseif deltaX == 0 then
        projXVel = 0
    end

    --if we've fallen to the ground, reset velocity (we could also diminish and reverse it to bounce)
    if deltaY == 0 and projYVel > 0 then
        projYVel = 0
    else
        projYVel += GRAV_ACCEL_DOWNWARD
    end

    if projYVel < minYVel then
        minYVel = projYVel
    end

	projectileSpeed = math.sqrt(projYVel^2 + projXVel^2)
    updateFlightAngle()
end

function updateProjectile()
    if projX == nil or projY == nil then
        reset()
    end

	if pd.buttonJustReleased(pd.kButtonA) and readyToFire then
		fire()
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		reset()
	end

    if pd.buttonIsPressed(pd.kButtonB) then
        hardResetCounter += 1
    else hardResetCounter = 0 end

    if hardResetCounter > pd.getFPS() then
        hardReset()
    end

    deltaX, deltaY = updateProjectilePosition()
    updateProjectileVelocities()

    gfx.fillCircleAtPoint(projX, projY, PROJECTILE_RADIUS)
end

function fire()
	if readyToFire ~= true then
		return
	end

	projYVel = launchPower * -(math.sin(math.rad(launchAngle)))
	projXVel = launchPower * (math.cos(math.rad(launchAngle)))
    readyToFire = false
    launchPower = resetLaunchPower()
end

function reset()
	projX, _, _, projY = getProjectileBounds()
	projYVel = 0
	projXVel = 0
	launchPower = resetLaunchPower()
	readyToFire = true
    flightAngle = launchAngle
end

function hardReset()
    launchAngle = DEFAULT_LAUNCH_ANGLE
end