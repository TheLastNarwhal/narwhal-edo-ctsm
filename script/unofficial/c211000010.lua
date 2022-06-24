--Sakashima's Deal - Doppelgänger
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --List of counters to better enable copy effects
    for _,counter in ipairs({0x1,0x3,0x8,0xa,0xf,0x10,0x11,0x14,0x16,0x17,0x1f,0x22,0x23,0x26,0x27,0x28,0x29,0x2c,0x2e,0x2b,0x34,0x36,0x40,0x42,0x43,0x44,0x4a,0x147,0x14a,0x202,0x203,0x59,0x20a}) do
        c:EnableCounterPermit(counter,LOCATION_MZONE)
    end
    --Special Summon as effect monster, Special Summon token to opponent's field
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
--Special Summon as effect monster, Special Summon token to opponent's field
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
        and Duel.IsPlayerCanSpecialSummonCount(tp,2) 
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER)
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2000,3000,8,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x199,0x21,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2000,3000,8,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-tp) then return end
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
        --Copy opponent's monster
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,0))
        e3:SetType(EFFECT_TYPE_QUICK_O)
        e3:SetCode(EVENT_FREE_CHAIN)
        e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCountLimit(1)
        e3:SetCost(s.copycost)
        e3:SetTarget(s.copytg)
        e3:SetOperation(s.copyop)
        c:RegisterEffect(e3)
    end
    Duel.SpecialSummonComplete()
    local token=Duel.CreateToken(tp,id+1)
    Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
end
--Copy opponent's monster
--Copy monster/bounce copied monster to hand
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.copyfilter(c)
    return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.copyfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.copyfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
        local code=tc:GetCode()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    e2:SetValue(tc:GetTextDefense())
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_SET_BASE_ATTACK)
    e3:SetValue(tc:GetTextAttack())
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EFFECT_CHANGE_RACE)
    e4:SetValue(tc:GetOriginalRace())
    c:RegisterEffect(e4)
    local e5=e1:Clone()
    e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e5:SetValue(tc:GetOriginalAttribute())
    c:RegisterEffect(e5)
    local e6=e1:Clone()
    e6:SetCode(EFFECT_CHANGE_LEVEL)
    e6:SetValue(tc:GetOriginalLevel())
    c:RegisterEffect(e6)
        if not tc:IsType(TYPE_TRAPMONSTER) then
            c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
        end
    end
end

