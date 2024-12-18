

IndexPQ = class("IndexPQ")

function IndexPQ:ctor( _maxsize )
	self.N = 0;
	self.MaxN = _maxsize;
	self.keys = {}
	self.pq = {}
	self.qp = {}
end

function IndexPQ:clear()
	self.N = 0;
	self.keys = {}
	self.pq = {}
	self.qp = {}
end

function IndexPQ:empty()
	return self.N == 0;
end

function IndexPQ:size()
	return self.N;
end


function IndexPQ:push( i, key )
	if self.qp[i] ~= nil then
		error("[IndexPQ.push]"..i.." exist!");
	end

	self.N = self.N + 1;
	self.qp[i] = self.N;
	self.pq[self.N] = i;
	self.keys[i] = key;
	self:swim(self.N);
end



function IndexPQ:changes( i, key )
	if not self:contains(i) then
		error("[IndexPQ:changes] not contains i="..i)
		return;
	end
	self.keys[i] = key;

	--error("changes:"..i..";"..self.qp[i]..";"..self.N );

	self:swim(self.qp[i]);
	self:sink(self.qp[i]);
end


function IndexPQ:contains( i )
	return self.qp[i] ~= nil;
end

function IndexPQ:top()
	return self.keys[ self.pq[1] ];
end

function IndexPQ:topIndex()
	return self.pq[1];
end


function IndexPQ:pop()
	local minKey = self.pq[1];
	local ret = self.keys[minKey];
	self:exch(1, self.N)
	self.N = self.N-1;
	self:sink(1);

	if( self.pq[self.N+1] ~= minKey ) then
		error("[IndexPQ.pop]error!")
	end

	self.qp[minKey] = nil;
	self.keys[minKey] = nil;  --change to  -math.hugeif you want desc order 
	self.pq[self.N+1] = nil;
	return ret;
end


function IndexPQ:swim( k )
	while( k > 1 and not self:less( math.floor(k/2), k) ) do
		self:exch( math.floor(k/2), math.floor(k) );
		k = math.floor(k/2);
	end
end

function IndexPQ:sink( k )
	while( 2*k <= self.N ) do
		local j = 2*k
		if j < self.N and not self:less(j,j+1) then
			j = j + 1;
		end
		if self:less(k, j) then
			break;	
		end
		self:exch( k, j );
		k = j;				
	end
end

function IndexPQ:less( i, j )
	if i == j then
		error( "less i == j ");
		return false;
	end
	return self.keys[self.pq[i]] < self.keys[self.pq[j]];	
end


function IndexPQ:exch( i, j )

	if i == j then
		--error("exch i == j, i = "..i);
		return;
	end

	local swap = self.pq[i];
	self.pq[i] = self.pq[j];
	self.pq[j] = swap;

	self.qp[self.pq[i]] = i;
	self.qp[self.pq[j]] = j;
end



function IndexPQ:print()
	local str = ""
	for i = 1, self.N do
		local k = self.pq[i];
		str = str .. tostring( self.keys[k] )..","
	end
	error( str );
end



-- --for test
-- local indexPq = IndexPQ.New(100);
-- indexPq:push( 1, 100 );
-- indexPq:push( 2, 50 );
-- indexPq:push( 3, 200 );
-- indexPq:push( 4, 80 );
-- indexPq:changes(1, 20);
-- indexPq:push(5, 70);

-- local iter = 1;
-- while not indexPq:empty() do
-- 	error( iter ..";"..indexPq:topIndex() .. "=" .. indexPq:top() .. "=".. indexPq:pop() .. "," );
-- 	iter = iter + 1;
-- end	

