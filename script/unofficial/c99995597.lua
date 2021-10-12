--Hamunaptra, Temple of the Gods
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
--Activate - send card from deck to grave
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,1))
e1:SetCategory(CATEGORY_TOGRAVE)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
--destroy and special
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(id,2))
e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
e2:SetType(EFFECT_TYPE_IGNITION)
e2:SetRange(LOCATION_FZONE)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
e2:SetCountLimit(1)
e2:SetTarget(s.destg)
e2:SetOperation(s.desop)
c:RegisterEffect(e2)
--destroy replace
local e3=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(id,3))
e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e3:SetCode(EFFECT_DESTROY_REPLACE)
e3:SetRange(LOCATION_FZONE)
e3:SetTarget(s.reptg)
e3:SetValue(s.repval)
c:RegisterEffect(e3)
end
--send to grave
s.listed_series={0x194}
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x194) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
--destroy and ss from grave
function s.desfilter(c,e,ft)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_TOKEN)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 then
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
--destroy replace - banish from deck
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_FZONE)
		and c:GetCode()==id and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
s.listed_series={0x194}
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x194) and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.repfilter,nil,tp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		if chk==0 then return ct>0 and g:IsExists(Card.IsAbleToRemove,ct,nil,tp,POS_FACEUP) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
	local tg=g:Select(tp,ct,ct,nil)
		Duel.DisableShuffleCheck()
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
