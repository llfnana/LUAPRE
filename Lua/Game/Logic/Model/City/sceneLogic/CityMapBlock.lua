local a=class('CityMapBlock')function a:ctor()self.gameObject=nil;self.transform=nil;self._spriteRenderer=nil end;function a:bind(b,c,d)self.gameObject=b;self.transform=b.transform;self._spriteRenderer=b:GetComponentInChildren(typeof(SpriteRenderer))local e=string.format("home_map_block_%d_%d.png",d,c)if not ResInterface.IsExist(e)then return end;ResInterface.SyncLoadSprite(e,function(f)self._spriteRenderer.sprite=f end)local g=CityDefine.MapBlockSize*(c-0.5-CityDefine.MapBlockNum[1]/2)local h=-CityDefine.MapBlockSize*(d-0.5-CityDefine.MapBlockNum[2]/2)self.transform.localPosition=Vector3.New(g,h,0)end;function a:bind2(b,c,d,i)i=i or 1;self.gameObject=b;self.transform=b.transform;self._spriteRenderer=b:GetComponent(typeof(SpriteRenderer))local j=(c-1)*CityDefine["Map"..i.."BlockNum"][2]+d;local k=j<10 and"0"..j or j;local l=string.format("map_%dbg_%s.png",i,k)local e=l;if not ResInterface.IsExist(e)then return end;ResInterface.SyncLoadSprite(e,function(f)self._spriteRenderer.sprite=f;local m=self._spriteRenderer.bounds.size;local g=CityDefine.MapBlockSize*(d-0.5-CityDefine["Map"..i.."BlockNum"][2]/2-1)+m.x/2;local h=-(CityDefine.MapBlockSize*(c-0.5-CityDefine["Map"..i.."BlockNum"][1]/2-1)+m.y/2)self.transform.localPosition=Vector3.New(g,h,0)end)end;return a
