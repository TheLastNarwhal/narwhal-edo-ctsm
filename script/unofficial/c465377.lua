--Sirenity's Wiles
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Return "Sirenity" monster to hand, Special Summon "Sirenity" with different name from hand/GY
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetHintTiming(0,TIMING_END_PHASE)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
end
s.listed_series={0x196}
--Return "Sirenity" monster to hand, Special Summon "Sirenity" with different name from hand/GY
function s.thfilter(c,e,tp)
  return c:IsFaceup() and c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToHandAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,tc)
  return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
  if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.thfilter(chkc,e,tp) and chkc~=c end
  if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,c,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
  local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,c,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc)
    if #g~=0 then
      Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
  end
end
