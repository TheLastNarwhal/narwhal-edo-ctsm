--Hamburger Recipe - Custom
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
--Activation
Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsSetCard,0x195))
end
s.listed_names={99995629}
