--Sansirenity Scylla
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  c:EnableReviveLimit()
  --Fusion material
  Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x196),2,99)
  --Destroy cards on the field equal to the amount of materials used for Fusion Summon
  local e0=Effect.CreateEffect(c)
  e0:SetCategory(CATEGORY_DESTROY)
  e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e0:SetCode(EVENT_SPSUMMON_SUCCESS)
  e0:SetCondition(s.descon)
  e0:SetTarget(s.destg)
  e0:SetOperation(s.desop)
  c:RegisterEffect(e0)
  --Unaffected by opponent's card effects during the BP
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_IMMUNE_EFFECT)
  e1:SetCondition(s.immucon)
  e1:SetValue(s.efilter)
  c:RegisterEffect(e1)
  --Gains ATK equal to cards in opponent's hand
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_UPDATE_ATTACK)
  e2:SetValue(s.value)
  c:RegisterEffect(e2)
  --Can attack up to the number of cards in opponent's hand +1
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_EXTRA_ATTACK)
  e3:SetValue(s.mulatkval)
  c:RegisterEffect(e3)
end
s.listed_series={0x196}
--Destroy cards on the field equal to the amount of materials used for Fusion Summon
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) end
	local ct=e:GetHandler():GetMaterialCount()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp, Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil,TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.Destroy(g,REASON_EFFECT)
end
--Gains ATK equal to cards in opponent's hand
function s.value(e,c)
  return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_HAND)*200
end
--Unaffected by opponent's card effects during the BP
function s.immucon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--Can attack up to the number of cards in opponent's hand +1
function s.mulatkval(e,c)
	local cc=Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_HAND)
	return math.max(cc)
end
