--Anubis, the Ancient Deity of Judgement
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x194),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
--cannot be targeted if field is Hamunaptra
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.tgoval)
	c:RegisterEffect(e1)
	--Cannot be destroyed if field is Hamunaptra
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indoval)
	c:RegisterEffect(e2)
	--banish monster in GY otherwise shuffle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--cannot be targeted or destroyed if field is Hamunaptra
s.listed_names={99995597}
function s.tgoval(e,tp,eg,ep,ev,re,r,rp)
	return tp~=e:GetHandlerPlayer()
	and Duel.IsEnvironment(99995597,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.indoval(e,tp,eg,ep,ev,re,r,rp)
	return tp~=e:GetHandlerPlayer()
	and Duel.IsEnvironment(99995597,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
--banish monster in GY otherwise shuffle
function s.filter(c)
	return c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
		if sg:GetFirst():IsType(TYPE_MONSTER) then
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		elseif
			sg:GetFirst():IsType(TYPE_SPELL+TYPE_TRAP) then
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
end
