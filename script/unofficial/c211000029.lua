--Njördir, Sacred Armament of the Eternals
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
    --If placed in the Monster Zone, can equip to monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_MOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.etbequipcon)
    e3:SetTarget(s.etbequiptg)
    e3:SetOperation(s.etbequipop)
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
--If placed in the Monster Zone, can equip to monster
function s.etbequipcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
end
function s.etbequiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() and chkc:IsControler(tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.etbequipop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Equip(tp,c,tc,true) then
        --Atk up
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_EQUIP)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        --Remove
        local e2=Effect.CreateEffect(c)
        e2:SetCategory(CATEGORY_REMOVE)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e2:SetCode(EVENT_BATTLE_START)
        e2:SetRange(LOCATION_SZONE)
        e2:SetCondition(s.rmcon)
        e2:SetTarget(s.rmtg)
        e2:SetOperation(s.rmop)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
        --Add Equip limit
        local e3=Effect.CreateEffect(tc)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_EQUIP_LIMIT)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        e3:SetValue(function(e,c) return e:GetOwner()==c end)
        c:RegisterEffect(e3)
    end
end
--Remove
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetEquipTarget()
end
function s.banfilter(c)
    return c:IsLocation(LOCATION_ONFIELD) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
    if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    g:AddCard(e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
    local g=Group.FromCards(c,tc)
    if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
        local og=Duel.GetOperatedGroup()
        local oc=og:GetFirst()
        for oc in og:Iter() do
            oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
            if oc:IsType(TYPE_FIELD) and oc:IsPreviousPosition(POS_FACEDOWN) then
                oc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
            elseif oc:IsType(TYPE_FIELD) and oc:IsPreviousPosition(POS_FACEUP) then
                oc:RegisterFlagEffect(id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
            elseif oc:IsType(TYPE_EQUIP) and oc:IsPreviousPosition(POS_FACEUP) then
                oc:RegisterFlagEffect(id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
            elseif oc:IsType(TYPE_MONSTER) and oc:IsPreviousLocation(LOCATION_SZONE) then
                oc:RegisterFlagEffect(id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
            end
            if not oc:IsImmuneToEffect(e) then
                oc:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_CONTROL)
                e1:SetValue(oc:GetOwner())
                e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
                oc:RegisterEffect(e1)
            end
        end
        og:KeepAlive()
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetLabelObject(og)
        e2:SetCountLimit(1)
        e2:SetOperation(s.retop)
        Duel.RegisterEffect(e2,tp)
    end
end
--Filter for re-equip of temp banished equip cards
function s.eqfilter(c,ec)
    return c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.eqfilter2(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.retfilter(c)
    return c:GetFlagEffect(id)~=0 and not c:IsType(TYPE_TOKEN)
end
function s.typefilter(c)
    return c:IsType(TYPE_MONSTER)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    local sg=g:Filter(s.retfilter,nil)
    if #sg>1 and sg:GetClassCount(Card.GetOwner)==1 then
        local ft=Duel.GetLocationCount(sg:GetFirst():GetOwner(),LOCATION_MZONE)
        local typ=sg:Filter(s.typefilter,nil)
        if ft==1 and #typ==2 then
            local tc=sg:Select(tp,1,1,nil):GetFirst()
            --This is to ensure that Field/Equip/Equip-Monster cards return "properly"
            --For own equip monster
            if tc:IsType(TYPE_MONSTER) and tc:GetFlagEffect(id+4)~=0 and tc:GetOwner()==tp then
                Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
                sg:RemoveCard(tc)
            else
                local loc=tc:GetPreviousLocation()
                local pos=tc:GetPreviousPosition()
                local val=false
                if tc:GetPreviousPosition()==POS_FACEUP then
                    val=true
                end
                Duel.MoveToField(tc,tp,tc:GetOwner(),loc,pos,val)
                sg:RemoveCard(tc)
            end
        elseif ft==1 and #typ~=2 then
            local tc=sg:GetFirst()
            for tc in sg:Iter() do
                --This is to ensure that Field/Equip/Equip-Monster cards return "properly"
                --For own field spell face-down
                if tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+1)~=0 and tc:GetOwner()==tp then
                    Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEDOWN,false)
                --For opponent field spell face-down
                elseif tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+1)~=0 and tc:GetOwner()~=tp then
                    Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEDOWN,false)
                --For own field spell face-up
                elseif tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+2)~=0 and tc:GetOwner()==tp then
                    Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
                --For opponent field spell face-up
                elseif tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+2)~=0 and tc:GetOwner()~=tp then
                    Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
                --For own equip card (unsure if I need this bit)
                elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()==tp and not Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
                    Duel.SendtoGrave(tc,REASON_RULE,tp)
                --For opponent equip card (unsure if I need this bit)
                elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()~=tp and not Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
                    Duel.SendtoGrave(tc,REASON_RULE,1-tp)
                --For own equip card
                elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()==tp then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc):GetFirst()
                    Duel.HintSelection(ec,true)
                    if not ec then return end
                    Duel.Equip(tp,tc,ec)
                --For opponent equip card
                elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()~=tp then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                    local ec=Duel.SelectMatchingCard(1-tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc):GetFirst()
                    Duel.HintSelection(ec,true)
                    if not ec then return end
                    Duel.Equip(1-tp,tc,ec)
                --For own equip monster
                elseif tc:IsType(TYPE_MONSTER) and tc:GetFlagEffect(id+4)~=0 and tc:GetOwner()==tp then
                    Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
                --For opponent equip monster
                elseif tc:IsType(TYPE_MONSTER) and tc:GetFlagEffect(id+4)~=0 and tc:GetOwner()~=tp then
                    Duel.MoveToField(tc,tp,1-tp,LOCATION_MZONE,POS_FACEUP,true)
                else
                    local loc=tc:GetPreviousLocation()
                    local pos=tc:GetPreviousPosition()
                    local val=false
                    if tc:GetPreviousPosition()==POS_FACEUP then
                        val=true
                    end
                    Duel.MoveToField(tc,tp,tc:GetOwner(),loc,pos,val)
                end
            end
        end
    else
        local tc=sg:GetFirst()
        for tc in sg:Iter() do
            --This is to ensure that Field/Equip/Equip-Monster cards return "properly"
            --For own field spell face-down
            if tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+1)~=0 and tc:GetOwner()==tp then
                Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEDOWN,false)
            --For opponent field spell face-down
            elseif tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+1)~=0 and tc:GetOwner()~=tp then
                Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEDOWN,false)
            --For own field spell face-up
            elseif tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+2)~=0 and tc:GetOwner()==tp then
                Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
            --For opponent field spell face-up
            elseif tc:IsType(TYPE_FIELD) and tc:GetFlagEffect(id+2)~=0 and tc:GetOwner()~=tp then
                Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
            --For own equip card (unsure if I need this bit)
            elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()==tp and not Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
                Duel.SendtoGrave(tc,REASON_RULE,tp)
            --For opponent equip card (unsure if I need this bit)
            elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()~=tp and not Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
                Duel.SendtoGrave(tc,REASON_RULE,1-tp)
            --For own equip card
            elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()==tp then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc):GetFirst()
                Duel.HintSelection(ec,true)
                if not ec then return end
                Duel.Equip(tp,tc,ec)
            --For opponent equip card
            elseif tc:IsType(TYPE_EQUIP) and tc:GetFlagEffect(id+3)~=0 and tc:GetOwner()~=tp then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                local ec=Duel.SelectMatchingCard(1-tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc):GetFirst()
                Duel.HintSelection(ec,true)
                if not ec then return end
                Duel.Equip(1-tp,tc,ec)
            --For own equip monster
            elseif tc:IsType(TYPE_MONSTER) and tc:GetFlagEffect(id+4)~=0 and tc:GetOwner()==tp then
                Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
            --For opponent equip monster
            elseif tc:IsType(TYPE_MONSTER) and tc:GetFlagEffect(id+4)~=0 and tc:GetOwner()~=tp then
                Duel.MoveToField(tc,tp,1-tp,LOCATION_MZONE,POS_FACEUP,true)
            else
                local loc=tc:GetPreviousLocation()
                local pos=tc:GetPreviousPosition()
                local val=false
                if tc:GetPreviousPosition()==POS_FACEUP then
                    val=true
                end
                Duel.MoveToField(tc,tp,tc:GetOwner(),loc,pos,val)
            end
        end
    end
end