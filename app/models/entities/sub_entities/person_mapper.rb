class Entities::SubEntities::PersonMapper
  extend HashMapper

  def self.person_references
    {
      record_references: %w(organization_id assignee_id),
      id_references: %w()
    }
  end

  def self.lead_references
    {
      record_references: %w(assignee_id),
      id_references: %w()
    }
  end

  after_denormalize do |input, output|
    # The field is present only in contacts and is false by default
    if input['is_organization'].nil?
      output[:is_lead] = true
      output[:is_customer] = false
    end
    output[:assignee_type] = "AppUser"
    output
  end

  after_normalize do |input, output|

    output.delete(:contact_id) if input['is_lead']

    # Base CRM does not provide 2 fields for landlines
    if input['phone_work'] && input['phone_work']['landline2']
      output[:mobile].empty? ? output[:mobile] = input['phone_work']['landline2'] : output[:mobile]
    end

    output[:address] ||= {}

    if input['address_work'] && input['address_work']['shipping']
      output[:address][:line1] ||= input['address_work']['shipping']['line1']
      output[:address][:city] ||= input['address_work']['shipping']['city']
      output[:address][:postal_code] ||= input['address_work']['shipping']['postal_code']
      output[:address][:state] ||= input['address_work']['shipping']['region']
      output[:address][:country] ||= input['address_work']['shipping']['country']
    end

    output
  end

  map from('job_title'), to('title')
  map from('first_name'), to('first_name')
  map from('last_name'), to('last_name'), default: "Not Available"
  map from('email/address'), to('email')

  map from('organization_id'), to('contact_id', &:to_i)
  map from('assignee_id'), to('owner_id', &:to_i)

  map from('contact_channel/skype'), to('skype')
  map from('phone_work/landline'), to('phone')
  map from('phone_work/mobile'), to('mobile')
  map from('phone_work/fax'), to('fax')

  map from('address_work/billing/line1'), to('address/line1')
  map from('address_work/billing/city'), to('address/city')
  map from('address_work/billing/postal_code'), to('address/postal_code')
  map from('address_work/billing/region'), to('address/state')
  map from('address_work/billing/country'), to('address/country')
end
