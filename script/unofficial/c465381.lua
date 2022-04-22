--B.E.S. Xaerous Core
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  c:EnableCounterPermit(0x1f)
  --Fusion material
  c:EnableReviveLimit()
  Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x15),2)
  Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
  --When Special Summoned add "B.E.F." Spell from Deck to hand
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --Add Counter to "B.E.S." monster when Summoned
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_COUNTER)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetCondition(s.ctcon)
  e2:SetTarget(s.cttg)
  e2:SetOperation(s.ctop)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e3)
  --Special Summon 1 "B.E.S." monster from hand
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1,id)
  e4:SetTarget(s.sptg)
  e4:SetOperation(s.spop)
  c:RegisterEffect(e4)
  --Remove "B.E.S." counters to destroy equal number of cards
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,1))
  e5:SetCategory(CATEGORY_DESTROY)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_MZONE)
  e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e5:SetCountLimit(1,{id,1})
  e5:SetTarget(s.destg)
  e5:SetOperation(s.desop)
  c:RegisterEffect(e5)
end
s.material_setcode=0x15
s.listed_series={0x15}
s.listed_names={975299,465363}
--Fusion Summon
function s.contactfil(tp)
  return Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() end,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
  Duel.ConfirmCards(1-tp,g)
  Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
  return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
--When Special Summoned add "B.E.F." Spell from Deck to hand
function s.thfilter(c)
  return c:IsCode(975299,465363) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--Add Counter to "B.E.S." monster when Summoned
function s.ctfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(0x15) and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
  return eg and eg:IsExists(s.ctfilter,1,nil,tp) and eg:GetFirst()~=e:GetHandler()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local ec=eg:FilterCount(s.ctfilter,nil,tp)
  Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ec,0,0x1f)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=eg:Filter(s.ctfilter,nil,tp)
  local tc=g:GetFirst()
  for tc in aux.Next(g) do
    tc:AddCounter(0x1f,1)
  end
end
--Special Summon 1 "B.E.S." monster from hand
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x15) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
  if #g>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end
--Remove "B.E.S." counters to destroy equal number of cards
function s.filter(c)
  return c:IsOnField()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
  if chk==0 then return ct>0 and Duel.IsCanRemoveCounter(tp,LOCATION_MZONE,0,0x1f,1,REASON_COST)
  end
  local cc=Duel.GetCounter(tp,LOCATION_MZONE,0,0x1f)
  local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,cc,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,cc,0,0)
  Duel.RemoveCounter(tp,LOCATION_MZONE,0,0x1f,#g,REASON_COST)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  Duel.Destroy(g,REASON_EFFECT)
end
