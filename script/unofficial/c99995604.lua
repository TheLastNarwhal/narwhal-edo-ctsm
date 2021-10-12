--Sphinx of Endless Riddles
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
--effect add 'archetype' card or 'reborn' from GY to Hand on ss
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
e1:SetCode(EVENT_SPSUMMON_SUCCESS)
e1:SetTarget(s.tg)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
--Activate call card topdeck
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
e2:SetType(EFFECT_TYPE_IGNITION)
e2:SetRange(LOCATION_MZONE)
e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
e2:SetTarget(s.target)
e2:SetOperation(s.operation)
c:RegisterEffect(e2)
-- banish and send to deck and ss token
local e3=Effect.CreateEffect(c)
e3:SetDescription(aux.Stringid(id,0))
e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TODECK)
e3:SetType(EFFECT_TYPE_QUICK_O)
e3:SetCode(EVENT_FREE_CHAIN)
e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
e3:SetRange(LOCATION_GRAVE)
e3:SetCountLimit(1,id)
e3:SetCondition(aux.exccon)
e3:SetCost(aux.bfgcost)
e3:SetTarget(s.tktg)
e3:SetOperation(s.tkop)
c:RegisterEffect(e3)
end
--add card to hand
s.listed_names={83764718}
s.listed_series={0x2194}
function s.cfilter1(c)
	return c:IsSetCard(0x2194) or c:IsCode(83764718) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    --limit on card use
    local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(tc:GetCode())
end
--call card name - add to hand - or ss
s.listed_series={0x194}
function s.filter(c,e,tp)
	return c:IsSetCard(0x194) and not c:IsSetCard(0x2194) and c:GetCode()~=id
  and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			local b1=sc:IsAbleToHand()
			local b2=sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local op=0
			if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
			else op=Duel.SelectOption(tp,aux.Stringid(id,2))+1 end
			if op==0 then
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sc)
			else
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			Duel.DisableShuffleCheck()
		end
		Duel.ShuffleHand(tp)
	else
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- banish / send deck / token
function s.filter2(c,e,tp)
	return c:IsSetCard(0x2194) and c:IsAbleToDeck()
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter2(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK)
  and Duel.IsPlayerCanSpecialSummonMonster(tp,99995599,0,TYPES_TOKEN,2000,0,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then
    local token=Duel.CreateToken(tp,99995599)
 		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP) end
end
