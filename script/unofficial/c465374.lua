--Sirenity Teles
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Opponent's monsters must attack
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(0,LOCATION_MZONE)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetCondition(s.con)
  c:RegisterEffect(e1)
  --Battle protection
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e2:SetCountLimit(1)
  e2:SetValue(s.valcon)
  c:RegisterEffect(e2)
  --If attacked add card from opponent's GY to hand
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetCategory(CATEGORY_TOHAND)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e3:SetCode(EVENT_BATTLED)
  e3:SetCondition(s.thcon)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
end
--Opponent's monsters must attack
function s.con(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
--Battle protection
function s.valcon(e,re,r,rp)
  return (r&REASON_BATTLE)~=0
end
--If attacked add card from opponent's GY to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttackTarget()==e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.thfilter(c)
  return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_GRAVE,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,0,LOCATION_GRAVE,1,1,nil)
	if #tc>0 then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
