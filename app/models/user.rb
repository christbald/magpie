class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :taggings
  has_many :hashtags, -> { distinct }, through: :taggings
  has_many :active_relationships, class_name:   "Relationship",
                                  foreign_key:  "follower_id",
                                  dependent:    :destroy
  has_many :passive_relationships,  class_name:   "Relationship",
                                    foreign_key:  "followed_id",
                                    dependent:    :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :projects, dependent: :destroy
  has_one  :right, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token, :new_hashtags
  before_save :downcase_email, unless: :guest?
  before_create :create_activation_digest, unless: :guest
  validates :name, presence: true,
                   length: { maximum: 50 }
  validates :identity, :format => { with: /\A(?=.*[a-z])[a-z\d]+\Z/i }, length: { maximum: 20}
  VALID_EMAIL_REGEX = /.+@.+/#/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    unless: :guest?
  has_secure_password
  validates :password, presence: true,
                       length: { minimum: 6 },
                       allow_nil: true,
                       unless: :guest?

   # Returns the hash digest of the given string.
   def User.digest(string)
     cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                   BCrypt::Engine.cost
     BCrypt::Password.create(string, cost: cost)
   end

   def self.new_guest
     length = 10
     guest_name = "guest#{Random.rand(length)}"
     while User.pluck(:identity).include?(guest_name)
       length = length * 10
       guest_name = "guest#{Random.rand(length)}"
     end
     new { |u| u.guest = true, u.name = "Guest User", u.password = "guest", u.identity = guest_name}
   end

   # Returns a random token.
   def User.new_token
     SecureRandom.urlsafe_base64
   end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a passwod reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed.
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    hashtags = self.hashtags.map { |h| "'#{h.tag}'" }.join(", ")
    # All microposts from
    #   following
    #   OR self
    #   OR post bot
    #   OR containing hashtags of interest
    #   OR user is mentioned in micropost
    #! LEFT_JOIN because we want also microposts without hashtags/taggings
    hashtags_string = hashtags.length == 0 ? "" : "OR hashtags.tag IN (#{hashtags})"
    Micropost.joins("LEFT JOIN taggings ON taggings.micropost_id = microposts.id
                     LEFT JOIN hashtags ON hashtags.id = taggings.hashtag_id").where(
              "microposts.user_id IN (#{following_ids})
               OR microposts.user_id = :user_id
               OR microposts.user_id = :postbot_id
               #{hashtags_string}
               OR microposts.mentions LIKE '%#{self.identity}%'",
               user_id: self.id,
               postbot_id: User.find_by(email: Rails.application.config.postbot_email).id).distinct
  end

  # Following a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollowing a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  #Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  def update_email
    create_activation_digest
    self.save
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
