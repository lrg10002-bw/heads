Bounds = require("Bounds")

eid = 0

local function newid()
	i = eid
	eid = eid + 1
	return i
end

function new(const)
	const = const or {}
	public = {}
	private = {}
	
	if not const.player then error("A player must be passed to the world constructor!") end
	
	private.entities = {}
	
	function public.addEntity(e)
		i = newid()
		private.entities[i] = e
		e.id = i
		return e.id
	end
	
	function public.getEntity(i)
		return private.entities[i]
	end
	
	function public.getEntities()
		return private.entities
	end
	
	function public.updateRange(rx, ry, rw, rh)
		for k,v in pairs(private.entities) do
			if not v.bounds.intersects(Bounds{x=rx,y=ry,width=rw,height=rh}) then
				return
			end
			
			
		end
	end
	
	