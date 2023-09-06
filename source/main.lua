import "imports"

local pd <const> = playdate
local gfx <const> = pd.graphics

function pd.update()
	gfx.clear()

	updateLaunchDetails()
	updateProjectile()
end