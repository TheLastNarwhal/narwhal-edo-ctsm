--Sakashima the Perfect Reflection
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,3,s.lcheck)
    --List of counters to better enable copy effects
    for _,counter in ipairs({0x1,0x3,0x8,0xa,0xf,0x10,0x11,0x14,0x16,0x17,0x1f,0x22,0x23,0x26,0x27,0x28,0x29,0x2c,0x2e,0x2b,0x34,0x36,0x40,0x42,0x43,0x44,0x4a,0x147,0x14a,0x202,0x203,0x59,0x20a}) do
        c:EnableCounterPermit(counter,LOCATION_MZONE)
    end
    --Gains ATK equal to the combined ATK of all monsters this card points to
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --Cannot be destroyed by battle while pointing to a Spell monster
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --Unaffected by activated effects while pointing to a Spell monster
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
    --Copy monster/bounce copied monster to hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetCost(s.copycost)
    e4:SetTarget(s.copytg)
    e4:SetOperation(s.copyop)
    c:RegisterEffect(e4)
end
--Check Link Materials for Spell monster
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsType,1,nil,TYPE_SPELL,lc,sumtype,tp)
end
--Gains ATK equal to the combined ATK of all monsters this card points to
function s.atkval(e,c)
    local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
    return g:GetSum(Card.GetAttack)
end
--Cannot be destroyed by battle while pointing to a Spell monster
function s.indcon(e)
    return #(e:GetHandler():GetLinkedGroup():Filter(Card.IsType,nil,TYPE_SPELL))>0
end
--Unaffected by activated effects while pointing to a Spell monster
function s.immval(e,te)
    return #(e:GetHandler():GetLinkedGroup():Filter(Card.IsType,nil,TYPE_SPELL))>0 and te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer()~=te:GetHandlerPlayer() and te:GetOwner():GetAttack()<=e:GetHandler():GetAttack() and te:IsActivated()
end
--Copy monster/bounce copied monster to hand
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.copyfilter(c)
    return not c:IsCode(id)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp|tp) and chkc:IsLocation(LOCATION_MZONE) and s.copyfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
        local code=tc:GetOriginalCodeRule()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(code)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        if not tc:IsType(TYPE_TRAPMONSTER) then
            c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
        end
    end
    Duel.SendtoHand(tc,nil,REASON_EFFECT)
end