
##
## skip: careers@wasya.co
## skip: mishellduvrazka2023|wasteplacellc|smttest42|robincroom|acelec|rleer24|statusunknown03|claricefth|abogadooctavioarango|claudenicefh|email4gregory|morishitaarata|314658|alisa406|dawnmeverly|faizana1298|jandrews555|midwestksp|mj8712|msohaibhere|piousbox|poxlovi|snehagophane99|stephenkim79
##
## exceptions: finradrnm@finra.org
##

filter = nil
WcoEmail::EmailFilter.active.each do |_filter|
  filter = _filter
  case filter.kind
  when WcoEmail::EmailFilter::KIND_ADD_TAG,
       WcoEmail::EmailFilter::KIND_REMOVE_TAG,
       WcoEmail::EmailFilter::KIND_AUTORESPOND_TMPL,
       WcoEmail::EmailFilter::KIND_AUTORESPOND_EACT

    aject_id = case filter.kind
      when WcoEmail::EmailFilter::KIND_ADD_TAG,
           WcoEmail::EmailFilter::KIND_REMOVE_TAG
        filter.tag_id
      when WcoEmail::EmailFilter::KIND_AUTORESPOND_TMPL
        filter.email_template_id
      when WcoEmail::EmailFilter::KIND_AUTORESPOND_EACT
        filter.email_action_template_id
      end
    # puts! aject_id, 'aject_id'

    aject_type = case filter.kind
      when WcoEmail::EmailFilter::KIND_ADD_TAG,
           WcoEmail::EmailFilter::KIND_REMOVE_TAG
        'Wco::Tag'
      when WcoEmail::EmailFilter::KIND_AUTORESPOND_TMPL
        'WcoEmail::EmailTemplate'
      when WcoEmail::EmailFilter::KIND_AUTORESPOND_EACT
        'WcoEmail::EmailActionTemplate'
      end
    # puts! aject_type, 'aject_type'

    aject_kind = filter.kind
    # aject_kind = case filter.kind
    #   when WcoEmail::EmailFilter::KIND_AUTORESPOND_EACT
    #     filter.kind
    #   else
    #     filter.kind
    #   end
    # puts! aject_kind, 'aject_kind'


    action_ids = WcoEmail::EmailFilterAction.where({
      kind: filter.kind,
      aject_id: aject_id,
    }).distinct(:email_filter_id)
    new_filter = WcoEmail::EmailFilter.where( :id.in => action_ids ).first

    if new_filter
      puts "+++ filter exists"
    else
      new_filter = WcoEmail::EmailFilter.new({
        actions_attributes: [{
          kind: aject_kind,
          aject_type: aject_type,
          aject_id: aject_id,
        }] })

      new_filter.save!
      puts "+++ created new filter #{new_filter.id}"
    end

    cond_field = WcoEmail::EmailFilterCondition::FIELD_FROM
    cond_op = WcoEmail::EmailFilterCondition::OPERATOR_MATCH
    cond_value = filter.from_exact
    if cond_value.blank?
      cond_field = WcoEmail::EmailFilterCondition::FIELD_SUBJECT
      cond_value = filter.subject_exact
    end
    if cond_value.blank?
      cond_field = WcoEmail::EmailFilterCondition::FIELD_FROM
      cond_op = WcoEmail::EmailFilterCondition::OPERATOR_REGEX
      cond_value = filter.from_regex
    end
    if cond_value.blank?
      cond_field = WcoEmail::EmailFilterCondition::FIELD_SUBJECT
      cond_op = WcoEmail::EmailFilterCondition::OPERATOR_REGEX
      cond_value = filter.subject_regex
    end
    if cond_value.blank?
      cond_field = WcoEmail::EmailFilterCondition::FIELD_BODY
      cond_op = WcoEmail::EmailFilterCondition::OPERATOR_MATCH
      cond_value = filter.body_exact
    end
    if cond_value.blank?
      throw '+++ cond_value cannot be blank'
    end
    # puts! cond_field, 'cond_field'
    # puts! cond_value, 'cond_value'

    new_condition = WcoEmail::EmailFilterCondition.where({
      email_filter_id: new_filter.id,
      field: cond_field,
      operator: cond_op,
      value: cond_value,
    }).first
    if new_condition
      puts "+++ condition exists"
    else
      new_condition = WcoEmail::EmailFilterCondition.new({
        email_filter_id: new_filter.id,
        field: cond_field,
        operator: cond_op,
        value: cond_value,
      })
      new_condition.save!
      puts "+++ created new condition #{new_condition.id}"
    end

    filter.conversations.update_all( filter_id: new_filter.id )
    filter.update( status: 'inactive' )

  end

end



