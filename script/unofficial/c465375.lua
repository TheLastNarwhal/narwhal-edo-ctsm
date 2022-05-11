--Sirenity Parthenope
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
  --Can attack directly
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_DIRECT_ATTACK)
  c:RegisterEffect(e3)
  --When inflicts battle dam, change 1 opponent's def monsters to atk
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_POSITION)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e4:SetCode(EVENT_BATTLE_DAMAGE)
  e4:SetCondition(s.poscon)
  e4:SetTarget(s.postg)
  e4:SetOperation(s.posop)
  c:RegisterEffect(e4)
end
--Opponent's monsters must attack
function s.con(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
--Battle protection
function s.valcon(e,re,r,rp)
  return (r&REASON_BATTLE)~=0
end
--When inflicts battle dam, change 1 opponent's def monsters to atk
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp
end
function s.filter(c)
  return c:IsCanChangePosition() and c:IsDefensePos()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
  if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
  local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
  if #g>0 then
    Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
    local tc=g:GetFirst()
      if tc:IsAttackPos() then
      --Cannot change its battle position
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetDescription(3313)
      e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD)
      tc:RegisterEffect(e1)
    end
  end
end
