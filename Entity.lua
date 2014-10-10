Bounds = require("Bounds")

function new(const)
	const = const or {}
	public = {}
	
	public.bounds = const.bounds or Bounds{x=0,y=0,width=100,height=100}
	public.vx = const.vx or 0
	public.vy = const.vy or 0
	public.static = const.static or false
	public.frozen = true
	
	
	return public
end

return new