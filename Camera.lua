function new(const)
	const = const or {}
	public = {}
	
	public.x = const.x or 0
	public.y = const.y or 0
	
	public.width = const.width or 640
	public.height = const.height or 480
	
	public.scalex = const.scalex or 1
	public.scaley = cosnt.scaley or 1
	
	public.buffer = const.buffer or 20
	
	function public.push()
		love.graphics.push()
		love.graphics.scale(1 / public.scalex, 1 / public.scaley)
		love.graphics.translate(-public.x, -public.y)
	end
	
	function public.pop()
		love.graphics.pop()
	end
	
	function public.setCenter(x, y)
		public.x = x - (public.width / 2)
		public.y = y - (public.height / 2)
	end
	
	function public.updateOnTarget(target)
		