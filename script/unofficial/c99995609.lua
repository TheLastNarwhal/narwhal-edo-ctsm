--The Eyes of Ra
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
-- activate
  local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
--gain HP off of token summon
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(s.reccon1)
  e2:SetTarget(s.rectg1)
  e2:SetOperation(s.recop1)
  c:RegisterEffect(e2)
  --destroy
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetCategory(CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(s.descon)
  e3:SetTarget(s.destg)
  e3:SetOperation(s.desop)
  e3:SetCountLimit(1)
  c:RegisterEffect(e3)
  --negate first monster effect
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e4:SetCode(EVENT_CHAIN_SOLVING)
  e4:SetRange(LOCATION_SZONE)
  e4:SetCountLimit(1)
  e4:SetCondition(s.discon)
  e4:SetOperation(s.disop)
  c:RegisterEffect(e4)
  --return cards to grave - draw 1
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,0))
  e5:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_SZONE)
  e5:SetCountLimit(1)
  e5:SetCost(s.thcon)
  e5:SetTarget(s.thtg)
  e5:SetOperation(s.thop)
  c:RegisterEffect(e5)
end
--conditions for effects
s.listed_names={99995598,99995606,99995607}
function s.adfilter(c)
	return c:IsFaceup() and c:IsCode(99995598,99995606,99995607)
end
function s.adcount(tp)
	return Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetCode)
end
--gain HP
function s.filter(c,sp)
	if c:IsLocation(LOCATION_MZONE,LOCATION_MZONE) then
		return c:IsFaceup() and c:IsLocation(LOCATION_MZONE,LOCATION_MZONE) and c:GetSummonPlayer()==sp
	end
end
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp) and s.adcount(tp)>0
		and (not re or (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS)))
end
function s.rectg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.recop1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,1-tp)
	if #g>0 then
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  	if Duel.Recover(p,d,REASON_EFFECT)~=0 then
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
--destroy
function s.filter2(c)
	return c:IsLocation(LOCATION_ONFIELD)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
  return s.adcount(tp)>1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	  if tc and tc:IsRelateToEffect(e) then
		  Duel.Destroy(tc,REASON_EFFECT)
	  end
  end
  --negate first monster effect
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp and s.adcount(tp)>2
	and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
--return cards and draw
function s.filter2(c)
	return c:IsAbleToDeck()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,99995605),tp,LOCATION_MZONE,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE,LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter2(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
