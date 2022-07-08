--Sakashima's Mask of Identities
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --Target 1 monster you control whose original name includes "Sakashima" or 1 face-up monster your opponent controls; equip this card to it
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    --Negate your opponent's monster effect with the same name as the monster equiped with this card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0,LOCATION_ONFIELD)
    e2:SetTarget(s.distg)
    e2:SetLabelObject(e1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.discon)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
    --Equipped to a monster you control:
    --Gains 500 ATK/DEF
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetValue(500)
    e4:SetCondition(aux.AttractionEquipCon(true))
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
    --If equipped monster would be destroyed by battle or card effect, destroy this card instead
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_EQUIP)
    e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e6:SetCode(EFFECT_DESTROY_SUBSTITUTE)
    e6:SetCondition(aux.AttractionEquipCon(true))
    e6:SetValue(s.repval)
    c:RegisterEffect(e6)
    --Equipped to a monster your opponent controls:
    --Loses 500 ATK equal to the amount of Spell monsters on your field
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_EQUIP)
    e7:SetCode(EFFECT_UPDATE_ATTACK)
    e7:SetValue(s.atkval)
    e7:SetCondition(aux.AttractionEquipCon(false))
    c:RegisterEffect(e7)
    --If this card is sent to the GY, except by its own effect, Special Summon this card as an Effect monster
    local e8=Effect.CreateEffect(c)
    e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_TO_GRAVE)
    e8:SetProperty(EFFECT_FLAG_DELAY)
    e8:SetCountLimit(1,id)
    e8:SetCondition(s.spcon)
    e8:SetTarget(s.sptg)
    e8:SetOperation(s.spop)
    e8:SetLabelObject(e6)
    c:RegisterEffect(e8)
end
s.listed_names={211000000,211000003,211000004,211000005,211000006,211000007,211000008,211000009,211000010,211000011}
--Target 1 monster you control whose original name includes "Sakashima" or 1 face-up monster your opponent controls; equip this card to it
function s.eqtgfilter(c,tp)
    local code=c:IsOriginalCodeRule(211000000,211000003,211000004,211000005,211000006,211000007,211000008,211000009,211000010,211000011)
    return c:IsFaceup() and (code and not c:IsCode(id) or (not c:IsControler(tp)))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqtgfilter(chkc,tp) end
    if chk==0 then
        return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(s.eqtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if (not c:IsLocation(LOCATION_SZONE)) or (not c:IsRelateToEffect(e)) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
        e:SetLabel(tc:GetCode())
        --Debug.Message("[label] is "..tostring(e:GetLabel()))
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(s.eqlim)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        c:RegisterEffect(e1)
    else
        c:CancelToGrave(false)
    end
end
function s.eqlim(e,c)
    return c:GetControler()==e:GetHandlerPlayer() or e:GetHandler():GetEquipTarget()==c
end
--Negate your opponent's monster effect with the same name as the monster equiped with this card
function s.distg(e,c)
    --Debug.Message("[label for neg] is "..tostring(e:GetLabelObject():GetLabel()))
    local tc=e:GetLabelObject():GetLabel()
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetCode()==tc
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetCode()==e:GetHandler():GetEquipTarget():GetCode()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end
--Equipped to a monster you control
--If equipped monster would be destroyed by battle or card effect, destroy this card instead
function s.repval(e,re,r,rp)
    e:SetLabel(66)
    return (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0
end
--Equipped to a monster your opponent controls:
--Loses 500 ATK equal to the amount of Spell monsters on your field
function s.atkval(e,c)
    local atk=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_SPELL),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*-500
    return atk
end
--If this card is sent to the GY, except by its own effect, Special Summon this card as an Effect monster
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetLabelObject():GetLabel()~=66
end
--Checking for activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then return end
    c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL)
    if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
        c:AddMonsterAttributeComplete()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(RACE_AQUA)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(ATTRIBUTE_WATER)
        c:RegisterEffect(e2)
    end
    Duel.SpecialSummonComplete()
end