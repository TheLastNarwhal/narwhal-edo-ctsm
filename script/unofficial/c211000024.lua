--Vanir the Bountiful Eternal
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    --If placed in the Monster Zone: Scry, Gain LP and/or Temp Banish
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_MOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.etbcon)
    e1:SetTarget(s.etbtg)
    e1:SetOperation(s.etbop)
    c:RegisterEffect(e1)
end
--If placed in the Monster Zone: Scry, Gain LP and/or Temp Banish
--Condition for trigger
function s.etbcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
end
--Setting up the optional effects
function s.etbtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local scry=s.scrytg(e,tp,eg,ep,ev,re,r,rp,0)
    local gainlp=s.gainlptg(e,tp,eg,ep,ev,re,r,rp,0)
    local tmpban=s.tmpbantg(e,tp,eg,ep,ev,re,r,rp,0)
    if chk==0 then return scry or gainlp or tmpban end
end
--Presenting the choices
function s.etbop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local scry=s.scrytg(e,tp,eg,ep,ev,re,r,rp,0)     --Stringid 1
    local gainlp=s.gainlptg(e,tp,eg,ep,ev,re,r,rp,0) --Stringid 2
    local tmpban=s.tmpbantg(e,tp,eg,ep,ev,re,r,rp,0) --Stringid 3
    local op=-1
    if scry and gainlp and tmpban then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    elseif scry and gainlp then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif scry and tmpban then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))
        if op==1 then
            op=2
        end
    elseif gainlp and tmpban then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if op==0 then
            op=1
        else op=2
        end
    elseif scry then
        op=0
    elseif gainlp then
        op=1
    elseif tmpban then
        op=2
    end
    if op==0 then
        s.scryop(e,tp,eg,ep,ev,re,r,rp)
    elseif op==1 then
        s.gainlpop(e,tp,eg,ep,ev,re,r,rp)
    elseif op==2 then
        s.tmpbanop(e,tp,eg,ep,ev,re,r,rp)
    end
end
--Scry 2 effect
function s.scrytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 and Duel.GetFlagEffect(tp,id)==0 end
end
function s.scryop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)>0 then return end
    local g=Duel.GetDecktopGroup(tp,2)
    Duel.ConfirmCards(tp,g)
    local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
    if opt==1 then
        for tc in g:Iter() do
            Duel.MoveSequence(tc,opt)
            e:SetLabel(opt)
        end
    end
    local bottom=e:GetLabel()
    if bottom==0 then
        Duel.SortDecktop(tp,tp,2)
        e:SetLabel(0)
    elseif bottom==1 then
        Duel.SortDeckbottom(tp,tp,2)
        e:SetLabel(0)
    end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.filter(c)
    return c:IsFaceup() and c:GetDefense()>0
end
function s.gainlptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) and Duel.GetFlagEffect(tp,id+1)==0 end
end
function s.gainlpop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetDefense()>0 then
        Duel.Recover(tp,tc:GetDefense(),REASON_EFFECT)
    end
    Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
end
function s.tmpbantg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.GetFlagEffect(tp,id+2)==0 end
end
function s.tmpbanop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    local tc=g:GetFirst()
    if tc then
        if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            Duel.BreakEffect()
            for tc in g:Iter() do
                if not tc:IsImmuneToEffect(e) then
                    tc:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_SET_CONTROL)
                    e1:SetValue(tc:GetOwner())
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
                    tc:RegisterEffect(e1)
                end
                Duel.ReturnToField(tc)
            end
        end
    end
    Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
end
