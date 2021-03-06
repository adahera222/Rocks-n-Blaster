-- Rocks-n-Blaster -- #LD48 -- by <weldale@gmail.com>

Entity = class("Entity")

function Entity:initialize( x, y)
	x = x or 0
	y = y or 0

	self.x = x
	self.y = y

	self.gravityAffected = false

	self.vx = 0
	self.vy = 0

	self.speedX = 16
	self.speedY = 160

	self.graphics = nil

	self.hitbox = { left = 0, top = 0, bottom = 0, right = 0}

	self.timers = {}

	self.remove = false

	self.obstacle = true
	self.blastable = true
	self.pushable = false

	self.dX = 0

end

function Entity:push(dX)

	if not self.pushable then
		return
	end

	local oldX = self.x

	self.x = self.x + dX

	if not gameManager:isObstacleForEntity(self) then
		self.dX = dX
	end

	self.x = oldX


end

function Entity:keypressed(key)
	return false
end

function Entity:keyreleased(key)
	return false
end

function Entity:timer(name, waitSecs, callback)

	self.timers[name] = {
		name = name,
		t = waitSecs,
		callback = callback
	}

end

function Entity:collides( x, y )
	return x >= self.x - self.hitbox.left and x <= self.x + self.hitbox.right and y >= self.y - self.hitbox.top and y <= self.y + self.hitbox.bottom
end

function Entity:collidesWith(entity)

	local or1x, or1y, or2x, or2y = self:getHitRectangle()
	local er1x, er1y, er2x, er2y = entity:getHitRectangle()

	function intersectRect( r1x1, r1y1, r1x2, r1y2, r2x1, r2y1, r2x2, r2y2 )
 	 	return not ( 
			r1x2 < r2x1 or 
			r2x2 < r1x1 or
			r2y1 > r1y2 or
			r1y1 > r2y2)
	end

	return intersectRect( or1x, or1y, or2x, or2y, er1x, er1y, er2x, er2y )

end


function Entity:removeTimer(name)
	self.timers[name] = nil
end

function Entity:draw()
	if self.graphics then
		self.graphics:draw(self.x, self.y)
	end

	--utils.withColor({255,0,0,255}, function()
	--	love.graphics.rectangle( "line", self.x - self.hitbox.left, self.y - self.hitbox.top, self.hitbox.left + self.hitbox.right, self.hitbox.top + self.hitbox.bottom )
	--	end)
end

function Entity:stop()
	self.vy = 0
	self.vx = 0
end

function Entity:rasterize()
	local mX, mY = gameManager:toMapXY(self.x, self.y)
	self.x, self.y = gameManager:toEntityXY(mX, mY, self.graphics.offset[1], self.graphics.offset[2])
end

function Entity:getHitRectangle()
	return 
		self.x - self.hitbox.left, 
		self.y - self.hitbox.top, 
		self.x + self.hitbox.right, 
		self.y + self.hitbox.bottom
end


function Entity:update(dt)

	for k,timer in pairs(self.timers) do
		timer.t = timer.t - dt

		if timer.t <= 0 then
			timer.t = timer.callback(self)
		end

		if timer.t == nil or timer.t < 0 then
			self.timers[k] = nil
		end
	end

	if self.gravityAffected then

		--print(self.vy, self.vx)

		if not gameManager:isObstacleInDir(self, 0, 1) then
			self.vy = 1 --self.vy + gameManager:getGravity()

			-- if self.dX == 0 and not gameManager:isObstacleInDir(self, 1, 1) and not gameManager:isObstacleInDir(self, 1, 0) then
			-- 	self.dX = 16
			-- elseif self.dX == 0 and not gameManager:isObstacleInDir(self, -1, 1) and not gameManager:isObstacleInDir(self, -1, 0) then
			-- 	self.dX = -16
			-- end
		end

		--print(self.vy, self.vx)

	end

	if self.pushable  then
		if self.dX < 0 then
			self.vx = -1
		elseif self.dX > 0 then
			self.vx = 1
		else
			self.vx = 0
		end
	end



	if self.vx ~= 0 or self.vy ~= 0 then

		local oldX = self.x
		local oldY = self.y


		local newX = self.x + (self.vx * self.speedX * dt)
		local newY = self.y + (self.vy * self.speedY * dt)

		self.x = newX
		self.y = newY

		local isObstacle, e = gameManager:isObstacleForEntity(self)

		if isObstacle then
			self.x = oldX

			self:onCollide(e)

			if gameManager:isObstacleForEntity(self) then
				self.x = newX
				self.y = oldY

				if gameManager:isObstacleForEntity(self) then
					self.x = oldX
				end

			end


		end

		if self.pushable then
			self.dX = self.dX - (self.x - oldX)

			if self.dX <= 0.001 then
				self.dX = 0
			end
		end

	end



end

function Entity:onCollide(e)

end

function Entity:onExplode()
	self.remove = true
end

function Entity:onMobCollide(mod)
end