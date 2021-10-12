--Reflection of the Pharaoh
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
  -- special token
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(s.tkcon)
  e2:SetTarget(s.tktg)
  e2:SetOperation(s.tkop)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e3)
	--send GY and special
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
  --self destroy
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_SINGLE)
  e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e5:SetRange(LOCATION_SZONE)
  e5:SetCode(EFFECT_SELF_DESTROY)
  e5:SetCondition(s.sdcon)
  c:RegisterEffect(e5)
  end
  s.listed_series={0x194}
  s.listed_names={99995597}
--activation condition
  function s.cfilter1(c)
  	return c:IsFaceup() and c:IsSetCard(0x194)
  end
  function s.actcon(e,tp,eg,ep,ev,re,r,rp)
  	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsEnvironment(99995597)
 end
 function s.cfilter(c,tp)
	 return c:IsControler(tp) and c:IsType(TYPE_TOKEN)
 end
--token creation
 function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
 	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
 end
 function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
 		if chk==0 then return true end
 		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
 		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
 end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
 		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
 		and Duel.IsPlayerCanSpecialSummonMonster(tp,99995599,0,TYPES_TOKEN,2000,0,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then
 		local token=Duel.CreateToken(tp,99995599)
 		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP) end
end
-- destroy and ss banished
function s.desfilter(c,e,ft)
	return c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x194) and not c:IsType(TYPE_TOKEN)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 then
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
--self-destruction
function s.sdcon(e)
	return not Duel.IsEnvironment(99995597)
end
