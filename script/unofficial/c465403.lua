--Acolyte of Bog
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Special Summon from your hand if you control "Witchinity" or "Ritual Doll" monster
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --Discards itself, negate activation of Spell/Trap or monster effect
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e2:SetCode(EVENT_CHAINING)
  e2:SetRange(LOCATION_HAND)
  e2:SetCountLimit(1,{id,1})
  e2:SetCondition(s.negcon)
  e2:SetCost(s.negcost)
  e2:SetTarget(s.negtg)
  e2:SetOperation(s.negop)
  c:RegisterEffect(e2)
end
s.listed_series={0x197,0x2197}
--Special Summon from your hand if you control "Witchinity" or "Ritual Doll" monster
function s.spcfilter(c)
  return c:IsFaceup() and (c:IsSetCard(0x197) or c:IsSetCard(0x2197))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--Discards itself, negate activation of Spell/Trap or monster effect
function s.edfilter(c)
  return (c:IsSetCard(0x197) and not c:IsSetCard(0x2197)) or (c:IsSummonLocation(LOCATION_EXTRA) and c:IsLevel(12))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.edfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
  end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
    Duel.Destroy(eg,REASON_EFFECT)
  end
end
