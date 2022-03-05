--Hungry Burger - Custom
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Allows the BK Hungry Burger tribute dodge to work
	 Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsCode,99995628))
end
