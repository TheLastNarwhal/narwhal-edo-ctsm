--Sirenity's Song
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Activation - activate "Sirenity's Cove" from Deck
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetHintTiming(0,TIMING_END_PHASE)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  --Activation - Special Summon "Sirenity" from Deck
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_ACTIVATE)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e2:SetCondition(s.spcon)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end
s.listed_names={465368}
--Activation - activate "Sirenity's Cove" from Deck
function s.filter(c,tp)
	return c:IsCode(465368) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
--Activation - Special Summon "Sirenity" from Deck
function s.posfilter(c)
  return c:IsAttackPos()
end
function s.spcon(e,c)
  local c=e:GetHandler()
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.posfilter,c:GetControler(),0,LOCATION_MZONE,1,nil)
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
  if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
  end
end
