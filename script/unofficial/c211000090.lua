--Yuki-Onna Eternal Winter
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate: You can add 1 "Yuki-Onna" monster from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    --Opponent cannot target Defense Position "Yuki-Onna" monsters for attacks
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(s.bttg)
    c:RegisterEffect(e2)
    --Spirits may not return
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(s.noreturncon)
    c:RegisterEffect(e3)
end
s.listed_series={SET_YUKI_ONNA}
--Activate: You can add 1 "Yuki-Onna" monster from Deck to hand
function s.thfilter(c)
    return c:IsSetCard(SET_YUKI_ONNA) and c:IsMonster() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #g>0 and Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
        Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end
--Opponent cannot target Defense Position "Yuki-Onna" monsters for attacks
function s.bttg(e,c)
    return c:IsFaceup() and c:IsDefensePos() and c:IsSetCard(SET_YUKI_ONNA)
end
--Spirits may not return
function s.filter(c)
    return c:IsFaceup() and c:IsDefensePos() and c:IsSetCard(SET_YUKI_ONNA)
end
function s.noreturncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
