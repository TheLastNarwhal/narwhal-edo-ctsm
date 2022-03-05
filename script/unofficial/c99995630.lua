--Multi-Reactor • SKY FIRE
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activate
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  e0:SetHintTiming(0,TIMING_END_PHASE)
  c:RegisterEffect(e0)
  --Send to GY or Shuffle back from GY to gain effect
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetHintTiming(0,TIMING_END_PHASE)
  e1:SetCountLimit(1,{id,0})
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
end
s.listed_series={0x63}
s.listed_names={15175429,52286175,89493368}
--Check for a "Reactor" monster
function s.togravefil(c)
  return c:IsSetCard(0x63) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.todeckfil(c)
  return c:IsSetCard(0x63) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
--Sets up the choices for to GY or to Deck
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.togravefil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
    local b2=Duel.IsExistingMatchingCard(s.todeckfil,tp,LOCATION_GRAVE,0,1,nil,tp)
    if chk==0 then return b1 or b2 end
end
--Send 1 "Reactor" monster from hand or Deck to GY
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.togravefil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
    local b2=Duel.IsExistingMatchingCard(s.todeckfil,tp,LOCATION_GRAVE,0,1,nil,tp)
    if not (b1 or b2) then return end
    local op=aux.SelectEffect(tp,
        {b1,aux.Stringid(id,2)},
        {b2,aux.Stringid(id,3)})
    local g
    if op==1 then
        g=Duel.SelectMatchingCard(tp,s.togravefil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
        Duel.SendtoGrave(g,REASON_EFFECT)
    elseif op==2 then
        g=Duel.SelectMatchingCard(tp,s.todeckfil,tp,LOCATION_GRAVE,0,1,1,nil,tp)
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    local c=e:GetHandler()
    local tc=g:GetFirst()
    if tc:IsCode(89493368) then
      --Negate opponent's first summon if sent/return Summon Reactor
      local e1=Effect.CreateEffect(c)
      e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
      e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
      e1:SetCode(EVENT_SPSUMMON)
      e1:SetRange(LOCATION_SZONE)
      e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
      e1:SetCondition(s.negsumcon)
      e1:SetTarget(s.negsumtg)
      e1:SetOperation(s.negsumop)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      c:RegisterEffect(e1)
    elseif tc:IsCode(52286175) then
      --Negate opponent's first trap effect if sent/return Trap Reactor
      local e2=Effect.CreateEffect(c)
      e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
      e2:SetCode(EVENT_CHAIN_SOLVING)
      e2:SetRange(LOCATION_SZONE)
      e2:SetCountLimit(1)
      e2:SetCondition(s.negcon1)
      e2:SetOperation(s.negop)
      e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      c:RegisterEffect(e2)
      aux.DoubleSnareValidity(c,LOCATION_SZONE)
    elseif tc:IsCode(15175429) then
      --Negate opponent's first spell effect if sent/return Spell Reactor
      local e3=Effect.CreateEffect(c)
      e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
      e3:SetCode(EVENT_CHAIN_SOLVING)
      e3:SetRange(LOCATION_SZONE)
      e3:SetCountLimit(1)
      e3:SetCondition(s.negcon2)
      e3:SetOperation(s.negop)
      e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      c:RegisterEffect(e3)
    end
end
function s.negcon1(e,tp,eg,ep,ev,re,r,rp)
  return rp~=tp and re:IsActiveType(TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
  return rp~=tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local rc=re:GetHandler()
  if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
    Duel.Destroy(rc,REASON_EFFECT)
  end
end
function s.negsumcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.GetCurrentChain(true)==0 --re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
function s.negsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.negsumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
