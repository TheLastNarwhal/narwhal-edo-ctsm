--Warlock of the Witchinity
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Special Summon from your hand if you control "Witchinity" or "Ritual Doll" monster
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --Name becomes "Witchinity of the Moor" while on the field on in GY
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetCode(EFFECT_CHANGE_CODE)
  e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
  e2:SetValue(465387)
  c:RegisterEffect(e2)
  --On Summon add "Acolyte" monster from Deck to hand
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e3:SetCode(EVENT_SUMMON_SUCCESS)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  e3:SetCountLimit(1,{id,1})
  c:RegisterEffect(e3)
  local e4=e3:Clone()
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e4)
  --If sent from the field to GY, can add 1 "Witchinity" card from GY to hand
  local e5=Effect.CreateEffect(c)
  e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e5:SetCode(EVENT_TO_GRAVE)
  e5:SetCountLimit(1,{id,2})
  e5:SetCondition(s.gythcon)
  e5:SetTarget(s.gythtg)
  e5:SetOperation(s.gythop)
  c:RegisterEffect(e5)
end
s.listed_series={0x197,0x2197,0x198}
s.listed_names={465387,27103517}
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
--On Summon add "Acolyte" monster from Deck to hand
function s.thfilter(c)
  return (c:IsSetCard(0x198) or c:IsCode(27103517)) and c:IsAbleToHand()
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
--If sent from the field to GY, can add 1 "Witchinity" card from GY to hand
function s.gythcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.gythfilter(c)
  return (c:IsSetCard(0x197) and not c:IsOriginalCode(id)) and c:IsAbleToHand()
end
function s.gythtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.gythfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.gythop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gythfilter),tp,LOCATION_GRAVE,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
