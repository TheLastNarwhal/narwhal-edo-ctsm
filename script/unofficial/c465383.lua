--Xaerous Fortress
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),4,2)
  c:EnableReviveLimit()
  --Cannot be destroyed by battle or card effects
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e0:SetRange(LOCATION_MZONE)
  e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e0:SetValue(1)
  c:RegisterEffect(e0)
  local e1=e0:Clone()
  e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  c:RegisterEffect(e1)
  --Detach 2 mats, Special Summon 3 Light Machine w/ 1200 ATK from hand, Deck, GY
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCost(s.spcost)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
  --If sent from field to GY, double ATK of LIGHT Machine monsters you currently control
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,2))
  e3:SetCategory(CATEGORY_DRAW)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetCondition(s.atkcon)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3)
  --If a LIGHT Machine monster attacks, opponent cannot activate cards until end of Damage Step
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e4:SetCode(EFFECT_CANNOT_ACTIVATE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetTargetRange(0,1)
  e4:SetValue(s.aclimit)
  e4:SetCondition(s.actcon)
  c:RegisterEffect(e4)
end
--Detach 2 mats, Special Summon 3 Light Machine w/ 1200 ATK from hand, Deck, GY
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
  c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.spfilter(c,e,tp)
  return (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttack(1200)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  if e:GetHandler():GetSequence()<5 then ft=ft+1 end
  if chk==0 then return ft>3 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,3,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
  local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
  if #g<3 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local sg=g:Select(tp,3,3,nil)
  local tc=sg:GetFirst()
  for tc in aux.Next(sg) do
    Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
  end
  Duel.SpecialSummonComplete()
  --Can only Normal or Special Summon once for the rest of the turn
  local spc=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
  local c=e:GetHandler()
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1,0)
  e1:SetTarget(s.limittg)
  e1:SetReset(RESET_PHASE+PHASE_END)
  e1:SetLabel(spc)
  Duel.RegisterEffect(e1,tp)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_CANNOT_SUMMON)
  Duel.RegisterEffect(e2,tp)
  local e3=e1:Clone()
  e3:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
  e3:SetValue(s.countval)
  Duel.RegisterEffect(e3,tp)
  aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.limittg(e,c,tp)
  local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
  return sp-e:GetLabel()>=1
end
function s.countval(e,re,tp)
  local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
  if sp-e:GetLabel()>=1 then return 0 else return 1-sp+e:GetLabel() end
end
--If sent from field to GY, double ATK of LIGHT Machine monsters you currently control
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.atkfilter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsImmuneToEffect(e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local sg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
  local c=e:GetHandler()
  local fid=c:GetFieldID()
  local tc=sg:GetFirst()
  for tc in aux.Next(sg) do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(tc:GetAttack()*2)
    tc:RegisterEffect(e1)
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
  end
end
--If a LIGHT Machine monster attacks, opponent cannot activate cards until end of Damage Step
function s.aclimit(e,re,tp)
  return not re:GetHandler():IsImmuneToEffect(e) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
  local tc=Duel.GetAttacker()
  local tp=e:GetHandlerPlayer()
  return tc and (tc:IsRace(RACE_MACHINE) and tc:IsAttribute(ATTRIBUTE_LIGHT))
end
