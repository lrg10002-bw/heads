function new(const)
	const = const or {}
	public = {}
	
	public.x = const.x or 0
	public.y = const.y or 0
	public.width = const.width or 0
	public.height = const.height or 0
	
	function public.contains(point)
		if point.x >= public.x and point.x <= public.x + public.width then
			if point.y >= public.y and point.y <= public.y + public.height then
				return true
			end
		end
		
		return false
	end
	
	function public.intersects(b)
		x1,y1,w1,h1 = public.x, public.y, public.width, public.height
		x2,y2,w2,h2 = b.x, b.y, b.width, b.height
		return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
	end
	
	return public
end

return new	