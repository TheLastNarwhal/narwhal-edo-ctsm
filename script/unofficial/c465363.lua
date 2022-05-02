--B.E.F. Deployment
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activate/Add card to hand
  local e0=Effect.CreateEffect(c)
  e0:SetDescription(aux.Stringid(id,0))
  e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e0:SetOperation(s.thop)
  c:RegisterEffect(e0)
  --Special Summon 1 B.E.S. then place 3 counters on it
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.sumcon)
  e1:SetTarget(s.sstg)
  e1:SetOperation(s.ssop)
  c:RegisterEffect(e1)
  --Prevent destruction by effects
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_DESTROY_REPLACE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTarget(s.reptg)
  e2:SetValue(s.repval)
  e2:SetOperation(s.repop)
  c:RegisterEffect(e2)
end
s.listed_names={66947414,975299,66947414}
s.listed_series={0x15}
--Add card to hand
function s.thfilter(c)
  return c:IsCode(66947414,975299) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
  if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
  end
end
--Check if current phase is a Main Phase
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsMainPhase()
end
--Special Summon 1 B.E.S. then place 3 counters on it
function s.ssfilter(c,e,sp)
  return c:IsSetCard(0x15) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local tc=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
  if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
    tc:AddCounter(0x1f,3)
  end
end
--Prevent destruction by opponent's effects
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsSetCard(0x15) or c:IsCode(975299) or c:IsCode(66947414) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
