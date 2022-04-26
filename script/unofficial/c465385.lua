--B.E.S. Crystalline Core
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(0x1f)
  --Xyz Summon procedure - 2 Level 8 monsters
  Xyz.AddProcedure(c,nil,8,2)
  -- Can use "B.E.S." monsters as Level 8 materials
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_FIELD)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
  e0:SetCode(EFFECT_XYZ_LEVEL)
  e0:SetRange(LOCATION_EXTRA)
  e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e0:SetTarget(function(e,c) return c:IsSetCard(0x15) end)
  e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 8 or 0 end)
  c:RegisterEffect(e0)
  --Add Counter to a monster when Summoned
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_COUNTER)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetCondition(s.ctcon)
  e1:SetTarget(s.cttg)
  e1:SetOperation(s.ctop)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)
  --Detach 1 material, shuffle cards from hand to Deck, draw same amount, then Special Summon 1 "B.E.S." monster, if can't, shuffle hand to Deck
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1,id)
  e3:SetCost(s.drwcost)
  e3:SetTarget(s.drwtg)
  e3:SetOperation(s.drwop)
  c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
  --Remove up to 3 "B.E.S." counters to negate equal number of cards
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,1))
  e4:SetCategory(CATEGORY_DISABLE)
  e4:SetType(EFFECT_TYPE_QUICK_O)
  e4:SetCode(EVENT_FREE_CHAIN)
  e4:SetRange(LOCATION_MZONE)
  e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e4:SetCountLimit(1,{id,1})
  e4:SetTarget(s.negtg)
  e4:SetOperation(s.negop)
  c:RegisterEffect(e4)
end
s.listed_series={0x15}
--Add Counter to a monster when Summoned
function s.ctfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(0x15) and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
  return eg and eg:IsExists(s.ctfilter,1,nil,tp) and eg:GetFirst()~=e:GetHandler()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local ec=eg:FilterCount(s.ctfilter,nil,tp)
  Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ec,0,0x1f)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=eg:Filter(s.ctfilter,nil,tp)
  local tc=g:GetFirst()
  for tc in aux.Next(g) do
    tc:AddCounter(0x1f,1)
  end
end
--Detach 1 material, shuffle cards from hand to Deck, draw same amount, then Special Summon 1 "B.E.S." monster, if can't, shuffle hand to Deck
function s.drwcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
  c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.cfilter(c,e,sp)
  return c:IsLocation(LOCATION_HAND) and (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x15) and c:IsCanBeSpecialSummoned(e,0,sp,false,false))
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp,chk)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,63,nil)
  if #g==0 then return end
  Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
  Duel.ShuffleDeck(p)
  Duel.BreakEffect()
  Duel.Draw(p,#g,REASON_EFFECT)
  Duel.BreakEffect()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local tc=Duel.SelectMatchingCard(p,s.cfilter,p,LOCATION_HAND,0,1,1,nil,e,p)
  local sc=tc:GetFirst()
  if sc then
    Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
  else
    local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    Duel.ShuffleDeck(p)
  end
end
--Remove up to 3 "B.E.S." counters to negate equal number of cards
function s.negfilter(c)
  return c:IsOnField() and c:IsFaceup()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
  if chk==0 then return ct>0 and Duel.IsCanRemoveCounter(tp,LOCATION_MZONE,0,0x1f,1,REASON_COST) and Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil,e,tp) end
  local cc=Duel.GetCounter(tp,LOCATION_MZONE,0,0x1f)
  if cc==0 then return end
  if cc>3 then cc=3 end
  local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,cc,nil)
  Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,cc,0,0)
  Duel.RemoveCounter(tp,LOCATION_MZONE,0,0x1f,#g,REASON_COST)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tg=Duel.GetTargetCards(e)
  for tc in tg:Iter() do
    Duel.NegateRelatedChain(tc,RESET_TURN_SET)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetValue(RESET_TURN_SET)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
    if tc:IsType(TYPE_TRAPMONSTER) then
      local e3=Effect.CreateEffect(c)
      e3:SetType(EFFECT_TYPE_SINGLE)
      e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
      e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
      e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e3)
    end
  end
end
