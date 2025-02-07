class Current < ActiveSupport::CurrentAttributes
  # do not delegate user to session, attach users to the current context based on multiple factors as needed
  # authentication of users does not necessarily require creation of sessions
  attribute :session, :user
end
