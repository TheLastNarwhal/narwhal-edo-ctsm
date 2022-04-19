--Sirenity Peisinoe
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Opponent's monsters must attack
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(0,LOCATION_MZONE)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetCondition(s.con)
  c:RegisterEffect(e1)
  --Battle protection
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e2:SetCountLimit(1)
  e2:SetValue(s.valcon)
  c:RegisterEffect(e2)
  --During opponent's BP, set 1 normal trap and can activate
  local e3=Effect.CreateEffect(c)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1,id)
  --e3:SetHintTiming(0,TIMING_BATTLE_PHASE)
  e3:SetCondition(s.setcon)
  e3:SetTarget(s.settg)
  e3:SetOperation(s.setop)
  c:RegisterEffect(e3)
end
--Opponent's monsters must attack
function s.con(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
--Battle protection
function s.valcon(e,re,r,rp)
  return (r&REASON_BATTLE)~=0
end
--During opponent's BP, set 1 normal trap and can activate
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_BATTLE_STEP
end
function s.setfilter(c)
  return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
  local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
  if sc then
    Duel.SSet(tp,sc)
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e0:SetReset(RESET_EVENT+RESETS_STANDARD)
    sc:RegisterEffect(e0)
  end
end
