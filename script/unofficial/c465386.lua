--Witches' Domain
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --When this card is activated: You can add 1 "Witch of the Moor", "Witch of the Fen", or, "Witch of the Bog" from your Deck to your hand
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1{id,1})
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  --"Witch" monsters gain ATK/DEF equal to cards your opponent controls x 350
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_ATTACK)
  e2:SetRange(LOCATION_FZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x197))
  e2:SetValue(s.adval)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e3)
  --Special Summon 1 "Witch" monster from your hand or GY.
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,1))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_FZONE)
  e4:SetCountLimit(1)
  e4:SetTarget(s.sptg)
  e4:SetOperation(s.spop)
  c:RegisterEffect(e4)
  --If your opponent Summons, Special Summon 1 "Witch" monster - sealed due to power
  --[[local e5=Effect.CreateEffect(c)
  e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e5:SetCode(EVENT_SPSUMMON_SUCCESS)
  e5:SetRange(LOCATION_FZONE)
  e5:SetCountLimit(1,{id,1})
  e5:SetCondition(s.sumcon)
  e5:SetTarget(s.sumtg)
  e5:SetOperation(s.sumop)
  c:RegisterEffect(e5)
  local e6=e5:Clone()
  e6:SetCode(EVENT_SUMMON_SUCCESS)
  c:RegisterEffect(e6)]]
  --If this card is in GY, pay 1500 LP and Tribute 1 monster, place this card in the field zone.
  local e7=Effect.CreateEffect(c)
  e7:SetDescription(aux.Stringid(id,2))
  e7:SetType(EFFECT_TYPE_IGNITION)
  e7:SetRange(LOCATION_GRAVE)
  e7:SetCountLimit(1,id)
  e7:SetCondition(aux.exccon)
  e7:SetCost(s.placecost)
  e7:SetTarget(s.placetg)
  e7:SetOperation(s.placeop)
  c:RegisterEffect(e7)
end
s.listed_series={0x197}
s.listed_names={465387,465389,465391}
--When this card is activated: You can add 1 "Witch of the Moor", "Witch of the Fen", or, "Witch of the Bog" from your Deck to your hand
function s.thfilter(c)
  return c:IsCode(465387,465389,465391) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
  if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
  end
end
--"Witch" monsters gain ATK/DEF equal to cards your opponent controls x 350
function s.adval(e,c)
  return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*250
end
--Special Summon 1 "Witch" monster from your hand or GY.
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
  if #g>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end
--If your opponent Summons, Special Summon 1 "Witch" monster - sealed due to power
--[[function s.spcfilter(c,tp)
  return not c:IsSummonPlayer(tp)
end
function s.spfilter2(c,e,tp)
  return c:IsSetCard(0x197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(s.spcfilter,1,nil,tp) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x197)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
  local tc=g:GetFirst()
  if tc then
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
  end
end]]
--If this card is in GY, pay 1500 LP and Tribute 1 monster, place this card in the field zone.
function s.tribfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsReleasable()
end
function s.placecost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckLPCost(tp,1500) and Duel.CheckReleaseGroupCost(tp,s.tribfilter,1,true,nil,nil,tp) and e:GetHandler():GetFlagEffect(id)==0 end
  e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
  local sg=Duel.SelectReleaseGroupCost(tp,s.tribfilter,1,1,true,nil,nil,tp)
  Duel.Release(sg,REASON_COST)
  Duel.PayLPCost(tp,1500)
end
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler() end
end
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
  if e:GetHandler():IsRelateToEffect(e) then
    Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
  end
end
