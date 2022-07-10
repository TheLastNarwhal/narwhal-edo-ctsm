--Anar the All-Seeing Eternal
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon self and token
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --If a card you own is banished, add 1 "Eternal" Spell/Trap Card from Deck to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
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
    and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x200,TYPES_TOKEN+TYPE_TUNER,0,0,2,RACE_FAIRY,ATTRIBUTE_LIGHT) 
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
--If a card you own is banished, add 1 "Eternal" Spell/Trap Card from Deck to hand
function s.filter(c,tp)
    return not c:IsType(TYPE_TOKEN) and c:GetOwner()==tp
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter,1,nil,tp)
end
function s.thfilter(c)
    return (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x200)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
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