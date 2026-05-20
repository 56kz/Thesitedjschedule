module ApplicationHelper
  def suscription_expires_value(suscription)
    suscription&.expires_at&.strftime("%Y-%m-%d") || ""
  end

  def hours_options_for_select
    Suscription::HOURS_VALUE.map { |key, val| ["#{val}h — #{key}", key] }
                            .sort_by { |_, key| Suscription::HOURS_VALUE[key] }
  end
end
