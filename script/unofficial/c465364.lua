--Sirenity Thelxiope
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
  --If attacked take control of attacking monster
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_CONTROL)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_BATTLED)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCondition(s.ctrlcon)
  e3:SetOperation(s.ctrlop)
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
--If attacked take control of attacking monster
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttackTarget()==e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetAttacker()
  if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return
  end
  Duel.GetControl(tc,tp)
end
