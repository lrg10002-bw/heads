Point = require("Point")

function new(const)
	const = const or {}
	public = {}
	private = {}
	
	cellSize = const.cellSize or 100
	
	hash = {}
	entities = {}
	
	function private.toHash(x, y)
		hx = math.floor(x / cellSize)
		hy = math.floor(y / cellSize)
		return hx, hy
	end
	
	function private.addToBucket(p, e)
		hx, hy = private.toHash(p.x, p.y)
		hid = tostring(hx)..tostring(hy)
		if type(hash[hid]) ~= "table" then hash[hid] = {} end
		hash[hid][e.id] = e
	end
	
	function public.clearBuckets()
		hash = {}
	end
	
	function public.addEntity(e)
		tl = Point(e.bounds.x, e.bounds.y)
		tr = Point(e.bounds.x+e.bounds.width, e.bounds.y)
		bl = Point(e.bounds.x, e.bounds.y+e.bounds.height)
		br = Point(e.bounds.x+e.bounds.width, e.bounds.y+e.bounds.height)
		
		private.addToBucket(tl, e); private.addToBucket(tr, e)
		private.addToBucket(bl, e); private.addToBucket(br, e)
	end
	
	function public.update()
		collisions = {}
		unique = {}
		for k,v in pairs(hash) do
			if type(v) == "table" then
				for eid,e in pairs(v) do
					for eid1, e_1 in pairs(v) do
						if e.bounds.intersects(e_1.bounds) then
							table.insert(collisions, {e, e_1})
					end
				end
			end
		end
	end
		
		