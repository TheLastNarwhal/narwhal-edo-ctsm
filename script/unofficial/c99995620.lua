--Hot Dog Recipe
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
--Ritual Summon w/ opponent's monsters if counter
local e1=Ritual.AddProcGreater({
  handler=c,
  filter=aux.FilterBoolFunction(Card.IsSetCard,0x195),
  location=LOCATION_HAND,
  extrafil=s.extramat
})
c:RegisterEffect(e1)
--Return "Hungry" ritual monster from GY to deck, draw 1
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
e2:SetType(EFFECT_TYPE_IGNITION)
e2:SetRange(LOCATION_GRAVE)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
e2:SetCountLimit(1,id)
e2:SetTarget(s.tdtg)
e2:SetOperation(s.tdop)
c:RegisterEffect(e2)
end
s.listed_names={30243636,99995619}
s.listed_series={0x195}
s.counter_place_list={0x1042}
--Allows use of opponent's monsters w/ counter
function s.matfilter(c)
  return c:HasLevel() and c:GetCounter(0x1042)>0
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
  return Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE,nil)
end
--Return "Hungry" ritual monster from GY to deck, draw 1
function s.costfilter(c)
  return c:IsCode(30243636) or c:IsSetCard(0x195) and c:IsType(TYPE_RITUAL) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() and chkc:IsControler(tp) and chkc~=e:GetHandler() and Duel.IsPlayerCanDraw(tp,1) end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		and Duel.IsExistingTarget(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
	end
end
