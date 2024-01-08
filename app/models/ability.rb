# frozen_string_literal: true

# require 'cancancan'

## v0.0.1 :: 2023-12-26
class Ability
  include ::CanCan::Ability

  def initialize(user)

    if user

      if [ 'piousbox@gmail.com', 'victor@piousbox.com', 'victor@wasya.co' ].include? user.email
        can :manage, :all
      end

    end

    can [ :open_permission ], Wco
    # can [ :open_permission ], WcoEmail

  end
end
