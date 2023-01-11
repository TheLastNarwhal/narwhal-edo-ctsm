--Yuki-Onna Rosy Cheeks
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
    --Cannot be Special Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e1)
    --Can attack directly
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e2)
    --When Inflict battle damage to opponent, can change to def position, then can change 1 atk position monster opponent controls to def position
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DAMAGE)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
    --Activate "Yuki-Onna Eternal Winter" from Deck
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.condition)
    e4:SetTarget(s.acttg)
    e4:SetOperation(s.actop)
    c:RegisterEffect(e4)
end
s.listed_names={CARD_YUKI_ONNA_ETERNAL_WINTER,id}
s.listed_series={SET_YUKI_ONNA}
--When Inflict battle damage to opponent, can change to def position, then can change 1 atk position monster opponent controls to def position
function s.posfilter(c)
    return c:IsAttackPos() and c:IsCanChangePosition()
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsAttackPos() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        if Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
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
--Activate "Yuki-Onna Eternal Winter" from Deck
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_HAND)
end
function s.ffilter(c,tp)
    return c:IsCode(CARD_YUKI_ONNA_ETERNAL_WINTER) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.atkfilter(c)
    return c:IsSetCard(SET_YUKI_ONNA) and c:IsAttackPos()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_DECK,0,1,nil,tp) end
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)~=0 then
        --Change all Attack Position "Yuki-Onna" monsters you control to Defense Position
        local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
        if #g>0 then
            Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
        end
    end
end