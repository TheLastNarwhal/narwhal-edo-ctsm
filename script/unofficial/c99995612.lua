--Diviner of the Gods
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from deck or hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
  --Additional Normal Summon
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
  e2:SetTarget(s.extg)
  c:RegisterEffect(e2)
end
--Special Summon from hand or deck
s.listed_names={99995598,99995607,99995606,99995597}
s.listed_series={0x194}
function s.spfilter(c,e,tp)
	return c:IsCode(99995598,99995607,99995606) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.spcon(e)
  return Duel.IsEnvironment(99995597,tp,LOCATION_FZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
--aditional normal summon
function s.extg(e,c)
	return c:IsSetCard(0x194)
end
