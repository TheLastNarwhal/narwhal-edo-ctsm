--Sirenity's Cove
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)
  --During MP1, Sirenity monsters you control are unaffected by opponent
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_IMMUNE_EFFECT)
  e2:SetRange(LOCATION_FZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetCondition(s.immucon)
  e2:SetTarget(s.immutarget)
  e2:SetValue(s.immufilter)
  c:RegisterEffect(e2)
  --Halve all battle damage you take involving Sirentiy monsters you control
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
  e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  e3:SetRange(LOCATION_FZONE)
  e3:SetTargetRange(LOCATION_MZONE,0)
  e3:SetCondition(s.damcon)
  e3:SetOperation(s.damop)
  c:RegisterEffect(e3)
end
s.listed_series={0x196}
--During MP1, Sirenity monsters you control are unaffected by opponent
function s.immucon(e)
  return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.immutarget(e,c)
  return c:IsSetCard(0x196)
end
function s.immufilter(e,re)
  return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--Halve all battle damage you take involving Sirenity monsters you control
function s.damcon(e,tp,eg,ev,re,r,rp)
  local at=Duel.GetAttacker()
  local atg=Duel.GetAttackTarget()
  return at:IsControler(1-tp) and atg:IsSetCard(0x196)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  Duel.ChangeBattleDamage(ep,ev/2)
end
