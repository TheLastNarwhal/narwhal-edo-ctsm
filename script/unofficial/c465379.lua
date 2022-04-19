--Sansirenity Scylla
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Fusion material
  c:EnableReviveLimit()
  Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x196),2)
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
