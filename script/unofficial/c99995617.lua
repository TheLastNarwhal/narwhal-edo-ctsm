--Earthbound Immortal Xeyal
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x21),LOCATION_MZONE)
--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,15187079,46263076,69931927,33537328,79798060,10875327,41181774)
--spsummon condition/restriction
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
e1:SetCode(EFFECT_SPSUMMON_CONDITION)
e1:SetValue(aux.fuslimit)
c:RegisterEffect(e1)
--cannot be destroyed by opponent
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e2:SetRange(LOCATION_MZONE)
e2:SetValue(aux.tgoval)
c:RegisterEffect(e2)
local e3=e2:Clone()
e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
e3:SetValue(s.tgvalue)
c:RegisterEffect(e3)
--self destroy
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_SINGLE)
e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e4:SetRange(LOCATION_MZONE)
e4:SetCode(EFFECT_SELF_DESTROY)
e4:SetCondition(s.sdcon)
c:RegisterEffect(e4)
--extra attack
local e5=Effect.CreateEffect(c)
e5:SetType(EFFECT_TYPE_SINGLE)
e5:SetCode(EFFECT_EXTRA_ATTACK)
e5:SetValue(2)
c:RegisterEffect(e5)
--destroy all cards on battle death
local e6=Effect.CreateEffect(c)
e6:SetCategory(CATEGORY_DESTROY)
e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e6:SetCode(EVENT_DESTROYED)
e6:SetProperty(EFFECT_FLAG_DELAY)
e6:SetCondition(function(_,_,_,_,_,_,r) return (r&(REASON_BATTLE))~=0 end)
e6:SetTarget(s.destg)
e6:SetOperation(s.desop)
c:RegisterEffect(e6)
end
--self destroy
s.listed_series={0x21}
function s.sdcon(e)
	return e:GetHandler() and not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
--immunity target
function s.tgvalue(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
--destroy all cards
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
