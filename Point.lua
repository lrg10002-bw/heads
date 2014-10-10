function new(...)
	const = {...} or {}
	public = {}
	
	public.x = const[0] or 0
	public.y = const[1] or 0
	
	return public
end

return new