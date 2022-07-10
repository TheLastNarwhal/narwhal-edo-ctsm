--Ehir the Omen-Speaker Eternal
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon self and token
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --If leaves field, look at top card of Deck, send to bottom or add to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetTarget(s.peektg)
    e2:SetOperation(s.peekop)
    c:RegisterEffect(e2)
end
s.listed_series={0x200}
--Special Summon self and token
function s.spcostfilter(c)
    return c:IsSetCard(0x200) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)>0 
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x200,TYPES_TOKEN+TYPE_TUNER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        local token=Duel.CreateToken(tp,id+1)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        --Cannot Special Summon non-Synchro non-Fairy monsters from Extra Deck
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetAbsoluteRange(tp,1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY)) end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e1,true)
        --Lizard check
        local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not (c:IsOriginalType(TYPE_SYNCHRO) and c:IsOriginalRace(RACE_FAIRY)) end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e2,true)
        Duel.SpecialSummonComplete()
    end
end
--If leaves field, look at top card of Deck, send to bottom or add to hand
function s.peektg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function s.peekop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,1)
    Duel.ConfirmCards(tp,g)
    if not g:GetFirst():IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.MoveSequence(g:GetFirst(),1)
    else
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
    end
end