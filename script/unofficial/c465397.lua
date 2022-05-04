--Witch-Maw, the Unholy Abomination
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Synchro Summon
  Synchro.AddMajesticProcedure(c,aux.FilterBoolFunction(Card.IsCode,465387),true,aux.FilterBoolFunction(Card.IsSetCard,0x197),true,Synchro.NonTuner(nil),false)
  c:EnableReviveLimit()
  --Must first be Synchro Summoned
  local e0=Effect.CreateEffect(c)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_SPSUMMON_CONDITION)
  e0:SetValue(aux.synlimit)
  c:RegisterEffect(e0)
  --Negate monster effect, banish, gain ATK and place "Witching Hour Counter"
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_COUNTER)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_CHAINING)
  e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.negcon)
  e1:SetTarget(s.negtg)
  e1:SetOperation(s.negop)
  c:RegisterEffect(e1)
  --1+ Witching Hour Counter - Cannot be destroyed by battle
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e2:SetCondition(s.countcon1)
  e2:SetValue(1)
  c:RegisterEffect(e2)
  --2+ Witching Hour Counter - Possesion cannot switch
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
  e3:SetCondition(s.countcon2)
  c:RegisterEffect(e3)
  --3+ Witching Hour Counter - Gains 500 ATK/DEF for each counter
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCode(EFFECT_UPDATE_ATTACK)
  e4:SetCondition(s.countcon3)
  e4:SetValue(s.atkval)
  c:RegisterEffect(e4)
  --4+ Witching Hour Counter - Target 1 card in your GY, shuffle into deck, draw 1
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,1))
  e5:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
  e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCountLimit(1,{id,1})
  e5:SetCondition(s.countcon4)
  e5:SetTarget(s.shufftg)
  e5:SetOperation(s.shuffop)
  c:RegisterEffect(e5)
  --5+ Witching Hour Counter - Unaffected by other cards' effects
  local e6=Effect.CreateEffect(c)
  e6:SetType(EFFECT_TYPE_SINGLE)
  e6:SetCode(EFFECT_IMMUNE_EFFECT)
  e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCondition(s.countcon5)
  e6:SetValue(s.efilter)
  c:RegisterEffect(e6)
  --6+ Witching Hour Counter - Full Fiber Jar reset for opponent, including banished/ED pends
  local e7=Effect.CreateEffect(c)
  e7:SetDescription(aux.Stringid(id,2))
  e7:SetCategory(CATEGORY_TODECK)
  e7:SetRange(LOCATION_MZONE)
  e7:SetType(EFFECT_TYPE_QUICK_O)
  e7:SetCode(EVENT_FREE_CHAIN)
  e7:SetCountLimit(1,{id,2})
  e7:SetCondition(s.countcon6)
  e7:SetCost(s.fiberjarcost)
  e7:SetTarget(s.fiberjartg)
  e7:SetOperation(s.fiberjarop)
  c:RegisterEffect(e7)
end
s.counter_place_list={0x1044}
s.listed_series={0x197}
--Negate monster effect, banish, gain ATK and place "Witching Hour Counter"
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local rc=re:GetHandler()
  return re:IsActiveType(TYPE_MONSTER) and rc~=c and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
  end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local rc=re:GetHandler()
  if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)~=0 and rc:GetBaseAttack()>=0
  and c:IsRelateToEffect(e) and c:IsFaceup() then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
    e1:SetValue(rc:GetBaseAttack())
    c:RegisterEffect(e1)
  end
  c:AddCounter(0x1044,1)
end
--1+ Witching Hour Counter - Cannot be destroyed by battle
function s.countcon1(e)
  return e:GetHandler():GetCounter(0x1044)>0
end
--2+ Witching Hour Counter - Possesion cannot switch
function s.countcon2(e)
  return e:GetHandler():GetCounter(0x1044)>1
end
--3+ Witching Hour Counter - Gains 500 ATK/DEF for each counter
function s.countcon3(e)
  return e:GetHandler():GetCounter(0x1044)>2
end
function s.atkval(e,c)
	return c:GetCounter(0x1044)*500
end
--4+ Witching Hour Counter - Target 1 card in your GY, shuffle into deck, draw 1
function s.countcon4(e)
  return e:GetHandler():GetCounter(0x1044)>3
end
function s.gyfilter(c)
  return c:IsAbleToDeck()
end
function s.shufftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter1(chkc) end
  if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.shuffop(e,tp,eg,ep,ev,re,r,rp)
  local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  if not tg then return end
  Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
  local g=Duel.GetOperatedGroup()
  if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
  local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
  if ct==1 then
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
  end
end
--5+ Witching Hour Counter - Unaffected by other cards' effects
function s.countcon5(e)
  return e:GetHandler():GetCounter(0x1044)>4
end
function s.efilter(e,te)
  return te:GetOwner()~=e:GetOwner()
end
--6+ Witching Hour Counter - Full Fiber Jar reset for opponent, including banished/ED pends
function s.countcon6(e)
  return e:GetHandler():GetCounter(0x1044)>5
end
function s.fiberjarcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct=e:GetHandler():GetCounter(0x1044)
  if chk==0 then return ct>0 and e:GetHandler():IsCanRemoveCounter(tp,0x1044,ct,REASON_COST) end
  e:GetHandler():RemoveCounter(tp,0x1044,ct,REASON_COST)
end
function s.fiberjartg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local loc=LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_HAND
  local g=Duel.GetFieldGroup(tp,0,loc)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
  Duel.SetChainLimit(aux.FALSE)
end
function s.fiberjarop(e,tp,eg,ep,ev,re,r,rp,chk)
  local loc=LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_HAND
  local g=Duel.GetFieldGroup(tp,0,loc)
  Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
