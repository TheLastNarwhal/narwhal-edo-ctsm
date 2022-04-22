--B.E.S. Shadowdancer
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  c:EnableCounterPermit(0x1f)
  --If "Boss Rush" is on your field, Special Summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --When Summoned add "B.E.S." monster or "B.E.F." Spell from Deck to hand
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetCountLimit(1,{id,1})
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e3)
  --Destroy this card, Special Summon 1 B.E.S. from GY
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetCode(EFFECT_FLAG_DELAY)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1,{id,2})
  e4:SetTarget(s.sstg)
  e4:SetOperation(s.ssop)
  c:RegisterEffect(e4)
end
s.listed_names={975299,465363,66947414}
s.listed_series={0x15}
--If "Boss Rush" is on your field, Special Summon from hand
function s.spfilter(c)
  return c:IsFaceup() and c:IsCode(66947414)
end
function s.spcon(e,c)
  if c==nil then return true end
  local tp=c:GetControler()
  return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil) and Duel.IsCanRemoveCounter(tp,LOCATION_MZONE,0,0x1f,1,REASON_COST)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
  Duel.RemoveCounter(tp,LOCATION_MZONE,0,0x1f,1,REASON_COST)
end
--When Summoned add "B.E.S." monster or "B.E.F." Spell from Deck to hand
function s.thfilter(c)
	return (c:IsCode(975299,465363) or c:IsSetCard(0x15) and not c:IsCode(id)) and c:IsAbleToHand()
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
--Destroy this card, Special Summon 1 B.E.S. from GY
function s.ssfilter(c,e,sp)
  return c:IsSetCard(0x15) and c:IsCanBeSpecialSummoned(e,0,sp,false,false) and not c:IsCode(id)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk) e:GetHandler():IsLocation(LOCATION_ONFIELD)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and e:GetHandler():IsLocation(LOCATION_ONFIELD) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local
  tc=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
  if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
    Duel.BreakEffect()
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
  end
end
