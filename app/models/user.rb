class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  
  
  
  
  has_many :favorites
  has_many :favoritings, through: :favorites, source: :micropost
  has_many :reverses_of_favorites, class_name: 'Favorites', foreign_key: 'favorite_id'
  has_many :favoritemicroposts, through: :reverses_of_favorites, source: :micropost
  

  def favorite(other_post)
    unless self == other_post
      self.favorites.find_or_create_by(micropost_id: other_post.id)
    end
  end

  def unfavorite(other_post)
    favorite = self.favorites.find_by(micropost_id: other_post.id)
    favorite.destroy if favorite
  end

  def favoriting?(other_post)
    self.favoritings.include?(other_post)
  end  
  def feed_favorites
    Micropost.where(user_id: self.favoritings_ids + [self.id])
  end  
    
  
end
