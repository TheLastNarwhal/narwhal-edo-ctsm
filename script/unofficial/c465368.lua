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
  --If your opponent Summons, Normal Summon 1 "Sirenity" monster
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_SUMMON)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  e4:SetRange(LOCATION_FZONE)
  e4:SetCountLimit(1,id)
  e4:SetCondition(s.sumcon)
  e4:SetTarget(s.sumtg)
  e4:SetOperation(s.sumop)
  c:RegisterEffect(e4)
  local e5=e4:Clone()
  e5:SetCode(EVENT_SUMMON_SUCCESS)
  c:RegisterEffect(e5)
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
  local a=Duel.GetAttacker()
  local at=Duel.GetAttackTarget()
  return Duel.GetBattleDamage(tp)>0 and ((a:IsControler(tp) and a:IsSetCard(0x196)) or (at and at:IsControler(tp) and at:IsSetCard(0x196)))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  Duel.ChangeBattleDamage(ep,ev/2)
end
--If your opponent Summons, Normal Summon 1 "Sirenity" monster
function s.spcfilter(c,tp)
  return c:IsAttackPos() and not c:IsSummonPlayer(tp)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.sumfilter(c)
  return c:IsSetCard(0x196) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
  local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
  local tc=g:GetFirst()
  if tc then
    Duel.Summon(tp,tc,true,nil)
  end
end
