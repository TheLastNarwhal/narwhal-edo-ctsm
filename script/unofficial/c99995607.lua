--Hathor, the Ancient Deity of Devotion
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
  --effect add 'archetype' card from deck to hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetTarget(s.tg)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
  c:RegisterEffect(e3)
  local e4=e2:Clone()
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e4)
	--token
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,})
	e5:SetTarget(s.sptg2)
	e5:SetOperation(s.spop2)
	c:RegisterEffect(e5)
--ss from GY when control Hamunaptra
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,3))
  e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e6:SetRange(LOCATION_GRAVE)
  e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e6:SetCountLimit(1,id)
  e6:SetCondition(s.spcon2)
  e6:SetTarget(s.sptg)
  e6:SetOperation(s.spop)
  c:RegisterEffect(e6)
end
s.listed_series={0x194}
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x194)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and	Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
--add card to hand
s.listed_names={99995596,99995600}
function s.cfilter1(c)
	return c:IsCode(99995600) or (c:IsLocation(LOCATION_REMOVED) and c:IsCode(99995596)) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
  end
end
--token creation
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,99995599,0x194,TYPES_TOKEN,2000,0,4,RACE_ZOMBIE,ATTRIBUTE_DARK) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,99995599,0x194,TYPES_TOKEN,2000,0,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then
    local token=Duel.CreateToken(tp,99995599)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
  end
end
--ss from GY if field is Hamunaptra
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(99995597,tp,LOCATION_FZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
