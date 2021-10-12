--Sekhmet, the Ancient Deity of Vengeance
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--atk increase per token
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
  --attack twice
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_EXTRA_ATTACK)
  e2:SetValue(1)
  c:RegisterEffect(e2)
  --bounce to hand during battle
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetCategory(CATEGORY_TOHAND)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_BATTLE_START)
  e3:SetCountLimit(1)
  e3:SetCondition(s.tgcon)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
  --Destroy 1 card from each side of the field
  local e4=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_DESTROY)
  e4:SetType(EFFECT_TYPE_QUICK_O)
  e4:SetCode(EVENT_FREE_CHAIN)
  e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1)
  e4:SetCondition(s.descon)
  e4:SetTarget(s.destg)
  e4:SetOperation(s.desop)
  c:RegisterEffect(e4)
end
--atk increase
function s.val(e,c)
  return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsCode,99995599),c:GetControler(),LOCATION_MZONE,0,nil)*300
end
--bounce to hand during battle
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,99995605)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
	if tc and tc:IsRelateToBattle() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
--destroy your card and opponent card
function s.descon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,99995605)
end
function s.desfilter(c,e,ft)
	return c:IsLocation(LOCATION_MZONE) and c:IsCode(99995599)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
  if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	--local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	--if chk==0 then return ft>-1
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
  local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
  g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT)
  end
end
