--Rabou, King of the Eternals
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x200),1,1)
    c:EnableReviveLimit()
    --Direct Attack / cannot be attack target
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    e1:SetCondition(s.checkcon)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(aux.imval2)
    c:RegisterEffect(e2)
    --At End of BP, if this card attacked, temp banish any number of cards you control
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetOperation(s.regop)
    c:RegisterEffect(e3)
end
s.listed_names={211000013}
--Direct Attack / cannot be attack target
function s.cfilter1(c)
    return c:IsFaceup() and c:IsCode(211000013)
end
function s.cfilter2(c)
    return c:IsFaceup() and c:IsSetCard(0x200) and c:IsType(TYPE_MONSTER)
end
function s.checkcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_FZONE,0,1,nil) and not Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
--At End of BP, if this card attacked, temp banish any number of cards you control
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    --Temporarily banish any number of cards you control
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.tmpbanop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
    e:GetHandler():RegisterEffect(e1)
end
--Filter for cards to be banished
function s.tmpbanfilter(c)
    return c:IsAbleToRemove()
end
--Filter for re-equip of temp banished equip cards
function s.eqfilter(c,ec)
    return c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.eqfilter2(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
--Temporarily banish any number of cards you control
function s.tmpbanop(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.tmpbanfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
    local tc=g
    if tc then
        if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            Duel.BreakEffect()
            for tc in g:Iter() do
                --e:SetLabelObject(rc)
                if tc:IsType(TYPE_FIELD) and tc:IsPreviousPosition(POS_FACEDOWN) then
                    e:SetLabel(20)
                elseif tc:IsType(TYPE_FIELD) and tc:IsPreviousPosition(POS_FACEUP) then
                    e:SetLabel(21)
                elseif tc:IsType(TYPE_EQUIP) and tc:IsPreviousPosition(POS_FACEUP) then
                    e:SetLabel(11)
                elseif tc:IsType(TYPE_MONSTER) and tc:IsPreviousLocation(LOCATION_SZONE) then
                    e:SetLabel(30)
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
                --This is to ensure that Field/Equip/Equip-Monster cards return "properly"
                local pos=e:GetLabel()
                if tc:IsType(TYPE_FIELD) and pos==20 then
                    Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEDOWN,false)
                elseif tc:IsType(TYPE_FIELD) and pos==21 then
                    Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
                elseif tc:IsType(TYPE_EQUIP) and pos==11 and not Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
                    Duel.SendtoGrave(tc,REASON_RULE,tp)
                elseif tc:IsType(TYPE_EQUIP) and pos==11 then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc):GetFirst()
                    Duel.HintSelection(ec,true)
                    if not ec then return end
                    Duel.Equip(tp,tc,ec)
                elseif tc:IsType(TYPE_MONSTER) and pos==30 then
                    Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
                else
                    Duel.ReturnToField(tc)
                end
            end
        end
    end
end