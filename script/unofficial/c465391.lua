--Witchinity of the Bog
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --On Summon add "Witch" card from Deck to hand
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  e1:SetCountLimit(1,{id,1})
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)
  --While "Witches' Domain" is on the field, id and any card in your field zone cannot be destroyed by card effects
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e3:SetRange(LOCATION_MZONE)
  e3:SetTargetRange(LOCATION_ONFIELD,0)
  e3:SetCondition(s.indcon)
  e3:SetTarget(s.indtg)
  e3:SetValue(1)
  c:RegisterEffect(e3)
  --During the Main Phase you can Special Summon 1 "Cursed Doll Token"
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1,{id,1})
  e4:SetCondition(s.tkcon)
  e4:SetTarget(s.tktg)
  e4:SetOperation(s.tkop)
  c:RegisterEffect(e4)
  --Same effect as e4 but converted to Quick status if conditions met - sealed due to power
  --[[local e5=e4:Clone()
  e5:SetType(EFFECT_TYPE_QUICK_O)
  e5:SetCode(EVENT_FREE_CHAIN)
  local timing=TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON
  e5:SetHintTiming(timing,timing)
  e5:SetCondition(s.tkquickcon)
  c:RegisterEffect(e5)]]
  --Pay 800 LP, add 1 "Festering Newt" or Witch's Bubbling Cauldron" from your Deck or GY to your hand.
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,3))
  e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e6:SetType(EFFECT_TYPE_IGNITION)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCountLimit(1,{id,1})
  e6:SetCost(s.newtcost)
  e6:SetTarget(s.newttg)
  e6:SetOperation(s.newtop)
  c:RegisterEffect(e6)
end
s.listed_series={0x197,0x2197}
s.listed_names={465386,465393,465394}
--On Summon add "Witch" card from Deck to hand
function s.thfilter(c)
  return c:IsSetCard(0x197) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--While "Witches' Domain" is on the field, id and any card in your field zone cannot be destroyed by card effects
function s.indcon(e)
  return Duel.IsEnvironment(465386)
end
function s.indtg(e,c)
  return c==e:GetHandler() or c:IsLocation(LOCATION_FZONE)
end
--
--
--------------Everything-below-this-line-is-token-related-------------
--
--
--Conditions to turn Token Summon into Quick - sealed due to power
--[[function s.tkquickcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase() and Duel.IsEnvironment(465386)
end]]
--During the Main Phase you can Special Summon 1 "Cursed Doll Token"
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase() --and not Duel.IsEnvironment(465386)
end
function s.tkfilter(c)
  return c:IsCode(id+1)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>=1 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2197,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp) and not Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE,tp)<1 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2197,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp) then return end
  local token=Duel.CreateToken(tp,id+1)
  if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
    --There can only be 1 "Cursed Doll Token" on the field
    token:SetUniqueOnField(1,1,id+1)
    token:SetCounterLimit(0x1043,5)
    --Cannot be Tributed for a Tribute Summon
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(3304)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(1)
    token:RegisterEffect(e1,true)
    --Cannot be used as material for Fusion, Synchro, or Link Summon
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO))
    token:RegisterEffect(e2,true)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e3:SetValue(1)
    token:RegisterEffect(e3,true)
    --Cannot be destroyed by battle
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetValue(1)
    token:RegisterEffect(e4,true)
    --Cannot be destroyed by effects while has counter
    local e5=e4:Clone()
    e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e5:SetCondition(s.indcon2)
    token:RegisterEffect(e5,true)
    --If battled, place 1 Needle Counter on this card
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetCategory(CATEGORY_COUNTER)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_BATTLED)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.ctcon)
    e6:SetOperation(s.ctop)
    token:RegisterEffect(e6,true)
    --During your End Phase, can remove 1 Needle Counter, place 1 Needle Counter on target opponent's monster
    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_COUNTER)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e7:SetCode(EVENT_PHASE+PHASE_END)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1,id)
    e7:SetCondition(s.noquickcon)
    e7:SetCost(s.placecost)
    e7:SetTarget(s.placetg)
    e7:SetOperation(s.placeop)
    token:RegisterEffect(e7,true)
    --Same effect as e7, but if control "Witch of the Bog" can activate on opponent's End Phase
    local e8=e7:Clone()
    e8:SetCondition(s.quickcon)
    token:RegisterEffect(e8,true)
  end
  Duel.SpecialSummonComplete()
end
s.counter_place_list={0x1043}
--s.listed_names={465391}
--Cannot be destroyed by effects while has counter
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():GetCounter(0x1043)>0
end
--If battled, place 1 Needle Counter on this card
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():GetBattledGroupCount()>0
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
  e:GetHandler():AddCounter(0x1043,1)
end
--Conditions to turn place counter into "Quick"
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,465391)
end
--During your End Phase, can remove 1 Needle Counter, place 1 Needle Counter on target opponent's monster
function s.noquickcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()==tp and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,465391)
end
function s.placecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1043,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1043,1,REASON_COST)
end
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
  Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetCounter(0x1043)<1 then
    tc:AddCounter(0x1043,1)
    --1+ Needle Counter - -300 ATK/DEF
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.condition1)
    e1:SetTarget(s.adtg)
    e1:SetValue(s.adval)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(e2)
    --2+ Needle Counter - No Attack/No Effect
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_ATTACK)
    e3:SetCondition(s.condition2)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_DISABLE)
    tc:RegisterEffect(e4)
    --3+ Needle Counter - No Material for Fusion/Synchro/Xyz/Link
    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e5:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e5:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO))
    e5:SetCondition(s.condition3)
    tc:RegisterEffect(e5)
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e6:SetValue(1)
    e6:SetCondition(s.condition3)
    tc:RegisterEffect(e6)
    --4+ Needle Counter - Can send this card to GY, take damage equal to ATK
    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetDescription(aux.Stringid(id,2))
    e7:SetCategory(CATEGORY_DAMAGE)
    e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCondition(s.condition4)
    e7:SetCost(s.sndcost)
    e7:SetOperation(s.sndop)
    tc:RegisterEffect(e7)
    --5+: Send all monsters you control to GY, if sent 3+, send 1 card opponent controls to GY.
    --local e8=Effect.CreateEffect(e:GetHandler())
    --e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    --e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_NEGATE)
    --e8:SetCode(EVENT_PHASE+PHASE_END)
    --e8:SetRange(LOCATION_MZONE)
    --e8:SetCondition(s.condition5)
    --e8:SetOperation(s.sendallop)
    --tc:RegisterEffect(e8) <--Can't get e8 effect to work, even while NOT under a perma negate
  else
    tc:AddCounter(0x1043,1)
  end
end
--1+ Needle Counter - -300 ATK/DEF
function s.condition1(e)
  return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget() and e:GetHandler():GetCounter(0x1043)>0
end
function s.adtg(e,c)
  local bc=c:GetBattleTarget()
  return bc and c:GetCounter(0x1043)~=0 and bc:IsSetCard(0x197)
end
function s.adval(e,c)
  return c:GetCounter(0x1043)*-300
end
--2+ Needle Counter - No Attack/No Effect
function s.condition2(e)
  return e:GetHandler():GetCounter(0x1043)>1
end
--3+ Needle Counter - No Material for Fusion/Synchro/Xyz/Link
function s.condition3(e)
  return e:GetHandler():GetCounter(0x1043)>2
end
--4+ Needle Counter - Can send this card to GY, take damage equal to ATK
function s.condition4(e)
  return e:GetHandler():GetCounter(0x1043)>3
end
function s.sndcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
  atk=e:GetHandler():GetAttack()
  if atk<0 then akt=0 end
  e:SetLabel(atk)
  Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.sndop(e,tp,eg,ep,ev,re,r,rp)
  local dam=e:GetLabel()
  Duel.Damage(tp,dam,REASON_EFFECT)
end
--5+: Send all monsters you control to GY, if sent 3+, send 1 card opponent controls to GY.
--function s.condition5(e)
  --return e:GetHandler():GetCounter(0x1043)>4
--end
--function s.sendallop(e,tp,eg,ep,ev,re,r,rp)
  --local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,e:GetHandler())
  --Duel.SendtoGrave(g,REASON_RULE)
--end
--
--
--------------Everything-above-this-line-is-token-related-------------
--
--
--Pay 800 LP, add 1 "Festering Newt" or Witch's Bubbling Cauldron" from your Deck or GY to your hand.
function s.newtcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckLPCost(tp,1000) end
  Duel.PayLPCost(tp,1000)
end
function s.newtfilter(c)
  return c:IsCode(465393,465394) and c:IsAbleToHand()
end
function s.newttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.newtfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.newtop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.newtfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
