--Dinowrestler Heel Turn
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Switch control of 1 Dinowrestler and 1 opponent's monster
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_CONTROL)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetTarget(s.cttg)
  e1:SetOperation(s.ctop)
  c:RegisterEffect(e1)
  --Banish from GY, add Dinowrestler card from removed to hand
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
end
s.listed_series={0x11a}
--filters for swap effect
function s.ctfilter1(c)
	return c:IsAbleToChangeControler()
end
function s.ctfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x11a) and c:IsAbleToChangeControler()
end
--swap control of 1 Dinowrestler and 1 opponent's monster
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter1,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.ctfilter2,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectTarget(tp,s.ctfilter2,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectTarget(tp,s.ctfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		Duel.SwapControl(a,b)
	end
end
--Banish from GY to add Dinowrestler card from banish to hand
function s.thfilter(c)
	return c:IsSetCard(0x11a) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
  Duel.SendtoHand(g,nil,REASON_EFFECT)
end
