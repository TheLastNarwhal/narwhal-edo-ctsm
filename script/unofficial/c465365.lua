--Sirenity Aglaopheme
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Special Summon and change attack target
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_ATTACK_ANNOUNCE)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetRange(LOCATION_HAND)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon)
  e1:SetCost(s.cost)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
end
s.listed_series={0x196}
--Special Summon and change attack target
function s.cfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x196)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x196) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
  if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
    local tc=Duel.GetOperatedGroup():GetFirst()
    local a=Duel.GetAttacker()
    local ag=a:GetAttackableTarget()
    if a:CanAttack() and not a:IsImmuneToEffect(e) and ag:IsContains(tc) then
      Duel.BreakEffect()
      Duel.ChangeAttackTarget(tc)
    end
  end
end
