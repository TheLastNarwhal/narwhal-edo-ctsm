--Sirenity Himerope
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
  --If attacked gain HP equal to attacking monster
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_RECOVER)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e3:SetCode(EVENT_BATTLED)
  e3:SetCondition(s.reccon)
  e3:SetTarget(s.rectg)
  e3:SetOperation(s.recop)
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
--If attacked gain HP equal to attacking monster
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttackTarget()==e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local a=Duel.GetAttacker()
  local d=a:GetBattleTarget()
  if a:IsControler(1-tp) then a,d=d,a end
  local rec=d:GetAttack()
  if rec<0 then rec=0 end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(rec)
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  if Duel.Recover(p,d,REASON_EFFECT) then
    local a=Duel.GetAttacker()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(0)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    a:RegisterEffect(e1)
  end
end
