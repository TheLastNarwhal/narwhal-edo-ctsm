--Festering Newt
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --If this card is Tributed or destroyed: You can target 1 monster your opponent controls; it loses 1500 ATK, then if its ATK has been reduced to 0 as a result, destroy it.
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_RELEASE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e1:SetCondition(s.atkcon1)
  e1:SetTarget(s.atktg)
  e1:SetOperation(s.atkop1)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EVENT_DESTROYED)
  c:RegisterEffect(e2)
  --Above is for -1500 and below is for -3000
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_RELEASE)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e3:SetCondition(s.atkcon2)
  e3:SetTarget(s.atktg)
  e3:SetOperation(s.atkop2)
  c:RegisterEffect(e3)
  local e4=e3:Clone()
  e4:SetCode(EVENT_DESTROYED)
  c:RegisterEffect(e4)
end
s.listed_names={465391,465386}
--Filter for -3000 ATK
function s.filter1(c)
  return c:IsCode(465391)
end
--Function for -1500 ATK
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
  return not Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
end
function s.atkfilter(c)
  return c:IsPosition(POS_FACEUP)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
  local g=Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetTargetCard(g)
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  local preatk=tc:GetAttack()
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(-1500)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  tc:RegisterEffect(e1)
  if preatk~=0 and tc:GetAttack()==0 then
    Duel.BreakEffect()
    Duel.Destroy(tc,REASON_EFFECT)
  end
end
--Filter for -3000 ATK
function s.filter2(c)
  return c:IsFaceup() and c:IsCode(465391)
end
--Function for -3000 ATK
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  local preatk=tc:GetAttack()
  local e2=Effect.CreateEffect(e:GetHandler())
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_UPDATE_ATTACK)
  e2:SetValue(-3000)
  e2:SetReset(RESET_EVENT+RESETS_STANDARD)
  tc:RegisterEffect(e2)
  if preatk~=0 and tc:GetAttack()==0 then
    Duel.BreakEffect()
    Duel.Destroy(tc,REASON_EFFECT)
  end
end
