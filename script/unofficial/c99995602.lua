--Horus, the Ancient Deity of Sun and Moon
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(aux.NOT(Card.IsRace),RACE_ZOMBIE),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_ZOMBIE),1,99)
	c:EnableReviveLimit()
  --increase attack
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
e1:SetCategory(CATEGORY_ATKCHANGE)
e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
e1:SetRange(LOCATION_MZONE)
e1:SetCountLimit(1)
e1:SetOperation(s.atkop)
c:RegisterEffect(e1)
--token on death
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(id,1))
e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetProperty(EFFECT_FLAG_DELAY)
e2:SetCode(EVENT_TO_GRAVE)
e2:SetCountLimit(1,id)
e2:SetTarget(s.sptg)
e2:SetOperation(s.spop)
c:RegisterEffect(e2)
--special sommon
local e3=Effect.CreateEffect(c)
e3:SetDescription(aux.Stringid(id,2))
e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
e3:SetType(EFFECT_TYPE_IGNITION)
e3:SetProperty(EFFECT_FLAG_DELAY)
e3:SetRange(LOCATION_GRAVE)
e3:SetCountLimit(1)
e3:SetCondition(aux.exccon)
e3:SetTarget(s.sptg2)
e3:SetOperation(s.spop2)
c:RegisterEffect(e3)
-- destroy horus token
local e4=Effect.CreateEffect(c)
e4:SetDescription(aux.Stringid(id,3))
e4:SetCategory(CATEGORY_DESTROY)
e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
e4:SetCode(EVENT_SPSUMMON_SUCCESS)
e4:SetTarget(s.destg)
e4:SetOperation(s.desop)
c:RegisterEffect(e4)
end
--attack gain on stnby
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetValue(100)
	c:RegisterEffect(e1)
end
--token creation
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,99995603,0x194,TYPES_TOKEN,2500,2500,6,RACE_WINGEDBEAST,ATTRIBUTE_DARK) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,99995603,0x194,TYPES_TOKEN,2500,2500,6,RACE_WINGEDBEAST,ATTRIBUTE_DARK) then
    local token=Duel.CreateToken(tp,id+1)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
  end
end
-- special summon if token
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,id+1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
--destroy token if special summon
function s.desfilter(c,e,ft)
	return c:IsLocation(LOCATION_MZONE) and c:IsCode(id+1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local tc1=g1:GetFirst()
	if tc1:IsRelateToEffect(e) then
    Duel.Destroy(tc1,REASON_EFFECT)
	end
end
