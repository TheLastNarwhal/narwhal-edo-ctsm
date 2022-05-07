--Acolyte of Moor
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
  --Discard, add 1 "Witchinity" monster/Extra Deck monster that lists a "Witchinity" monster as material from GY to hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_HAND)
  e2:SetCountLimit(1,{id,1})
  e2:SetCost(s.thcost)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
  --Synchro effect gain
  local e3=Effect.CreateEffect(c)
  e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_BE_MATERIAL)
  e3:SetCondition(s.effectcon)
  e3:SetOperation(s.effectop)
  c:RegisterEffect(e3)
end
s.listed_series={0x197,0x2197}
s.listed_names={465397,465399}
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
--Discard, add 1 "Witchinity" monster/Extra Deck monster that lists a "Witchinity" monster as material from GY to hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.thfilter(c)
  return (c:IsSetCard(0x197) or c:IsCode(465397,465399)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--Synchro effect gain
function s.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function s.effectop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local rc=c:GetReasonCard()
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,2))
  e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e1:SetCode(EVENT_ATTACK_ANNOUNCE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCondition(s.discon)
  e1:SetOperation(s.disop)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  rc:RegisterEffect(e1)
  local e2=e1:Clone()
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	rc:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return (Duel.GetAttacker()==c and c:GetBattleTarget()) or Duel.GetAttackTarget()==c
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetAttackTarget()
  if not tc then return end
  if tc:IsControler(tp) then tc=Duel.GetAttacker() end
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DISABLE)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
  tc:RegisterEffect(e1)
  local e2=Effect.CreateEffect(e:GetHandler())
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_DISABLE_EFFECT)
  e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
  tc:RegisterEffect(e2)
end
