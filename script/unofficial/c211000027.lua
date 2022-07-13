--Lawstones of the Eternal Realm
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activation
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    --LIGHT monsters become "Eternal" monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
    e1:SetValue(0x200)
    c:RegisterEffect(e1)
    --"Eternal" cost replacement
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(CARD_LAWSTONES_ETERNAL_REALM) --not working for others, but working for me -- CARD_LAWSTONES_ETERNAL_REALM
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_HAND,0)
    e2:SetCountLimit(1)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
    --Return 2 of your banished monsters to the GY, add this to your hand
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.retbantg)
    e3:SetOperation(s.retbanop)
    c:RegisterEffect(e3)
end
--"Eternal" cost replacement
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
    local c=e:GetHandler()
	return c:IsSetCard(0x200)
end
function s.repfilter(c)
    return c:IsSetCard(0x200) and c:IsAbleToGraveAsCost()
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
    local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
    Duel.Hint(HINT_CARD,0,id)
    Duel.SendtoGrave(g,REASON_COST)
end
--Return 2 of your banished monsters to the GY, add this to your hand
function s.filter(c,tp)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.retbantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) and e:GetHandler():IsAbleToHand() end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,LOCATION_GRAVE)
end
function s.retbanop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
    if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)~=0 then
        Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,e:GetHandler())
    end
end
