--Koihsa, Devourer of Sanity
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Can only control 1 id
  c:SetUniqueOnField(1,0,id)
  --Contact Fusion procedure and material list
  c:EnableReviveLimit()
  Fusion.AddProcMix(c,true,true,465387,465389,465391)
  Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
  --Gains 100 ATK for each opponent's banished cards
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(s.atkval)
  c:RegisterEffect(e1)
  --During the End Phase you can Special Summon 1 "Nightmare Token"
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EVENT_PHASE+PHASE_END)
  e2:SetCondition(s.tokencon)
  e2:SetCountLimit(1,{id,1})
  e2:SetTarget(s.tktg)
  e2:SetOperation(s.tkop)
  c:RegisterEffect(e2)
  --Flag operation for conditional Token Summon
  aux.GlobalCheck(s,function()
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_DESTROYED)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1,0)
  end)
  --Return card opponent controls to hand, banish card from hand
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,2))
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_CHAINING)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1,{id,2})
  e3:SetCondition(s.condition)
  e3:SetTarget(s.tg1)
  e3:SetOperation(s.op1)
  c:RegisterEffect(e3)
  --Special Summon 1 "Witchinity" monster from hand/GY
  local e4=e3:Clone()
  e4:SetDescription(aux.Stringid(id,3))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e4:SetCountLimit(1,{id,2})
  e4:SetTarget(s.tg2)
  e4:SetOperation(s.op2)
  c:RegisterEffect(e4)
  --Add 1 of opponent's face-up banished cards to hand
  local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.tg3)
	e5:SetOperation(s.op3)
	c:RegisterEffect(e5)
end
s.listed_names={465387,465389,465391}
s.material_setcode={0x197}
--Contact Fusion procedure
function s.contactfil(tp)
  return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
  Duel.ConfirmCards(1-tp,g)
  Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
  return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
--Gains 100 ATK for each opponent's banished cards
function s.atkval(e,c)
  return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_REMOVED)*100
end
--
--
--------------Everything-below-this-line-is-token-related-------------
--
--
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=eg:GetFirst()
  if tc:IsCode(id+1) then
    Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
    --Debug.Message("[flag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
  end
end
--Condition for Token Summon
function s.tokencon(e,tp,eg,ep,ev,re,r,rp)
  --Debug.Message("[flag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
  return Duel.GetFlagEffect(tp,id)==0
end
--During the End Phase you can Special Summon 1 "Nightmare Token"
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>=1 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2000,1000,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE,tp)<1 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2000,1000,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp) then return end
  local token=Duel.CreateToken(tp,id+1)
  if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
    --If this card battles opponent's monster, banish the top card(s) of opponent's deck equal to Level of battled monster, during end Battle Phase, if this effect activated, destroy this card.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.banishcon)
    e1:SetOperation(s.banishop)
    token:RegisterEffect(e1,true)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e2:SetProperty(EFFECT_FLAG_REPEAT)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    token:RegisterEffect(e2,true)
    --Shift type to effect, because it's clearly an effect monster even if it's a token
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_REMOVE_TYPE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(TYPE_NORMAL)
    token:RegisterEffect(e3,true)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_ADD_TYPE)
    e4:SetValue(TYPE_EFFECT)
    token:RegisterEffect(e4,true)
  end
  Duel.SpecialSummonComplete()
end
--If this card battles opponent's monster, banish the top card(s) of opponent's deck equal to Level of battled monster, during end Battle Phase, if this effect activated, destroy this card.
function s.banishcon(e)
	return e:GetHandler():GetBattleTarget()
end
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
  local val=e:GetHandler():GetBattleTarget():GetLevel()
  local tg=Duel.GetDecktopGroup(1-tp,val)
  if chk==0 then return val>0 and tg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==val end
  Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,val,1-tp,LOCATION_DECK)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
  local val=e:GetHandler():GetBattleTarget():GetLevel()
  if val==0 then return end
  local tg=Duel.GetDecktopGroup(1-tp,val)
  Duel.DisableShuffleCheck()
  Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)
  e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id+1)>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
--
--
--------------Everything-above-this-line-is-token-related-------------
--
--
--Check for opponent's activated Spell Card/effect or monster effect
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return rp~=tp and (re:IsActiveType(TYPE_MONSTER) or re:IsActiveType(TYPE_SPELL)) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
--Return opponent's card, banish card from their hand or field
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
  if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
  local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
  local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  local g=tg:Filter(Card.IsRelateToEffect,nil,e)
  if #g>0 then
    if Duel.SendtoHand(g,nil,REASON_EFFECT) then
      Duel.BreakEffect()
      if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
      local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
      if #g2>0 then
        local sg=g2:Select(1-tp,1,1,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
      end
    end
  end
end
--Special Summon 1 "Witchinity" monster from hand/GY
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
  if #g>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end
--Add 1 of opponent's face-up banished cards to hand
function s.thfilter(c)
  return c:IsLocation(LOCATION_REMOVED) and c:IsFaceup() and c:IsAbleToHand()
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_REMOVED,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_REMOVED,1,1,nil)
  if #tc>0 then
    Duel.SendtoHand(tc,tp,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,tc)
  end
end
