--Sirenity Molpe
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
  --If battled "Sirenity" monsters you control gain ATK equal to opponent's monster
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_ATKCHANGE)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_BATTLED)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1)
  e3:SetCondition(s.atkcon)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3)
end
s.listed_series={0x196}
--Opponent's monsters must attack
function s.con(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
--Battle protection
function s.valcon(e,re,r,rp)
  return (r&REASON_BATTLE)~=0
end
--If attacked "Sirenity" monsters you control gain ATK equal to opponent's monster
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttackTarget()==e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.atkop(e,tp,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  local d=a:GetBattleTarget()
  local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x196),tp,LOCATION_MZONE,0,nil)
  if a:IsControler(1-tp) then a,d=d,a end
  for tc in aux.Next(g) do
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(d:GetAttack())
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    tc:RegisterEffect(e1)
  end
end
