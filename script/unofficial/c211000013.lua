--Celestial Realm of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --On activation add 1 "Eternal" monster from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Activation and effects of "Eternal" cards on your field cannot be negated
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetValue(s.effectfilter)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e3)
    --When you take battle damage, can temp banish 1 other card you control
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.tmpbancon)
    e4:SetOperation(s.tmpbanop)
    c:RegisterEffect(e4)
end
s.listed_series={0x200}
--On activation add 1 "Eternal" monster from Deck to hand
function s.thfilter(c)
    return c:IsSetCard(0x200) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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
--Activation and effects of "Eternal" cards on your field cannot be negated
function s.effectfilter(e,ct)
    local p=e:GetHandler():GetControler()
    local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
    return p==tp and te:GetHandler():IsSetCard(0x200) and loc&LOCATION_ONFIELD~=0
end
--When you take battle damage, can temp banish 1 card you control
function s.eternalfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x200) and c:IsOriginalType(TYPE_MONSTER)
end
function s.tmpbancon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp and Duel.IsExistingMatchingCard(s.eternalfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tmpbanfilter(c)
    return c:IsAbleToRemove() and not (c:IsStatus(STATUS_BATTLE_DESTROYED) or c:IsCode(id))
end
function s.eqfilter(c,ec)
    return (c:IsFaceup() and not c:IsStatus(STATUS_BATTLE_DESTROYED)) and ec:CheckEquipTarget(c) 
end
function s.eqfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.tmpbanop(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.tmpbanfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    local tc=g
    if tc then
        if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            Duel.BreakEffect()
            for tc in g:Iter() do
                if tc:IsType(TYPE_EQUIP) and tc:IsPreviousPosition(POS_FACEUP) then
                    e:SetLabel(11)
                    if not tc:IsImmuneToEffect(e) then
                        tc:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
                        local e1=Effect.CreateEffect(e:GetHandler())
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetCode(EFFECT_SET_CONTROL)
                        e1:SetValue(tc:GetOwner())
                        e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
                        tc:RegisterEffect(e1)
                    end
                end
                local pos=e:GetLabel()
                if tc:IsType(TYPE_EQUIP) and pos==11 and not Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil) then
                    Duel.SendtoGrave(tc,REASON_RULE,tp)
                elseif tc:IsType(TYPE_EQUIP) and pos==11 then
                    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tc):GetFirst()
                    Duel.HintSelection(ec,true)
                    if not ec then return end
                    Duel.Equip(tp,tc,ec)
                else
                    Duel.ReturnToField(tc)
                end
            end
        end
    end
end