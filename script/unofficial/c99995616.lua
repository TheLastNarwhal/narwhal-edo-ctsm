--Last Draw To Break The Camel's Back
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x300)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
--Add Counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_DRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.addc)
	c:RegisterEffect(e3)
	--Destroy and Discard
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetTarget(s.disctg)
	e4:SetOperation(s.discop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ADD_COUNTER+0x300)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
--Add Counter On Draw
s.counter_place_list={0x300}
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep then
		c:AddCounter(0x300,1)
		if c:GetCounter(0x300)==5 then
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,0,0,ep,0)
		end
	end
end
--Destroy and Discard
function s.disctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,ep,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.discop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(ep,LOCATION_HAND,LOCATION_HAND)
	if not c:IsRelateToEffect(e) or ct==0 then return end
	if Duel.Destroy(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,ep,0,LOCATION_HAND,1,nil,REASON_EFFECT) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_DISCARD)
		Duel.DiscardHand(ep,Card.IsDiscardable,ct,ct,REASON_EFFECT,nil,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and e:GetHandler():GetCounter(0x300)>=5
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
