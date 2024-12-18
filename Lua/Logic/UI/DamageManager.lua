---------------------------------------
--战场伤害字
---------------------------------------
DamageManager = {};
local this 	  = DamageManager;

--[[
function DamageManager.OnObjectDestroy()
	if this.cachedata==nil then
		return;
	end
	local index = table.remove(this.cachedata.fifoList,1);
	if this.cachedata.savedItems[index] then
		this.cachedata.savedItems[index].IsFree = true;
	end
end
]]


function DamageManager.Init(initCount)
	this.cachedata 				= {};
	this.cachedata.fifoList 	= {};
	this.PreloadItems(initCount);
end
 
function DamageManager.Clear()
	if this.cachedata ~=nil and this.cachedata.savedItems~=nil then
		for i=1,#this.cachedata.savedItems do
			this.cachedata.savedItems[i]:Destroy();
		end
	end
	this.cachedata = {};

	if nil ~= this.resId and this.resId > 0 then
		ResInterface.ReleaseRes(this.resId);
	end
end

function DamageManager.PreloadItems(initCount)
	if not this.cachedata then
		this.cachedata 	= {};
	end

	if not this.cachedata.savedItems then
		this.cachedata.savedItems = {};
	end 

	if not this.cachedata.objRoot then
		this.cachedata.objRoot = GameObject.Find("UICanvas/Layer_HUD/DamageTextRoot").gameObject;
	end

	if not this.cachedata.itemPrefab then
	  this.resId =	ResInterface.LoadModel("DamageHUDText",function(prefab)
	  		SafeSetActive(prefab.gameObject,true);
			this.cachedata.itemPrefab = prefab;
			local itemCount 	      = 0;

			if this.cachedata and this.cachedata.savedItems then
				itemCount = #(this.cachedata.savedItems) or 0;
			end

			for i=1,initCount-itemCount do
				local newItem 					= this.GenItem();
				if newItem then
					this.cachedata.savedItems[i]= newItem;
				end
			end
		end);
	end
end

function DamageManager.GenItem()
	if this.cachedata.itemPrefab then
		local newItem = GOInstantiate(this.cachedata.itemPrefab):GetComponent("UIHUDText");
		AddChild(this.cachedata.objRoot.gameObject,newItem.gameObject);
		return newItem;
	end
end

function DamageManager.GetUnusedItem()
	if this.cachedata==nil or this.cachedata.savedItems==nil then
		return;
	end

	local unusedOne = nil; 
	local index 	= 1;
	for i=1,#this.cachedata.savedItems do
		if not unusedOne and this.cachedata.savedItems[i] and this.cachedata.savedItems[i].IsFree then
			unusedOne = this.cachedata.savedItems[i];
			index     = i;
			break;
		end
	end

	if not unusedOne then
		unusedOne = this.GenItem();
		index     = (#this.cachedata.savedItems or 0)+1;
		if this.cachedata and this.cachedata.savedItems then
			this.cachedata.savedItems[index] = unusedOne;
		end
	end 
	table.insert(this.cachedata.fifoList,index);
	return unusedOne;
end

function DamageManager.ShowDmg(dmg,bindObj,isEnemy,isCrit,isRestrained,isBlock,isResist,isArmorBreak,isPenetrated)

	if bindObj == nil then
		return;
	end

	local unusedOne = this.GetUnusedItem();
	if unusedOne then
		local dmgStr 	= string.format("%s%s",dmg>0 and "-" or "+",dmg);
		unusedOne:Show(dmgStr,bindObj,isEnemy,isCrit,isRestrained,isBlock,isResist,isArmorBreak,isPenetrated);
	end
end

return DamageManager;