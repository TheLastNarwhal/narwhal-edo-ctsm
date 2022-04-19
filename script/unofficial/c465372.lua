--Sirenity Leucosia
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --On Summon add "Sirenity" card from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
  --Opponent's monsters must attack
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetRange(LOCATION_MZONE)
  e3:SetTargetRange(0,LOCATION_MZONE)
  e3:SetCode(EFFECT_MUST_ATTACK)
  e3:SetCondition(s.con)
  c:RegisterEffect(e3)
  --Battle protection
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e4:SetCountLimit(1)
  e4:SetValue(s.valcon)
  c:RegisterEffect(e4)
	--Control opponent's attacks
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(0,1)
	c:RegisterEffect(e5)
end
s.listed_series={0x196}
--On Summon add "Sirenity" card from Deck to hand
function s.thfilter(c)
	return c:IsSetCard(0x196) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Opponent's monsters must attack
function s.con(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
--Battle protection
function s.valcon(e,re,r,rp)
  return (r&REASON_BATTLE)~=0
end
