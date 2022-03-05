--BK Ξ Hungry Burger
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsCode,id),LOCATION_MZONE)
	--Register Ritual Summon with only "Hungry" monsters
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Cannot be Special Summoned except by Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Attacks per BP equal to amount of Grease Counters on field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.flagcheck)
	e2:SetValue(s.mulatkval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.noatkcon)
	c:RegisterEffect(e3)
	--Add counters to face-up cards equal to "Hungry" monsters own field/GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetCondition(s.addccon)
	--e4:SetTarget(s.addctg) --couldn't get to work so moved into operation
	e4:SetOperation(s.addc)
	c:RegisterEffect(e4)
--Negate effects of monsters(except "Hungry") with Grease Counters during BP
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.negtg)
	e5:SetCondition(s.negcon)
	c:RegisterEffect(e5)
	--Lose ATK equal to LVL/R/LR
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.negtg)
	e6:SetCondition(s.negcon)
	e6:SetValue(s.val)
	c:RegisterEffect(e6)
	--Inflict damage on destroy battle equal to original ATK/DEF, whichever greater
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	e7:SetCondition(s.flagcheck)
	e7:SetTarget(s.damtg)
	e7:SetOperation(s.damop)
	c:RegisterEffect(e7)
	--Destroyed & Sent to GY, shuffle to deck + search "Recipe" ritual spell
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_LEAVE_FIELD)
	e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e8:SetCondition(s.thcon)
	e8:SetTarget(s.tdtg)
	e8:SetOperation(s.tdop)
	c:RegisterEffect(e8)
end
s.listed_series={0x195}
s.counter_place_list={0x1042}
s.listed_names={99995620,99995621,30243636}
--Register Ritual Summon with only "Hungry" monsters
function s.matfilter(c)
  return not c:IsSetCard(0x195)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
  if not e then return false end
  return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:GetMaterial():IsExists(Card.IsSetCard,1,nil,0x195) and not c:GetMaterial():IsExists(s.matfilter,1,nil) then
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
  end
end
--Check to see if summoned using "Hungry" monster
function s.flagcheck(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
--Ritual only summon
function s.splimit(e,se,sp,st)
	return e:GetHandler():IsLocation(LOCATION_HAND|LOCATION_GRAVE) and (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
--Attacks equal to Grease Counters on field
function s.noatkcon(e,c)
	local cc=Duel.GetCounter(1,LOCATION_ONFIELD,LOCATION_ONFIELD,0x1042)
	return cc==0 and e:GetHandler():GetFlagEffect(id)>0
end
function s.mulatkval(e,c)
	local cc=Duel.GetCounter(1,LOCATION_ONFIELD,LOCATION_ONFIELD,0x1042)
	return math.min(4,cc-1)
end
--Add counters to face-up opp cards equal to "Hungry" monster on/in own field/GY
function s.filter(c)
	return c:IsFaceup()
end
function s.cfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSetCard(0x195) or c:IsCode(30243636)
end
----------------------------------------------------------------
--couldn't get to work so moved into operation
--function s.addctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	--if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and  chkc:IsControler(1-tp) and s.filter(chkc) end
	--if chk==0 then return ct>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	--local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	--Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,0x1042,0,0)
--end
----------------------------------------------------------------
function s.addccon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil,tp) and e:GetHandler():GetFlagEffect(id)>0
end
function s.addc(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and  chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,0x1042,0,0)
	local tc=g
	for tc in aux.Next(g) do
		tc:AddCounter(0x1042,1)
	end
end
--Negate effects of monsters(except "Hungry") with Grease Counters during BP only
function s.negcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and e:GetHandler():GetFlagEffect(id)>0
end
function s.negtg(e,c)
	return c:GetCounter(0x1042)>0 and not c:IsSetCard(0x195)
end
--Adjust Attack of non-Hungry monsters w/ Grease Counter during BP
function s.atkfilter(c)
	return c:IsFaceup() and c:IsLinkMonster()
end
function s.val(e,c)
	if c:IsType(TYPE_LINK) then
		return c:GetLink()*-500
	elseif c:IsType(TYPE_XYZ) then
		return c:GetRank()*-200
	else
		return c:GetLevel()*-200
	end
end
--Inflict damage on destroy battle equal to original ATK/DEF, whichever greater
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	local atk=math.max(tc:GetBaseAttack(),tc:GetBaseDefense())
	if atk<0 then atk=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
--Destroyed & Sent to GY, shuffle to deck + search "Recipe" ritual spell
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.tdfilter(c,tp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(99995620,99995621)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) and chkc==c end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	if not Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_DECK) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
