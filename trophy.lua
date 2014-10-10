trophy = {}

-- Actual trophy code
function trophy:init(cell_size, gx, gy)
  self.contents = {}
  self.actives = {}
  self.GRAVITY_X = gx or 0
  self.GRAVITY_Y = gy or 5
  self.cell_size = cell_size or 100
end

function trophy:_hash(x, y)
  return math.floor(x/self.cell_size), math.floor(y/self.cell_size)
end

function trophy:_parse(p)
  -- We have to parse the string to get the x/y location
  local r = {}
  for i in string.gmatch(p, "(%w+)") do
    table.insert(r, i)
  end
  return r[1], r[2]
end

function trophy:_bucket(x, y)
  if self.contents[self:_create_key(x, y)] == nil then
    self.contents[self:_create_key(x, y)] = {}
  end
  return self.contents[self:_create_key(x, y)]
end

function trophy:_create_key(x, y)
  return x .. " " .. y -- Using strings as keys
end

function trophy:_get_nearby(col)
  local t = {}
  local minx, miny = self:_hash(col.x, col.y)
  local maxx, maxy = self:_hash(col.x + col.w, col.y + col.h)
  for i=minx,maxx do
    for j=miny,maxy do
      for _, o in pairs(self.contents[self:_create_key(i, j)]) do
        t[o] = o -- We want uniq stuff... kinda hacky, but it works (because we ignore the keys later on).
      end
    end
  end
  return t
end

function trophy:_assign_to_bucket(c)
  local minx, miny = self:_hash(c.x, c.y)
  local maxx, maxy = self:_hash(c.x + c.w, c.y + c.h)

  for i=minx, maxx do
    for j=miny, maxy do
      table.insert(self:_bucket(i, j), c)
    end
  end
end

function trophy:_remove_from_bucket(c, px, py)
  local minx, miny = self:_hash(px, py)
  local maxx, maxy = self:_hash(px + c.w, py + c.h)

  for i=minx, maxx do
    for j=miny, maxy do
      for k,o in ipairs(self.contents[self:_create_key(i, j)]) do
        if c == o then
          table.remove(self.contents[self:_create_key(i, j)], k)
        end
      end
    end
  end
end

function trophy:_get_left(c)
  return c.x
end

function trophy:_get_top(c)
  return c.y
end

function trophy:_get_right(c)
  return c.x + c.w
end

function trophy:_get_bottom(c)
  return c.y + c.h
end

function trophy:_solve_collision(c, o)
  if self:_get_bottom(c) < self:_get_top(o)
    or self:_get_top(c) > self:_get_bottom(o)
    or self:_get_right(c) < self:_get_left(o)
    or self:_get_left(c) > self:_get_right(o)
    or c.static then
    return -- Return if it's absolutely not colliding
  end

  local c_mid_x = c.x + (c.w / 2)
  local c_mid_y = c.y + (c.h / 2)
  local o_mid_x = o.x + (o.w / 2)
  local o_mid_y = o.y + (o.h / 2)

  local dx = (o_mid_x - c_mid_x) / (o.w / 2)
  local dy = (o_mid_y - c_mid_y) / (o.h / 2)

  local abs_dx = math.abs(dx)
  local abs_dy = math.abs(dy)

  if math.abs(abs_dx - abs_dy) < .1 then
    if dx < 0 then
      c.x = self:_get_right(o)
    else
      c.x = self:_get_left(o) - o.w
    end

    if dy < 0 then
      c.y = self:_get_bottom(o)
    else
      c.y = self:_get_top(o) - c.h
    end

    if math.random() < .5 then
      c.vx = -c.vx * o.r
      if math.abs(c.vx) < .001 then
        c.vx = 0
      end
    else
      c.vy = -c.vy * o.r
      if math.abs(c.vy) < .001 then
        c.vy = 0
      end
    end
  elseif abs_dx > abs_dy then
    if dx < 0 then
      c.x = self:_get_right(o)
    else
      c.x = self:_get_left(o) - c.w
    end

    c.vx = -c.vx * o.r

    if math.abs(c.vx) < .001 then
      c.vx = 0
    end
  else
    if dy < 0 then
      c.y = self:_get_bottom(o)
    else
      c.y = self:_get_top(o) - c.h
    end

    c.vy = -c.vy * o.r
    if math.abs(c.vy) < .001 then
      c.vy = 0
    end
  end
end

function trophy:create_collider(t, x, y, w, h, r, static)
  t.col = {}
  t.col.static = static or false
  t.col.x = x
  t.col.y = y
  t.col.w = w
  t.col.h = h
  t.col.r = r or .1
  t.col.vx = 0
  t.col.vy = 0

  self:_assign_to_bucket(t.col)

  if not t.col.static then
    table.insert(self.actives, t.col)
  end
end

function trophy:remove_collider(c)
  for i, j in ipairs(self.actives) do
    if j == c then
      table.remove(self.actives, i)
    end
  end

  local i,j=self:_hash(c.x, c.y)
  local maxx,maxy=self:_hash(c.x+c.w, c.y+c.h)
  while i<=maxx do
    while j<=maxy do
      for k,o in ipairs(self.contents[self:_create_key(i, j)]) do
        if o == c then
          table.remove(self.contents[self:_create_key(i, j)], k)
        end
      end
      j = j + 1
    end
    i = i + 1
    -- Hack to get out of the last bucket
    if i == maxx then
      table.remove(self.contents[self:_create_key(i, j-1)], k)
    end
  end
end

function trophy:update(dt)
  for _, c in pairs(self.actives) do
    -- Previous x, y, max x and max y
    local px, py = c.x, c.y
    local pmx, pmy = c.x + c.w, c.y + c.h

    -- Set delta x
    c.vy = c.vy + self.GRAVITY_Y
    c.vx = c.vx

    for _, o in pairs(self:_get_nearby(c)) do
      if o ~= c then
        self:_solve_collision(c, o)
      end
    end

    c.y = c.y + c.vy * dt
    c.x = c.x + c.vx * dt

    -- Get the buckets
    local bpx, bpy = self:_hash(px,py)
    local bmpx, bmpy = self:_hash(pmx,pmy)
    local bcx, bcy = self:_hash(c.x,c.y)
    local bmcx, bmcy = self:_hash(c.x + c.w, c.y + c.h)

    if(bpx ~= bcx or bpy ~= bcy) then
      self:_remove_from_bucket(c, px, py)
      self:_assign_to_bucket(c)
    end

    if(bmpx ~= bmcx or bmpy ~= bmcy) then
      self:_remove_from_bucket(c, px, py)
      self:_assign_to_bucket(c)
    end
  end
end

function trophy:debug_draw()
  -- Love2d specific
  love.graphics.setColor(255, 0, 255, 155)
  for k, bucket in pairs(self.contents) do
    local x, y = self:_parse(k)
    love.graphics.rectangle('line', x * self.cell_size, y * self.cell_size, self.cell_size, self.cell_size)
    love.graphics.print(#self.contents[k], x * self.cell_size, y * self.cell_size)
    for _, e in pairs(bucket) do
      love.graphics.rectangle('line', e.x, e.y, e.w, e.h)
    end
  end
end

return trophy