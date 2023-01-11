--Yuki-Onna Wandering Girl
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
    --Cannot be Special Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e1)
    --Add 1 Level 4 or lower Spirit monster from Deck to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    --Can attack directly
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e3)
    --When Inflict battle damage to opponent, can change to def position, then can change 1 atk position monster opponent controls to def position
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_POSITION)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetOperation(s.posop)
    c:RegisterEffect(e4)
end
s.listed_names={id}
--Add 1 Level 4 or lower Spirit monster from Deck to hand
function s.thfilter(c)
    return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spiritfil(c)
    return c:IsType(TYPE_SPIRIT) and not c:IsCode(id) and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
        local sg=Duel.GetMatchingGroup(s.spiritfil,tp,LOCATION_HAND,0,nil)
        if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.BreakEffect()
            Duel.ShuffleHand(tp)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local sc=sg:Select(tp,1,1,nil):GetFirst()
            Duel.Summon(tp,sc,true,nil)
        end
    end
end
--When Inflict battle damage to opponent, can change to def position, then can change 1 atk position monster opponent controls to def position
function s.posfilter(c)
    return c:IsAttackPos() and c:IsCanChangePosition()
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsAttackPos() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        if Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
            local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
            if #g>0 then
                Duel.HintSelection(g,true)
                Duel.BreakEffect()
                if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=0 then
                    local tc=g:GetFirst()
                    c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
                    --Cannot change battle position
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    e1:SetCondition(s.nochangecon)
                    tc:RegisterEffect(e1)
                end
            end
        end
    end
end
function s.nochangecon(e)
    return e:GetOwner():IsRelateToCard(e:GetHandler()) and e:GetOwner():IsPosition(POS_FACEUP_DEFENSE)
end