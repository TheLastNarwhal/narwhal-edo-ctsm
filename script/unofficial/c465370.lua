--Sirenity's Seduction
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Activation - Special Summon from opponent's hand to their field
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetHintTiming(0,TIMING_END_PHASE)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --Activation - Change battle position of def monster opponent controls
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_ACTIVATE)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCategory(CATEGORY_POSITION)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetHintTiming(0,TIMING_END_PHASE)
  e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e2:SetCondition(s.condition)
  e2:SetTarget(s.postg)
  e2:SetOperation(s.posop)
  c:RegisterEffect(e2)
end
s.listed_series={0x196}
--Activation - Special Summon from opponent's hand to their field
function s.posfilter(c)
  return c:IsAttackPos() and c:IsSetCard(0x196)
end
function s.condition(e,c)
  local c=e:GetHandler()
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.posfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
  if #g>0 and Duel.GetLocationCount(1-tp,0,LOCATION_MZONE,tp)>0 then
    Duel.ConfirmCards(tp,g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
    local tg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
    local tc=tg:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,1-tp,true,false,POS_FACEUP_ATTACK) then
      Duel.ShuffleHand(1-tp)
    end
    Duel.SpecialSummonComplete()
  end
end
--Activation - Change battle position of def monster opponent controls
function s.filter(c)
  return c:IsCanChangePosition() and c:IsDefensePos()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
  if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
  local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsDefensePos() then
    Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
  end
end
