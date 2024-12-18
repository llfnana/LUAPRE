
--封装数学计算工具


MathUtils = MathUtils or {}
local this = MathUtils;

function MathUtils.GetAABBRect( _v3list )
	
	local minx = 1000000;
	local minz = 1000000
	local maxx = -1000000;
	local maxz = -1000000;

	for i = 1, #_v3list do
		if _v3list[i].x < minx then
			minx = _v3list[i].x
		end
		if _v3list[i].x > maxx then
			maxx = _v3list[i].x
		end		


		if _v3list[i].z < minz then
			minz = _v3list[i].z
		end
		if _v3list[i].z > maxz then
			maxz = _v3list[i].z
		end		
	end
	return minx, minz, maxx, maxz;
end


--求线段ab和线段cd的交点
function MathUtils.SegmentsIntr(a, b, c, d)
	if a == nil or b == nil or c == nil or b == nil then
		return nil;
	end

	if a.x == nil or a.y == nil or b.x == nil or b.y == nil or c.x == nil or c.y == nil or b.x == nil or b.y == nil then
		return nil;
	end
	
	
	--线段ab的法线N1  
    local nx1 = (b.y - a.y);
	local ny1 = (a.x - b.x);  
  
    --线段cd的法线N2  
    local nx2 = (d.y - c.y);
	local ny2 = (c.x - d.x);  
      
    --两条法线做叉乘, 如果结果为0, 说明线段ab和线段cd平行或共线,不相交  
    local denominator = nx1*ny2 - ny1*nx2;  
    if math.abs(denominator) < 0.00001 then
        return nil;  
	end
      
    --在法线N2上的投影  
    local distC_N2 = nx2 * c.x + ny2 * c.y;  
    local distA_N2 = nx2 * a.x + ny2 * a.y - distC_N2;  
    local distB_N2 = nx2 * b.x + ny2 * b.y - distC_N2;  
  
    -- 点a投影和点b投影在点c投影同侧 (对点在线段上的情况,本例当作不相交处理);  
    if distA_N2 * distB_N2 >= 0.0 then
        return nil;  
	end
      
    --  
    --判断点c点d 和线段ab的关系, 原理同上  
    --  
    --在法线N1上的投影  
    local distA_N1 = nx1 * a.x + ny1 * a.y;  
    local distC_N1 = nx1 * c.x + ny1 * c.y - distA_N1;  
    local distD_N1 = nx1 * d.x + ny1 * d.y - distA_N1;  
    if  distC_N1 * distD_N1 >= 0.0 then
        return nil;  
	end
  
    --计算交点坐标  
    local fraction= distA_N2 / denominator;  
    local dx= fraction * ny1;
	local dy= -fraction * nx1;  

	return {x = a.x + dx, y = a.y + dy};
end


--求线段ab, 和Rect(c-最小点,d-最大点)交点（注意：只返回最近交点)
function MathUtils.LineRectInsercts(a, b, c, d )

	local rectPoints = {}
	rectPoints[1] = { x = c.x, y = c.y };
	rectPoints[2] = { x = d.x, y = c.y };
	rectPoints[3] = { x = d.x, y = d.y };
	rectPoints[4] = { x = c.x, y = d.y };
	rectPoints[5] = rectPoints[1];

	local insercts = {}
	for i = 1, 4 do
		local retPt = this.SegmentsIntr(a, b, rectPoints[i], rectPoints[i+1] );
		if retPt ~= nil then
			table.insert( insercts, retPt )
		end
	end

	if #insercts == 0 then
		return nil;
	end

	local minmumDist = 0
	local minmumPtIndex = nil
	for i = 1, #insercts do
		local distSqr1 = (a.x - insercts[i].x)*(a.x - insercts[i].x) + (a.y - insercts[i].y)*(a.y - insercts[i].y)
		local distSqr2 = (b.x - insercts[i].x)*(b.x - insercts[i].x) + (b.y - insercts[i].y)*(b.y - insercts[i].y)
		local distSqr =  math.min(distSqr1, distSqr2)
		if minmumPtIndex == nil or minmumDist > distSqr then
			minmumPtIndex = i;
			minmumDist = distSqr;
		end
	end
	return insercts[minmumPtIndex];

end




function MathUtils.PointDistance(a, b)
	if a == nil or b == nil then
		return 0.0;
	end
	
	if a.x == nil or a.y == nil or b.x == nil or b.y == nil then
		return 0.0;
	end
	
	local x = a.x - b.x;
	local y = a.y - b.y;
	
	return math.sqrt(x * x + y * y);
end


--判断两个轴对齐矩形是否重叠
function MathUtils.IsRectOverlap( _x1, _z1, _w1, _h1, _x2, _z2, _w2, _h2 )
	if (_x1 + _w1 > _x2) and (_x2 + _w2 > _x1) and (_z1+_h1 > _z2) and (_z2+_h2 > _z1) then
		return true;
	else
		return false;
	end
end

