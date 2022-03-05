--Fry Fry Splash
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Add counter during your standby
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--Add counter to all monsters when destroyed and sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.addccon)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--Quick Ritual Summon "Hungry" from hand/GY from either field
	local e4=Ritual.AddProcGreater({
		handler=c,
	  filter=aux.FilterBoolFunction(Card.IsSetCard,0x195),
	  location=LOCATION_HAND|LOCATION_GRAVE,
	  extrafil=s.extramat
	})
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.ritcost)
	c:RegisterEffect(e4)
end
s.counter_place_list={0x1042}
s.listed_series={0x195}
--Remove Grease Counters for Ritual Summon from hand/GY
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1042,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x1042,3,REASON_COST)
end
function s.matfilter(c)
  return c:HasLevel() and c:GetCounter(0x1042)>0
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
  return Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE,nil)
end
--Add counter to 1 monster on the field
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(0x1042,1)
	end
end
--Conditional to add counters to all monsters on sent to GY
function s.addccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
