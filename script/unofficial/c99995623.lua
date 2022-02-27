 --Dinowrestler Tag Out
 --Scripted by Narwhal
 local s,id=GetID()
 function s.initial_effect(c)
 	--Add Dinowrestler from deck to hand
 	local e1=Effect.CreateEffect(c)
 	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
 	e1:SetType(EFFECT_TYPE_ACTIVATE)
 	e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id)
 	e1:SetOperation(s.activate)
 	c:RegisterEffect(e1)
  --Return 1 Dinowrestler to hand, SS Dinowrestler from hand
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1,{id,2})
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
  --Banish from GY to activate Dinowrestler spell from Deck
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_GRAVE)
  e3:SetCountLimit(1,{id,3})
  e3:SetCost(aux.bfgcost)
  e3:SetTarget(s.actg)
  e3:SetOperation(s.acop)
  c:RegisterEffect(e3)
end
s.listed_names={15543940,90173539}
s.listed_series={0x11a}
--add Dinowrestler card from deck to hand
function s.filter(c,e,tp)
	return c:IsSetCard(0x11a) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
  end
end
--Return  Dinowrestler monster to hand, ss Dinowrestler from hand
function s.thfilter(c,e,tp)
  return c:IsFaceup() and c:IsSetCard(0x11a) and c:IsLocation(LOCATION_MZONE) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x11a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp,ft) end
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			local
      g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
  		if #g>0 then
  			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    end
  end
end
--Banish self from GY then activate Dinowrestler spell from Deck
function s.cfilter(c,tp)
	return (c:IsCode(90173539) or c:IsSetCard(0x11a)) and c:IsType(TYPE_SPELL) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true) or (c:IsCode(15543940) or c:IsSetCard(0x11a)) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
  if tc:IsType(TYPE_FIELD) then
    aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
  elseif
  tc:GetType()==TYPE_SPELL+TYPE_CONTINUOUS then
    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone)
  else
    if tc:GetType()==TYPE_SPELL or tc:GetType()==TYPE_SPELL+TYPE_QUICKPLAY then
      Duel.SSet(tp,tc)
  		if tc:IsType(TYPE_QUICKPLAY) then
  			local e1=Effect.CreateEffect(e:GetHandler())
  			e1:SetType(EFFECT_TYPE_SINGLE)
  			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
  			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
  			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  			tc:RegisterEffect(e1)
      end
    end
  end
end
