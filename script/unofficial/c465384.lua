--Full Frontal Assault! We're Counting on You!
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Target 1 LIGHT Machine with original ATK 1200, can attack twice
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.mulatkcon)
	e1:SetTarget(s.mulatktg)
	e1:SetOperation(s.mulatkop)
	c:RegisterEffect(e1)
  --Banish from GY, until end of turn LIGHT Machine monsters w/ original ATK 1200 cannot be destroyed
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCondition(aux.exccon)
  e2:SetCost(aux.bfgcost)
  e2:SetOperation(s.indop)
  c:RegisterEffect(e2)
end
--Target 1 LIGHT Machine with original ATK 1200, can attack twice
function s.mulatkcon(e,tp,eg,ep,ev,re,r,rp)
  local ph=Duel.GetCurrentPhase()
  return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and (ph~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.filter(c)
  return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:GetBaseAttack(1200))
end
function s.mulatktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
  if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
  Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.mulatkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(3000)
    e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
  end
end
--Banish from GY, until end of turn LIGHT Machine monsters w/ original ATK 1200 cannot be destroyed
function s.indop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  --Cannot be destroyed by battle or card effect
  local e1=Effect.CreateEffect(c)
  --e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e1:SetTarget(s.indtg)
  e1:SetValue(1)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
  Duel.RegisterEffect(e1,tp)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  Duel.RegisterEffect(e2,tp)
  --aux.RegisterClientHint(c,nil,tp,1,1,aux.Stringid(id,0),nil)
end
function s.indtg(e,c)
  return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:GetBaseAttack(1200))
end
