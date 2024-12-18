
--可移动模型
RenderModelMovable = class("RenderModelMovable", RenderModel)


function RenderModelMovable:ctor()
	RenderModel.ctor( self )
	self.moveControl = nil;
	self.speed = 1;
end


function RenderModelMovable:SetSpeed( _speed )
	self.speed  = _speed;
	if not self:CheckMoveControl() then
		return;
	end
	self.moveControl:SetSpeed( _speed )
end


function RenderModelMovable:GetSpeed()
	return self.speed;
end


function RenderModelMovable:CheckMoveControl()

	-- if self.state ~= RenderObjectState_Loaded then
	-- 	return false;
	-- end	

	if isNil(self.moveControl) then
		self.moveControl = self:GetComponent( MoveObjectControl );
		if isNil(self.moveControl) then
			self.moveControl = self:AddComponent( MoveObjectControl );
			if isNil(self.moveControl) then
				return false;
			end
		end
	end
	return true;
end


function RenderModelMovable:SetPosition( tarPos )
	if not self:CheckMoveControl() then
		return;
	end
	self.moveControl:SetPosition( tarPos.x, tarPos.y, tarPos.z )
end


function RenderModelMovable:RotateOn(_isrotatechild)
	if not self:CheckMoveControl() then
		return;
	end
	self.moveControl:RotateOn(_isrotatechild)
end


function RenderModelMovable:RotateOff()
	if not self:CheckMoveControl() then
		return;
	end
	self.moveControl:RotateOff()
end




function RenderModelMovable:MoveTo( tarPos, _callback )
	if not self:CheckMoveControl() then
		error("[RenderModelMovable:MoveTo] Error return!self.state="..self.state)
		return;
	end
	self.moveControl:SimpleMoveTo( tarPos.x, tarPos.y, tarPos.z, _callback );
end


function RenderModelMovable:MoveBegin( _isClear )
	if not self:CheckMoveControl() then
		error("[RenderModelMovable:BeginMove] Error return!self.state="..self.state)
		return false;
	end
	if _isClear == nil then
		_isClear = true;
	end
	self.moveControl:Begin( _isClear);	
	return true;
end


function RenderModelMovable:AddPos( _pos )
	self.moveControl:AddPos( _pos.x, _pos.y, _pos.z );	
end


function RenderModelMovable:MoveEnd( _callback )
	self.moveControl:End( _callback);	
end


function RenderModelMovable:GoSpeedMode( _speed )
	if _speed == nil then
		_speed = 0;
	end
	self.moveControl:GoSpeedMode( _speed);	
end

function RenderModelMovable:GoTimeMode( _totaltime, _remaintime )
	self.moveControl:GoTimeMode( _totaltime, _remaintime );	
end

function RenderModelMovable:Stop()
	self.moveControl:Clear()
end


-- function RenderModelMovable:RegisterOnArrived( _callback )
-- 	if not self:CheckMoveControl() then
-- 		return;
-- 	end
-- 	self.moveControl:RegisterArrivedCallback(_callback)
-- end
