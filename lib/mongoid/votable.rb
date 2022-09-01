module Mongoid
  module Votable
    extend ActiveSupport::Concern

    # How many points should be assigned for each up or down vote.
    # This array should be manipulated using Votable.vote_point method
    VOTE_POINT = {}

    included do
      field :votable, type: Hash

      index({ "votable.votes_count" => 1 })
      index({ "votable.votes_point" => 1 })

      scope :most_voted, -> { order_by(["votable.votes_count", :desc]) }
      scope :best_voted, -> { order_by(["votable.votes_point", :desc]) }

      # Set vote point for each up (down) vote on an object of this class
      def self.vote_point(klass = self, options = nil)
        VOTE_POINT[self.name] ||= {}
        VOTE_POINT[self.name][klass.name] ||= options
      end

      #
      # We usually need to show current_user his voting value on votable object
      # voting value can be nil (not voted yet), :up or :down
      # from voting value, we can decide it should be new vote or revote with :up or :down
      # In this case, validation can be skip to maximize performance
      #
      # Make a vote on an object of this class
      #
      # @param [Hash] options a hash containings:
      #   - :votee_id: the votee document id
      #   - :voter_id: the voter document id
      #   - :value: :up or :down
      #   - :revote: change from vote up to vote down
      #   - :unvote: unvote the vote value (:up or :down)
      #
      def self.vote(options)
        options.symbolize_keys!
        value = options[:value]
        votee_id = options[:votee_id]
        voter_id = options[:voter_id]

        klass = options[:class]
        klass ||= VOTE_POINT.keys.include?(name) ? name : collection.name.classify
        value_point = VOTE_POINT[klass][klass]

        if options[:revote]
          if value == :up
            positive_field = :up_voter_ids
            negative_field = :down_voter_ids
            point_delta = value_point[:up] - value_point[:down]
          else
            positive_field = :down_voter_ids
            negative_field = :up_voter_ids
            point_delta = -value_point[:up] + value_point[:down]
          end

          update_result = collection.update_one({
            # Validate voter_id did a vote with value for votee_id
            :_id => votee_id,
            "votable.#{positive_field.to_s}" => { '$ne' => voter_id },
            "votable.#{negative_field.to_s}" => voter_id
          }, {
            # then update
            '$pull' => { "votable.#{negative_field.to_s}" => voter_id },
            '$push' => { "votable.#{positive_field.to_s}" => voter_id },
            '$inc' => {
              "votable.votes_point" => point_delta
            }
          }, {
            :safe => true
          })

        elsif options[:unvote]
          if value == :down
            positive_field = :down_voter_ids
            negative_field = :up_voter_ids
          else
            positive_field = :up_voter_ids
            negative_field = :down_voter_ids
          end

          # Check if voter_id did a vote with value for votee_id
          update_result = collection.update_one({
            # Validate voter_id did a vote with value for votee_id
            :_id => votee_id,
            "votable.#{negative_field.to_s}" => { '$ne' => voter_id },
            "votable.#{positive_field.to_s}" => voter_id
          }, {
            # then update
            '$pull' => { "votable.#{positive_field.to_s}" => voter_id },
            '$inc' => {
              "votable.votes_count" => -1,
              "votable.votes_point" => -value_point[value]
            }
          }, {
            :safe => true
          })

        else # new vote
          if value == :up
            positive_field = :up_voter_ids
          else
            positive_field = :down_voter_ids
          end

          update_result = collection.update_one({
            # Validate voter_id did not vote for votee_id yet
            :_id => votee_id,
            "votable.up_voter_ids" => { '$ne' => voter_id },
            "votable.down_voter_ids" => { '$ne' => voter_id }
          }, {
            # then update
            '$push' => { "votable.#{positive_field.to_s}" => voter_id },
            '$inc' => {
              "votable.votes_count" => +1,
              "votable.votes_point" => value_point[value] }
          }, {
            :safe => true
          })
        end

        # Only update parent class if votee is updated successfully
        success = ( update_result.documents[0]['err'] == nil and
          update_result.documents[0]['nModified'] == 1 and
          update_result.documents[0]['n'] == 1 )

        if success
          VOTE_POINT[klass].each do |class_name, value_point|
            # For other class in VOTE_POINT options, if is parent of current class
            next unless relation_metadata = relations[class_name.underscore]
            votee ||= options[:votee] || find(options[:votee_id])
            # If can find current votee foreign_key value for that class
            next unless foreign_key_value = votee.read_attribute(relation_metadata.foreign_key.to_sym)

            # Update that class / collection
            inc_options = if options[:revote]
              {
                "votable.votes_point" => ( value == :up ?
                   value_point[:up] - value_point[:down] :
                  -value_point[:up] + value_point[:down] )
              }
            elsif options[:unvote]
              {
                "votable.votes_count" => value_point[:not_increase_votes_count] ? 0 : -1,
                "votable.votes_point" => -value_point[value]
              }
            else
              {
                "votable.votes_count" => value_point[:not_increase_votes_count] ? 0 : 1,
                "votable.votes_point" => value_point[value]
              }
            end

            class_name.constantize.collection.update_one(
              { :_id => foreign_key_value },
              { '$inc' =>  inc_options }
            )
          end
        end

        success
      end

    end

    # Make a vote on this votee
    #
    # @param [Hash] options a hash containings:
    #   - :voter_id: the voter document id
    #   - :value: vote :up or vote :down
    def vote(options)
      options[:votee_id] ||= _id
      options[:votee] ||= self

      if options[:unvote]
        options[:value] ||= vote_value(options[:voter_id])
      else
        options[:revote] ||= !vote_value(options[:voter_id]).nil?
      end

      self.class.vote(options)
    end

    # Get a voted value on this votee
    #
    # Let's NOT CONVERT bson::objectid's to strings. _vp_ 2022-08-31
    #
    # @param [Mongoid Object, BSON::ObjectId] voter is Mongoid object the id of the voter who made the vote
    def vote_value(voter)
      voter_id = voter.is_a?(BSON::ObjectId) ? voter.to_s : voter.is_a?(String) ? voter : voter.id.to_s

      return :up if up_voter_ids.try(:include?, voter_id)
      return :down if down_voter_ids.try(:include?, voter_id)
    end

    # Get the number of up votes
    def up_votes_count
      up_voter_ids.length
    end

    # Get the number of down votes
    def down_votes_count
      down_voter_ids.length
    end

    # Get the number of votes count
    def votes_count
      if self.has_attribute?(:votable)
        self["votable"]["votes_count"]
      else
        0
      end
    end

    # Get the votes point
    def votes_point
      if self.has_attribute?(:votable)
        self["votable"]["votes_point"]
      else
        0
      end
    end
    alias :votes_score :votes_point

    # Array of up voter ids
    def up_voter_ids
      if self.has_attribute?(:votable)
        self['votable']["up_voter_ids"]
      else
        []
      end
    end

    # Array of down voter ids
    def down_voter_ids
      if self.has_attribute?(:votable)
        self["votable"]["down_voter_ids"]
      else
        []
      end
    end
  end
end
